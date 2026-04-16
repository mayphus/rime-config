# Migration Notes

Moved into `~/making/rime-config`:

- `engine/` from `orchestrator/apps/rime`
- repo-root frontend from `mayphus-sites`

Removed during extraction:

- the island registry and page-type bootstrap handoff
- the assumption that Rime is embedded inside a larger site page
- the extra `app/` nesting for the frontend

Still to do:

- switch `mayphus-sites` so `/rime-config` proxies or rewrites to this project
