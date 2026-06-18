#include "pulse.h"

Pulse::Pulse(QObject *parent)
    : QObject(parent)
{
    m_group   = new QSequentialAnimationGroup(this);
    m_forward = new QVariantAnimation(this);
    m_reverse = new QVariantAnimation(this);

    m_group->addAnimation(m_forward);
    m_group->addAnimation(m_reverse);
    m_group->setLoopCount(-1);

    auto writeTarget = [this](const QVariant &v) {
        if (m_target.isValid())
            m_target.write(v);
    };

    connect(m_forward, &QVariantAnimation::valueChanged, this, writeTarget);
    connect(m_reverse, &QVariantAnimation::valueChanged, this, writeTarget);

    rebuildAnimation();
}

Pulse::~Pulse() = default;

void Pulse::setTarget(const QQmlProperty &property)
{
    m_target = property;
    rebuildAnimation();
    if (m_running)
        m_group->start();
}

qreal Pulse::from() const { return m_from; }
void  Pulse::setFrom(qreal from)
{
    if (qFuzzyCompare(m_from, from))
        return;
    m_from = from;
    rebuildAnimation();
    emit fromChanged();
}

qreal Pulse::to() const { return m_to; }
void  Pulse::setTo(qreal to)
{
    if (qFuzzyCompare(m_to, to))
        return;
    m_to = to;
    rebuildAnimation();
    emit toChanged();
}


int  Pulse::duration() const { return m_duration; }
void Pulse::setDuration(int duration)
{
    if (m_duration == duration)
        return;
    m_duration = duration;
    rebuildAnimation();
    emit durationChanged();
}

bool Pulse::running() const { return m_running; }
void Pulse::setRunning(bool running)
{
    if (m_running == running)
        return;
    m_running = running;
    if (m_running)
        m_group->start();
    else
        m_group->stop();
    emit runningChanged();
}

void Pulse::rebuildAnimation()
{
    const bool wasRunning =
        (m_group->state() == QAbstractAnimation::Running);
    m_group->stop();

    m_forward->setStartValue(m_from);
    m_forward->setEndValue(m_to);
    m_forward->setDuration(m_duration / 2);
    m_forward->setEasingCurve(QEasingCurve::InOutSine);

    m_reverse->setStartValue(m_to);
    m_reverse->setEndValue(m_from);
    m_reverse->setDuration(m_duration / 2);
    m_reverse->setEasingCurve(QEasingCurve::InOutSine);

    if (wasRunning || (m_running && m_target.isValid()))
        m_group->start();
}