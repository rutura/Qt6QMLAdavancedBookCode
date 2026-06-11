find_package(Qt6 REQUIRED COMPONENTS Test)

qt_add_executable(tst_version
    tst_version.cpp
    tst_theme.cpp
)

target_link_libraries(tst_version
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_version COMMAND tst_version)


qt_add_executable(tst_theme
    tst_theme.cpp
)

target_link_libraries(tst_theme
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_theme COMMAND tst_theme)