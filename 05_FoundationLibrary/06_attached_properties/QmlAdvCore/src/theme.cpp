#include "theme.h"

Theme::Theme(QObject *parent)
    : QObject(parent)
    , m_colors(new ColorPalette(this))
    , m_spacing(new SpacingGroup(this))
{
}

ColorPalette *Theme::colors() const
{
    return m_colors;
}

SpacingGroup *Theme::spacing() const
{
    return m_spacing;
}