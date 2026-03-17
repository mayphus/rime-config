# 亂序17

`skins/shuffle17` 是这个皮肤在仓库里的源目录。

`shuffle17` 是当前建议的英文内部名，对应中文名 `亂序17`。

对应的 Rime 方案设计说明见：
`../../shuffle17.schema-plan.md`

当前版本已经改为 17 键 iPhone 布局，用于配合 `shuffle17_ice` / `亂序17` 方案测试。

- 中央大字：`HP / Sh / Zh / ...` 这类可见键位标签
- 左上：该键承载的声母组
- 下方：该键承载的韵母组
- 右上：内部码 `A-Q`，用于和 `shuffle17_ice` 方案对应

说明：

- 皮肤上的主标签只是视觉标识；真正送给 Rime 的是内部码 `a-q`。
- 第三行左侧改为 `中/英` 键，方便直接切换 `ascii_mode`。
- `o X v` 键下划：打开 Emoji 键盘。
- `SM` 键下划：打开脚本页面。
- `WZ` 键下划：打开剪贴板页面。
- 数字、符号和回车仍然走原来的系统功能键。

皮肤文件通过 `Jsonnet` 语法编写，PC 端编译时需要安装 `jsonnet` 等命令行工具。

仓库中的 `jsonnet/`、`config.yaml` 等文件是源文件；
`dark/` 和 `light/` 是编译生成的输出目录，不作为源文件跟踪。

## 使用说明

本皮肤不单独提供英文字母排布；测试英文时请使用第三行左侧的 `中/英` 键切换 `ascii_mode`，或者切回系统英文键盘。

## 自定义皮肤调整说明

- `jsonnet/Constants/Keyboard.libsonnet`: 定义了键盘按键，各区域高度等常量。

  如想对按键上下划动进行调整，可在此文件中添加或修改对应按键的 `swipeUpAction` 或 `swipeDownAction` 属性。

## 手机端编译

长按皮肤，选择「运行 main.jsonnet」

## PC 端编译

```shell
make
```
