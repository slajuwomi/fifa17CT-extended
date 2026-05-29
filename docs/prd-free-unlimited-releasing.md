# PRD: Free & Unlimited Releasing Players (FIFA 17)

## Problem Statement

In FIFA 17 Career Mode, releasing a player from their contract is restricted — you can only release 1-2 players per season, and each release costs a transfer fee. This limits the user's ability to manage their squad freely, clear out unwanted players to rebuild a team, or experiment with different roster compositions.

## Solution

Port the "Free & Unlimited Releasing Players" Auto Assembler script from the FIFA 19 Career Mode Cheat Table to the FIFA 17 Cheat Table. When activated, the script removes both the per-season release limit and the monetary cost, allowing the user to release as many players as desired at zero cost.

## User Stories

1. As a FIFA 17 Career Mode player, I want to release an unlimited number of players per season, so that I can freely rebuild my squad without arbitrary game restrictions.
2. As a FIFA 17 Career Mode player, I want to release players at zero cost, so that I don't waste my transfer budget on unwanted players.
3. As a cheat table user, I want a simple toggle (activate/deactivate), so that I can enable the feature only when I need it and disable it when I don't.
4. As a cheat table user, I want the script placed under the `ActivateItFirst` group, so that it follows the same organizational structure as other scripts in the table.
5. As a cheat table user, I want a clear description of what the script does, so that I understand its effect before activating it.

## Implementation Decisions

- **Approach**: The feature will be implemented as an Auto Assembler Script within the existing `FIFA_17_Cheat_Table.CT` file, nested under the `ActivateItFirst` group header.
- **Injection points**: Three code injection points will be ported from the FIFA 19 script:
  1. **Unlimited Release Count** — overrides the per-season release limit check, setting max to 999 and zeroing cost display.
  2. **Release Fee Zero** — zeroes the actual fee deduction when releasing a player.
  3. **Message Box Fix** — makes the confirmation popup display $0 cost (cosmetic, lower priority; can be skipped if the AOB pattern proves difficult to find).
- **Discovery method**: Use the Cheat Engine MCP bridge to scan FIFA 17 process memory for AOB patterns from the FIFA 19 script. If patterns match (FIFA 17 and 19 share the Frostbite engine, so internal logic is likely similar), use them directly. Fallback: search for function name strings and disassemble relevant code sections.
- **Validation**: Test each injection live using the MCP bridge's `auto_assemble` function before writing to the CT file. Verify in-game by releasing players and confirming no limit and no cost.
- **File format**: The script will follow the same XML structure as existing entries in the FIFA 17 cheat table (e.g., `Training sim - A`, `Free 5/5 Scout`), with `[ENABLE]`/`[DISABLE]` sections and inline original code comments.

## Testing Decisions

- Testing is deferred — will not be covered in this PRD cycle.
- Manual validation will be performed via in-game testing with the MCP bridge.

## Out of Scope

- The GUI editor for players — this will be addressed in a separate PRD.
- Any modifications to FIFA 17's INI configuration files.
- Scripts that modify player contract details, release clauses, or transfer fees in other contexts.
- The hard game requirement of having at least 18 players on the roster (this is not overridden by the script).

## Further Notes

- The FIFA 19 Career Mode Cheat Table source code is available in the repo at `FIFA-19---Career-Mode-Cheat-Table/`. The release script is located in `FIFA19.CT` with three injection points defined by AOB patterns `AOB_UnlimitedPlayerRelease`, `AOB_ReleasePlayerMsgBox`, and `AOB_ReleasePlayerFee`.
- The existing FIFA 17 cheat table already has similar Auto Assembler injection patterns under `ActivateItFirst` (e.g., `ptrTransferBudget`, `ptrPlayer`, `ptrNotEditable`) which serve as structural reference.
- All discovery and testing will use the Cheat Engine MCP bridge for live memory access to the FIFA 17 process.
