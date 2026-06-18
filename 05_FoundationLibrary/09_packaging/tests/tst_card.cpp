#include <QTest>
#include <QSignalSpy>
#include <QGuiApplication>
#include <QQuickItem>
#include "card.h"

class TestCard : public QObject
{
    Q_OBJECT
private slots:
    void defaultPadding();
    void defaultSpacing();
    void setPaddingRoundtrip();
    void setSpacingRoundtrip();
    void paddingChangedEmitted();
    void spacingChangedEmitted();
    void paddingNotEmittedForSameValue();
    void appendItemIncreasesCount();
    void itemAtReturnsCorrectItem();
    void clearRemovesAllItems();
    void appendSetsParentItem();
    void contentItemsChangedOnAppend();
    void contentItemsChangedOnClear();
};

void TestCard::defaultPadding()
{
    Card card;
    QCOMPARE(card.padding(), 8);
}

void TestCard::defaultSpacing()
{
    Card card;
    QCOMPARE(card.spacing(), 8);
}


void TestCard::setPaddingRoundtrip()
{
    Card card;
    card.setPadding(16);
    QCOMPARE(card.padding(), 16);
}

void TestCard::setSpacingRoundtrip()
{
    Card card;
    card.setSpacing(12);
    QCOMPARE(card.spacing(), 12);
}

void TestCard::paddingChangedEmitted()
{
    Card card;
    QSignalSpy spy(&card, &Card::paddingChanged);
    card.setPadding(24);
    QCOMPARE(spy.count(), 1);
}

void TestCard::spacingChangedEmitted()
{
    Card card;
    QSignalSpy spy(&card, &Card::spacingChanged);
    card.setSpacing(4);
    QCOMPARE(spy.count(), 1);
}

void TestCard::paddingNotEmittedForSameValue()
{
    Card card;
    card.setPadding(20);
    QSignalSpy spy(&card, &Card::paddingChanged);
    card.setPadding(20);
    QCOMPARE(spy.count(), 0);
}

void TestCard::appendItemIncreasesCount()
{
    Card card;
    auto list = card.contentItems();
    auto *item = new QQuickItem(&card);
    list.append(&list, item);
    QCOMPARE(list.count(&list), 1);
}

void TestCard::itemAtReturnsCorrectItem()
{
    Card card;
    auto list = card.contentItems();
    auto *item0 = new QQuickItem(&card);
    auto *item1 = new QQuickItem(&card);
    list.append(&list, item0);
    list.append(&list, item1);
    QCOMPARE(list.at(&list, 0), item0);
    QCOMPARE(list.at(&list, 1), item1);
}

void TestCard::clearRemovesAllItems()
{
    Card card;
    auto list = card.contentItems();
    list.append(&list, new QQuickItem);
    list.append(&list, new QQuickItem);
    QCOMPARE(list.count(&list), 2);
    list.clear(&list);
    QCOMPARE(list.count(&list), 0);
}

void TestCard::appendSetsParentItem()
{
    Card card;
    auto list = card.contentItems();
    auto *item = new QQuickItem(&card);
    list.append(&list, item);
    QCOMPARE(item->parentItem(), &card);
}

void TestCard::contentItemsChangedOnAppend()
{
    Card card;
    QSignalSpy spy(&card, &Card::contentItemsChanged);
    auto list = card.contentItems();
    list.append(&list, new QQuickItem(&card));
    QCOMPARE(spy.count(), 1);
}

void TestCard::contentItemsChangedOnClear()
{
    Card card;
    auto list = card.contentItems();
    list.append(&list, new QQuickItem(&card));
    QSignalSpy spy(&card, &Card::contentItemsChanged);
    list.clear(&list);
    QCOMPARE(spy.count(), 1);
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    TestCard tc;
    return QTest::qExec(&tc, argc, argv);
}

#include "tst_card.moc"