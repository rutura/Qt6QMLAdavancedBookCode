#include "version.h"

Version::Version(QObject *parent)
    : QObject(parent)
{
}

QString Version::string() const
{
    return QStringLiteral("0.8.0");
}
