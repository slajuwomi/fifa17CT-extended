# FIFA 19 Career Mode Cheat Table — Youth Scouting & Youth Player Features

## Complete Breakdown

---

## 1. CT Structure (Cheat Table Entries)

The Youth Academy section sits under the main CheatEntry tree as **ID 2657**, titled **"Youth Academy"** (moHideChildren=1). It contains two groups of sub-entries plus standalone scripts:

### 1A. "Generate new report" (ID 2998)
- **Type**: Auto Assembler Script
- **Risk**: 2/5
- **Description**: Instantly generate new youth academy scout reports.
- **How to use**: Activate script in main career menu; reactivate to use again.
- **Logic**: See Section 3 below.

### 1B. "Activate scripts BEFORE you load your career mode save." (ID 2658, GroupHeader)
This is a PARENT group containing all the pre-load Youth Academy scripts. Children:

#### 1B-i. "SCOUT_REPORT_PLAYERS" (ID 1264)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Control how many players your scout can bring you each month (max ~15).
- **Child entry**: "Players per report" (ID 2951) — `intScoutReportPlayers` (4 Bytes, default 15)
- **AOB**: `AOB_YouthAcademyMoreYouthPlayers = '89 06 FF C7 48 83 C6 04 83 FF 02'`
- **Injects at**: `FIFA19.exe+40F3D8A` — `mov [rsi],eax; inc edi; add rsi,04` (loop writing player count)
- **Logic**: Replaces `mov [rsi],eax` with `mov eax,[intScoutReportPlayers]; mov [rsi],eax; inc edi; add rsi,04`, effectively letting the user control how many players appear per scout report.
- **Symbols registered**: `intScoutReportPlayers` (4 bytes, default 15)

#### 1B-ii. "Reveal ovr and pot" (ID 1266)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Immediately see OVR and POT of youth players without scouting.
- **AOB**: `AOB_YouthAcademyRevealPotAndOvr = '89 07 FF C3 48 83 C7 04 83 FB 06'`
- **Injects at**: `FIFA19.exe+40F581D` — `mov [rdi],eax; inc ebx; add rdi,04` (loop of 6 iterations for pot/ovr values)
- **Logic**: Replaces `mov [rdi-18],eax` then `mov [rdi],eax; inc ebx; add rdi,04` with `xor eax,eax; mov [rdi-18],eax; mov [rdi],eax; inc ebx; add rdi,04` — sets the OVR/POT variance values to 0 (removes the hidden/uncertainty overlay, revealing true values).

#### 1B-iii. "PRIMARY_ATTRIBUTES_RANGE" (ID 2656)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Control Primary Attributes range for generated youth players. Default Low=10, High=20.
- **Child entries**: "Range Low" (ID 2661, `primattr_rangelow`, default 10), "Range High" (ID 2660, `primattr_rangehigh`, default 20)
- **AOB**: `AOB_YouthAcademyPrimAttr = '43 89 44 F7 30'`
- **Injects at**: `FIFA19.exe+40F65EE` (5 bytes)
- **Logic**: Replaces the attribute range write with custom controlled values:
  ```asm
  mov eax, [primattr_rangelow]
  mov [r15+r14*8+2C], eax   // PRIMARY_ATTRIBUTES_RANGE_LOW_TYPE
  mov eax, [primattr_rangehigh]
  mov [r15+r14*8+30], eax   // PRIMARY_ATTRIBUTES_RANGE_HIGH_TYPE
  ```
- **Symbols registered**: `primattr_rangelow`, `primattr_rangehigh`

#### 1B-iv. "SECONDARY_ATTRIBUTES_RANGE" (ID 1268)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Control Secondary Attributes range. Default Low=10, High=20.
- **Child entries**: "Range Low" (ID 2663, `secmattr_rangelow`, default 10), "Range High" (ID 2662, `secmattr_rangehigh`, default 20)
- **AOB**: `AOB_YouthAcademySecAttr = '43 89 44 F7 68'`
- **Injects at**: `FIFA19.exe+40F65EE` — `mov [r15+r14*8+68],eax`
- **Logic**: Similar to PRIMARY but at offset 0x64 and 0x68:
  ```asm
  mov eax, [secmattr_rangelow]
  mov [r15+r14*8+64], eax   // SECONDARY_ATTRIBUTES_RANGE_LOW_TYPE
  mov eax, [secmattr_rangehigh]
  mov [r15+r14*8+68], eax   // SECONDARY_ATTRIBUTES_RANGE_HIGH_TYPE
  ```
- **Symbols registered**: `secmattr_rangelow`, `secmattr_rangehigh`

#### 1B-v. "MIN_PLAYER_AGE_FOR_PROMOTION = 12" (ID 2683)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Allows promoting players aged 12+ to senior team (default min age is higher).
- **AOB**: `AOB_YouthAcademyMinAgeForPromotion = '41 B8 03 00 00 00 89 85 E4'`
- **Injects at**: `FIFA19.exe+40EDA53` — `mov r8d,3` (min age enum = 3)
- **Logic**: Replaces `mov r8d,00000003` with `mov eax,#12; mov r8d,00000003` which sets min promotion age to 12. Actually, the injection forces `eax = 12` before the original `mov r8d,3` instruction. The `r8d=3` is the age category; `eax=12` sets the numeric age value used in the promotion check.

#### 1B-vi. "YOUTH_PLAYER_AGE_RANGE = [12, 16]" (ID 1275)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Scouts will bring players aged 12–16.
- **AOB**: `AOB_YouthAcademyPlayerAgeRange = '41 B8 04 00 00 00 41 89 07'`
- **Injects at**: `FIFA19.exe+3****10` — `mov [r15+08],eax` (age range high write)
- **Logic**: Injects before the age write:
  ```asm
  mov eax, #12       // YOUTH_PLAYER_AGE_RANGE_LOW = 12
  mov [r15+04], eax
  mov eax, #16       // YOUTH_PLAYER_AGE_RANGE_HIGH = 16
  mov [r15+08], eax
  ```
  Then falls through to original `mov r8d,00000004`.

#### 1B-vii. "Youth Player Retire At Age = 30" (ID 2760)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Prevents youth players from leaving the academy (sets retirement age to 30).
- **AOB**: `AOB_YouthAcademyYouthPlayersRetirement = '41 FF C4 89 03'`
- **Injects at**: `FIFA19.exe+40F154A` — `inc r12d; mov [rbx],eax`
- **Logic**: Replaces with `mov eax, #30; inc r12d; mov [rbx],eax` — forces retirement age value to 30 instead of whatever random value was generated.

#### 1B-viii. "95 Potential" (ID 1276)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: All youth players will have 95 potential.
- **AOB**: `AOB_YouthAcademyPlayerPotential = '89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48'`
- **Injects at**: `FIFA19.exe+40F6AF0` — `mov [rsi],eax; lea rsi,[rsi+04]`
- **Logic**: Forces TIER_%d_POTENTIAL_RANGE_%d to 95:
  ```asm
  mov eax, #95      // Force potential to 95
  mov [rsi], eax
  lea rsi, [rsi+04]
  ```

#### 1B-ix. "100% chance for 5* weak foot" (ID 1269)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: All youth players will have 5-star weak foot.
- **AOB**: `AOB_YouthAcademyWeakFootChance = 'FF C3 89 07 48 8D 7F 04 83 FB 06'`
- **Injects at**: `FIFA19.exe+40F695A` — `inc ebx; mov [rdi],eax; lea rdi,[rdi+04]` (loop for 6 WEAKFOOT_ABILITY_LEVEL values)
- **Logic**: The loop iterates 6 times (ebx 0→5). When ebx==6 (5-star), writes 100 (0x64) chance; otherwise writes 0:
  ```asm
  inc ebx
  cmp ebx, 06
  je foot_fivestar
  jmp foot_zero
  foot_zero:
    mov eax, 0
    mov [rdi], eax
    lea rdi, [rdi+04]
    jmp ret
  foot_fivestar:
    mov eax, 64       // 100% chance
    mov [rdi], eax
    lea rdi, [rdi+04]
    jmp ret
  ```

#### 1B-x. "Send scout to any country" (ID 1790)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Force scout nationality regardless of which country is selected for the mission.
- **Child entry**: "Nationality ID" (ID 1791, `ptr_YA_NatID`, 4 Bytes)
- **AOB**: `AOB_YouthAcademyAllCountriesAvailable = '89 4C 24 30 B9 04 00 00 00'`
- **Injects at**: `FIFA19.exe+3FD152F` — `mov [rsp+30],ecx; mov ecx,4`
- **Logic**: If `ptr_YA_NatID != 0`, overrides the nationality ID in `[rsp+30]` with the user-specified value:
  ```asm
  mov [rsp+30], ecx      // store original value
  mov ecx, [ptr_YA_NatID]
  cmp ecx, 0
  je code_allCountriesAvailable
  mov [rsp+30], ecx       // override with user-specified nationality
  jmp code_allCountriesAvailable
  ```

#### 1B-xi. "100% chance for 5* skill moves" (ID 1270)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: All youth players will have 5-star skill moves.
- **AOB**: `AOB_YouthAcademySkillMoveChance = '89 B5 7C 01 00 00 4C'`
- **Injects at**: `FIFA19.exe+3702BA4` — `mov [rbp+0000017C],esi`
- **Logic**: Forces `esi = 4` (0-indexed, so 4 = 5 stars):
  ```asm
  mov esi, #4        // 0-indexed, 4 = 5 stars
  mov [rbp+0000017C], esi
  ```

#### 1B-xii. "Set up multiple scouting networks in the same country" (ID 2659)
- **Type**: AA Script
- **Risk**: 0/5
- **Description**: Bypasses the "Country Is Being Scouted" popup that prevents sending multiple scouts to the same country.
- **AOB**: `AOB_CountryIsBeingScouted = '80 FB 01 75 0C 4C'`
- **Injects at**: `FIFA19.exe+3FD1808` — `cmp bl,01; jne ...` (CMYS_Popup_CountryIsBeingScouted check)
- **Logic**: Replaces `cmp bl,01` with `cmp bl,01` then forces `jmp` past the popup block, effectively always allowing same-country scouting:
  ```asm
  cmp bl, 01           // "CMYS_Popup_CountryIsBeingScouted"
  jmp $INJECT_CountryIsBeingScouted+11  // skip the branch that shows popup
  ```

#### 1B-xiii. "Generate players with custom ID" (ID 2975)
- **Type**: AA Script
- **Risk**: 3/5 (can harm save if duplicate IDs used)
- **Description**: Override youth scout player IDs with custom player IDs from existing player database.
- **Child entries**: PlayerID 1 through PlayerID 15 (`arr_YACustomPlayerID` through `arr_YACustomPlayerID+0x38`, 4 Bytes each)
- **AOB**: `AOB_YouthAcademyGeneratePlayer = 'F6 48 8B 3D ?? ?? ?? ?? 48 8B 9C 24 80 00 00 00'`
- **Injects at**: `FIFA19.exe+380A896` — `mov rbx,[rsp+00000080]`
- **Logic**: Maintains a 25-slot (100 byte) array `arr_YACustomPlayerID`. When a scout generates a new player (playerid != -1), checks if the array has a custom ID. If so, replaces the generated playerid with the custom one from position 0, then shifts the array left (FIFO queue):
  ```asm
  cmp [rsi], FFFFFFFF      // playerid == -1?
  je code                  // skip if no real player
  cmp [arr_YACustomPlayerID], 0  // any custom IDs queued?
  je code                  // skip if not
  push rsi
  mov rsi, [rsp+18]       // get player pointer from stack
  mov ebx, [arr_YACustomPlayerID]
  mov [rsi], ebx           // overwrite playerid with custom ID
  pop rsi
  // FIFO shift: move arr[1] -> arr[0], arr[2] -> arr[1], etc.
  xor ebx, ebx
  mov [arr_YACustomPlayerID], ebx
  loop: shift array left
  ```
- **Symbols registered**: `arr_YACustomPlayerID` (100 bytes)

---

### 2A. "Hire Scouts" (ID 2463)
This sits OUTSIDE the Youth Academy group but is closely related.

- **Type**: AA Script
- **Risk**: 3/5
- **Description**: Edit scouts before hiring them.
- **AOB**: `AOB_HireScout = '41 8B 01 89 45 48'`
- **Injects at**: `FIFA19.exe+3F785D4` — `imul r9,rax,00000084; add r9,[rcx]` (scout struct access)
- **Logic**: 
  - Captures `scoutPtr` (pointer to first scout struct) when `r12 == 0`
  - If `bFreeScouts == 1`, forces `Exp = 4` (5 stars), `Judgment = 4` (5 stars), `Cost = 0`
  - Scout struct offsets: `+0x00`=ID, `+0x08`=Nationality, `+0x0C`=Experience, `+0x10`=Judgment, `+0x18`=Cost, `+0x28`=FirstName, `+0x55`=LastName
  - Each scout is 0x84 (132) bytes apart
- **Child: "Free 5/5 Scouts" (ID 598)**: Sets `bFreeScouts = 1` on enable, `0` on disable.
- **Child: "Detailed Info" (ID 2499)**: Contains Scout 1–5 sub-entries, each with:
  - Nationality (`scoutPtr+0x08`, 4 Bytes)
  - Experience (`scoutPtr+0x0C`, 4 Bytes, dropdown 0–4 = 1–5 stars)
  - Judgment (`scoutPtr+0x10`, 4 Bytes, dropdown 0–4 = 1–5 stars)
  - Cost (`scoutPtr+0x18`, 4 Bytes)
  - First Name (`scoutPtr+0x28`, String 40 chars)
  - Last Name (`scoutPtr+0x55`, String 40 chars)
  - Offsets for Scout 2: `+0x84`, Scout 3: `+0x108`, Scout 4: `+0x18C`, Scout 5: `+0x210`

### Scout Database Table Pointer
The CT's main DatabaseRead injection also captures:
- `scoutsDataPtr` — pointer to career_scouts table data
- `scoutmissionDataPtr` — pointer to career_scoutmission table data

These are checked via `cmp [rdi+8], 'zlrC'` (career_scouts) and `cmp [rdi+8], 'apoo'` (career_scoutmission).

---

## 2. AOB Signatures (from helpers.lua)

All youth-related AOBs defined in `load_aobs()`:

```lua
AOB_HireScout                            = '41 8B 01 89 45 48'
AOB_YouthAcademyMoreYouthPlayers          = '89 06 FF C7 48 83 C6 04 83 FF 02'
AOB_YouthAcademyRevealPotAndOvr          = '89 07 FF C3 48 83 C7 04 83 FB 06'
AOB_YouthAcademyPrimAttr                  = '43 89 44 F7 30'
AOB_YouthAcademySecAttr                   = '43 89 44 F7 68'
AOB_YouthAcademyMinAgeForPromotion        = '41 B8 03 00 00 00 89 85 E4'
AOB_YouthAcademyPlayerAgeRange            = '41 B8 04 00 00 00 41 89 07'
AOB_YouthAcademyYouthPlayersRetirement    = '41 FF C4 89 03'
AOB_YouthAcademyPlayerPotential           = '89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48'
AOB_YouthAcademyWeakFootChance            = 'FF C3 89 07 48 8D 7F 04 83 FB 06'
AOB_YouthAcademyAllCountriesAvailable     = '89 4C 24 30 B9 04 00 00 00'
AOB_YouthAcademySkillMoveChance           = '89 B5 7C 01 00 00 4C'
AOB_YouthAcademyGeneratePlayer            = 'F6 48 8B 3D ?? ?? ?? ?? 48 8B 9C 24 80 00 00 00'
AOB_CountryIsBeingScouted                = '80 FB 01 75 0C 4C'
AOB_GENERATE_NEW_YA_REPORT               = '8D 43 0E 89 44 24 3C'
```

Related:
```lua
AOB_NoPlayerRegens = '41 BF 10 00 00 00 48 8B CE'
AOB_SCRIPTS_BASE_PTR = '48 8B 46 10 4C 89 2A'
AOB_F_GEN_REPORT = '48 8B CB E8 ?? ?? ?? ?? 48 8B CB 48 8B 5C 24 38 48 8B 74 24 40'
```

---

## 3. "Generate New Report" Script — Detailed Analysis

**ID**: 2998  
**AOB**: `AOB_GENERATE_NEW_YA_REPORT = '8D 43 0E 89 44 24 3C'`  
**Injection point**: `FIFA19.exe+36FC2F9`

### How it Works

This is the most complex youth script. It has TWO components:

1. **Injection hook** — patches the date calculation for scout report generation:
   ```asm
   ; Original code: lea eax,[rbx+0E]   ; adds 14 days to current date
   ;                mov [rsp+3C],eax
   ; Patched to:    cmp [bNewReport], 1
   ;                jne code
   ;                mov ebx, r15d      ; set report date to CURRENT day instead of +14 days
   ; code:
   ;                lea eax,[rbx+0E]
   ;                mov [rsp+3C],eax
   ```

2. **Code cave `callGenerateNewReport`** — calls the game's internal YA report generation function. Runs in a new thread via `CREATETHREAD`:
   ```asm
   sub rsp, 28
   cmp [ptrBaseScripts], 0        ; check base pointer
   je callRet
   cmp [funcGenReport], 0         ; check function pointer
   je callRet
   mov [bNewReport], 1             ; set flag for injection hook
   mov rcx, [ptrBaseScripts]       ; dereference pointer chain:
   mov rcx, [rcx+0]               ;   [ptrBaseScripts]+0x0
   mov rcx, [rcx+538]             ;   +0x538
   mov rcx, [rcx+0]               ;   +0x0
   mov rcx, [rcx+20]             ;   +0x20
   mov rcx, [rcx+148]             ;   +0x148  → this = YA context object
   call [funcGenReport]            ; call game function
   callRet:
   add rsp, 28
   mov [bNewReport], 0             ; clear flag
   ret
   ```

The function pointer `funcGenReport` is resolved from the AOB `AOB_F_GEN_REPORT` (`48 8B CB E8 ?? ?? ?? ?? 48 8B CB 48 8B 5C 24 38 48 8B 74 24 40`) and `ptrBaseScripts` from `AOB_SCRIPTS_BASE_PTR`.

### Symbols
- `bNewReport` (1 byte, globalalloc) — flag to trigger instant report
- `callGenerateNewReport` (code cave, runs in separate thread)
- `INJECT_GENERATE_NEW_YA_REPORT` — injection address
- `ORG_GENERATE_NEW_YA_REPORT` — original bytes (12 bytes)

---

## 4. Lua-Side Youth Logic

### 4A. Youth Head Image Loading (`lua/GUI/helpers.lua`, lines 84–96)

```lua
function load_head(playerid, headtypecode, haircolorcode)
    -- ...
    local iplayerid = tonumber(playerid)
    if iplayerid < 280000 then
        -- Regular player heads
        fpath = string.format('heads/p%d.png', playerid)
    else
        -- Youth player heads
        if headtypecode == 0 then
            fpath = string.format('youthheads/p%d.png', haircolorcode)
        else
            fpath = string.format('youthheads/p%d%02d.png', headtypecode, haircolorcode)
        end
    end
    -- Downloads from: https://fifatracker.net/static/img/assets/{FIFA}/{fpath}
end
```

**Key insight**: Youth players have `playerid >= 280000`. Their head images use a different naming scheme: `youthheads/p{haircolorcode}.png` if headtypecode==0, or `youthheads/p{headtypecode}{haircolorcode:02d}.png` otherwise.

### 4B. Lua Activation Hook (standard pattern in all youth AA scripts)

Every youth AA script uses the same Lua activation pattern:

```lua
[ENABLE]
{$lua}
local status, error = pcall(get_validated_address)
if not status then
    showMessage('Error during script activation, error:\n' .. error)
    print("Read guide...")
    assert(false, error)
end

INJECT_xxx = get_validated_address('AOB_YouthAcademyXxx')
ORG_xxx = readBytes(INJECT_xxx, N, true)
{$asm}
... asm code ...
[DISABLE]
{$lua}
writeBytes(INJECT_xxx, ORG_xxx)
{$asm}
... cleanup ...
```

This means all youth scripts depend on `get_validated_address()` from `helpers.lua`, which does an AOB scan to find the injection point at runtime.

---

## 5. Memory Layout Summary

### Scout Structure (0x84 bytes per scout, up to 5 scouts)
| Offset | Size | Field |
|--------|------|-------|
| 0x00 | 4 | Scout ID |
| 0x08 | 4 | Nationality |
| 0x0C | 4 | Experience (0=1★, 4=5★) |
| 0x10 | 4 | Judgment (0=1★, 4=5★) |
| 0x18 | 4 | Cost |
| 0x28 | 40 | First Name (null-terminated) |
| 0x55 | 40 | Last Name (null-terminated) |

Scout 2 = Scout 1 + 0x84  
Scout 3 = Scout 1 + 0x108  
Scout 4 = Scout 1 + 0x18C  
Scout 5 = Scout 1 + 0x210

### Youth Player Internal Format Fields (from AA code analysis)
- `[r15+04]` — Age range low
- `[r15+08]` — Age range high
- `[r15+r14*8+2C]` — Primary attributes range low
- `[r15+r14*8+30]` — Primary attributes range high
- `[r15+r14*8+64]` — Secondary attributes range low
- `[r15+r14*8+68]` — Secondary attributes range high
- `[rbp+0000017C]` — Skill moves level (0-indexed)
- `[rsp+30]` — Nationality ID for YA player generation
- `[rbx]` — Retirement age (when iterated in a 2-element loop)
- `[rsi]` — Potential values (when in potential assignment loop)
- `[rdi-18]` / `[rdi]` — OVR/POT variance values (6 iterations)

---

## 6. Pointer Chain for Generate Report

```
ptrBaseScripts → [+0x0] → [+0x538] → [+0x0] → [+0x20] → [+0x148] = YA context
call [funcGenReport]                    ; calls generate report function on YA context
```

---

## 7. Youth-Related Database Tables

From the DatabaseRead hook in FIFA19.CT:
- `career_scouts` (table ID tag: `'zlrC'`) → `scoutsDataPtr`
- `career_scoutmission` (table ID tag: `'apoo'`) → `scoutmissionDataPtr`

---

## 8. Full Feature Summary Table

| # | Feature Name | AA Script ID | AOB Key | Risk | Purpose | Symbols Registered |
|---|---|---|---|---|---|---|
| 1 | Generate New Report | 2998 | AOB_GENERATE_NEW_YA_REPORT | 2/5 | Instant scout report | bNewReport, callGenerateNewReport |
| 2 | More Players Per Report | 1264 | AOB_YouthAcademyMoreYouthPlayers | 0/5 | Control # of players per report | intScoutReportPlayers |
| 3 | Reveal OVR & POT | 1266 | AOB_YouthAcademyRevealPotAndOvr | 0/5 | Show true ratings | (none) |
| 4 | Primary Attr Range | 2656 | AOB_YouthAcademyPrimAttr | 0/5 | Set primary attribute range | primattr_rangelow, primattr_rangehigh |
| 5 | Secondary Attr Range | 1268 | AOB_YouthAcademySecAttr | 0/5 | Set secondary attribute range | secmattr_rangelow, secmattr_rangehigh |
| 6 | Min Age for Promotion | 2683 | AOB_YouthAcademyMinAgeForPromotion | 0/5 | Promote players aged 12+ | (none) |
| 7 | Youth Player Age Range | 1275 | AOB_YouthAcademyPlayerAgeRange | 0/5 | Scouts find players aged 12–16 | (none) |
| 8 | Youth Retire at 30 | 2760 | AOB_YouthAcademyYouthPlayersRetirement | 0/5 | Prevent academy leaving | (none) |
| 9 | 95 Potential | 1276 | AOB_YouthAcademyPlayerPotential | 0/5 | All youth = 95 potential | (none) |
| 10 | 5★ Weak Foot | 1269 | AOB_YouthAcademyWeakFootChance | 0/5 | 100% chance 5★ weak foot | (none) |
| 11 | Scout Any Country | 1790 | AOB_YouthAcademyAllCountriesAvailable | 0/5 | Force nationality ID | ptr_YA_NatID |
| 12 | 5★ Skill Moves | 1270 | AOB_YouthAcademySkillMoveChance | 0/5 | Force 5★ skill moves | (none) |
| 13 | Same Country Multi-Scout | 2659 | AOB_CountryIsBeingScouted | 0/5 | Bypass same-country popup | (none) |
| 14 | Custom Player ID | 2975 | AOB_YouthAcademyGeneratePlayer | 3/5 | Override player IDs | arr_YACustomPlayerID |
| 15 | Hire Scouts | 2463 | AOB_HireScout | 3/5 | Edit scout before hiring | bFreeScouts, scoutPtr |
| 16 | Free 5/5 Scouts | 598 | (child of Hire Scouts) | 0/5 | Free max-star scouts | bFreeScouts |
| 17 | Disable Player Regens | 2795 | AOB_NoPlayerRegens | 0/5 | Disable regen generation | (none) |