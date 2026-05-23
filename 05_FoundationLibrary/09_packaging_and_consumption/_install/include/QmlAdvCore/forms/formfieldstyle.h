#ifndef FORMFIELDSTYLE_H
#define FORMFIELDSTYLE_H

#include <QObject>
#include <QColor>
#include <QtQml/qqmlregistration.h>

// FormFieldStyle is the second grouped-property sub-object on FormField.
// Usage:
//     FormField {
//         style.padding: 12
//         style.borderColor: "#6750A4"
//         style.radius: 6
//     }
class FormFieldStyle : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(int    padding     READ padding     WRITE setPadding     NOTIFY paddingChanged)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged)
    Q_PROPERTY(int    borderWidth READ borderWidth WRITE setBorderWidth NOTIFY borderWidthChanged)
    Q_PROPERTY(int    radius      READ radius      WRITE setRadius      NOTIFY radiusChanged)

public:
    explicit FormFieldStyle(QObject *parent = nullptr);

    int    padding()     const { return m_padding; }
    QColor borderColor() const { return m_borderColor; }
    int    borderWidth() const { return m_borderWidth; }
    int    radius()      const { return m_radius; }

    void setPadding    (int v);
    void setBorderColor(const QColor &v);
    void setBorderWidth(int v);
    void setRadius     (int v);

signals:
    void paddingChanged();
    void borderColorChanged();
    void borderWidthChanged();
    void radiusChanged();

private:
    int    m_padding{8};
    QColor m_borderColor{QColor("#6750A4")};
    int    m_borderWidth{1};
    int    m_radius{4};
};

#endif // FORMFIELDSTYLE_H
