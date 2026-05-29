# Youth Academy Feature Port — FIFA 19 → FIFA 17

## Overview

Port 13 youth academy/scout features from the FIFA 19 Career Mode Cheat Table to the
FIFA 17 CT (`FIFA_17_Cheat_Table.CT`). The FIFA 19 CT has 17 youth-related features; we
exclude 4 for complexity/risk reasons and implement the remaining 13 plus supporting
infrastructure.

**Existing FIFA 17 CT features left untouched:**
- `Free 5/5 Scout` — stays in Scouts Management group
- `Reveal GTN player data` — stays in Scouts Management group

---

## Excluded Features

| Feature | Reason |
|---------|--------|
| Generate New Report | Requires `CREATETHREAD`, complex pointer chain (`ptrBaseScripts → [+0x0] → [+0x538] → [+0x0] → [+0x20] → [+0x148]`), and a resolved function pointer. Risk 2/5. |
| Hire Scouts | Requires editing scout structs before hiring (names, nationality, etc.). Risk 3/5. |
| Custom Player ID | FIFO queue management of 15 player IDs; can crash save on duplicate. Risk 3/5. |
| Free 5/5 Scouts | Already exists in FIFA 17 CT as "Free 5/5 Scout" under Scouts Management. |

---

## Features to Implement (13 Total)

### Group: "Youth Academy"

All scripts are "Activate before you load your career mode save" type (Risk 0/5 unless
noted).

#### 1. SCOUT_REPORT_PLAYERS (ID 1264)
- **Purpose:** Control how many players the scout brings per report (default 15, max ~15)
- **Child entry:** `intScoutReportPlayers` — 4 Bytes, configurable
- **FIFA 19 AOB:** `89 06 FF C7 48 83 C6 04 83 FF 02`
- **Injection:** Replaces `mov [rsi],eax` with override from user-controlled value
- **Mechanism:** Loop writing player count; patch the value being written

#### 2. Reveal OVR & POT (ID 1266)
- **Purpose:** Immediately see true OVR and Potential without scouting
- **FIFA 19 AOB:** `89 07 FF C3 48 83 C7 04 83 FB 06`
- **Injection:** Sets OVR/POT variance values to 0 (removes hidden uncertainty overlay)
- **Mechanism:** `xor eax,eax` before the variance write (6-iteration loop)

#### 3. PRIMARY_ATTRIBUTES_RANGE (ID 2656)
- **Purpose:** Control primary attribute range for generated youth players
- **Child entries:** `primattr_rangelow` (default 10), `primattr_rangehigh` (default 20)
- **FIFA 19 AOB:** `43 89 44 F7 30`
- **Injection:** Replaces `mov [r15+r14*8+30],eax` with controlled values at `+2C` and `+30`
- **Mechanism:** Override attribute range writes with user-configured values

#### 4. SECONDARY_ATTRIBUTES_RANGE (ID 1268)
- **Purpose:** Control secondary attribute range for generated youth players
- **Child entries:** `secmattr_rangelow` (default 10), `secmattr_rangehigh` (default 20)
- **FIFA 19 AOB:** `43 89 44 F7 68`
- **Injection:** Replaces `mov [r15+r14*8+68],eax` with controlled values at `+64` and `+68`
- **Mechanism:** Same pattern as Primary but at different offsets

#### 5. MIN_PLAYER_AGE_FOR_PROMOTION = 12 (ID 2683)
- **Purpose:** Allow promoting players aged 12+ to senior team
- **FIFA 19 AOB:** `41 B8 03 00 00 00 89 85 E4`
- **Injection:** Sets `eax = 12` before the age category write (`mov r8d, 3`)
- **Mechanism:** Pre-loads EAX with desired min age before the original comparison code

#### 6. YOUTH_PLAYER_AGE_RANGE = [12, 16] (ID 1275)
- **Purpose:** Scouts find players aged 12–16
- **FIFA 19 AOB:** `41 B8 04 00 00 00 41 89 07`
- **Injection:** Writes age range low (12) to `[r15+04]` and high (16) to `[r15+08]`
- **Mechanism:** Override the generated age range values with fixed 12–16

#### 7. Youth Player Retire at Age = 30 (ID 2760)
- **Purpose:** Prevent youth players from leaving the academy
- **FIFA 19 AOB:** `41 FF C4 89 03`
- **Injection:** Forces `eax = 30` in the retirement age assignment loop
- **Mechanism:** Override the random retirement age with 30 (essentially never retires)

#### 8. 95 Potential (ID 1276)
- **Purpose:** All generated youth players get 95 potential
- **FIFA 19 AOB:** `89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48`
- **Injection:** Forces `eax = 95` before the potential write in the 2-iteration loop
- **Mechanism:** Hardcode potential value at the assignment point

#### 9. 100% Chance for 5★ Weak Foot (ID 1269)
- **Purpose:** All youth players get 5-star weak foot
- **FIFA 19 AOB:** `FF C3 89 07 48 8D 7F 04 83 FB 06`
- **Injection:** In the 6-iteration weak foot chance loop: set chance=100 when iteration=5 (5★), chance=0 otherwise
- **Mechanism:** Replace the probability distribution with 100% at max level

#### 10. Send Scout to Any Country (ID 1790)
- **Purpose:** Override the nationality of generated youth players regardless of scouting country
- **Child entry:** `ptr_YA_NatID` — 4 Bytes, configurable (0 = disabled)
- **FIFA 19 AOB:** `89 4C 24 30 B9 04 00 00 00`
- **Injection:** If `ptr_YA_NatID != 0`, override the nationality ID on stack with user value
- **Mechanism:** Conditional override of the nationality parameter before scouting

#### 11. 100% Chance for 5★ Skill Moves (ID 1270)
- **Purpose:** All youth players get 5-star skill moves
- **FIFA 19 AOB:** `89 B5 7C 01 00 00 4C`
- **Injection:** Forces `esi = 4` (0-indexed = 5 stars) before the skill moves write
- **Mechanism:** Hardcode the skill move level at the assignment point

#### 12. Set Up Multiple Scouting Networks in Same Country (ID 2659)
- **Purpose:** Bypass the "Country Is Being Scouted" popup
- **FIFA 19 AOB:** `80 FB 01 75 0C 4C`
- **Injection:** Forces jump past the popup branch (always allows same-country scouting)
- **Mechanism:** NOP out the conditional check that triggers the conflict popup

#### 13. Disable Player Regens (ID 2795)
- **Purpose:** Prevent CPU team regen generation
- **FIFA 19 AOB:** `41 BF 10 00 00 00 48 8B CE`
- **Injection:** Likely overrides a regen counter or flag
- **Mechanism:** TBD on discovery — FIFA 17 equivalent may differ

---

## Architecture

### CT Hierarchy

```
ActivateItFirst (ID 135)                 — Root entry, 3 pointer caves
├── Club Finances (ID 1)
├── NotEditable (ID 285)                  — OVR, POT, stats
├── Edit Player (ID 134)                  — Attributes, traits
├── Player Training (ID 53)
├── Scouts Management (ID 52)             — Existing: Free 5/5, Reveal GTN
├── Youth Academy (ID NEW)                — NEW: GroupHeader
│   ├── SCOUT_REPORT_PLAYERS (NEW)
│   │   └── Players per report (NEW)
│   ├── Reveal OVR & POT (NEW)
│   ├── PRIMARY_ATTRIBUTES_RANGE (NEW)
│   │   ├── Range Low (NEW)
│   │   └── Range High (NEW)
│   ├── SECONDARY_ATTRIBUTES_RANGE (NEW)
│   │   ├── Range Low (NEW)
│   │   └── Range High (NEW)
│   ├── MIN_PLAYER_AGE_FOR_PROMOTION (NEW)
│   ├── YOUTH_PLAYER_AGE_RANGE (NEW)
│   ├── Youth Retire at 30 (NEW)
│   ├── 95 Potential (NEW)
│   ├── 5★ Weak Foot (NEW)
│   ├── Scout Any Country (NEW)
│   │   └── Nationality ID (NEW)
│   ├── 5★ Skill Moves (NEW)
│   ├── Same Country Multi-Scout (NEW)
│   └── Disable Player Regens (NEW)
└── [CheatCodes, other entries]
```

### Lua Infrastructure

A new `lua/` directory at the project root provides minimal Lua support for dynamic
AOB resolution:

```
lua/
├── youth_helpers.lua     — AOB definitions + get_validated_address() equivalent
└── README.md             — (optional) documentation
```

`youth_helpers.lua` contains:

```lua
-- AOB Signature Registry for FIFA 17 Youth Academy features
-- Each AOB key maps to the byte pattern within FIFA17.exe

local aobs = {
    AOB_MoreYouthPlayers          = '89 06 FF C7 48 83 C6 04 83 FF 02',
    AOB_RevealPotAndOvr           = '89 07 FF C3 48 83 C7 04 83 FB 06',
    AOB_PrimAttr                  = '43 89 44 F7 30',
    AOB_SecAttr                   = '43 89 44 F7 68',
    AOB_MinAgeForPromotion        = '41 B8 03 00 00 00 89 85 E4',
    AOB_PlayerAgeRange            = '41 B8 04 00 00 00 41 89 07',
    AOB_YouthPlayersRetirement    = '41 FF C4 89 03',
    AOB_PlayerPotential           = '89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48',
    AOB_WeakFootChance            = 'FF C3 89 07 48 8D 7F 04 83 FB 06',
    AOB_AllCountriesAvailable     = '89 4C 24 30 B9 04 00 00 00',
    AOB_SkillMoveChance           = '89 B5 7C 01 00 00 4C',
    AOB_CountryIsBeingScouted     = '80 FB 01 75 0C 4C',
    AOB_NoPlayerRegens            = '41 BF 10 00 00 00 48 8B CE',
}

function get_validated_address(key)
    local aob = aobs[key]
    if not aob then
        error('Unknown AOB key: ' .. key)
    end
    -- Uses Cheat Engine's AOB scan internally
    -- (equivalent to aobscanmodule(INJECT, FIFA17.exe, pattern))
end
```

Each youth AA script follows this hybrid Lua+AA pattern:

```asm
[ENABLE]
{$lua}
local status, err = pcall(get_validated_address)
if not status then
    showMessage('Error: ' .. err)
    assert(false, err)
end
INJECT_YA = get_validated_address('AOB_YouthXxx')
ORG_YA = readBytes(INJECT_YA, N, true)
{$asm}
alloc(newmem_YA, $500, INJECT_YA)
// ... injection code ...
INJECT_YA:
  jmp newmem_YA
  nop (padding)

[DISABLE]
{$lua}
writeBytes(INJECT_YA, ORG_YA)
{$asm}
dealloc(newmem_YA)
```

The `{$lua}` blocks are embedded AA directives. On enable: validate → resolve AOB → save
original bytes → inject. On disable: restore original bytes → dealloc.

---

## Execution Phases

Development should move in thin vertical slices. After shared scaffolding is in place,
each phase should attempt exactly one youth academy feature: discover its FIFA 17
injection point, write only that script, integrate only that CT entry, and validate only
that feature before moving on.

### Phase 0 — Shared Scaffolding (Estimated: 1 session)

1. Back up `FIFA_17_Cheat_Table.CT` to `FIFA_17_Cheat_Table.CT.bak`
2. Create the empty "Youth Academy" GroupHeader after the Scouts Management group
3. Create `lua/youth_helpers.lua` with helper functions but no unconfirmed FIFA 17 AOBs
4. Add Lua helper loading initialization — embed in `ActivateItFirst` or as a separate init entry:
   ```lua
   {$lua}
   -- Load youth helpers
   local f = io.open("lua/youth_helpers.lua", "r")
   if f then
       local code = f:read("*a")
       f:close()
       load(code)()
   end
   {$asm}
   ```
5. Add a minimal Lua execution test to confirm Cheat Engine can load the helper from
   the external file path
6. Verify the CT file is well-formed XML
7. Load the CT in Cheat Engine and verify existing features still appear and activate

### Standard Feature Slice Checklist

Use this checklist for every feature phase below. Do not batch multiple features into
one implementation pass.

1. Launch FIFA 17 with a career mode save loaded
2. Attach MCP Bridge: `open_process("FIFA17.exe")`
3. Try the feature's FIFA 19 AOB pattern: `aob_scan_module(pattern, "FIFA17.exe")`
4. If match found and unique, disassemble around it with `disassemble(address, count=10)`
5. If no match or multiple matches, search only for this feature's equivalent code path:
   - Search related strings or nearby known constants
   - Use references to relevant data structures where available
   - Set a targeted data breakpoint if the feature can be triggered in-game
6. Document the confirmed FIFA 17 AOB, injection address, original code, and notes
7. Add only this feature's AOB key to `lua/youth_helpers.lua`
8. Write only this feature's hybrid Lua+AA script
9. Validate syntax with `auto_assemble_check(script)`
10. Test enable, in-game behavior, disable, and re-enable
11. Add only this feature's CT XML entry and child memory records, if needed
12. Reload the CT and confirm the new entry appears under "Youth Academy"
13. Update the discovery log before starting the next feature

**Discovery Documentation Template (per feature):**

```markdown
## Feature: [Name]
- FIFA 19 AOB: `xx xx xx ...`
- FIFA 17 AOB: `xx xx xx ...` (or N/A if reengineered)
- Injection address: FIFA17.exe+XXXXXXXX
- Original code context: [5-10 lines]
- Matches expected logic? Yes/No
- In-game validation: Pass/Fail/Blocked
- Notes: [any quirks]
```

### Phase 1 — SCOUT_REPORT_PLAYERS Slice (Estimated: 1 session)

Deliver only `SCOUT_REPORT_PLAYERS` and its `intScoutReportPlayers` child entry.
This is the first feature slice because it has a visible scout-report outcome and a
simple configurable value, making it a good proof of the helper + CT integration path.

### Phase 2 — Reveal OVR & POT Slice (Estimated: 1 session)

Deliver only `Reveal OVR & POT`. Validate that generated youth players show true OVR
and Potential without scouting uncertainty.

### Phase 3 — PRIMARY_ATTRIBUTES_RANGE Slice (Estimated: 1 session)

Deliver only `PRIMARY_ATTRIBUTES_RANGE` and its `primattr_rangelow` /
`primattr_rangehigh` child entries. Validate the configurable values affect generated
primary attribute ranges.

### Phase 4 — SECONDARY_ATTRIBUTES_RANGE Slice (Estimated: 1 session)

Deliver only `SECONDARY_ATTRIBUTES_RANGE` and its `secmattr_rangelow` /
`secmattr_rangehigh` child entries. Validate independently from the primary attribute
range feature.

### Phase 5 — MIN_PLAYER_AGE_FOR_PROMOTION Slice (Estimated: 1 session)

Deliver only `MIN_PLAYER_AGE_FOR_PROMOTION = 12`. Validate that a player below the
normal promotion age can be promoted while the script is active.

### Phase 6 — YOUTH_PLAYER_AGE_RANGE Slice (Estimated: 1 session)

Deliver only `YOUTH_PLAYER_AGE_RANGE = [12, 16]`. Validate new scout reports produce
players in the configured age range.

### Phase 7 — Youth Player Retire at Age 30 Slice (Estimated: 1 session)

Deliver only `Youth Player Retire at Age = 30`. Validate the generated retirement or
academy-leaving age behavior without changing age range or promotion scripts.

### Phase 8 — 95 Potential Slice (Estimated: 1 session)

Deliver only `95 Potential`. Validate generated youth players receive 95 potential
with all other youth generation modifiers disabled.

### Phase 9 — 5-Star Weak Foot Slice (Estimated: 1 session)

Deliver only `100% Chance for 5★ Weak Foot`. Validate generated youth players receive
5-star weak foot.

### Phase 10 — Scout Any Country Slice (Estimated: 1 session)

Deliver only `Send Scout to Any Country` and its `ptr_YA_NatID` child entry. Validate
both disabled behavior (`0`) and a specific nationality override.

### Phase 11 — 5-Star Skill Moves Slice (Estimated: 1 session)

Deliver only `100% Chance for 5★ Skill Moves`. Validate generated youth players
receive 5-star skill moves.

### Phase 12 — Same-Country Multi-Scout Slice (Estimated: 1 session)

Deliver only `Set Up Multiple Scouting Networks in Same Country`. Validate the
"Country Is Being Scouted" popup no longer blocks duplicate country assignments.

### Phase 13 — Disable Player Regens Discovery Slice (Estimated: 1 session)

Investigate only `Disable Player Regens`. This feature has unknown FIFA 17 behavior, so
the phase may end with a documented implementation plan instead of a CT entry if the
equivalent code path is not confidently identified.

Exit criteria:
- Confirm the FIFA 17 equivalent and proceed with the standard feature slice checklist, or
- Mark the feature blocked with evidence and leave it out of the CT until a safer
  approach is found

### Phase 14 — Cross-Feature Validation Pass (Estimated: 1 session)

Run this only after all individually validated slices are complete.

1. Load the modified CT in Cheat Engine
2. Enable `ActivateItFirst` and verify no errors
3. Enable each youth script individually once more
4. Test common combinations of scripts active simultaneously
5. Test `[DISABLE]` behavior after combination testing
6. Document any conflicts or unexpected behavior

---

## Risk Assessment

| Feature | Risk | Failure Mode |
|---------|------|-------------|
| All 0/5 scripts | Minimal | Script fails to find AOB → safe error message; no game modification |
| Disable Player Regens | Unknown | FIFA 17 regen system may differ significantly; may need different approach |
| Same Country Multi-Scout | Low | If AOB wrong, popup still appears; no crash risk |

**Mitigations:**
- Every script validates AOB on enable and shows error before any modification
- Original bytes are saved before injection for clean disable
- All scripts are independent — one failing doesn't affect others
- External Lua helpers are loaded with `pcall` to prevent CT crashes on load errors

---

## File Changes Summary

| File | Action |
|------|--------|
| `FIFA_17_Cheat_Table.CT` | Edit — add Youth Academy group + 13 script entries + child entries |
| `lua/youth_helpers.lua` | Create — AOB registry + validation function |
| `FIFA_17_Cheat_Table.CT.bak` | Create — backup before modification |

No changes to:
- `FIFA 17 - IniToCT.au3` (AutoIt tool — unrelated)
- `scout.ini`, `youth_scout.ini` (game config files — not cheat table)
- `docs/` files (already captured this plan separately)

---

## Future Considerations (Post-Port)

After the 13 core features are stable:

1. **Generate New Report** — Requires reverse engineering the YA report generation
   function call in FIFA 17 (different pointer chain offsets likely)
2. **Hire Scouts** — Requires finding the scout hiring struct/screen in FIFA 17;
   scout struct may differ in size/offsets from FIFA 19
3. **Custom Player ID** — Straightforward port if the player generation code path
   is similar; mainly risk management
4. **GUI Forms** — Player Editor GUI is already in progress as a separate PRD
