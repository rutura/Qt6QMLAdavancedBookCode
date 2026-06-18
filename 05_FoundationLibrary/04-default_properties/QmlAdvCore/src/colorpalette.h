#ifndef COLORPALETTE_H
#define COLORPALETTE_H

#include <QObject>
#include <QColor>
#include <QtQml/qqmlregistration.h>

class ColorPalette : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // properties go here
    Q_PROPERTY(QColor primary   READ primary   WRITE setPrimary   NOTIFY primaryChanged)
    Q_PROPERTY(QColor secondary READ secondary WRITE setSecondary NOTIFY secondaryChanged)
    Q_PROPERTY(QColor surface   READ surface   WRITE setSurface   NOTIFY surfaceChanged)
    Q_PROPERTY(QColor onPrimary READ onPrimary WRITE setOnPrimary NOTIFY onPrimaryChanged)

public:
    explicit ColorPalette(QObject *parent = nullptr);

    QColor primary() const;
    void setPrimary(const QColor &color);

    QColor secondary() const;
    void setSecondary(const QColor &color);

    QColor surface() const;
    void setSurface(const QColor &color);

    QColor onPrimary() const;
    void setOnPrimary(const QColor &color);

signals:
    void primaryChanged();
    void secondaryChanged();
    void surfaceChanged();
    void onPrimaryChanged();

private:
    // members go here
    QColor m_primary{QColor("#6750A4")};
    QColor m_secondary{QColor("#625B71")};
    QColor m_surface{QColor("#FFFBFE")};
    QColor m_onPrimary{QColor("#FFFFFF")};
};

#endif // COLORPALETTE_H