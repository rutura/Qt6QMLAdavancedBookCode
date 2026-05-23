# Standalone runnable examples — one per pattern from chapter 5.
# Each example is a tiny executable that links against the parent
# QmlAdvCore library and exercises a single pattern in isolation.
#
# Enabled automatically when QmlAdvCore is built as a top-level project.
# Pass -DQMLADVCORE_BUILD_EXAMPLES=OFF to skip.

function(qmladvcore_add_example example_name)
    # Target name and QML URI are intentionally distinct: qt_add_qml_module
    # creates a build-tree subdirectory named after the URI, which would
    # collide with the executable's output path if both used the same name.
    set(target qmladvcore_ex_${example_name})
    set(uri    Example_${example_name})

    qt_add_executable(${target} ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp)

    qt_add_qml_module(${target}
        URI ${uri}
        VERSION 1.0
        QML_FILES ${example_name}/Main.qml
    )

    target_compile_definitions(${target} PRIVATE
        EXAMPLE_URI="${uri}"
    )

    set_target_properties(${target} PROPERTIES
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
    )

    target_link_libraries(${target} PRIVATE
        Qt6::Quick
        QmlAdvCore
        QmlAdvCoreplugin
    )
endfunction()

qmladvcore_add_example(object_property)
qmladvcore_add_example(list_property)
qmladvcore_add_example(default_property)
qmladvcore_add_example(grouped_properties)
qmladvcore_add_example(attached_properties)
qmladvcore_add_example(value_source)
qmladvcore_add_example(services)
