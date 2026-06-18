#include "undostack.h"

UndoStack::UndoStack(QObject *parent)
    : QObject(parent)
{
}

void UndoStack::push(const QString &description, const QVariant &data)
{
    const bool     prevCanUndo  = canUndo();
    const bool     prevCanRedo  = canRedo();
    const QString  prevUndoText = undoText();
    const QString  prevRedoText = redoText();
    const int      prevCount    = count();

    while (m_stack.size() > m_index + 1)
        m_stack.removeLast();

    m_stack.append({description, data});
    m_index = m_stack.size() - 1;

    emitStateChange(prevCanUndo, prevCanRedo,
                    prevUndoText, prevRedoText, prevCount);
}

void UndoStack::undo()
{
    if (!canUndo())
        return;

    const bool     prevCanUndo  = canUndo();
    const bool     prevCanRedo  = canRedo();
    const QString  prevUndoText = undoText();
    const QString  prevRedoText = redoText();
    const int      prevCount    = count();

    const Command &cmd  = m_stack.at(m_index);
    const QString  desc = cmd.description;
    const QVariant dat  = cmd.data;
    --m_index;

    emitStateChange(prevCanUndo, prevCanRedo,
                    prevUndoText, prevRedoText, prevCount);
    emit undone(desc, dat);
}

void UndoStack::redo()
{
    if (!canRedo())
        return;

    const bool     prevCanUndo  = canUndo();
    const bool     prevCanRedo  = canRedo();
    const QString  prevUndoText = undoText();
    const QString  prevRedoText = redoText();
    const int      prevCount    = count();

    ++m_index;
    const Command &cmd  = m_stack.at(m_index);
    const QString  desc = cmd.description;
    const QVariant dat  = cmd.data;

    emitStateChange(prevCanUndo, prevCanRedo,
                    prevUndoText, prevRedoText, prevCount);
    emit redone(desc, dat);
}


void UndoStack::clear()
{
    if (m_stack.isEmpty())
        return;

    const bool    prevCanUndo  = canUndo();
    const bool    prevCanRedo  = canRedo();
    const QString prevUndoText = undoText();
    const QString prevRedoText = redoText();
    const int     prevCount    = count();

    m_stack.clear();
    m_index = -1;

    emitStateChange(prevCanUndo, prevCanRedo,
                    prevUndoText, prevRedoText, prevCount);
}

bool    UndoStack::canUndo()  const { return m_index >= 0; }
bool    UndoStack::canRedo()  const
{ return m_index < m_stack.size() - 1; }
QString UndoStack::undoText() const
{ return canUndo() ? m_stack.at(m_index).description : QString{}; }
QString UndoStack::redoText() const
{ return canRedo() ? m_stack.at(m_index + 1).description : QString{}; }
int     UndoStack::count()    const { return m_stack.size(); }


void UndoStack::emitStateChange(bool prevCanUndo, bool prevCanRedo,
                                const QString &prevUndoText,
                                const QString &prevRedoText,
                                int prevCount)
{
    if (canUndo()  != prevCanUndo)  emit canUndoChanged();
    if (canRedo()  != prevCanRedo)  emit canRedoChanged();
    if (undoText() != prevUndoText) emit undoTextChanged();
    if (redoText() != prevRedoText) emit redoTextChanged();
    if (count()    != prevCount)    emit countChanged();
}