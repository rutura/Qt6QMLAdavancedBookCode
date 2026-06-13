#include <QTest>
#include <QRegularExpression>
#include "version.h"

class TestVersion : public QObject
{
    Q_OBJECT
private slots:
    void stringReturnsExpectedVersion();
    void stringIsNotEmpty();
    void stringIsSemVer();
};

void TestVersion::stringReturnsExpectedVersion()
{
    Version v;
    QCOMPARE(v.string(), QStringLiteral("0.1.0"));
}

void TestVersion::stringIsNotEmpty()
{
    Version v;
    QVERIFY(!v.string().isEmpty());
}

void TestVersion::stringIsSemVer()
{
    Version v;
    const QRegularExpression semver(R"(\d+\.\d+\.\d+)");
    QVERIFY(semver.match(v.string()).hasMatch());
}

QTEST_MAIN(TestVersion)
#include "tst_version.moc"