cmake_minimum_required(VERSION 3.21)
project(QmlAdvCoreFetchContentDemo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

include(FetchContent)

FetchContent_Declare(
    QmlAdvCore
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../QmlAdvCore"
)

FetchContent_MakeAvailable(QmlAdvCore)

qt_add_executable(QmlAdvCoreFCDemo main.cpp)

qt_add_qml_module(QmlAdvCoreFCDemo
    URI QmlAdvCoreFCDemoApp
    VERSION 1.0
    QML_FILES Main.qml
)

set_target_properties(QmlAdvCoreFCDemo PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QmlAdvCoreFCDemo
    PRIVATE Qt6::Quick
    PRIVATE QmlAdvCore
    PRIVATE QmlAdvCoreplugin
)