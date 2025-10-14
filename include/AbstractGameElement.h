#pragma once

#include <QList>
#include <QObject>
#include <QPointer>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

#include <functional>

class AbstractGameElement : public QObject
{
    Q_OBJECT

public:
    enum class TraversalDirective {
        Continue,
        SkipChildren,
        Stop,
    };
    Q_ENUM(TraversalDirective)

    Q_PROPERTY(QString elementId READ elementId WRITE setElementId NOTIFY elementIdChanged FINAL)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(bool blocked READ isBlocked WRITE setBlocked NOTIFY blockedChanged FINAL)

    explicit AbstractGameElement(const QString &name = QString(), QObject *parent = nullptr);
    ~AbstractGameElement() override = default;

    Q_INVOKABLE QString elementId() const;
    Q_INVOKABLE void setElementId(const QString &id);
    Q_INVOKABLE QString name() const;
    Q_INVOKABLE void setName(const QString &name);

    AbstractGameElement *parentElement() const;
    QList<AbstractGameElement *> childElements() const;
    Q_INVOKABLE QList<QObject *> qmlChildElements() const;
    Q_INVOKABLE int childCount() const;

    virtual bool addChildElement(AbstractGameElement *child);
    virtual bool removeChildElement(AbstractGameElement *child);

    Q_INVOKABLE bool isBlocked() const;
    Q_INVOKABLE void setBlocked(bool blocked);

    Q_INVOKABLE QVariantMap serialize() const;
    Q_INVOKABLE QVariantList serializeChildren() const;
    virtual void deserialize(const QVariantMap &data);

    void forEachDescendant(const std::function<TraversalDirective(AbstractGameElement *)> &visitor) const;
    bool isDescendantOf(const AbstractGameElement *candidate) const;

signals:
    void elementIdChanged();
    void nameChanged();
    void blockedChanged();
    void childAdded(AbstractGameElement *child);
    void childRemoved(AbstractGameElement *child);
    void childrenChanged();

protected:
    void setParentElement(AbstractGameElement *parent);

private:
    QString m_elementId;
    QString m_name;
    QVector<QPointer<AbstractGameElement>> m_children;
    AbstractGameElement *m_parentElement = nullptr;
    bool m_blocked = false;
};
