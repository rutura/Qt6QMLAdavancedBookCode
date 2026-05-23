#include "components/card.h"

Card::Card(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, false);
}

QQmlListProperty<QQuickItem> Card::contentItems()
{
    return QQmlListProperty<QQuickItem>(this, nullptr,
                                        &Card::appendItem,
                                        &Card::itemCount,
                                        &Card::itemAt,
                                        &Card::clearItems);
}

void Card::setPadding(int v)
{
    if (m_padding == v) return;
    m_padding = v;
    emit paddingChanged();
    polish();
}

void Card::setSpacing(int v)
{
    if (m_spacing == v) return;
    m_spacing = v;
    emit spacingChanged();
    polish();
}

void Card::componentComplete()
{
    QQuickItem::componentComplete();
    layoutItems();
}

void Card::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size())
        layoutItems();
}

void Card::layoutItems()
{
    if (!isComponentComplete())
        return;

    qreal y = m_padding;
    qreal maxW = 0;

    for (QQuickItem *item : std::as_const(m_items)) {
        item->setX(m_padding);
        item->setY(y);
        qreal h = item->implicitHeight() > 0 ? item->implicitHeight() : item->height();
        y += h + m_spacing;
        qreal w = item->implicitWidth() > 0 ? item->implicitWidth() : item->width();
        maxW = qMax(maxW, w);
    }

    if (!m_items.isEmpty())
        y -= m_spacing; // remove trailing gap

    setImplicitHeight(y + m_padding);
    setImplicitWidth(maxW + 2 * m_padding);
}

// --- Static callbacks ---

void Card::appendItem(QQmlListProperty<QQuickItem> *list, QQuickItem *item)
{
    auto *self = qobject_cast<Card *>(list->object);
    item->setParentItem(self);
    self->m_items.append(item);
    emit self->contentItemsChanged();
    self->polish();
}

qsizetype Card::itemCount(QQmlListProperty<QQuickItem> *list)
{
    return qobject_cast<Card *>(list->object)->m_items.size();
}

QQuickItem *Card::itemAt(QQmlListProperty<QQuickItem> *list, qsizetype index)
{
    return qobject_cast<Card *>(list->object)->m_items.value(index);
}

void Card::clearItems(QQmlListProperty<QQuickItem> *list)
{
    auto *self = qobject_cast<Card *>(list->object);
    self->m_items.clear();
    emit self->contentItemsChanged();
    self->polish();
}
