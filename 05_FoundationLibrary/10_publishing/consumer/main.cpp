#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // QmlAdvCore is a static library. Its QML module resources are
    // embedded at :/qt/qml/QmlAdvCore/ inside the library. Adding
    // ":/" as an import path lets the QML engine find them.
    engine.addImportPath(QStringLiteral(":/"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule(
        QStringLiteral("QmlAdvCoreConsumerApp"),
        QStringLiteral("Main"));

    return app.exec();
}