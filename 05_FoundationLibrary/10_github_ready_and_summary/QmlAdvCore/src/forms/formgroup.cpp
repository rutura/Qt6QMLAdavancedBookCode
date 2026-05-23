#include "formgroup.h"

FormGroup::FormGroup(QObject *parent)
    : QObject(parent)
{
}

QQmlListProperty<FormField> FormGroup::fields()
{
    return QQmlListProperty<FormField>(this, nullptr,
                                      &FormGroup::appendField,
                                      &FormGroup::fieldCount,
                                      &FormGroup::fieldAt,
                                      &FormGroup::clearFields);
}

QList<QObject *> FormGroup::fieldList() const
{
    QList<QObject *> result;
    result.reserve(m_fields.size());
    for (FormField *f : m_fields)
        result.append(f);
    return result;
}

int FormGroup::fieldCount() const
{
    return m_fields.size();
}

FormField *FormGroup::fieldAt(int index) const
{
    return m_fields.value(index);
}

// --- Static callbacks required by QQmlListProperty ---

void FormGroup::appendField(QQmlListProperty<FormField> *list, FormField *field)
{
    auto *self = qobject_cast<FormGroup *>(list->object);
    field->setParent(self);
    self->m_fields.append(field);
    emit self->fieldsChanged();
}

qsizetype FormGroup::fieldCount(QQmlListProperty<FormField> *list)
{
    return qobject_cast<FormGroup *>(list->object)->m_fields.size();
}

FormField *FormGroup::fieldAt(QQmlListProperty<FormField> *list, qsizetype index)
{
    return qobject_cast<FormGroup *>(list->object)->m_fields.value(index);
}

void FormGroup::clearFields(QQmlListProperty<FormField> *list)
{
    auto *self = qobject_cast<FormGroup *>(list->object);
    self->m_fields.clear();
    emit self->fieldsChanged();
}
