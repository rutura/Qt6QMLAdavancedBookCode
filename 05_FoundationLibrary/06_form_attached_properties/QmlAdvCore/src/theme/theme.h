#ifndef THEME_H
#define THEME_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "theme/themecolors.h"
#include "theme/themespacing.h"

// Theme is the section's key type.  It exposes ThemeColors and ThemeSpacing
// as *object properties* — child QObjects accessible via Theme.colors.primary
// and Theme.spacing.md.  The pointers are CONSTANT (same object throughout
// the app lifetime) but ThemeColors' individual color properties are NOTIFY,
// so bindings update when setMode() changes the palette.
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
