-- Youth Academy AOB Signature Registry for FIFA 17
-- Maps feature keys to byte patterns found in FIFA17.exe
-- Status: Phase 1 discovery in progress
-- Patterns marked PENDING need runtime verification
-- Patterns marked VERIFIED have been confirmed in FIFA 17

local aobs = {
    AOB_MoreYouthPlayers       = '89 06 FF C7 48 83 C6 04 83 FF 02',
    AOB_RevealPotAndOvr        = '89 07 FF C3 48 83 C7 04 83 FB 06',
    AOB_PrimAttr               = '43 89 44 F7 30',
    AOB_SecAttr                = '43 89 44 F7 68',
    AOB_MinAgeForPromotion     = '41 B8 03 00 00 00 89 85 E4',
    AOB_PlayerAgeRange         = '41 B8 04 00 00 00 41 89 07',
    AOB_YouthPlayersRetirement = '41 FF C4 89 03',
    AOB_PlayerPotential        = '89 06 48 8D 76 04 83 FF 02 ?? ?? 4C 8B 7C 24 48',
    AOB_WeakFootChance         = 'FF C3 89 07 48 8D 7F 04 83 FB 06',
    AOB_AllCountriesAvailable  = '89 4C 24 30 B9 04 00 00 00',
    AOB_SkillMoveChance        = '89 B5 7C 01 00 00 4C',
    AOB_CountryIsBeingScouted  = '80 FB 01 75 0C 4C',
    AOB_NoPlayerRegens         = '41 BF 10 00 00 00 48 8B CE',
}

local aob_status = {
    AOB_MoreYouthPlayers       = 'CANDIDATE: 2 matches found in FIFA 17 — need runtime verification to select correct one',
    AOB_RevealPotAndOvr        = 'PENDING: No exact match; 3 partial matches for shortened pattern',
    AOB_PrimAttr               = 'PENDING: No exact match; single 64-bit variant found (wrong op size)',
    AOB_SecAttr                = 'PENDING: No exact match; single match in garbage data section',
    AOB_MinAgeForPromotion     = 'PENDING: No match found; needs runtime analysis',
    AOB_PlayerAgeRange         = 'PENDING: No match found; needs runtime analysis',
    AOB_YouthPlayersRetirement = 'PENDING: No match found; needs runtime analysis',
    AOB_PlayerPotential        = 'PENDING: No match found; needs runtime analysis',
    AOB_WeakFootChance         = 'PENDING: No match found; needs runtime analysis',
    AOB_AllCountriesAvailable  = 'PENDING: No match found; needs runtime analysis',
    AOB_SkillMoveChance        = 'CANDIDATE: 2 shortened matches for mov [rbp+17C],esi',
    AOB_CountryIsBeingScouted  = 'PENDING: No exact match; 35 partial matches for cmp bl,01; jne',
    AOB_NoPlayerRegens         = 'PENDING: No match found; needs runtime analysis',
}

local _cached = {}
local _originalBytes = {}

local function scan_unique(pattern)
    local results = AOBScan(pattern)
    if results == nil then
        return nil
    end
    local count = results.getCount()
    local addr = nil
    if count == 1 then
        addr = results.getAddress(0)
    end
    results.destroy()
    return addr, count
end

function get_validated_address(key)
    if _cached[key] then
        return _cached[key]
    end

    local pattern = aobs[key]
    if not pattern then
        error('Unknown AOB key: ' .. tostring(key))
    end

    local addr, count = scan_unique(pattern)

    if addr == nil then
        if count == nil then
            error('AOB not found for key: ' .. key .. ' (pattern: ' .. pattern .. ')')
        else
            error('AOB found ' .. tostring(count) .. ' matches for key: ' .. key .. ' (expected 1)')
        end
    end

    _cached[key] = addr
    return addr
end

function save_original_bytes(key, address, byteCount)
    _originalBytes[key] = readBytes(address, byteCount, true)
end

function restore_original_bytes(key, address)
    local bytes = _originalBytes[key]
    if bytes then
        writeBytes(address, unpack(bytes))
        _originalBytes[key] = nil
    end
end

function get_aob_keys()
    local keys = {}
    for k, _ in pairs(aobs) do
        keys[#keys + 1] = k
    end
    return keys
end

function get_aob_pattern(key)
    return aobs[key]
end

function set_aob_pattern(key, pattern)
    aobs[key] = pattern
    _cached[key] = nil
end