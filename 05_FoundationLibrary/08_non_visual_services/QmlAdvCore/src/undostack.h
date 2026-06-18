#ifndef UNDOSTACK_H
#define UNDOSTACK_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QList>
#include <QtQml/qqmlregistration.h>

class UndoStack : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool    canUndo  READ canUndo  NOTIFY canUndoChanged)
    Q_PROPERTY(bool    canRedo  READ canRedo  NOTIFY canRedoChanged)
    Q_PROPERTY(QString undoText READ undoText NOTIFY undoTextChanged)
    Q_PROPERTY(QString redoText READ redoText NOTIFY redoTextChanged)
    Q_PROPERTY(int     count    READ count    NOTIFY countChanged)

public:
    explicit UndoStack(QObject *parent = nullptr);

    Q_INVOKABLE void push(const QString &description,
                          const QVariant &data = {});
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void clear();

    bool    canUndo()  const;
    bool    canRedo()  const;
    QString undoText() const;
    QString redoText() const;
    int     count()    const;

signals:
    void canUndoChanged();
    void canRedoChanged();
    void undoTextChanged();
    void redoTextChanged();
    void countChanged();

    void undone(const QString &description, const QVariant &data);
    void redone(const QString &description, const QVariant &data);

private:
    struct Command {
        QString  description;
        QVariant data;
    };

    void emitStateChange(bool prevCanUndo, bool prevCanRedo,
                         const QString &prevUndoText,
                         const QString &prevRedoText,
                         int prevCount);

    QList<Command> m_stack;
    int            m_index{-1};
};

#endif // UNDOSTACK_H