## Using with FetchContent (recommended)

include(FetchContent)
FetchContent_Declare(
    QmlAdvCore
    GIT_REPOSITORY https://github.com/<you>/QmlAdvCore.git
    GIT_TAG        v1.0.0
)
FetchContent_MakeAvailable(QmlAdvCore)

target_link_libraries(myApp
    PRIVATE QmlAdvCore
    PRIVATE QmlAdvCoreplugin
)

In main.cpp, add:
engine.addImportPath(":/");

## Using with find_package

cmake --build <build-dir> --target install
# then in your project:
find_package(QmlAdvCore REQUIRED)
target_link_libraries(myApp
    PRIVATE QmlAdvCore::QmlAdvCore
    PRIVATE QmlAdvCore::QmlAdvCoreplugin
)