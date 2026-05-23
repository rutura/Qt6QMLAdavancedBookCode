#ifndef TOASTMANAGER_H
#define TOASTMANAGER_H

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// ToastManager is an app-level singleton service.  Any QML code can call
// ToastManager.show("Saved!") from anywhere without passing references around.
//
// The companion ToastHost.qml (also in this module) connects to the
// `toastShown` signal and renders the actual toast UI.  Drop it once at
// the root of your UI:
//
//     ApplicationWindow {
//         ToastHost {}        // listens for ToastManager.show() calls
//         // ... rest of your UI
//     }
//
// This pattern separates concerns cleanly:
//   - ToastManager handles the public API and signal routing
//   - ToastHost handles all rendering
//   - Any code anywhere just calls ToastManager.show()
class ToastManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ToastManager(QObject *parent = nullptr);

    Q_INVOKABLE void show(const QString &text, int durationMs = 3000);

signals:
    void toastShown(const QString &text, int durationMs);
};

#endif // TOASTMANAGER_H
