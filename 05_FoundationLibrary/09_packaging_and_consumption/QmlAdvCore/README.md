# QmlAdvCore

A Qt 6 QML library demonstrating advanced component patterns built throughout
Chapter 5 of *Qt 6 QML Advanced*.

## Features

| Pattern | Type(s) |
|---|---|
| Version singleton | `Version` (QML_SINGLETON) |
| Theme object-property | `Theme`, `ThemeColors`, `ThemeSpacing` |
| List property | `FormGroup`, `FormField` |
| Default property | `Card` |
| Grouped properties | `FormFieldValidation`, `FormFieldStyle` |
| Attached properties | `Form` / `FormAttached` |
| Property value source | `Pulse` |
| Singleton services | `ToastManager`, `UndoStack`, `ToastHost` |

## Requirements

- Qt 6.8 or later
- CMake 3.16 or later
- A C++17 compliant compiler

## Building

```bash
cmake -B build -S .
cmake --build build
```

## Installing

```bash
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/path/to/install
cmake --build build
cmake --install build
```

## Consuming via `find_package`

After installation:

```cmake
find_package(QmlAdvCore REQUIRED)
target_link_libraries(MyApp PRIVATE QmlAdvCore::QmlAdvCore)
```

Pass `-DCMAKE_PREFIX_PATH=/path/to/install` to cmake.

## Consuming via `add_subdirectory` (in-tree)

```cmake
add_subdirectory(QmlAdvCore)
target_link_libraries(MyApp PRIVATE QmlAdvCore QmlAdvCoreplugin)
```

## Consuming via CMake `FetchContent`

```cmake
include(FetchContent)
FetchContent_Declare(QmlAdvCore
    GIT_REPOSITORY https://github.com/yourname/QmlAdvCore.git
    GIT_TAG        v0.9.0
)
FetchContent_MakeAvailable(QmlAdvCore)
target_link_libraries(MyApp PRIVATE QmlAdvCore QmlAdvCoreplugin)
```

## License

MIT © 2026 Daniel Gakwaya
