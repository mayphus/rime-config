# Migration Notes

Moved into `~/making/rime-config`:

- `engine/` from `orchestrator/apps/rime`
- `app/` Rime UI logic from `mayphus-sites`

Removed during extraction:

- the island registry and page-type bootstrap handoff
- the assumption that Rime is embedded inside a larger site page

Still to do:

- move or recreate the Rime-specific CSS in the standalone app
- add a standalone HTML entry for the app
- switch `mayphus-sites` so `/rime-config` proxies or rewrites to this project
