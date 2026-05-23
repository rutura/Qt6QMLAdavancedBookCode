#ifndef FORMFIELDVALIDATION_H
#define FORMFIELDVALIDATION_H

#include <QObject>
#include <QRegularExpression>
#include <QtQml/qqmlregistration.h>

// FormFieldValidation is an object property of FormField.
// In QML this looks like:
//
//     FormField {
//         label: "Username"
//         validation.required: true
//         validation.minLength: 3
//         validation.maxLength: 20
//     }
//
// The nested `validation.xxx` syntax is "grouped properties" — the same
// pattern Qt uses for `font.family`, `anchors.fill`, `border.width`.
// The trick: expose a sub-QObject as a CONSTANT Q_PROPERTY.
// The pointer never changes; the sub-object's own properties do.
class FormFieldValidation : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool    required   READ required   WRITE setRequired   NOTIFY requiredChanged)
    Q_PROPERTY(int     minLength  READ minLength  WRITE setMinLength  NOTIFY minLengthChanged)
    Q_PROPERTY(int     maxLength  READ maxLength  WRITE setMaxLength  NOTIFY maxLengthChanged)
    Q_PROPERTY(QString pattern    READ pattern    WRITE setPattern    NOTIFY patternChanged)
    Q_PROPERTY(QString errorText  READ errorText                      NOTIFY errorTextChanged)

public:
    explicit FormFieldValidation(QObject *parent = nullptr);

    bool    required()  const { return m_required; }
    int     minLength() const { return m_minLength; }
    int     maxLength() const { return m_maxLength; }
    QString pattern()   const { return m_pattern; }
    QString errorText() const { return m_errorText; }

    void setRequired (bool v);
    void setMinLength(int v);
    void setMaxLength(int v);
    void setPattern  (const QString &v);

    Q_INVOKABLE bool validate(const QString &value);

signals:
    void requiredChanged();
    void minLengthChanged();
    void maxLengthChanged();
    void patternChanged();
    void errorTextChanged();

private:
    void setErrorText(const QString &v);

    bool    m_required{false};
    int     m_minLength{0};
    int     m_maxLength{0};    // 0 = no limit
    QString m_pattern;
    QString m_errorText;
};

#endif // FORMFIELDVALIDATION_H
