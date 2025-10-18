# ADDITIONAL AGENT INSTRUCTIONS

- Embrace the persona described by the user: prioritize deep abstraction, layered architecture, math-first reasoning, and resilient error handling. Keep business logic hidden behind reusable types and avoid procedural sprawl.
- Always compute gameplay energy requirements instead of allowing players to edit raw values directly.
- Maintain rigorous commit discipline on the current branch and invoke the PR creation tool after committing when changes exist.
- When addressing TODO items in this file, only mark them as complete with a ✔️ once the underlying feature is fully implemented.

# CODING STYLE EXAMPLE

SelectPowerupscene.qml

    GameScene {
        id: selectPowerupSceneRootItem
        
        PowerupDataStore { 
            id: singlePlayerPowerupSelectedDataStore
            table:  "singlePlayerSelectedPowerupsForPlayer"

       }

        SelectPowerupSlotView {
            id: selectPowerupSlotViewer
            
            selectedPowerupDataStore: singlePlayerPowerupSelectedDataStore
            
            onOpenSelectionModal: function (slotIdx) {
            
                // call function from Powercatalog.qml
                powerupCatalog.openCatalogForSlot(slotIdx)
               
                // connect to function in PowerupCatalog.qml
               powerupCatalog.powerupChosen.connect(singlePlayerPowerupSelectedDataStore.updateSelectedPowerupData) 
            }
            
        }
        
        PowerupCatalog {
           id: powerupCatalog
          
       }
     }

The example code is how the entire file should be (with imports etc at the top too) for everything.
No cramming or functional hellscapes. 
C++ style abstraction OOP only when coding with QML.

# CODING GUIDELINES

- Use play-by-play descriptions as references for how each scene in the game will look. 
- Use Game Rules as references as to how to enforce the overall flow of the game and limitations on what can be done and when.
- Use TODO list to determine what needs to be done still
- Set yourself up for success. Write code so that it will be compatible and portable even when other components change 
- Break down large problems into multiple QML files, and use OOP style integration to keep them from being overly dependent
- Encapsulate code to manipulate and control other QML files as functions and properties with generic purposes - avoid being too specific and instead use relative values (parent.implicitWidth * 0.60) instead of 650
- Use functions to control the scene and use generic types that are then used as base classes for more specific types with specialized features. 
- Break down difficult integrations into many different small integrations. 
- Leave room everywhere to be able to tie in additional bells and whistles by connecting animations to events and then connecting events to their destinations so i can make things have little animated experiences as they transition through states
- Use states to control what interactive types are allowed to do and what role they play.
- GameGrid should have many many states
- Blocks should have many states
- Powerups should have a number of states from dead to onboard, to fully charged, to charging, to (possibly more so leave room) and make it all clean and easy to follow by a human who is lazy

# TO DO

- ✔️ Edit Powerup Area doesn't properly load the powerup data from QtQuick.LocalStorage based store
- ✔️ Fix bug in SinglePlayerGameScene: "qrc:/qt/qml/Blockwars24/SinglePlayerGameScene.qml:150: ReferenceError: model is not defined"
- ✔️ Read through the play-by-play and add TODO items for each of the play-by-play items needed to be done in order to fully implement each of the items with special attention to detail. - Do not implement all play-by-play items, just generate the to do list of items that will have to be done to fully complete each item. (can be more than 1 per item)
- ✔️ TODO [Step 1]: Compose the Block Wars main menu with the title occupying the top 20% of the screen and centered horizontally on application launch.
- ✔️ TODO [Step 2]: Lay out Single Player, Multiplayer, Powerup Editor, Options, and Exit buttons beneath the title and wire them into the StackView navigation flow.
- ✔️ TODO [Step 3]: Present the Powerup Editor landing list with Create New, Edit Existing, and Back entries that switch StackView pages and prime the data store.
- ✔️ TODO [Step 4]: Build the Create Powerup form with the dismiss button, combobox selections for type/target/color, and a guarded Next action.
- ✔️ TODO [Step 5]: Persist the player's chosen type, target, and color selections between pages so block selection inherits the configuration.
- ✔️ TODO [Step 6]: Implement the Select Blocks page with a 6x6 grey block grid that toggles to the chosen color with shading and tracks selections.
- ✔️ TODO [Step 7]: Add the HP adjustment slider (1–20) that binds into the powerup configuration and previews applied values.
- ✔️ TODO [Step 8]: Hook the Finish action to serialize the configured powerup, compute energy, commit to LocalStorage, and return to the editor menu.
- ✔️ TODO [Step 9]: Populate the Edit Existing list with scrollable cards showing color, type, target, damage, block count, and an energy panel per entry.
- ✔️ TODO [Step 10]: Ensure selecting an existing powerup rehydrates both pages with stored values, including slider ranges for heroes or players versus block flows.
- ✔️ TODO [Step 11]: Maintain the LocalStorage schema so the complete set of player powerups is stored in JSON and accessible to other systems.
- ✔️ TODO [Step 12]: When saving edits, overwrite the selected powerup, refresh the list model, and return to the Powerup Editor menu.
- ✔️ TODO [Step 13]: Provide a Back to Main Menu action from the editor that transitions the StackView to the title screen.
- ✔️ TODO [Step 14]: Assemble SinglePlayerSelectPowerupsScene with a GameScene root, PlayerPowerupLoadoutStore, and four loadout slots arranged via ColumnLayout.
- ✔️ TODO [Step 15]: Implement the shared selection modal that merges player-created powerups with default presets and commits decisions to the loadout store.
- ✔️ TODO [Step 16]: Reopen slots with their current selection highlighted and ensure confirming the existing entry leaves the store unchanged while new picks replace atomically.
- ✔️ TODO [Step 17]: Create the ReadyForMatchButton component sized to ~18% width, styled with the success palette, and enabled only when the loadout store reports readiness.
- ✔️ TODO [Step 18]: Emit beginMatch with a loadout snapshot, persist it, and transition into SinglePlayerMatchScene through the application controller.
- ✔️ TODO [Step 19]: Structure SinglePlayerMatchScene with a GameScene root stacking identical dashboards for CPU and human players in a SplitView.
- ✔️ TODO [Step 20]: Compose each SinglePlayerMatchDashboard with momentum bar, central GameGridElement, and powerup column while respecting the 80% grid width goal.
- ✔️ TODO [Step 21]: Build the PowerupColumn to render four cards linked to PowerupChargeMeter instances whose colors derive from powerup metadata.
- ✔️ TODO [Step 22]: Expose the underlying GameGridElement from the dashboard through a property alias so controllers can route signals without duplicating logic.
- ✔️ TODO [Step 23]: Show a centered WaitingForOpponentBanner that hides itself once both dashboards confirm readiness.
- ✔️ TODO [Step 24]: Instantiate a CpuPlayerController on first entry, seed it with four default powerups, and store its loadout internally.
- ✔️ TODO [Step 25]: Relay the CPU loadout via loadoutPrepared to the top dashboard using applyPowerupLoadout and ensure UI binds correctly.
- ✔️ TODO [Step 26]: Instantiate a HumanPlayerController that mirrors the CPU flow by replaying the persisted player loadout into the bottom dashboard.
- ✔️ TODO [Step 27]: Listen for powerupDataLoaded signals from both dashboards and track readiness flags before allowing play to continue.
- ✔️ TODO [Step 28]: Generate seeds through SeedRngHelper and invoke setBlockSeed on each dashboard, waiting for confirmations before initialization.
- ✔️ TODO [Step 29]: After both seeds are confirmed, call initializeGame to wire control signals between scene, dashboards, and controllers.
- ✔️ TODO [Step 30]: Conduct initiative rolls by requesting random values from both controllers, rerolling ties, and storing the active dashboard index.
- ✔️ TODO [Step 31]: Clear the waiting banner, issue beginTurn to the active dashboard, and notify the opponent that it is observing via queued signals.
- ✔️ TODO [Step 32]: Ensure GameGridElement creates Block components through a Component factory so every block shares the behavior tree.
- ✔️ TODO [Step 33]: Implement BlockAnimationStateMachine to map block states (idle, matched, launching, etc.) to sprite-sheet sequences from BlockSpriteRepository.
- ✔️ TODO [Step 34]: Maintain interactionEnabled and inAnimation flags on blocks, toggled by the grid and animation state machine to protect timing-sensitive logic.
- ✔️ TODO [Step 35]: Handle the beginFilling state by spawning new blocks via BlockFactory into virtual row -1 and animating them into place while tracking timers.
- ✔️ TODO [Step 36]: Provide settleSpawnedBlocks routines that wrap block drops in SequentialAnimation and correctly flip inAnimation markers.
- ✔️ TODO [Step 37]: Gate fillTimer on animation completion and transition to the compact state once row 0 is gap-free.
- ✔️ TODO [Step 38]: Implement compactTimer to compress columns one cell at a time toward the defender, respecting orientation and animation guards.
- ✔️ TODO [Step 39]: Create matchTimer to search for horizontal and vertical runs, populate matchList, and emit cascadeEnded when no matches remain.
- ✔️ TODO [Step 40]: Build launchTimer to iterate over matchList, trigger block.launch(), track launchCount, and revert to compact once all launches finish.
- ✔️ TODO [Step 41]: Execute swapBlocks only when the grid is in the match state with no animations, dropping immediately back into match processing on success.
- ✔️ TODO [Step 42]: When matches exhaust and swaps run out, emit turnEnded for the active dashboard and freeze cascading until the opponent finishes.
- ✔️ TODO [Step 43]: Upon receiving turnEnded, enable cascading on the opposing grid, reset swaps, and process fill/compact loops until stable.
- ✔️ TODO [Step 44]: After the opponent's first cascade, re-enable swapping and inform the corresponding controller to choose a move.
- ✔️ TODO [Step 45]: Have CpuPlayerController evaluate serialized grid snapshots, score all legal swaps, emit requestSwap, and wait for cascades before continuing.
- ✔️ TODO [Step 46]: Decrement CPU swaps after each cascade and emit turnComplete when no swaps remain or no legal moves exist.
- ✔️ TODO [Step 47]: After both GameGrids broadcast `beginFilling`, notify each dashboard (with its index) to transition into the enabled filling/launch state chain so their UI and logic stay synchronized.
- ✔️ TODO [Step 48]: Maintain a persistent association between Player controllers and dashboards so routed signals (fill, launch, swaps, health updates) always land on the correct side.
- ✔️ TODO [Step 49]: When a dashboard receives the `beginFilling` directive, compress existing blocks toward the centre-facing edge before spawning replacements so grids reset cleanly.
- ✔️ TODO [Step 50]: Implement the pooled block generator that iterates columns, advances a pool index, spawns new blocks at virtual row -1, and stages them for compression into row 0.
- ✔️ TODO [Step 51]: Refactor `Block.qml` to inherit from `AbstractGameElement`, wiring drop/launch tweens through the engine helpers instead of ad-hoc JavaScript animations.
- ✔️ TODO [Step 52]: Implement `GameGridOrchestrator` (C++) that owns fill/compact/match state, deterministic spawn pools, and exposes concise QML hooks for `GameGridElement`.
- ✔️ TODO [Step 53]: Add pointer handlers that honour `interactionEnabled`, allowing the grid to toggle swap hit testing per turn.
- TODO [Step 54]: On receipt of `beginFilling`, drive the grid into `fill` via a QuickPromise state gate that resolves once the fill controller begins (avoid direct signal-slot binds).
- TODO [Step 55]: When `fill` activates, spin up a QuickPromise vacancy scan (replacing `fillTimer`) that inspects row 0 and resolves with the list of open cells.
- TODO [Step 56]: Chain the vacancy promise to spawn row -1 blocks for each open column and expose a promise that settles after the component creations register.
- TODO [Step 57]: Promote staged row -1 blocks into row 0 using drop animations wrapped in QuickPromise sequences so `inAnimation` flags flip only after `.then()` handlers run.
- TODO [Step 58]: Wrap block Y animations in QuickPromise helpers that set `inAnimation = true` before movement and resolve to flip it off post-landing.
- TODO [Step 59]: Keep the fill-chain promise pending whenever any block's animation promise is unresolved and exit early only once every drop promise settles.
- TODO [Step 60]: When the fill-chain resolves, transition to `compact` by chaining a new QuickPromise instead of firing timers.
- TODO [Step 61]: Implement compaction as a QuickPromise-driven column iterator that moves one cell per resolved step while honoring orientation.
- TODO [Step 62]: After the compaction promise settles, branch with `.then()`; re-enter `fill` if gaps remain or advance into `match` otherwise.
- TODO [Step 63]: In `match` state, guard against unresolved animation promises, detect empty rows, and populate `matchList` as the resolved payload.
- TODO [Step 64]: Extend the detector promise to append vertical runs so every qualifying sequence enters `matchList` exactly once.
- TODO [Step 65]: When the match detection promise resolves empty, return to `idle` and notify the turn manager by fulfilling a QuickPromise instead of emitting raw signals.
- TODO [Step 66]: If `matchList` carries entries, enter `launch` by resolving a QuickPromise that triggers each block's `launch()` and aggregates launch promises with `Q.all`.
- TODO [Step 67]: Await the aggregated launch promise before looping back into the compaction promise chain.
- TODO [Step 68]: Wrap swap requests in QuickPromise guards so the grid snaps back to `match` only after the swap promise resolves.
- TODO [Step 69]: Maintain the (`match`→`launch`→`compact`→`fill`) loop as a series of chained promises to guarantee deterministic cascades without signal races.
- TODO [Step 70]: Once the match promise resolves with no runs and all animation promises have settled, verify remaining swaps through a QuickPromise-based check.
- TODO [Step 71]: If no swaps remain, fulfill a turn-ending QuickPromise that pauses cascading on that grid instead of emitting directly.
- TODO [Step 72]: Upon the opponent's turn completion promise, re-enable cascading on the passive grid and drive it through the promise-based fill/compact loop until stable.
- TODO [Step 73]: Chain a promise that replenishes the defending grid's swaps and only resolves when the board is back in `match` with no pending animations.
- TODO [Step 74]: After the defender's first cascade promise fulfills, permit swaps for that grid and notify its controller via `.then()`.
- TODO [Step 75]: Surface grid serialization via an async API that returns a QuickPromise delivering row/column/color data for the CPU.
- TODO [Step 76]: Have CpuPlayerController score adjacent swaps inside promise chains, using `.then()` to request the highest-value swap through the grid API.
- TODO [Step 77]: After dispatching a swap, keep the CPU idle by awaiting the cascade promise before decrementing swaps.
- TODO [Step 78]: Repeat the CPU evaluation loop by chaining promises until three swaps resolve or no legal moves remain.
- TODO [Step 79]: When the CPU move budget promise completes, resolve a turn completion promise so control passes back to the human grid.
- TODO [Step 80]: Ensure the human-side grid awaits the CPU turn completion promise before cascading, refilling, and unlocking swaps.
- TODO [Step 81]: Allow charged powerup cards to be placed only when swap/cascade promise guards resolve, enforcing interactions through promise gating.
- TODO [Step 82]: Replace targeted blocks with the deployed powerup and resolve a QuickPromise once the board exclusions propagate to match logic.
- TODO [Step 83]: Enforce one deployment per card by chaining activation promises; sequential activations only start after the previous promise settles.
- TODO [Step 84]: Resolve powerup abilities via promise-based damage/heal pipelines that also trigger animations and settle when feedback completes.
- TODO [Step 85]: Reset card energy inside the activation promise's `.then()` while keeping the board entity live for recharge.
- TODO [Step 86]: Permit re-activation when the recharge promise fulfills, supporting click re-use and energy reset inside the resolution handler.
- TODO [Step 87]: Trigger explosion/glow/shake feedback through QuickPromise animation helpers so upstream logic awaits visual completion.
- ✔️ TODO [Step 88]: Collapse the WaitingForOpponentBanner only after a `Q.all` aggregate of dashboard readiness promises resolves, keeping UI state changes promise-gated.
- ✔️ TODO [Step 89]: Refactor CPU and Human loadout hydration so controllers expose QuickPromise hooks that resolve once cards bind and animations settle, avoiding direct signal wiring.
- ✔️ TODO [Step 90]: Replace the seed confirmation handshake with chained QuickPromises—generate seeds, wait on both `setBlockSeed` resolutions, then resolve into `initializeGame`.
- ✔️ TODO [Step 91]: Conduct initiative rolls inside a QuickPromise loop that reruns on ties and settles before `beginTurn` promise chains trigger dashboard state flips.





# QML API Reference

This section is the QML-facing API for the engine classes that inherit
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
- `queueEvents(target: GameElement, signals: []) -> bool`
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
- When we have fully built up the Game Engine, and it has everything needed to create the Blockwars game by using a simple abstraction layer based design with useful API, then we will proceed to fulfill any requirements which are listed here in play-by-play format while ensuring that they adhere to all of the Gameplay "rules" and make full use of the Game Engine's API
- Create new interactive elements by creating QML files that are of type AbstractGameElement (or any class derived from AbstractGameElement)
- Avoid re-inventing the wheel. Instead, utilize the QML API to build new QML types with functions and properties. 
- Its better to have 100 files starting with SinglePlayerSelectPowerup<various Elements>.qml than it is to have one file called SelectPowerupGameScene.qml with 100 different elements in it.
- Try to avoid what I call spaghetti code (dumping all code into a single QML file) and instead, logically separate elements into separate QML files and pass properties along and encapsulate functions within those separate files to wire them up

## Example

 

## Play-by-play section

### (DONE)  Main Menu
 1. The application opens revealing a Screen with the title Block Wars on the top 20% of the screen, centered on the X axis with the application
 2. Beneath the Block Wars logo there are a few buttons: Single Player, Multiplayer, Powerup Editor, Options, and Exit.

### Powerup Editor
  3. The player clicks on Powerup Editor which changes the entire screen (stackview) to the PowerupEditor scene which starts
   by showning a List View that displays the following choices: Create New, Edit Existing, Back to Main Menu
 4. The player clicks on Create New which changes the page to the "Create Powerup" page which has a red button with an "X" on the 
   top-right which would essentially pop the stackview back one page. while the majority of the page is made of a few options to choose from in a form-like layout:
   "Type" which has a Combobox and the options "Enemy" and "Self"
   "Target" which is a combobox with "Blocks", "Hero(s)", and " Player Health"
   "Color" which is a combobox with "Red", "Green", "Blue" and "Yellow"
   "Next" which is a button at the bottom centered and larger than the rest of the page's components slightly.
  5. Player chooses "Enemy", "Blocks" and "Green" then clicks "Next"
  6. Next, another page transitions in which has the title "Select Blocks" because "Blocks" was chosen as the powerup type.
   The "Select Blocks" page contains a Game Grid (a 6x6 Grid Layout) with only Grey blocks, each one with clearly defined shadows for a simple 3d-ish effect.
   Clicking on any of the blocks in the Game Grid will cause that individual block to change from Grey into a block matching the color chosen on the previous page
   Clicking a colored blockw will change it back to Grey. 
  7. Below the grid, there is a slider which goes from 1 to 20 idicating the amount of HP to add or remove to each block when the powerup is activated while in a game.
   Under the slider is a "Finish"
  8. The player clicks "Finish" and the page returns to the Powerup Editor main scene. 
  9. Clicking on "Edit Existing" Opens the "Choose Powerup" page to transition into view which contains a scrollable listview where each item is a card which has: a block
   matching that powerup's block color chosen during create powerup, the Type, the Target, the amount of damage, and if "Blocks" is chosen, the number of blocks selected.
   There s also a final, separate box but still connected to the same card on the right-side which says: "Energy: <energy>"  where energy is the 
   amount calculated by a special algorithm (number of targets * amount of HP * 0.5).
 10. Clicking on any of the Powerup "Cards" will push the stackview to transition to a page identical to the "Create Powerup" page, only it will have all the values filled in 
   so that they match the selected Powerup card.  Clicking Next will take to the same page as the "Select Blocks" page if "Blocks" is chosen 
   or just a slider from 0 to 100 if "Hero" or "Player/Enemy" is chosen instead of blocks for amount of damage / health to give/take
   At the bottom is a "Save" button which overwrites the chosen powerup with the new values chosen from the two pages.
 11. All powerup data is stored in the LocalStorage SQL Database feature that QML has built-in in JSON format and must contain all of the Player's Powerups in a table in a form that
   can be read by other parts of the same program.  
 12. The player's Powerup is saved afte they click Save which returns them to the Powerup Editor main menu.
 13. The player clicks on "Back to Main Menu" which transitions back to the Main Menu (title screen)


### Single Player (Player Vs. CPU)
14. Selecting **Single Player** pushes `SinglePlayerSelectPowerupsScene.qml` onto the navigation stack. The scene owns a single `GameScene` root that wires a `PlayerPowerupLoadoutStore` to four `SinglePlayerSelectPowerupSlot` children laid out with a `ColumnLayout` (spaced evenly and centered). Each slot exposes `powerupSummary` data and renders either a populated `SinglePlayerPowerupOptionCard` or the branded "Select Powerup…" placeholder when no loadout entry is stored.
15. Each slot routes its `requestSelection` signal into a shared `SinglePlayerPowerupSelectionModal`. The modal is implemented as an `Overlay.modal` item that nests two data sources: the player's persisted `PowerupEditorStore` entries first, then a `DefaultPowerupRepository` for the shipped presets. Choosing an option commits the JSON payload back into the `PlayerPowerupLoadoutStore`, which in turn updates the originating slot via a model binding—no slot ever mutates its own content directly.
16. Opening a slot that already has data simply rehydrates the modal with the current selection highlighted. Confirming the same entry leaves the loadout untouched; picking a new entry replaces that slot's JSON atomically so the UI remains in sync with LocalStorage.
17. A dedicated `ReadyForMatchButton` lives in the same scene as the slots but is composed as a separate reusable QML type. It anchors to the right edge, consumes ~18 % of the available width, and binds its `enabled` flag to `PlayerPowerupLoadoutStore.ready` so it only lights up when every slot references a valid powerup. The button's visual state uses the game's standard success palette rather than an ad-hoc color constant.
18. Triggering the button emits `beginMatch(loadoutSnapshot)`; the scene forwards this payload to the application controller, which immediately persists the snapshot and transitions into `SinglePlayerMatchScene.qml`. Because the data lives inside the store, the most recent loadout is always restored when the player returns to this screen.

#### Game Board
19. `SinglePlayerMatchScene.qml` uses a `GameScene` root that vertically stacks two `SinglePlayerMatchDashboard` instances inside a `SplitView`. The upper dashboard hosts the CPU, the lower hosts the human player; both share an identical component tree so layout changes stay symmetrical.

##### Dashboard
20. Each `SinglePlayerMatchDashboard` composes three child regions: a `MatchMomentumBar` hugging the outer edge (top-aligned for the CPU, bottom-aligned for the human), a central `SinglePlayerMatchGrid`, and a right-aligned `PowerupColumn`. Geometry relies on anchors and fixed spacing constants so the grid consumes ~80 % of the width while the powerup column remains visually detached.
21. `PowerupColumn` renders four `SinglePlayerMatchPowerupCard` elements stacked with uniform spacing. Every card binds to a `PowerupChargeMeter` subcomponent whose fill color is driven by the powerup metadata rather than inline RGB strings. The meters surface raw charge progress without textual clutter, matching the minimalist HUD style.
22. The `SinglePlayerMatchGrid` exposes the `GameGridElement` it wraps through a property alias, enabling the dashboard to forward controller signals without re-implementing gameplay logic inside the view.

#### Game Board Flow
23. When the match scene becomes active it shows a centered `WaitingForOpponentBanner` between the dashboards. The banner hides itself once both dashboards report readiness.
24. `SinglePlayerMatchScene` constructs a `CpuPlayerController` the first time the scene is entered. The controller is an `AbstractGameElement` derivative that owns its own `PowerupLoadoutStore`. It immediately requests four entries from the built-in `DefaultPowerupRepository` and caches them in memory.
25. After the CPU finishes seeding its repository, it emits `loadoutPrepared(dashboardIndex, loadoutPayload)`. The match scene relays that payload to the top dashboard through its `applyPowerupLoadout` invokable so the cards populate strictly via data binding.
26. In parallel, the scene instantiates a `HumanPlayerController` bound to the bottom dashboard. The controller pulls the persisted `PlayerPowerupLoadoutStore` snapshot and issues the same `loadoutPrepared` signal so both dashboards hydrate through identical pathways.
27. Dashboards confirm their UI is ready by firing `powerupDataLoaded(dashboardIndex)` once their `Repeater` (or ListView equivalent) finishes binding. The scene tracks those acknowledgements in two booleans (`powerupsLoaded0`, `powerupsLoaded1`) that default to `false` until explicitly set.
28. When both booleans are `true`, the scene generates independent deterministic seeds (range 1–500) via its `SeedRngHelper`. Each dashboard exposes a `setBlockSeed(seedValue)` invokable that stores the seed and acknowledges completion by emitting `seedConfirmed(dashboardIndex, seedValue)`.
29. The scene waits until both dashboards emit `seedConfirmed` before invoking `initializeGame()`. Initialization connects every high-level signal (`setSwitchingEnabled`, `setFillingEnabled`, `beginFilling`, `beginTurn`, `turnEnded`, `setLaunchOnMatchEnabled`, `activatePowerup`) through the scene so dashboards never talk to each other directly.
30. With wiring complete, the scene broadcasts `requestInitiativeRoll()` to both player controllers. Each controller responds with `initiativeRolled(dashboardIndex, rollValue)` using a random range of 1–5 000 000. Ties trigger another roll until one dashboard wins; the scene records the winner and sets `activeDashboardIndex` accordingly.
31. The scene clears the waiting banner, tells the active dashboard to `beginTurn()`, and notifies the opposing dashboard that it is observing. From this point forward all game state changes flow strictly through queued signals so order of operations remains deterministic.

##### Blocks
32. `Block.qml` now derives from `AbstractGameElement`, so drops, launches, and collisions use the engine’s tween helpers rather than bespoke JavaScript animations. `BlockAnimationStateMachine` remains the visual layer, responding to engine-driven state changes.
33. Sprite atlases still originate from `BlockSpriteRepository`, but blocks request sequences through engine callbacks so sprite selection stays data-driven while leaning on the unified tween pipeline.
34. Interaction gates (`interactionEnabled`, `inAnimation`) are toggled inside the engine-managed tweens. `GameGridElement` simply mirrors desired intent, letting the engine keep authoritative timing for swap eligibility.

##### Game Board Simulation
35. A dedicated `GameGridOrchestrator` C++ element owns the fill/compact/match loop. `GameGridElement` forwards high-level cues to it and reacts to orchestration signals that describe which blocks to move, spawn, or launch.
36. During filling, the orchestrator pre-compresses columns toward the arena centre, pulls deterministic spawn specs from its seeded pool, and emits `queueDrop` commands. Blocks animate via engine tweens so the top grid drops downward while the bottom grid rises into view without ad-hoc animations.
37. Compaction advances only after every drop tween reports completion. The orchestrator processes one cell per tick toward the opponent, again dispatching tween instructions so motion cadence stays deterministic.
38. Match detection and launch scheduling also live in C++. The orchestrator issues `queueLaunch` directives that blocks convert into launch tweens and waits for completion acknowledgements before resuming filling.
39. Because orchestration runs inside the engine, async ordering is guaranteed. `GameGridElement` becomes a thin view that relays orchestrator signals to the dashboards while controllers consume clean lifecycle events (`fillCycleStarted`, `cascadeCompleted`, etc.).
40. Additional client-side timers exist only for presentation (e.g., HUD updates); game-state progression is anchored in the orchestrator to keep both dashboards perfectly synchronized.

##### Turn Management and CPU Behavior
41. Swaps arrive via `swapBlocks(row1, column1, row2, column2)`. The grid only executes the swap if its state is `match` and no block is animating; successful swaps immediately push the state back into `match` so the standard fill/compact/match loop resumes.
42. When `match` completes without finding additional matches, the grid checks remaining swaps. If the active player has no swaps left, the grid emits `turnEnded(dashboardIndex)` and disables cascading on itself until the opponent finishes their cascade chain.
43. The opposing grid, upon receiving `turnEnded`, enables cascading, resets its available swaps to three, and begins compacting/filling until its board stabilizes in the `match` state.
44. Once the opponent's first cascade completes, the scene enables swapping for that dashboard and tells the corresponding controller (CPU or remote player) to make a move.
45. `CpuPlayerController` responds by requesting a serialized snapshot of its grid (`serializeElements()` restricted to blocks). It evaluates every legal adjacent swap, scoring each outcome for potential matches. When it finds the highest-value move it issues `requestSwap(row1, column1, row2, column2)` and waits for the grid to finish cascading before consuming another swap.
46. After each cascade the CPU decrements its internal `swapsRemaining`. When the counter hits zero—or no legal swaps remain—it emits `turnComplete(dashboardIndex)`. The scene relays that to the opposing dashboard, restarting the state machine described above so play alternates cleanly.

47. Dashboards expose explicit `bindOrchestratorSignals(index)` helpers so `SinglePlayerMatchScene` can connect orchestration events to the correct HUD without guessing. Every high-level cue therefore travels from controller → scene → orchestrator → dashboard in a single, ordered chain.
48. Player controllers maintain persistent references to their dashboards (and vice versa) to keep swap toggles, turn summaries, and orchestrator messages aligned with the correct side. The association is established once during scene initialization and reused across rematches.
49. When a dashboard receives `beginFilling` it merely calls `orchestrator.beginFill(dashboardIndex, fillDirection)`. The C++ orchestrator handles compression toward the centre, spawn pooling, and tween dispatch; the dashboard listens for engine callbacks to update HUD state.
50. Blocks remain one-per-cell, but creation now flows through the engine. The orchestrator instantiates new `Block` elements via the factory and queues tweens relative to the dashboard’s orientation, eliminating ad-hoc column loops in QML.

##### Blocks
51. Each `Block` surfaces invokables like `queueDropTo(cellIndex)` and `queueLaunch(vector)` that simply wrap engine tween helpers. Visual state changes (matched, charging, launched, destroyed) trigger `BlockAnimationStateMachine` updates, keeping the QML clean and declarative.
52. Sprite atlases still drive the look: powering up, projectile flight, and explosions reuse the existing sheets, but the selection now occurs inside the `Block` engine callbacks so behaviour remains centralized and consistent.
53. Blocks also must detect mouse events for switching when enabled, so they must be updated as to whether they are allowed to be interacted wth or not by the Game Grid

##### Game Board
54. `GameGridElement` forwards `beginFilling` to the orchestrator, which flips the logical state to `fill`, pre-compresses columns toward centre court, and issues deterministic `queueDrop` commands for any empty cells.
55. The orchestrator watches engine-managed drop acknowledgements before transitioning to `compact`. Compaction runs one cell per tick toward the opposing player and only concludes when every column is stable.
56. Once compacted, the orchestrator performs horizontal and vertical match scans. A non-empty result queues launches; an empty result loops back into fill. All state transitions are surfaced to QML via concise signals (`fillCycleStarted`, `compactionComplete`, `launchQueued`).
57. Launch handling is orchestrator-driven: it emits `queueLaunch` events, tracks completion from each `Block`, and finally broadcasts `cascadeCompleted` so dashboards and controllers advance the turn.

##### Block
58. Blocks expose invokables that wrap engine tweens (`queueDropTo`, `queueLaunch`, `queueDamage`) and invoke `BlockAnimationStateMachine` updates so visuals mirror the orchestrator without bespoke JavaScript animation code.

##### Game Board
59. Swap requests (`requestSwap`) still originate from `GameGridElement`, but validation, execution, and the ensuing fill/compact/match loop are orchestrated in C++. Dashboards listen for orchestrator signals to unlock or lock interaction.
60. End-of-turn behaviour hinges on orchestrator callbacks (`swapBudgetDepleted`, `cascadeCompleted`), giving controllers deterministic points to hand control to the opponent.
72. If match has no matches, and the GameGrid blocks are not animating, then  this point the swaps remaining is 0 issue a signal to the other Game Grid stating that the turn has been ended for this Game Grid which in turn results in Cascading being disabled for this Game Grid as well as swapping being disabled. 
73. once the signal is sent informing that a Game Grid has finished their turn, the other Game Grid instance should detect that signal and enable cascades. 
74. After enabling cascades on the opponent Game Grid, the opponent Game Grid state should be set to compact which will trigger the infite loop system of compact, fill, match, launch, compact, fill, match, launch, and on and on.
75. Also, the opponent Game Grid should be given 3 swaps that they can make, and enable swapping once the Game Grid is in match state and has no mathes and no animations happening, which will be available to be used by the CPU (or remote player) depending on who the other player is. 
76. Once its the opponent's turn and their grid has completed at least one full cascade (or more depending on if any matches come up during the match state), but once the cascade is completed, then the CPU's Game Grid should be set to allow swaps to happen. 
77. The CPU Player will be sent a signal to make one move, which will cause the CPU player object to request the block data from the Game Grid, which will show all the available blocks on Game Grid 1 to the CPU by sending a signal containing the block data (row, col, color) for all blocks.
78. The CPU player will iterate through each grid position, searching each possible direction that the block can swap (up down left or right) and then check to see if there are any 3+ in a row or column when making that switch.  Once it finds a valid swap, it sends a signal to GameGrid 1 to make that swap then waits until cascading finishes (using timers) from that move and decrease moves remaining by 1 
79. Once cascading finished and sends the cascade finished signal, then the CPU will check to see if it has any moves remaining (out of its 3 moves), it will proceed to find a swap and make it 
80. After all 3 CPU swaps are made and all cascades are fully completed, then endTurn signal is sent which is picked up by Game Grid 0, which then cascades its blocks starting with comact and continuing on matching and launching etc (using timers) until no matches exist when the state changes to "match" at which point Game Grid 0 unlocks and swaps are allowed for Game Grid 0. 
#####  Game Board / Powerups
81. When the active player still has swaps remaining, both grids are idle, and at least one of their four powerup cards is fully charged, that player may drag a charged card from the Powerup HUD onto any empty-friendly cell (never onto the opponent's grid) to deploy the powerup instead of performing a swap.
82. Dropping a powerup onto the board replaces the two horizontal blocks beneath it with the powerup entity; those cells are no longer considered matchable blocks for the purposes of the match-3 rules.
83. Each powerup card may be dragged onto its owner's grid at most once per game; up to four powerups can be deployed sequentially provided no cascades are active, the player still has swaps remaining, and no other powerup ability is firing.
84. Deploying a powerup card immediately resolves its ability using the stored powerup data (target owner, affected type, HP adjustments, and block selection); block targets either lose or gain health (including deployed powerup cards) according to the ability's color/amount and target rules.
85. After a powerup ability fires, that powerup card's current charged energy resets to 0 and must be recharged again up to the powerup card's energy level property by matching, but the deployed powerup tile remains on the grid permanently.
86. Clicking on a Powerup Card from the PowerupHud when that card has alreeady been deployed to the Game Grid, if the player has more than 0 swaps available and the Game is not in a cascading state (fill, match, launch, compact), if the Powerup Card that was clicked on is fully charged, then it will activate the Powerup Card's ability and reset that Powerup Card's charged energy back to 0.
87. Anytime a Powerup Card is activated and the powerup is targetting Blocks on either player's grid, the blocks which are affected will either show an explosion if the block is destroyed  in the process, display a temporary glowing affect if the block gains HP, or a small shake animation where the block just jitters for a half second if the block is damaged but not destroyed. 
  
 

## Rules
1. Both players start off with 2 complete grids of blocks which have no instances of 3 matching blocks of the same color either horizontally or vertically (adjacently) anywhere on their Game Grid 
2. One player is attacking, the other defending.  
3. The attacking player's GameGrid is allowed to switch any block with another block that is directly adjacent to it as long as making that switch will result in 3 blocks all of the same color being adjacent to each other either horizontally or vertically
4. after the switch is made, the Game Grid does not accept input or switches temporarily, but will clear any matches, launch those blocks, and after launching all blocks, will fill in the empty spaces by dropping blocks down to fill in (or raiing blocks up depending on orientation) and continue to infinitely cascade and launch any matches that occur, followed by a fill in until no matches exist. This is where the "switch move ends" and if a player has more than 0 switches remaining, the board will now unlock and let them switch again as long as all cells have a block in them and no match-3 matches are pressent and no block launch animations are in progress. 
5. All blocks that are 3 or more in a row or column and next to each other without any other blocks of different color in between will begin the launch animation which ultimately causes the blocks to be launched at the opponent's GameGrid
6. All matches will be launched and all animations (explosion on the opponent's game grid will fully complete, and at which point all remaining blocks on the attacker's GameGrid will fill by dropping down (or rising up) depending on the orientation of the GameGrid so that there are no floating blocks (blocks with spaces beneath them where blocks have launched after matching)
7. Once all blocks have fully filled in all spaces beneath them, then blocks will be pulled from a predetermined poool of blocks in order and drop in from the above the grid simultanously (or in rapid succession) until all of the GameGrid rows and columns (cells) have one block in them.
8. Once the GameGrid is full, then the process of checking for matches and launching any matches occurs again, followed by the waiting for launch animations and then filling in and finally refilling of blocks. 
9. The whole process will repeat and continuously launch blocks at the enemy until there are no 3-in-a-line matches anywhere on the attacker's GameGrid and the game grid has no blocks in every cell with no active animations (no launches) happening.
10. once there are no further matches, animations, or empty cells, then the game move is complete. The attacker's gamegrid will accept input again and then the attacker can make another switch which will kick off the whole process again from steps 4 thru 9.
11. Each player gets 3 moves, then after the moves and animations are fully completed, and the attacker's board is filled in, the attacker becomes the defender. 
12. When defending, the defender's GameGrid does not fill in blocks.  Blocks just stay in position and are destroyed by the attacker's launched blocks. After the attacker completes all 3 moves and all animations etc have completed, and their grid is completely filled in with no matches or launches happening, then the defender's board will fill in and launch any matches, followed by the fill in / check matches / launch matches / fill in loop
13. Once the defender's board is fully filled in with no more animatons or matches, then now the defender becoems the attacker and attacker becomes defender, repeating the entire process forever until one player's life reaches 0.
14. Life is taken from a player when all of their blocks in a column  are destroyed (which is controlled by the amount of power the blocks have when launched versus the amount of power each block has when hit by the launch).  When all blocks on a defender's grid are destroyed, any additional blocks in that column launched will damage the player directly. 
15. Blocks can be damaged and powered up by Powerups. Powerups can be customed to damage enemy blocks or players,  or can be setup to grant power to blocks either by color or by pre-selecting specific cell locations to power up or damage on either their own grid or the enemy grid. Powerups each have a color that matches one of the game colors which can be chosen as well. 
16. Depending on how much power the powerup is calling on (more blocks affected * more power amount = more required energy), each player will have to match blocks of the same color as that powerup in order to charge up its temporary magic energy before the Powerups can be used.  
17. The amount of damage done to an opponent's blocks or directly to the player is converted directly into energy of the color of the block that was launched.  
18. Launching a yellow block with 10 power that destroys 2 green blocks with 5 points each would result in 10 yellow energy being added to all yellow Powerups
19. Once a powerup reaches the amount of required energy, it can be activated by dragging it onto the gamegrid from the powerup hud and placed on the board (only for the first activation). 
20. Once on the board, it can be damaged by enemy blocks or enemy powerups just like any other block with its health being equivalent to its max energy to start. Powerups are not counted towards match-3 matches, and always are considered not matching color despite them possibly havig the same colors as other blocks or powerups. 
21. Powerups can move one square in any direction but it costs one move to do so. 
22. When powerups are activated, their magic energy is set to 0 and must be refilled before they can activate again.  
23. once killed, Powerups cannot be revived and will disappear from the board like any other block. 
24. Powerups should not drop down with the other blocks that fill in.  Their position should remain static and blocks should merely skip over them and consider cells with powerups to be occupied and blocks should continue on past them or stop if there are no empty spaces beneath the powerups.
25. Hitting a defender's powerup with a launched block or  other powerup attack will cause the powerup to be moved from its static position down to the lowest empty space on the defender's GameGrid. This is to allow for powerups to be pulled out of defensive positions behind many blocks to break up defensive positions. 
26. Activating a powerup does not use a move.
27. Powerups can only be activated or moved when attacking, never while defending. 
 
