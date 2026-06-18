#include "form.h"
#include <QDebug>

Form::Form(QObject *parent)
    : QObject(parent)
{
}

FormAttached *Form::qmlAttachedProperties(QObject *object)
{
    qDebug() << "[Form] Creating FormAttached for:" << object;
    return new FormAttached(object);
}