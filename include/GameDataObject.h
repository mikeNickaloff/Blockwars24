#pragma once

#include <QString>
#include <QVariant>
#include <QVariantMap>

class GameDataObject
{
public:
    GameDataObject() = default;
    explicit GameDataObject(QVariantMap data);

    bool isValid() const;
    const QVariantMap &data() const;
    QVariantMap &data();

    QVariant value(const QString &key, const QVariant &defaultValue = {}) const;
    void setValue(const QString &key, const QVariant &value);
    bool contains(const QString &key) const;

private:
    QVariantMap m_data;
};
