#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

// Include ContactManager to ensure QML_ELEMENT registration works
#include "managers/ContactManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set Fusion style to support custom controls
    QQuickStyle::setStyle("Fusion");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ContactManagerApp", "Main");

    return app.exec();
}
