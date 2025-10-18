#include "gamegridorchestrator.h"
#include <QSet>
#include <algorithm>

namespace {
static const quint32 kLcgMultiplier = 1664525u;
static const quint32 kLcgIncrement = 1013904223u;
static const quint32 kLcgModulus = 0xFFFFFFFFu;
static const int kDefaultHp = 10;
}

GameGridOrchestrator::GameGridOrchestrator(QQuickItem *parent)
    : AbstractGameElement(parent)
{
    m_palette = {
        { QStringLiteral("red"), QStringLiteral("#ef4444") },
        { QStringLiteral("green"), QStringLiteral("#22c55e") },
        { QStringLiteral("blue"), QStringLiteral("#3b82f6") },
        { QStringLiteral("yellow"), QStringLiteral("#facc15") }
    };
    rebuildPool();
}

void GameGridOrchestrator::setRowCount(int value)
{
    if (m_rowCount == value || value <= 0)
        return;
    m_rowCount = value;
    rebuildPool();
    emit rowCountChanged();
}

void GameGridOrchestrator::setColumnCount(int value)
{
    if (m_columnCount == value || value <= 0)
        return;
    m_columnCount = value;
    rebuildPool();
    emit columnCountChanged();
}

void GameGridOrchestrator::setFillDirection(int value)
{
    const int normalized = value >= 0 ? 1 : -1;
    if (m_fillDirection == normalized)
        return;
    m_fillDirection = normalized;
    emit fillDirectionChanged();
}

void GameGridOrchestrator::setSpawnSeed(quint32 value)
{
    if (value == 0)
        value = 1u;
    if (m_seed == value)
        return;
    m_seed = value;
    rebuildPool();
    emit spawnSeedChanged();
}

QVariantList GameGridOrchestrator::prepareFill(const QVariantList &matrixVariant)
{
    auto matrix = toMatrix(matrixVariant);
    return prepareFillInternal(matrix);
}

QVariantList GameGridOrchestrator::compactionMoves(const QVariantList &matrixVariant)
{
    auto matrix = toMatrix(matrixVariant);
    return compactionMovesInternal(matrix);
}

QVariantList GameGridOrchestrator::detectMatches(const QVariantList &matrixVariant) const
{
    const auto matrix = toMatrix(matrixVariant);
    return detectMatchesInternal(matrix);
}

QVariantMap GameGridOrchestrator::spawnSpecFor(const QVariantList &matrixVariant, int row, int column)
{
    auto matrix = toMatrix(matrixVariant);
    const ColorEntry entry = chooseFromPool(matrix, row, column);

    QVariantMap spec;
    spec.insert(QStringLiteral("colorKey"), entry.key);
    spec.insert(QStringLiteral("colorHex"), entry.hex);
    spec.insert(QStringLiteral("hp"), kDefaultHp);
    return spec;
}

void GameGridOrchestrator::resetPool()
{
    rebuildPool();
}

void GameGridOrchestrator::rebuildPool()
{
    m_spawnPool.clear();
    m_poolIndex = 0;
    if (m_palette.isEmpty())
        return;

    const int total = qMax(m_rowCount * m_columnCount * 4, m_palette.size());
    m_spawnPool.reserve(total);
    quint32 localSeed = m_seed;
    for (int i = 0; i < total; ++i) {
        localSeed = (localSeed * kLcgMultiplier + kLcgIncrement) & kLcgModulus;
        const double value = static_cast<double>(localSeed) / static_cast<double>(kLcgModulus);
        const int index = static_cast<int>(value * m_palette.size()) % m_palette.size();
        m_spawnPool.append(m_palette.at(index));
    }
}

QVector<QVector<QString>> GameGridOrchestrator::toMatrix(const QVariantList &matrixVariant) const
{
    QVector<QVector<QString>> matrix(m_rowCount, QVector<QString>(m_columnCount));
    const int rows = std::min<int>(matrixVariant.size(), m_rowCount);
    for (int r = 0; r < rows; ++r) {
        const QVariantList rowList = matrixVariant.at(r).toList();
        const int columns = std::min<int>(rowList.size(), m_columnCount);
        for (int c = 0; c < columns; ++c) {
            matrix[r][c] = rowList.at(c).toString();
        }
    }
    return matrix;
}

QVariantList GameGridOrchestrator::prepareFillInternal(QVector<QVector<QString>> &matrix)
{
    QVariantList instructions;
    if (m_rowCount <= 0 || m_columnCount <= 0)
        return instructions;

    const int spawnRow = (m_fillDirection >= 0) ? -1 : m_rowCount;
    if (m_fillDirection >= 0) {
        for (int column = 0; column < m_columnCount; ++column) {
            for (int row = m_rowCount - 1; row >= 0; --row) {
                if (!matrix[row][column].isEmpty())
                    continue;
                const ColorEntry entry = chooseFromPool(matrix, row, column);
                matrix[row][column] = entry.key;

                QVariantMap spec;
                spec.insert(QStringLiteral("colorKey"), entry.key);
                spec.insert(QStringLiteral("colorHex"), entry.hex);
                spec.insert(QStringLiteral("hp"), kDefaultHp);

                QVariantMap op;
                op.insert(QStringLiteral("column"), column);
                op.insert(QStringLiteral("targetRow"), row);
                op.insert(QStringLiteral("spawnRow"), spawnRow);
                op.insert(QStringLiteral("spec"), spec);
                instructions.append(op);
            }
        }
    } else {
        for (int column = 0; column < m_columnCount; ++column) {
            for (int row = 0; row < m_rowCount; ++row) {
                if (!matrix[row][column].isEmpty())
                    continue;
                const ColorEntry entry = chooseFromPool(matrix, row, column);
                matrix[row][column] = entry.key;

                QVariantMap spec;
                spec.insert(QStringLiteral("colorKey"), entry.key);
                spec.insert(QStringLiteral("colorHex"), entry.hex);
                spec.insert(QStringLiteral("hp"), kDefaultHp);

                QVariantMap op;
                op.insert(QStringLiteral("column"), column);
                op.insert(QStringLiteral("targetRow"), row);
                op.insert(QStringLiteral("spawnRow"), spawnRow);
                op.insert(QStringLiteral("spec"), spec);
                instructions.append(op);
            }
        }
    }

    return instructions;
}

QVariantList GameGridOrchestrator::compactionMovesInternal(QVector<QVector<QString>> &matrix) const
{
    QVariantList moves;
    if (m_rowCount <= 0 || m_columnCount <= 0)
        return moves;

    if (m_fillDirection >= 0) {
        for (int column = 0; column < m_columnCount; ++column) {
            int writeRow = m_rowCount - 1;
            for (int row = m_rowCount - 1; row >= 0; --row) {
                const QString &value = matrix[row][column];
                if (value.isEmpty())
                    continue;
                if (row != writeRow) {
                    QVariantMap move;
                    move.insert(QStringLiteral("fromRow"), row);
                    move.insert(QStringLiteral("toRow"), writeRow);
                    move.insert(QStringLiteral("column"), column);
                    moves.append(move);
                    matrix[writeRow][column] = value;
                    matrix[row][column].clear();
                }
                --writeRow;
            }
            for (int row = writeRow; row >= 0; --row)
                matrix[row][column].clear();
        }
    } else {
        for (int column = 0; column < m_columnCount; ++column) {
            int writeRow = 0;
            for (int row = 0; row < m_rowCount; ++row) {
                const QString &value = matrix[row][column];
                if (value.isEmpty())
                    continue;
                if (row != writeRow) {
                    QVariantMap move;
                    move.insert(QStringLiteral("fromRow"), row);
                    move.insert(QStringLiteral("toRow"), writeRow);
                    move.insert(QStringLiteral("column"), column);
                    moves.append(move);
                    matrix[writeRow][column] = value;
                    matrix[row][column].clear();
                }
                ++writeRow;
            }
            for (int row = writeRow; row < m_rowCount; ++row)
                matrix[row][column].clear();
        }
    }

    return moves;
}

QVariantList GameGridOrchestrator::detectMatchesInternal(const QVector<QVector<QString>> &matrix) const
{
    QVariantList matches;
    if (m_rowCount <= 0 || m_columnCount <= 0)
        return matches;

    QSet<QString> seen;

    // Horizontal runs
    for (int row = 0; row < m_rowCount; ++row) {
        int column = 0;
        while (column < m_columnCount) {
            const QString &value = matrix[row][column];
            if (value.isEmpty()) {
                ++column;
                continue;
            }
            int runEnd = column + 1;
            while (runEnd < m_columnCount && matrix[row][runEnd] == value)
                ++runEnd;
            if (runEnd - column >= 3) {
                for (int c = column; c < runEnd; ++c) {
                    const QString key = QString::number(row) + QLatin1Char(':') + QString::number(c);
                    seen.insert(key);
                }
            }
            column = runEnd;
        }
    }

    // Vertical runs
    for (int column = 0; column < m_columnCount; ++column) {
        int row = 0;
        while (row < m_rowCount) {
            const QString &value = matrix[row][column];
            if (value.isEmpty()) {
                ++row;
                continue;
            }
            int runEnd = row + 1;
            while (runEnd < m_rowCount && matrix[runEnd][column] == value)
                ++runEnd;
            if (runEnd - row >= 3) {
                for (int r = row; r < runEnd; ++r) {
                    const QString key = QString::number(r) + QLatin1Char(':') + QString::number(column);
                    seen.insert(key);
                }
            }
            row = runEnd;
        }
    }

    for (const QString &entry : seen) {
        const QStringList parts = entry.split(QLatin1Char(':'));
        if (parts.size() != 2)
            continue;
        QVariantMap map;
        map.insert(QStringLiteral("row"), parts.at(0).toInt());
        map.insert(QStringLiteral("column"), parts.at(1).toInt());
        matches.append(map);
    }

    return matches;
}

GameGridOrchestrator::ColorEntry GameGridOrchestrator::chooseFromPool(QVector<QVector<QString>> &matrix, int row, int column)
{
    if (m_spawnPool.isEmpty())
        rebuildPool();

    if (m_spawnPool.isEmpty())
        return { QStringLiteral("red"), QStringLiteral("#ef4444") };

    const int poolSize = m_spawnPool.size();
    for (int attempt = 0; attempt < poolSize; ++attempt) {
        const ColorEntry &candidate = m_spawnPool.at(m_poolIndex % poolSize);
        m_poolIndex = (m_poolIndex + 1) % poolSize;
        if (!wouldCreateMatch(matrix, row, column, candidate.key))
            return candidate;
    }

    // Fallback to first palette entry if every candidate would create a match
    return m_palette.isEmpty() ? ColorEntry{ QStringLiteral("gray"), QStringLiteral("#737373") }
                               : m_palette.first();
}

bool GameGridOrchestrator::wouldCreateMatch(const QVector<QVector<QString>> &matrix, int row, int column, const QString &colorKey) const
{
    if (colorKey.isEmpty())
        return false;

    int count = 1;
    for (int c = column - 1; c >= 0; --c) {
        if (matrix[row][c] == colorKey)
            ++count;
        else
            break;
    }
    for (int c = column + 1; c < m_columnCount; ++c) {
        if (matrix[row][c] == colorKey)
            ++count;
        else
            break;
    }
    if (count >= 3)
        return true;

    count = 1;
    for (int r = row - 1; r >= 0; --r) {
        if (matrix[r][column] == colorKey)
            ++count;
        else
            break;
    }
    for (int r = row + 1; r < m_rowCount; ++r) {
        if (matrix[r][column] == colorKey)
            ++count;
        else
            break;
    }
    return count >= 3;
}
