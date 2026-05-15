cmake_minimum_required(VERSION 3.16)
project(QmlAdvCoreFindPackageDemo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

# Locate the installed QmlAdvCore package.
# Point cmake to the install prefix with:
#   -DCMAKE_PREFIX_PATH=<install-prefix>
# or:
#   -DQmlAdvCore_ROOT=<install-prefix>/lib/cmake/QmlAdvCore
find_package(QmlAdvCore REQUIRED)

qt_add_executable(QmlAdvCoreFindPkgDemo
    main.cpp
)

qt_add_qml_module(QmlAdvCoreFindPkgDemo
    URI QmlAdvCoreDemoApp
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(QmlAdvCoreFindPkgDemo PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QmlAdvCoreFindPkgDemo
    PRIVATE Qt6::Quick
    PRIVATE QmlAdvCore::QmlAdvCore
    PRIVATE QmlAdvCore::QmlAdvCoreplugin
)
