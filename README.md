# rime-config

Standalone Rime Config product, served by one Racket app.

## Layout

- `web.rkt` serves the public HTML, HTMX partials, metadata, previews, and ZIP builds.
- `build.rkt` is the callable build library for schemas, skins, profiles, and archives.
- `frontend.rkt` renders the server-side UI.
- `data/`, `schema/`, `skin/`, and `profiles/` hold the Rime inputs and generators.
- `tools/` contains maintenance scripts.
- `deploy/k8s/` deploys the Racket app to k3s on `pb62`.

## URL strategy

The product is served directly by the k3s-hosted Racket app:

- `rime.mayphus.org`
- `rime-config.mayphus.org`
- `api-rime.mayphus.org` for compatibility with older API clients

## Local development

```sh
racket web.rkt
```

Visit `http://localhost:5001`.

## Current shape

The old ClojureScript/React/Bun/Wrangler frontend path has been removed. Racket
renders the pages, HTMX handles small form refreshes, and the same Racket process
builds the downloadable ZIP archives.
