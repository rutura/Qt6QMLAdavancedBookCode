#include "backend.h"

Backend::Backend(QObject *parent)
    : QObject(parent)
    , m_message("Hello from C++ Backend!")
    , m_counter(0)
{
}

QString Backend::message() const
{
    return m_message;
}

void Backend::setMessage(const QString &message)
{
    if (m_message != message) {
        m_message = message;
        emit messageChanged();
    }
}

int Backend::counter() const
{
    return m_counter;
}

void Backend::setCounter(int counter)
{
    if (m_counter != counter) {
        m_counter = counter;
        emit counterChanged();
    }
}

void Backend::incrementCounter()
{
    setCounter(m_counter + 1);
}

void Backend::resetCounter()
{
    setCounter(0);
}
