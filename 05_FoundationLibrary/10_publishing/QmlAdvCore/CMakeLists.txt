if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(QmlAdvCore VERSION 1.0.0 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    find_package(Qt6 REQUIRED COMPONENTS Quick)
    qt_standard_project_setup(REQUIRES 6.8)
endif()

# Canonical library version used by install rules (works in both standalone and
# subdirectory builds).
set(QMLADVCORELIB_VERSION "1.0.0")

# Generate a header that exposes the version string to C++ code.
# The generated file lands in CMAKE_CURRENT_BINARY_DIR/src/version_string.h
# and is #included by version.cpp.
configure_file(
    src/version_string.h.in
    src/version_string.h
    @ONLY
)

qt_add_library(QmlAdvCore STATIC)

qt_add_qml_module(QmlAdvCore
    URI QmlAdvCore
    VERSION 1.0
    SOURCES
        src/version.h
        src/version.cpp
        src/colorpalette.h
        src/colorpalette.cpp
        src/spacinggroup.h
        src/spacinggroup.cpp
        src/theme.h
        src/theme.cpp
        src/fieldvalidation.h
        src/fieldvalidation.cpp
        src/formfield.h
        src/formfield.cpp
        src/formgroup.h 
        src/formgroup.cpp
        src/card.h
        src/card.cpp
        src/formattached.h
        src/formattached.cpp
        src/form.h
        src/form.cpp
        src/pulse.h
        src/pulse.cpp
        src/toastmanager.h
        src/toastmanager.cpp
        src/undostack.h
        src/undostack.cpp
)

target_include_directories(QmlAdvCore
    PUBLIC
        # In the build tree, expose src/ directly.
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        # Also expose the binary dir so version_string.h (generated) is found.
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
        # In the install tree, headers land in <prefix>/include/QmlAdvCore/.
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/QmlAdvCore>
)
target_link_libraries(QmlAdvCore PUBLIC Qt6::Quick)


# ── Install rules ──
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Where cmake config files land (e.g. <prefix>/lib/cmake/QmlAdvCore/)
set(QMLADVCORELIB_INSTALL_CMAKEDIR
    "${CMAKE_INSTALL_LIBDIR}/cmake/QmlAdvCore"
    CACHE STRING "Install destination for QmlAdvCore CMake config files")

# 1. Install all library targets.
#    qt_add_qml_module creates several internal targets — all must appear in the
#    same EXPORT set so the generated QmlAdvCoreTargets.cmake is self-contained:
#
#    QmlAdvCore            – backing STATIC library (type registrations)
#    QmlAdvCore_resources_1– OBJECT library: embedded QML module resources
#    QmlAdvCoreplugin      – optional STATIC plugin
#    QmlAdvCoreplugin_init – OBJECT library: Q_IMPORT_PLUGIN bootstrap
install(TARGETS
    QmlAdvCore
    QmlAdvCore_resources_1
    QmlAdvCoreplugin
    QmlAdvCoreplugin_init
    EXPORT  QmlAdvCoreTargets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    OBJECTS DESTINATION "${CMAKE_INSTALL_LIBDIR}/objects/QmlAdvCore"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)


# 2. Install public C++ headers.
install(DIRECTORY src/
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/QmlAdvCore"
    FILES_MATCHING PATTERN "*.h"
)

# 3. Install QML module descriptor files (qmldir + type info).
#    These live in the resources at :/qt/qml/QmlAdvCore/ at runtime, but
#    installing them to the filesystem lets tools (qmlls, Qt Creator) find them.
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/qmldir"
    "${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCore.qmltypes"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/QmlAdvCore"
)

# 4. Write and install the CMake targets file.
install(EXPORT QmlAdvCoreTargets
    FILE      QmlAdvCoreTargets.cmake
    NAMESPACE QmlAdvCore::
    DESTINATION "${QMLADVCORELIB_INSTALL_CMAKEDIR}"
)

# 5. Generate QmlAdvCoreConfig.cmake from the .in template.
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlAdvCoreConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfig.cmake"
    INSTALL_DESTINATION "${QMLADVCORELIB_INSTALL_CMAKEDIR}"
)

# 6. Generate QmlAdvCoreConfigVersion.cmake (SameMajorVersion compatibility).
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake"
    VERSION     "${QMLADVCORELIB_VERSION}"
    COMPATIBILITY SameMajorVersion
)

# 7. Install both generated cmake files.
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake"
    DESTINATION "${QMLADVCORELIB_INSTALL_CMAKEDIR}"
)