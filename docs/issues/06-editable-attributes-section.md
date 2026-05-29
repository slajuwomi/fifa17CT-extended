# 06 — Editable Attributes section (ptrPlayer attribute panels)

Type: AFK

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Add an `Attributes` section to the Players Editor containing the existing FIFA 17 `Edit Player` attribute groups, each rendered as its own group panel. All attributes use the slice 03 `ptrPlayer -> [68] -> [idx*8] -> [0] -> [20]` resolver and the metadata-table architecture, so this slice is mostly metadata population.

Slice 01 may already contain one editable attribute tracer (`Acceleration`) using the early `ptrNotEditable` resolver. In this slice, either migrate that tracer into the full `Attributes` section if the `ptrPlayer` field proves equivalent in-game, or keep the existing row and avoid rendering a duplicate `Acceleration` control. Document the choice in the PR.

Required panels and their fields (per the PRD MVP and the existing CT):

- **Attacking**: crossing, finishing, heading accuracy, short passing, volleys
- **Defending**: marking, standing tackle, sliding tackle
- **Skill**: dribbling, curve, free kick accuracy, long passing, ball control
- **Power**: shot power, jumping, stamina, strength, long shots
- **Movement**: acceleration, sprint speed, agility, reactions, balance
- **Mentality**: aggression, composure, interceptions, positioning, vision, penalties
- **Goalkeeping**: include this panel only if the current FIFA 17 CT exposes the GK fields through `ptrPlayer` (the `Edit Player → Goalkeeping` sub-group does — verify the offsets). If included, fields are GK Diving, GK Handling, GK Kicking, GK Positioning, GK Reflexes. If skipped, note it in the PR as a phase-two follow-up.

All attributes use the standard 1–99 (or 0–99 — match what the existing CT entries accept) numeric range for validation. The resolver, validation, write, and pointer-failure guard are all reused from earlier slices — no new architecture should be needed.

Layout: each attribute group is its own visual panel under an `Attributes` parent section so the form stays scannable. The PRD's phase-two list mentions tabs as a fallback if the form grows too dense; if the implementer judges the form is now too tall, raise it in the PR for slice 07 to address.

## Acceptance criteria

- [ ] Each listed attribute has a metadata-table row using the slice 03 `ptrPlayer` resolver; no hand-written read/write paths.
- [ ] The slice 01 `Acceleration` tracer is reconciled with the full Attributes section: migrated if equivalent, or retained once without duplicate controls if not.
- [ ] Six attribute panels (Attacking, Defending, Skill, Power, Movement, Mentality) render under an `Attributes` section.
- [ ] Goalkeeping panel is included if the current CT exposes the GK fields via `ptrPlayer`; otherwise its omission is noted in the PR.
- [ ] Min/max validation matches the existing CT entries' accepted ranges.
- [ ] `Load Current Player`, `Reload`, and `Apply Changes` all work for the new fields, with per-field failure reporting in the status label.
- [ ] Pointer-failure guard works for the entire Attributes section.
- [ ] Manual validation: at least one attribute from each visible panel can be edited, applied, and reflected on the player screen in FIFA 17.

## Blocked by

- 03 — ptrPlayer resolver + Preferred Foot tracer
