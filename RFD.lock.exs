# Written by `mix rfd.refs.update`; RFD prose resolves &{...} against it.
%{
  manifest: %{
    commit: "b13f17244a8558fc594475af8618ea07ef3086a3",
    repo: "chibifire-smoke-water/contract-manifest-smoke-water"
  },
  files: %{{"datasource-store", "fly/backup-fresh.sh"} => %{contains: []}},
  repos: %{
    "entities-godot-sandbox" => %{state: :planned, side: "4-entities"},
    "interactor-av1mkv" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/av1mkv",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-av1mkv",
      tip: "da96755140694b06953e865013176161f78bff80"
    },
    "entities-godot-sandbox-gdscript-compiler" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-sandbox-gdscript-compiler",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/entities-godot-sandbox-gdscript-compiler",
      tip: "fdbef5d010acccfaa4e9b88cab531105edaf5b7d"
    },
    "interactor-voice" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/voice",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-voice",
      tip: "c7776471fbda663a2337c84ad0b31bc151c39052"
    },
    "ggml" => %{
      default: "main",
      state: :placed,
      path: "2-contract/ggml",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/ggml",
      tip: "29cae86726d8ae2b4d699d8e432fd1bb1801e959"
    },
    "contract-cineform-movie-writer" => %{
      default: "main",
      state: :placed,
      path: "2-contract/cineform-movie-writer",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-cineform-movie-writer",
      tip: "34eb224e343ffdc4b64bd881e17e2a0cec1e5609"
    },
    "contract-bootstrap" => %{
      default: "main",
      state: :placed,
      path: "2-contract/bootstrap",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-bootstrap",
      tip: "996822977e15d1c59c1b7faac76f2cd738a98a7d"
    },
    "contract-anny-kernels" => %{
      default: "main",
      state: :placed,
      path: "2-contract/anny-kernels",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-anny-kernels",
      tip: "6727055d6a5a9c7b102f5c40573cb3e27fdb7e4e"
    },
    "service-godot-build" => %{
      default: "main",
      state: :placed,
      path: "7-service/godot-build",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-godot-build",
      tip: "aa99c040350a4437b9b1dc8244dd36c91fc58121"
    },
    "interactor-usd-guest" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/usd-guest",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-usd-guest",
      tip: "fb960c0272ad3dbe98f9f275ebe42b8f962cdef2"
    },
    "datasource-foundationdb" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/foundationdb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/datasource-foundationdb",
      tip: "865819b2941b750a486858d8a566b19a8df981cb"
    },
    "character-marocchino" => %{
      default: "main",
      state: :placed,
      path: "4-entities/character-marocchino",
      revision: "main",
      url: "https://github.com/chibifire-stages/character-marocchino",
      tip: "dcd38ff7f6f2ea10a584dca383a6b7c3fab27d36"
    },
    "transport-elixir-libgodot-connector" => %{
      default: "main",
      state: :placed,
      path: "1-transport/elixir-libgodot-connector",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-elixir-libgodot-connector",
      tip: "2747e6fe378fe1abc1d002912a9b19c21c1b23b9"
    },
    "character-mille-mire-feuille" => %{
      default: "main",
      state: :placed,
      path: "4-entities/character-mille-mire-feuille",
      revision: "main",
      url: "https://github.com/chibifire-stages/character-mille-mire-feuille",
      tip: "ee77c5b1198b441bf261fe27e85dd2f86e1781ff"
    },
    "frame-controller-sim" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/frame-controller-sim",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/frame-controller-sim",
      tip: "bf4a1beedd993afb3400ce07104b731e879a8ab4"
    },
    "manuals-weftspun" => %{
      default: "main",
      state: :placed,
      path: "2-contract/manuals-weftspun",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/manuals-weftspun",
      tip: "9b6580b5d2bd61c6c327a56db4bd77727d58181f"
    },
    "contract-ggml-rd" => %{
      default: "main",
      state: :placed,
      path: "2-contract/ggml-rd",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-ggml-rd",
      tip: "94b6be4d3dabf50fcde08315b90033c65e054d8f"
    },
    "contract-guest-common" => %{
      default: "main",
      state: :placed,
      path: "2-contract/guest-common",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-guest-common",
      tip: "9ffd906d14a6773fedb6b00a269baf464cde7a89"
    },
    "datasource-cassie" => %{
      default: "master",
      state: :placed,
      path: "6-datasource/cassie",
      revision: "master",
      url: "https://github.com/v-sekai/datasource-cassie",
      tip: "ed6870db441ece00701979db67190972deeff59b"
    },
    "service-cineform" => %{
      default: "main",
      state: :placed,
      path: "7-service/cineform",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-cineform",
      tip: "a6b30a2f63f73f8596455578bb67e59ff9590b9f"
    },
    "entities-sakuragaoka-station" => %{
      default: "main",
      state: :placed,
      path: "4-entities/sakuragaoka-station",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/entities-sakuragaoka-station",
      tip: "d9c0f0f916c1e7280fab4f09fc685c6ea679d814"
    },
    "transport-meshing-pen" => %{
      default: "main",
      state: :placed,
      path: "1-transport/meshing-pen",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-meshing-pen",
      tip: "d555e9a17ebbd5bc695f1329653a988a656f4d7e"
    },
    "transport-central-launcher" => %{
      default: "main",
      state: :placed,
      path: "1-transport/central-launcher",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-central-launcher",
      tip: "fb961f3d0b9766cba66c2b9700874b1042b8b9e2"
    },
    "repository-riscv64-sysroot" => %{
      default: "main",
      state: :placed,
      path: "5-repository/riscv64-sysroot",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/repository-riscv64-sysroot",
      tip: "585de9e0cfe15fc14f9961083d857d609592de42"
    },
    "interactor-taskweft-godot-sandbox" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/taskweft-godot-sandbox",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-taskweft-godot-sandbox",
      tip: "b94aee9a0d52dd2ce05cc692a4e8094b55aaf820"
    },
    "entities-godot" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-cineform",
      revision: "dev/cineform",
      url: "https://github.com/V-Sekai-fire/entities-godot",
      tip: "0bac82758eadc9fc00b2c80753f0dce3304d50bc"
    },
    "godot_openvr" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-openvr",
      revision: "feat/frame-devices",
      url: "https://github.com/V-Sekai-fire/godot_openvr",
      tip: "04c84ba1654ba6f9bb974a065bbb23aabf627a52"
    },
    "pyrowave" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/pyrowave-upstream",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/pyrowave",
      tip: "a2527babe8390d5c59cf9c29fbae8c5f5022b2b3"
    },
    "contract-zone-backend" => %{
      default: "main",
      state: :placed,
      path: "2-contract/zone-backend",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-zone-backend",
      tip: "cda66e317c527239315169c1dd08ca3ecb47991b"
    },
    "interactor-drape" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/drape",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-drape",
      tip: "923c9b0d77e438f556f8865143bd5f9e6a63b8f6"
    },
    "interactor-curvenet" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/curvenet",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-curvenet",
      tip: "c4e73831ab5718f3baf730da2e77d51ff9d02b03"
    },
    "service-bao-sqlite-fdb" => %{
      default: "main",
      state: :placed,
      path: "7-service/bao-sqlite-fdb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-bao-sqlite-fdb",
      tip: "870e48cc6a982fcc9bce3013ad2f10860d7b56bd"
    },
    "transport-cineform-tui" => %{
      default: "main",
      state: :placed,
      path: "1-transport/cineform-tui",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-cineform-tui",
      tip: "2d8856d2c9f7863dbee12040b107753a4abb5aaf"
    },
    "contract-lbfgsb" => %{
      default: "main",
      state: :placed,
      path: "2-contract/lbfgsb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-lbfgsb",
      tip: "449bb7d6a375ee534ffc8cc85dba7aa6076676a6"
    },
    "sakuragaoka-station" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/sakuragaoka-station-upstream",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/sakuragaoka-station",
      tip: "f7cf5ac562149d1454da9b8f0b0d15a847d54226"
    },
    "contract-guest-runtime" => %{
      default: "main",
      state: :placed,
      path: "2-contract/guest-runtime",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-guest-runtime",
      tip: "1d8341825ac6fcfa8b8b2a11ae908e5d6aa71b33"
    },
    "interactor-motion-guest" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/motion-guest",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-motion-guest",
      tip: "23ccd1829b4b4daf83e73e3926a4eab4afd36378"
    },
    "interactor-mujoco-sandbox-demo" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/mujoco-sandbox-demo",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-mujoco-sandbox-demo",
      tip: "f93828bc3a2730ccc34e49c18ae0b73479ae34f0"
    },
    "contract-sinew-align" => %{
      default: "main",
      state: :placed,
      path: "2-contract/sinew-align",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-sinew-align",
      tip: "7e00cdb42aeba6dcc8e263898096a6c4c55e2a47"
    },
    "interactor-lasso" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/lasso",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-lasso",
      tip: "2610aac5e0393c88c706ebff43c5f7f158a4ed6a"
    },
    "interactor-cineform" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/cineform",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-cineform",
      tip: "e7e64492be75e884e81644a28be01b2094a46e81"
    },
    "transport-usbip-frame" => %{
      default: "main",
      state: :placed,
      path: "1-transport/usbip-frame",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-usbip-frame",
      tip: "c222b2b60a83efb1f09449211521345908a118d6"
    },
    "contract-manifest-skateboard" => %{state: :planned, side: "2-contract"},
    "interactor-fabric-zone" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/fabric-zone",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-fabric-zone",
      tip: "e7a446455020684440a00aee9eed211bcf99b243"
    },
    "service-zone" => %{
      default: "main",
      state: :placed,
      path: "7-service/zone",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-zone",
      tip: "747c037d659c08a4f09cfbd729dbba2e2a0a8cf1"
    },
    "service-openbao" => %{
      default: "main",
      state: :placed,
      path: "7-service/openbao",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-openbao",
      tip: "a80cb3d81cf7352fd42adf74ebd4d99ce8e6ea00"
    },
    "datasource-store" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/store",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/datasource-store",
      tip: "0439036a36f9e66f727a045abcb70c69e722921f"
    }
  }
}
