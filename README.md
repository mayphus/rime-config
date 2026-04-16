# rime-config

Standalone Rime Config product.

## Layout

- `app/` holds the standalone product frontend
- `engine/` holds the Rime config generation and export engine
- `docs/` tracks migration and deployment notes

## URL strategy

The product should remain publicly reachable at `mayphus.org/rime-config`.
`mayphus-sites` should eventually serve only as the outer router or proxy for
that path, while the actual product code lives here.

## Migration status

The first extraction pass is complete:

- engine code copied from `orchestrator/apps/rime`
- Rime frontend logic copied from `mayphus-sites`
- standalone frontend build config trimmed to Rime-only scope

Remaining cutover work is documented in `docs/migration.md`.
