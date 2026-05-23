#include "themecolors.h"

ThemeColors::ThemeColors(QObject *parent)
    : QObject(parent)
{
    applyLight();
}

void ThemeColors::applyLight()
{
    m_primary    = QColor("#6750A4");
    m_onPrimary  = QColor("#FFFFFF");
    m_surface    = QColor("#FFFBFE");
    m_background = QColor("#F6F5F5");
    m_text       = QColor("#1C1B1F");

    emit primaryChanged();
    emit onPrimaryChanged();
    emit surfaceChanged();
    emit backgroundChanged();
    emit textChanged();
}

void ThemeColors::applyDark()
{
    m_primary    = QColor("#D0BCFF");
    m_onPrimary  = QColor("#381E72");
    m_surface    = QColor("#1C1B1F");
    m_background = QColor("#121212");
    m_text       = QColor("#E6E1E5");

    emit primaryChanged();
    emit onPrimaryChanged();
    emit surfaceChanged();
    emit backgroundChanged();
    emit textChanged();
}
