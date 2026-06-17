#include <QTest>
#include <QSignalSpy>
#include "fieldvalidation.h"
#include "formfield.h"

class TestFieldValidation : public QObject
{
    Q_OBJECT
private slots:
    void defaultRequired();
    void defaultMinLength();
    void defaultMaxLength();
    void setRequiredRoundtrip();
    void setMinLengthRoundtrip();
    void setMaxLengthRoundtrip();
    void requiredChangedEmitted();
    void minLengthChangedEmitted();
    void maxLengthChangedEmitted();
    void notEmittedForSameValue();
    void formFieldValidationIsNotNull();
    void formFieldValidationIsOwnedByField();
};


void TestFieldValidation::defaultRequired()
{
    FieldValidation v;
    QVERIFY(!v.required());
}

void TestFieldValidation::defaultMinLength()
{
    FieldValidation v;
    QCOMPARE(v.minLength(), 0);
}

void TestFieldValidation::defaultMaxLength()
{
    FieldValidation v;
    QCOMPARE(v.maxLength(), 0);
}

void TestFieldValidation::setRequiredRoundtrip()
{
    FieldValidation v;
    v.setRequired(true);
    QVERIFY(v.required());
    v.setRequired(false);
    QVERIFY(!v.required());
}

void TestFieldValidation::setMinLengthRoundtrip()
{
    FieldValidation v;
    v.setMinLength(5);
    QCOMPARE(v.minLength(), 5);
}

void TestFieldValidation::setMaxLengthRoundtrip()
{
    FieldValidation v;
    v.setMaxLength(100);
    QCOMPARE(v.maxLength(), 100);
}


void TestFieldValidation::requiredChangedEmitted()
{
    FieldValidation v;
    QSignalSpy spy(&v, &FieldValidation::requiredChanged);
    v.setRequired(true);
    QCOMPARE(spy.count(), 1);
}

void TestFieldValidation::minLengthChangedEmitted()
{
    FieldValidation v;
    QSignalSpy spy(&v, &FieldValidation::minLengthChanged);
    v.setMinLength(3);
    QCOMPARE(spy.count(), 1);
}

void TestFieldValidation::maxLengthChangedEmitted()
{
    FieldValidation v;
    QSignalSpy spy(&v, &FieldValidation::maxLengthChanged);
    v.setMaxLength(50);
    QCOMPARE(spy.count(), 1);
}

void TestFieldValidation::notEmittedForSameValue()
{
    FieldValidation v;
    v.setRequired(true);
    QSignalSpy spy(&v, &FieldValidation::requiredChanged);
    v.setRequired(true);
    QCOMPARE(spy.count(), 0);
}

void TestFieldValidation::formFieldValidationIsNotNull()
{
    FormField f;
    QVERIFY(f.validation() != nullptr);
}

void TestFieldValidation::formFieldValidationIsOwnedByField()
{
    FormField f;
    QCOMPARE(f.validation()->parent(), &f);
}

QTEST_MAIN(TestFieldValidation)
#include "tst_fieldvalidation.moc"
