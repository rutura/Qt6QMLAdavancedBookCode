#ifndef THEME_H
#define THEME_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "theme/themecolors.h"
#include "theme/themespacing.h"

class Theme : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(ThemeColors  *colors  READ colors  CONSTANT)
    Q_PROPERTY(ThemeSpacing *spacing READ spacing CONSTANT)
    Q_PROPERTY(QString       mode    READ mode    NOTIFY modeChanged)

public:
    explicit Theme(QObject *parent = nullptr);

    ThemeColors  *colors()  const { return m_colors; }
    ThemeSpacing *spacing() const { return m_spacing; }
    QString       mode()    const { return m_mode; }

    Q_INVOKABLE void setMode(const QString &mode);

signals:
    void modeChanged();

private:
    ThemeColors  *m_colors;
    ThemeSpacing *m_spacing;
    QString       m_mode{QStringLiteral("light")};
};

#endif // THEME_H
