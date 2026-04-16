# Deployment

## Engine on pb62 k3s

This repo assumes the public frontend stays separate and the engine is deployed
to k3s on `pb62`.

### CI flow

1. GitHub Actions builds `engine/` into `ghcr.io/mayphus/rime-config-engine`.
2. Actions joins your tailnet using Tailscale OAuth client credentials.
3. Actions uses `KUBECONFIG_PB62` to reach k3s on `pb62`.
4. Actions applies `deploy/k8s` and updates the engine image tag.

### Required GitHub secrets

- `TAILSCALE_OAUTH_CLIENT_ID`
- `TAILSCALE_OAUTH_SECRET`
- `KUBECONFIG_PB62`

### Notes

- The deploy workflow rewrites the kubeconfig `server:` to
  `https://pb62.tailae38.ts.net:6443` before running `kubectl`, so the stored
  `KUBECONFIG_PB62` secret can keep the original cluster/user/certificate data.
- If you rotate the node name or tailnet domain, update `K8S_API_SERVER` in
  `.github/workflows/deploy-engine.yml` to match.
- The ingress manifest assumes `api-rime.mayphus.org` should terminate in the
  cluster.
- The cert-manager issuer name is currently `letsencrypt`.
- If your k3s ingress class or cert-manager setup differs, adjust
  `deploy/k8s/ingress.yaml`.
