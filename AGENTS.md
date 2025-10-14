# QML API Reference

This document summarizes the QML-facing API for the engine classes that inherit
`AbstractGameElement`. Use it as a quick reference while wiring up gameplay
from QML.

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
