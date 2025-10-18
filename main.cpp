#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "src/abstractgameelement.h"
#include "src/gamespritesheetelement.h"
#include "src/gamescene.h"
#include "src/gamesignal.h"
#include "src/gamegridorchestrator.h"
#include <QResource>
#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication::setOrganizationName("Blockwars");
    QGuiApplication::setOrganizationDomain("blockwars.example");
    QGuiApplication::setApplicationName("Blockwars24");

    QGuiApplication app(argc, argv);
    const QString rccPath = QDir(QCoreApplication::applicationDirPath()).filePath("resources.rcc");
    QResource::registerResource(rccPath);
    QQmlApplicationEngine engine;

    engine.addImportPath("qrc:///");         // often enough
    engine.addImportPath("qrc:///qt/qml");
    qmlRegisterType<AbstractGameElement>("Blockwars24", 1, 0, "AbstractGameElement");
    qmlRegisterType<GameSpriteSheetElement>("Blockwars24", 1, 0, "GameSpriteSheetElement");
     qmlRegisterType<GameScene>("Blockwars24", 1, 0, "GameScene");
     qmlRegisterType<GameSignal>("Blockwars24", 1, 0, "GameSignal");
    qmlRegisterType<GameGridOrchestrator>("Blockwars24", 1, 0, "GameGridOrchestrator");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Blockwars24", "Main");

    return app.exec();
}
