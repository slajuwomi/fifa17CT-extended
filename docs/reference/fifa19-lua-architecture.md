# FIFA 19 Lua Architecture

How the FIFA 19 Cheat Table Lua codebase is organized and how the GUI system works.

## Entry Point: main.lua

`lua/main.lua` is executed when the cheat table is loaded. It orchestrates:
1. Loading `commons.lua` and `consts.lua`
2. Running requirement checks from `lua/requirements/`
3. Loading helpers.lua for AOB definitions
4. Initializing all 6 TCEForms
5. Setting up form event handlers
6. Loading localization strings from `loc.lua`
7. Showing the MainWindowForm

## Form Architecture

Each TCEForm lives in its own subdirectory under `lua/GUI/forms/`:

```
lua/GUI/forms/
├── playerseditorform/
│   ├── helpers.lua     # Data loading: reads player from memory, populates form fields
│   └── events.lua      # Event handlers: button clicks, text changes, apply/save
├── transferplayersform/
│   ├── helpers.lua     # Creates the transfer GUI panels dynamically
│   └── events.lua      # Handles add/delete/confirm transfer operations
├── updateform/
│   └── helpers.lua     # Update checker logic
└── ... (MainWindow, Settings, MatchSchedule, MatchFixing)
```

### Pattern: helpers.lua + events.lua

Every form follows this split:
- **helpers.lua**: Contains all functions that read from or write to game memory. These are the "model" layer — they load data from the FIFA process into Lua variables, and write changes back.
- **events.lua**: Contains TCEForm event handlers (button clicks, text changes). These are the "controller" layer — they call helpers.lua functions in response to user actions.

### Form Lifecycle

1. Form is defined in the CT file as Ascii85-encoded TCEForm XML
2. On table load, main.lua calls the form's init function
3. The init function creates form components, sets up event handlers
4. When a player is selected in-game, the form loads that player's data
5. User edits values in the form
6. On "Apply" button click, events.lua calls save functions in helpers.lua
7. save functions write modified values back to game memory

## PlayersEditorForm — Detailed Walkthrough

### Components (in the form XML)
- Player search/filter controls
- Player info display (name, OVR, potential, position, etc.)
- Attribute groups (same categories as FIFA 17 CT)
- Release Clause section
- Fitness section
- Morale section
- Form section
- Apply Changes button

### Data Loading Flow

When a player is selected:
1. `load_player_general_data(playerid)` — loads OVR, potential, age, height, weight, etc.
2. `load_player_attributes(playerid)` — loads all 30+ attribute scores
3. `load_player_release_clause(playerid)` — loads release clause amount
4. `load_player_fitness(playerid)` — loads fitness data
5. `load_player_morale(playerid)` — loads morale data
6. `load_player_form(playerid)` — loads match form data

Each load function reads from game memory via `readInteger()`, `readString()`, etc.

### Data Saving Flow

When "Apply" is clicked:
1. `save_player_general_data(playerid)` — writes modified values
2. `save_player_attributes(playerid)` — writes all attributes
3. `save_player_release_clause(playerid)` — writes release clause
4. `save_player_fitness(playerid)` — writes fitness changes
5. `save_player_morale(playerid)` — writes morale changes
6. `save_player_form(playerid)` — writes form changes

## TransferPlayersForm — Detailed Walkthrough

### Custom Transfer System
- Allows creating transfers between any two clubs
- Each transfer has: player ID, from team, to team, transfer fee, release clause
- Transfers are stored in an in-memory array (`arr_NewTransfers`)

### Transfer Entry Structure
Each entry is 20 bytes (0x14):
```
Offset 0x00: player_id    (4 bytes)
Offset 0x04: from_team_id (4 bytes)
Offset 0x08: to_team_id   (4 bytes)
Offset 0x0C: fee          (4 bytes)
Offset 0x10: release_clause (4 bytes)
```

### GUI Panel Creation
- `transferplayersform/helpers.lua` dynamically creates a scrollable panel for each transfer
- Each panel has: Player ID, From Team, To Team, Fee, Release Clause fields, plus Delete button
- Panels are named `NewTransferContainerPanel{N}` with child controls indexed by `{N}`

## Memory Access Pattern

All memory access goes through Cheat Engine's Lua API:
- `readInteger(address)` — read 4-byte integer
- `writeInteger(address, value)` — write 4-byte integer
- `readString(address, max_length)` — read string
- `writeString(address, value)` — write string
- `readBytes(address, count)` — read raw bytes
- `getAddressSafe(address_string)` — resolve symbol/module+offset to address

## AOB System

### Registration
AOB patterns are registered in `helpers.lua` as Lua table entries with string keys. The CT file's AA scripts reference these keys. When an AA script needs an AOB, it looks up the key in helpers.lua.

### Pattern Format
Standard space-separated hex bytes with `??` for wildcards. Example: `'E8 ?? ?? ?? ?? 48 89 35 ?? ?? ?? ?? 41 B8 01 00 00 00'`

### Resolution
Cheat Engine resolves AOB patterns at runtime when the AA script's `[ENABLE]` section runs. If the pattern matches multiple locations, it fails. The matched address becomes the injection point.

### Dependencies
AOB patterns can depend on each other. For example, `AOB_BASE_FORM_MORALE` must be found before the release clause functions can work, because they use the resolved address as a base pointer.

## TCEForm Event System

### Standard Event Handlers
- `OnShow` — form is displayed
- `OnClose` — form is hidden
- `OnClick` — button clicked
- `OnChange` — text field changed
- `OnKeyPress` — key pressed in form

### Pattern Example
```lua
function ApplyButtonClick(sender)
    local playerid = get_current_player_id()
    save_player_general_data(playerid)
    save_player_attributes(playerid)
    save_player_release_clause(playerid)
    -- ... more saves
end
```

## Input/Output Dialogs

Used for user interaction:
- `inputQuery(caption, prompt, default)` — modal text input
- `showMessage(message)` — modal message dialog
- Note: these block the CE main thread in the FIFA 19 table (all TCEForms run on main thread)

## Localization

`lua/loc.lua` contains locale-specific strings. The table supports English and potentially other languages.

## Key Design Patterns

1. **Separation of concerns**: helpers.lua (data) vs events.lua (UI events)
2. **Centralized AOB registry**: All patterns in one file, keyed for lookup
3. **Dynamic form creation**: Transfer panels are created programmatically rather than in form XML
4. **Pointer chain navigation**: Deep pointer chains are common (e.g., the 5-level chain for release clauses)
5. **Form lifecycle management**: show/hide coordinated with table load/unload
