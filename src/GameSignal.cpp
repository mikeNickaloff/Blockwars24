#include "GameSignal.h"

GameSignal::GameSignal(QString name, QVariantMap payload)
    : m_name(std::move(name))
    , m_payload(std::move(payload))
{
}

const QString &GameSignal::name() const
{
    return m_name;
}

void GameSignal::setName(const QString &name)
{
    m_name = name;
}

QVariantMap GameSignal::payload() const
{
    return m_payload;
}

void GameSignal::setPayload(const QVariantMap &payload)
{
    m_payload = payload;
}

bool GameSignal::isValid() const
{
    return !m_name.isEmpty();
}

QVariantMap GameSignal::toVariantMap() const
{
    QVariantMap data;
    data.insert(QStringLiteral("name"), m_name);
    data.insert(QStringLiteral("payload"), m_payload);
    return data;
}

GameSignal GameSignal::fromVariantMap(const QVariantMap &data)
{
    return GameSignal(data.value(QStringLiteral("name")).toString(), data.value(QStringLiteral("payload")).toMap());
}
