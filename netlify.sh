#!/usr/bin/env bash
# Bootstrap the static export, following ada-x64/blog's Netlify build.
set -Eeuo pipefail

mkdir -p .tools/tmp
export TMPDIR="$PWD/.tools/tmp"
export JUST_TEMPDIR="$TMPDIR"

curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ./.tools/bin/
export TYPST_INSTALL="$PWD/.tools"
curl -fsSL https://install.typst.community/install.sh | sh -s -- 0.15.0
export PATH="$PWD/.tools/bin:$PWD/node_modules/.bin:$PATH"

bun install --frozen-lockfile
WIKI_HOSTED=true just build
just test
