# Agent Handoff: Youth Academy AOB Discovery

## What This Project Is

Porting 13 youth academy/scout features from a FIFA 19 Cheat Table to the FIFA 17 Cheat Table (`FIFA_17_Cheat_Table.CT`). The FIFA 19 CT is at `FIFA-19---Career-Mode-Cheat-Table/FIFA 19 - CM Cheat Table/FIFA19.CT`. The PRD is at `docs/prd-youth-academy-port.md`.

## Current State

- **Phase 0 (Scaffolding)**: COMPLETE
- **Phase 1 (AOB Discovery)**: IN PROGRESS — initial static scan done, runtime verification needed

### Phase 0 Deliverables (done)

| File | Status |
|------|--------|
| `lua/youth_helpers.lua` | Created — AOB registry with 13 keys + scan/validation functions |
| `FIFA_17_Cheat_Table.CT.bak` | Created — backup of original CT |
| Lua load test | Passed — CE can load the helper file via `io.open` + `load()`, all 13 AOB keys register correctly |

## Critical Finding: FIFA 17 Code Obfuscation

FIFA 17 uses crypto-constant-based field access instead of direct struct offsets. FIFA 19 writes fields directly:

```asm
; FIFA 19 style (direct offset)
mov [r15+r14*8+30],eax      ; Primary attribute low
mov [r15+r14*8+68],eax      ; Secondary attribute high
```

FIFA 17 resolves fields through a lookup function:

```asm
; FIFA 17 style (obfuscated)
mov rdx,<64-bit_crypto_constant>   ; e.g. 0x0D06D353524F0332
lea rcx,[rsp+28]
call 145EE0220                     ; Field resolver
test rax,rax
jne skip_error
lea ecx,[rax+04]
call 1473582E0                     ; Error handler
skip_error:
mov eax,[rax]                      ; Dereference resolved field
mov [rbx+offset],eax               ; Write to struct
```

This means NO direct FIFA 19 AOB pattern will match in FIFA 17 (except by coincidence). The code structure, register usage, and instruction sequences all differ.

## AOB Scan Results

Full details in `docs/aob-discovery-log.md`. Summary:

| # | Feature | FIFA 19 AOB | FIFA 17 Result | Status |
|---|---------|-------------|----------------|--------|
| 1 | SCOUT_REPORT_PLAYERS | `89 06 FF C7 48 83 C6 04 83 FF 02` | 2 exact matches | Has candidates, needs runtime pick |
| 2 | Reveal OVR & POT | `89 07 FF C3 48 83 C7 04 83 FB 06` | 0 exact, 3 partial for `89 07 FF C3 48 83 C7 04` | Needs runtime |
| 3 | PRIMARY_ATTR_RANGE | `43 89 44 F7 30` | 0 exact, 1 match `mov [rdi+rsi*8+30],rax` (64-bit, wrong) | Needs runtime |
| 4 | SECONDARY_ATTR_RANGE | `43 89 44 F7 68` | 0 exact, 1 match in garbage data section | Needs runtime |
| 5 | MIN_AGE_FOR_PROMOTION | `41 B8 03 00 00 00 89 85 E4` | 0 | Needs runtime |
| 6 | YOUTH_PLAYER_AGE_RANGE | `41 B8 04 00 00 00 41 89 07` | 0 | Needs runtime |
| 7 | Youth Retire at 30 | `41 FF C4 89 03` | 0 | Needs runtime |
| 8 | 95 Potential | `89 06 48 8D 76 04 83 FF 02 ?? ??` | 0 | Needs runtime |
| 9 | 5-star Weak Foot | `FF C3 89 07 48 8D 7F 04 83 FB 06` | 0 | Needs runtime |
| 10 | Scout Any Country | `89 4C 24 30 B9 04 00 00 00` | 0 | Needs runtime |
| 11 | 5-star Skill Moves | `89 B5 7C 01 00 00 4C` | 0 exact, 2 matches for `89 B5 7C 01 00 00` | Needs runtime |
| 12 | Same Country Multi-Scout | `80 FB 01 75 0C 4C` | 0 exact, 35 for `80 FB 01 75` | Needs runtime |
| 13 | Disable Player Regens | `41 BF 10 00 00 00 48 8B CE` | 0 | Needs runtime |

### Key Candidate Addresses

**SCOUT_REPORT_PLAYERS — Candidate A: `0x1454FA893`**
```asm
; Loop writing values with cmp edi,02 (2 iterations)
0x1454FA893: mov [rsi],eax
0x1454FA895: inc edi
0x1454FA897: add rsi,04
0x1454FA89B: cmp edi,02
0x1454FA89E: jl 1454FA852
; After loop: crypto lookup → movups to [rbx+4C] (copy 16 bytes)
```

**SCOUT_REPORT_PLAYERS — Candidate B: `0x14550E023`** (STRONGER candidate)
```asm
; Preceded by 3-iteration loop (cmp edi,03) at 0x14550DFA0-0x14550DFC4
; Then writes to [rbx+59C] area, then:
0x14550E000: mov eax,[rax]
0x14550E002: mov [rsi-38],eax        ; Field write at offset 0x59C-0x38
0x14550E005: mov r8d,edi
0x14550E023: mov [rsi],eax            ; 2-iteration loop
0x14550E025: inc ebx
0x14550E027: add rdi,04
0x14550E02B: cmp ebx,02
0x14550E02E: jl 14550DFE4
; After loop: lea rdi,[rbx+5C8]; more crypto lookups
```
Candidate B is more likely — it has a 3-iteration loop (OVR/POT/squad position?) followed by a 2-iteration loop matching the FIFA 19 pattern.

**5-star Skill Moves — Candidate A: `0x145433B20`**
```asm
mov [rbp+17C],esi
; Followed by: call 145437350, xor r8d,r8d, mov rax,[rbx+1A848]
; Context suggests rendering/UI code
```

**5-star Skill Moves — Candidate B: `0x14576537A`**
```asm
mov [rbp+17C],esi
; Followed by: movaps xmm0,[global], movaps [rbp+180],xmm0
; Then: mov [rbp+19C],19h (25 decimal)
; Context more consistent with attribute struct initialization
```

**RevealPotAndOvr Candidate: `0x148038925`**
```asm
; Outer loop (5 iterations) with inner loop (3 iterations) = 15 total
; cmp ebx,05 (5 star levels)
; cmp esi,03 (3 attributes per level?)
0x148038925: mov [rdi],eax
0x148038927: inc ebx
0x148038929: add rdi,04
0x14803892D: cmp ebx,05
0x148038930: jl 1480388F7
0x148038932: inc esi
0x148038934: cmp esi,03
0x148038937: jl 1480388F4
```
5×3 = 15 matches youth player count. This is a PRIORITY candidate for WeakFoot or Potential functionality.

## What To Do Next

### Step 1: Runtime Verification (REQUIRES FIFA 17 RUNNING WITH CAREER SAVE)

You need FIFA 17 running with a career save loaded and CE MCP Bridge connected.

1. **Attach to FIFA17.exe** via `cheatengine_open_process("FIFA17.exe")`
2. **Set execution breakpoints** on candidate addresses:
   ```
   0x14550E023  — SCOUT_REPORT_PLAYERS candidate B
   0x1454FA893  — SCOUT_REPORT_PLAYERS candidate A
   0x148038925  — RevealPotAndOvr / WeakFoot candidate
   0x145433B20  — SkillMoves candidate A
   0x14576537A  — SkillMoves candidate B
   ```
3. **Trigger scout report generation in-game**: Send a youth scout on a short mission, simulate forward
4. **Note which breakpoints fire** during youth player generation
5. **For each hit, disassemble the surrounding code** to confirm the injection context

### Step 2: Find Missing Features via Data Breakpoints

For features with zero candidates, use data breakpoints on known youth player structs:

1. Use the existing `ptrNotEditable` or `ptrPlayer` pointers from `ActivateItFirst` to find a youth player in memory
2. Set **write breakpoints** on key fields (potential, age, skill moves, weak foot)
3. Trigger youth player generation/scout report
4. The breakpoint handler will reveal the exact code writing these values
5. Extract unique AOB patterns from those code locations

### Step 3: For Same Country Multi-Scout

Search for the popup string:
```
cheatengine_search_string("Country Is Being Scouted")
```
Or find the UI text reference and trace back to the comparison logic. The FIFA 19 pattern `cmp bl,01; jne` should have an equivalent check in FIFA 17's UI flow.

### Step 4: Update youth_helpers.lua

Once you have confirmed FIFA 17 AOB patterns, update the `aobs` table in `lua/youth_helpers.lua` and change the corresponding status from `PENDING` to `VERIFIED`.

### Step 5: Move to Phase 2

After all 13 AOBs are confirmed, proceed to Phase 2 (Script Construction) per the PRD.

## FIFA 19 Reference: What Each Script Does

Each injection follows this pattern:
1. `aobscanmodule(INJECT_*, FIFA19.exe, <pattern>)` — find the code
2. Save original bytes with `readBytes()`
3. Replace with `jmp newmem_*` (5 bytes) + NOPs
4. Cave code: force desired values into registers, then execute original code
5. On disable: restore original bytes

| Feature | Original Bytes | Hook Size | What's Forced |
|---------|---------------|-----------|----------------|
| SCOUT_REPORT_PLAYERS | `89 06 FF C7 48 83 C6 04` (8 bytes) | jmp+3NOP | `eax = [intScoutReportPlayers]` before `mov [rsi],eax` |
| Reveal OVR & POT | `89 07 FF C3 48 83 C7 04` (8 bytes) | jmp+3NOP | `xor eax,eax` before OVR/POT mask write |
| PRIMARY_ATTR_RANGE | `43 89 44 F7 30` (5 bytes) | jmp | `eax = [primattr_rangelow]` / `[primattr_rangehigh]` to `[r15+r14*8+2C/30]` |
| SECONDARY_ATTR_RANGE | `43 89 44 F7 68` (5 bytes) | jmp | Same pattern at offsets +64/+68 |
| MIN_AGE (12) | `41 B8 03 00 00 00` (6 bytes) | jmp+NOP | `eax = 12` before `mov r8d,3` |
| AGE_RANGE [12,16] | 6 bytes at `mov [r15+08],eax` | jmp+NOP | `eax=12 → [r15+04]`, `eax=16 → [r15+08]` |
| Retire at 30 | `41 FF C4 89 03` (5 bytes) | jmp | `eax = 30` before `mov [rbx],eax` |
| 95 Potential | 9 bytes (first 6 hooked) | jmp+NOP | `eax = 95` before `mov [rsi],eax` |
| 5-star Weak Foot | `FF C3 89 07 48 8D 7F 04` (8 bytes) | jmp+3NOP | In 6-iteration loop: if iter==5, `eax=100`; else `eax=0` |
| Scout Any Country | `89 4C 24 30 B9 04 00 00 00` (9 bytes) | jmp+4NOP | If `[ptr_YA_NatID] != 0`, override `[rsp+30]` with user value |
| 5-star Skill Moves | `89 B5 7C 01 00 00` (6 bytes) | jmp+NOP | `esi = 4` (0-indexed 5 stars) |
| Same Country Multi-Scout | `80 FB 01 75 0C` (5 bytes) | jmp | Bypasses `cmp bl,01; jne` popup check |
| Disable Player Regens | `41 BF 10 00 00 00` (6 bytes) | jmp+NOP | `xor eax,eax` before `mov r15d,10h` |

## Key Memory Addresses & Symbols

- `FIFA17.exe` base: `0x140000000`
- Crypto field resolver function: `0x145EE0220`
- Error handler: `0x1473582E0`
- `ptrNotEditable` / `ptrPlayer` / `ptrTransferBudget` — existing CT symbols
- Youth-related strings found in data: `youthplayerattributes` at `0x098357DF` and `0x143BE09AF`

## Files

| File | Purpose |
|------|---------|
| `FIFA_17_Cheat_Table.CT` | The target cheat table |
| `FIFA_17_Cheat_Table.CT.bak` | Backup (made during Phase 0) |
| `lua/youth_helpers.lua` | AOB registry + validation functions |
| `docs/prd-youth-academy-port.md` | Full PRD |
| `docs/aob-discovery-log.md` | Detailed discovery findings from Session 1 |
| `docs/reference/fifa17-ct-structure.md` | Existing CT structure docs |
| `docs/reference/fifa19-ct-structure.md` | Reference FIFA 19 CT docs |