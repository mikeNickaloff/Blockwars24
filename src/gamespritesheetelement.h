#ifndef GAMESPRITESHEETELEMENT_H
#define GAMESPRITESHEETELEMENT_H


#include "abstractgameelement.h"

#include <QImage>
#include <QPointer>
#include <QPropertyAnimation>
#include <QSGTexture>
#include <QSGSimpleTextureNode>
//#include <QtQml/qqmlregistration.h>

class GameSpriteSheetElement : public AbstractGameElement
{
    Q_OBJECT


    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sheetChanged)
    Q_PROPERTY(int frameWidth READ frameWidth WRITE setFrameWidth NOTIFY frameGeometryChanged)
    Q_PROPERTY(int frameHeight READ frameHeight WRITE setFrameHeight NOTIFY frameGeometryChanged)
    Q_PROPERTY(int columns READ columns NOTIFY sheetChanged)
    Q_PROPERTY(int rows READ rows NOTIFY sheetChanged)
    Q_PROPERTY(int frameCount READ frameCount NOTIFY sheetChanged)
    Q_PROPERTY(int currentFrame READ currentFrame WRITE setCurrentFrame NOTIFY currentFrameChanged)

public:
    explicit GameSpriteSheetElement(QQuickItem* parent = nullptr);
    ~GameSpriteSheetElement() override;

    // Sheet
    QUrl source() const { return m_source; }
    void setSource(const QUrl& url);

    Q_INVOKABLE bool loadSpriteSheet(const QUrl& path);  // accepts string or url from QML too

    // Frame geometry
    int frameWidth()  const { return m_frameWidth;  }
    int frameHeight() const { return m_frameHeight; }
    Q_INVOKABLE void setFrameWidth(int w);
    Q_INVOKABLE void setFrameHeight(int h);

    // Frame indexing
    int columns()     const { return m_columns; }
    int rows()        const { return m_rows; }
    int frameCount()  const { return m_frameCount; }

    int  currentFrame() const { return m_currentFrame; }
    Q_INVOKABLE void setCurrentFrame(int idx);
    Q_INVOKABLE int  getCurrentFrame() const { return m_currentFrame; }
    // keep a forgiving alias for the typo the spec listed
    Q_INVOKABLE int  getCurrentFame() const { return m_currentFrame; }

    // Animate frames
    Q_INVOKABLE bool interpolate(int startFrame, int endFrame, int durationMs,
                                 QJSValue easing = QJSValue(),
                                 QJSValue start_func = QJSValue(),
                                 QJSValue end_func = QJSValue());

signals:
    void sheetChanged();
    void frameGeometryChanged();
    void currentFrameChanged();

protected:
    QSGNode* updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData*) override;
    void releaseResources() override;

private:
    // helpers
    bool loadImageSync(const QUrl& url);
    void ensureTexture();
    void recomputeGrid();     // columns/rows/count from image & frame size
    QRectF frameRectPx(int frameIndex) const;
    QEasingCurve easingFromQJSValue(const QJSValue& v) const; // local (kept independent of base)

private:
    QUrl  m_source;
    QImage m_image;                 // CPU copy; texture created lazily
    QSGTexture* m_texture = nullptr;
    bool  m_dirtyTexture = false;

    int   m_frameWidth  = 0;        // px in source image
    int   m_frameHeight = 0;        // px in source image
    int   m_columns = 1;
    int   m_rows = 1;
    int   m_frameCount = 1;

    int   m_currentFrame = 0;

    QPropertyAnimation* m_frameAnim = nullptr;
};

#endif // GAMESPRITESHEETELEMEENT_H
