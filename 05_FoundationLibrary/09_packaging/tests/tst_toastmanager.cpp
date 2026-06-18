#include <QTest>
#include <QSignalSpy>
#include "toastmanager.h"

class TestToastManager : public QObject
{
    Q_OBJECT
private slots:
    void defaultMessage();
    void defaultVisible();
    void defaultDuration();
    void showSetsVisible();
    void showSetsMessage();
    void showEmitsVisibleChanged();
    void showEmitsMessageChanged();
    void showWithCustomDuration();
    void dismissClearsVisible();
    void dismissEmitsVisibleChanged();
    void dismissWhenAlreadyHiddenIsNoop();
    void setDurationRoundtrip();
    void setDurationEmitsSignal();
    void setDurationSameValueNoSignal();
    void autoDismissAfterDuration();
    void repeatedShowRestartsTimer();
};


void TestToastManager::defaultMessage()
{
    ToastManager tm;
    QVERIFY(tm.message().isEmpty());
}

void TestToastManager::defaultVisible()
{
    ToastManager tm;
    QVERIFY(!tm.visible());
}

void TestToastManager::defaultDuration()
{
    ToastManager tm;
    QCOMPARE(tm.duration(), 3000);
}


void TestToastManager::showSetsVisible()
{
    ToastManager tm;
    tm.show("hello");
    QVERIFY(tm.visible());
}

void TestToastManager::showSetsMessage()
{
    ToastManager tm;
    tm.show("test message");
    QCOMPARE(tm.message(), QStringLiteral("test message"));
}

void TestToastManager::showEmitsVisibleChanged()
{
    ToastManager tm;
    QSignalSpy spy(&tm, &ToastManager::visibleChanged);
    tm.show("hi");
    QCOMPARE(spy.count(), 1);
}

void TestToastManager::showEmitsMessageChanged()
{
    ToastManager tm;
    QSignalSpy spy(&tm, &ToastManager::messageChanged);
    tm.show("msg");
    QVERIFY(spy.count() >= 1);
}

void TestToastManager::showWithCustomDuration()
{
    ToastManager tm;
    tm.show("quick", 100);
    QVERIFY(tm.visible());
    QCOMPARE(tm.duration(), 3000);
    QTest::qWait(250);
    QVERIFY(!tm.visible());
}


void TestToastManager::dismissClearsVisible()
{
    ToastManager tm;
    tm.show("x");
    QVERIFY(tm.visible());
    tm.dismiss();
    QVERIFY(!tm.visible());
}

void TestToastManager::dismissEmitsVisibleChanged()
{
    ToastManager tm;
    tm.show("x");
    QSignalSpy spy(&tm, &ToastManager::visibleChanged);
    tm.dismiss();
    QCOMPARE(spy.count(), 1);
}

void TestToastManager::dismissWhenAlreadyHiddenIsNoop()
{
    ToastManager tm;
    QSignalSpy spy(&tm, &ToastManager::visibleChanged);
    tm.dismiss();
    QCOMPARE(spy.count(), 0);
    QVERIFY(!tm.visible());
}


void TestToastManager::setDurationRoundtrip()
{
    ToastManager tm;
    tm.setDuration(2000);
    QCOMPARE(tm.duration(), 2000);
    tm.setDuration(500);
    QCOMPARE(tm.duration(), 500);
}

void TestToastManager::setDurationEmitsSignal()
{
    ToastManager tm;
    QSignalSpy spy(&tm, &ToastManager::durationChanged);
    tm.setDuration(1500);
    QCOMPARE(spy.count(), 1);
}

void TestToastManager::setDurationSameValueNoSignal()
{
    ToastManager tm;
    QSignalSpy spy(&tm, &ToastManager::durationChanged);
    tm.setDuration(tm.duration());
    QCOMPARE(spy.count(), 0);
}

void TestToastManager::autoDismissAfterDuration()
{
    ToastManager tm;
    tm.setDuration(150);
    tm.show("auto");
    QVERIFY(tm.visible());
    QTest::qWait(350);
    QVERIFY(!tm.visible());
}

void TestToastManager::repeatedShowRestartsTimer()
{
    ToastManager tm;
    tm.setDuration(200);
    tm.show("first");
    QTest::qWait(100);
    tm.show("second");
    QTest::qWait(100);
    QVERIFY(tm.visible());
    QTest::qWait(200);
    QVERIFY(!tm.visible());
}

QTEST_MAIN(TestToastManager)
#include "tst_toastmanager.moc"