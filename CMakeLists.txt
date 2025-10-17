cmake_minimum_required(VERSION 3.16)

project(Blockwars24 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appBlockwars24
    main.cpp
)

qt_add_qml_module(appBlockwars24
    URI Blockwars24
    VERSION 1.0
    QML_FILES
        Main.qml
        MainMenu/MainMenuPage.qml
        PowerupEditor/PowerupEditorScene.qml
        PowerupEditor/CreatePowerupFlow.qml
        PowerupEditor/CreatePowerupOverviewStep.qml
        PowerupEditor/CreatePowerupBlockStep.qml
        PowerupEditor/PowerupLibraryPage.qml
        PowerupEditor/PowerupLibraryView.qml
        Shared/DefaultPowerupRepository.qml
        Shared/PowerupDataStore.qml
        Shared/PowerupEnergyModel.qml
        Shared/PowerupRepository.qml
        Shared/PlaceholderPage.qml
        SinglePlayer/PlayerPowerupLoadoutStore.qml
        SinglePlayer/SinglePlayerSelectPowerupsScene.qml
        SinglePlayer/SinglePlayerMatchScene.qml
        SinglePlayer/components/SelectPowerupSlot.qml
        SinglePlayer/components/ReadyForMatchButton.qml
        SinglePlayer/components/PowerupSelectionModal.qml
        SinglePlayer/components/MatchDashboard.qml
        SinglePlayer/components/MatchMomentumBar.qml
        SinglePlayer/components/MatchGridView.qml
        SinglePlayer/components/PowerupColumn.qml
        SinglePlayer/components/PowerupChargeMeter.qml
        SinglePlayer/controllers/CpuPlayerController.qml
        SinglePlayer/controllers/HumanPlayerController.qml
    RESOURCES
        resources.qrc
        AGENTS.md
    SOURCES
        src/abstractgameelement.h src/abstractgameelement.cpp
        src/gamespritesheetelement.h src/gamespritesheetelement.cpp
        src/gamescene.h src/gamescene.cpp
        src/gamesignal.h src/gamesignal.cpp
        src/gameelementstore.h src/gameelementstore.cpp
        src/gamedataobject.h src/gamedataobject.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appBlockwars24 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBlockwars24
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appBlockwars24
    PRIVATE Qt6::Quick
)
target_link_libraries(appBlockwars24 PRIVATE Qt6::Core Qt6::Quick)
target_link_libraries(appBlockwars24 PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS appBlockwars24
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/resources.rcc
  COMMAND Qt6::rcc -binary ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc
                   -o ${CMAKE_CURRENT_BINARY_DIR}/resources.rcc
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc
)
add_custom_target(assets_rcc ALL
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/resources.rcc)
