# Repo Explorer Pro — Chapter 4 Final Project

A multi-tab GitHub client built with Qt 6 QML. Demonstrates REST-powered models,
disk caching, threading, ETags, live updates via polling, and persistent settings.

## Features

- **Repositories tab**: Search GitHub repos with offset or cursor pagination, star/fork counts, live auto-refresh with diff-merge highlighting.
- **Issues tab**: Search GitHub issues by keyword, paginated results.
- **Users tab**: Search GitHub users, paginated results with avatar images.
- **Disk cache**: All API responses cached to `%LOCALAPPDATA%\<org>\cache\RepoExplorerPro\` on Windows.
- **ETag conditional requests**: Avoids re-downloading unchanged data.
- **Tab persistence**: Last active tab and GitHub PAT are remembered between runs.
- **Keyboard shortcuts**: `Ctrl+L` focuses the search bar; `Esc` clears it.

## Build Requirements

- Qt 6.8 or later (tested with Qt 6.11.0)
- MinGW 13.1+ **or** MSVC 2022 on Windows; GCC 12+ on Linux
- CMake 3.16+

## Building

```bash
# Windows — MinGW
qt-cmake.bat -G "MinGW Makefiles" -S . -B build
cmake --build build -j 4
```

```bash
# Linux / macOS
qt-cmake -S . -B build
cmake --build build -j 4
```

## GitHub Personal Access Token

Without a PAT the GitHub Search API is rate-limited to **10 requests per minute**.
With a PAT you get 30 requests per minute.

1. Go to <https://github.com/settings/tokens> → *Generate new token (classic)*.
2. Grant **public_repo** read scope (no write permissions needed).
3. Paste the token into the expandable **Token** field in the Repositories tab.

The token is stored in the app's QSettings file and persists between launches.

## Cache Location

| Platform | Path |
|----------|------|
| Windows  | `%LOCALAPPDATA%\Qt6 QML Advanced\Repo Explorer Pro\cache\RepoExplorerPro\` |
| Linux    | `~/.local/share/Qt6 QML Advanced/Repo Explorer Pro/cache/RepoExplorerPro/` |
| macOS    | `~/Library/Application Support/Qt6 QML Advanced/Repo Explorer Pro/cache/RepoExplorerPro/` |

Delete the cache directory to force fresh network fetches.
