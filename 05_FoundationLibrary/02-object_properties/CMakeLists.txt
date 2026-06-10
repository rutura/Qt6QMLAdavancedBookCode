cmake_minimum_required(VERSION 3.16)
project(QmlAdvCore LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Test)
qt_standard_project_setup(REQUIRES 6.8)

enable_testing()

add_subdirectory(QmlAdvCore)
add_subdirectory(demo)
add_subdirectory(tests)