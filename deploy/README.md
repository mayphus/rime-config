# Deployment

## Racket app on pb62 k3s

This repo deploys the public frontend and build API together as one Racket app
on k3s on `pb62`.

`deploy/k8s/manifests.rkt` owns the Kubernetes objects. The YAML files in this
directory are generated for Kustomize; update the Racket file and run:

```sh
racket deploy/k8s/manifests.rkt
```

### CI flow

1. GitHub Actions builds the repo root into `ghcr.io/mayphus/rime-config`.
2. Actions joins your tailnet using Tailscale OAuth client credentials.
3. Actions uses `KUBECONFIG_PB62` to reach k3s on `pb62`.
4. Actions applies `deploy/k8s` and updates the app image tag.

### Required GitHub secrets

- `TAILSCALE_OAUTH_CLIENT_ID`
- `TAILSCALE_OAUTH_SECRET`
- `KUBECONFIG_PB62`
- `GHCR_PULL_TOKEN`

### Notes

- The deploy workflow rewrites the kubeconfig `server:` to
  `https://100.116.247.67:6443` before running `kubectl`, so the stored
  `KUBECONFIG_PB62` secret can keep the original cluster/user/certificate data.
- If `pb62` gets a different Tailscale IP, update `K8S_API_SERVER` in
  `.github/workflows/deploy-k3s.yml` to match the new address.
- `GHCR_PULL_TOKEN` should be a GitHub personal access token for `mayphus`
  with at least `read:packages`, so the workflow can create the `ghcr-pull`
  image pull secret in Kubernetes before deploying.
- The ingress manifest assumes `rime.mayphus.org` and
  `rime-config.mayphus.org` should terminate in the cluster.
- Cloudflare should route those hostnames to the k3s ingress. The old Worker
  frontend is no longer part of this repo.
- The cert-manager issuer name is currently `letsencrypt`.
- If your k3s ingress class or cert-manager setup differs, adjust
  `deploy/k8s/ingress.yaml`.
