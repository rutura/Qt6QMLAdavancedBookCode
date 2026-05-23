qt_add_executable(QmlAdvCoreDemo
    main.cpp
)

qt_add_qml_module(QmlAdvCoreDemo
    URI QmlAdvCoreDemoApp
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(QmlAdvCoreDemo PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QmlAdvCoreDemo
    PRIVATE Qt6::Quick
    PRIVATE QmlAdvCore
    PRIVATE QmlAdvCoreplugin
)
