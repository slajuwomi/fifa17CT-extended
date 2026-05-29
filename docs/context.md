# FIFA 17 Cheat Table Development — Agent Context

High-level entry point for AI agents working on this codebase. Read this first.

## What Is This Repo?

A FIFA 17 cheat table (`FIFA_17_Cheat_Table.CT`) built with Cheat Engine, alongside a reference FIFA 19 cheat table (`FIFA-19---Career-Mode-Cheat-Table/`) that is being used as a source for porting features.

The repo also contains many `.ini` files for FIFA 17 game configuration modding, but these are not relevant to the cheat table development work.

## Current State

### FIFA 17 Cheat Table (FIFA_17_Cheat_Table.CT)
- Working cheat table with cheat engine version 24
- No Lua scripts — everything is XML + Auto Assembler
- Root entry is `ActivateItFirst` (must be enabled first)
- Provides: player editing, stats editing, training hacks, scout hacks, club finances
- Does NOT have: free/unlimited player releasing, any GUI forms

### FIFA 19 Cheat Table (FIFA19.CT)
- Full-featured cheat table with extensive Lua and 6 GUI forms (TCEForms)
- Reference implementation for features we want to port
- Has free/unlimited releasing, custom transfers, contract negotiation, etc.

## Active PRDs

| PRD | Status | File |
|-----|--------|------|
| Free & Unlimited Releasing Players | Planning complete, ready to build | `docs/prd-free-unlimited-releasing.md` |

## Documentation Index

### Reference Documentation (what exists and how it works)
| File | Content |
|------|---------|
| `docs/reference/fifa17-ct-structure.md` | Complete structure of the FIFA 17 CT — all entries, offsets, AOBs, pointer chains |
| `docs/reference/fifa19-ct-structure.md` | Complete structure of the FIFA 19 CT — forms, scripts, release clause system |
| `docs/reference/fifa19-lua-architecture.md` | How the Lua code is organized, form lifecycle, event system |
| `docs/reference/fifa19-release-feature-analysis.md` | Deep analysis of the 3-injection release script (the feature being ported) |
| `docs/reference/mcp-development-approach.md` | How to use the CE MCP Bridge for agentic development |

## Key Technical Facts

### Pointer Structures
- **ptrPlayer**: `player_ptr → [+68] → [index*8] → [+0] → [+20]` — used for editable attributes, traits, appearance
- **ptrNotEditable**: `noteditable_ptr → [index*8] → [+0]` — used for OVR, potential, and stat categories. OVR should be treated as read-only context; direct writes were proven to update memory but not the visible FIFA 17 overall.
- **ptrTransferBudget**: `budget_ptr → [+8]` — transfer budget value

### AOB Patterns (FIFA 17)
- `44 8B 48 08 41 89 F8 48 8D 55 A7` — ptrTransferBudget cave
- `45 89 AF FC 09 00 00 41 C6` — ptrPlayer cave
- `85 F6 ?? ?? 49 29 FA 48 8B 07` — ptrNotEditable cave

### AOB Patterns (FIFA 19 Release — for porting)
- `39 46 54 40 0F 9C C7` — UnlimitedPlayerRelease
- `4C 8B E0 85 FF 0F` — ReleasePlayerMsgBox
- `8B D8 48 8B 45 77` — ReleasePlayerFee

### Development Tool
- Cheat Engine MCP Bridge v12.0.0 — accessed via the `cheatengine_*` tools
- Full memory read/write, scanning, disassembly, auto-assemble, and Lua execution

## Decisions Made (from grilling session)

1. **Build order**: Free & Unlimited Releasing first (simpler), GUI second (complex)
2. **Testing**: AOB scan from FIFA 19 patterns first, fall back to reverse engineering
3. **Delivery**: MCP bridge for live discovery, then write to CT file
4. **Placement**: New script goes under `ActivateItFirst` group
5. **Scope**: All 3 injection points; cosmetic msgbox one is optional
6. **Timeline**: Open-ended until discovery succeeds
7. **No tests**: Manual validation only in this cycle

## Next Steps

1. Launch FIFA 17 with career mode save loaded
2. Attach CE MCP Bridge
3. Run AOB scans for the 3 release patterns
4. Verify disassembly context
5. Build and test Auto Assembler script
6. Integrate into FIFA_17_Cheat_Table.CT
