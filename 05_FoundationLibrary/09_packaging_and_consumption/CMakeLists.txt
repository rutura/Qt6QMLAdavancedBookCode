cmake_minimum_required(VERSION 3.16)
project(Ch05_09_PackagingAndConsumption LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

# Build the library first so the in-tree demo can link against it directly.
add_subdirectory(QmlAdvCore)
add_subdirectory(demo/in_tree)

# demo/find_package is intentionally NOT added here — it is a standalone
# project that discovers QmlAdvCore via find_package() after installation.
# Build it separately:
#
#   cmake -B build/find_pkg demo/find_package \
#         -DQmlAdvCore_ROOT=<install-prefix>/lib/cmake/QmlAdvCore
