# 10 — Youth Academy reveal OVR and POT feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `Reveal OVR & POT` feature so generated youth players show true OVR and Potential without scouting uncertainty. This slice should be validated independently with other Youth Academy generation modifiers disabled.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `Reveal OVR & POT` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `Reveal OVR & POT` entry under `Youth Academy`.
- [ ] Enabling the script removes youth OVR/POT uncertainty in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
