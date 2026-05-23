# QmlAdvCore

A production-ready Qt 6 QML library showcasing eight advanced component
patterns from *Qt 6 QML Advanced*, Chapter 5.

## What's inside

| Section | Pattern | Key type(s) |
|---|---|---|
| 01 | Library skeleton | `Version` (QML_SINGLETON) |
| 02 | Object property | `Theme`, `ThemeColors`, `ThemeSpacing` |
| 03 | List property | `FormGroup`, `FormField` |
| 04 | Default property | `Card` |
| 05 | Grouped properties | `FormFieldValidation`, `FormFieldStyle` |
| 06 | Attached properties | `Form` / `FormAttached` |
| 07 | Property value source | `Pulse` |
| 08 | Singleton services | `ToastManager`, `UndoStack`, `ToastHost` |

## Requirements

- **Qt 6.8+** — `qt_standard_project_setup(REQUIRES 6.8)` enforces this
- **CMake 3.16+**
- **C++17** compiler (MSVC, GCC, Clang)

No shell scripts, no platform-specific hacks. The library builds identically
on Windows, macOS, and Linux.

## Quick start

```bash
# Clone
git clone https://github.com/yourname/QmlAdvCore.git
cd QmlAdvCore

# Configure + build
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

# (optional) Install
cmake --install build --prefix /usr/local
```

## Consumption options

### 1 — `add_subdirectory` (in-tree / submodule)

```cmake
add_subdirectory(QmlAdvCore)
target_link_libraries(MyApp PRIVATE QmlAdvCore QmlAdvCoreplugin)
```

### 2 — `FetchContent`

```cmake
include(FetchContent)
FetchContent_Declare(QmlAdvCore
    GIT_REPOSITORY https://github.com/yourname/QmlAdvCore.git
    GIT_TAG        v1.0.0
)
FetchContent_MakeAvailable(QmlAdvCore)
target_link_libraries(MyApp PRIVATE QmlAdvCore QmlAdvCoreplugin)
```

### 3 — `find_package` (after install)

```cmake
find_package(QmlAdvCore REQUIRED)
target_link_libraries(MyApp PRIVATE QmlAdvCore::QmlAdvCore)
```

Pass `-DCMAKE_PREFIX_PATH=/usr/local` (or wherever you installed).

## Versioning

This library follows **Semantic Versioning** (semver.org).  
The `Version` singleton exposes the current version string at runtime:

```qml
import QmlAdvCore
Text { text: "v" + Version.string }
```

Compatible with any Qt 6.8 minor release. Major API changes will
increment the major version.

## License

MIT © 2026 Daniel Gakwaya — see [LICENSE](LICENSE)
