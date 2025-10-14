cmake_minimum_required(VERSION 3.16)
project(Blockwars24 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Qml)

add_library(blockwars STATIC
    src/AbstractGameElement.cpp
    src/GameDataObject.cpp
    src/GameElementsStore.cpp
    src/GameScene.cpp
    src/GameSignal.cpp
)

target_include_directories(blockwars PUBLIC include)

target_link_libraries(blockwars PUBLIC Qt6::Core Qt6::Qml)
