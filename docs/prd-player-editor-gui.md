# PRD: FIFA 17 Player Editor GUI

## Problem Statement

The FIFA 17 cheat table already exposes many player editing fields through the Cheat Engine address list, but editing them is cumbersome: users must expand nested groups, understand which pointer group is active, and manually edit raw values. FIFA 19's cheat table provides a better workflow through a dedicated player editor GUI. The goal is to bring that style of workflow to the FIFA 17 table without overreaching into unproven FIFA 17 memory areas.

## Goal

Create a FIFA 17 `Players Editor` GUI inside the cheat table that can load the currently selected in-game player, display useful identity context, edit proven numeric fields, validate input, and apply changes back to memory.

## Reference Source

The FIFA 19 reference cheat table is in this repository at `FIFA-19---Career-Mode-Cheat-Table/FIFA 19 - CM Cheat Table/FIFA19.CT`. The FIFA 17 implementation should use that file, plus the existing reference docs under `docs/reference/`, when comparing the FIFA 19 player editor GUI architecture against the FIFA 17 table.

## MVP Decisions

- Build a lightweight Lua/TCEForm layer inside `FIFA_17_Cheat_Table.CT`.
- Construct the MVP form programmatically in Lua so the implementation is reviewable and easy to iterate in git.
- Use the existing `ActivateItFirst` pointer captures as the memory foundation:
  - `ptrPlayer` for player edit fields.
  - `ptrNotEditable` for fields already exposed in the `NotEditable` group.
- Load the player via a `Load Current Player` button, using whichever player FIFA 17 has currently opened or selected in-game.
- Use explicit writes: values are loaded into GUI fields, validated, and written only when the user clicks `Apply Changes`.
- Provide a `Reload` button to discard unsaved GUI edits and reread current memory.
- Show name/string identity fields in MVP, but keep them read-only until string write safety is tested.
- Validate MVP manually in-game rather than building automated tests around Cheat Engine/game memory.

## MVP Field Coverage

### Editable General Fields

- Player potential
- Player ID
- International reputation
- Height
- Skill moves value, using the existing `Value + 1 = SkillMoves *` field semantics
- Weak foot

### Read-Only General Context

- Player OVR

Direct writes to the FIFA 17 stored OVR field were proven to write/read back in memory but not update the visible in-game overall. Treat OVR as read-only context in the MVP. A future "target OVR" feature would need to derive and write appropriate attributes rather than editing OVR directly.

### Read-Only Identity Fields

- First name
- Surname
- Known as
- Kit name

### Editable Bio/Appearance Fields

Only numeric fields already proven in the current FIFA 17 table should be included:

- Player position ID
- Preferred foot
- Nationality
- Year of birth
- Month of birth
- Day of birth
- Boots ID
- Sleeves
- Football socks length
- Height
- Weight
- Skin color ID
- Position type
- Position

Fields currently named as unknowns in the CT should not be included in the MVP GUI unless they are renamed and validated first.

### Editable Attributes

The MVP should include the existing FIFA 17 `Edit Player` attribute groups:

- Attacking: crossing, finishing, heading accuracy, short passing, volleys.
- Defending: marking, standing tackle, sliding tackle.
- Skill: dribbling, curve, free kick accuracy, long passing, ball control.
- Power: shot power, jumping, stamina, strength, long shots.
- Movement: acceleration, sprint speed, agility, reactions, balance.
- Mentality: aggression, composure, interceptions, positioning, vision, penalties.
- Goalkeeping fields should be included if the current CT exposes them through `ptrPlayer`; otherwise they can remain phase-two.

## Out Of Scope For MVP

- Searching players by player ID or database.
- Editing release clause, morale, form, fitness, contract details, or transfer data.
- Recreating the full FIFA 19 GUI architecture with all forms.
- Enabling string writes for names or kit-name fields.
- Reworking the existing address-list memory records.
- Adding external companion applications.

## UX Requirements

- The GUI should be a single `Players Editor` window.
- The top section should show current-player context and actions:
  - `Load Current Player`
  - `Apply Changes`
  - `Reload`
  - status/error label
- Fields should be grouped into clear sections:
  - General
  - Identity
  - Bio / Appearance
  - Attributes
- Read-only fields should be visually distinct or disabled.
- Numeric fields should reject invalid values before writing.
- Failed pointer resolution should show a clear message instead of writing to address `0`.

## Technical Plan

1. Add a Lua script block to the FIFA 17 CT that initializes the player editor GUI.
2. Define field metadata tables rather than hand-writing every read/write path:
   - label
   - control name
   - variable type
   - base symbol, such as `ptrPlayer` or `ptrNotEditable`
   - offset chain
   - min/max validation
   - editable/read-only flag
3. Implement address resolution helpers for the two current memory patterns:
   - `ptrNotEditable -> [0] + index * 8`
   - `ptrPlayer -> pointer chains currently used by Edit Player`
4. Implement form creation helpers:
   - create labels and edit boxes
   - create grouped panels
   - create buttons and status label
5. Implement `load_current_player()`:
   - verify `ptrPlayer` and `ptrNotEditable` resolve safely
   - read field values
   - populate controls
   - mark the form as clean
6. Implement `apply_changes()`:
   - validate editable controls
   - write numeric fields
   - report any failed writes
   - reload after successful apply
7. Add a way to open the form from the table:
   - either show it on table load, or add an `Open Player Editor GUI` script/menu action.
8. Manually test in FIFA 17 Career Mode.

## Manual Validation Checklist

- Activate `ActivateItFirst`.
- Open or select a player in FIFA 17 so `ptrPlayer` and `ptrNotEditable` are populated.
- Open the player editor GUI.
- Click `Load Current Player`.
- Confirm read-only OVR displays as context and is not editable.
- Confirm identity fields display the expected player.
- Change at least one general numeric field.
- Change at least one attribute in each visible attribute group.
- Click `Apply Changes`.
- Back out and reopen the player screen in FIFA 17.
- Confirm changed values are reflected in-game.
- Click `Reload` and confirm the GUI rereads the current values.
- Try an invalid value and confirm the GUI blocks the write with a clear message.

## Phase Two Candidates

- Enable safe editing for name/string fields after testing buffer limits and encoding.
- Add player search by Player ID.
- Add release clause editing if a reliable FIFA 17 pointer chain is discovered.
- Add morale, form, and fitness if FIFA 17 equivalents can be mapped.
- Add a target-OVR workflow that adjusts attributes after the attribute weighting/calculation is understood.
- Move from grouped panels to tabs if the form grows too dense.
- Extract Lua into clearer module-style sections if the CT script grows large.

