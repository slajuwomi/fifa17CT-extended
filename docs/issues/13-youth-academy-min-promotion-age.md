# 13 — Youth Academy minimum promotion age feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `MIN_PLAYER_AGE_FOR_PROMOTION = 12` feature so younger academy players can be promoted to the senior team while the script is active.

## Acceptance criteria

- [x] The FIFA 17 equivalent of the FIFA 19 `MIN_PLAYER_AGE_FOR_PROMOTION` AOB has been discovered or reengineered.
- [x] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [x] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [x] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [x] The CT contains the `MIN_PLAYER_AGE_FOR_PROMOTION = 12` entry under `Youth Academy`.
- [ ] Enabling the script allows promotion of a player below the normal promotion age in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Prerequisite

- 08 — Youth Academy shared scaffolding: complete

## Blocker

Implementation and static/runtime discovery are complete, but the final two acceptance criteria require a real FIFA 17 Career Mode save with a youth academy player below the normal promotion age. Validate by enabling `ActivateItFirst`, enabling `Youth Academy > MIN_PLAYER_AGE_FOR_PROMOTION = 12` before loading the save, promoting a below-age academy player, disabling the script, then re-enabling it without reloading the CT.
