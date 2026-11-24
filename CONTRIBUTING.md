# Contributing to Tuneless

Thank you for helping improve Tuneless.

## Before you start

1. Search existing issues and pull requests.
2. Open an issue before adding features. Tuneless stays deliberately small: no UI, no network, no dependencies.

## Development workflow

Requirements: macOS 14 or later and Swift 6 (Xcode 16 or later).

```bash
make test      # unit tests
make install   # build and run your local copy as a LaunchAgent
make smoke     # open Apple Music and check that it gets quit
make logs      # watcher logs from the last hour
```

`make uninstall` removes your local copy.

## Pull requests

- Keep each pull request focused.
- Explain the user-facing problem and the chosen solution.
- Add or update tests in `Tests/TunelessCoreTests` when behaviour changes.
- Use [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`, …). Release Please builds the changelog from them.

By contributing, you agree that your contribution may be distributed under the MIT Licence.
