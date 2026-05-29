# AOB Discovery Log — FIFA 17 Youth Academy Port

## Session 3: Minimum Promotion Age

### Scope

Implemented issue `13-youth-academy-min-promotion-age.md` up to the required real Career Mode validation pass.

### Results

- FIFA 19 AOB `41 B8 03 00 00 00 89 85 E4` was scanned against `FIFA17.exe` and returned 0 matches.
- Reengineered the slice through FIFA 17's INI setting lookup path instead of the FIFA 19 hardcoded age-category write.
- Confirmed unique FIFA 17 AOB `49 8B 41 18 48 8B 04 C8 48 85 C0 74 0E` at `0x147765D31`.
- Added `AOB_MinAgeForPromotionIniLookup` to `lua/youth_helpers.lua`.
- Added `MIN_PLAYER_AGE_FOR_PROMOTION = 12` under the `Youth Academy` CT group.
- `auto_assemble_check(script)` passed for the enable section.
- Confirmed `FIFA_17_Cheat_Table.CT` remains well-formed XML.

### Original Code Context

```asm
147765D31 - 49 8B 41 18  - mov rax,[r9+18]
147765D35 - 48 8B 04 C8  - mov rax,[rax+rcx*8]
147765D39 - 48 85 C0     - test rax,rax
147765D3C - 74 0E        - je 147765D4C
147765D3E - 44 3B 00     - cmp r8d,[rax]
147765D41 - 74 0C        - je 147765D4F
147765D43 - 48 8B 40 10  - mov rax,[rax+10]
147765D47 - 48 85 C0     - test rax,rax
147765D4A - 75 F2        - jne 147765D3E
147765D4C - 31 C0        - xor eax,eax
147765D4E - C3           - ret
147765D4F - 48 8B 40 08  - mov rax,[rax+08]
```

### Validation Notes

The hook preserves the first two original lookup instructions, compares the current lookup string against `YOUTH_SQUAD/MIN_PLAYER_AGE_FOR_PROMOTION`, and writes `12` to the resolved setting value at `[value+08]`. Disable restores the original 8 bytes at the injection point. Real in-game validation is still required with a FIFA 17 Career Mode save containing a youth academy player below the normal promotion age.

## Session 2: Shared Scaffolding

### Scope

Implemented issue `08-youth-academy-shared-scaffolding.md`.

### Results

- Backed up `FIFA_17_Cheat_Table.CT` to `FIFA_17_Cheat_Table.CT.bak` before editing.
- Added an empty `Youth Academy` group after the existing `Scouts Management` group.
- Replaced `lua/youth_helpers.lua` with helper functions and an empty AOB registry.
- Wired helper loading through `ActivateItFirst` using external `lua/youth_helpers.lua` path lookup.
- Confirmed the CT remains well-formed XML with Python `xml.etree.ElementTree`.

### Notes

No gameplay feature AOBs were added in this pass. The previous helper file contained candidate and pending FIFA 19-derived patterns, but this scaffolding slice requires no unconfirmed FIFA 17 AOBs in the registry.

## Session 1: Initial Static Scan

### Methodology
Scanned all 13 FIFA 19 AOB patterns against FIFA17.exe (PID 12004 attached).
Extended with shorter/relaxed pattern variants where exact matches failed.

### Results Summary

| # | Feature | FIFA 19 AOB | FIFA 17 Matches | Status |
|---|---------|------------|-----------------|--------|
| 1 | SCOUT_REPORT_PLAYERS | `89 06 FF C7 48 83 C6 04 83 FF 02` | 2 exact | **Candidate** |
| 2 | Reveal OVR & POT | `89 07 FF C3 48 83 C7 04 83 FB 06` | 0 exact, 3 partial | **Needs runtime** |
| 3 | PRIMARY_ATTR_RANGE | `43 89 44 F7 30` | 0 exact, 1 at `89 44 F7 30` — 64-bit write | **Rejected (wrong op size)** |
| 4 | SECONDARY_ATTR_RANGE | `43 89 44 F7 68` | 0 exact, 1 at `89 44 F7 68` — in data/garbage | **Rejected** |
| 5 | MIN_AGE_FOR_PROMOTION | `41 B8 03 00 00 00 89 85 E4` | 0 | **Needs runtime** |
| 6 | YOUTH_PLAYER_AGE_RANGE | `41 B8 04 00 00 00 41 89 07` | 0 | **Needs runtime** |
| 7 | Youth Retire at 30 | `41 FF C4 89 03` | 0 | **Needs runtime** |
| 8 | 95 Potential | `89 06 48 8D 76 04 83 FF 02` | 0 | **Needs runtime** |
| 9 | 5★ Weak Foot | `FF C3 89 07 48 8D 7F 04 83 FB 06` | 0 | **Needs runtime** |
| 10 | Scout Any Country | `89 4C 24 30 B9 04 00 00 00` | 0 | **Needs runtime** |
| 11 | 5★ Skill Moves | `89 B5 7C 01 00 00 4C` | 0, 2 short matches | **Candidate (needs verification)** |
| 12 | Same Country Multi-Scout | `80 FB 01 75 0C 4C` | 0 exact, 35 for `80 FB 01 75` | **Needs runtime** |
| 13 | Disable Player Regens | `41 BF 10 00 00 00 48 8B CE` | 0 | **Needs runtime** |

### Key Finding: Heavy Code Obfuscation

FIFA 17 uses crypto-constant-based field access throughout the code. Instead of:
```asm
mov [r15+r14*8+30],eax   ; Direct field access (FIFA 19 style)
```
FIFA 17 uses:
```asm
mov rdx,<crypto_constant>    ; Random-looking 64-bit constant
lea rcx,[rsp+28]
call 145EE0220               ; Field resolver function
test rax,rax
jne skip_error
lea ecx,[rax+04]
call 1473582E0               ; Error handler
skip_error:
mov eax,[rax]                ; Dereference resolved field
mov [rbx+offset],eax         ; Write to struct
```

This means register allocations, instruction encodings, and byte patterns differ
significantly between FIFA 17 and FIFA 19, making direct AOB porting unreliable.

### Candidate Details

#### SCOUT_REPORT_PLAYERS — 2 candidates

**Candidate A: `0x1454FA893`**
- Function starts at `0x1454FA621` (sub rsp,40)
- Loop: `mov [rsi],eax; inc edi; add rsi,04; cmp edi,02; jl`
- After loop: crypto lookup → `movups [rbx+4C],xmm0` (copy 16 bytes)
- Multiple crypto-constant field accesses in same function

**Candidate B: `0x14550E023`**
- In same area as `0x14550E002` (`mov [rsi-38],eax`)
- Preceded by 3-iteration loop at `0x14550DFA0-0x14550DFC4` (`cmp edi,03`)
- Then crypto lookup → set up rsi at `[rbx+0x59C]`
- Then write to `[rsi-38]` at `0x14550E002`
- Then 2-iteration loop: `mov [rsi],eax; inc edi; add rsi,04; cmp edi,02`
- After loop: `lea rdi,[rbx+5C8]`; more crypto lookups

Candidate B has more youth-related structure (multiple loops with different counts,
offsets matching youth player data patterns).

#### 5★ Skill Moves — 2 candidates

**Candidate A: `0x145433B20`**
- `mov [rbp+17C],esi`
- Followed by crypto constants and `call 145437350`
- Near: `xor r8d,r8d`, `mov rax,[rbx+1A848]`, movaps operations
- Context suggests rendering/UI code rather than attribute generation

**Candidate B: `0x14576537A`**
- `mov [rbp+17C],esi`
- Followed by `movaps xmm0,[global]` and `movaps [rbp+180],xmm0`
- Then `mov [rbp+19C],19` (sets value to 25/0x19)
- Context more consistent with attribute struct initialization

Neither is clearly the youth skill moves writer. Runtime verification needed.

### Partial Pattern Matches (RevealPotAndOvr variants)

3 addresses matched the shorter pattern `89 07 FF C3 48 83 C7 04`:

1. `0x145503478` — `cmp ebx,0Bh` (11 iterations) — not 6, likely wrong context
2. `0x148038925` — `cmp ebx,05`, nested with `cmp esi,03` (5×3=15 iterations) — promising for scout report (15 players)
3. `0x148504BE7` — `cmp ebx,0Bh` (11 iterations) — same as #1 pattern, not a match

Candidate #2 (`0x148038925`) has a 5-iteration × 3-iteration nested loop = 15 total,
which could relate to 15 players per scout report. This deserves further investigation.

### String Search Results

- `youthSquadFlow.nav` — navigation flow file reference
- `youthplayerattributes` — at `0x143BE09AF` (code section) and `0x098357DF` (data section)
- `youthplayerhistory` — data section reference
- `youthplayers` — data section reference
- `scoutNetworkFlow.nav` — navigation flow file reference
- `scoutmission` — data section reference

No direct code references found from these strings to our candidate addresses.

### Next Steps

Static analysis alone is insufficient for 11 of 13 features due to heavy code obfuscation.
The recommended approach for the remaining features is runtime analysis:

1. **Set up data breakpoints on known youth player structures** in FIFA 17
2. **Trigger scout report generation in-game** (send a youth scout on a mission)
3. **Capture the code paths** that write to youth player data
4. **Identify injection points** from the captured code

For features where we have candidates (SCOUT_REPORT_PLAYERS, SkillMoves):
- Set breakpoints at candidate addresses
- Verify they fire during youth scout report generation
- Confirm the game behavior matches expectations