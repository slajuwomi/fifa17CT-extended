# FIFA 17 Cheat Table Structure

Full structural reference for `FIFA_17_Cheat_Table.CT` (CheatEngineTableVersion="24").

## Top-Level: ActivateItFirst (ID 135)

The root entry. Auto Assembler Script with `moHideChildren="1"`. Must be activated before anything else in the table works.

### Code Caves in ActivateItFirst

ActivateItFirst defines 3 code caves that set up global pointers used by the entire table:

| Symbol | AOB Signature | Function |
|--------|--------------|----------|
| `INJECT_ptrTransferBudgetCave` | `44 8B 48 08 41 89 F8 48 8D 55 A7` | Captures a pointer to transfer budget data. Stores in `ptrTransferBudget` |
| `INJECT_ptrPlayerCave` | `45 89 AF FC 09 00 00 41 C6` | Captures a pointer to the current player being edited. Stores in `ptrPlayer` |
| `INJECT_ptrNotEditable` | `85 F6 ?? ?? 49 29 FA 48 8B 07` | Captures a pointer to player attribute data. Stores in `ptrNotEditable` |

### Injection Details

**ptrTransferBudget cave** (`FIFA17.exe+850293B`):
- Original: `mov r9d,[rax+08]; mov r8d,edi`
- Modified: stores rax into `ptrTransferBudget`, then executes original code
- `ptrTransferBudget` → dereference → `+8` = transfer budget value (4 bytes)

**ptrPlayer cave** (`FIFA17.exe+83B3F11`):
- Original: `mov [r15+000009FC],r13d`
- Modified: stores r15 into `ptrPlayer`, then executes original
- Player pointer structure uses offset `0x9FC` among many others

**ptrNotEditable cave** (`FIFA17.exe+83C19CD`):
- Original: `test esi,esi; jle ...; sub r10,rdi`
- Modified: stores rax into `ptrNotEditable`, then executes original
- This provides access to a player's non-editable attribute array

---

## Group: NotEditable (ID 285)

Color: `004080`. Under ActivateItFirst. Contains player attributes accessed via `ptrNotEditable`.

### Pointer Structure

Address: `ptrNotEditable` → offsets `[offset*8]` → offsets `[0]`

Each attribute is at a multiple-of-8 offset within an array of 4-byte values.

### Direct Child Entries

| Description | Type | Offsets | Notes |
|-------------|------|---------|-------|
| PlayerOVR | 4 Bytes | `[41*8]`, `[0]` in the original CT; live GUI validation found the visible value at the neighboring slot for the tested save | Read-only context only. Direct writes update memory but do not change the visible in-game overall. |
| PlayerPotential | 4 Bytes | `[44*8]`, `[0]` | Potential rating |
| International Reputation | 4 Bytes | `[12*8]`, `[0]` | Star rating |
| Height | 4 Bytes | `[27*8]`, `[0]` | Height in cm? |
| PlayerID | 4 Bytes | `[46*8]`, `[0]` | Unique player ID |
| Value + 1 = SkillMoves* | 4 Bytes | `[33*8]`, `[0]` | Skill moves (value + 1) |
| WeakFoot* | 4 Bytes | `[4A*8]`, `[0]` | Weak foot rating |

### Sub-Group: Stats → Physical

| Description | Offsets |
|-------------|---------|
| Acceleration | `[32*8]`, `[0]` |
| Sprint Speed | `[5C*8]`, `[0]` |
| Agility | `[3F*8]`, `[0]` |
| Balance | `[54*8]`, `[0]` |
| Jumping | `[24*8]`, `[0]` |
| Strength | `[5E*8]`, `[0]` |
| Reactions | `[3A*8]`, `[0]` |

### Sub-Group: Stats → Psychic

| Description | Offsets |
|-------------|---------|
| Aggression | `[1B*8]`, `[0]` |
| Composure | `[48*8]`, `[0]` |
| Interceptions | `[2*8]`, `[0]` |
| Positioning | `[35*8]`, `[0]` |
| Vision | `[3B*8]`, `[0]` |

### Sub-Group: Stats → Technique

| Description | Offsets |
|-------------|---------|
| Ball Control | `[39*8]`, `[0]` |
| Crossing | `[43*8]`, `[0]` |
| Dribbling | `[3E*8]`, `[0]` |
| Free Kick Accuracy | `[69*8]`, `[0]` |
| Finishing | `[4D*8]`, `[0]` |
| Heading Accuracy | `[2B*8]`, `[0]` |
| Long Passing | `[68*8]`, `[0]` |
| Short Passing | `[11*8]`, `[0]` |
| Marking | `[4*8]`, `[0]` |
| Shot Power | `[6*8]`, `[0]` |
| Long Shots | `[64*8]`, `[0]` |
| Sliding Tackle | `[4F*8]`, `[0]` |
| Standing Tackle | `[56*8]`, `[0]` |
| Volleys | `[5D*8]`, `[0]` |
| Penalties | `[34*8]`, `[0]` |
| Curve | `[2F*8]`, `[0]` |

### Sub-Group: Stats → Goalkeeping

| Description | Offsets |
|-------------|---------|
| GK Kicking | `[7*8]`, `[0]` |
| GK Handling | `[3*8]`, `[0]` |
| GK Positioning | `[28*8]`, `[0]` |
| GK Reflexes | `[30*8]`, `[0]` |

---

## Group: Edit Player (ID 134)

Color: `404080`. Under ActivateItFirst. Contains editable player attributes accessed via `ptrPlayer`.

### Pointer Structure

Address: `ptrPlayer` → offsets `[68]` → offsets `[index*8]` → offsets `[0]` → offsets `[20]`

The pattern `68 → N*8 → 0 → 20` is consistent across all Edit Player entries. This is a different memory layout than NotEditable — it accesses the player through a different object path.

### Sub-Group: Attacking

| Description | Offset Index |
|-------------|-------------|
| Crossing | `48*8` |
| Finishing | `49*8` |
| Heading Accuracy | `4A*8` |
| Short Passing | `4B*8` |
| Volleys | `4C*8` |

### Sub-Group: Defending

| Description | Offset Index |
|-------------|-------------|
| Marking | `4E*8` |
| Standing Tackle | `4F*8` |
| Sliding Tackle | `50*8` |

### Sub-Group: Skill

| Description | Offset Index |
|-------------|-------------|
| Dribbling | `51*8` |
| Curve | `52*8` |
| Free Kick Accuracy | `53*8` |
| Long Passing | `54*8` |
| Ball Control | `55*8` |

### Sub-Group: Power

| Description | Offset Index |
|-------------|-------------|
| Shot Power | `56*8` |
| Jumping | `57*8` |
| Stamina | `58*8` |
| Strength | `59*8` |
| Long Shots | `5A*8` |

### Sub-Group: Movement

| Description | Offset Index |
|-------------|-------------|
| Acceleration | `5B*8` |
| Sprint Speed | `5C*8` |
| Agility | `5D*8` |
| Reactions | `5E*8` |
| Balance | `5F*8` |

### Sub-Group: Mentality

| Description | Offset Index |
|-------------|-------------|
| Aggression | `60*8` |
| Composure | `61*8` |
| Interceptions | `62*8` |
| Positioning | `63*8` |
| Vision | `64*8` |
| Penalties | `65*8` |

### Sub-Group: Goalkeeping

| Description | Offset Index |
|-------------|-------------|
| GK Diving | `66*8` |
| GK Handling | `67*8` |
| GK Kicking | `68*8` |
| GK Positioning | `69*8` |
| GK Reflexes | `6A*8` |

### Sub-Group: Traits

Traits start at index `6B*8` and go through `7E*8`. Byte/boolean values (0 or 1).

| Index | Description |
|-------|-------------|
| `6B*8` | Long Throw-in |
| `6C*8` | Second Wind |
| `6D*8` | Acrobatic Clearance |
| `6E*8` | Early Crosser |
| `6F*8` | Finesse Shot |
| `70*8` | Outside Foot Shot |
| `71*8` | Power Header |
| `72*8` | Giant Throw-in |
| `73*8` | Swerve Pass |
| `74*8` | Power Free-Kick |
| `75*8` | Stutter Penalty |
| `76*8` | Skilled Dribbling |
| `78*8` | Fancy Flicks (note: 77*8 skipped) |
| `79*8` | Bicycle Kicks |
| `7A*8` | Diving Header |
| `7B*8` | Strong Pass |
| `7C*8` | Target Forward |
| `7D*8` | GK Long Throw |
| `7E*8` | Flat Clearance |

### Sub-Group: Other

Contains player metadata accessed via `ptrPlayer` with varying offsets.

| Description | Type | Offsets | Notes |
|-------------|------|---------|-------|
| FirstName | String (20) | `ptrPlayerFirstName`, `[0]` | Requires AA_Name scripts activated |
| Surname | String (20) | `ptrPlayerLastName`, `[0]` | Requires AA_Name scripts activated |
| Known As | String (20) | `ptrKnownAs`, `[0]` | Requires AA_Name scripts activated |
| Kit Name | String (10) | `ptrNameOnShirt`, `[0]` | Requires AA_Name scripts activated |
| PlayerPositionID | 4 Bytes | `ptrPlayer`, `[A28]` | |
| Preferred Foot | 4 Bytes | `ptrPlayer`, `[68]`, `[5*8]`, `[0]`, `[20]` | |
| Nationality | 4 Bytes | `ptrPlayer`, `[68]`, `[6*8]`, `[0]`, `[20]` | |
| YearOfBirth | 4 Bytes | `ptrPlayer`, `[68]`, `[7*8]`, `[0]`, `[20]` | |
| MonthOfBirth | 4 Bytes | `ptrPlayer`, `[68]`, `[8*8]`, `[0]`, `[20]` | |
| DayOfBirth | 4 Bytes | `ptrPlayer`, `[68]`, `[9*8]`, `[0]`, `[20]` | |
| BootsID | 4 Bytes | `ptrPlayer`, `[68]`, `[10*8]`, `[0]`, `[20]` | |
| Height | 4 Bytes | `ptrPlayer`, `[68]`, `[16*8]`, `[0]`, `[20]` | |
| Weight | 4 Bytes | `ptrPlayer`, `[68]`, `[17*8]`, `[0]`, `[20]` | |
| Weak Foot | 4 Bytes | `ptrPlayer`, `[68]`, `[4D*8]`, `[0]`, `[20]` | Same offset as Finishing in NotEditable |
| SkinColorID | 4 Bytes | `ptrPlayer`, `[68]`, `[19*8]`, `[0]`, `[20]` | |
| Sleeves | 4 Bytes | `ptrPlayer`, `[68]`, `[C*8]`, `[0]`, `[20]` | |
| Socks Length | 4 Bytes | `ptrPlayer`, `[68]`, `[85*8]`, `[0]`, `[20]` | |

### Sub-Group: UnknownValues

Miscellaneous values with offset indices like `18*8` (Body Type), `80*8` - `8A*8`.

### Name Editing

Requires 4 separate AA scripts to be activated before values appear:
- `AA_NameOnShirt` (AOB: `48 C7 85 10 0F 00 00 00 00 00 00`)
- `AA_KnownAs` (AOB: `48 89 BD 18 04 00 00 48 8B`)
- `AA_FirstName` (AOB: `48 89 BD D8 01 00 00 48 8B 00`)
- `AA_LastName` (AOB: `48 89 85 C0 03 00 00 49 83`)

Each allocates a pointer (`ptrNameOnShirt`, `ptrKnownAs`, `ptrPlayerFirstName`, `ptrPlayerLastName`) that points to the string in memory.

---

## Group: Player Training (ID 53)

Under ActivateItFirst. Color: `004080`.

### Scripts

| Description | AOB Signature |
|-------------|--------------|
| Training sim - A | `89 C3 4C 8D 44 24 40 89 C2 4C 89 F1 E8 ?? ?? ?? ?? 41 8B 8E 38 01 00 00 89 8C 24 B0 00 00 00 4D` |
| Training Everyday | `0F 89 ?? ?? ?? ?? C7 47 44 07 00 00 00 48 8B 5C 24 30` |

Training sim - A sets `eax` to 0 before the training simulation, giving perfect results.
Training Everyday bypasses the daily training limit.

---

## Group: Scouts Management (ID 52)

Under ActivateItFirst. Color: `004080`.

| Description | AOB Signature | Function |
|-------------|--------------|----------|
| Free 5/5 Scout | `41 8B 41 0C 89 45 60` | Sets scout experience to 4, knowledge to 4, cost to 0 |
| Reveal GTN player data (scouting not needed) | `85 C0 75 0D 4C 8D 86 8C 02 00 00` | Forces the `TransferConfidenceMinRevealLevel` branch to the fully revealed path so GTN scouting details are visible without scouting. Activate before loading the Career save. |

### GTN reveal notes

- Injection point: `FIFA17.exe+846A6A1`
- Original branch:
  - `test eax,eax`
  - `jne FIFA17.exe+846A6B2`
  - `lea r8,[rsi+0000028C]`
- The patch preserves `test eax,eax` and jumps directly to `FIFA17.exe+846A6B2`, matching the FIFA 19 GTN reveal behavior.
- Nearby labels in the same function include `FamousPlayerMinGreenAttr`, `FamousPlayerIntRep`, and `TransferConfidenceMinRevealLevel`, which helped confirm this is the GTN reveal gate.

---

## Group: Club Finances (ID 1)

Under ActivateItFirst. Color: `404080`.

| Description | Type | Address | Offsets |
|-------------|------|---------|---------|
| ptrTransferBudget | 4 Bytes | `ptrTransferBudget` | `[8]` |

---

## CheatCodes Section

Contains one manual patch at `FIFA17.exe+83D06A2`:
- Before: `8B 4F 20 84 C0`
- Actual (after patch): `0F 84 B8 00 00 00`
- Changed: a conditional jump at `je FIFA17.exe+83D06A2` was modified

---

## Key Observations

1. **Two distinct player data structures**: `ptrPlayer` and `ptrNotEditable` access different memory layouts. `ptrPlayer` uses a nested chain (`+68 → index*8 → +0 → +20`) while `ptrNotEditable` uses a flat array (`index*8 → +0`).

2. **Cheat entry types used**: Auto Assembler Script (`VariableType="Auto Assembler Script"`), 4 Bytes, String.

3. **String handling**: Player names require separate injection scripts that capture pointers to the string data. The strings are ASCII (`Unicode="0"`, `ZeroTerminate="1"`).

4. **Consistent XML pattern**: All entries use `<ID>`, `<Description>`, `<LastState>`, `<VariableType>`, `<Address>`, `<Offsets>` structure.

5. **No Lua**: The FIFA 17 cheat table has NO Lua scripts — everything is pure Auto Assembler and XML. This is a key difference from FIFA 19 which has extensive Lua.
