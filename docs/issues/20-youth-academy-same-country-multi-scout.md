# 20 — Youth Academy same-country multi-scout feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `Set Up Multiple Scouting Networks in Same Country` feature so duplicate country assignments are not blocked by the "Country Is Being Scouted" popup.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `Set Up Multiple Scouting Networks in Same Country` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `Set Up Multiple Scouting Networks in Same Country` entry under `Youth Academy`.
- [ ] Enabling the script allows multiple scouting networks in the same country in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
