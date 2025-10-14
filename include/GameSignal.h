#pragma once

#include <QMetaType>
#include <QString>
#include <QVariantMap>

class GameSignal
{
public:
    Q_GADGET
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QVariantMap payload READ payload WRITE setPayload)

public:
    GameSignal() = default;
    GameSignal(QString name, QVariantMap payload = {});

    const QString &name() const;
    void setName(const QString &name);

    QVariantMap payload() const;
    void setPayload(const QVariantMap &payload);

    bool isValid() const;
    QVariantMap toVariantMap() const;
    static GameSignal fromVariantMap(const QVariantMap &data);

private:
    QString m_name;
    QVariantMap m_payload;
};

Q_DECLARE_METATYPE(GameSignal)
