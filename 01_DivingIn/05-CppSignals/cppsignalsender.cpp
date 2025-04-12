//cppsignalsender.cpp
#include "cppsignalsender.h"

CppSignalSender::CppSignalSender(QObject *parent)
    : QObject{parent}
{
    connect(&m_timer, &QTimer::timeout, this, [this]() {
        ++m_value;
        emit cppTimer(QString::number(m_value));
    });

    m_timer.start(1000);
}

void CppSignalSender::cppSlot()
{
    emit callQml("Message from C++");
}
