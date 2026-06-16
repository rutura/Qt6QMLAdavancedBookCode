#ifndef FORM_H
#define FORM_H

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QtQml/qqml.h>
#include "formattached.h"

class Form : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit Form(QObject *parent = nullptr);

    static FormAttached *qmlAttachedProperties(QObject *object);
};
QML_DECLARE_TYPEINFO(Form, QML_HAS_ATTACHED_PROPERTIES)

#endif // FORM_H