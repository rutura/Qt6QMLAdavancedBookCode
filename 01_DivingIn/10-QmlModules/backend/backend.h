#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    Q_PROPERTY(int counter READ counter WRITE setCounter NOTIFY counterChanged)
    QML_ELEMENT

public:
    explicit Backend(QObject *parent = nullptr);

    QString message() const;
    void setMessage(const QString &message);

    int counter() const;
    void setCounter(int counter);

public slots:
    void incrementCounter();
    void resetCounter();

signals:
    void messageChanged();
    void counterChanged();

private:
    QString m_message;
    int m_counter;
};

#endif // BACKEND_H