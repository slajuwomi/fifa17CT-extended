# Session Summary: FIFA 17 Free & Unlimited Releasing Players Handoff

**Date:** 2026-05-09  
**Context:** Continuing from `docs/session-summary-free-unlimited-releasing.md` and `docs/prd-free-unlimited-releasing.md`  
**Current status:** A CT entry was added to preserve the only patch that restored the release option. Further fee/free-release work remains unresolved.

## Goal

Port FIFA 19's "Free & Unlimited Releasing Players" behavior to FIFA 17:

1. Remove the per-season release limit.
2. Make player releases cost zero.
3. Optionally make the confirmation/menu display show zero cost.

The immediate priority became preserving the release-limit bypass that made the menu option selectable again.

## Environment

- FIFA 17 process was attached through the Cheat Engine MCP bridge.
- MCP bridge connectivity was confirmed earlier via `ping`.
- Cheat Engine bridge version reported: `12.0.0`.
- FIFA 17 process ID during this session: `12712`.
- Work was done live in memory via MCP and then preserved in `FIFA_17_Cheat_Table.CT`.

## Important Correction From Previous Session

The previous session labeled `FIFA17.exe+834E060` as the release-limit function start. That was wrong.

The function containing the release-limit comparison starts at:

```asm
FIFA17.exe+834E290
```

The known release-limit comparison inside that function is:

```asm
FIFA17.exe+834E3CE - 8B 46 14      - mov eax,[rsi+14]
FIFA17.exe+834E3D1 - 39 45 54      - cmp [rbp+54],eax
FIFA17.exe+834E3D4 - 40 0F 9C D5   - setl bpl
```

The helper later produces error result `-2` for the "Too Many Players Released Already" case:

```asm
FIFA17.exe+834E4BA - BE FE FF FF FF - mov esi,FFFFFFFFFFFFFFFE
FIFA17.exe+834E4BF - 40 84 ED       - test bpl,bpl
FIFA17.exe+834E4C2 - 41 0F 44 F7    - cmove esi,r15d
FIFA17.exe+834E4E5 - 89 F0          - mov eax,esi
FIFA17.exe+834E508 - C3             - ret
```

## What Worked

A broad helper-entry bypass made the player action menu show the release option again instead of "Too Many Players Released Already".

Live patch:

```asm
FIFA17.exe+834E290:
  xor eax,eax
  ret
```

Original bytes overwritten:

```text
55 56 57 41 54 41 55 41 56 41 57 48 81 EC A0 00 00 00 48
```

Patched bytes:

```text
31 C0 C3 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
```

User confirmed after this patch:

- The "Too Many Players Released Already" message disappeared.
- The release option returned.
- The release option still showed a per-player release cost.

## CT Change Made

A new cheat table entry was added to:

```text
FIFA_17_Cheat_Table.CT
```

Location:

- Under `ActivateItFirst`
- After `Club Finances`

Entry description:

```text
"Free & Unlimited Releasing Players"
```

Entry ID:

```text
9000
```

Script added:

```asm
[ENABLE]
// Bypass the FIFA 17 release-limit helper so the player action menu allows releases.
// This intentionally leaves the per-player release cost display untouched.
aobscanmodule(INJECT_FreeUnlimitedReleasingPlayers,FIFA17.exe,55 56 57 41 54 41 55 41 56 41 57 48 81 EC A0 00 00 00 48 C7 44 24 60 FE FF FF FF)

INJECT_FreeUnlimitedReleasingPlayers:
  xor eax,eax
  ret
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop

registersymbol(INJECT_FreeUnlimitedReleasingPlayers)

[DISABLE]
INJECT_FreeUnlimitedReleasingPlayers:
  db 55 56 57 41 54 41 55 41 56 41 57 48 81 EC A0 00 00 00 48

unregistersymbol(INJECT_FreeUnlimitedReleasingPlayers)
```

Important: this CT entry only preserves the release-limit bypass. It does not make release fees free.

## Experiments That Failed Or Were Reverted

### 1. Patch Only The Internal `bpl` Flag

Tried:

```asm
FIFA17.exe+834E3D4:
  xor bpl,bpl
  nop
```

Result:

- The menu still showed "Too Many Players Released Already".
- This suggested the visible menu state was either cached or built through a side-effect path before the final helper return.

Reverted to:

```text
40 0F 9C D5
```

### 2. Patch The `-2` Error Assignment

Tried:

```asm
FIFA17.exe+834E4BA:
  xor esi,esi
  nop
  nop
  nop
```

Result:

- Did not reliably clear the disabled menu state.
- Reverted to original:

```text
BE FE FF FF FF
```

### 3. Patch Final Return Only

Tried:

```asm
FIFA17.exe+834E4E5:
  xor eax,eax
```

Result:

- The menu still showed "Too Many Players Released Already".
- The item remained disabled and could not be selected.
- This implied the helper performs a UI/menu side effect before returning.

Reverted to:

```text
89 F0
```

### 4. Zero Release Fee Register

Breakpoint logs showed `r13d` matched the displayed release fee for the selected player. Example:

- Displayed fee: `£13,175`
- `r13d`: `0x3377` = `13175`

Tried:

```asm
FIFA17.exe+834E3CB:
  xor r13d,r13d
```

Original:

```asm
FIFA17.exe+834E3CB:
  mov r13d,eax
```

Result:

- Not enough to solve the release-limit behavior.
- Fee display work was intentionally deferred.
- Reverted to:

```text
41 89 C5
```

### 5. Unsafe Virtual/UI Side-Effect Call NOP

Hypothesis: this call was notifying/building the disabled menu reason before the final return.

Tried:

```asm
FIFA17.exe+834E4E2:
  nop
  nop
  nop
```

Original:

```asm
FIFA17.exe+834E4E2:
  call qword ptr [rax+18]
```

Result:

- Bad. The game froze.
- Cheat Engine Lua editor started showing repeated errors:

```text
bad argument #1 to 'insert' (table expected, got nil)
```

Action taken:

- Restored `FIFA17.exe+834E4E2` to `FF 50 18`.
- Restored `FIFA17.exe+834E4E5` to `89 F0`.
- Cleared all breakpoints.
- User later confirmed they could release players again.

Do not patch this virtual call path again without a safer, deeper understanding.

## Breakpoint Findings

Breakpoints were set on:

```text
FIFA17.exe+834E290
FIFA17.exe+834E4B3
FIFA17.exe+834E4BA
FIFA17.exe+834E4E5
```

Key observation from logs:

- The helper was hit when reopening the menu.
- The `-2` branch at `FIFA17.exe+834E4BA` was hit.
- The return point showed `rsi = FFFFFFFE`, confirming the "too many releases" result.
- `r13d` contained the release fee for the selected player.

Example fee observation:

```text
r13d = 0x3377 = 13175
```

## UI/Text Investigation

The exact string was searched in process memory:

```text
Too Many Players Released Already
```

Live copies were found at addresses including:

```text
0x0F4CCF10
0xDDF73398
0xDE34BD98
```

Data watchpoints on those strings produced a very large number of hits, mostly in generic UI/string routines, including:

```text
0x1477EDB5C
0x1477FB647
0x1477CBD32
0x1477E0A3A
```

This path was noisy and not a good direct patch target. It confirmed that chasing the rendered text or per-player formatted cost is brittle.

## Current Live Process State At End

Before writing this handoff, the risky live patches were reverted.

The CT file now contains the helper-entry bypass, but the currently running game process may or may not still have the live helper-entry bypass applied depending on subsequent manual toggles/reloads. For a clean validation, restart FIFA 17 and Cheat Engine, load the updated CT, activate `ActivateItFirst`, then activate `"Free & Unlimited Releasing Players"`.

## What Still Needs To Be Done

### Immediate Validation

1. Start from a clean FIFA 17 + Cheat Engine session.
2. Load the updated `FIFA_17_Cheat_Table.CT`.
3. Activate `ActivateItFirst`.
4. Activate `"Free & Unlimited Releasing Players"`.
5. Confirm the AOB resolves and the script activates.
6. Open a player action menu after already hitting the normal release limit.
7. Confirm the release option is selectable.
8. Actually release a player and verify the action succeeds.

### Fee Work

The current CT entry does not make releases free.

Known clue:

- `r13d` in the helper held the selected player's release fee.
- Zeroing it at `FIFA17.exe+834E3CB` was not sufficient to solve the whole feature and was reverted.

Recommended next direction:

- Do not chase the displayed string.
- Find the actual budget deduction path when confirming a release.
- Use a before/after transfer budget value or set a watchpoint on the budget pointer, then release a player and inspect the code that writes the deduction.
- Patch that write/calculation to zero the deduction.

### Better Limit Patch If The Entry Bypass Is Too Broad

The helper-entry bypass is broad but worked for restoring the release option.

If a narrower/safer patch is desired later:

- Investigate the caller that passes or stores `-2` into the menu builder before the helper's final return.
- Avoid patching `FIFA17.exe+834E4E2`; it froze the game.
- Prefer finding where the result code is generated before the UI notification call, or where the menu enable flag is decided.

## Recovery Bytes

If a future session needs to manually restore the helper function entry:

```text
FIFA17.exe+834E290:
55 56 57 41 54 41 55 41 56 41 57 48 81 EC A0 00 00 00 48
```

If a future session needs to restore other experimented bytes:

```text
FIFA17.exe+834E3CB:
41 89 C5

FIFA17.exe+834E3D4:
40 0F 9C D5

FIFA17.exe+834E4BA:
BE FE FF FF FF

FIFA17.exe+834E4E2:
FF 50 18

FIFA17.exe+834E4E5:
89 F0
```

## High-Level Takeaway

The useful progress is the helper-entry bypass at `FIFA17.exe+834E290`. It restored the release option and has been saved into `FIFA_17_Cheat_Table.CT`.

The remaining unsolved part is making releases free. That should be approached through the actual budget deduction/write path, not by patching the menu text or per-player displayed cost.
