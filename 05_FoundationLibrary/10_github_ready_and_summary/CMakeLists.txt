cmake_minimum_required(VERSION 3.16)
project(Ch05_10_GitHubReadyAndSummary LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(QmlAdvCore)
add_subdirectory(demo)
