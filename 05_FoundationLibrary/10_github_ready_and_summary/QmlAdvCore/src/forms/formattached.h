#ifndef FORMATTACHED_H
#define FORMATTACHED_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QtQml/qqmlregistration.h>

// FormAttached holds the per-item attached state.
// One instance is created per QML item that accesses Form.xxx.
// The engine calls Form::qmlAttachedProperties(item) to create it.
//
// The `value` property auto-reads the target item's `text`, `value`, or
// `checked` property (whichever exists) and emits `valueChanged()` when
// that property changes — so the Form singleton's `values` map stays
// up to date without the user having to write any binding code.
class FormAttached : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(QString  field    READ field    WRITE setField    NOTIFY fieldChanged)
    Q_PROPERTY(bool     required READ required WRITE setRequired NOTIFY requiredChanged)
    Q_PROPERTY(QString  pattern  READ pattern  WRITE setPattern  NOTIFY patternChanged)
    Q_PROPERTY(QVariant value    READ value                      NOTIFY valueChanged)

public:
    explicit FormAttached(QObject *parent = nullptr);

    QString  field()    const { return m_field; }
    bool     required() const { return m_required; }
    QString  pattern()  const { return m_pattern; }
    QVariant value()    const;

    void setField   (const QString &v);
    void setRequired(bool v);
    void setPattern (const QString &v);

signals:
    void fieldChanged();
    void requiredChanged();
    void patternChanged();
    void valueChanged();

private:
    void connectToTargetValue();

    QString m_field;
    bool    m_required{false};
    QString m_pattern;
};

#endif // FORMATTACHED_H
