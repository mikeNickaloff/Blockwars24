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
- TODO [Step 32]: Ensure GameGridElement creates Block components through a Component factory so every block shares the behavior tree.
- TODO [Step 33]: Implement BlockAnimationStateMachine to map block states (idle, matched, launching, etc.) to sprite-sheet sequences from BlockSpriteRepository.
- TODO [Step 34]: Maintain interactionEnabled and inAnimation flags on blocks, toggled by the grid and animation state machine to protect timing-sensitive logic.
- TODO [Step 35]: Handle the beginFilling state by spawning new blocks via BlockFactory into virtual row -1 and animating them into place while tracking timers.
- TODO [Step 36]: Provide settleSpawnedBlocks routines that wrap block drops in SequentialAnimation and correctly flip inAnimation markers.
- TODO [Step 37]: Gate fillTimer on animation completion and transition to the compact state once row 0 is gap-free.
- TODO [Step 38]: Implement compactTimer to compress columns one cell at a time toward the defender, respecting orientation and animation guards.
- TODO [Step 39]: Create matchTimer to search for horizontal and vertical runs, populate matchList, and emit cascadeEnded when no matches remain.
- TODO [Step 40]: Build launchTimer to iterate over matchList, trigger block.launch(), track launchCount, and revert to compact once all launches finish.
- TODO [Step 41]: Execute swapBlocks only when the grid is in the match state with no animations, dropping immediately back into match processing on success.
- TODO [Step 42]: When matches exhaust and swaps run out, emit turnEnded for the active dashboard and freeze cascading until the opponent finishes.
- TODO [Step 43]: Upon receiving turnEnded, enable cascading on the opposing grid, reset swaps, and process fill/compact loops until stable.
- TODO [Step 44]: After the opponent's first cascade, re-enable swapping and inform the corresponding controller to choose a move.
- TODO [Step 45]: Have CpuPlayerController evaluate serialized grid snapshots, score all legal swaps, emit requestSwap, and wait for cascades before continuing.
- TODO [Step 46]: Decrement CPU swaps after each cascade and emit turnComplete when no swaps remain or no legal moves exist.
- TODO [Step 81]: Allow charged powerup cards to be dragged onto friendly grid cells only when swaps remain and no cascades are underway.
- TODO [Step 82]: Replace the targeted two horizontal blocks with the deployed powerup entity and exclude those cells from match logic.
- TODO [Step 83]: Enforce one deployment per card while permitting sequential activations as long as cascades are idle and swaps remain.
- TODO [Step 84]: Resolve powerup abilities against their configured targets, applying damage or healing and triggering the appropriate animations.
- TODO [Step 85]: Reset the card's current energy to zero after activation while keeping the board entity alive and ready for recharge via matches.
- TODO [Step 86]: Permit re-activation of deployed powerups when charged, clicking instead of dragging if already on the board, and reset energy afterward.
- TODO [Step 87]: Trigger explosion, glow, or shake feedback on affected blocks depending on whether they are destroyed, healed, or damaged without destruction.





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
32. `GameGridElement` never spawns raw rectangles. Instead, it instantiates `Block.qml` entities through a `Component` factory so every block inherits the same behavior tree. Each block owns a `BlockAnimationStateMachine` helper that maps logical states (idle, matched, preparingLaunch, launching, airborne, colliding, exploding, filling, waiting, defeated) to sprite-sheet frame ranges and transitions.
33. The sprite system loads atlases once through `BlockSpriteRepository`. Individual blocks request their sequence by logical action; the repository hands back a `SpriteSequence` object so blocks never hardcode URLs. Launch-to-impact flows reuse a single sheet, while explosions trigger `BlockExplodeParticle` emitters routed through the grid's particle overlay layer.
34. Blocks expose `interactionEnabled` and `inAnimation` flags. The grid toggles `interactionEnabled` when swaps are legal; the animation state machine is responsible for toggling `inAnimation` whenever an animation begins or ends so timers can make safe decisions.

##### Game Board Simulation
35. Receiving `beginFilling` places the grid into the `fill` state and arms `fillTimer`. The timer inspects row 0 for null entries. For each empty column it requests a new `Block` from `BlockFactory`, seeds it at virtual row -1, and pushes it into the grid matrix.
36. After populating row -1, the grid calls `settleSpawnedBlocks()` which steps each newcomer to its real row while marking `inAnimation = true`. Blocks animate downward via a `SequentialAnimation` on `y` that begins with `ScriptAction { inAnimation = true }`, runs the `NumberAnimation`, and ends with `ScriptAction { inAnimation = false }`.
37. `fillTimer` first checks whether any block still reports `inAnimation = true`. If so, it defers work until animations finish. When the entire grid is stable and row 0 contains no gaps, the grid flips to the `compact` state.
38. `compactTimer` runs while the state is `compact`. It skips processing whenever a block is mid-animation. Otherwise it scans from the interior toward the opposing player (row 5→0 for the top grid, 0→5 for the bottom grid) and moves blocks one cell per tick using `compressColumnStep()` so motion stays orderly. Once every column is compacted the grid re-enters `fill`.
39. When `fill` and `compact` no longer discover work, the grid transitions to `match`. `matchTimer` again guards on `inAnimation`, then searches for horizontal and vertical runs using the grid's helper algorithms. Matching blocks populate `matchList`; a non-empty list pushes the state to `launch`, otherwise the grid enters `idle` and emits `cascadeEnded` to signal that the turn may end.
40. `launchTimer` dequeues blocks from `matchList`, calls their `launch()` method, and increments `launchCount`. Once every match has launched, the timer waits until `launchCount` returns to zero (blocks decrement the counter when they finish colliding) before swapping the state back to `compact`.

##### Turn Management and CPU Behavior
41. Swaps arrive via `swapBlocks(row1, column1, row2, column2)`. The grid only executes the swap if its state is `match` and no block is animating; successful swaps immediately push the state back into `match` so the standard fill/compact/match loop resumes.
42. When `match` completes without finding additional matches, the grid checks remaining swaps. If the active player has no swaps left, the grid emits `turnEnded(dashboardIndex)` and disables cascading on itself until the opponent finishes their cascade chain.
43. The opposing grid, upon receiving `turnEnded`, enables cascading, resets its available swaps to three, and begins compacting/filling until its board stabilizes in the `match` state.
44. Once the opponent's first cascade completes, the scene enables swapping for that dashboard and tells the corresponding controller (CPU or remote player) to make a move.
45. `CpuPlayerController` responds by requesting a serialized snapshot of its grid (`serializeElements()` restricted to blocks). It evaluates every legal adjacent swap, scoring each outcome for potential matches. When it finds the highest-value move it issues `requestSwap(row1, column1, row2, column2)` and waits for the grid to finish cascading before consuming another swap.
46. After each cascade the CPU decrements its internal `swapsRemaining`. When the counter hits zero—or no legal swaps remain—it emits `turnComplete(dashboardIndex)`. The scene relays that to the opposing dashboard, restarting the state machine described above so play alternates cleanly.

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
 
