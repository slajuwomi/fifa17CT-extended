# 01 — Player Editor GUI shell + editable attribute tracer

Type: HITL

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Stand up the FIFA 17 `Players Editor` GUI inside `FIFA_17_Cheat_Table.CT` as the first end-to-end vertical slice. The form must be openable from the cheat table, must safely resolve the required player pointers (and abort with a clear message when they are null), and must support the full load → edit → validate → apply → reload loop for one visible editable tracer field: `Acceleration`.

`PlayerOVR` is **not** the editable tracer. Manual testing showed the value can be written and read back in memory, but FIFA 17 does not use that stored field to drive the visible in-game overall. Treat OVR as read-only context in the GUI until/unless a separate derived-OVR feature is designed. Every later slice is "add more rows to the metadata table" and depends on the architecture established here.

The slice should establish:

- A new Lua script block inside `FIFA_17_Cheat_Table.CT` that creates the form on load and exposes a way to (re)open it (either auto-show, or an `Open Player Editor GUI` script entry under `ActivateItFirst`).
- A field-metadata table shape — even with a small tracer set — that later slices extend. At minimum each row carries: label, control name, variable type, base symbol, offset chain, min/max, editable/read-only flag.
- Address-resolution helper for read-only `ptrNotEditable` context.
- Address-resolution helper for the existing CT's editable `ptrPlayer` pointer-chain pattern used by `Acceleration`.
- A single `Players Editor` window with header section: `Load Current Player`, `Apply Changes`, `Reload`, and a status/error label.
- A `General` group panel containing read-only `PlayerOVR` context and one editable numeric field for `Acceleration`.
- Validation that rejects non-numeric / out-of-range values before any write occurs.
- Pointer-failure guard: if `ptrNotEditable` does not resolve, the GUI must surface a clear message in the status label and must not write to address 0.
- Visual treatment for read-only vs editable fields established now, so later slices reuse it.

Manual validation in FIFA 17 Career Mode is part of acceptance.

## Acceptance criteria

- [x] `FIFA_17_Cheat_Table.CT` contains a Lua script block that creates a `Players Editor` TCEForm.
- [x] The form is openable from the cheat table (auto-show on table load and/or via a script entry under `ActivateItFirst`).
- [x] Header contains `Load Current Player`, `Apply Changes`, `Reload` buttons and a status/error label.
- [x] A field-metadata table exists and drives reading for all displayed fields and writing for the editable tracer field.
- [x] Address-resolution helpers exist for read-only `ptrNotEditable` context and the editable `ptrPlayer` pointer-chain tracer.
- [x] `Load Current Player` reads `PlayerOVR` from memory into a read-only control and reads `Acceleration` into an editable control; pressing it again is idempotent.
- [x] `Apply Changes` validates the editable `Acceleration` input, writes the changed value back to memory, reads it back, and reports success or failure in the status label.
- [x] `Reload` discards unsaved edits and re-reads current memory.
- [x] Entering a non-numeric or out-of-range value blocks the write and shows a clear message; nothing is written to memory.
- [x] When `ptrNotEditable` or `ptrPlayer` is null, all three buttons surface a clear status message and skip the read/write; no write goes to address 0.
- [x] Read-only fields have a visually distinct or disabled style established for later slices to reuse.
- [x] Manual validation: with `ActivateItFirst` enabled and a player selected in FIFA 17, `Acceleration` can be loaded, edited, applied, and the change is reflected on the player screen in-game.
- [x] Manual validation: `PlayerOVR` is displayed read-only and is not presented as an editable field; changing visible overall remains out of scope for this slice.

## Blocked by

None — can start immediately.
