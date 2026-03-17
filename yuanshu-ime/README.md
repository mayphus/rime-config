# Yuanshu App Configuration (元书输入法)

The `yuanshu-ime/` directory holds the app-specific source files designed for the iOS input method app **Yuanshu (元书输入法)**. These source files are compiled into a deployable bundle located in the `export/` directory.

Note: Shared Rime schemas and dictionaries are maintained at the repository root.

## Source Files

- **Custom Configurations:**
  - `cangjie5.custom.yaml`, `cangjie6.custom.yaml`, `flypy.custom.yaml`, `jyut6ping3.custom.yaml`
- **Mobile-Specific Schemas & Dictionaries:**
  - `flypy_ice.schema.yaml`, `flypy_ice.custom.yaml`
  - `rime_ice.dict.yaml`, `rime_ice_dicts/*.dict.yaml`
- **Experimental 17-Key Layout:**
  - `shuffle17_ice.schema.yaml`, `shuffle17_ice.custom.yaml`
  - `shuffle17.schema-plan.md`
- **Keyboard Skins:**
  - `skins/quadharmonic/`
  - `skins/shuffle17/`

## Generate Export Bundle

To rebuild the self-contained bundle for your iPhone, run the export script from the repository root:

```sh
./scripts/export-yuanshu-ime.sh
```

This script generates a ready-to-copy bundle in `yuanshu-ime/export/`. It also packages each custom keyboard skin directory under `skins/` into its own `.cskin` bundle (e.g., `quadharmonic.cskin` and `shuffle17.cskin`).

*Note: The generated files in `yuanshu-ime/export/` are build artifacts and are not tracked as source files.*
