#include "abstractgameelement.h"

#include <QParallelAnimationGroup>
#include <QPropertyAnimation>
#include <QEasingCurve>
#include <QQmlEngine>
#include <QJSEngine>
#include <QJSValueList>
#include <QMetaProperty>
#include <QQuickWindow>
#include <QUrl>
#include <QVariant>
#include <QPointer>
#include <QKeyValueIterator>
#include <QJsonObject>
#include <QDebug>
#include <QQuickItem>

AbstractGameElement::AbstractGameElement(QQuickItem* parent)
    : QQuickItem(parent)
{
    setFlag(ItemHasContents, false); // purely logical default
    qRegisterMetaType<QJSValue>("QJSValue");
}

AbstractGameElement::~AbstractGameElement()
{
    // Ensure any running animations are cleaned up
    if (m_animGroup) {
        m_animGroup->stop();
        m_animGroup->deleteLater();
        m_animGroup = nullptr;
    }
}

void AbstractGameElement::componentComplete()
{
    QQuickItem::componentComplete();
}

void AbstractGameElement::setPropertyList(const QStringList& props)
{
    if (m_propertyList == props) return;
    m_propertyList = props;
    emit propertyListChanged();
}

void AbstractGameElement::setLoader(QObject* loader)
{
    if (m_loader == loader) return;
    m_loader = loader;
    emit loaderChanged();
}

void AbstractGameElement::setExecutionQueuePaused(bool paused)
{
    if (m_executionQueuePaused == paused) return;
    m_executionQueuePaused = paused;
    emit executionQueuePausedChanged();
}

// ----------------------- Helpers -----------------------

bool AbstractGameElement::isScalar(const QJSValue& v)
{
    return v.isBool() || v.isNumber() || v.isString() || v.isNull() || v.isUndefined();
}

QVariant AbstractGameElement::toVariant(const QJSValue& v)
{
    return v.toVariant();
}

QVariantMap AbstractGameElement::toVariantMap(const QJSValue& v)
{
    QVariantMap out;
    if (!v.isObject()) return out;
    QJsonObject obj = v.toVariant().toJsonObject();
    out = obj.toVariantMap();

    return out;
}

bool AbstractGameElement::hasWritableProperty(QObject* obj, const QByteArray& name, QVariant::Type* typeOut) const
{
    const QMetaObject* mo = obj->metaObject();
    int idx = mo->indexOfProperty(name.constData());
    if (idx < 0) return false;
    QMetaProperty mp = mo->property(idx);
    if (!mp.isWritable()) return false;
    if (typeOut) *typeOut = static_cast<QVariant::Type>(mp.typeId());
    return true;
}

QEasingCurve AbstractGameElement::easingFromQJSValue(const QJSValue& v) const
{
    // If it's a number, assume QEasingCurve::Type
    if (v.isNumber())
        return QEasingCurve(static_cast<QEasingCurve::Type>(v.toInt()));

    // If it's an object, accept .easing or .type
    if (v.isObject()) {
        QJSValue ev = v.property("easing");
        if (!ev.isUndefined())
            return easingFromQJSValue(ev);

        QJSValue tv = v.property("type");
        if (!tv.isUndefined())
            return easingFromQJSValue(tv);
    }

    // Strings like "linear", "InOutQuad", or "Easing.Linear"
    QString name = v.toString().trimmed();
    if (name.startsWith("Easing.", Qt::CaseInsensitive))
        name = name.mid(QStringLiteral("Easing.").size());
    name = name.toLower();

    static const QHash<QString, QEasingCurve::Type> map = {
                                                           {"linear", QEasingCurve::Linear},
                                                           {"inquad", QEasingCurve::InQuad}, {"outquad", QEasingCurve::OutQuad}, {"inoutquad", QEasingCurve::InOutQuad},
                                                           {"incubic", QEasingCurve::InCubic}, {"outcubic", QEasingCurve::OutCubic}, {"inoutcubic", QEasingCurve::InOutCubic},
                                                           {"inquart", QEasingCurve::InQuart}, {"outquart", QEasingCurve::OutQuart}, {"inoutquart", QEasingCurve::InOutQuart},
                                                           {"inquint", QEasingCurve::InQuint}, {"outquint", QEasingCurve::OutQuint}, {"inoutquint", QEasingCurve::InOutQuint},
                                                           {"insine", QEasingCurve::InSine}, {"outsine", QEasingCurve::OutSine}, {"inoutsine", QEasingCurve::InOutSine},
                                                           {"inexpo", QEasingCurve::InExpo}, {"outexpo", QEasingCurve::OutExpo}, {"inoutexpo", QEasingCurve::InOutExpo},
                                                           {"inelastic", QEasingCurve::InElastic}, {"outelastic", QEasingCurve::OutElastic}, {"inoutelastic", QEasingCurve::InOutElastic},
                                                           {"inback", QEasingCurve::InBack}, {"outback", QEasingCurve::OutBack}, {"inoutback", QEasingCurve::InOutBack},
                                                           {"inbounce", QEasingCurve::InBounce}, {"outbounce", QEasingCurve::OutBounce}, {"inoutbounce", QEasingCurve::InOutBounce},
                                                           };

    return QEasingCurve(map.value(name, QEasingCurve::InOutQuad));
}

// Core animation builder used by both tween methods
bool AbstractGameElement::buildAnimationsFromTo(const QVariantMap& from,
                                                const QVariantMap& to,
                                                int animTimeMs,
                                                const QEasingCurve& easing,
                                                QJSValue start_func,
                                                QJSValue end_func)
{
    if (m_propertyList.isEmpty()) return false;

    // Stop previous group if any
    if (m_animGroup) {
        m_animGroup->stop();
        m_animGroup->deleteLater();
        m_animGroup = nullptr;
    }
    m_animGroup = new QParallelAnimationGroup(this);

    // Set 'from' values first (if provided)
    for (const auto& propName : m_propertyList) {
        const QByteArray ba = propName.toUtf8();

        // Validate
        if (!hasWritableProperty(this, ba)) {
            qWarning() << "AbstractGameElement: property" << propName << "not found/writable on item";
            continue;
        }

        // If 'from' has a value for this property, set it now
        if (from.contains(propName)) {
            this->setProperty(ba.constData(), from.value(propName));
        } else if (!from.isEmpty()) {
            // Scalar-start case is handled by caller via repeating keys, so we only act on present keys
        }
    }

    // Optional start callback
    if (start_func.isCallable()) {
        QJSValueList args;
        args << qmlEngine(this)->newQObject(this);
        start_func.call(args);
    }

    // Build animations to 'to' values
    for (const auto& propName : m_propertyList) {
        const QByteArray ba = propName.toUtf8();
        if (!hasWritableProperty(this, ba)) continue;

        auto* anim = new QPropertyAnimation(this, ba, m_animGroup);
        anim->setDuration(animTimeMs);
        anim->setEasingCurve(easing);

        if (to.contains(propName)) {
            anim->setEndValue(to.value(propName));
        } else {
            // If no explicit 'to', animate back to current (which may have been captured)
            anim->setEndValue(this->property(ba.constData()));
        }
        m_animGroup->addAnimation(anim);
    }

    // End callback hookup
    connect(m_animGroup, &QParallelAnimationGroup::finished, this, [this, end_func]() mutable {
        if (end_func.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->newQObject(this);
            end_func.call(args);
        }
        emit tweenFinished();
        // auto-cleanup
        m_animGroup->deleteLater();
        m_animGroup = nullptr;
    });

    emit tweenStarted();
    m_animGroup->start(QAbstractAnimation::DeleteWhenStopped);
    return true;
}

// ----------------------- Public API -----------------------

bool AbstractGameElement::tweenPropertiesFrom(QJSValue start, int animTimeMs, QJSValue easingVal,
                                              QJSValue start_func, QJSValue end_func)
{
    QVariantMap from;
    if (isScalar(start)) {
        const auto v = toVariant(start);
        if (m_propertyList.isEmpty()) return false;              // still need list for scalar
        for (const auto& p : m_propertyList) from.insert(p, v);
    } else if (start.isObject()) {
        from = toVariantMap(start);
        if (m_propertyList.isEmpty()) setPropertyList(QStringList(from.keys()));
    } else {
        return false;
    }

    QVariantMap to;
    for (const auto& p : m_propertyList)
        to.insert(p, this->property(p.toUtf8().constData()));

    return buildAnimationsFromTo(from, to, animTimeMs, easingFromQJSValue(easingVal), start_func, end_func);
}

bool AbstractGameElement::tweenPropertiesTo(QJSValue end, int animTimeMs, QJSValue easingVal,
                                            QJSValue start_func, QJSValue end_func)
{
    QVariantMap to;
    if (isScalar(end)) {
        const auto v = toVariant(end);
        if (m_propertyList.isEmpty()) return false;              // still need list for scalar
        for (const auto& p : m_propertyList) to.insert(p, v);
    } else if (end.isObject()) {
        to = toVariantMap(end);
        if (m_propertyList.isEmpty()) setPropertyList(QStringList(to.keys()));
    } else {
        return false;
    }

    QVariantMap from; // animate from current
    return buildAnimationsFromTo(from, to, animTimeMs, easingFromQJSValue(easingVal), start_func, end_func);
}


// ----------------------- Particles -----------------------

bool AbstractGameElement::attachParticleSystem(QObject* particleSystem)
{
    if (!particleSystem) return false;
    if (m_particleSystems.contains(particleSystem)) return true;
    m_particleSystems.push_back(particleSystem);
    return true;
}

bool AbstractGameElement::detachParticleSystem(QJSValue which)
{
    if (which.isUndefined() || which.isNull()) {
        m_particleSystems.clear();
        return true;
    }
    QObject* obj = which.toQObject();
    if (!obj) return false;
    return m_particleSystems.removeOne(obj);
}

QObject* AbstractGameElement::getParticleSystem(int systemIdx) const
{
    if (systemIdx < 0 || systemIdx >= m_particleSystems.size()) return nullptr;
    return m_particleSystems.at(systemIdx);
}

QVariantList AbstractGameElement::listParticleSystems() const
{
    QVariantList list;
    list.reserve(m_particleSystems.size());
    for (auto* ps : m_particleSystems) {
        list << QVariant::fromValue(ps);
    }
    return list;
}

// Try to call "burst(int)" on the only attached system or its child emitters
bool AbstractGameElement::burstParticleSystem(int numParticles)
{
    if (m_particleSystems.size() != 1) return false;
    QObject* target = m_particleSystems.first();
    bool ok = false;

    // Try common names: burst(int), pulse(int)
    ok = QMetaObject::invokeMethod(target, "burst", Q_ARG(QVariant, QVariant(numParticles)));
    if (!ok) ok = QMetaObject::invokeMethod(target, "burst", Q_ARG(int, numParticles));
    if (!ok) ok = QMetaObject::invokeMethod(target, "pulse", Q_ARG(QVariant, QVariant(numParticles)));
    if (!ok) ok = QMetaObject::invokeMethod(target, "pulse", Q_ARG(int, numParticles));

    // If still not, try children with same methods (e.g., emitters under a ParticleSystem)
    if (!ok) {
        const auto children = target->findChildren<QObject*>();
        for (auto* c : children) {
            ok = QMetaObject::invokeMethod(c, "burst", Q_ARG(QVariant, QVariant(numParticles)))
            || QMetaObject::invokeMethod(c, "burst", Q_ARG(int, numParticles))
                || QMetaObject::invokeMethod(c, "pulse", Q_ARG(QVariant, QVariant(numParticles)))
                || QMetaObject::invokeMethod(c, "pulse", Q_ARG(int, numParticles));
            if (ok) break;
        }
    }
    return ok;
}

// ----------------------- Loader -----------------------

bool AbstractGameElement::loadSource(const QUrl& componentUrl)
{
    if (!m_loader) return false;
    // Expecting a QML Loader instance bound from QML: element.loader: loaderObject
    bool ok = m_loader->setProperty("source", componentUrl);
    if (!ok) {
        // Some apps use "sourceComponent" with QQmlComponent; here we only support 'source'
        qWarning() << "AbstractGameElement: failed to set Loader.source";
    }
    return ok;
}

// ----------------------- Global mapping -----------------------

QVariantMap AbstractGameElement::getGlobalPos() const
{
    QVariantMap out;
    QPointF scenePt = mapToScene(QPointF(0, 0));
    QPointF globalPt = scenePt;

    if (window()) {
        // map scene (window content) -> global screen coords
        globalPt = window()->mapToGlobal(scenePt.toPoint());
    }

    out["x"] = globalPt.x();
    out["y"] = globalPt.y();
    out["z"] = this->z();
    return out;
}

bool AbstractGameElement::setGlobalPos(qreal x, qreal y, qreal z)
{
    QPointF scenePt(x, y);
    if (window()) {
        scenePt = window()->mapFromGlobal(QPoint(x, y));
    }
    QPointF local = mapFromScene(scenePt);
    setX(local.x());
    setY(local.y());
    setZ(z);
    return true;
}

// ----------------------- Execution Queue -----------------------

QVariantList AbstractGameElement::getExecutionQueue() const
{
    QVariantList out;
    out.reserve(m_executionQueue.size());
    for (const auto& f : m_executionQueue) {
        out << QVariant::fromValue(f); // QJSValue is storable in QVariant
    }
    return out;
}

bool AbstractGameElement::addFunctionToExecutionQueue(QJSValue func_to_execute)
{
    if (!func_to_execute.isCallable()) return false;
    m_executionQueue.push_back(func_to_execute);
    return true;
}

void AbstractGameElement::beginProcessExecutionQueueTimed(int intervalMs)
{
    if (m_executionQueue.isEmpty()) {
        emit executionQueueEmpty();
        return;
    }
    setExecutionQueuePaused(false);
    emit executionQueueStarted();
    // kick off immediately (first item), then schedule the next with delay
    processNextQueueItemTimed(intervalMs);
}

void AbstractGameElement::processNextQueueItemTimed(int intervalMs)
{
    if (m_executionQueuePaused) return;
    if (m_executionQueue.isEmpty()) {
        emit executionQueueEmpty();
        return;
    }

    // Pop-front and execute
    QJSValue func = m_executionQueue.front();
    m_executionQueue.pop_front();
    if (func.isCallable()) {
        QJSValueList args;
        args << qmlEngine(this)->newQObject(this);
        func.call(args);
    }

    if (m_executionQueuePaused) return;
    if (m_executionQueue.isEmpty()) {
        emit executionQueueEmpty();
        return;
    }

    // Chain the next execution after the interval (single-shot each step)
    QPointer<AbstractGameElement> that(this);
    QTimer::singleShot(intervalMs, this, [that, intervalMs]() {
        if (!that) return;
        if (that->m_executionQueuePaused) return;
        that->processNextQueueItemTimed(intervalMs);
    });
}

void AbstractGameElement::pauseProcessExecutionQueueTimed()
{
    setExecutionQueuePaused(true);
}

void AbstractGameElement::beginProcessExecutionQueueAsync()
{
    if (m_executionQueue.isEmpty()) {
        emit executionQueueEmpty();
        return;
    }

    emit executionQueueStarted();
    // Copy then clear to ensure reentrancy safety
    const auto copy = m_executionQueue;
    m_executionQueue.clear();

    for (const auto& func : copy) {
        if (func.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->newQObject(this);
            func.call(args);
        }
    }
    emit executionQueueEmpty();
}

void AbstractGameElement::clearExecutionQueue()
{
    m_executionQueue.clear();
}

QVariantMap AbstractGameElement::serialize() const
{
    QVariantMap serialized;
    serialized.insert(QStringLiteral("objectName"), objectName());
    serialized.insert(QStringLiteral("className"), QString::fromLatin1(metaObject()->className()));
    serialized.insert(QStringLiteral("propertyList"), m_propertyList);

    QVariantMap properties;
    for (const QString& propName : m_propertyList) {
        const QByteArray propKey = propName.toUtf8();
        if (!hasWritableProperty(const_cast<AbstractGameElement*>(this), propKey))
            continue;
        const QVariant value = this->property(propKey.constData());
        if (value.isValid())
            properties.insert(propName, value);
    }

    serialized.insert(QStringLiteral("properties"), properties);

    return serialized;
}

bool AbstractGameElement::unserialize(const QVariantMap& data)
{
    if (data.contains(QStringLiteral("objectName")))
        setObjectName(data.value(QStringLiteral("objectName")).toString());

    if (data.contains(QStringLiteral("propertyList")))
        setPropertyList(data.value(QStringLiteral("propertyList")).toStringList());

    const QVariantMap properties = data.value(QStringLiteral("properties")).toMap();
    for (auto it = properties.constBegin(); it != properties.constEnd(); ++it) {
        const QByteArray propKey = it.key().toUtf8();
        if (!hasWritableProperty(this, propKey))
            continue;
        setProperty(propKey.constData(), it.value());
    }

    return true;
}
