# 18 — Youth Academy scout any country feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `Send Scout to Any Country` feature so the user can optionally override generated youth player nationality through a configurable Nationality ID.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `Send Scout to Any Country` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `Send Scout to Any Country` entry under `Youth Academy`.
- [ ] The CT contains the `ptr_YA_NatID` child entry.
- [ ] With `ptr_YA_NatID` set to `0`, scouting nationality behaves normally.
- [ ] With `ptr_YA_NatID` set to a valid nationality ID, generated youth players use that nationality in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
