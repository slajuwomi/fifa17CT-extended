# Youth Academy Implementation Prompt

You are implementing the FIFA 17 Youth Academy port described in
`docs/prd-youth-academy-port.md`.

Work from the local issue queue in `docs/issues/`. The active Youth Academy issues are
`08-youth-academy-shared-scaffolding.md` through
`22-youth-academy-cross-feature-validation.md`.

## Goal

Port the approved FIFA 19 Youth Academy cheat table features into
`FIFA_17_Cheat_Table.CT` incrementally. Each development pass must complete at most one
local issue and at most one user-facing feature.

Do not batch multiple Youth Academy features into one pass. The PRD intentionally splits
the work into vertical slices so each feature can be discovered, implemented, validated,
and reviewed independently.

## Required Workflow

1. Pick the lowest-numbered unblocked Youth Academy issue in `docs/issues/`.
2. Read the issue, `docs/prd-youth-academy-port.md`, and any referenced discovery docs.
3. Confirm the issue is not blocked by an unfinished prerequisite.
4. Follow TDD-style vertical development:
   - RED: define one observable behavior or validation check for the current slice.
   - GREEN: make the smallest implementation change that satisfies that behavior.
   - REFACTOR: clean up only after the check passes.
   - Repeat for the next behavior in the same issue.
5. Keep tests and checks behavior-focused. Prefer public surfaces and real integration
   paths: CT XML loading, Lua helper behavior, Auto Assembler syntax checks, MCP Bridge
   discovery output, and real FIFA 17 Career Mode validation where required.
6. Update `docs/aob-discovery-log.md` for every feature slice before considering the
   issue complete.
7. Add a concise handoff summary for the feature slice under `docs/summary/` before
   finishing the pass. Name it after the issue, for example
   `docs/summary/13-youth-academy-min-promotion-age-summary.md`.
8. Do not start the next issue until the current issue's acceptance criteria are either
   complete or explicitly blocked with evidence.

## TDD Guidance for This Repo

This project has a mix of static files, Cheat Engine Auto Assembler scripts, Lua helpers,
and manual in-game validation. Apply TDD as vertical tracer bullets rather than bulk test
writing.

Good RED checks for this repo include:

- A CT XML parse check that fails before a new entry is added.
- A Lua helper lookup check that fails before a confirmed AOB key exists.
- An `auto_assemble_check(script)` failure before the script is syntactically valid.
- A documented MCP Bridge discovery check before an injection point is confirmed.
- A manual FIFA 17 validation checklist item before the in-game behavior is proven.

Avoid implementation-coupled tests that only prove internal helper names, exact XML
ordering beyond what Cheat Engine requires, or speculative behavior for future issues.

## Issue Completion Rules

An issue is complete only when:

- Every acceptance criterion in the issue is checked off or explicitly marked blocked.
- The PRD remains consistent with the implementation.
- Relevant discovery notes have been added to `docs/aob-discovery-log.md`.
- A feature-slice handoff summary has been added under `docs/summary/`.
- The modified CT still loads or the blocker explains why it cannot be validated yet.
- No unrelated features were implemented.

When an issue is complete, move its markdown file from `docs/issues/` to
`docs/issues/done/`. Preserve the filename. Do not delete completed issues.

If an issue is blocked:

- Leave it in `docs/issues/`.
- Add a short `## Blocker` section to the issue with the evidence, failed command or
  validation step, and the next decision needed.
- Do not move blocked issues to `done/`.

## Dependency Order

Start here:

1. `08-youth-academy-shared-scaffolding.md`

Then each feature slice may start after `08` is complete:

1. `09-youth-academy-scout-report-players.md`
2. `10-youth-academy-reveal-ovr-pot.md`
3. `11-youth-academy-primary-attributes-range.md`
4. `12-youth-academy-secondary-attributes-range.md`
5. `13-youth-academy-min-promotion-age.md`
6. `14-youth-academy-player-age-range.md`
7. `15-youth-academy-retire-age-30.md`
8. `16-youth-academy-95-potential.md`
9. `17-youth-academy-5-star-weak-foot.md`
10. `18-youth-academy-scout-any-country.md`
11. `19-youth-academy-5-star-skill-moves.md`
12. `20-youth-academy-same-country-multi-scout.md`
13. `21-youth-academy-disable-player-regens-discovery.md`

Finish with:

1. `22-youth-academy-cross-feature-validation.md`

The final validation issue is blocked by all completed feature slices. If a feature slice
was explicitly blocked or skipped, reference that issue and its discovery notes in the
final validation summary.

## Scope Guardrails

- Keep existing FIFA 17 CT features untouched unless the current issue requires a local
  integration point.
- Do not implement excluded PRD features: Generate New Report, Hire Scouts, Custom
  Player ID, or the already-existing Free 5/5 Scout feature.
- Add only confirmed FIFA 17 AOBs to `lua/youth_helpers.lua`.
- Each script must validate its AOB before patching memory and restore original bytes on
  disable.
- Do not preserve compatibility with speculative or unshipped Youth Academy work if a
  cleaner implementation is available within the current issue.

## Required Summary File Per Issue

Create `docs/summary/<issue-file-stem>-summary.md` during each feature pass. Keep it
brief but useful for the next agent. Include:

- What changed.
- What was discovered, including confirmed AOBs, rejected AOBs, injection addresses, and
  alternate approaches.
- What validation passed and what remains blocked.
- What worked well.
- What did not work or caused errors.
- Notes and cautions for future agents.
- Remaining risks for cross-feature validation.

If an issue is blocked, still create or update the summary file and clearly mark the
blocked validation step, evidence gathered, and next decision needed.

## Expected Final Report Per Issue

When finishing a development pass, report:

- Which issue was completed, blocked, or left in progress.
- What behavior was validated.
- Which files changed.
- Whether the issue file was moved to `docs/issues/done/`.
- Which summary file was created or updated.
- Any remaining risk or manual validation still needed.
