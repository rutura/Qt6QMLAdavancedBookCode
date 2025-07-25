cmake_minimum_required(VERSION 3.16)

project(10-QmlModules VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(app10-QmlModules
    main.cpp
)

qt_add_qml_module(app10-QmlModules
    URI QmlModules
    VERSION 1.0
    QML_FILES
        Main.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(app10-QmlModules PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.app10-QmlModules
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(app10-QmlModules
    PRIVATE Qt6::Quick
)

# Add the extra module subdirectory
add_subdirectory(extra)

# Add the backend module subdirectory
add_subdirectory(backend)

# Link the extra module plugin and backend module to the main program
target_link_libraries(app10-QmlModules
    PRIVATE extra_moduleplugin
    PRIVATE backend_module)

include(GNUInstallDirs)
install(TARGETS app10-QmlModules
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
