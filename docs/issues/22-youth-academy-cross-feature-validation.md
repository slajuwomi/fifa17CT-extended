# 22 — Youth Academy cross-feature validation pass

Type: HITL

## Parent

`docs/prd-youth-academy-port.md`

## What to build

Run the final Youth Academy validation pass after the individual feature slices have been implemented and validated. This slice should prove the scripts coexist, disable cleanly, and do not regress existing FIFA 17 cheat table behavior.

## Acceptance criteria

- [ ] The modified CT loads in Cheat Engine without XML or Lua initialization errors.
- [ ] `ActivateItFirst` enables without errors.
- [ ] Each completed Youth Academy script enables individually and still passes its feature-specific behavior check.
- [ ] Common combinations of Youth Academy scripts can be enabled together without crashes or conflicting patches.
- [ ] Each completed Youth Academy script disables cleanly after combination testing.
- [ ] Existing non-Youth-Academy CT features still appear and activate.
- [ ] Any skipped or blocked Youth Academy feature is documented with a link to its issue and discovery notes.
- [ ] A short validation summary records the Career Mode save used, the feature combinations tested, and any defects found.

## Blocked by

- 09 — Youth Academy SCOUT_REPORT_PLAYERS feature slice
- 10 — Youth Academy reveal OVR and POT feature slice
- 11 — Youth Academy primary attributes range feature slice
- 12 — Youth Academy secondary attributes range feature slice
- 13 — Youth Academy minimum promotion age feature slice
- 14 — Youth Academy player age range feature slice
- 15 — Youth Academy retire age 30 feature slice
- 16 — Youth Academy 95 potential feature slice
- 17 — Youth Academy 5-star weak foot feature slice
- 18 — Youth Academy scout any country feature slice
- 19 — Youth Academy 5-star skill moves feature slice
- 20 — Youth Academy same-country multi-scout feature slice
- 21 — Youth Academy disable player regens discovery slice, unless explicitly blocked or skipped
