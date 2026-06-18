find_package(Qt6 REQUIRED COMPONENTS Quick Test)

qt_add_executable(tst_version
    tst_version.cpp
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


qt_add_executable(tst_formgroup
    tst_formgroup.cpp
)

target_link_libraries(tst_formgroup
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_formgroup COMMAND tst_formgroup)


qt_add_executable(tst_card
    tst_card.cpp
)

target_link_libraries(tst_card
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_card COMMAND tst_card)


qt_add_executable(tst_fieldvalidation
    tst_fieldvalidation.cpp
)

target_link_libraries(tst_fieldvalidation
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_fieldvalidation COMMAND tst_fieldvalidation)

qt_add_executable(tst_formattached
    tst_formattached.cpp
)

target_link_libraries(tst_formattached
    PRIVATE Qt6::Test
    PRIVATE Qt6::Quick
    PRIVATE QmlAdvCore
)

add_test(NAME tst_formattached COMMAND tst_formattached)


qt_add_executable(tst_pulse
    tst_pulse.cpp
)

target_link_libraries(tst_pulse
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_pulse COMMAND tst_pulse)


qt_add_executable(tst_toastmanager
    tst_toastmanager.cpp
)

target_link_libraries(tst_toastmanager
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_toastmanager COMMAND tst_toastmanager)

qt_add_executable(tst_undostack
    tst_undostack.cpp
)

target_link_libraries(tst_undostack
    PRIVATE Qt6::Test
    PRIVATE QmlAdvCore
)

add_test(NAME tst_undostack COMMAND tst_undostack)