#ifndef GAMEDATAOBJECT_H
#define GAMEDATAOBJECT_H

#include <QObject>
#include <QVariant>
#include <QVariantList>

#include <QtQml/qqmlregistration.h>

class GameDataObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant data READ data WRITE setData NOTIFY dataChanged)

    QML_ELEMENT

public:
    explicit GameDataObject(QObject* parent = nullptr);

    QVariant data() const;
    void setData(const QVariant& data);

    QVariantList asList() const;

signals:
    void dataChanged();

private:
    QVariant m_data;
};

#endif // GAMEDATAOBJECT_H
