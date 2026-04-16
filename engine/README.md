# rime-config

Rime input method config and Yuanshu app skin/config generator, managed with a Racket build system.

## Structure

```
build.rkt       — build system entry point
schema/         — Racket generators for schema YAML and shared config
skin/           — Racket generators for .cskin skin bundles
data/           — static YAML: schemas, dictionaries, data files
profiles/       — build profiles (desktop + Yuanshu mobile)
tools/          — Python utilities (upload, skin demo renderer)
```

## Commands

```sh
racket build.rkt deploy                # build desktop profile → sync to ~/Library/Rime
racket build.rkt -p <profile> build    # build + zip a profile
racket build.rkt all                   # build + zip all profiles
racket build.rkt clean                 # delete build cache
racket build.rkt skins                 # build standalone skin previews
racket build.rkt -p <profile> upload   # build + upload to Yuanshu server
```

## Web Customizer

A Racket-based web interface for customizing and downloading configurations.

```sh
racket web.rkt
```
Visit `http://localhost:5001` to select your platform, schemas, and skins.

## Profiles

| Profile | Schemas | Notes |
|---|---|---|
| `desktop` | cangjie6, jyut6ping3, bopomofo, flypy | syncs to `~/Library/Rime` |
| `yuanshu/all` | all | full Yuanshu mobile build |
| `yuanshu/flypy_18` | flypy_18 | single-schema Yuanshu build |

## How it works

Each schema in `schema/` exports `config-files` — a hash of relative paths to YAML content. Skins in `skin/` export `skin-files` — a hash of relative paths to JSON content, zipped into `.cskin` bundles.

Schema modules declare their own dependencies (`schema-deps`, `static-dep-files`, `static-dep-dirs`) and mobile-only status (`mobile-only?`). Skin modules declare which schemas trigger their inclusion (`trigger-schemas`). The build system discovers everything from these exports — no central dispatch table.
