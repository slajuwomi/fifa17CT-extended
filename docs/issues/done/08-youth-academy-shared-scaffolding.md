# 08 — Youth Academy shared scaffolding

Type: AFK

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Prepare the FIFA 17 cheat table for incremental Youth Academy feature work without implementing any gameplay feature yet. The completed slice should create a safe empty Youth Academy group, wire helper loading, and prove the existing table still loads cleanly.

## Acceptance criteria

- [x] `FIFA_17_Cheat_Table.CT` has been backed up before modification.
- [x] An empty `Youth Academy` group appears after the existing Scouts Management group.
- [x] `lua/youth_helpers.lua` exists with helper functions but no unconfirmed FIFA 17 AOBs.
- [x] Lua helper loading is wired through `ActivateItFirst` or a dedicated init entry.
- [x] Cheat Engine can load the helper file from the external Lua path.
- [x] The CT file remains well-formed XML.
- [x] Existing CT features still appear and activate after the scaffolding change.

## Validation

- Backed up the CT to `FIFA_17_Cheat_Table.CT.bak` before edits.
- Parsed `FIFA_17_Cheat_Table.CT` with Python `xml.etree.ElementTree`.
- Loaded the edited CT through Cheat Engine MCP Bridge and confirmed `ActivateItFirst`, `Scouts Management`, `Free 5/5 Scout`, `Reveal GTN player data (scouting not needed)`, and `Youth Academy` appear.
- Loaded `lua/youth_helpers.lua` through Cheat Engine Lua from its external file path and confirmed `YouthAcademyHelpers.loaded == true` with zero registered AOB keys.

## Blocked by

None - can start immediately
