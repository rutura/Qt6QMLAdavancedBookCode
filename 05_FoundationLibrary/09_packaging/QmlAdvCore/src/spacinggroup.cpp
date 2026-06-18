#include "spacinggroup.h"

SpacingGroup::SpacingGroup(QObject *parent)
    : QObject(parent)
{
}

int SpacingGroup::small() const
{
    return m_small;
}

void SpacingGroup::setSmall(int value)
{
    if (m_small == value)
        return;
    m_small = value;
    emit smallChanged();
}

int SpacingGroup::medium() const
{
    return m_medium;
}

void SpacingGroup::setMedium(int value)
{
    if (m_medium == value)
        return;
    m_medium = value;
    emit mediumChanged();
}

int SpacingGroup::large() const
{
    return m_large;
}

void SpacingGroup::setLarge(int value)
{
    if (m_large == value)
        return;
    m_large = value;
    emit largeChanged();
}