#include "gamespritesheetelement.h"
#include "abstractgameelement.h"
#include <QQuickWindow>
#include <QQmlEngine>
#include <QQmlFile>
#include <QJSValueIterator>
#include <QUrl>
#include <QDebug>

GameSpriteSheetElement::GameSpriteSheetElement(QQuickItem* parent)
    : AbstractGameElement(parent)
{
    setFlag(ItemHasContents, true);
    // Reasonable default: if the user scales the item, visuals scale,
    // but source frame size stays in source pixels.
}

GameSpriteSheetElement::~GameSpriteSheetElement()
{
    if (m_frameAnim) {
        m_frameAnim->stop();
        m_frameAnim->deleteLater();
    }
    releaseResources();
}

void GameSpriteSheetElement::releaseResources()
{
    if (m_texture) {
        delete m_texture;
        m_texture = nullptr;
    }
}

void GameSpriteSheetElement::setSource(const QUrl& url)
{
    if (m_source == url)
        return;
    if (!loadImageSync(url))
        return; // keep old if load failed

    m_source = url;
    m_dirtyTexture = true;

    // Auto-derive frame size to "whole image" if not set yet
    if (m_frameWidth <= 0)  m_frameWidth  = m_image.width();
    if (m_frameHeight <= 0) m_frameHeight = m_image.height();
    recomputeGrid();

    // Default implicit size to one frame
    setImplicitWidth(m_frameWidth);
    setImplicitHeight(m_frameHeight);

    emit sheetChanged();
    update();
}

bool GameSpriteSheetElement::loadSpriteSheet(const QUrl& path)
{
    // Allow string or URL from QML
    QUrl u = path;
    if (!u.isValid()) {
        // If QML passed a string, it converts implicitly; still check
        u = QUrl(QString(path.toString()));
    }
    setSource(u);
    return !m_image.isNull();
}

bool GameSpriteSheetElement::loadImageSync(const QUrl& url)
{
    QUrl abs = url;
    if (!abs.isValid()) return false;

    // Allow raw strings like "sprites.png" (relative to qml) too:
    if (!abs.scheme().isEmpty()) {
        // ok
    } else {
        abs = QUrl::fromUserInput(url.toString());
    }

    QString local = QQmlFile::urlToLocalFileOrQrc(abs);
    QImage img;
    if (!img.load(local)) {
        qWarning() << "GameSpriteSheetElement: failed to load" << local;
        return false;
    }
    m_image = img.convertToFormat(QImage::Format_RGBA8888);
    return true;
}

void GameSpriteSheetElement::recomputeGrid()
{
    if (m_image.isNull()) {
        m_columns = m_rows = 1;
        m_frameCount = 1;
        m_currentFrame = 0;
        return;
    }

    int iw = m_image.width();
    int ih = m_image.height();

    m_columns = (m_frameWidth  > 0) ? qMax(1, iw / m_frameWidth)  : 1;
    m_rows    = (m_frameHeight > 0) ? qMax(1, ih / m_frameHeight) : 1;
    m_frameCount = qMax(1, m_columns * m_rows);

    if (m_currentFrame >= m_frameCount)
        m_currentFrame = m_frameCount - 1;
}

void GameSpriteSheetElement::setFrameWidth(int w)
{
    if (w <= 0 || w == m_frameWidth) return;
    m_frameWidth = w;
    recomputeGrid();
    emit frameGeometryChanged();
    update();
}

void GameSpriteSheetElement::setFrameHeight(int h)
{
    if (h <= 0 || h == m_frameHeight) return;
    m_frameHeight = h;
    recomputeGrid();
    emit frameGeometryChanged();
    update();
}

void GameSpriteSheetElement::setCurrentFrame(int idx)
{
    if (m_frameCount <= 0) return;
    idx = qBound(0, idx, m_frameCount - 1);
    if (idx == m_currentFrame) return;
    m_currentFrame = idx;
    emit currentFrameChanged();
    update();
}

QRectF GameSpriteSheetElement::frameRectPx(int frameIndex) const
{
    if (m_frameCount <= 0 || m_frameWidth <= 0 || m_frameHeight <= 0)
        return QRectF(0, 0, 0, 0);

    int col = frameIndex % m_columns;
    int row = frameIndex / m_columns;

    qreal sx = col * m_frameWidth;
    qreal sy = row * m_frameHeight;
    return QRectF(sx, sy, m_frameWidth, m_frameHeight);
}

QEasingCurve GameSpriteSheetElement::easingFromQJSValue(const QJSValue& v) const
{
    // Accept:
    //  - number (QEasingCurve::Type)
    //  - { easing: Easing.Linear } or { type: "InOutQuad" }
    //  - "linear", "inoutquad", "Easing.OutCubic"
    if (v.isNumber())
        return QEasingCurve(static_cast<QEasingCurve::Type>(v.toInt()));

    if (v.isObject()) {
        QJSValue ev = v.property("easing");
        if (!ev.isUndefined())
            return easingFromQJSValue(ev);
        QJSValue tv = v.property("type");
        if (!tv.isUndefined())
            return easingFromQJSValue(tv);
    }

    QString name = v.toString().trimmed();
    if (name.startsWith(u"Easing.", Qt::CaseInsensitive))
        name = name.mid(7);
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

bool GameSpriteSheetElement::interpolate(int startFrame, int endFrame, int durationMs,
                                         QJSValue easing, QJSValue start_func, QJSValue end_func)
{
    if (m_frameCount <= 0) return false;

    startFrame = qBound(0, startFrame, m_frameCount - 1);
    endFrame   = qBound(0, endFrame,   m_frameCount - 1);

    if (m_frameAnim) {
        m_frameAnim->stop();
        m_frameAnim->deleteLater();
        m_frameAnim = nullptr;
    }

    // Call start callback
    if (start_func.isCallable()) {
        QJSValueList args; args << qmlEngine(this)->newQObject(this);
        start_func.call(args);
    }

    m_frameAnim = new QPropertyAnimation(this, "currentFrame", this);
    m_frameAnim->setStartValue(startFrame);
    m_frameAnim->setEndValue(endFrame);
    m_frameAnim->setDuration(qMax(0, durationMs));
    m_frameAnim->setEasingCurve(easingFromQJSValue(easing));

    connect(m_frameAnim, &QPropertyAnimation::finished, this, [this, end_func]() mutable {
        if (end_func.isCallable()) {
            QJSValueList args; args << qmlEngine(this)->newQObject(this);
            end_func.call(args);
        }
        m_frameAnim->deleteLater();
        m_frameAnim = nullptr;
    });

    // Ensure initial pose
    setCurrentFrame(startFrame);
    m_frameAnim->start(QAbstractAnimation::DeleteWhenStopped);
    return true;
}

QSGNode* GameSpriteSheetElement::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData*)
{
    if (m_image.isNull() || m_frameWidth <= 0 || m_frameHeight <= 0) {
        delete oldNode;
        return nullptr;
    }

    QSGSimpleTextureNode* node = static_cast<QSGSimpleTextureNode*>(oldNode);
    if (!node) {
        node = new QSGSimpleTextureNode();
    }

    ensureTexture();
    if (!m_texture) {
        delete node;
        return nullptr;
    }

    node->setTexture(m_texture);
    node->setFiltering(QSGTexture::Linear);
    node->setRect(0, 0, width(), height());           // draw area in item coords
    node->setSourceRect(frameRectPx(m_currentFrame)); // source rect in texture pixels

    return node;
}

void GameSpriteSheetElement::ensureTexture()
{
    if (!window()) return;

    if (!m_texture || m_dirtyTexture) {
        if (m_texture) {
            delete m_texture;
            m_texture = nullptr;
        }
        if (!m_image.isNull()) {
            m_texture = window()->createTextureFromImage(m_image);
            m_dirtyTexture = false;
        }
    }
}
