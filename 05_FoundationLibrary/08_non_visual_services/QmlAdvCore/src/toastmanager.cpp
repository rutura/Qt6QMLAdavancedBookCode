#include "toastmanager.h"

ToastManager::ToastManager(QObject *parent)
    : QObject(parent)
{
    m_timer = new QTimer(this);
    m_timer->setSingleShot(true);
    connect(m_timer, &QTimer::timeout, this, &ToastManager::dismiss);
}


void ToastManager::show(const QString &message, int duration)
{
    m_message = message;

    const int effectiveDuration = (duration > 0) ? duration : m_duration;
    m_timer->start(effectiveDuration);

    if (!m_visible) {
        m_visible = true;
        emit visibleChanged();
    }
    emit messageChanged();
}


void ToastManager::dismiss()
{
    m_timer->stop();
    if (!m_visible)
        return;
    m_visible = false;
    emit visibleChanged();
}

QString ToastManager::message()  const { return m_message; }
bool    ToastManager::visible()  const { return m_visible; }
int     ToastManager::duration() const { return m_duration; }

void ToastManager::setDuration(int ms)
{
    if (m_duration == ms)
        return;
    m_duration = ms;
    emit durationChanged();
}