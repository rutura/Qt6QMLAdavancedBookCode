#include "card.h"

Card::Card(QQuickItem *parent)
    : QQuickItem(parent)
{
}

QQmlListProperty<QQuickItem> Card::contentItems()
{
    return QQmlListProperty<QQuickItem>(
        this, &m_items,
        &Card::appendItem,
        &Card::itemCount,
        &Card::itemAt,
        &Card::clearItems
        );
}

int Card::padding() const { return m_padding; }

void Card::setPadding(int padding)
{
    if (m_padding == padding)
        return;
    m_padding = padding;
    emit paddingChanged();
    polish();
}

int Card::spacing() const { return m_spacing; }

void Card::setSpacing(int spacing)
{
    if (m_spacing == spacing)
        return;
    m_spacing = spacing;
    emit spacingChanged();
    polish();
}

void Card::componentComplete()
{
    QQuickItem::componentComplete();
    layoutItems();
}

void Card::geometryChange(const QRectF &newGeometry,
                          const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.width() != oldGeometry.width())
        polish();
}

void Card::updatePolish()
{
    layoutItems();
}

void Card::layoutItems()
{
    if (!isComponentComplete())
        return;

    qreal y = m_padding;
    const qreal contentWidth = width() - 2.0 * m_padding;

    for (QQuickItem *item : std::as_const(m_items)) {
        if (!item->isVisible())
            continue;
        item->setX(m_padding);
        item->setY(y);
        if (contentWidth > 0)
            item->setWidth(contentWidth);
        y += item->height() + m_spacing;
    }

    if (!m_items.isEmpty())
        setImplicitHeight(y - m_spacing + m_padding);
}

void Card::appendItem(QQmlListProperty<QQuickItem> *list,
                      QQuickItem *item)
{
    auto *card = qobject_cast<Card *>(list->object);
    item->setParentItem(card);
    item->setParent(card);
    card->m_items.append(item);
    emit card->contentItemsChanged();
    card->polish();
}

qsizetype Card::itemCount(QQmlListProperty<QQuickItem> *list)
{
    return qobject_cast<Card *>(list->object)->m_items.size();
}

QQuickItem *Card::itemAt(QQmlListProperty<QQuickItem> *list,
                         qsizetype index)
{
    return qobject_cast<Card *>(list->object)->m_items.at(index);
}

void Card::clearItems(QQmlListProperty<QQuickItem> *list)
{
    auto *card = qobject_cast<Card *>(list->object);
    for (QQuickItem *item : std::as_const(card->m_items)) {
        item->setParentItem(nullptr);
        item->setParent(nullptr);
    }
    qDeleteAll(card->m_items);
    card->m_items.clear();
    emit card->contentItemsChanged();
    card->polish();
}