# yuanshu-ime

`yuanshu-ime/` holds the app-specific source files for the generated `export/` bundle.

Shared Rime schemas and dictionaries stay at the repository root.

## Source Files

- `bopomofo_hsu.schema.yaml`
- `bopomofo_hsu.custom.yaml`
- `default.custom.yaml`
- `cangjie5.custom.yaml`
- `cangjie6.custom.yaml`
- `flypy.custom.yaml`
- `flypy_ice.custom.yaml`
- `luna_pinyin.dict.yaml`
- `quadharmonic/`

## Generate Export

Rebuild the self-contained iPhone bundle with:

```sh
scripts/export-yuanshu-ime.sh
```

This writes the copyable bundle to `yuanshu-ime/export/` and also packages `quadharmonic.cskin`.

Generated files in `yuanshu-ime/export/` are not source files.
