#include "formfield.h"

FormField::FormField(QObject *parent)
    : QObject(parent)
    , m_validation(new FormFieldValidation(this))
    , m_style(new FormFieldStyle(this))
{
}

void FormField::setLabel(const QString &v)
{
    if (m_label == v) return;
    m_label = v;
    emit labelChanged();
}

void FormField::setPlaceholder(const QString &v)
{
    if (m_placeholder == v) return;
    m_placeholder = v;
    emit placeholderChanged();
}

void FormField::setValue(const QString &v)
{
    if (m_value == v) return;
    m_value = v;
    emit valueChanged();
}

void FormField::setFieldType(FieldType v)
{
    if (m_fieldType == v) return;
    m_fieldType = v;
    emit fieldTypeChanged();
}
