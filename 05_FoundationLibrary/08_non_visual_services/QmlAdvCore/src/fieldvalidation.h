#ifndef FIELDVALIDATION_H
#define FIELDVALIDATION_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class FieldValidation : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS
    Q_PROPERTY(bool required  READ required  WRITE setRequired  NOTIFY requiredChanged)
    Q_PROPERTY(int  minLength READ minLength WRITE setMinLength NOTIFY minLengthChanged)
    Q_PROPERTY(int  maxLength READ maxLength WRITE setMaxLength NOTIFY maxLengthChanged)

public:
    explicit FieldValidation(QObject *parent = nullptr);

    bool required() const;
    void setRequired(bool required);

    int minLength() const;
    void setMinLength(int minLength);

    int maxLength() const;
    void setMaxLength(int maxLength);

signals:
    void requiredChanged();
    void minLengthChanged();
    void maxLengthChanged();

private:
    bool m_required{false};
    int  m_minLength{0};
    int  m_maxLength{0};
};

#endif // FIELDVALIDATION_H