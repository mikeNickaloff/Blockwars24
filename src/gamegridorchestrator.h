#ifndef GAMEGRIDORCHESTRATOR_H
#define GAMEGRIDORCHESTRATOR_H

#include "abstractgameelement.h"
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

class GameGridOrchestrator : public AbstractGameElement
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount WRITE setRowCount NOTIFY rowCountChanged)
    Q_PROPERTY(int columnCount READ columnCount WRITE setColumnCount NOTIFY columnCountChanged)
    Q_PROPERTY(int fillDirection READ fillDirection WRITE setFillDirection NOTIFY fillDirectionChanged)
    Q_PROPERTY(quint32 spawnSeed READ spawnSeed WRITE setSpawnSeed NOTIFY spawnSeedChanged)

public:
    explicit GameGridOrchestrator(QQuickItem *parent = nullptr);

    int rowCount() const { return m_rowCount; }
    void setRowCount(int value);

    int columnCount() const { return m_columnCount; }
    void setColumnCount(int value);

    int fillDirection() const { return m_fillDirection; }
    void setFillDirection(int value);

    quint32 spawnSeed() const { return m_seed; }
    void setSpawnSeed(quint32 value);

    Q_INVOKABLE QVariantList prepareFill(const QVariantList &matrixVariant);
    Q_INVOKABLE QVariantList compactionMoves(const QVariantList &matrixVariant);
    Q_INVOKABLE QVariantList detectMatches(const QVariantList &matrixVariant) const;
    Q_INVOKABLE QVariantMap spawnSpecFor(const QVariantList &matrixVariant, int row, int column);
    Q_INVOKABLE void resetPool();

signals:
    void rowCountChanged();
    void columnCountChanged();
    void fillDirectionChanged();
    void spawnSeedChanged();

private:
    struct ColorEntry {
        QString key;
        QString hex;
    };

    QVector<ColorEntry> m_palette;
    QVector<ColorEntry> m_spawnPool;
    int m_rowCount = 6;
    int m_columnCount = 6;
    int m_fillDirection = 1;
    quint32 m_seed = 1u;
    int m_poolIndex = 0;

    void rebuildPool();

    QVector<QVector<QString>> toMatrix(const QVariantList &matrixVariant) const;
    QVariantList prepareFillInternal(QVector<QVector<QString>> &matrix);
    QVariantList compactionMovesInternal(QVector<QVector<QString>> &matrix) const;
    QVariantList detectMatchesInternal(const QVector<QVector<QString>> &matrix) const;
    ColorEntry chooseFromPool(QVector<QVector<QString>> &matrix, int row, int column);
    bool wouldCreateMatch(const QVector<QVector<QString>> &matrix, int row, int column, const QString &colorKey) const;
};

#endif // GAMEGRIDORCHESTRATOR_H
