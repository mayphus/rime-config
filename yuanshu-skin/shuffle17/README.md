# Shuffle17 (亂序17) Keyboard Skin

`skins/shuffle17` is the source directory for the **Shuffle17 (亂序17)** keyboard skin.

For details on the Rime schema design that corresponds to this skin, see:
`../../shuffle17.schema-plan.md`

This skin implements an experimental 17-key layout for iPhone, designed to be tested alongside the `shuffle17_ice` (亂序17) Rime schema.

## Layout Features

- **Large Central Labels:** Displays visible key labels like `HP / Sh / Zh / ...`.
- **Bottom Labels:** Shows the vowel/final groups assigned to that key (currently displayed on a single line).
- **`X` Key:** Shows smaller `o / v` labels on the left and right of the main label.

### Usage Notes

- The labels on the skin are purely visual identifiers. The actual internal codes sent to the Rime engine are the letters `a-q`.
- **Swipe Down Actions:**
  - `o X v` key: Opens the Emoji keyboard.
  - `SM` key: Opens the Script (脚本) page.
  - `WZ` key: Opens the Clipboard (剪贴板) page.
- Numbers, symbols, and the Return key still use the default system function keys.
- **English Input:** This skin does not provide a standard English QWERTY layout. To type in English, please switch to the native iOS system English keyboard.

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
