#include <QTest>
#include <QSignalSpy>
#include "formattached.h"
#include "form.h"

class TestFormAttached : public QObject
{
    Q_OBJECT
private slots:
    // Default values
    void defaultField();
    void defaultLabel();
    void defaultRequired();
    void defaultHint();
    void defaultError();

    // Round-trips
    void setFieldRoundtrip();
    void setLabelRoundtrip();
    void setRequiredRoundtrip();
    void setHintRoundtrip();

    // Signals emitted on change
    void fieldChangedEmitted();
    void labelChangedEmitted();
    void requiredChangedEmitted();
    void hintChangedEmitted();

    // Signals NOT emitted for same value
    void notEmittedForSameStringValue();
    void notEmittedForSameBoolValue();

    // Attached-property factory
    void qmlAttachedPropertiesReturnsNonNull();
    void attachedObjectOwnedByAttachee();
    void differentObjectsGetDifferentInstances();

    // validate() behaviour
    void validateClearsErrorForOptionalEmptyField();
    void validateSetsErrorForRequiredEmptyField();
    void validateClearsErrorWhenFieldFilled();
    void errorChangedEmittedOnValidate();
    void errorNotEmittedWhenErrorUnchanged();
};


void TestFormAttached::defaultField()
{
    FormAttached a;
    QVERIFY(a.field().isEmpty());
}

void TestFormAttached::defaultLabel()
{
    FormAttached a;
    QVERIFY(a.label().isEmpty());
}

void TestFormAttached::defaultRequired()
{
    FormAttached a;
    QVERIFY(!a.required());
}

void TestFormAttached::defaultHint()
{
    FormAttached a;
    QVERIFY(a.hint().isEmpty());
}

void TestFormAttached::defaultError()
{
    FormAttached a;
    QVERIFY(a.error().isEmpty());
}


void TestFormAttached::setFieldRoundtrip()
{
    FormAttached a;
    a.setField(QStringLiteral("email"));
    QCOMPARE(a.field(), QStringLiteral("email"));
    a.setField(QStringLiteral("password"));
    QCOMPARE(a.field(), QStringLiteral("password"));
}

void TestFormAttached::setLabelRoundtrip()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Email Address"));
    QCOMPARE(a.label(), QStringLiteral("Email Address"));
}

void TestFormAttached::setRequiredRoundtrip()
{
    FormAttached a;
    a.setRequired(true);
    QVERIFY(a.required());
    a.setRequired(false);
    QVERIFY(!a.required());
}

void TestFormAttached::setHintRoundtrip()
{
    FormAttached a;
    a.setHint(QStringLiteral("at least 8 characters"));
    QCOMPARE(a.hint(), QStringLiteral("at least 8 characters"));
}


void TestFormAttached::fieldChangedEmitted()
{
    FormAttached a;
    QSignalSpy spy(&a, &FormAttached::fieldChanged);
    a.setField(QStringLiteral("username"));
    QCOMPARE(spy.count(), 1);
}

void TestFormAttached::labelChangedEmitted()
{
    FormAttached a;
    QSignalSpy spy(&a, &FormAttached::labelChanged);
    a.setLabel(QStringLiteral("Username"));
    QCOMPARE(spy.count(), 1);
}

void TestFormAttached::requiredChangedEmitted()
{
    FormAttached a;
    QSignalSpy spy(&a, &FormAttached::requiredChanged);
    a.setRequired(true);
    QCOMPARE(spy.count(), 1);
}

void TestFormAttached::hintChangedEmitted()
{
    FormAttached a;
    QSignalSpy spy(&a, &FormAttached::hintChanged);
    a.setHint(QStringLiteral("some hint"));
    QCOMPARE(spy.count(), 1);
}


void TestFormAttached::notEmittedForSameStringValue()
{
    FormAttached a;
    a.setField(QStringLiteral("email"));
    QSignalSpy spy(&a, &FormAttached::fieldChanged);
    a.setField(QStringLiteral("email")); // same — no signal
    QCOMPARE(spy.count(), 0);
}

void TestFormAttached::notEmittedForSameBoolValue()
{
    FormAttached a;
    a.setRequired(true);
    QSignalSpy spy(&a, &FormAttached::requiredChanged);
    a.setRequired(true); // same — no signal
    QCOMPARE(spy.count(), 0);
}


void TestFormAttached::qmlAttachedPropertiesReturnsNonNull()
{
    QObject attachee;
    FormAttached *att = Form::qmlAttachedProperties(&attachee);
    QVERIFY(att != nullptr);
    delete att; // we own it (created outside the QML engine)
}

void TestFormAttached::attachedObjectOwnedByAttachee()
{
    QObject attachee;
    FormAttached *att = Form::qmlAttachedProperties(&attachee);
    QCOMPARE(att->parent(), &attachee);
    // att is deleted when attachee goes out of scope via parent-child ownership
}

void TestFormAttached::differentObjectsGetDifferentInstances()
{
    QObject a, b;
    FormAttached *attA = Form::qmlAttachedProperties(&a);
    FormAttached *attB = Form::qmlAttachedProperties(&b);
    QVERIFY(attA != attB);
    delete attA;
    delete attB;
}

void TestFormAttached::validateClearsErrorForOptionalEmptyField()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Display Name"));
    a.setRequired(false);
    a.validate(QStringLiteral(""));
    QVERIFY(a.error().isEmpty());
}

void TestFormAttached::validateSetsErrorForRequiredEmptyField()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Email"));
    a.setRequired(true);
    a.validate(QStringLiteral(""));
    QCOMPARE(a.error(), QStringLiteral("Email is required"));
}

void TestFormAttached::validateClearsErrorWhenFieldFilled()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Email"));
    a.setRequired(true);
    a.validate(QStringLiteral(""));
    QVERIFY(!a.error().isEmpty());
    a.validate(QStringLiteral("user@example.com"));
    QVERIFY(a.error().isEmpty());
}

void TestFormAttached::errorChangedEmittedOnValidate()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Password"));
    a.setRequired(true);
    QSignalSpy spy(&a, &FormAttached::errorChanged);
    a.validate(QStringLiteral(""));   // triggers error
    QCOMPARE(spy.count(), 1);
    a.validate(QStringLiteral("ok")); // clears error
    QCOMPARE(spy.count(), 2);
}

void TestFormAttached::errorNotEmittedWhenErrorUnchanged()
{
    FormAttached a;
    a.setLabel(QStringLiteral("Email"));
    a.setRequired(true);
    a.validate(QStringLiteral("")); // sets error
    QSignalSpy spy(&a, &FormAttached::errorChanged);
    a.validate(QStringLiteral("")); // same error — no signal
    QCOMPARE(spy.count(), 0);
}

QTEST_MAIN(TestFormAttached)
#include "tst_formattached.moc"