#!/usr/bin/env bash
# Builds the tackler-core 0.12.0 oracle that wrote
# test/fixtures/tackler/tackler.jsonl, then writes that file again.
# tackler-core keeps its parsed transactions crate-private, so the
# vendored copy opens field visibility only; no parsing code changes.
set -euo pipefail
cd "$(dirname "$0")"
rm -rf .fetch && mkdir -p .fetch/src && cp Cargo.toml.registry .fetch/Cargo.toml
echo "fn main() {}" > .fetch/src/main.rs
cargo fetch --manifest-path .fetch/Cargo.toml
src=$(find "${CARGO_HOME:-$HOME/.cargo}/registry/src" -maxdepth 2 \
  -type d -name 'tackler-core-0.12.0' | head -1)
rm -rf vendor && mkdir vendor && cp -r "$src" vendor/tackler-core
m=vendor/tackler-core/src/model
sed -i 's/pub(crate) \(txns\|metadata\): /pub \1: /' $m/txn_data.rs
sed -i 's/pub(crate) \(header\|posts\): /pub \1: /' $m/transaction.rs
sed -i 's/^pub(crate) struct AccountTreeNode/pub struct AccountTreeNode/' \
  $m/account_tree_node.rs
sed -i '/^pub struct AccountTreeNode/,/^}/ s/pub(crate) \([a-z_]*\): /pub \1: /' \
  $m/account_tree_node.rs
sed -i 's/pub(crate) \(atn\|comm\): /pub \1: /' $m/account_tree_node.rs
cargo build --release
fixtures=../../test/fixtures/tackler
(cd "$fixtures" && "$OLDPWD/target/release/tackler-oracle" *.txn > tackler.jsonl)
echo "wrote $fixtures/tackler.jsonl"
