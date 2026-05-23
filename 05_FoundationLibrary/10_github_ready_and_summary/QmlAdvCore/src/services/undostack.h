#ifndef UNDOSTACK_H
#define UNDOSTACK_H

#include <QObject>
#include <QList>
#include <QJSValue>
#include <QtQml/qqmlregistration.h>

// UndoStack is instantiable (not a singleton) so each page or subsystem
// can have its own independent undo history.  QML closures are used as
// undo/redo actions, keeping the API free of any C++ application logic.
//
// Usage:
//     UndoStack { id: undoStack }
//
//     // Push a reversible action
//     undoStack.push(
//         function() { item.x = oldX },   // undo
//         function() { item.x = newX }    // redo
//     )
//
//     Button { text: "Undo"; enabled: undoStack.canUndo
//              onClicked: undoStack.undo() }
class UndoStack : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY canRedoChanged)
    Q_PROPERTY(int  count   READ count   NOTIFY countChanged)

public:
    explicit UndoStack(QObject *parent = nullptr);

    bool canUndo() const;
    bool canRedo() const;
    int  count()   const { return m_stack.size(); }

    Q_INVOKABLE void push (const QJSValue &undoFn, const QJSValue &redoFn);
    Q_INVOKABLE void undo ();
    Q_INVOKABLE void redo ();
    Q_INVOKABLE void clear();

signals:
    void canUndoChanged();
    void canRedoChanged();
    void countChanged();

private:
    void notifyChanged();

    struct Command { QJSValue undoFn; QJSValue redoFn; };
    QList<Command> m_stack;
    int            m_index{-1}; // points to last executed command
};

#endif // UNDOSTACK_H
