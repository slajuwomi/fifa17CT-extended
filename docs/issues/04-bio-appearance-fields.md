# 04 — Remaining Bio / Appearance fields

Type: AFK

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Fill out the `Bio / Appearance` group panel created in slice 03 with the remaining MVP fields. All of these ride the `ptrPlayer` resolver and existing CT entries already prove their offsets, so this slice is pure metadata-table population plus layout.

Fields to add (`Preferred foot` is already present from slice 03):

- Player position ID (`PlayerPositionID`) — uses the single-offset `ptrPlayer -> [A28]` variant
- Nationality
- Year of birth
- Month of birth
- Day of birth
- Boots ID
- Sleeves
- Football socks length
- Height (note: this is the `ptrPlayer` Height, distinct from the `ptrNotEditable` Height already in the General panel — keep both, or merge into one row in General per implementer judgement; if merged, document why)
- Weight
- Skin color ID

The PRD also lists `Position type` and `Position`. The PRD's scope rule is: only include numeric fields **already proven in the current FIFA 17 table**. Inspect `FIFA_17_Cheat_Table.CT` for entries matching those names. If they exist with proven offsets, include them. If they do not, skip them in this slice and call them out in the issue completion notes as phase-two candidates.

Min/max validation per field uses realistic in-game ranges where known (e.g. months 1–12, days 1–31). Where a sensible range is not obvious (e.g. `Boots ID`, `Skin color ID`), use a permissive range and note the choice — fine-tuning is part of slice 07's manual validation pass.

## Acceptance criteria

- [ ] Each listed field has a metadata-table row using the slice 03 resolver; no hand-written read/write paths.
- [ ] `PlayerPositionID` uses the single-offset `ptrPlayer -> [A28]` variant.
- [ ] All fields render in the `Bio / Appearance` group with consistent layout.
- [ ] Whether the duplicate `Height` field is kept or merged is decided and documented in the PR.
- [ ] `Position type` and `Position` are included only if proven in the current CT; otherwise skipped with a note.
- [ ] Out-of-range or non-numeric input is rejected before any write occurs.
- [ ] Pointer-failure guard works for the whole panel.
- [ ] Manual validation: at least three fields from this slice can be edited, applied, and reflected on the player screen in FIFA 17.

## Blocked by

- 03 — ptrPlayer resolver + Preferred Foot tracer
