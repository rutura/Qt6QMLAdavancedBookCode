#ifndef SPACINGGROUP_H
#define SPACINGGROUP_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class SpacingGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int small  READ small  WRITE setSmall  NOTIFY smallChanged)
    Q_PROPERTY(int medium READ medium WRITE setMedium NOTIFY mediumChanged)
    Q_PROPERTY(int large  READ large  WRITE setLarge  NOTIFY largeChanged)

public:
    explicit SpacingGroup(QObject *parent = nullptr);

    int small() const;
    void setSmall(int value);

    int medium() const;
    void setMedium(int value);

    int large() const;
    void setLarge(int value);

signals:
    void smallChanged();
    void mediumChanged();
    void largeChanged();

private:
    int m_small{8};
    int m_medium{16};
    int m_large{32};
};

#endif // SPACINGGROUP_H