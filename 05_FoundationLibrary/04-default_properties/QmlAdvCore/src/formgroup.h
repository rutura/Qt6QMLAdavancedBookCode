#ifndef FORMGROUP_H
#define FORMGROUP_H

#include <QObject>
#include <QString>
#include <QList>
#include <QQmlListProperty>
#include <QtQml/qqmlregistration.h>
#include "formfield.h"

class FormGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QQmlListProperty<FormField> fields READ fields NOTIFY fieldsChanged)
    Q_PROPERTY(int fieldCount READ fieldCount NOTIFY fieldsChanged)
    
public:
    explicit FormGroup(QObject *parent = nullptr);
    
    QString title() const;
    void setTitle(const QString &title);
    
    QQmlListProperty<FormField> fields();
    int fieldCount() const;
    Q_INVOKABLE FormField *fieldAt(int index) const;
    
signals:
    void titleChanged();
    void fieldsChanged();
    
private:
    QString m_title;
    QList<FormField *> m_fields;
    
    static void appendField(QQmlListProperty<FormField> *list, FormField *field);
    static qsizetype fieldCount(QQmlListProperty<FormField> *list);
    static FormField *fieldAt(QQmlListProperty<FormField> *list, qsizetype index);
    static void clearFields(QQmlListProperty<FormField> *list);
};

#endif // FORMGROUP_H