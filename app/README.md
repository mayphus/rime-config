# app

Standalone frontend for the Rime Config product.

Current scope:

- mounts a normal single-page Reagent app
- fetches metadata and build artifacts from the engine API
- carries over the current selection logic from `mayphus-sites`
- uses a standard `#app` root with optional `data-api-url`

The frontend now uses standalone `rime-config.*` namespaces and its own static
entry files instead of the old site-specific embedding setup.
