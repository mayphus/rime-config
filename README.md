# rime-config

Standalone Rime Config product, served by one Racket app.

## Layout

- `web.rkt` and `build.rkt` are small repo-root shims.
- `engine/` owns the web UI, build API, schema generators, skin generators, and static CSS.
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
