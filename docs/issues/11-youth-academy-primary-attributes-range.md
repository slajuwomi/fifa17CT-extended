# 11 — Youth Academy primary attributes range feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `PRIMARY_ATTRIBUTES_RANGE` feature so the user can configure generated youth player primary attribute low and high ranges. This slice should validate the primary range behavior independently from secondary attributes.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `PRIMARY_ATTRIBUTES_RANGE` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `PRIMARY_ATTRIBUTES_RANGE` entry under `Youth Academy`.
- [ ] The CT contains the `primattr_rangelow` and `primattr_rangehigh` child entries.
- [ ] Enabling the script applies the configured primary attribute range in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
