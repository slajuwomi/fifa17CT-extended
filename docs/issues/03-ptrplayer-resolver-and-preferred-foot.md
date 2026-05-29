# 03 — ptrPlayer resolver + Preferred Foot tracer

Type: AFK

## Parent

`docs/prd-player-editor-gui.md`

## What to build

Extend the `ptrPlayer` resolver introduced by slice 01 so it supports the Bio/Appearance pointer shapes, and prove that end-to-end with a single field (`Preferred foot`). This slice exists separately from the bulk Bio/Appearance fields slice so the expanded resolver gets its own focused review and a minimal demoable surface, instead of being introduced alongside ten other fields at once.

The expanded resolver must support both Bio/Appearance shapes used by the existing CT:

- The standard nested chain: `ptrPlayer -> [68] -> [idx*8] -> [0] -> [20]` (used by Preferred Foot, Nationality, YOB, etc.).
- The single-offset variant: `ptrPlayer -> [A28]` (used by `PlayerPositionID`).

The metadata-table row shape from slice 01 may need a small extension (e.g. an `offset_chain` array or a `resolver` discriminator) so a single helper can dispatch to either pattern. Keep the change minimal and additive — slice 01's existing rows must continue to work unchanged.

The new resolver must reuse the same pointer-failure guard pattern: if `ptrPlayer` is null, the GUI surfaces a clear status message and skips the read/write rather than dereferencing 0.

The tracer field is `Preferred foot`. Add it as a numeric edit box in a new `Bio / Appearance` group panel (the panel itself is created here and filled out by slice 04).

## Acceptance criteria

- [ ] The existing `ptrPlayer` address-resolution helper remains alongside the existing `ptrNotEditable` helper.
- [ ] The helper handles slice 01's attribute chain, the Bio/Appearance `[68] -> [idx*8] -> [0] -> [20]` chain, and the single-offset `[A28]` variant.
- [ ] Metadata rows can declare which resolver / offset chain they use; existing slice 01 rows still work without modification.
- [ ] A `Bio / Appearance` group panel exists in the form, currently containing only `Preferred foot`.
- [ ] `Preferred foot` loads, validates, applies, and reloads end-to-end.
- [ ] Pointer-failure guard fires cleanly when `ptrPlayer` is null — no write to address 0, clear status message.
- [ ] Manual validation: editing `Preferred foot` and applying changes the value on the player screen in FIFA 17.

## Blocked by

- 01 — Player Editor GUI shell + editable attribute tracer
