# 09 — Youth Academy SCOUT_REPORT_PLAYERS feature slice

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Implement only the Youth Academy `SCOUT_REPORT_PLAYERS` feature so the user can configure how many players appear in each youth scout report. This slice should discover the FIFA 17 injection point, add the script and child value, and validate the feature in game before any other Youth Academy feature is attempted.

## Acceptance criteria

- [ ] The FIFA 17 equivalent of the FIFA 19 `SCOUT_REPORT_PLAYERS` AOB has been discovered or reengineered.
- [ ] The discovery log records the FIFA 19 AOB, FIFA 17 AOB or alternate injection approach, injection address, original code context, and validation notes.
- [ ] `lua/youth_helpers.lua` contains only the new confirmed AOB key needed for this feature.
- [ ] The hybrid Lua+AA script passes `auto_assemble_check(script)`.
- [ ] The CT contains the `SCOUT_REPORT_PLAYERS` entry under `Youth Academy`.
- [ ] The CT contains the `intScoutReportPlayers` child entry.
- [ ] Enabling the script changes the scout report player count in a real FIFA 17 Career Mode session.
- [ ] Disabling and re-enabling the script restores clean behavior without requiring a CT reload.

## Blocked by

- 08 — Youth Academy shared scaffolding
