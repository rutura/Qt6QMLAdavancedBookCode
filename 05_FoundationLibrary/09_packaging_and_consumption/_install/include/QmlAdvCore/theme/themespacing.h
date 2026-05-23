#ifndef THEMESPACING_H
#define THEMESPACING_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class ThemeSpacing : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(int xs READ xs CONSTANT)
    Q_PROPERTY(int sm READ sm CONSTANT)
    Q_PROPERTY(int md READ md CONSTANT)
    Q_PROPERTY(int lg READ lg CONSTANT)
    Q_PROPERTY(int xl READ xl CONSTANT)

public:
    explicit ThemeSpacing(QObject *parent = nullptr);

    int xs() const { return 4; }
    int sm() const { return 8; }
    int md() const { return 16; }
    int lg() const { return 24; }
    int xl() const { return 32; }
};

#endif // THEMESPACING_H
