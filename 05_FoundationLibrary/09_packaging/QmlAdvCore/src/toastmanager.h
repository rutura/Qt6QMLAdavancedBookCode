#ifndef TOASTMANAGER_H
#define TOASTMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class ToastManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString message  READ message  NOTIFY messageChanged)
    Q_PROPERTY(bool    visible  READ visible  NOTIFY visibleChanged)
    Q_PROPERTY(int     duration READ duration WRITE setDuration
                   NOTIFY durationChanged)

public:
    explicit ToastManager(QObject *parent = nullptr);

    Q_INVOKABLE void show(const QString &message, int duration = -1);
    Q_INVOKABLE void dismiss();

    QString message()  const;
    bool    visible()  const;
    int     duration() const;
    void    setDuration(int ms);

signals:
    void messageChanged();
    void visibleChanged();
    void durationChanged();

private:
    QString  m_message;
    bool     m_visible{false};
    int      m_duration{3000};
    QTimer  *m_timer;
};

#endif // TOASTMANAGER_H