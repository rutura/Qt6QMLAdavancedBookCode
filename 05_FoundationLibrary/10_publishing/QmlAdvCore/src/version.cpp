#include "version.h"
#include "version_string.h"

Version::Version(QObject *parent)
    : QObject(parent)
{
}

QString Version::string() const
{
    return QStringLiteral(QMLADVCORELIB_VERSION_STRING);
}