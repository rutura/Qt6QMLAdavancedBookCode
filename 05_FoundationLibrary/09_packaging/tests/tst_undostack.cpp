#include <QTest>
#include <QSignalSpy>
#include "undostack.h"

class TestUndoStack : public QObject
{
    Q_OBJECT
private slots:
    void defaultCanUndo();
    void defaultCanRedo();
    void defaultUndoText();
    void defaultRedoText();
    void defaultCount();
    void pushIncreasesCount();
    void pushMakesCanUndoTrue();
    void pushSetsUndoText();
    void pushClearsRedoHistory();
    void pushEmitsCountChanged();
    void pushEmitsCanUndoChanged();
    void pushEmitsUndoTextChanged();
    void undoDecrementsIndex();
    void undoEmitsUndoneSignal();
    void undoMakesCanRedoTrue();
    void undoWhenEmptyIsNoop();
    void undoTextUpdatesAfterUndo();
    void redoIncrementsIndex();
    void redoEmitsRedonedSignal();
    void redoWhenNothingToRedoIsNoop();
    void redoAfterUndoRestoresCanUndo();
    void clearResetsAll();
    void clearWhenEmptyIsNoop();
    void clearEmitsCountChanged();
    void undoRedoSequence();
    void pushAfterUndoDiscardsRedo();
    void payloadRoundtrip();
};


void TestUndoStack::defaultCanUndo()  { UndoStack s; QVERIFY(!s.canUndo()); }
void TestUndoStack::defaultCanRedo()  { UndoStack s; QVERIFY(!s.canRedo()); }
void TestUndoStack::defaultUndoText() { UndoStack s; QVERIFY(s.undoText().isEmpty()); }
void TestUndoStack::defaultRedoText() { UndoStack s; QVERIFY(s.redoText().isEmpty()); }
void TestUndoStack::defaultCount()    { UndoStack s; QCOMPARE(s.count(), 0); }


void TestUndoStack::pushIncreasesCount()
{
    UndoStack s;
    s.push("a");
    QCOMPARE(s.count(), 1);
    s.push("b");
    QCOMPARE(s.count(), 2);
}

void TestUndoStack::pushMakesCanUndoTrue()
{
    UndoStack s;
    s.push("x");
    QVERIFY(s.canUndo());
}

void TestUndoStack::pushSetsUndoText()
{
    UndoStack s;
    s.push("Delete item");
    QCOMPARE(s.undoText(), QStringLiteral("Delete item"));
}

void TestUndoStack::pushClearsRedoHistory()
{
    UndoStack s;
    s.push("a");
    s.push("b");
    s.undo();
    QVERIFY(s.canRedo());
    s.push("c");
    QVERIFY(!s.canRedo());
    QCOMPARE(s.count(), 2);
}

void TestUndoStack::pushEmitsCountChanged()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::countChanged);
    s.push("x");
    QCOMPARE(spy.count(), 1);
}

void TestUndoStack::pushEmitsCanUndoChanged()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::canUndoChanged);
    s.push("x");
    QCOMPARE(spy.count(), 1);
    s.push("y");
    QCOMPARE(spy.count(), 1);
}

void TestUndoStack::pushEmitsUndoTextChanged()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::undoTextChanged);
    s.push("first");
    QCOMPARE(spy.count(), 1);
    s.push("second");
    QCOMPARE(spy.count(), 2);
}


void TestUndoStack::undoDecrementsIndex()
{
    UndoStack s;
    s.push("a");
    s.push("b");
    s.undo();
    QCOMPARE(s.undoText(), QStringLiteral("a"));
}

void TestUndoStack::undoEmitsUndoneSignal()
{
    UndoStack s;
    s.push("Delete row");
    QSignalSpy spy(&s, &UndoStack::undone);
    s.undo();
    QCOMPARE(spy.count(), 1);
    const QList<QVariant> args = spy.takeFirst();
    QCOMPARE(args.at(0).toString(), QStringLiteral("Delete row"));
}

void TestUndoStack::undoMakesCanRedoTrue()
{
    UndoStack s;
    s.push("x");
    s.undo();
    QVERIFY(s.canRedo());
}

void TestUndoStack::undoWhenEmptyIsNoop()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::undone);
    s.undo();
    QCOMPARE(spy.count(), 0);
    QVERIFY(!s.canUndo());
}

void TestUndoStack::undoTextUpdatesAfterUndo()
{
    UndoStack s;
    s.push("a");
    s.push("b");
    s.undo();
    QCOMPARE(s.undoText(), QStringLiteral("a"));
    s.undo();
    QVERIFY(s.undoText().isEmpty());
    QVERIFY(!s.canUndo());
}


void TestUndoStack::redoIncrementsIndex()
{
    UndoStack s;
    s.push("a");
    s.undo();
    s.redo();
    QVERIFY(s.canUndo());
    QVERIFY(!s.canRedo());
}

void TestUndoStack::redoEmitsRedonedSignal()
{
    UndoStack s;
    s.push("Add row");
    s.undo();
    QSignalSpy spy(&s, &UndoStack::redone);
    s.redo();
    QCOMPARE(spy.count(), 1);
    const QList<QVariant> args = spy.takeFirst();
    QCOMPARE(args.at(0).toString(), QStringLiteral("Add row"));
}

void TestUndoStack::redoWhenNothingToRedoIsNoop()
{
    UndoStack s;
    s.push("x");
    QSignalSpy spy(&s, &UndoStack::redone);
    s.redo();
    QCOMPARE(spy.count(), 0);
}

void TestUndoStack::redoAfterUndoRestoresCanUndo()
{
    UndoStack s;
    s.push("x");
    s.undo();
    QVERIFY(!s.canUndo());
    s.redo();
    QVERIFY(s.canUndo());
}


void TestUndoStack::clearResetsAll()
{
    UndoStack s;
    s.push("a");
    s.push("b");
    s.clear();
    QCOMPARE(s.count(), 0);
    QVERIFY(!s.canUndo());
    QVERIFY(!s.canRedo());
    QVERIFY(s.undoText().isEmpty());
    QVERIFY(s.redoText().isEmpty());
}

void TestUndoStack::clearWhenEmptyIsNoop()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::countChanged);
    s.clear();
    QCOMPARE(spy.count(), 0);
}

void TestUndoStack::clearEmitsCountChanged()
{
    UndoStack s;
    s.push("x");
    QSignalSpy spy(&s, &UndoStack::countChanged);
    s.clear();
    QCOMPARE(spy.count(), 1);
}

void TestUndoStack::undoRedoSequence()
{
    UndoStack s;
    s.push("step1");
    s.push("step2");
    s.push("step3");

    QCOMPARE(s.undoText(), QStringLiteral("step3"));
    s.undo();
    QCOMPARE(s.undoText(), QStringLiteral("step2"));
    QCOMPARE(s.redoText(), QStringLiteral("step3"));
    s.undo();
    QCOMPARE(s.undoText(), QStringLiteral("step1"));
    s.redo();
    QCOMPARE(s.undoText(), QStringLiteral("step2"));
    QCOMPARE(s.redoText(), QStringLiteral("step3"));
}

void TestUndoStack::pushAfterUndoDiscardsRedo()
{
    UndoStack s;
    s.push("a");
    s.push("b");
    s.undo();
    QCOMPARE(s.redoText(), QStringLiteral("b"));
    s.push("c");
    QVERIFY(!s.canRedo());
    QCOMPARE(s.undoText(), QStringLiteral("c"));
    QCOMPARE(s.count(), 2);
}

void TestUndoStack::payloadRoundtrip()
{
    UndoStack s;
    QSignalSpy spy(&s, &UndoStack::undone);
    s.push("Delete", QVariant(42));
    s.undo();
    QCOMPARE(spy.count(), 1);
    const QList<QVariant> args = spy.takeFirst();
    QCOMPARE(args.at(1).toInt(), 42);
}


QTEST_MAIN(TestUndoStack)
#include "tst_undostack.moc"