#ifndef CACHEMANAGER_H
#define CACHEMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QThread>
#include <qqml.h>

class CacheWorker;

// Facade owned on the GUI thread. Owns a QThread + CacheWorker; signals/slots
// hop across the thread boundary automatically thanks to queued connections.
// Exposed to QML as a singleton so all models share the same on-disk cache.
class CacheManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit CacheManager(QObject *parent = nullptr);
    ~CacheManager() override;

    static CacheManager *create(QQmlEngine *, QJSEngine *);

public slots:
    void requestLoad(const QString &key);
    void requestSave(const QString &key, const QByteArray &body);

signals:
    void loaded(const QString &key, const QByteArray &body, bool found);

    // Internal-only signals used to dispatch work to the worker on its thread.
    // They cross threads via the queued connection set up in the constructor.
    void saveRequested(const QString &key, const QByteArray &body);
    void loadRequested(const QString &key);

private:
    QThread m_thread;
    CacheWorker *m_worker;
};

#endif // CACHEMANAGER_H