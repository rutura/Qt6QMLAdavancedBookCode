#include "formattached.h"
#include <QDebug>

FormAttached::FormAttached(QObject *parent)
    : QObject(parent)
{
    qDebug() << "[FormAttached] Attached object created, parent:" << parent;
}

QString FormAttached::field() const { return m_field; }

void FormAttached::setField(const QString &field)
{
    if (m_field == field) return;
    m_field = field;
    emit fieldChanged();
}

QString FormAttached::label() const { return m_label; }

void FormAttached::setLabel(const QString &label)
{
    if (m_label == label) return;
    m_label = label;
    emit labelChanged();
}

bool FormAttached::required() const { return m_required; }

void FormAttached::setRequired(bool required)
{
    if (m_required == required) return;
    m_required = required;
    emit requiredChanged();
}

QString FormAttached::hint() const { return m_hint; }

void FormAttached::setHint(const QString &hint)
{
    if (m_hint == hint) return;
    m_hint = hint;
    emit hintChanged();
}

QString FormAttached::error() const
{
    return m_error;
}

void FormAttached::validate(const QString &value)
{
    qDebug() << "[FormAttached] validate() called on field:" << m_field
             << "  value:" << value
             << "  required:" << m_required;

    QString newError;
    if (m_required && value.trimmed().isEmpty())
        newError = m_label + " is required";

    if (m_error == newError)
        return;
    m_error = newError;
    qDebug() << "[FormAttached] errorChanged emitted, error:" << m_error;
    emit errorChanged();
}