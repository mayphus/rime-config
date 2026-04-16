# Deployment

## Engine on pb62 k3s

This repo assumes the public frontend stays separate and the engine is deployed
to k3s on `pb62`.

### CI flow

1. GitHub Actions builds `engine/` into `ghcr.io/mayphus/rime-config-engine`.
2. Actions joins your tailnet using `TAILSCALE_AUTHKEY`.
3. Actions uses `KUBECONFIG_PB62` to reach k3s on `pb62`.
4. Actions applies `deploy/k8s` and updates the engine image tag.

### Required GitHub secrets

- `TAILSCALE_AUTHKEY`
- `KUBECONFIG_PB62`

### Notes

- The ingress manifest assumes `api-rime.mayphus.org` should terminate in the
  cluster.
- The cert-manager issuer name is currently `letsencrypt`.
- If your k3s ingress class or cert-manager setup differs, adjust
  `deploy/k8s/ingress.yaml`.
