# Remote Control Module Tests

Autowork test suite for the Blazium **remote_control** module (localhost HTTP API for CLI↔editor control).

## Features

- Fully integrated with the native C++ **Autowork** testing framework
- Headless execution of lifecycle, health/status, exec, command list, and gated eval tests
- Optional Luau eval coverage when the editor is built with `luau_module` (otherwise those cases are skipped/`pending`)

## Requirements

Build or use a Blazium editor with:

- `module_remote_control_enabled=yes`
- `module_httpserver_enabled=yes`
- `module_autowork_enabled=yes`
- `module_luau_module_enabled=yes` (optional; needed for Luau eval asserts)

## Running tests

With `blazium` on your `PATH`:

```bash
blazium --headless --path . -s run_tests.gd
```

Or via the helper script (Windows PowerShell):

```powershell
.\tools\validate_all.ps1
.\tools\validate_all.ps1 -Editor "C:\path\to\blazium.exe"
```

`validate_all.ps1` prefers `blazium` on `PATH`, then optional sibling build paths under `..\blazium\bin\` for local development.

## What is covered

| Test | Focus |
| --- | --- |
| `test_001` | Server start/stop lifecycle |
| `test_002` | `GET /v1/health` and `/v1/status` |
| `test_003` | `POST /v1/exec` ping |
| `test_004` | `GET /v1/commands` |
| `test_005` | Gated eval + `language: gdscript` |
| `test_006` | `language: luau` (skipped without `LuaState`) |

## License

MIT — see [LICENSE](LICENSE).
