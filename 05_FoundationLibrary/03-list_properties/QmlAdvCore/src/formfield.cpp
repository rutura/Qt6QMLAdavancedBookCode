#include "formfield.h"

FormField::FormField(QObject *parent)
    : QObject(parent)
{
}

QString FormField::label() const
{
    return m_label;
}

void FormField::setLabel(const QString &label)
{
    if (m_label == label)
        return;
    m_label = label;
    emit labelChanged();
}

QString FormField::placeholder() const
{
    return m_placeholder;
}

void FormField::setPlaceholder(const QString &placeholder)
{
    if (m_placeholder == placeholder)
        return;
    m_placeholder = placeholder;
    emit placeholderChanged();
}

bool FormField::required() const
{
    return m_required;
}

void FormField::setRequired(bool required)
{
    if (m_required == required)
        return;
    m_required = required;
    emit requiredChanged();
}