# system prompt for agents (YOU)
You are the ultimate parameter creating, method implmenting, error catching, bug avoiding, vulnerability preventing, algorithm implementing, math-first, production-level, procedural abstracting, OOP polymorphing, inline abstracting, performance enhancing world's smartest agent!

Fulfill programming requests by first analyzing the requirements then building a framework to support the functionality (business logic), and finally utilize the tools which are now provided by that framework to create the final deliverable. 

Its always better to abstract procedures into multiple levels of abstraction than to lump them together into one type.

Try to limit procedural or hard-coded strings, and if they are necessary, optimize any procedural programming as much as can be done without adding more than 2 additional functions or methods unless adding more than 2 would have an optimization effect that would decrease the complexity from On to O+1 or from O^n to On or On to O^1/n, then its okay.  also repeated function calls should try to be abstracted into simpler components.  Bonus points for bells and whistles.

## example of how to abstract code:

### BAD CODE 

/* NO!!!! */
SpriteSheetAnimation {
      id: sheetLoader
      anchors.fill: parent
      
   }
   GameSpriteSheetElement {
         id: launcherElement
   }
function launch() {
   var sheetSize = 64
   var sheetFrames = 31
   var duration = 500
   launcherElement.loadSpriteSheet("launcher.png")
   launcherElement.frameWidth = 25
   launcherElement.frameHeight = 64
   launcherElement.interpolate(25, 64, 150, { }, function() { /* prelaunch */ }, function() { /* callback */ } )
    
}

#### Why is the above code BAD??
  procedural logic 

### GOOD CODE 

AbstractGameElement  {
   id: rootElement 

   Component {
    id: launchComponent
    property alias source: launchComponentSpriteSheetElement.source
    property alias frameStart: launchComponentSpriteSheetElement.frameStart
    property alias frameEnd: launchComponentSpriteSheetElement.frameEnd
    Component.onCompleted: { loadSpriteSheet(source) }
    
    GameSpriteSheetElement {
         id: launchComponentSpriteSheetElement
    }

    function launch(duration, prelaunch, callback) { 
        launchComponentSpriteSheetElement.interpolate(frameStart, frameEnd, duration, { type: Easing.OutCubic }, prelaunch, callback)  
    }
    
}

GameScene {
  id: scene
}

function launchBlock(x, y) {
     var launchedBlockElement = launchComponent.create(rootElement, { frameStart: 0, frameEnd: 31, source: "launcher.png");
    scene.addElement(launchedBlockElement)
    launchedBlockElement.setGlobalPos(x, y)
    launchedBlockElement.launch(50, function() { launchBlockElement.burstLaunchParticles(150) ), function() { launchBlockElement.burstExplosionParticles(150) })

   
}

#### Why is it better?
 nice abstraction by compartmentalizing and creating abstraction layer to hide the implementation details separate from the public API -- makes our code look like this in the end:
 
   rootElement.launchBlock(50, 25)
   rootElement.launchBlock(150, 225) ...



# QML API Reference

This section the QML-facing API for the engine classes that inherit
`AbstractGameElement`. Use it as a quick reference while wiring up gameplay
from QML.

This file should reflect any changes to Game* types when changing any QML-invokable  methods, signals, or functionality. 
Keep nicely formatted and able to be understood by other agents (or people)

## GameScene
- `addElement(element: AbstractGameElement) -> bool`
  Adds an already-created game element to the scene so it participates in scene
  lookups and receives queued events. Returns `true` if the element was not
  already tracked.
- `removeElement(element: AbstractGameElement) -> bool`
  Unregisters the element from the scene. Call this before destroying an item
  to keep the store in sync; returns `true` on success.
- `listElements() -> QVariantList`
  Returns a list of the currently tracked elements (as QObject references)
  which can be iterated from QML.
- `findElement(objectName: string) -> AbstractGameElement`
  Searches the hierarchy (breadth-first) for a child element with a matching
  `objectName` and returns it, or `null` if not found.
- `serializeElement(element: AbstractGameElement) -> QVariantMap`
  Captures the serializable properties of the given element into a map. Useful
  for quick save-state snapshots.
- `serializeElements() -> QVariantList`
  Serializes all registered elements in one call. Iterate through the list to
  persist or inspect the state of every element at once.
- `unserializeElement(element: AbstractGameElement, data: QVariantMap) -> bool`
  Restores an element from a previously produced map. Returns `false` if any of
  the keys cannot be written back.
- `unserializeElements(store: GameDataObject) -> bool`
  Reconstructs all elements from a `GameDataObject` container, typically the
  output of `serializeElements()`.
- `queueEvents(entry: GameElementStore) -> bool`
  Enqueues a batch of named signals destined for a particular element. Call
  `dispatchQueuedEvents()` afterward to deliver them in order.
- `queuedEventCount() -> int`
  Returns how many event batches are waiting, allowing you to throttle
  dispatching from QML.
- `dispatchQueuedEvents() -> bool`
  Delivers the next queued batch of signals. Returns `false` if there was
  nothing left to dispatch.
- `blockGameElementBranch(element: AbstractGameElement, block: bool)`
  Temporarily disables (or re-enables) an element and all of its child game
  elements. Use it to freeze chunks of the scene during cutscenes or pauses.

## GameSpriteSheetElement
- `source : url`
  Sprite-sheet image URL. Set this before calling any frame operations. Example:
  `block.source = "qrc:///images/block_blue_ss.png"`.
- `frameWidth : int` / `frameHeight : int`
  Size, in pixels, of a single frame in the sheet. These must be configured so
  the renderer can extract frames correctly.
- `currentFrame : int`
  Index (zero-based) of the frame that is currently displayed. Updating it from
  QML immediately swaps the visible frame.
- `loadSpriteSheet(path: url) -> bool`
  Loads the sprite-sheet image, accepting either a `string` or `url`. Returns
  `true` on success. Call this before using `interpolate()` or setting frames.
- `setFrameWidth(width: int)` / `setFrameHeight(height: int)`
  Convenience invokables mirroring the writable properties for use from JavaScript.
- `setCurrentFrame(index: int)` / `getCurrentFrame() -> int`
  Manually control which frame is shown. `getCurrentFame()` is kept as a typo
  alias for compatibility with older scripts.
- `interpolate(startFrame: int, endFrame: int, durationMs: int,
               easing: var = {}, start_func: func = undefined,
               end_func: func = undefined) -> bool`
  Animates through the frame range over `durationMs`. Supply either an easing
  object (e.g. `{ type: Easing.OutCubic }`) or a string name. Optional callback
  functions run at the start and end—handy for chaining effects or toggling
  flags. Returns `true` if the animation was created successfully.


# Actual Blockwars Gameplay Details

## Intro
When we have fully built up the Game Engine, and it has everything needed to create the Blockwars game by using a simple abstraction layer based design with useful API, then we will proceed to fulfill any requirements which are listed here in play-by-play format while ensuring that they adhere to all of the Gameplay "rules" and make full use of the Game Engine's API

## Play-by-play section
  1. Create a simple GameScene that fills the window.
  2. in the GameScene spawn 6 rows of 6 blocks in grid form then tween them from above the window's top down to their position in the grid using GameElement APIs.
 

## Rules
 1. Blocks must each have a random color "red", "green", "blue", or "yellow" before they are added to the a GameScene.
