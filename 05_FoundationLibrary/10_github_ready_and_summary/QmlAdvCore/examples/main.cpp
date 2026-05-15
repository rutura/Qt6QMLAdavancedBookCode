#include <QGuiApplication>
#include <QQmlApplicationEngine>

#ifndef EXAMPLE_URI
#  error "EXAMPLE_URI must be defined at compile time."
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.loadFromModule(EXAMPLE_URI, "Main");

    return app.exec();
}
