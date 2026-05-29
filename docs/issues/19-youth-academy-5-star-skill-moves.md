# 19 — Youth Academy 5-star skill moves feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `100% Chance for 5-star Skill Moves` feature so newly generated youth players receive 5-star skill moves while the script is active.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `100% Chance for 5-star Skill Moves` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `100% Chance for 5-star Skill Moves` entry under `Youth Academy`.
- [ ] Enabling the script generates youth players with 5-star skill moves in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
