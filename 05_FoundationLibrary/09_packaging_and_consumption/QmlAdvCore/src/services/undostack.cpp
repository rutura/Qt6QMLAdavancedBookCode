#include "services/undostack.h"

UndoStack::UndoStack(QObject *parent)
    : QObject(parent)
{
}

bool UndoStack::canUndo() const
{
    return m_index >= 0;
}

bool UndoStack::canRedo() const
{
    return m_index < m_stack.size() - 1;
}

void UndoStack::push(const QJSValue &undoFn, const QJSValue &redoFn)
{
    // Discard any redo history above current position
    while (m_stack.size() > m_index + 1)
        m_stack.removeLast();

    m_stack.append({undoFn, redoFn});
    m_index = m_stack.size() - 1;

    notifyChanged();
}

void UndoStack::undo()
{
    if (!canUndo()) return;
    QJSValue fn = m_stack[m_index].undoFn;
    --m_index;
    if (fn.isCallable())
        fn.call();
    notifyChanged();
}

void UndoStack::redo()
{
    if (!canRedo()) return;
    ++m_index;
    QJSValue fn = m_stack[m_index].redoFn;
    if (fn.isCallable())
        fn.call();
    notifyChanged();
}

void UndoStack::clear()
{
    m_stack.clear();
    m_index = -1;
    notifyChanged();
}

void UndoStack::notifyChanged()
{
    emit canUndoChanged();
    emit canRedoChanged();
    emit countChanged();
}
