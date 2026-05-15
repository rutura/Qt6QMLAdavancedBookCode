#ifndef PULSE_H
#define PULSE_H

#include <QObject>
#include <QVariantAnimation>
#include <QtQml/qqmlregistration.h>
#include <QtQml/QQmlProperty>
#include <QtQml/QQmlPropertyValueSource>

// Pulse drives a target property back and forth between `from` and `to`
// over `period` milliseconds, looping indefinitely.
//
// It implements the property value source interface — the same mechanism
// behind NumberAnimation, Behavior, and SmoothedAnimation.
//
// Usage:
//     Button {
//         Pulse on opacity { from: 0.4; to: 1.0; period: 800 }
//     }
//
// The `on opacity` syntax:
//   1. QML creates a Pulse instance.
//   2. It calls setTarget(QQmlProperty(button, "opacity")).
//   3. Pulse starts an internal animation that writes to that property.
//
// The target's type is QQmlProperty — a lightweight handle that wraps
// the object + property name.  Writing to it respects bindings and
// notifies the engine, just like a normal property write.
class Pulse : public QObject, public QQmlPropertyValueSource
{
    Q_OBJECT
    Q_INTERFACES(QQmlPropertyValueSource)
    QML_ELEMENT

    Q_PROPERTY(double from    READ from    WRITE setFrom    NOTIFY fromChanged)
    Q_PROPERTY(double to      READ to      WRITE setTo      NOTIFY toChanged)
    Q_PROPERTY(int    period  READ period  WRITE setPeriod  NOTIFY periodChanged)
    Q_PROPERTY(bool   running READ running WRITE setRunning NOTIFY runningChanged)

public:
    explicit Pulse(QObject *parent = nullptr);
    ~Pulse() override;

    // QQmlPropertyValueSource interface
    void setTarget(const QQmlProperty &property) override;

    double from()    const { return m_from; }
    double to()      const { return m_to; }
    int    period()  const { return m_period; }
    bool   running() const { return m_running; }

    void setFrom   (double v);
    void setTo     (double v);
    void setPeriod (int v);
    void setRunning(bool v);

signals:
    void fromChanged();
    void toChanged();
    void periodChanged();
    void runningChanged();

private:
    void rebuild();

    QQmlProperty       m_target;
    QVariantAnimation *m_animation{nullptr};

    double m_from{0.0};
    double m_to{1.0};
    int    m_period{1000};
    bool   m_running{true};
};

#endif // PULSE_H
