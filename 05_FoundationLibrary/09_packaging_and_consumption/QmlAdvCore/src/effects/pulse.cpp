#include "effects/pulse.h"

Pulse::Pulse(QObject *parent)
    : QObject(parent)
    , QQmlPropertyValueSource()
{
}

Pulse::~Pulse()
{
    if (m_animation)
        m_animation->stop();
}

void Pulse::setTarget(const QQmlProperty &property)
{
    m_target = property;
    rebuild();
}

void Pulse::rebuild()
{
    if (!m_target.isValid())
        return;

    if (m_animation) {
        m_animation->stop();
        m_animation->deleteLater();
        m_animation = nullptr;
    }

    m_animation = new QVariantAnimation(this);
    m_animation->setDuration(m_period);
    m_animation->setLoopCount(-1); // infinite

    // Key values: from → to → from over [0.0, 1.0] progress
    // This creates a smooth ping-pong effect without a second animation object
    QVariantAnimation::KeyValues kv;
    kv << QVariantAnimation::KeyValue(0.0, m_from)
       << QVariantAnimation::KeyValue(0.5, m_to)
       << QVariantAnimation::KeyValue(1.0, m_from);
    m_animation->setKeyValues(kv);

    connect(m_animation, &QVariantAnimation::valueChanged,
            this, [this](const QVariant &value) {
                m_target.write(value);
            });

    if (m_running)
        m_animation->start();
}

void Pulse::setFrom(double v)
{
    if (qFuzzyCompare(m_from, v)) return;
    m_from = v;
    emit fromChanged();
    rebuild();
}

void Pulse::setTo(double v)
{
    if (qFuzzyCompare(m_to, v)) return;
    m_to = v;
    emit toChanged();
    rebuild();
}

void Pulse::setPeriod(int v)
{
    if (m_period == v) return;
    m_period = v;
    emit periodChanged();
    rebuild();
}

void Pulse::setRunning(bool v)
{
    if (m_running == v) return;
    m_running = v;
    emit runningChanged();
    if (m_animation) {
        if (m_running)
            m_animation->start();
        else
            m_animation->pause();
    }
}
