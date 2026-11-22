# Rick Burn Remote Support connectors

This is RustDesk 1.5.3 (https://github.com/rustdesk/rustdesk, AGPL-3.0) with a built-in brand,
used by Rick Burn Consulting for remote support. The full source of every connector we hand out is here.

Changes from RustDesk:
- `src/common.rs`: `res/brand.json` is applied at start-up like a custom client config.
- `brand/rickburn/` = quick support (receive only, no install); `brand/rickburn-access/` = two-way, installable (home-to-work access).
- `brand/<name>/`: settings (`brand.json`), names and colours (`brand.env`), icons and logo (`files/`).
- `brand/apply-brand.sh <name>`: copies a brand into the source before building.
- `.github/workflows/brand-build.yml`: builds the Windows connector for a brand and publishes it as a release.
