#ifndef FORMFIELD_H
#define FORMFIELD_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// FormField represents a single input in a form.  It is creatable from QML
// so the reader can write:
//     FormGroup {
//         FormField { label: "Email"; fieldType: FormField.Email }
//     }
class FormField : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString   label       READ label       WRITE setLabel       NOTIFY labelChanged)
    Q_PROPERTY(QString   placeholder READ placeholder WRITE setPlaceholder NOTIFY placeholderChanged)
    Q_PROPERTY(QString   value       READ value       WRITE setValue       NOTIFY valueChanged)
    Q_PROPERTY(FieldType fieldType   READ fieldType   WRITE setFieldType   NOTIFY fieldTypeChanged)

public:
    enum FieldType { Text, Email, Number, Password };
    Q_ENUM(FieldType)

    explicit FormField(QObject *parent = nullptr);

    QString   label()       const { return m_label; }
    QString   placeholder() const { return m_placeholder; }
    QString   value()       const { return m_value; }
    FieldType fieldType()   const { return m_fieldType; }

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
};

#endif // FORMFIELD_H
