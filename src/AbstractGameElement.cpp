#include "AbstractGameElement.h"

#include <QUuid>

#include <algorithm>

namespace {
constexpr auto CHILDREN_KEY = "children";
constexpr auto ID_KEY = "id";
constexpr auto NAME_KEY = "name";
constexpr auto BLOCKED_KEY = "blocked";
}

AbstractGameElement::AbstractGameElement(const QString &name, QObject *parent)
    : QObject(parent)
    , m_elementId(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , m_name(name)
{
    setObjectName(name);
}

QString AbstractGameElement::elementId() const
{
    return m_elementId;
}

void AbstractGameElement::setElementId(const QString &id)
{
    if (id.isEmpty() || m_elementId == id) {
        return;
    }
    m_elementId = id;
    emit elementIdChanged();
}

QString AbstractGameElement::name() const
{
    return m_name;
}

void AbstractGameElement::setName(const QString &name)
{
    if (m_name == name) {
        return;
    }
    m_name = name;
    setObjectName(name);
    emit nameChanged();
}

AbstractGameElement *AbstractGameElement::parentElement() const
{
    return m_parentElement;
}

QList<AbstractGameElement *> AbstractGameElement::childElements() const
{
    QList<AbstractGameElement *> result;
    result.reserve(m_children.size());
    for (const auto &child : m_children) {
        if (child) {
            result.append(child.data());
        }
    }
    return result;
}

QList<QObject *> AbstractGameElement::qmlChildElements() const
{
    QList<QObject *> result;
    result.reserve(m_children.size());
    for (const auto &child : m_children) {
        if (child) {
            result.append(child.data());
        }
    }
    return result;
}

int AbstractGameElement::childCount() const
{
    return childElements().size();
}

bool AbstractGameElement::addChildElement(AbstractGameElement *child)
{
    if (!child || child == this || isDescendantOf(child) || child->isDescendantOf(this)) {
        return false;
    }

    const auto alreadyContains = std::any_of(m_children.cbegin(), m_children.cend(), [child](const QPointer<AbstractGameElement> &existing) {
        return existing == child;
    });
    if (alreadyContains) {
        return true;
    }

    if (child->parentElement()) {
        child->parentElement()->removeChildElement(child);
    }

    child->setParent(this);
    child->setParentElement(this);
    m_children.append(QPointer<AbstractGameElement>(child));

    emit childAdded(child);
    emit childrenChanged();
    return true;
}

bool AbstractGameElement::removeChildElement(AbstractGameElement *child)
{
    if (!child) {
        return false;
    }

    const auto it = std::find_if(m_children.begin(), m_children.end(), [child](const QPointer<AbstractGameElement> &existing) {
        return existing == child;
    });
    if (it == m_children.end()) {
        return false;
    }

    QPointer<AbstractGameElement> storedChild = *it;
    m_children.erase(it);

    if (storedChild) {
        storedChild->setParentElement(nullptr);
        storedChild->setParent(nullptr);
        emit childRemoved(storedChild);
    }

    emit childrenChanged();
    return true;
}

bool AbstractGameElement::isBlocked() const
{
    return m_blocked;
}

void AbstractGameElement::setBlocked(bool blocked)
{
    if (m_blocked == blocked) {
        return;
    }

    m_blocked = blocked;
    emit blockedChanged();
}

QVariantMap AbstractGameElement::serialize() const
{
    QVariantMap data;
    data.insert(ID_KEY, m_elementId);
    data.insert(NAME_KEY, m_name);
    data.insert(BLOCKED_KEY, m_blocked);

    data.insert(CHILDREN_KEY, serializeChildren());

    return data;
}

QVariantList AbstractGameElement::serializeChildren() const
{
    QVariantList childrenData;
    childrenData.reserve(m_children.size());
    for (const auto &child : m_children) {
        if (!child) {
            continue;
        }
        childrenData.append(child->serialize());
    }
    return childrenData;
}

void AbstractGameElement::deserialize(const QVariantMap &data)
{
    if (data.contains(ID_KEY)) {
        setElementId(data.value(ID_KEY).toString());
    }

    if (data.contains(NAME_KEY)) {
        setName(data.value(NAME_KEY).toString());
    }

    if (data.contains(BLOCKED_KEY)) {
        setBlocked(data.value(BLOCKED_KEY).toBool());
    }
}

void AbstractGameElement::forEachDescendant(const std::function<TraversalDirective(AbstractGameElement *)> &visitor) const
{
    if (!visitor) {
        return;
    }

    QList<AbstractGameElement *> pending = childElements();
    while (!pending.isEmpty()) {
        AbstractGameElement *current = pending.takeFirst();
        if (!current) {
            continue;
        }

        const auto decision = visitor(current);
        if (decision == TraversalDirective::Stop) {
            return;
        }

        if (decision == TraversalDirective::SkipChildren) {
            continue;
        }

        const auto nextChildren = current->childElements();
        for (auto *child : nextChildren) {
            if (child) {
                pending.append(child);
            }
        }
    }
}

bool AbstractGameElement::isDescendantOf(const AbstractGameElement *candidate) const
{
    if (!candidate) {
        return false;
    }

    const AbstractGameElement *current = parentElement();
    while (current) {
        if (current == candidate) {
            return true;
        }
        current = current->parentElement();
    }

    return false;
}

void AbstractGameElement::setParentElement(AbstractGameElement *parent)
{
    m_parentElement = parent;
}
