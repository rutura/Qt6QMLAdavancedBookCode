# CMakeLists.txt for the extra QML module
qt_add_library(extra_module STATIC)
qt_add_qml_module(extra_module
    URI ExtraModule
    VERSION 1.0
    QML_FILES
        Extra.qml
    RESOURCE_PREFIX /
)