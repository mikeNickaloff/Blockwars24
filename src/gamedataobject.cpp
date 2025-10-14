#include "gamedataobject.h"

GameDataObject::GameDataObject(QObject* parent)
    : QObject(parent)
{
}

QVariant GameDataObject::data() const
{
    return m_data;
}

void GameDataObject::setData(const QVariant& data)
{
    if (m_data == data)
        return;
    m_data = data;
    emit dataChanged();
}

QVariantList GameDataObject::asList() const
{
    if (m_data.canConvert<QVariantList>())
        return m_data.toList();
    return {};
}
