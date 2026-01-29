#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "src/models/contactlistmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set Fusion style to support custom controls
    QQuickStyle::setStyle("Fusion");

    // Create and register the contact list model
    ContactListModel contactModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("contactsModel", &contactModel);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ContactManagerApp", "Main");


    return app.exec();
}
