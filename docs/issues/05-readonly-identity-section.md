# 05 — Read-only Identity section

Type: AFK

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Add an `Identity` group panel to the Players Editor that displays the four player name strings as **read-only** values. Per the PRD MVP rule, name editing is explicitly out of scope until string-write safety is tested separately.

Fields to display:

- First name
- Surname
- Known as
- Kit name

These strings live behind the existing `ptrPlayerFirstName`, `ptrPlayerLastName`, `ptrKnownAs`, and `ptrNameOnShirt` symbols, which are only populated when the corresponding `AA_Name*` Auto Assembler scripts (under the existing `Edit Player → Other` group in the CT) are activated. The GUI must degrade gracefully when those pointers are null:

- The four name controls are visually distinct / disabled per the read-only treatment established in slice 01.
- If any of the four name pointers are null when `Load Current Player` runs, that specific field shows a clear placeholder (e.g. `<AA_Name scripts not activated>`) instead of crashing or showing stale data.
- The status label may surface a one-line hint pointing the user at the `AA_Name*` scripts when at least one name pointer is null — but only as a hint; loading other fields must still succeed.
- `Apply Changes` skips identity fields entirely (they are read-only).

The string-read helper added here lives alongside the existing numeric resolvers and reads a null-terminated ASCII string from the dereferenced pointer (matching the existing CT entries' `Unicode="0" ZeroTerminate="1"` shape).

## Acceptance criteria

- [ ] An `Identity` group panel exists in the form, containing the four name fields rendered with the read-only style established in slice 01.
- [ ] A string-read helper exists and is used by all four identity rows; no hand-written per-field read code.
- [ ] When any of `ptrPlayerFirstName`, `ptrPlayerLastName`, `ptrKnownAs`, `ptrNameOnShirt` is null, the corresponding field shows a clear placeholder instead of crashing or showing garbage.
- [ ] The status label hints at the `AA_Name*` scripts when at least one name pointer is null, without blocking other fields from loading.
- [ ] `Apply Changes` does not attempt to write any identity field.
- [ ] Manual validation: with the four `AA_Name*` scripts activated, the displayed names match the player open in FIFA 17. With them deactivated, the placeholders appear and the rest of the form still loads.

## Blocked by

- 01 — Player Editor GUI shell + editable attribute tracer
