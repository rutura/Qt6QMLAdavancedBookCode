#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QString>
#include <qqml.h>

// QML singleton wrapping QSettings. Persists UI state across runs.
// Properties write-through immediately so there is no explicit save() call.
class AppSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int lastTabIndex READ lastTabIndex WRITE setLastTabIndex NOTIFY lastTabIndexChanged)
    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)
    Q_PROPERTY(int refreshIntervalMs READ refreshIntervalMs WRITE setRefreshIntervalMs NOTIFY refreshIntervalMsChanged)

public:
    explicit AppSettings(QObject *parent = nullptr);

    static AppSettings *create(QQmlEngine *, QJSEngine *);

    int lastTabIndex() const;
    QString authToken() const;
    int refreshIntervalMs() const;

    void setLastTabIndex(int index);
    void setAuthToken(const QString &token);
    void setRefreshIntervalMs(int ms);

signals:
    void lastTabIndexChanged();
    void authTokenChanged();
    void refreshIntervalMsChanged();

private:
    QSettings m_settings;
};

#endif // APPSETTINGS_H
