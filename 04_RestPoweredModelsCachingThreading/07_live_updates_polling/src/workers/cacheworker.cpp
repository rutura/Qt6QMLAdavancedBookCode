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
    /*
    const QString base = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    return base + "/RepoExplorerPro";
    */

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

void CacheWorker::save(const QString &key, const QByteArray &body, const QByteArray &etag)
{
    QDir().mkpath(cacheDir());

    QFile file(fileForKey(key));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;

    const quint32 etagLen = static_cast<quint32>(etag.size());
    char header[4];
    header[0] = static_cast<char>(etagLen & 0xFF);
    header[1] = static_cast<char>((etagLen >> 8) & 0xFF);
    header[2] = static_cast<char>((etagLen >> 16) & 0xFF);
    header[3] = static_cast<char>((etagLen >> 24) & 0xFF);

    file.write(header, 4);
    if (etagLen > 0)
        file.write(etag);
    file.write(body);
}

void CacheWorker::load(const QString &key)
{
    QFile file(fileForKey(key));
    if (!file.open(QIODevice::ReadOnly)) {
        emit loaded(key, {}, {}, false);
        return;
    }

    const QByteArray header = file.read(4);
    if (header.size() != 4) {
        emit loaded(key, {}, {}, false);
        return;
    }

    const quint32 etagLen = static_cast<quint8>(header[0])
                            | (static_cast<quint32>(static_cast<quint8>(header[1])) << 8)
                            | (static_cast<quint32>(static_cast<quint8>(header[2])) << 16)
                            | (static_cast<quint32>(static_cast<quint8>(header[3])) << 24);

    const QByteArray etag = etagLen > 0 ? file.read(etagLen) : QByteArray();
    const QByteArray body = file.readAll();

    emit loaded(key, body, etag, true);
}