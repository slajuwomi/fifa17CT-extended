# Issue 13 Summary — Youth Academy Minimum Promotion Age

## Scope

Completed `docs/issues/13-youth-academy-min-promotion-age.md`, which adds only the Youth Academy `MIN_PLAYER_AGE_FOR_PROMOTION = 12` feature to `FIFA_17_Cheat_Table.CT`.

## What Changed

- Added `MIN_PLAYER_AGE_FOR_PROMOTION = 12` under the `Youth Academy` CT group.
- Added confirmed helper key `AOB_MinAgeForPromotionIniLookup` to `lua/youth_helpers.lua`.
- Updated `docs/aob-discovery-log.md` with the FIFA 19 AOB, FIFA 17 alternate injection approach, injection address, original code context, and validation notes.
- Moved the completed issue file to `docs/issues/done/13-youth-academy-min-promotion-age.md`.

## Discovery

- The FIFA 19 AOB `41 B8 03 00 00 00 89 85 E4` returned 0 matches in `FIFA17.exe`.
- The feature was reengineered through FIFA 17's INI setting lookup path instead of the FIFA 19 hardcoded age-category write.
- The confirmed FIFA 17 AOB is `49 8B 41 18 48 8B 04 C8 48 85 C0 74 0E`.
- The injection address observed during discovery was `0x147765D31`.
- The script compares the current lookup name against `YOUTH_SQUAD/MIN_PLAYER_AGE_FOR_PROMOTION` and writes `12` to the resolved setting value at `[value+08]`.

## Validation

- `FIFA17.exe` was running and Cheat Engine attached successfully through MCP Bridge.
- The confirmed FIFA 17 AOB resolved uniquely.
- `auto_assemble_check(script)` passed for the enable section.
- `FIFA_17_Cheat_Table.CT` parsed as well-formed XML after the CT edit.
- HITL validation passed in a real FIFA 17 Career Mode session: the script allowed promotion below the normal promotion age, and disable/re-enable worked without requiring a CT reload.

## What Worked Well

- The external `lua/youth_helpers.lua` registry kept the confirmed AOB isolated to this feature slice.
- The alternate INI lookup approach was safer than forcing a speculative direct FIFA 19-style code port.
- Cheat Engine MCP Bridge was useful for confirming process attachment, AOB scan count, disassembly, and Lua helper behavior.
- Keeping the issue blocked until HITL validation avoided prematurely moving the issue to `done/`.

## What Did Not Work

- Direct FIFA 19 AOB porting failed for this feature; the exact FIFA 19 pattern had no FIFA 17 match.
- The first helper implementation assumed `AOBScan()` results supported `getAddress()`. This Cheat Engine build did not, causing activation to fail with `attempt to call a nil value (field 'getAddress')`.
- `auto_assemble_check` did not catch the helper accessor problem because it only surfaced when the Lua helper ran against the actual AOB scan result object.

## Fixes Made During Validation

- Added a compatibility accessor in `lua/youth_helpers.lua` that tries `getAddress`, then `getString`, then indexed access for AOB scan results.
- Verified the fixed helper in Cheat Engine Lua: `get_validated_address('AOB_MinAgeForPromotionIniLookup')` resolved to `147765D31`.

## Notes For Future Agents

- Do not assume FIFA 19 youth feature AOBs map directly to FIFA 17. Start with exact scan, but be ready to reengineer through FIFA 17's INI lookup or obfuscated field resolver paths.
- When using `AOBScan()` in Cheat Engine Lua, support string-list variants. This environment may expose `getString()` but not `getAddress()`.
- For INI-backed gameplay constants, `YOUTH_SQUAD/...` and similar setting names can be strong anchors when direct instruction patterns fail.
- Keep each Youth Academy issue to one feature slice. Add only confirmed AOB keys to `lua/youth_helpers.lua`.
- If a feature needs HITL validation, leave it in `docs/issues/` with a blocker until the user confirms in-game behavior.
- After completion, update the discovery log, move the issue to `docs/issues/done/`, and add a session summary under `docs/summary/`.

## Remaining Risks

- This feature was validated manually in one Career Mode flow. Future cross-feature validation should still test it alongside other Youth Academy scripts once more slices are implemented.
- The INI lookup hook is shared infrastructure-level code, so future INI-backed scripts should avoid installing overlapping hooks at the same AOB unless they intentionally compose behavior in one script.
