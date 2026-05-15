#include "theme/theme.h"

Theme::Theme(QObject *parent)
    : QObject(parent)
    , m_colors(new ThemeColors(this))
    , m_spacing(new ThemeSpacing(this))
{
}

void Theme::setMode(const QString &mode)
{
    if (m_mode == mode)
        return;

    m_mode = mode;

    if (mode == QStringLiteral("dark"))
        m_colors->applyDark();
    else
        m_colors->applyLight();

    emit modeChanged();
}
