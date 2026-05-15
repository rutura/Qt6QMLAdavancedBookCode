#include "forms/form.h"

Form::Form(QObject *parent)
    : QObject(parent)
{
}

FormAttached *Form::qmlAttachedProperties(QObject *object)
{
    return new FormAttached(object);
}
