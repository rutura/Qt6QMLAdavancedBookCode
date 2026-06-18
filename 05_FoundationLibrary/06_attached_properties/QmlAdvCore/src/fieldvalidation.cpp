#include "fieldvalidation.h"

FieldValidation::FieldValidation(QObject *parent)
    : QObject(parent)
{
}

bool FieldValidation::required() const
{
    return m_required;
}

void FieldValidation::setRequired(bool required)
{
    if (m_required == required)
        return;
    m_required = required;
    emit requiredChanged();
}

int FieldValidation::minLength() const
{
    return m_minLength;
}

void FieldValidation::setMinLength(int minLength)
{
    if (m_minLength == minLength)
        return;
    m_minLength = minLength;
    emit minLengthChanged();
}

int FieldValidation::maxLength() const
{
    return m_maxLength;
}

void FieldValidation::setMaxLength(int maxLength)
{
    if (m_maxLength == maxLength)
        return;
    m_maxLength = maxLength;
    emit maxLengthChanged();
}