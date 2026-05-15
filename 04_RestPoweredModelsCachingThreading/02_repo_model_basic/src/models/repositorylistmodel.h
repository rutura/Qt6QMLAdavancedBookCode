#ifndef REPOSITORYLISTMODEL_H
#define REPOSITORYLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <qqml.h>

class GitHubService;
class Repository;

class RepositoryListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    // The model owns its GitHubService internally. We picked internal ownership
    // (over injection via a writable property) because it gives the model a
    // single, predictable place to wire signals and clean up replies on reset.
    Q_PROPERTY(GitHubService* service READ service CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FullNameRole,
        DescriptionRole,
        StarsRole,
        ForksRole,
        LanguageRole,
        UrlRole
    };

    explicit RepositoryListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    GitHubService* service() const { return m_service; }
    int count() const { return m_repos.size(); }

    Q_INVOKABLE void search(const QString &query);

signals:
    void countChanged();

private slots:
    void onSearchResultsReady(const QList<Repository*> &repositories);

private:
    void resetWith(const QList<Repository*> &repositories);

    GitHubService *m_service;
    QList<Repository*> m_repos;
};

#endif // REPOSITORYLISTMODEL_H
