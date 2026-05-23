#ifndef FORMFIELD_H
#define FORMFIELD_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

#include "forms/formfieldvalidation.h"
#include "forms/formfieldstyle.h"

// FormField represents a single input in a form.  It is creatable from QML
// so the reader can write:
//     FormGroup {
//         FormField { label: "Email"; fieldType: FormField.Email }
//     }
//
// Starting in section 05, FormField also carries two grouped sub-objects:
// `validation` and `style`.  Because they are exposed as CONSTANT
// Q_PROPERTYs, QML can write:
//
//     FormField {
//         label: "Email"
//         fieldType: FormField.Email
//         validation.required: true
//         validation.pattern: "^[\\w.]+@[\\w]+\\.[a-z]{2,}$"
//         style.borderColor: "#6750A4"
//         style.radius: 6
//     }
//
// The grouped-property syntax `validation.required` is not a special language
// feature — it is plain property-dot-property access, enabled by the fact that
// `validation` is itself a QObject with its own Q_PROPERTYs.
class FormField : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString   label       READ label       WRITE setLabel       NOTIFY labelChanged)
    Q_PROPERTY(QString   placeholder READ placeholder WRITE setPlaceholder NOTIFY placeholderChanged)
    Q_PROPERTY(QString   value       READ value       WRITE setValue       NOTIFY valueChanged)
    Q_PROPERTY(FieldType fieldType   READ fieldType   WRITE setFieldType   NOTIFY fieldTypeChanged)

    // Grouped properties — pointer is CONSTANT, sub-properties emit signals
    Q_PROPERTY(FormFieldValidation *validation READ validation CONSTANT)
    Q_PROPERTY(FormFieldStyle      *style      READ style      CONSTANT)

public:
    enum FieldType { Text, Email, Number, Password };
    Q_ENUM(FieldType)

    explicit FormField(QObject *parent = nullptr);

    QString   label()       const { return m_label; }
    QString   placeholder() const { return m_placeholder; }
    QString   value()       const { return m_value; }
    FieldType fieldType()   const { return m_fieldType; }

    FormFieldValidation *validation() const { return m_validation; }
    FormFieldStyle      *style()      const { return m_style; }

    void setLabel(const QString &v);
    void setPlaceholder(const QString &v);
    void setValue(const QString &v);
    void setFieldType(FieldType v);

signals:
    void labelChanged();
    void placeholderChanged();
    void valueChanged();
    void fieldTypeChanged();

private:
    QString   m_label;
    QString   m_placeholder;
    QString   m_value;
    FieldType m_fieldType{Text};

    FormFieldValidation *m_validation;
    FormFieldStyle      *m_style;
};

#endif // FORMFIELD_H
