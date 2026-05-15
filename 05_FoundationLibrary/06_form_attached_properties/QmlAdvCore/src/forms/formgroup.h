#ifndef FORMGROUP_H
#define FORMGROUP_H

#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include <QtQml/QQmlListProperty>

#include "forms/formfield.h"

// FormGroup owns a collection of FormField children declared inline in QML:
//
//     FormGroup {
//         FormField { label: "Name" }
//         FormField { label: "Email"; fieldType: FormField.Email }
//     }
//
// QQmlListProperty provides the four callbacks the engine calls when QML
// child elements are appended/counted/indexed/cleared.  The read-side
// helper `fieldList()` returns QList<QObject*> which Repeater can use
// directly as a model.
class FormGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // Write side: child-element syntax in QML
    Q_PROPERTY(QQmlListProperty<FormField> fields READ fields NOTIFY fieldsChanged)

    // Read side: QList<QObject*> works natively as a Repeater model
    Q_PROPERTY(QList<QObject*> fieldList READ fieldList NOTIFY fieldsChanged)

public:
    explicit FormGroup(QObject *parent = nullptr);

    QQmlListProperty<FormField> fields();
    QList<QObject *>            fieldList() const;

    Q_INVOKABLE int        fieldCount() const;
    Q_INVOKABLE FormField *fieldAt(int index) const;

signals:
    void fieldsChanged();

private:
    static void       appendField(QQmlListProperty<FormField> *list, FormField *field);
    static qsizetype  fieldCount (QQmlListProperty<FormField> *list);
    static FormField *fieldAt    (QQmlListProperty<FormField> *list, qsizetype index);
    static void       clearFields(QQmlListProperty<FormField> *list);

    QList<FormField *> m_fields;
};

#endif // FORMGROUP_H
