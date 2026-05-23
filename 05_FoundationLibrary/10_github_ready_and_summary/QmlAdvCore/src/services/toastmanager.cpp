#include "services/toastmanager.h"

ToastManager::ToastManager(QObject *parent)
    : QObject(parent)
{
}

void ToastManager::show(const QString &text, int durationMs)
{
    emit toastShown(text, durationMs);
}
