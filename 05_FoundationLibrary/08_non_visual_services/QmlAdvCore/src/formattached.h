#ifndef FORMATTACHED_H
#define FORMATTACHED_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class FormAttached : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS
    QML_UNCREATABLE("FormAttached is accessed via Form.field, Form.label, etc.")
    Q_PROPERTY(QString field    READ field    WRITE setField    NOTIFY fieldChanged)
    Q_PROPERTY(QString label    READ label    WRITE setLabel    NOTIFY labelChanged)
    Q_PROPERTY(bool    required READ required WRITE setRequired NOTIFY requiredChanged)
    Q_PROPERTY(QString hint     READ hint     WRITE setHint     NOTIFY hintChanged)
    Q_PROPERTY(QString error    READ error    NOTIFY errorChanged)

public:
    explicit FormAttached(QObject *parent = nullptr);

    QString field() const;
    void setField(const QString &field);

    QString label() const;
    void setLabel(const QString &label);

    bool required() const;
    void setRequired(bool required);

    QString hint() const;
    void setHint(const QString &hint);

    QString error() const;

    Q_INVOKABLE void validate(const QString &value);

signals:
    void fieldChanged();
    void labelChanged();
    void requiredChanged();
    void hintChanged();
    void errorChanged();

private:
    QString m_field;
    QString m_label;
    bool    m_required{false};
    QString m_hint;
    QString m_error;
};

#endif // FORMATTACHED_H