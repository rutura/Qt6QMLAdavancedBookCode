#ifndef CACHEWORKER_H
#define CACHEWORKER_H

#include <QObject>
#include <QByteArray>
#include <QString>

// Lives on a worker thread (moved by CacheManager). All slots run off the GUI thread.
// On-disk format per entry: raw body bytes only.
// Files stored at <CacheLocation>/RepoExplorerPro/<sha1(key)>.bin.
class CacheWorker : public QObject
{
    Q_OBJECT
public:
    explicit CacheWorker(QObject *parent = nullptr);

public slots:
    void save(const QString &key, const QByteArray &body);
    void load(const QString &key);

signals:
    void loaded(const QString &key, const QByteArray &body, bool found);

private:
    QString fileForKey(const QString &key) const;
    QString cacheDir() const;
};

#endif // CACHEWORKER_H
