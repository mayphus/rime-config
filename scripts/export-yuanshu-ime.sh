#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SRC_DIR="$ROOT_DIR/yuanshu-ime"
OUT_DIR="$SRC_DIR/export"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp "$ROOT_DIR/cangjie6.dict.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/cangjie6.schema.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/flypy.schema.yaml" "$OUT_DIR/"
cp "$ROOT_DIR/flypy.yaml" "$OUT_DIR/"

cp "$SRC_DIR/default.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/cangjie6.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/flypy.custom.yaml" "$OUT_DIR/"
cp "$SRC_DIR/luna_pinyin.dict.yaml" "$OUT_DIR/"
cp "$SRC_DIR/trinote.cskin" "$OUT_DIR/"
cp -R "$SRC_DIR/trinote" "$OUT_DIR/"
