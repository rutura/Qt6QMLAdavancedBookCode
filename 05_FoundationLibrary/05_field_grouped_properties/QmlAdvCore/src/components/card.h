#ifndef CARD_H
#define CARD_H

#include <QQuickItem>
#include <QtQml/qqmlregistration.h>
#include <QtQml/QQmlListProperty>

// Card is a QQuickItem subclass that uses Q_CLASSINFO("DefaultProperty", ...)
// so child items declared directly inside Card {} braces are collected into
// `contentItems` — no explicit property name needed in QML.
//
// Compare:
//   Card { Text { text: "A" }  Button { text: "B" } }   // with DefaultProperty
//   Card { contentItems: [ Text { text: "A" }, ... ] }   // without
//
// Qt itself uses this pattern for Rectangle (default property: "data")
// and ColumnLayout (default property: "data").
class Card : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_CLASSINFO("DefaultProperty", "contentItems")

    Q_PROPERTY(QQmlListProperty<QQuickItem> contentItems READ contentItems NOTIFY contentItemsChanged)
    Q_PROPERTY(int  padding READ padding WRITE setPadding NOTIFY paddingChanged)
    Q_PROPERTY(int  spacing READ spacing WRITE setSpacing NOTIFY spacingChanged)

public:
    explicit Card(QQuickItem *parent = nullptr);

    QQmlListProperty<QQuickItem> contentItems();

    int  padding() const { return m_padding; }
    void setPadding(int v);

    int  spacing() const { return m_spacing; }
    void setSpacing(int v);

signals:
    void contentItemsChanged();
    void paddingChanged();
    void spacingChanged();

protected:
    void componentComplete() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    static void        appendItem(QQmlListProperty<QQuickItem> *list, QQuickItem *item);
    static qsizetype   itemCount (QQmlListProperty<QQuickItem> *list);
    static QQuickItem *itemAt    (QQmlListProperty<QQuickItem> *list, qsizetype index);
    static void        clearItems(QQmlListProperty<QQuickItem> *list);

    void layoutItems();

    QList<QQuickItem *> m_items;
    int m_padding{16};
    int m_spacing{8};
};

#endif // CARD_H
