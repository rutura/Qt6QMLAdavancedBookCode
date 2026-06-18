find_package(Qt6 REQUIRED COMPONENTS Test)

qt_add_executable(tst_version
    tst_version.cpp
)

target_link_libraries(tst_version
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_version COMMAND tst_version)