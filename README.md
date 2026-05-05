# rime-config

Standalone Rime Config product, served by one Racket app.

## Layout

- `web.rkt` serves the public HTML, HTMX partials, metadata, previews, and ZIP builds.
- `build.rkt` is the callable build library for schemas, skins, profiles, and archives.
- `frontend.rkt` renders the server-side UI.
- `k8s.rkt` generates and checks the Kubernetes YAML.
- `data/`, `schema/`, `skin/`, and `profiles/` hold the Rime inputs and generators.
- `tools/` contains maintenance scripts.
- `k8s/` contains generated manifests for k3s on `pb62`.

## URL strategy

The product is served directly by the k3s-hosted Racket app:

- `rime.mayphus.org`
- `rime-config.mayphus.org`

## Local development

```sh
racket web.rkt
```

Visit `http://localhost:5001`.

Regenerate Kubernetes manifests after changing deploy settings:

```sh
racket k8s.rkt
```

## Deployment

This repo deploys the public frontend and build API together as one Racket app
on k3s on `pb62`. `k8s.rkt` owns the Kubernetes objects; the YAML files in
`k8s/` are generated for Kustomize.

The GitHub Actions deploy flow builds the repo root into
`ghcr.io/mayphus/rime-config`, joins your tailnet with Tailscale OAuth
credentials, uses `KUBECONFIG_PB62` to reach k3s on `pb62`, applies `k8s/`, and
updates the image tag.

Required GitHub secrets:

- `TAILSCALE_OAUTH_CLIENT_ID`
- `TAILSCALE_OAUTH_SECRET`
- `KUBECONFIG_PB62`
- `GHCR_PULL_TOKEN`

Deployment notes:

- The deploy workflow rewrites the kubeconfig `server:` to
  `https://100.116.247.67:6443` before running `kubectl`, so the stored
  `KUBECONFIG_PB62` secret can keep the original cluster/user/certificate data.
- If `pb62` gets a different Tailscale IP, update `K8S_API_SERVER` in
  `.github/workflows/deploy-k3s.yml`.
- `GHCR_PULL_TOKEN` should be a GitHub personal access token for `mayphus` with
  at least `read:packages`, so the workflow can create the `ghcr-pull` image
  pull secret before deploying.
- The ingress manifest assumes `rime.mayphus.org` and
  `rime-config.mayphus.org` terminate in the cluster.
- Cloudflare should route those hostnames to the k3s ingress. The old Worker
  frontend is no longer part of this repo.
- The cert-manager issuer name is currently `letsencrypt`.
- If your k3s ingress class or cert-manager setup differs, adjust `k8s.rkt` and
  regenerate with `racket k8s.rkt`.

## Current shape

The old ClojureScript/React/Bun/Wrangler frontend path has been removed. Racket
renders the pages, HTMX handles small form refreshes, and the same Racket process
builds the downloadable ZIP archives.
