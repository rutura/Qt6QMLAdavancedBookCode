cmake_minimum_required(VERSION 3.16)

project(RepoExplorerPro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network Concurrent)

qt_standard_project_setup(REQUIRES 6.8)

set(PROJECT_SOURCES
    main.cpp
)

set(QML_FILES
    qml/Main.qml
    qml/pages/RepositoryListPage.qml
    qml/pages/IssueListPage.qml
    qml/pages/UserListPage.qml
    qml/components/RepoDelegate.qml
    qml/components/IssueDelegate.qml
    qml/components/UserDelegate.qml
    qml/components/TokenSettings.qml
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
        src/models/abstractgithublistmodel.h
        src/models/abstractgithublistmodel.cpp
        src/models/repositorylistmodel.h
        src/models/repositorylistmodel.cpp
        src/models/issue.h
        src/models/issue.cpp
        src/models/issuelistmodel.h
        src/models/issuelistmodel.cpp
        src/models/userlistmodel.h
        src/models/userlistmodel.cpp
        src/services/cachemanager.h
        src/services/cachemanager.cpp
        src/services/appsettings.h
        src/services/appsettings.cpp
        src/workers/cacheworker.h
        src/workers/cacheworker.cpp
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
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/src/services
    ${CMAKE_CURRENT_SOURCE_DIR}/src/workers
)

target_link_libraries(RepoExplorerPro
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Concurrent
)

include(GNUInstallDirs)
install(TARGETS RepoExplorerPro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
