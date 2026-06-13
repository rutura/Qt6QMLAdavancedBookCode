#include <QTest>
#include <QColor>
#include "theme.h"
#include "colorpalette.h"
#include "spacinggroup.h"

class TestTheme : public QObject
{
    Q_OBJECT
private slots:
    void colorsIsNotNull();
    void spacingIsNotNull();
    void primaryColorDefault();
    void spacingSmallDefault();
    void setPrimaryColor();
};


void TestTheme::colorsIsNotNull()
{
    Theme t;
    QVERIFY(t.colors() != nullptr);
}

void TestTheme::spacingIsNotNull()
{
    Theme t;
    QVERIFY(t.spacing() != nullptr);
}

void TestTheme::primaryColorDefault()
{
    Theme t;
    QCOMPARE(t.colors()->primary(), QColor("#6750A4"));
}

void TestTheme::spacingSmallDefault()
{
    Theme t;
    QCOMPARE(t.spacing()->small(), 8);
}

void TestTheme::setPrimaryColor()
{
    ColorPalette palette;
    palette.setPrimary(QColor("red"));
    QCOMPARE(palette.primary(), QColor("red"));
}

QTEST_MAIN(TestTheme)
#include "tst_theme.moc"