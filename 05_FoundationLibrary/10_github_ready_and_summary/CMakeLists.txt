cmake_minimum_required(VERSION 3.16)
project(Ch05_10_GitHubReadyAndSummary LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

# Build the runnable per-pattern examples alongside the chapter demo so
# the section verifies they all compile against the final 1.0.0 library.
set(QMLADVCORE_BUILD_EXAMPLES ON CACHE BOOL "" FORCE)

add_subdirectory(QmlAdvCore)
add_subdirectory(demo)
