#include "formfieldstyle.h"

FormFieldStyle::FormFieldStyle(QObject *parent)
    : QObject(parent)
{
}

void FormFieldStyle::setPadding(int v)
{
    if (m_padding == v) return;
    m_padding = v;
    emit paddingChanged();
}

void FormFieldStyle::setBorderColor(const QColor &v)
{
    if (m_borderColor == v) return;
    m_borderColor = v;
    emit borderColorChanged();
}

void FormFieldStyle::setBorderWidth(int v)
{
    if (m_borderWidth == v) return;
    m_borderWidth = v;
    emit borderWidthChanged();
}

void FormFieldStyle::setRadius(int v)
{
    if (m_radius == v) return;
    m_radius = v;
    emit radiusChanged();
}
