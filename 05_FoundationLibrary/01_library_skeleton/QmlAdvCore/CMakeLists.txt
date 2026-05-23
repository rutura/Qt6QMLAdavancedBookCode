if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(QmlAdvCore VERSION 0.1.0 LANGUAGES CXX)
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
)

target_include_directories(QmlAdvCore PUBLIC src)
target_link_libraries(QmlAdvCore PUBLIC Qt6::Quick)
