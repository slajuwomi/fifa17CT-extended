# 02 — Editable General fields (ptrNotEditable)

Type: HITL

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Extend the `General` panel of the Players Editor with the remaining MVP fields that live behind the `ptrNotEditable -> [idx*8] + [0]` pattern. This slice is the first real reuse of the metadata-driven architecture established in slice 01 and is HITL because the metadata table shape is being stress-tested for the first time — minor revisions to the row shape, validation rules, or panel layout are expected.

`PlayerOVR` remains read-only. Manual validation in slice 01 showed FIFA 17 does not honor direct writes to that stored field for the visible in-game overall, so this slice must not reintroduce editable OVR.

Fields to add:

- Player OVR — read-only context only
- Player potential
- Player ID
- International reputation
- Height
- Skill moves — exposed using the existing `Value + 1 = SkillMoves *` semantics from the current CT (i.e. the GUI displays / writes the on-screen skill-moves value, but stores `value - 1` to memory or vice versa, matching the CT entry exactly).
- Weak foot

Each field gets a label + numeric control in the `General` group and a metadata-table row. Editable fields get load/validate/apply/reload behaviour identical to slice 01; read-only OVR loads and reloads but is skipped by apply. Min/max validation per editable field uses the realistic in-game ranges (e.g. ratings 1–99, reputation 1–5, weak foot 1–5).

The PRD does not finalise the exact min/max bounds for every field — call those out in the implementation and confirm during the manual check.

## Acceptance criteria

- [ ] Each field has a row in the metadata table; no read or write logic is hand-written outside the metadata-driven helpers from slice 01.
- [ ] `PlayerOVR` appears in the `General` group as read-only context and is skipped by `Apply Changes`.
- [ ] All six editable fields appear in the `General` group with consistent label / edit-box layout.
- [ ] `Load Current Player` populates all fields; `Reload` re-reads them; `Apply Changes` writes only the fields whose values changed (or writes all editable fields, matching whatever pattern slice 01 established) and reports per-field failures in the status label.
- [ ] Skill moves uses the same `value + 1` semantic as the existing CT entry — verified by editing the in-game value and confirming the displayed and stored numbers match the existing CT entry's behaviour.
- [ ] Out-of-range or non-numeric input is rejected before any write occurs.
- [ ] Pointer-failure guard from slice 01 still works for all new fields.
- [ ] Manual validation: each editable field can be edited, applied, and the change is reflected on the player screen in FIFA 17.

## Blocked by

- 01 — Player Editor GUI shell + editable attribute tracer
