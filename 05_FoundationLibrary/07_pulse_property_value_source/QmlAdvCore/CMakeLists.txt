if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(QmlAdvCore VERSION 0.7.0 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    find_package(Qt6 REQUIRED COMPONENTS Quick)
    qt_standard_project_setup(REQUIRES 6.8)
endif()

qt_add_library(QmlAdvCore STATIC)

qt_add_qml_module(QmlAdvCore
    URI QmlAdvCore
    VERSION 1.0
    SOURCES
        src/version.h
        src/version.cpp
        src/theme/themecolors.h
        src/theme/themecolors.cpp
        src/theme/themespacing.h
        src/theme/themespacing.cpp
        src/theme/theme.h
        src/theme/theme.cpp
        src/forms/formfieldvalidation.h
        src/forms/formfieldvalidation.cpp
        src/forms/formfieldstyle.h
        src/forms/formfieldstyle.cpp
        src/forms/formfield.h
        src/forms/formfield.cpp
        src/forms/formgroup.h
        src/forms/formgroup.cpp
        src/forms/formattached.h
        src/forms/formattached.cpp
        src/forms/form.h
        src/forms/form.cpp
        src/components/card.h
        src/components/card.cpp
        src/effects/pulse.h
        src/effects/pulse.cpp
)

target_include_directories(QmlAdvCore PUBLIC src src/theme src/forms src/components src/effects)
target_link_libraries(QmlAdvCore PUBLIC Qt6::Quick)
