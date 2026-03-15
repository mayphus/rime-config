#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SRC_DIR="$ROOT_DIR/yuanshu-ime"
OUT_DIR="$SRC_DIR/export"
SKIN_NAME="quadharmonic"
BUILD_SKIN=0

if [ "${1-}" = "--with-skin" ]; then
  BUILD_SKIN=1
elif [ "${1-}" != "" ]; then
  echo "usage: $0 [--with-skin]" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp "$ROOT_DIR/cangjie6.dict.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/cangjie6.schema.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/flypy.schema.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/flypy_ice.schema.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/flypy.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/rime_ice.dict.yaml" "$OUT_DIR/"
cp -R "$ROOT_DIR/rime_ice_dicts" "$OUT_DIR/"

cp "$SRC_DIR/default.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/cangjie6.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/flypy.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/flypy_ice.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/luna_pinyin.dict.yaml" "$OUT_DIR/"

if [ "$BUILD_SKIN" -eq 1 ]; then
  (
    cd "$SRC_DIR"
    zip -qr "$OUT_DIR/$SKIN_NAME.cskin" "$SKIN_NAME"
  )
fi
