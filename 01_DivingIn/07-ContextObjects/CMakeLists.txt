cmake_minimum_required(VERSION 3.16)

project(07-ContextObjects VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(app07-ContextObjects
    main.cpp
)

qt_add_qml_module(app07-ContextObjects
    URI ContextObjects
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES propertywrapper.h propertywrapper.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(app07-ContextObjects PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.app07-ContextObjects
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(app07-ContextObjects
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS app07-ContextObjects
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
