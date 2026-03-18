# Yuanshu App Configuration (元书输入法)

The `yuanshu-config/` directory holds the app-specific source files designed for the iOS input method app **Yuanshu (元书输入法)**. These source files are compiled into a deployable bundle.

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
  - `yuanshu-skin/quadharmonic/`
  - `yuanshu-skin/shuffle17/`

## Generate Export Bundle

To rebuild the self-contained bundles for your iPhone or your customers, run the `make` commands from the repository root:

```sh
# Generate the personal build for your own iOS use
make build-yuanshu

# Generate the standalone bundle zip specifically for customers sharing the shuffle17 layout
make build-customer-pack

# Build both
make all
```

This will generate the built artifacts in the top-level `output/` directory (e.g. `output/yuanshu/` and `output/customer-shuffle17.zip`). Each custom keyboard skin directory under `yuanshu-skin/` is packaged into its own `.cskin` bundle automatically during the build process.

*Note: The generated files in `output/` are build artifacts and are automatically ignored by git.*
