# 16 — Youth Academy 95 potential feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `95 Potential` feature so newly generated youth players receive 95 potential while the script is active.

## Acceptance criteria

- [x] The FIFA 17 equivalent of the FIFA 19 `95 Potential` AOB has been discovered or reengineered.
- [x] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [x] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [x] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [x] The CT contains the `95 Potential` entry under `Youth Academy`.
- [ ] Enabling the script generates youth players with 95 potential in a real FIFA 17 Career Mode session with other youth generation modifiers disabled.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding

## Validation pending

Runtime discovery found the FIFA 17 potential range initialization path after a Career Mode scout report was generated.

- The FIFA 19 AOB `89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48` returned 0 matches in `FIFA17.exe`.
- The FIFA 17 format string `PLAYER_ATTRIBUTES/TIER_%d_POTENTIAL_RANGE_%d` was found at `0x143C626D0`.
- The code reference at `0x148579C6B` builds each `PLAYER_ATTRIBUTES/TIER_%d_POTENTIAL_RANGE_%d` key, looks up the value, then writes it in a two-value loop.
- The confirmed FIFA 17 AOB is `FF C3 48 83 C6 04 89 46 FC 83 FB 02 7C C2 44 89 F3` at `0x148579C97`.
- The hook forces `eax = 95` before `mov [rsi-04],eax`, overriding each loaded potential range value.

Next decision needed: validate in a real FIFA 17 Career Mode session that enabling `95 Potential` before generating a fresh scout report produces youth players with 95 potential, then disable and re-enable the script without reloading the CT.
