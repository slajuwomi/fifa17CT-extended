# 21 — Youth Academy disable player regens discovery slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Investigate only the Youth Academy `Disable Player Regens` feature. Because the FIFA 17 regen system may differ from FIFA 19, this slice should either produce a safely validated implementation or stop with evidence explaining why the feature should remain blocked.

## Acceptance criteria

- [ ] The FIFA 19 `Disable Player Regens` behavior and AOB context have been reviewed against FIFA 17.
- [ ] The discovery log records the FIFA 19 AOB, any FIFA 17 candidates, disassembly context, and why the selected path is or is not safe.
- [ ] If a safe FIFA 17 equivalent is found, `lua/youth_helpers.lua` contains only the confirmed AOB key needed for this feature.
- [ ] If a safe FIFA 17 equivalent is found, the hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] If implemented, the CT contains the `Disable Player Regens` entry under `Youth Academy`.
- [ ] If implemented, the feature is validated in a real FIFA 17 Career Mode session.
- [ ] If blocked, no CT entry is added and the discovery log explains the blocker with enough detail for a future reverse-engineering pass.

## Blocked by

- 08 — Youth Academy shared scaffolding
