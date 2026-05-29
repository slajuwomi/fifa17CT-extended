# 12 — Youth Academy secondary attributes range feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `SECONDARY_ATTRIBUTES_RANGE` feature so the user can configure generated youth player secondary attribute low and high ranges. This slice should validate the secondary range behavior independently from primary attributes.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `SECONDARY_ATTRIBUTES_RANGE` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `SECONDARY_ATTRIBUTES_RANGE` entry under `Youth Academy`.
- [ ] The CT contains the `secmattr_rangelow` and `secmattr_rangehigh` child entries.
- [ ] Enabling the script applies the configured secondary attribute range in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
