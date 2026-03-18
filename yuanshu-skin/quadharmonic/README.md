# QuadHarmonic Keyboard (四合一鍵盤)

`skins/quadharmonic` is the source directory for the **QuadHarmonic (四合一鍵盤)** keyboard skin.

This skin modifies the default keyboard to display a dual-layer layout on the keys:

- **Top-Left:** Cangjie codes (倉解碼)
- **Bottom-Right:** Flypy Double Pinyin codes (小鶴雙拼)

## Features

- **Cangjie Coding:** The Cangjie labels map directly to the `cangjie6` configuration in the current workspace, showing existing character components like `的 / 止 / 片`.
- **Double Pinyin:** The Flypy (小鶴雙拼) labels, numbers, toolbar, and swipe-up actions are preserved from the default skin.

### Usage Notes

- **English Input:** This skin does not include a dedicated "English keyboard". To type in English, either switch Rime to `ascii_mode` (English mode) or use the native iOS system English keyboard.
- **Swipe Actions:**
  - `e` swipe down: Open Emoji keyboard.
  - `s` swipe down: Open Script (脚本) page (Mnemonic: `s` for Script).
  - `p` swipe down: Open Clipboard (剪贴板) page (Mnemonic: `p` for Pasteboard).
  - `a` swipe down: Toggle RIME `ascii_mode`.
- **Swipe Up (Numbers & Symbols):**
  - Top row (`q` to `p`): `1 2 3 4 5 6 7 8 9 0`
  - Middle row (`a` to `l`): <code>\` / : ; ( [ ~ @ "</code>
  - Bottom row (`z` to `m`): `, . # \ ? ! …`

## Development & Customization

The skin files are written in [Jsonnet](https://jsonnet.org/). To compile them on a PC, you must have the `jsonnet` command-line tool installed.

- The `jsonnet/` directory and `config.yaml` are the source files.
- The `dark/` and `light/` directories are compilation outputs and are ignored by git.

### Adjusting the Skin

- `jsonnet/Constants/Keyboard.libsonnet`: Defines the keyboard keys and the heights of different regions.
- To adjust the swipe up/down actions for any key, modify the `swipeUpAction` or `swipeDownAction` properties in this file.

### Compilation

**On Mobile (Yuanshu / 元书输入法):**
Long-press the skin and select "Run main.jsonnet" (运行 main.jsonnet).

**On PC:**
```shell
make
```
