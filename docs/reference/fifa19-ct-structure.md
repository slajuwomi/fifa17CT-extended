# FIFA 19 Career Mode Cheat Table Structure

Full structural reference for `FIFA19.CT` located at `FIFA-19---Career-Mode-Cheat-Table/FIFA 19 - CM Cheat Table/FIFA19.CT`.

## TCEForm GUI Forms

Six forms are defined at the top of the file (lines 4-10), encoded in Ascii85 format:

| Form Name | Class |
|-----------|-------|
| MainWindowForm | TCEForm |
| SettingsForm | TCEForm |
| PlayersEditorForm | TCEForm |
| MatchScheduleEditorForm | TCEForm |
| TransferPlayersForm | TCEForm |
| UpdateForm | TCEForm |
| MatchFixingForm | TCEForm |

Form lifecycle:
- Line 89: `MainWindowForm.show()` — shown on table load
- Line 90: `MainWindowForm.bringToFront()`
- Line 94: `MainWindowForm.hide()` — hidden on table close
- Line 95: `PlayersEditorForm.hide()`

---

## Lua Architecture

The entire GUI and much of the logic is driven by Lua scripts. Files in `lua/` directory:

```
lua/
├── main.lua              # Entry point, orchestrates everything
├── helpers.lua           # AOB definitions, memory read/write wrappers
├── consts.lua            # Constants (team IDs, league IDs, etc.)
├── commons.lua           # Shared utilities
├── loc.lua               # Localization strings
├── fut_requests.lua      # FUT web API requests (unrelated to career mode)
├── requirements/         # Dependency checks
│   └── ...
└── GUI/
    ├── consts.lua        # GUI-specific constants
    ├── helpers.lua       # GUI helper utilities
    └── forms/
        ├── playerseditorform/
        │   ├── helpers.lua    # Player data loading/saving
        │   ├── events.lua     # Form event handlers
        │   └── ...
        ├── transferplayersform/
        │   ├── helpers.lua    # Transfer form logic
        │   ├── events.lua     # Transfer form events
        │   └── ...
        ├── updateform/
        │   └── helpers.lua
        └── ... (other forms)
```

---

## Key Lua Files

### helpers.lua — AOB Signature Definitions

Central registry of AOB patterns. Each pattern is keyed for lookup by AA scripts.

**Release-related AOBs (lines 535-549):**
```lua
AOB_UnlimitedPlayerRelease = '39 46 54 40 0F 9C C7'
AOB_ReleasePlayerMsgBox   = '4C 8B E0 85 FF 0F'
AOB_ReleasePlayerFee      = '8B D8 48 8B 45 77'
AOB_EditReleaseClause     = '8B 48 08 83 F9 FF 74 06 89 8B'
```

**Base pointer AOB (line 616):**
```lua
AOB_BASE_FORM_MORALE = "E8 ?? ?? ?? ?? 48 89 35 ?? ?? ?? ?? 41 B8 01 00 00 00"
```
This base pointer is used to access player morale, form, and release clause data.

---

## Free & Unlimited Releasing Players Script

### Description
- ID: 1626
- Title: "Free & Unlimited Releasing Players"
- "You can release as many players from your team as you want. But of course you need to have at least 18 players. Releasing players will also be free."
- How to use: 1. Activate script. 2. Release player.

### Injection Point 1: UnlimitedPlayerRelease

**AOB**: `39 46 54 40 0F 9C C7`
**Injection address**: `cm_ap_release_releasetoomanyplayers` (FIFA19.exe+42E2868)

Original code:
```asm
cmp [rdi+54], eax       ; Compare release count with limit
setl dil                 ; Set flag if limit exceeded
```

Modified code:
```asm
mov [rdi+14], #999       ; Override max player release limit
mov [rsi+54], #0         ; Zero the cost
mov eax, [rdi+14]        ; Return the overridden value
; Original: mov dil, 1
```

### Injection Point 2: ReleasePlayerMsgBox

**AOB**: `4C 8B E0 85 FF 0F`
**Injection address**: FIFA19.exe+38A67EB

Original code:
```asm
mov r12, rax             ; Load the cost value
test edi, edi            ; Test some condition
```

Modified code:
```asm
xor r13, r13             ; Zero out cost display
; Original: mov r12,rax ; test edi,edi
```

This is cosmetic — makes the release confirmation dialog show $0.

### Injection Point 3: ReleasePlayerFee

**AOB**: `8B D8 48 8B 45 77`

Original code:
```asm
mov ebx, eax             ; Load the fee amount
mov rax, [rbp+77]        ; Load something else
```

Modified code:
```asm
xor eax, eax             ; Zero out the fee
; Original: mov ebx,eax ; mov rax,[rbp+77]
```

This is functional — actually prevents the fee from being charged.

---

## Change Release Clause Value to $1

### Description
- Title: "Change Release Clause value to 1$"
- Changes release clause of all shortlisted players to $1
- AOB: `8B 48 08 83 F9 FF 74 06 89 8B`
- Injection: FIFA19.exe+3EE434A

Modified code:
```asm
mov [rax+08], #1         ; Set release clause to 1
; Original: mov ecx,[rax+08] ; cmp ecx,-01
```

---

## ContractNeg — Release Clause Memory Record

Memory record ID 1462 with description "Release Clause":
- Variable type: 4 Bytes
- Address: `ContractNeg_ReleaseClause`
- Written via AA injection from contract negotiation code at `[rax+8]`

---

## playerseditorform Lua Functions

### get_player_release_clause_addr(playerid)
- Location: `lua/GUI/forms/playerseditorform/helpers.lua` (lines 354-381)
- Walks pointer chain from `basePtrTeamFormMorale`:
  - `basePtrTeamFormMorale` → `[0x0]` → `[0x10]` → `[0x40]` → `[0x28]` → `[0x1D8]`
  - Iterates a 0xC-sized array at this base + `0x2C8`
  - Each entry: `{playerid, teamid, release_clause}` (3 x 4-byte integers)
- Returns the address of a matching entry for the given player ID

### load_player_release_clause(playerid)
- Lines 524-536
- Calls `get_player_release_clause_addr()`
- If found, reads value at `addr+0x8` and populates `PlayersEditorForm.ReleaseClauseEdit.Text`
- If not found, sets text to "None"

### save_player_release_clause(playerid)
- Lines 676-743
- Handles three modes: `add_clause`, `remove_clause`, `edit_clause`
- Validates release clause <= 2147483646
- Prompts for team ID via `inputQuery()`
- On add: extends the clause list by copying+appending
- On remove: shifts remaining entries to compact
- Writes `{playerid, teamid, release_clause}` struct at the target address

---

## Transfer Players Form — Release Clause

### Creating the GUI field
- `lua/GUI/forms/transferplayersform/helpers.lua` lines 272-300
- Creates a Label "Release Clause:" and Edit control named `ReleaseClauseValue{N}`
- Part of the custom transfer panel

### Reading/writing release clause in transfers
- `lua/GUI/forms/transferplayersform/events.lua` line 101: reads from GUI field
- Line 116-118: writes to `arr_NewTransfers` array at offset `+16` within each 20-byte transfer entry
- The transfer entry struct is 20 bytes (0x14): offset `+16` = release clause (4 bytes)

---

## Key Differences from FIFA 17 CT

| Aspect | FIFA 17 CT | FIFA 19 CT |
|--------|-----------|-----------|
| Lua scripts | None — pure XML/AA | Extensive Lua architecture |
| GUI | None | 6 TCEForms with full GUI |
| Script structure | Flat, all under ActivateItFirst | Modular, Lua-orchestrated |
| AOB management | Inline in each script | Centralized in helpers.lua |
| Form support | None | Full form system with events |
| Player name editing | Separate AA scripts with ptr capture | Integrated into GUI |
| Release feature | Not present | Full 3-injection script |
| Release clause editing | Not present | Full add/remove/edit in GUI |
| Custom transfers | Not present | Custom transfer system with GUI |

---

## offsets.ini

Located at `FIFA-19---Career-Mode-Cheat-Table/FIFA 19 - CM Cheat Table/offsets.ini`:

```ini
[offsets]
AOB_DatabaseRead=DE056A0
AOB_codeGameDB=19DC274
AOB_screenID=1391618
```

Minimal — only 3 offsets defined. Most offsets are in helpers.lua.

---

## Users Lua Scripts

Located in `users lua scripts/`:
- `is_retiring=0.lua` — sets retirement flag to 0
- `make everyone 16 (or any other age).lua` — age modification
- `medium_socklenghtcode.lua` — sock length script
- `randomize_shoe_models.lua` — randomize shoe models
- `randomize.lua` — randomize various attributes
- `untuck_shirts.lua` — untuck shirt models

None of these contain release-related code.
