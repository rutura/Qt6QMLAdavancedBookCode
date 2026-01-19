#include "JsonSerializer.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

QString JsonSerializer::s_lastError;

bool JsonSerializer::saveContacts(const QVector<Contact> &contacts, const QString &filePath)
{
    s_lastError.clear();

    QJsonArray contactsArray;
    for (const Contact &contact : contacts) {
        contactsArray.append(contact.toJson());
    }

    QJsonObject rootObject;
    rootObject["version"] = 1;
    rootObject["contacts"] = contactsArray;

    QJsonDocument doc(rootObject);

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        s_lastError = QString("Failed to open file for writing: %1").arg(file.errorString());
        qWarning() << "JsonSerializer:" << s_lastError;
        return false;
    }

    qint64 bytesWritten = file.write(doc.toJson(QJsonDocument::Indented));
    if (bytesWritten == -1) {
        s_lastError = QString("Failed to write to file: %1").arg(file.errorString());
        qWarning() << "JsonSerializer:" << s_lastError;
        file.close();
        return false;
    }

    file.close();
    qDebug() << "JsonSerializer: Saved" << contacts.size() << "contacts to" << filePath;
    return true;
}

bool JsonSerializer::loadContacts(const QString &filePath, QVector<Contact> &contacts)
{
    s_lastError.clear();
    contacts.clear();

    if (!fileExists(filePath)) {
        s_lastError = QString("File does not exist: %1").arg(filePath);
        qDebug() << "JsonSerializer:" << s_lastError;
        return false;
    }

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        s_lastError = QString("Failed to open file for reading: %1").arg(file.errorString());
        qWarning() << "JsonSerializer:" << s_lastError;
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        s_lastError = QString("JSON parse error: %1 at offset %2")
                          .arg(parseError.errorString())
                          .arg(parseError.offset);
        qWarning() << "JsonSerializer:" << s_lastError;
        return false;
    }

    if (!doc.isObject()) {
        s_lastError = "Invalid JSON structure: root is not an object";
        qWarning() << "JsonSerializer:" << s_lastError;
        return false;
    }

    QJsonObject rootObject = doc.object();

    if (!rootObject.contains("contacts") || !rootObject["contacts"].isArray()) {
        s_lastError = "Invalid JSON structure: missing 'contacts' array";
        qWarning() << "JsonSerializer:" << s_lastError;
        return false;
    }

    QJsonArray contactsArray = rootObject["contacts"].toArray();

    for (const QJsonValue &value : contactsArray) {
        if (value.isObject()) {
            Contact contact = Contact::fromJson(value.toObject());
            contacts.append(contact);
        }
    }

    qDebug() << "JsonSerializer: Loaded" << contacts.size() << "contacts from" << filePath;
    return true;
}

QString JsonSerializer::getDefaultFilePath()
{
    QString appDir = QCoreApplication::applicationDirPath();
    return QDir(appDir).filePath("contacts.json");
}

bool JsonSerializer::fileExists(const QString &filePath)
{
    return QFileInfo::exists(filePath);
}

QString JsonSerializer::lastError()
{
    return s_lastError;
}
