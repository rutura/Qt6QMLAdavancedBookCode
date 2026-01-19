#ifndef JSONSERIALIZER_H
#define JSONSERIALIZER_H

#include <QString>
#include <QVector>
#include "../models/Contact.h"

/**
 * @brief The JsonSerializer class provides JSON file operations for contacts.
 *
 * This utility class handles:
 * - Saving contacts to a JSON file
 * - Loading contacts from a JSON file
 * - Error handling for file operations
 *
 * The JSON file is stored in the same directory as the executable.
 */
class JsonSerializer
{
public:
    /**
     * @brief Saves contacts to a JSON file.
     * @param contacts The list of contacts to save.
     * @param filePath The path to the JSON file.
     * @return true if successful, false otherwise.
     */
    static bool saveContacts(const QVector<Contact> &contacts, const QString &filePath);

    /**
     * @brief Loads contacts from a JSON file.
     * @param filePath The path to the JSON file.
     * @param contacts Output parameter for the loaded contacts.
     * @return true if successful, false otherwise.
     */
    static bool loadContacts(const QString &filePath, QVector<Contact> &contacts);

    /**
     * @brief Gets the default file path for contacts storage.
     * @return The full path to the contacts.json file next to the executable.
     */
    static QString getDefaultFilePath();

    /**
     * @brief Checks if the contacts file exists.
     * @param filePath The path to check.
     * @return true if the file exists, false otherwise.
     */
    static bool fileExists(const QString &filePath);

    /**
     * @brief Gets the last error message from file operations.
     * @return The last error message, or empty string if no error.
     */
    static QString lastError();

private:
    static QString s_lastError;
};

#endif // JSONSERIALIZER_H
