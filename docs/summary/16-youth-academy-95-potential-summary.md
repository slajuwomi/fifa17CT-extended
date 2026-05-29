# Issue 16 Summary — Youth Academy 95 Potential

## Scope

Attempted `docs/issues/16-youth-academy-95-potential.md`, which targets only the Youth Academy `95 Potential` feature.

## What Changed

- Added `95 Potential` under the `Youth Academy` CT group.
- Added confirmed helper key `AOB_PlayerPotentialRange` to `lua/youth_helpers.lua`.
- Updated `docs/aob-discovery-log.md` with the FIFA 19 AOB, FIFA 17 alternate initialization hook, injection address, original code context, and validation notes.
- Updated `docs/issues/16-youth-academy-95-potential.md` to mark implementation criteria complete and HITL behavior criteria pending.

## Discovery

- Cheat Engine attached to `FIFA17.exe` PID 17932.
- FIFA 19 AOB `89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48` returned 0 matches.
- FIFA 17 static format string `PLAYER_ATTRIBUTES/TIER_%d_POTENTIAL_RANGE_%d` was found at `0x143C626D0`.
- Code reference `0x148579C6B` builds the formatted setting name, calls the setting lookup, and writes the result in a two-value loop.
- Confirmed unique FIFA 17 AOB `FF C3 48 83 C6 04 89 46 FC 83 FB 02 7C C2 44 89 F3` at `0x148579C97`.
- The hook forces `eax = 95` before `mov [rsi-04],eax`, so each loaded potential range value is written as 95.

## Validation

- The confirmed AOB resolved uniquely in `FIFA17.exe`.
- `auto_assemble_check(script)` passed for the enable section.
- HITL validation confirmed the script enabled without error and generated scout report players had high potentials consistent with the feature.
- Standalone disable-section checking reported a Cheat Engine access violation at `dealloc(newmem_YA_PlayerPotential)` because the allocation does not exist during isolated disable validation.
- Live disable/re-enable validation remains pending.

## What Worked Well

- The direct FIFA 19 signature was ruled out quickly.
- Searching for `POTENTIAL_RANGE` found the FIFA 17 setting format string even though fully formatted keys were not resident.
- A CE Lua RIP-relative scan found the exact code reference to the format string.

## What Did Not Work

- The direct FIFA 19 assignment signature did not map to FIFA 17.
- A read watchpoint on the format string did not fire when reopening an already generated scout report, likely because the settings initialization path had already run.
- Fully formatted setting keys such as `PLAYER_ATTRIBUTES/TIER_1_POTENTIAL_RANGE_0` were not resident as plain strings.

## Notes For Future Agents

- Validate by enabling `95 Potential` before generating a fresh scout report with other youth generation modifiers disabled.
- Confirm generated youth players have 95 potential.
- Disable and re-enable the script without reloading the CT, then generate another fresh report to confirm clean behavior.
- If validation fails, inspect whether FIFA 17 initializes these ranges only once per Career Mode load; the script may need to be enabled before loading the save.

## Remaining Risks

- The likely INI-backed approach may conflict with other future INI-backed youth scripts if they hook the same lookup site independently.
- Cross-feature validation should explicitly test this feature with other youth generation modifiers disabled first, then with compatible combinations.
