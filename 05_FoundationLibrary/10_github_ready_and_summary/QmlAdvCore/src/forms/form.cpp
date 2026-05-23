#include "forms/form.h"
#include "forms/formattached.h"

#include <QtQml/qqml.h>
#include <QtQml/qqmlengine.h>

Form::Form(QObject *parent)
    : QObject(parent)
{
}

QVariantMap Form::values() const
{
    QVariantMap map;
    for (FormAttached *a : std::as_const(m_fields)) {
        if (!a) continue;
        const QString key = a->field();
        if (key.isEmpty()) continue;
        map.insert(key, a->value());
    }
    return map;
}

int Form::fieldCount() const
{
    return m_fields.size();
}

void Form::submit()
{
    emit submitted(values());
}

FormAttached *Form::qmlAttachedProperties(QObject *object)
{
    return new FormAttached(object);
}

void Form::registerField(FormAttached *attached)
{
    if (!attached || m_fields.contains(attached))
        return;

    m_fields.insert(attached);

    connect(attached, &FormAttached::valueChanged,
            this,     &Form::valuesChanged, Qt::UniqueConnection);
    connect(attached, &QObject::destroyed, this, [this, attached]() {
        m_fields.remove(attached);
        emit valuesChanged();
    });

    emit valuesChanged();
}

void Form::unregisterField(FormAttached *attached)
{
    if (m_fields.remove(attached))
        emit valuesChanged();
}

void Form::notifyValuesChanged()
{
    emit valuesChanged();
}

Form *Form::instance(QObject *contextObject)
{
    QQmlEngine *engine = qmlEngine(contextObject);
    if (!engine)
        return nullptr;
    const int typeId = qmlTypeId("QmlAdvCore", 1, 0, "Form");
    if (typeId < 0)
        return nullptr;
    return engine->singletonInstance<Form *>(typeId);
}
