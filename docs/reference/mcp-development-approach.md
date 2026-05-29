# MCP Bridge Development Approach

How to use the Cheat Engine MCP Bridge for agentic FIFA 17 cheat table development.

## Overview

The CE MCP Bridge exposes Cheat Engine's full API over a JSON-RPC interface. This means an AI agent can:
- Attach to running processes
- Scan and read/write memory
- Disassemble code
- Set breakpoints
- Execute Lua and Auto Assembler scripts
- All without manual CE interaction

## Prerequisites

1. Cheat Engine installed with the MCP Bridge plugin active
2. FIFA 17 running and attached in CE (or attachable)
3. Career mode save loaded in-game
4. The bridge returns `{"success": true}` from `ping`

## Key MCP Tools for Development

### Process Management
| Tool | Purpose |
|------|---------|
| `open_process` | Attach to FIFA17.exe by name or PID |
| `get_process_info` | Get PID, architecture, module count |
| `get_process_list` | Find FIFA17.exe PID |

### Memory Scanning
| Tool | Purpose |
|------|---------|
| `aob_scan` | Search for byte patterns (our primary tool) |
| `aob_scan_module` | Search within a specific module (e.g., FIFA17.exe) |
| `aob_scan_unique` | Search for a pattern that should match exactly once |
| `scan_all` | Generic memory scan for values |
| `search_string` | Search for text strings in memory |

### Memory Reading/Writing
| Tool | Purpose |
|------|---------|
| `read_memory` | Read raw bytes at address |
| `read_integer` | Read typed value (byte/word/dword/qword/float/double) |
| `read_string` | Read string with encoding choice |
| `read_pointer` | Follow pointer chain to final value |
| `write_integer` | Write typed value to memory |
| `write_memory` | Write raw bytes |
| `write_string` | Write string to memory |

### Code Analysis
| Tool | Purpose |
|------|---------|
| `disassemble` | Disassemble instructions at address |
| `get_instruction_info` | Get details about a specific instruction |
| `find_function_boundaries` | Find start/end of function containing address |
| `analyze_function` | Find all CALL instructions in a function |
| `find_references` | Find all code that references an address |
| `find_call_references` | Find all locations that CALL a function |

### Code Assembly & Injection
| Tool | Purpose |
|------|---------|
| `auto_assemble` | Execute an Auto Assembler script (code injection) |
| `auto_assemble_check` | Validate AA script syntax without executing |
| `assemble_instruction` | Assemble a single instruction to bytes |
| `compile_c_code` | Compile C source and get symbols |
| `allocate_memory` | Allocate memory in target process |
| `free_memory` | Free allocated memory |

### Symbol Management
| Tool | Purpose |
|------|---------|
| `get_symbol_address` | Resolve symbol name to address |
| `get_address_info` | Get module/symbol info for an address |
| `register_symbol` | Register a user-defined symbol for AA scripts |
| `enum_modules` | List all loaded modules with base addresses |

### Breakpoints & Debugging
| Tool | Purpose |
|------|---------|
| `set_breakpoint` | Set hardware execution breakpoint (logging) |
| `set_data_breakpoint` | Set hardware data watchpoint (read/write) |
| `get_breakpoint_hits` | Get captured breakpoint data |
| `clear_all_breakpoints` | Remove all breakpoints |
| `dbvm watch` | Invisible hypervisor-level watch |

### Lua Execution
| Tool | Purpose |
|------|---------|
| `evaluate_lua` | Execute arbitrary Lua code in CE |
| `create_thread` | Run Lua code in a separate thread |

## Development Workflow

### Phase 1: Discovery (AOB Scanning)

```python
# Pseudocode for finding injection points

# 1. Attach to FIFA 17
open_process("FIFA17.exe")

# 2. Try each AOB pattern from FIFA 19
aob_scan("39 46 54 40 0F 9C C7")  # Injection 1
aob_scan("4C 8B E0 85 FF 0F")     # Injection 2
aob_scan("8B D8 48 8B 45 77")     # Injection 3

# 3. For each match, verify context
disassemble(address, count=10)      # Check surrounding code matches expected logic
```

### Phase 2: Validation

```python
# 1. Construct AA script for discovered injection point
script = """
[ENABLE]
aobscanmodule(INJECT_FreeRelease, FIFA17.exe, 39 46 54 40 0F 9C C7)
alloc(newmem, $1000, INJECT_FreeRelease)
...
[DISABLE]
...
"""

# 2. Validate syntax
auto_assemble_check(script)

# 3. Test injection
auto_assemble(script)

# 4. Verify in-game: release a player, check no limit/cost
```

### Phase 3: Integration

```python
# Write validated script into FIFA_17_Cheat_Table.CT
# Follow the existing XML structure:
# <CheatEntry>
#   <ID>next_available</ID>
#   <Description>"Free & Unlimited Releasing Players"</Description>
#   <VariableType>Auto Assembler Script</VariableType>
#   <AssemblerScript>...</AssemblerScript>
# </CheatEntry>
```

## Discovery Fallback: Reverse Engineering

If AOB patterns don't match:

### Step 1: String Search
```python
search_string("releasetoomanyplayers")  # Search for function name
search_string("release")                # Broader search
```

### Step 2: Disassembly Analysis
For any hits found:
```python
disassemble(address, count=20)          # Disassemble around the hit
find_function_boundaries(address)       # Find function start/end
analyze_function(function_start)        # Find all calls within function
```

### Step 3: Dynamic Analysis
If static analysis fails:
```python
# Set breakpoint on a known data field
set_data_breakpoint(known_player_address, access_type='w')

# Trigger release in-game
# Check breakpoint hits to trace execution:
get_breakpoint_hits()

# Disassemble at hit addresses to find release logic
```

## CT File Structure Reference

The FIFA 17 CT file uses these XML patterns:

### Auto Assembler Script Entry
```xml
<CheatEntry>
  <ID>UNIQUE_ID</ID>
  <Description>"Script Name"</Description>
  <VariableType>Auto Assembler Script</VariableType>
  <AssemblerScript>
[ENABLE]
// injection code
[DISABLE]
// disable code
{
// ORIGINAL CODE comments
}
  </AssemblerScript>
</CheatEntry>
```

### Group Header Entry
```xml
<CheatEntry>
  <ID>UNIQUE_ID</ID>
  <Description>"Group Name"</Description>
  <Options moHideChildren="1"/>
  <GroupHeader>1</GroupHeader>
  <CheatEntries>
    <!-- child entries -->
  </CheatEntries>
</CheatEntry>
```

### Memory Record Entry
```xml
<CheatEntry>
  <ID>UNIQUE_ID</ID>
  <Description>"Value Name"</Description>
  <VariableType>4 Bytes</VariableType>
  <Address>symbol_or_pointer</Address>
  <Offsets>
    <Offset>value</Offset>
  </Offsets>
</CheatEntry>
```

## Caveats & Notes

1. **Process must be attached**: Most tools require `open_process()` first. `ping` is the exception.
2. **AOB scanning is CPU-intensive**: Pattern scanning on a large process like FIFA 17 takes seconds.
3. **Breakpoints degrade performance**: Hardware breakpoints are limited (4 total). Logging breakpoints impact game speed.
4. **AA scripts persist**: An injected script stays active until disabled or the process exits. Clean up with `[DISABLE]` sections.
5. **Module names**: FIFA 17's main executable is `FIFA17.exe`. Offsets reference module base + offset.
6. **Wildcards in AOB**: Use `??` for single-byte wildcards. Patterns can span any length.
7. **Memory protection**: Injected code needs execute permission. Use `alloc()` with default `rwx` or explicit protection.
