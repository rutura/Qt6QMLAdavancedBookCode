#include "formattached.h"

FormAttached::FormAttached(QObject *parent)
    : QObject(parent)
{
}

void FormAttached::setField(const QString &v)
{
    if (m_field == v) return;
    m_field = v;
    emit fieldChanged();
}

void FormAttached::setRequired(bool v)
{
    if (m_required == v) return;
    m_required = v;
    emit requiredChanged();
}

void FormAttached::setPattern(const QString &v)
{
    if (m_pattern == v) return;
    m_pattern = v;
    emit patternChanged();
}
