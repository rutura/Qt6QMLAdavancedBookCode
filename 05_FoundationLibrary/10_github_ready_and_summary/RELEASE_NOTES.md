# Chapter 5 Release Notes — QmlAdvCore 1.0.0

**Book**: *Qt 6 QML Advanced*, Chapter 5 — Foundation Library  
**Author**: Daniel Gakwaya  
**Date**: 2026

## Summary

This chapter built `QmlAdvCore` incrementally across ten sections,
demonstrating the full lifecycle of a Qt 6 QML module:

1. **Library skeleton** — standalone-guarded CMakeLists, Version singleton
2. **Object property** — nested QObject children exposed as constant properties
3. **List property** — `QQmlListProperty` for child-element syntax + Repeater model
4. **Default property** — `Q_CLASSINFO("DefaultProperty", ...)` on a `QQuickItem`
5. **Grouped properties** — sub-objects (validation, style) on an element
6. **Attached properties** — `QML_ATTACHED` on `Form` + `QML_ANONYMOUS` attached object
7. **Property value source** — `QQmlPropertyValueSource` + `Pulse on opacity {}`
8. **Singleton services** — `ToastManager` (QML_SINGLETON) + `UndoStack` (QML_ELEMENT)
9. **Packaging** — CMake install rules, `find_package` support, config helpers
10. **GitHub-ready** — README, CHANGELOG, CI workflow, .gitignore

## Key design decisions

- All C++ types use `#ifndef` include guards (consistent with rest of book)
- `QML_SINGLETON` types use a public default constructor (Qt calls it automatically)
- `UndoStack` is instantiable (not singleton) so multiple stacks can coexist
- `ToastHost.qml` decouples rendering from the `ToastManager` API
- Section 09 ships both `build_and_install.sh` and `build_and_install.ps1`
  so the `find_package` consumer can be reproduced on Linux and Windows
- CMake target name: `QmlAdvCore`; plugin: `QmlAdvCoreplugin`; URI: `QmlAdvCore`

## Build command (any section)

```bash
cd 05_FoundationLibrary/<section_folder>
cmake -B build
cmake --build build
./build/demo/QmlAdvCoreDemo        # Linux/macOS
build\demo\Release\QmlAdvCoreDemo.exe  # Windows
```
