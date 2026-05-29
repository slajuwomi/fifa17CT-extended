# FIFA 19 "Free & Unlimited Releasing Players" — Deep Analysis

Complete analysis of the release feature being ported from FIFA 19 to FIFA 17.

## Script Overview

The script is a single Auto Assembler entry in FIFA19.CT with 3 code injection points. When activated, it removes the per-season release limit and eliminates the release fee. The user still sees the release confirmation dialog (which is necessary for the action to proceed), but the cost shown is $0 and no budget is deducted.

## Injection Point 1: UnlimitedPlayerRelease

### Purpose
Overrides the game's "too many players released this season" check and zeroes the cost that would be displayed.

### AOB Pattern
```
39 46 54 40 0F 9C C7
```

### Original Assembly
```asm
FIFA19.exe+42E2868:  cmp [rdi+54], eax     ; [rdi+54] = current release count
FIFA19.exe+42E286B:  setl dil              ; dil = 1 if eax < [rdi+54] (too many)
```

### Injected Code
```asm
newmem:
  mov [rdi+14], #999    ; Set max allowed releases to 999 (effectively unlimited)
  mov [rsi+54], #0      ; Zero out whatever is at [rsi+54] (cost-related)
  mov eax, [rdi+14]     ; Return the 999 value
  ; Original: mov dil, 1
  ; Falls through to original code which reads the overridden value
```

### Key Insights
- `[rdi+14]` is the release count limit — overridden to 999
- `[rsi+54]` is cost-related — zeroed out
- The function being injected is `cm_ap_release_releasetoomanyplayers` — a named internal function within FIFA 19's Action::Util namespace

## Injection Point 2: ReleasePlayerMsgBox

### Purpose
Makes the release confirmation popup show $0 cost. Purely cosmetic.

### AOB Pattern
```
4C 8B E0 85 FF 0F
```

### Original Assembly
```asm
FIFA19.exe+38A67EB:  mov r12, rax          ; Load cost into r12 for display
FIFA19.exe+38A67EE:  test edi, edi          ; Test condition
```

### Injected Code
```asm
newmem:
  xor r13, r13         ; Zero a register
  ; Original: mov r12,rax ; test edi,edi
  ; Falls through — r12 remains zeroed, dialog shows $0
```

### Key Insights
- `r12` holds the cost value displayed in the message box
- `xor r13, r13` is a 3-byte NOP-like instruction (zeroes r13) used as padding
- The original 6 bytes (`4C 8B E0 85 FF`) are replaced with a 5-byte jmp + 1 nop
- This injection is lower priority — the feature works without it, but the dialog shows a misleading non-zero cost

## Injection Point 3: ReleasePlayerFee

### Purpose
Actually prevents the release fee from being deducted from the club's budget.

### AOB Pattern
```
8B D8 48 8B 45 77
```

### Original Assembly
```asm
FIFA19.exe+...  mov ebx, eax              ; ebx = fee amount to deduct
FIFA19.exe+...  mov rax, [rbp+77]         ; Load something from stack
```

### Injected Code
```asm
newmem:
  xor eax, eax         ; Set eax to 0 (no fee)
  ; Original: mov ebx,eax ; mov rax,[rbp+77]
  ; Code continues, ebx will get eax which is 0
```

### Key Insights
- `eax` at this point contains the release fee amount
- By zeroing `eax` before `mov ebx, eax` executes, the fee becomes 0
- This is the only injection point that actually prevents budget deduction
- Without this, the message box might show $0 but the fee could still be charged because injection #1 works on a different code path

## Interaction Between Injection Points

Injection #1 handles the "too many releases" check AND zeros a cost value in a different register/structure. Injection #3 handles the actual fee deduction in yet another code path. The two functional injections complement each other — #1 prevents the limit enforcement and #3 prevents the fee deduction. They operate at different moments in the release flow:

```
User clicks "Release Player"
  → Game checks: too many released? → Injection #1 intercepts, says "no" (999 limit)
  → Game calculates fee → Injection #3 intercepts, says "$0"
  → Game shows confirmation dialog → Injection #2 intercepts, shows "$0"
  → User confirms → No fee deducted, player released
```

## How the Script Reference Works in FIFA19.CT

The AA script in FIFA19.CT uses AOB references from helpers.lua:

```asm
// The CT file references AOBs indirectly
// helpers.lua defines:
AOB_UnlimitedPlayerRelease = '39 46 54 40 0F 9C C7'
AOB_ReleasePlayerMsgBox   = '4C 8B E0 85 FF 0F'
AOB_ReleasePlayerFee      = '8B D8 48 8B 45 77'
```

The script uses `aobscanmodule()` with the pattern string directly (not the Lua variable name), since AutoAssembler and Lua are separate namespaces.

## Porting Strategy for FIFA 17

### Step 1: AOB Scanning
Search for each of the 3 AOB patterns in FIFA17.exe:
```powershell
# MCP bridge commands (pseudocode):
aob_scan "39 46 54 40 0F 9C C7"  # Injection 1
aob_scan "4C 8B E0 85 FF 0F"     # Injection 2
aob_scan "8B D8 48 8B 45 77"     # Injection 3
```

### Step 2: Context Verification
For each match found, disassemble the surrounding code to verify it's the same release logic:
```powershell
disassemble <matched_address>, count=10
```

### Step 3: Fallback — String Search
If AOB patterns don't match, search for function name strings:
```powershell
search_string "releasetoomanyplayers"
search_string "release"  # broader search
```

### Step 4: Fallback — Disassembly
If strings don't help, use memory breakpoints:
1. Set a write breakpoint on a known player data field
2. Trigger a release in-game
3. Trace the execution back to find the release check and fee calculation

### Step 5: Script Construction
Build the AA script matching the FIFA 17 structure:
- `aobscanmodule(INJECT_..., FIFA17.exe, ...)`
- `alloc(...)`
- Label original code
- Write code cave
- Register symbols
- Provide disable section with original bytes

### Step 6: Validation
1. Activate script via MCP bridge
2. In-game, release a player
3. Verify: no "too many released" error, $0 cost shown, no budget deducted
4. Release a second player to confirm unlimited

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| AOB patterns don't match FIFA 17 | Medium | Fallback to string search + disassembly |
| Memory layout differs (register assignments changed) | Medium | Adapt code cave logic after disassembly analysis |
| Release flow logic changed between FIFA 17 and 19 | Low | Frostbite engine, career mode logic is similar across versions |
| Script conflicts with existing ActivateItFirst injections | Low | Allocate separate code caves, different injection points |
