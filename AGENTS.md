# AGENTS.md

Instructions for AI coding agents working in this repository. Humans: see [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## What Tuneless is

A macOS background service that quits Apple Music the moment it launches, so it stops opening on its own when AirPods or Bluetooth headphones connect or the Play key is pressed. It runs as a per-user LaunchAgent, has no UI, and leaves `com.apple.rcd` alone so media keys keep working.

## Layout

| Path | Purpose |
|---|---|
| `Sources/TunelessCore/Tuneless.swift` | Pure logic: version, identifier, blocked bundle IDs, `shouldBlock(bundleID:)`, argument parsing, usage text. No AppKit. |
| `Sources/Tuneless/main.swift` | Executable: parses arguments, observes `NSWorkspace` launch notifications, quits Apple Music, logs with `os.Logger`. |
| `Tests/TunelessCoreTests/` | Swift Testing unit tests for `TunelessCore`. |
| `LaunchAgent/io.github.nacholaciar.tuneless.plist` | LaunchAgent template; `__BIN__` is replaced by `Scripts/install.sh`. |
| `Scripts/install.sh`, `Scripts/uninstall.sh` | Install to `~/.local/bin` and register or remove the LaunchAgent. |
| `Packaging/homebrew/tuneless.rb` | Copy of the formula published in `nacholaciar/homebrew-tap`. |
| `.github/assets/` | Icon (`tuneless-icon.svg` is the source) and social preview; `src/social-preview.html` renders the preview. |

## Commands

```bash
swift build -c release   # or: make build
swift test               # or: make test
make install             # build, install and (re)start the LaunchAgent on this Mac
make smoke               # open Apple Music and check the running service quits it
make logs                # unified logs from the last hour
make uninstall
```

Requires macOS 14+ and Swift 6. Run `swift test` before finishing any change. `make install` and `make smoke` change the machine's login services and open Apple Music: run them only when asked.

## Rules

- **Stay small.** No UI, no menu bar item, no network access, no telemetry, no third-party dependencies, no configuration files unless an issue asks for one.
- **Swift 6 language mode** with strict concurrency. AppKit callbacks run on the main queue; hop with `MainActor.assumeIsolated`.
- **Logic goes in `TunelessCore`** so it can be unit-tested; keep `main.swift` as thin glue. Add or update tests for any behaviour change.
- **Never disable or modify `com.apple.rcd`.** That breaks media keys, which is the reason this project exists.
- **Only quit `com.apple.Music` and `com.apple.iTunes`.** Never kill other processes.
- The identifier `io.github.nacholaciar.tuneless` is the launchd label and the logging subsystem. Changing it breaks existing installs.
- Keep `README.md` accurate when behaviour, commands or requirements change. README is in English; keep it that way.

## Versioning and releases

- Commits follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:` minor, `fix:` patch, `docs:`/`chore:`/`refactor:`/`test:` no release.
- Release Please opens the release PR and tags `vX.Y.Z`. Do not edit `CHANGELOG.md`, `.release-please-manifest.json` or the version string by hand; the `// x-release-please-version` comment in `Tuneless.swift` is updated automatically.
- After a release, update `url` and `sha256` in both `Packaging/homebrew/tuneless.rb` and the tap's `Formula/tuneless.rb`:

```bash
curl -sL https://github.com/nacholaciar/tuneless/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
```

## Gotchas

- In zsh, `log` is a builtin; use `/usr/bin/log`.
- `launchctl kill` on this service may fail with "Not privileged to signal service"; use `launchctl bootout gui/$(id -u)/io.github.nacholaciar.tuneless`.
- launchd logs "This service is defined to be constantly running and is inherently inefficient" because of `KeepAlive`. This is expected.
