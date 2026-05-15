cmake_minimum_required(VERSION 3.16)

project(RepoExplorerPro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.8)

set(PROJECT_SOURCES
    main.cpp
)

set(QML_FILES
    qml/Main.qml
    qml/pages/RepositoryListPage.qml
)

qt_add_executable(RepoExplorerPro
    ${PROJECT_SOURCES}
)

qt_add_qml_module(RepoExplorerPro
    URI RepoExplorerProApp
    VERSION 1.0
    QML_FILES ${QML_FILES}
    SOURCES
        src/user.h
        src/user.cpp
        src/repository.h
        src/repository.cpp
        src/api/githubservice.h
        src/api/githubservice.cpp
)

set_target_properties(RepoExplorerPro PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(RepoExplorerPro
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/api
)

target_link_libraries(RepoExplorerPro
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS RepoExplorerPro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
