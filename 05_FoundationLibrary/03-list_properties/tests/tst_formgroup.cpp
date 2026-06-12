#include <QTest>
#include <QSignalSpy>
#include "formgroup.h"
#include "formfield.h"

class TestFormGroup : public QObject
{
    Q_OBJECT
private slots:
    void emptyGroupHasZeroFields();
    void appendedFieldIsCountedAndRetrievable();
    void appendMultipleFields();
    void fieldAtReturnsCorrectField();
    void fieldAtOutOfBoundsReturnsNull();
    void clearRemovesAllFields();
    void titleRoundtrip();
    void titleChangedSignalEmitted();
    void appendSetsFieldParent();
    void formFieldPropertiesRoundtrip();
    void requiredDefaultIsFalse();
};


void TestFormGroup::emptyGroupHasZeroFields()
{
    FormGroup g;
    QCOMPARE(g.fieldCount(), 0);
}

void TestFormGroup::appendedFieldIsCountedAndRetrievable()
{
    FormGroup g;
    auto *f = new FormField(&g);
    f->setLabel("Username");
    auto list = g.fields();
    QQmlListProperty<FormField>::AppendFunction append = list.append;
    append(&list, f);
    QCOMPARE(g.fieldCount(), 1);
}

void TestFormGroup::appendMultipleFields()
{
    FormGroup g;
    auto list = g.fields();
    for (int i = 0; i < 5; ++i) {
        auto *f = new FormField(&g);
        f->setLabel(QString("Field %1").arg(i));
        list.append(&list, f);
    }
    QCOMPARE(g.fieldCount(), 5);
}

void TestFormGroup::fieldAtReturnsCorrectField()
{
    FormGroup g;
    auto list = g.fields();
    auto *f0 = new FormField(&g);
    f0->setLabel("First");
    auto *f1 = new FormField(&g);
    f1->setLabel("Second");
    list.append(&list, f0);
    list.append(&list, f1);
    QCOMPARE(g.fieldAt(0)->label(), QStringLiteral("First"));
    QCOMPARE(g.fieldAt(1)->label(), QStringLiteral("Second"));
}

void TestFormGroup::fieldAtOutOfBoundsReturnsNull()
{
    FormGroup g;
    QVERIFY(g.fieldAt(0) == nullptr);
    QVERIFY(g.fieldAt(-1) == nullptr);
}

void TestFormGroup::clearRemovesAllFields()
{
    FormGroup g;
    auto list = g.fields();
    for (int i = 0; i < 3; ++i) {
        auto *f = new FormField;
        list.append(&list, f);
    }
    QCOMPARE(g.fieldCount(), 3);
    list.clear(&list);
    QCOMPARE(g.fieldCount(), 0);
}

void TestFormGroup::titleRoundtrip()
{
    FormGroup g;
    g.setTitle("Login");
    QCOMPARE(g.title(), QStringLiteral("Login"));
}

void TestFormGroup::titleChangedSignalEmitted()
{
    FormGroup g;
    QSignalSpy spy(&g, &FormGroup::titleChanged);
    g.setTitle("Registration");
    QCOMPARE(spy.count(), 1);
    g.setTitle("Registration");
    QCOMPARE(spy.count(), 1);
}

void TestFormGroup::appendSetsFieldParent()
{
    FormGroup g;
    auto list = g.fields();
    auto *f = new FormField;
    list.append(&list, f);
    QCOMPARE(f->parent(), &g);
}

void TestFormGroup::formFieldPropertiesRoundtrip()
{
    FormField f;
    f.setLabel("Email");
    f.setPlaceholder("user@example.com");
    f.setRequired(true);
    QCOMPARE(f.label(),       QStringLiteral("Email"));
    QCOMPARE(f.placeholder(), QStringLiteral("user@example.com"));
    QVERIFY(f.required());
}

void TestFormGroup::requiredDefaultIsFalse()
{
    FormField f;
    QVERIFY(!f.required());
}

QTEST_MAIN(TestFormGroup)
#include "tst_formgroup.moc"