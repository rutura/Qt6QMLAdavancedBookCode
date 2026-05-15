#ifndef FORM_H
#define FORM_H

#include <QObject>
#include <QSet>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class FormAttached;

// Form is the attached-type owner *and* an app-level singleton.
//
// As an attached-property owner, it lets any QML item opt into form tracking:
//
//     TextField {
//         Form.field: "email"
//         Form.required: true
//         Form.pattern: "^[\\w.]+@[\\w]+\\.[a-z]{2,}$"
//     }
//
// As a singleton, it aggregates every tracked field's current value into
// `Form.values` and exposes a `Form.submit()` method/signal:
//
//     Button {
//         text: "Submit"
//         onClicked: Form.submit()
//     }
//
//     Connections {
//         target: Form
//         function onSubmitted(values) { console.log(JSON.stringify(values)) }
//     }
//
// The same name (`Form`) plays both roles because QML resolves attached
// access (`item.Form.x`) and singleton access (`Form.x`) at different
// lookup sites — exactly the way `Window` works in QtQuick.
class Form : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_ATTACHED(FormAttached)

    Q_PROPERTY(QVariantMap values     READ values     NOTIFY valuesChanged)
    Q_PROPERTY(int         fieldCount READ fieldCount NOTIFY valuesChanged)

public:
    explicit Form(QObject *parent = nullptr);

    QVariantMap values() const;
    int         fieldCount() const;

    Q_INVOKABLE void submit();

    static FormAttached *qmlAttachedProperties(QObject *object);

    // FormAttached talks back through these to keep `values` consistent
    void registerField  (FormAttached *attached);
    void unregisterField(FormAttached *attached);
    void notifyValuesChanged();

    // Helper: look up the singleton from an attached object's context
    static Form *instance(QObject *contextObject);

signals:
    void valuesChanged();
    void submitted(QVariantMap values);

private:
    QSet<FormAttached *> m_fields;
};

#endif // FORM_H
