#include "forms/formattached.h"
#include "forms/form.h"

#include <QMetaMethod>
#include <QMetaProperty>

FormAttached::FormAttached(QObject *parent)
    : QObject(parent)
{
    connectToTargetValue();
}

QVariant FormAttached::value() const
{
    QObject *target = parent();
    if (!target)
        return {};
    QVariant v = target->property("text");
    if (v.isValid()) return v;
    v = target->property("value");
    if (v.isValid()) return v;
    return target->property("checked");
}

void FormAttached::setField(const QString &v)
{
    if (m_field == v) return;
    const QString old = m_field;
    m_field = v;
    emit fieldChanged();

    if (auto *form = Form::instance(this)) {
        if (old.isEmpty() && !v.isEmpty())
            form->registerField(this);
        else if (!old.isEmpty() && v.isEmpty())
            form->unregisterField(this);
        else
            form->notifyValuesChanged();
    }
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

void FormAttached::connectToTargetValue()
{
    QObject *target = parent();
    if (!target) return;

    // Auto-wire the target's input property change-signal to our valueChanged.
    // Works for TextField (text), Slider (value), CheckBox (checked), etc.
    const char *propNames[] = { "text", "value", "checked" };
    const QMetaObject *mo = target->metaObject();
    for (const char *name : propNames) {
        const int idx = mo->indexOfProperty(name);
        if (idx < 0) continue;
        const QMetaProperty prop = mo->property(idx);
        if (!prop.hasNotifySignal()) continue;

        const int ourIdx = this->metaObject()->indexOfSignal("valueChanged()");
        if (ourIdx < 0) return;
        QObject::connect(target, prop.notifySignal(),
                         this,   this->metaObject()->method(ourIdx));
        return;
    }
}
