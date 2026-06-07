cmake_minimum_required(VERSION 3.16)

project(RepoExplorerPro VERSION 0.1 LANGUAGES CXX)


set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)


qt_standard_project_setup(REQUIRES 6.10)

set(PROJECT_SOURCES
    main.cpp
)

# Notice that the QML files have moved in a qml subfolder.
# We will need to move the QML file Qt Creator generated .
set(QML_FILES
    qml/Main.qml
    qml/pages/RepositoryListPage.qml
    qml/components/ThemeToggle.qml
    qml/components/AppHeader.qml
    qml/components/SearchField.qml
    qml/components/AccentButton.qml
    qml/components/PillBadge.qml
    qml/components/TokenField.qml
    qml/components/RepoCard.qml
    qml/components/StatusStrip.qml
    qml/components/ListContainer.qml
    qml/components/EmptyState.qml
    qml/components/LoadingOverlay.qml
)

# Theme.qml is a QML singleton (it starts with `pragma Singleton`). This
# property makes Qt generate the qmldir entry for it automatically, so we
# don't hand-write a qmldir file.
set_source_files_properties(qml/components/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_executable(RepoExplorerPro
    ${PROJECT_SOURCES}
)

qt_add_qml_module(RepoExplorerPro
    URI RepoExplorerProApp
    VERSION 1.0
    QML_FILES
        ${QML_FILES}
        qml/components/Theme.qml

    SOURCES
        src/user.h
        src/user.cpp
        src/repository.h
        src/repository.cpp
        src/api/githubservice.h
        src/api/githubservice.cpp
        src/models/repositorylistmodel.h
        src/models/repositorylistmodel.cpp
)

target_include_directories(RepoExplorerPro
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/api
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(RepoExplorerPro PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appRepositoryExplorerPro
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
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

install(TARGETS RepoExplorerPro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
