#include "appsettings.h"

#include <QCoreApplication>

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings(QSettings::IniFormat, QSettings::UserScope,
                 QCoreApplication::organizationName(),
                 QCoreApplication::applicationName())
{
}

AppSettings *AppSettings::create(QQmlEngine *, QJSEngine *)
{
    static AppSettings *instance = new AppSettings(QCoreApplication::instance());
    return instance;
}

int AppSettings::lastTabIndex() const
{
    return m_settings.value("ui/lastTabIndex", 0).toInt();
}

QString AppSettings::authToken() const
{
    return m_settings.value("api/authToken").toString();
}

int AppSettings::refreshIntervalMs() const
{
    return m_settings.value("ui/refreshIntervalMs", 60000).toInt();
}

void AppSettings::setLastTabIndex(int index)
{
    if (lastTabIndex() != index) {
        m_settings.setValue("ui/lastTabIndex", index);
        emit lastTabIndexChanged();
    }
}

void AppSettings::setAuthToken(const QString &token)
{
    if (authToken() != token) {
        m_settings.setValue("api/authToken", token);
        emit authTokenChanged();
    }
}

void AppSettings::setRefreshIntervalMs(int ms)
{
    if (refreshIntervalMs() != ms && ms > 0) {
        m_settings.setValue("ui/refreshIntervalMs", ms);
        emit refreshIntervalMsChanged();
    }
}
