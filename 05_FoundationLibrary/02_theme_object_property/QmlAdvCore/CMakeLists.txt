if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(QmlAdvCore VERSION 0.2.0 LANGUAGES CXX)
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
)

target_include_directories(QmlAdvCore PUBLIC src src/theme)
target_link_libraries(QmlAdvCore PUBLIC Qt6::Quick)
