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

- `KUBECONFIG_PB62` must point the cluster `server:` at a Tailscale-reachable
  endpoint for `pb62` such as its tailnet IP or MagicDNS name, not a LAN
  address like `192.168.x.x`. GitHub-hosted runners cannot reach your home LAN
  directly unless you have Tailscale subnet routing set up.
- The deploy workflow uses `kubectl apply --validate=false` because client-side
  schema validation downloads the cluster OpenAPI spec before applying and can
  fail even when a normal API request would succeed.
- The ingress manifest assumes `api-rime.mayphus.org` should terminate in the
  cluster.
- The cert-manager issuer name is currently `letsencrypt`.
- If your k3s ingress class or cert-manager setup differs, adjust
  `deploy/k8s/ingress.yaml`.
