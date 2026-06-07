#include "cachemanager.h"
#include "cacheworker.h"

#include <QCoreApplication>

CacheManager::CacheManager(QObject *parent)
    : QObject(parent)
    , m_worker(new CacheWorker)
{
    m_worker->moveToThread(&m_thread);

    connect(this, &CacheManager::saveRequested,
            m_worker, &CacheWorker::save);
    connect(this, &CacheManager::loadRequested,
            m_worker, &CacheWorker::load);
    connect(m_worker, &CacheWorker::loaded,
            this, &CacheManager::loaded);

    connect(&m_thread, &QThread::finished, m_worker, &QObject::deleteLater);
    m_thread.setObjectName("CacheWorkerThread");
    m_thread.start();
}

CacheManager::~CacheManager()
{
    m_thread.quit();
    m_thread.wait();
}

CacheManager *CacheManager::create(QQmlEngine *, QJSEngine *)
{
    // Owned by the engine; survives for the lifetime of the application.
    static CacheManager *instance = new CacheManager(QCoreApplication::instance());
    return instance;
}

void CacheManager::requestLoad(const QString &key)
{
    emit loadRequested(key);
}

void CacheManager::requestSave(const QString &key, const QByteArray &body)
{
    emit saveRequested(key, body);
}