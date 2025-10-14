#include "gamesignal.h"

GameSignal::GameSignal(QObject* parent)
    : QObject(parent)
{
}

GameSignal::GameSignal(const QString& name, const QVariantList& arguments, QObject* parent)
    : QObject(parent)
    , m_name(name)
    , m_arguments(arguments)
{
}

QString GameSignal::name() const
{
    return m_name;
}

void GameSignal::setName(const QString& name)
{
    if (m_name == name)
        return;
    m_name = name;
    emit nameChanged();
}

QVariantList GameSignal::arguments() const
{
    return m_arguments;
}

void GameSignal::setArguments(const QVariantList& arguments)
{
    if (m_arguments == arguments)
        return;
    m_arguments = arguments;
    emit argumentsChanged();
}
