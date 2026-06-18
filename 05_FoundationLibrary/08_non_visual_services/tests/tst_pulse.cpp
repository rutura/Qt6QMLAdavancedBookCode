#include <QTest>
#include <QSignalSpy>
#include <QQmlEngine>
#include <QQmlProperty>
#include "pulse.h"

class TargetObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal value READ value WRITE setValue NOTIFY valueChanged)
public:
    explicit TargetObject(QObject *parent = nullptr) : QObject(parent) {}
    qreal value() const { return m_value; }
    void setValue(qreal v)
    {
        if (!qFuzzyCompare(m_value + 1.0, v + 1.0)) {
            m_value = v;
            emit valueChanged();
        }
    }
signals:
    void valueChanged();
private:
    qreal m_value{0.0};
};


class TestPulse : public QObject
{
    Q_OBJECT
private slots:
    void defaultFrom();
    void defaultTo();
    void defaultDuration();
    void defaultRunning();
    void setFromRoundtrip();
    void setToRoundtrip();
    void setDurationRoundtrip();
    void fromChangedEmitted();
    void toChangedEmitted();
    void durationChangedEmitted();
    void runningChangedEmitted();
    void fromNotEmittedForSameValue();
    void toNotEmittedForSameValue();
    void durationNotEmittedForSameValue();
    void runningNotEmittedForSameValue();
    void setRunningFalseStopsAnimation();
    void setRunningTrueStartsAnimation();
    void setTargetKeepsRunningFlag();
    void setTargetWritesPropertyEventually();
};


void TestPulse::defaultFrom()
{
    Pulse p;
    QCOMPARE(p.from(), 0.2);
}

void TestPulse::defaultTo()
{
    Pulse p;
    QCOMPARE(p.to(), 1.0);
}

void TestPulse::defaultDuration()
{
    Pulse p;
    QCOMPARE(p.duration(), 1000);
}

void TestPulse::defaultRunning()
{
    Pulse p;
    QVERIFY(p.running());
}


void TestPulse::setFromRoundtrip()
{
    Pulse p;
    p.setFrom(0.0);
    QCOMPARE(p.from(), 0.0);
    p.setFrom(0.5);
    QCOMPARE(p.from(), 0.5);
}

void TestPulse::setToRoundtrip()
{
    Pulse p;
    p.setTo(0.8);
    QCOMPARE(p.to(), 0.8);
}

void TestPulse::setDurationRoundtrip()
{
    Pulse p;
    p.setDuration(2000);
    QCOMPARE(p.duration(), 2000);
}


void TestPulse::fromChangedEmitted()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::fromChanged);
    p.setFrom(0.0);
    QCOMPARE(spy.count(), 1);
}

void TestPulse::toChangedEmitted()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::toChanged);
    p.setTo(0.9);
    QCOMPARE(spy.count(), 1);
}

void TestPulse::durationChangedEmitted()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::durationChanged);
    p.setDuration(500);
    QCOMPARE(spy.count(), 1);
}

void TestPulse::runningChangedEmitted()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::runningChanged);
    p.setRunning(false);
    QCOMPARE(spy.count(), 1);
    p.setRunning(true);
    QCOMPARE(spy.count(), 2);
}


void TestPulse::fromNotEmittedForSameValue()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::fromChanged);
    p.setFrom(p.from());
    QCOMPARE(spy.count(), 0);
}

void TestPulse::toNotEmittedForSameValue()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::toChanged);
    p.setTo(p.to());
    QCOMPARE(spy.count(), 0);
}

void TestPulse::durationNotEmittedForSameValue()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::durationChanged);
    p.setDuration(p.duration());
    QCOMPARE(spy.count(), 0);
}

void TestPulse::runningNotEmittedForSameValue()
{
    Pulse p;
    QSignalSpy spy(&p, &Pulse::runningChanged);
    p.setRunning(p.running());
    QCOMPARE(spy.count(), 0);
}


void TestPulse::setRunningFalseStopsAnimation()
{
    Pulse p;
    p.setRunning(false);
    QVERIFY(!p.running());
}

void TestPulse::setRunningTrueStartsAnimation()
{
    Pulse p;
    p.setRunning(false);
    p.setRunning(true);
    QVERIFY(p.running());
}


void TestPulse::setTargetKeepsRunningFlag()
{
    TargetObject obj;
    QQmlEngine engine;
    QQmlProperty prop(&obj, QStringLiteral("value"), &engine);
    QVERIFY(prop.isValid());

    Pulse p;
    p.setTarget(prop);
    QVERIFY(p.running());
}

void TestPulse::setTargetWritesPropertyEventually()
{
    TargetObject obj;
    QQmlEngine engine;
    QQmlProperty prop(&obj, QStringLiteral("value"), &engine);
    QVERIFY(prop.isValid());

    Pulse p;
    p.setFrom(0.0);
    p.setTo(1.0);
    p.setDuration(200);
    p.setTarget(prop);

    QTest::qWait(60);

    const qreal v = obj.value();
    QVERIFY2(v >= 0.0 && v <= 1.0,
             qPrintable(QString("value %1 out of [0,1]").arg(v)));
}


QTEST_MAIN(TestPulse)
#include "tst_pulse.moc"