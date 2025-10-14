#include "GameDataObject.h"

GameDataObject::GameDataObject(QVariantMap data)
    : m_data(std::move(data))
{
}

bool GameDataObject::isValid() const
{
    return !m_data.isEmpty();
}

const QVariantMap &GameDataObject::data() const
{
    return m_data;
}

QVariantMap &GameDataObject::data()
{
    return m_data;
}

QVariant GameDataObject::value(const QString &key, const QVariant &defaultValue) const
{
    return m_data.value(key, defaultValue);
}

void GameDataObject::setValue(const QString &key, const QVariant &value)
{
    m_data.insert(key, value);
}

bool GameDataObject::contains(const QString &key) const
{
    return m_data.contains(key);
}
