#ifndef GAMESIGNAL_H
#define GAMESIGNAL_H

#include <QObject>
#include <QVariantList>

#include <QtQml/qqmlregistration.h>

class GameSignal : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QVariantList arguments READ arguments WRITE setArguments NOTIFY argumentsChanged)

    QML_ELEMENT

public:
    explicit GameSignal(QObject* parent = nullptr);
    GameSignal(const QString& name, const QVariantList& arguments, QObject* parent = nullptr);

    QString name() const;
    void setName(const QString& name);

    QVariantList arguments() const;
    void setArguments(const QVariantList& arguments);

signals:
    void nameChanged();
    void argumentsChanged();

private:
    QString m_name;
    QVariantList m_arguments;
};

#endif // GAMESIGNAL_H
