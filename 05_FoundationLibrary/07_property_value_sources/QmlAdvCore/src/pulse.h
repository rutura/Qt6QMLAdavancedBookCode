#ifndef PULSE_H
#define PULSE_H

#include <QObject>
#include <QQmlProperty>
#include <QQmlPropertyValueSource>
#include <QSequentialAnimationGroup>
#include <QVariantAnimation>
#include <QtQml/qqmlregistration.h>

class Pulse : public QObject, public QQmlPropertyValueSource
{
    Q_OBJECT
    Q_INTERFACES(QQmlPropertyValueSource)
    QML_ELEMENT

    Q_PROPERTY(qreal from     READ from     WRITE setFrom     NOTIFY fromChanged)
    Q_PROPERTY(qreal to       READ to       WRITE setTo       NOTIFY toChanged)
    Q_PROPERTY(int   duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(bool  running  READ running  WRITE setRunning  NOTIFY runningChanged)

public:
    explicit Pulse(QObject *parent = nullptr);
    ~Pulse() override;

    void setTarget(const QQmlProperty &property) override;

    qreal from() const;
    void  setFrom(qreal from);

    qreal to() const;
    void  setTo(qreal to);

    int  duration() const;
    void setDuration(int duration);

    bool running() const;
    void setRunning(bool running);

signals:
    void fromChanged();
    void toChanged();
    void durationChanged();
    void runningChanged();

private:
    void rebuildAnimation();

    QQmlProperty               m_target;
    QSequentialAnimationGroup *m_group{nullptr};
    QVariantAnimation         *m_forward{nullptr};
    QVariantAnimation         *m_reverse{nullptr};

    qreal m_from{0.2};
    qreal m_to{1.0};
    int   m_duration{1000};
    bool  m_running{true};
};

#endif // PULSE_H