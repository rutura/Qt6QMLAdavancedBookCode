qt_add_library(backend_module STATIC)
qt_add_qml_module(backend_module
    URI Backend
    VERSION 1.0
    QML_FILES
    SOURCES
        backend.h
        backend.cpp
    RESOURCE_PREFIX /
)
