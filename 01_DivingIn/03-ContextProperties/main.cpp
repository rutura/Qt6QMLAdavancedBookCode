#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> //Make sure this header is included
#include "cppworker.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    CppWorker cppworker;
    engine.rootContext()->setContextProperty("BWorker", &cppworker);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ContextProperties", "Main");

    return app.exec();
}
