# 07 — Manual validation pass against PRD checklist

Type: HITL

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Run the PRD's `Manual Validation Checklist` against a real FIFA 17 Career Mode session with the fully assembled Players Editor (slices 01 + 02 + 03 + 04 + 05 + 06 merged). Use this slice to surface and fix any defects that only show up when the whole form is present together — layout regressions, validation-range guesses that turn out to be wrong, missing pointer guards, panel density issues, status-label clarity, etc.

The PRD's checklist, run end-to-end:

- Activate `ActivateItFirst`.
- Open or select a player in FIFA 17 so `ptrPlayer` and `ptrNotEditable` are populated.
- Open the player editor GUI.
- Click `Load Current Player`.
- Confirm read-only `PlayerOVR` displays as context only and is not editable.
- Confirm identity fields display the expected player.
- Change at least one general numeric field.
- Change at least one attribute in each visible attribute group.
- Click `Apply Changes`.
- Back out and reopen the player screen in FIFA 17.
- Confirm changed values are reflected in-game.
- Click `Reload` and confirm the GUI rereads the current values.
- Try an invalid value and confirm the GUI blocks the write with a clear message.

Also re-check the negative path: with `ActivateItFirst` not yet enabled, every button in the form must surface a clear status message rather than crash or write to address 0.

Defect fixes made in this slice are scoped to issues uncovered by the checklist. Anything new (e.g. release clause editing, name editing, player search) belongs to the PRD's phase-two list, not here.

## Acceptance criteria

- [ ] Every step of the PRD's `Manual Validation Checklist` has been executed against FIFA 17 Career Mode and passes.
- [ ] The negative path (`ActivateItFirst` not enabled) has been executed and surfaces clear messages, no writes to address 0, no crashes.
- [ ] All min/max validation ranges have been sanity-checked against accepted in-game values; any range adjustments are documented.
- [ ] The form remains scannable; if the implementer judged a tabs migration is needed, that decision is documented (and either done here or filed as a phase-two follow-up).
- [ ] Any defects found during validation are either fixed in this slice or filed as new issues with clear repro steps.
- [ ] A short validation summary is added to the PR description listing what was tested, on which player, and what changed.

## Blocked by

- 02 — Editable General fields (ptrNotEditable)
- 04 — Remaining Bio / Appearance fields
- 05 — Read-only Identity section
- 06 — Editable Attributes section (ptrPlayer attribute panels)
