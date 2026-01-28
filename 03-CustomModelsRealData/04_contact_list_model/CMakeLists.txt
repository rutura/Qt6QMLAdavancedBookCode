cmake_minimum_required(VERSION 3.16)

project(ContactManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)


qt_standard_project_setup(REQUIRES 6.8)

# Source files
set(PROJECT_SOURCES
    main.cpp
    src/models/contact.h
    src/models/contact.cpp
    src/models/contactlistmodel.h
    src/models/contactlistmodel.cpp
)


# QML files
set(QML_FILES
    qml/Main.qml
    qml/components/ContactDelegate.qml
    qml/components/SearchBar.qml
    qml/components/FilterPanel.qml
    qml/pages/ContactListPage.qml
)


qt_add_executable(ContactManager
    ${PROJECT_SOURCES}
)

qt_add_qml_module(ContactManager
    URI ContactManagerApp
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(ContactManager PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.app02_ContactDataClass
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(ContactManager
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(ContactManager
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS ContactManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
