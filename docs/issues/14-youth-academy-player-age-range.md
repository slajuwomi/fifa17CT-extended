# 14 — Youth Academy player age range feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `YOUTH_PLAYER_AGE_RANGE = [12, 16]` feature so new scout reports produce youth players in the configured age range.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `YOUTH_PLAYER_AGE_RANGE` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `YOUTH_PLAYER_AGE_RANGE = [12, 16]` entry under `Youth Academy`.
- [ ] Enabling the script generates scout report players aged 12 through 16 in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
