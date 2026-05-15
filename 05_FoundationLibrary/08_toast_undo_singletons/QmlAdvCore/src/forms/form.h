#ifndef FORM_H
#define FORM_H

#include <QObject>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

#include "forms/formattached.h"

// Form is the attached-type owner.  It is never instantiated directly —
// its only purpose is to make `Form.field`, `Form.required`, `Form.pattern`
// available on any QML item via the attached-property mechanism.
//
// Usage (in any QML item, typically a TextField):
//
//     TextField {
//         Form.field: "email"
//         Form.required: true
//         Form.pattern: "^[\\w.]+@[\\w]+\\.[a-z]{2,}$"
//     }
//
// This is identical to how Qt's own Layout.fillWidth or Keys.onPressed work:
//   1. The engine sees `Form.xxx` on an item.
//   2. It calls Form::qmlAttachedProperties(item) to get/create the
//      FormAttached instance for that item.
//   3. It sets `xxx` on the FormAttached instance.
class Form : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(FormAttached)
    QML_UNCREATABLE("Form provides attached properties only — use Form.field, Form.required, etc.")

public:
    explicit Form(QObject *parent = nullptr);

    // Required by QML_ATTACHED — returns the attached object for `object`
    static FormAttached *qmlAttachedProperties(QObject *object);
};

#endif // FORM_H
