# rime-config

Rime input method config and Yuanshu app skin/config generator, managed with a Racket build system.

## Structure

``` 
build-lib.rkt   — shared build library
default-profile.rkt — built-in desktop/default profile
frontend.rkt    — Racket-rendered HTMX web UI
web.rkt         — Racket HTTP app for pages, metadata, previews, and ZIP builds
schema/         — Racket generators for schema YAML and shared config
skin/           — Racket generators for .cskin skin bundles
data/           — static YAML: schemas, dictionaries, data files
static/         — CSS served by the Racket app
profiles/       — build profiles (desktop + Yuanshu mobile)
tools/          — Racket utilities plus the Python skin demo renderer
```

## Invocation

From the repo root:

```racket
(require "build.rkt")

(build-profile! "flypy_18")
(zip-profile! "flypy_18")
(build-preview-skins!)
(build-preview-skins! #:render-docs? #t)
```

## Web Customizer

A Racket-based web interface for customizing and downloading configurations.
The UI is plain server-rendered HTML with HTMX-enhanced partial refreshes; there
is no ClojureScript or React build step.

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

`demo.svg` and `demo.png` generation are build-time concerns. Production/runtime services should serve prebuilt skin docs/assets instead of rendering them on demand.
