# 15 — Youth Academy retire age 30 feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `Youth Player Retire at Age = 30` feature so generated youth players do not leave the academy early due to the retirement or academy-leaving age assignment.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `Youth Player Retire at Age = 30` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `Youth Player Retire at Age = 30` entry under `Youth Academy`.
- [ ] Enabling the script forces the expected age behavior in a real FIFA 17 Career Mode session without relying on age range or promotion scripts.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
