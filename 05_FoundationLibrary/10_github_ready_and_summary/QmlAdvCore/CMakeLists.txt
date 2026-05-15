if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(QmlAdvCore VERSION 1.0.0 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    find_package(Qt6 REQUIRED COMPONENTS Quick)
    qt_standard_project_setup(REQUIRES 6.8)
endif()

qt_add_library(QmlAdvCore STATIC)

qt_add_qml_module(QmlAdvCore
    URI QmlAdvCore
    VERSION 1.0
    SOURCES
        src/version.h
        src/version.cpp
        src/theme/themecolors.h
        src/theme/themecolors.cpp
        src/theme/themespacing.h
        src/theme/themespacing.cpp
        src/theme/theme.h
        src/theme/theme.cpp
        src/forms/formfieldvalidation.h
        src/forms/formfieldvalidation.cpp
        src/forms/formfieldstyle.h
        src/forms/formfieldstyle.cpp
        src/forms/formfield.h
        src/forms/formfield.cpp
        src/forms/formgroup.h
        src/forms/formgroup.cpp
        src/forms/formattached.h
        src/forms/formattached.cpp
        src/forms/form.h
        src/forms/form.cpp
        src/components/card.h
        src/components/card.cpp
        src/effects/pulse.h
        src/effects/pulse.cpp
        src/services/toastmanager.h
        src/services/toastmanager.cpp
        src/services/undostack.h
        src/services/undostack.cpp
    QML_FILES
        qml/ToastHost.qml
)

target_include_directories(QmlAdvCore PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/theme>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/forms>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/components>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/effects>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/services>
    $<INSTALL_INTERFACE:include/QmlAdvCore>
)

target_link_libraries(QmlAdvCore PUBLIC Qt6::Quick)

# --------------------------------------------------------------------------
# Install rules — allow consumers to use find_package(QmlAdvCore)
# --------------------------------------------------------------------------
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Install the backing library archive
install(TARGETS QmlAdvCore
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install the QML plugin archive (consumers must link it for type registration)
install(TARGETS QmlAdvCoreplugin
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Public headers (preserves subdir structure: include/QmlAdvCore/theme/...)
install(DIRECTORY src/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/QmlAdvCore
    FILES_MATCHING PATTERN "*.h"
)

# QML module files (qmldir, qmltypes, compiled QML)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCore/
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/QmlAdvCore
    FILES_MATCHING
        PATTERN "*.qml"
        PATTERN "*.qmltypes"
        PATTERN "qmldir"
        PATTERN "*.so"
        PATTERN "*.dll"
)

# CMake package config files (hand-crafted — avoids Qt internal target export issues)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlAdvCoreConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QmlAdvCore
    PATH_VARS CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_INCLUDEDIR
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake
    VERSION       1.0.0
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QmlAdvCore
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake
    VERSION       1.0.0
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/QmlAdvCoreConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QmlAdvCore
)
