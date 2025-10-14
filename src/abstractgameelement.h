#ifndef ABSTRACTGAMEELEMENT_H
#define ABSTRACTGAMEELEMENT_H
#include <QQuickItem>
#include <QVariant>
#include <QVariantMap>
#include <QJSValue>
#include <QList>
#include <QTimer>
#include <QStringList>

/* #include <QtQml/qqmlregistration.h> */



class QParallelAnimationGroup;

class AbstractGameElement : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QStringList propertyList READ propertyList WRITE setPropertyList NOTIFY propertyListChanged)
    Q_PROPERTY(QObject* loader READ loader WRITE setLoader NOTIFY loaderChanged)
    Q_PROPERTY(bool executionQueuePaused READ executionQueuePaused WRITE setExecutionQueuePaused NOTIFY executionQueuePausedChanged)

public:
    explicit AbstractGameElement(QQuickItem* parent = nullptr);
    ~AbstractGameElement() override;

    // propertyList
    const QStringList& propertyList() const { return m_propertyList; }
    void setPropertyList(const QStringList& props);

    // associated Loader (from QML)
    QObject* loader() const { return m_loader; }
    void setLoader(QObject* loader);

    // Execution Queue paused flag
    bool executionQueuePaused() const { return m_executionQueuePaused; }
    void setExecutionQueuePaused(bool paused);

    // Tweens
    Q_INVOKABLE bool tweenPropertiesFrom(QJSValue start, int animTimeMs, QJSValue easing,
                                         QJSValue start_func = QJSValue(), QJSValue end_func = QJSValue());

    Q_INVOKABLE bool tweenPropertiesTo(QJSValue end, int animTimeMs, QJSValue easing,
                                       QJSValue start_func = QJSValue(), QJSValue end_func = QJSValue());

    // Particles
    Q_INVOKABLE bool attachParticleSystem(QObject* particleSystem);
    Q_INVOKABLE bool detachParticleSystem(QJSValue which = QJSValue()); // undefined/null => all
    Q_INVOKABLE QObject* getParticleSystem(int systemIdx) const;
    Q_INVOKABLE QVariantList listParticleSystems() const;
    Q_INVOKABLE bool burstParticleSystem(int numParticles);

    // Loader
    Q_INVOKABLE bool loadSource(const QUrl& componentUrl);

    // Global position helpers
    Q_INVOKABLE QVariantMap getGlobalPos() const; // { x, y, z }
    Q_INVOKABLE bool setGlobalPos(qreal x, qreal y, qreal z);

    // Execution queue (for "then" chaining)
    Q_INVOKABLE QVariantList getExecutionQueue() const; // returns list of QJSValue (functions)
    Q_INVOKABLE bool addFunctionToExecutionQueue(QJSValue func_to_execute);
    Q_INVOKABLE void beginProcessExecutionQueueTimed(int intervalMs);
    Q_INVOKABLE void pauseProcessExecutionQueueTimed(); // toggles pause=true
    Q_INVOKABLE void beginProcessExecutionQueueAsync();
    Q_INVOKABLE void clearExecutionQueue();

    Q_INVOKABLE virtual QVariantMap serialize() const;
    Q_INVOKABLE virtual bool unserialize(const QVariantMap& data);

signals:
    void propertyListChanged();
    void loaderChanged();
    void executionQueuePausedChanged();

    // Optional niceties:
    void tweenStarted();
    void tweenFinished();
    void executionQueueStarted();
    void executionQueueEmpty();

protected:
    void componentComplete() override;

private:
    // helpers
    static bool isScalar(const QJSValue& v);
    static QVariant toVariant(const QJSValue& v);
    static QVariantMap toVariantMap(const QJSValue& v);
    QEasingCurve easingFromQJSValue(const QJSValue& easing) const;
    bool hasWritableProperty(QObject* obj, const QByteArray& name, QVariant::Type* typeOut = nullptr) const;

    bool buildAnimationsFromTo(const QVariantMap& from, const QVariantMap& to,
                               int animTimeMs, const QEasingCurve& easing,
                               QJSValue start_func, QJSValue end_func);

    void processNextQueueItemTimed(int intervalMs);

private:
    QStringList m_propertyList;
    QObject* m_loader = nullptr;

    QList<QObject*> m_particleSystems;

    // animation
    QParallelAnimationGroup* m_animGroup = nullptr;

    // execution queue
    QList<QJSValue> m_executionQueue;
    bool m_executionQueuePaused = false;
};

#endif // ABSTRACTGAMEELEMENT_H
