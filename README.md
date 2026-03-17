# My Rime Configuration

This repository contains my personal configuration files for [Rime](https://rime.im/) (中州韻輸入法引擎), a highly customizable input method engine. It includes setups for both desktop and mobile environments.

## Main Schemas (Desktop)

The root directory contains the schemas and dictionaries for my desktop setup:

- `cangjie6.schema.yaml`: Cangjie 6 (倉頡六代)
- `flypy.schema.yaml`: Flypy Double Pinyin (小鶴雙拼)
- `bopomofo.schema.yaml`: Bopomofo (注音)
- `jyut6ping3.schema.yaml`: Cantonese Jyutping (粵拼)

**Shared Dictionaries & Configurations:**
- `cangjie6.dict.yaml`
- `luna_pinyin.dict.yaml`
- `terra_pinyin.dict.yaml`
- `jyut6ping3_dicts/*.dict.yaml`
- `jyut6ping3_dicts/essay-cantonese.txt`
- `zhuyin.yaml`
- `flypy.yaml`
- `default.custom.yaml`: Controls the active schema list

## Mobile Bundle (Yuanshu / 元书输入法)

The `yuanshu-ime/` directory contains source files specifically tailored for the iOS app **Yuanshu (元书输入法)**. This includes mobile-only `rime-ice` schemas, dictionaries, and custom keyboard skins.

Please refer to the [Mobile Configuration README](yuanshu-ime/README.md) for instructions on how to build and export the mobile bundle.

## Installation

1. Clone this repository.
2. Copy or symlink the YAML files to your Rime user data directory (e.g., `~/Library/Rime` on macOS).
3. Deploy (重新部署) your Rime input method to apply the changes.
