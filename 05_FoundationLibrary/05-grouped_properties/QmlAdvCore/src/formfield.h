#ifndef FORMFIELD_H
#define FORMFIELD_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>
#include "fieldvalidation.h"

class FormField : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString label       READ label       WRITE setLabel
                   NOTIFY labelChanged)
    Q_PROPERTY(QString placeholder READ placeholder WRITE setPlaceholder
                   NOTIFY placeholderChanged)
    /*
    Q_PROPERTY(bool    required    READ required    WRITE setRequired
                   NOTIFY requiredChanged)
    */
    Q_PROPERTY(FieldValidation* validation READ validation CONSTANT)


public:
    explicit FormField(QObject *parent = nullptr);

    QString label() const;
    void setLabel(const QString &label);

    QString placeholder() const;
    void setPlaceholder(const QString &placeholder);

    /*
    bool required() const;
    void setRequired(bool required);
    */
    FieldValidation *validation() const;


signals:
    void labelChanged();
    void placeholderChanged();
    /*
    void requiredChanged();
    */

private:
    QString m_label;
    QString m_placeholder;
    /*
    bool m_required{false};
    */
    FieldValidation *m_validation;

};

#endif // FORMFIELD_H