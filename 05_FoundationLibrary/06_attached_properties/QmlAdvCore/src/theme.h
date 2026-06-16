#ifndef THEME_H
#define THEME_H

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include "colorpalette.h"
#include "spacinggroup.h"

class Theme : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(ColorPalette* colors  READ colors  CONSTANT)
    Q_PROPERTY(SpacingGroup* spacing READ spacing CONSTANT)

public:
    explicit Theme(QObject *parent = nullptr);

    ColorPalette *colors() const;
    SpacingGroup *spacing() const;

private:
    ColorPalette *m_colors;
    SpacingGroup *m_spacing;
};

#endif // THEME_H