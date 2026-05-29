# 08 — Youth Academy shared scaffolding

Type: AFK

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Prepare the FIFA 17 cheat table for incremental Youth Academy feature work without implementing any gameplay feature yet. The completed slice should create a safe empty Youth Academy group, wire helper loading, and prove the existing table still loads cleanly.

## Acceptance criteria

- [ ] `FIFA_17_Cheat_Table.CT` has been backed up before modification.
- [ ] An empty `Youth Academy` group appears after the existing Scouts Management group.
- [ ] `lua/youth_helpers.lua` exists with helper functions but no unconfirmed FIFA 17 AOBs.
- [ ] Lua helper loading is wired through `ActivateItFirst` or a dedicated init entry.
- [ ] Cheat Engine can load the helper file from the external Lua path.
- [ ] The CT file remains well-formed XML.
- [ ] Existing CT features still appear and activate after the scaffolding change.

## Blocked by

None - can start immediately
