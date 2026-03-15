# yuanshu-ime

`yuanshu-ime/` holds the app-specific source files for the generated `export/` bundle.

Shared Rime schemas stay at the repository root.

## Source Files

- `default.custom.yaml`
- `cangjie6.custom.yaml`
- `flypy.custom.yaml`
- `luna_pinyin.dict.yaml`
- `quadharmonic/`

## Generate Export

Rebuild the self-contained iPhone bundle with:

```sh
scripts/export-yuanshu-ime.sh
```

This writes the copyable bundle to `yuanshu-ime/export/`.

Generated files in `yuanshu-ime/export/` are not source files.

If you also want to package the skin archive:

```sh
scripts/export-yuanshu-ime.sh --with-skin
```
