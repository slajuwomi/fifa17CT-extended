# 01 — Player Editor GUI shell + editable attribute tracer

## Summary

Implemented the first FIFA 17 `Players Editor` GUI slice inside `FIFA_17_Cheat_Table.CT`.

The completed slice adds an `Open Player Editor GUI` cheat-table entry that creates a `Players Editor` form with `Load Current Player`, `Apply Changes`, `Reload`, and a status label. The form is metadata-driven and currently displays read-only `PlayerOVR` context plus editable `Acceleration` as the visible tracer field.

## Key Decisions

- `PlayerOVR` is read-only. Manual validation proved direct writes update memory but do not change FIFA 17's visible overall.
- `Acceleration` became the editable tracer because it resolves through the existing `ptrPlayer` chain and is reflected in-game.
- The metadata row shape now supports read-only and editable fields, resolver selection, offset chains, min/max validation, and per-field controls.
- The GUI establishes reusable styling for read-only controls and validates inputs before any write occurs.

## Validation

- Structural regression test: `python -m unittest tests.test_player_editor_gui`.
- Live CE MCP checks confirmed `PlayerOVR` and `Acceleration` resolution.
- Human validation confirmed the updated GUI could load a player and successfully edit `Acceleration` in FIFA 17 Career Mode.

## Follow-Up Notes

- A future target-OVR feature should adjust attributes through an understood weighting/calculation rather than directly writing the stored OVR field.
- Slice `03` should expand the existing `ptrPlayer` resolver for Bio/Appearance fields rather than introducing `ptrPlayer` from scratch.
