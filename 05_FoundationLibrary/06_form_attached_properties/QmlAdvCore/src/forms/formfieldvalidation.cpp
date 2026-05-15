#include "formfieldvalidation.h"

FormFieldValidation::FormFieldValidation(QObject *parent)
    : QObject(parent)
{
}

void FormFieldValidation::setRequired(bool v)
{
    if (m_required == v) return;
    m_required = v;
    emit requiredChanged();
}

void FormFieldValidation::setMinLength(int v)
{
    if (m_minLength == v) return;
    m_minLength = v;
    emit minLengthChanged();
}

void FormFieldValidation::setMaxLength(int v)
{
    if (m_maxLength == v) return;
    m_maxLength = v;
    emit maxLengthChanged();
}

void FormFieldValidation::setPattern(const QString &v)
{
    if (m_pattern == v) return;
    m_pattern = v;
    emit patternChanged();
}

void FormFieldValidation::setErrorText(const QString &v)
{
    if (m_errorText == v) return;
    m_errorText = v;
    emit errorTextChanged();
}

bool FormFieldValidation::validate(const QString &value)
{
    if (m_required && value.trimmed().isEmpty()) {
        setErrorText(QStringLiteral("This field is required"));
        return false;
    }

    if (m_minLength > 0 && value.length() < m_minLength) {
        setErrorText(QStringLiteral("Minimum %1 characters required").arg(m_minLength));
        return false;
    }

    if (m_maxLength > 0 && value.length() > m_maxLength) {
        setErrorText(QStringLiteral("Maximum %1 characters allowed").arg(m_maxLength));
        return false;
    }

    if (!m_pattern.isEmpty()) {
        QRegularExpression re(m_pattern);
        if (!re.match(value).hasMatch()) {
            setErrorText(QStringLiteral("Invalid format"));
            return false;
        }
    }

    setErrorText(QString());
    return true;
}
