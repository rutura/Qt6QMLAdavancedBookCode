#include "colorpalette.h"

ColorPalette::ColorPalette(QObject *parent)
    : QObject(parent)
{
}

QColor ColorPalette::primary() const
{
    return m_primary;
}

void ColorPalette::setPrimary(const QColor &color)
{
    if (m_primary == color)
        return;
    m_primary = color;
    emit primaryChanged();
}

QColor ColorPalette::secondary() const
{
    return m_secondary;
}

void ColorPalette::setSecondary(const QColor &color)
{
    if (m_secondary == color)
        return;
    m_secondary = color;
    emit secondaryChanged();
}

QColor ColorPalette::surface() const
{
    return m_surface;
}

void ColorPalette::setSurface(const QColor &color)
{
    if (m_surface == color)
        return;
    m_surface = color;
    emit surfaceChanged();
}

QColor ColorPalette::onPrimary() const
{
    return m_onPrimary;
}

void ColorPalette::setOnPrimary(const QColor &color)
{
    if (m_onPrimary == color)
        return;
    m_onPrimary = color;
    emit onPrimaryChanged();
}