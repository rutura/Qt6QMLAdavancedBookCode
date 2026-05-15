#ifndef VERSION_H
#define VERSION_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class Version : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString string READ string CONSTANT)

public:
    explicit Version(QObject *parent = nullptr);
    QString string() const;
};

#endif // VERSION_H
