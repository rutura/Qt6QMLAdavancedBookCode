#include "cacheworker.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDebug>

CacheWorker::CacheWorker(QObject *parent)
    : QObject(parent)
{
}

QString CacheWorker::cacheDir() const
{
    const QString base = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    const QString dir = base + "/RepoExplorerPro";
    static bool logged = false;
    if (!logged) {
        qDebug() << "[CacheWorker] Cache directory:" << dir;
        logged = true;
    }
    return dir;
}

QString CacheWorker::fileForKey(const QString &key) const
{
    const QByteArray hash = QCryptographicHash::hash(key.toUtf8(), QCryptographicHash::Sha1).toHex();
    return cacheDir() + "/" + QString::fromLatin1(hash) + ".bin";
}

void CacheWorker::save(const QString &key, const QByteArray &body)
{
    QDir().mkpath(cacheDir());

    QFile file(fileForKey(key));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;

    file.write(body);
}

void CacheWorker::load(const QString &key)
{
    QFile file(fileForKey(key));
    if (!file.open(QIODevice::ReadOnly)) {
        emit loaded(key, {}, false);
        return;
    }

    const QByteArray body = file.readAll();
    emit loaded(key, body, true);
}
