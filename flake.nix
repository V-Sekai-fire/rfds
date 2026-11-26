{
  description = "The RFD site, built offline from this repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hex-jason = {
      url = "https://repo.hex.pm/tarballs/jason-1.4.5.tar";
      flake = false;
    };
    hex-mdex = {
      url = "https://repo.hex.pm/tarballs/mdex-0.14.6.tar";
      flake = false;
    };
    hex-mdex_native = {
      url = "https://repo.hex.pm/tarballs/mdex_native-0.3.1.tar";
      flake = false;
    };
    hex-nimble_options = {
      url = "https://repo.hex.pm/tarballs/nimble_options-1.2.0.tar";
      flake = false;
    };
    hex-nimble_parsec = {
      url = "https://repo.hex.pm/tarballs/nimble_parsec-1.4.2.tar";
      flake = false;
    };
    hex-rustler_precompiled = {
      url =
        "https://repo.hex.pm/tarballs/rustler_precompiled-0.10.1.tar";
      flake = false;
    };
    # The NIF mdex_native would download; its checksum ships in the
    # Hex package, so rustler_precompiled verifies it.
    mdex-nif = {
      url = "file+https://github.com/leandrocp/mdex_native/releases/download/v0.3.1/libmdex_native_nif-v0.3.1-nif-2.15-x86_64-unknown-linux-gnu.so.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      hex = [
        "jason"
        "mdex"
        "mdex_native"
        "nimble_options"
        "nimble_parsec"
        "rustler_precompiled"
      ];
      nif = "libmdex_native_nif-v0.3.1-nif-2.15-"
        + "x86_64-unknown-linux-gnu.so.tar.gz";

      site = { lib, stdenvNoCC, beam }:
        let
          beamPkgs = beam.packages.erlang_29;
          hexLib = "${beamPkgs.hex}/lib/erlang/lib";
          hexEbin = "${hexLib}/hex-${beamPkgs.hex.version}/ebin";
          pathDep = n: ''{:${n}, path: "deps/${n}", override: true}'';
          unpack = n: ''
            mkdir -p deps/${n}
            tar xzf ${inputs."hex-${n}"}/contents.tar.gz -C deps/${n}
          '';
        in
        stdenvNoCC.mkDerivation {
          pname = "rfds-site";
          version = self.shortRev or "dirty";
          src = lib.cleanSourceWith {
            src = self;
            filter = path: _:
              !(builtins.elem (baseNameOf path) [
                "flake.nix"
                "flake.lock"
                ".github"
                "deps"
                "_build"
                "docs"
              ]);
          };
          nativeBuildInputs = [ beamPkgs.erlang beamPkgs.elixir_1_20 ];
          dontConfigure = true;
          buildPhase = ''
            export HOME=$TMPDIR MIX_HOME=$TMPDIR/mix LANG=C.UTF-8
            # Hex only names optional deps' SCM; nothing is fetched.
            export MIX_PATH=${hexEbin} HEX_OFFLINE=1
            export TARGET_ARCH=x86_64 TARGET_VENDOR=unknown
            export TARGET_OS=linux TARGET_ABI=gnu
            export RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH=$TMPDIR/nif
            mkdir -p $TMPDIR/nif
            cp ${inputs.mdex-nif} $TMPDIR/nif/${nif}
            ${lib.concatMapStrings unpack hex}
            rm -f mix.lock
            substituteInPlace mix.exs --replace-fail \
              'deps: [{:mdex, "~> 0.14.6"}, {:nimble_parsec, "~> 1.4"}]' \
              'deps: [${lib.concatMapStringsSep ", " pathDep hex}]'
            mix compile
            mix run scripts/pages_docs.exs --write
          '';
          installPhase = ''
            cp -r docs $out
          '';
        };

      overlay = final: _: { rfds-site = final.callPackage site { }; };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      overlays.default = overlay;
      packages.${system} = {
        site = pkgs.rfds-site;
        default = pkgs.rfds-site;
      };
    };
}
