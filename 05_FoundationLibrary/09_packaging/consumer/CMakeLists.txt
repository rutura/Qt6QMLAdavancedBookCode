cmake_minimum_required(VERSION 3.16)
project(QmlAdvCoreConsumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

find_package(QmlAdvCore REQUIRED)

qt_add_executable(QmlAdvCoreConsumer main.cpp)

qt_add_qml_module(QmlAdvCoreConsumer
    URI QmlAdvCoreConsumerApp
    VERSION 1.0
    QML_FILES Main.qml
)

set_target_properties(QmlAdvCoreConsumer PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QmlAdvCoreConsumer
    PRIVATE Qt6::Quick
    PRIVATE QmlAdvCore::QmlAdvCore
    PRIVATE QmlAdvCore::QmlAdvCoreplugin
)