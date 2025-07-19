cmake_minimum_required(VERSION 3.16)

project(09-Instantiable_types VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(app09-Instantiable_types
    main.cpp
)

qt_add_qml_module(app09-Instantiable_types
    URI Instantiable_types
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES movie.h movie.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(app09-Instantiable_types PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.app09-Instantiable_types
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(app09-Instantiable_types
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS app09-Instantiable_types
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
