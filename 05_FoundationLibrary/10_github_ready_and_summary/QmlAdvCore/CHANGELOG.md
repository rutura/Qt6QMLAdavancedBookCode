# Changelog

All notable changes to QmlAdvCore are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026

### Added
- CI matrix workflow (Ubuntu + Windows) via GitHub Actions

### Changed
- Promoted from 0.9.0 pre-release; public API is now stable

---

## [0.9.0]

### Added
- CMake install rules: `install(TARGETS …)`, `configure_package_config_file`, `write_basic_package_version_file`
- `QmlAdvCoreConfig.cmake.in` enabling `find_package(QmlAdvCore)`
- In-tree demo (`demo/in_tree`) and installed-package demo (`demo/find_package`)
- `README.md` with all three consumption patterns

---

## [0.8.0]

### Added
- `ToastManager` — app-level singleton for displaying non-blocking toasts
- `UndoStack` — instantiable command-pattern undo/redo stack using QJSValue closures
- `ToastHost.qml` — companion QML component; drop once at the window root

---

## [0.7.0]

### Added
- `Pulse` property value source — drives any writable `real` property with a
  ping-pong animation using the `Pulse on propertyName {}` syntax

---

## [0.6.0]

### Added
- `Form` / `FormAttached` — attached properties pattern; items declare
  `Form.field`, `Form.required`, `Form.pattern` without referencing a concrete object

---

## [0.5.0]

### Added
- `FormFieldValidation` — required / minLength / maxLength / pattern validation
- `FormFieldStyle` — padding / border / radius style group
- `FormField` extended with `.validation` and `.style` grouped-property objects

---

## [0.4.0]

### Added
- `Card` — `QQuickItem` subclass with a `DefaultProperty` of `contentItems`,
  polished layout engine, and `padding`/`spacing` properties

---

## [0.3.0]

### Added
- `FormGroup` with `QQmlListProperty<FormField>` enabling child-element syntax
- `fieldList` (`QList<QObject*>`) for use as a `Repeater` model
- `FormField` with `FieldType` enum (Text, Email, Number, Password)

---

## [0.2.0]

### Added
- `Theme` singleton with `colors` (ThemeColors) and `spacing` (ThemeSpacing) object properties
- `setMode("light"|"dark")` driving `ThemeColors::applyLight/applyDark`

---

## [0.1.0]

### Added
- Initial library skeleton: `Version` QML singleton, CMake module structure,
  standalone-guard in `QmlAdvCore/CMakeLists.txt`
