# Session Summary: Free & Unlimited Releasing Players (FIFA 17)

**Date:** 2026-05-09
**PRD:** `docs/prd-free-unlimited-releasing.md`
**Status:** Injection point 1 found and tested, but NOT working. Two attempts failed to bypass the release limit.

---

## Goal

Port the "Free & Unlimited Releasing Players" script from the FIFA 19 Career Mode Cheat Table to FIFA 17. This requires three code injection points that remove the per-season release limit, zero the release fee, and fix the confirmation popup to show $0.

---

## FIFA 19 Reference (Source of Truth)

**File:** `FIFA-19---Career-Mode-Cheat-Table\FIFA 19 - CM Cheat Table\FIFA19.CT` (lines 23266–23493)

**AOB patterns** (from `FIFA 19 - CM Cheat Table\lua\helpers.lua`, lines 547–549):

| Pattern | Bytes | Purpose |
|---------|-------|---------|
| `AOB_UnlimitedPlayerRelease` | `39 46 54 40 0F 9C C7` | Override per-season release limit |
| `AOB_ReleasePlayerMsgBox` | `4C 8B E0 85 FF 0F` | Make confirmation popup show $0 |
| `AOB_ReleasePlayerFee` | `8B D8 48 8B 45 77` | Zero the actual fee deduction |

### FIFA 19 Injection 1 Details (Release Limit)

Original code:
```
mov eax,[rbx+14]          // Load release count
cmp [rdi+54],eax          // Compare max vs count
setl dil                  // dil = 1 if max < count (limit exceeded)
```

FIFA 19 replacement (code cave):
```
mov [rdi+14], #999        // Write 999 to a data structure
mov [rsi+54], #0          // Write 0 to another data structure
mov eax, [rdi+14]         // Load 999 into eax
mov dil, 1                // Force setl result
jmp return
```

**Key insight:** The FIFA 19 script modifies actual game DATA (`[rdi+14]` and `[rsi+54]`), not just the comparison result. These data modifications affect ALL code paths that read these values — including UI code that shows the "Too Many Players Released Already" message.

---

## FIFA 17 Discovery Results

### Environment
- FIFA 17 process open (PID: 12712), Cheat Engine attached via MCP bridge
- `FIFA_17_Cheat_Table.CT` loaded but **ActivateItFirst NOT activated**
- Module: `FIFA17.exe`

### AOB Scan Results (FIFA 19 patterns vs FIFA 17)

| FIFA 19 Pattern | FIFA 17 Matches | Result |
|----------------|-----------------|--------|
| `39 46 54 40 0F 9C C7` | 0 | No match |
| `39 47 54 40 0F 9C C7` | 0 | No match |
| `4C 8B E0 85 FF 0F` | 3 (all in system DLLs, not FIFA17.exe) | No relevant match |
| `8B D8 48 8B 45 77` | 0 | No match |

**Conclusion:** FIFA 17's executable has different instruction encodings than FIFA 19. Direct pattern reuse doesn't work.

### RTTI String Discovery

Found function name strings in `FIFA17.exe.srdata`:

| String | Address |
|--------|---------|
| `cm_ap_release_releasetoomanyplayers` | `0x143C3EB88` |
| `cm_ap_release_cannotaffordfee` | `0x143C3EBB0` |
| `cm_ap_release_squadtoosmall` | `0x143C3EBD0` |
| `cm_ap_releaseplayer` | `0x143C4C4A8` |
| `ReleasePlayersForInstruction::order` | `0x143C3D821` |
| `ReleasePlayerData` | `0x14398EEF0` |

These confirm the same Frostbite function names exist in FIFA 17, just at different addresses.

### Injection Point 1 Found (Release Limit)

Wildcard scan `39 ?? 54 ?? 0F 9C` found exactly 1 match in `FIFA17.exe`:

**Address:** `FIFA17.exe+834E3D1` (`0x14834E3D1`)

Original code:
```
14834E3CE - 8B 46 14      - mov eax,[rsi+14]     // Load release count
14834E3D1 - 39 45 54      - cmp [rbp+54],eax     // Compare max vs count
14834E3D4 - 40 0F9C D5    - setl bpl              // bpl = (max < count)
```

Difference from FIFA 19: registers differ (rsi→rbx, rbp→rdi, bpl→dil) but logic is identical.

### How bpl Is Used Downstream

After the `cmp/setl`, `bpl` is tested far downstream:

```
14834E499 - 45 39 EC      - cmp r12d,r13d        // Compare budget vs fee
14834E49C - 0F99 D1       - setns cl
14834E4BF - 40 84 ED      - test bpl,bpl         // Check bpl
14834E4C2 - 41 0F44 F7    - cmove esi,r15d       // If bpl==0: esi = r15d = 0 (success)
...
14834E4E5 - 89 F0         - mov eax,esi           // Return value
14834E508 - C3            - ret
```

When `bpl=0`: function returns 0 (success — can release).
When `bpl=1`: function returns error code (2 or -2).

### Injection Point 2 (Message Box) — Not Found

The pattern `4C 8B E0 85 FF 0F` has no matches in `FIFA17.exe`. The wildcard `4C 8B ?? 85 ?? 0F 84` found 6 matches in `FIFA17.exe` but none were investigated — lower priority per PRD.

### Injection Point 3 (Fee Deduction) — Not Found

The pattern `8B D8 48 8B 45 77` has no matches in `FIFA17.exe`, and `8B D8 48 8B` has 0 matches too. Different instruction encodings.

However, `mov rax,[rbp+77]; mov [rax],ebx` (bytes `48 8B 45 77 89 18`) was found at:
- `0x14828DB7C` but the context doesn't match FIFA 19 (preceded by `2B 48 8B` not `8B D8`). Not the right location.

### Functions Identified

| Function | Address Range | Purpose |
|----------|--------------|---------|
| `cm_ap_release_cannotaffordfee` | `0x14834DF51` – `0x14834E049` | Budget/fee validation |
| `cm_ap_release_releasetoomanyplayers` | Starts at `0x14834E060` | Release count limit check (contains injection point 1) |

---

## Two Injection Attempts (Both Failed)

### Attempt 1: Minimal (Force bpl + Zero r13d)

```
newmem:
  xor r13d, r13d    // zero fee for budget check
  xor bpl, bpl      // zero limit flag
  jmp ret
```

**Result:** User still saw "Too Many Players Released Already" message. The function returns success but the UI message is generated from game data that wasn't modified.

### Attempt 2: Data-Field Modification (Like FIFA 19)

```
newmem:
  xor r13d, r13d            // zero fee
  mov [rbp+54], 999         // set max to 999 in game data
  mov [rsi+14], 0           // set count to 0 in game data
  mov eax, [rsi+14]         // load 0
  xor bpl, bpl              // zero limit flag
  jmp ret
```

**Result:** Still failed. "Too Many Players Released Already" message persisted.

---

## Why It's Not Working — Hypotheses

1. **The "Too Many Players Released Already" message is generated in a DIFFERENT code path** than `cm_ap_release_releasetoomanyplayers`. The message might come from the UI layer (`cm_ap_releaseplayer` or the popup creation code) that reads data from different structures or different offsets than `[rsi+14]`/`[rbp+54]`.

2. **The count and limit might be stored in different structure offsets** than in FIFA 19. In FIFA 19, the script modifies `[rdi+14]` (not `[rbx+14]` where count was loaded) and `[rsi+54]` (not `[rdi+54]` where max was loaded). This suggests a more complex data layout where count and limit exist in multiple locations. The correct offsets in FIFA 17 may differ.

3. **The `mov [rbp+54], 999` and `mov [rsi+14], 0` writes might be to the wrong structures.** The rsi/rbp registers at the injection point may point to objects that don't correspond to the fields the UI reads.

4. **There may be additional checks** — e.g., `cm_ap_releaseplayer` might call `cm_ap_release_releasetoomanyplayers` AND also do its own independent limit check that bypasses this function entirely.

---

## Next Steps / Ideas

### Approach A: Trace the FULL release flow with breakpoints
1. Set hardware breakpoints at `cm_ap_releaseplayer` and `cm_ap_release_releasetoomanyplayers`
2. Try to release a player and see which functions are actually called
3. Check the return values to confirm the injection IS making `cm_ap_release_releasetoomanyplayers` return success
4. If it returns success but still blocks, the block is elsewhere

### Approach B: Search for ALL references to the release count data
1. Activate `ActivateItFirst` in the cheat table to resolve pointers
2. Use `ptrPlayer` or other pointers to trace the actual data structures
3. Scan for ALL code that reads from `[rsi+14]` to find other check locations

### Approach C: Find the UI popup code
1. Search for the actual display string "Too Many Players Released Already" or similar
2. Trace backward from the popup to find the validation code
3. Inject there instead

### Approach D: Broader injection point
1. Inject at the function entry (`0x14834E060`) and force immediate return with success
2. This is more aggressive but bypasses ALL internal checks

### Approach E: Use DBVM watch on release-related data
1. Set DBVM memory watches on `[rsi+14]` to see what code reads/writes it during the release flow
2. This reveals ALL code paths that interact with the release count

---

## Files Modified This Session

- **None** — no files were written to disk. All work was done via MCP bridge live memory access.

## CT File Insertion Location

When ready to write the script to `FIFA_17_Cheat_Table.CT`:
- Insert as a new `<CheatEntry>` under ActivateItFirst, as a sibling to the GroupHeaders
- After line 2371 (after `</CheatEntry>` closing "Club Finances"), before line 2372 (`</CheatEntries>` closing ActivateItFirst children)
- Use 8-space indent for the `<CheatEntry>` and 10-space indent for its children

---

## Key Addresses

| Description | Address |
|-------------|---------|
| `cm_ap_release_releasetoomanyplayers` string | `0x143C3EB88` |
| `cm_ap_release_cannotaffordfee` string | `0x143C3EBB0` |
| `cm_ap_release_squadtoosmall` string | `0x143C3EBD0` |
| `cm_ap_releaseplayer` string | `0x143C4C4A8` |
| Injection point 1 (cmp+setl) | `0x14834E3D1` (`FIFA17.exe+834E3D1`) |
| AOB for injection point 1 | `39 45 54 40 0F 9C D5` (7 bytes, unique) |
| `cm_ap_release_cannotaffordfee` start | `0x14834DF51` |
| `cm_ap_release_releasetoomanyplayers` start | `0x14834E060` |
| `bpl` usage (cmove) | `0x14834E4BF` |
| Function return | `0x14834E508` |
| Possible fee pattern (differs from FIFA 19) | `0x14828DB7C` |
