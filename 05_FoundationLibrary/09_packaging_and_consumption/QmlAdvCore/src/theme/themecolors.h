#ifndef THEMECOLORS_H
#define THEMECOLORS_H

#include <QObject>
#include <QColor>
#include <QtQml/qqmlregistration.h>

// ThemeColors is not created directly from QML — it is only accessed
// through the Theme singleton's `colors` property.  QML_ANONYMOUS
// registers the type's meta-object with the engine so property bindings
// and signals work, while preventing direct instantiation in QML.
class ThemeColors : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(QColor primary    READ primary    NOTIFY primaryChanged)
    Q_PROPERTY(QColor onPrimary  READ onPrimary  NOTIFY onPrimaryChanged)
    Q_PROPERTY(QColor surface    READ surface    NOTIFY surfaceChanged)
    Q_PROPERTY(QColor background READ background NOTIFY backgroundChanged)
    Q_PROPERTY(QColor text       READ text       NOTIFY textChanged)

public:
    explicit ThemeColors(QObject *parent = nullptr);

    QColor primary()    const { return m_primary; }
    QColor onPrimary()  const { return m_onPrimary; }
    QColor surface()    const { return m_surface; }
    QColor background() const { return m_background; }
    QColor text()       const { return m_text; }

    void applyLight();
    void applyDark();

signals:
    void primaryChanged();
    void onPrimaryChanged();
    void surfaceChanged();
    void backgroundChanged();
    void textChanged();

private:
    QColor m_primary;
    QColor m_onPrimary;
    QColor m_surface;
    QColor m_background;
    QColor m_text;
};

#endif // THEMECOLORS_H
