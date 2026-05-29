-- Youth Academy helper functions for FIFA 17.
-- Feature slices add AOBs only after their FIFA 17 patterns are confirmed.

YouthAcademyHelpers = YouthAcademyHelpers or {}

local aobs = YouthAcademyHelpers.aobs or {}
local cachedAddresses = YouthAcademyHelpers.cachedAddresses or {}
local originalBytes = YouthAcademyHelpers.originalBytes or {}

YouthAcademyHelpers.aobs = aobs
YouthAcademyHelpers.cachedAddresses = cachedAddresses
YouthAcademyHelpers.originalBytes = originalBytes
YouthAcademyHelpers.loaded = true

local function get_scan_result_address(results, index)
  if results.getAddress then
    return results.getAddress(index)
  end
  if results.getString then
    return results.getString(index)
  end
  return results[index]
end

local function scan_unique(pattern)
  local results = AOBScan(pattern)
  if results == nil then
    return nil, nil
  end

  local count = results.getCount()
  local address = nil
  if count == 1 then
    address = get_scan_result_address(results, 0)
  end

  results.destroy()
  return address, count
end

function register_youth_aob(key, pattern)
  if key == nil or key == '' then
    error('Youth Academy AOB key is required')
  end
  if pattern == nil or pattern == '' then
    error('Youth Academy AOB pattern is required for key: ' .. tostring(key))
  end

  aobs[key] = pattern
  cachedAddresses[key] = nil
end

register_youth_aob(
  'AOB_MinAgeForPromotionIniLookup',
  '49 8B 41 18 48 8B 04 C8 48 85 C0 74 0E'
)

function get_validated_address(key)
  if cachedAddresses[key] then
    return cachedAddresses[key]
  end

  local pattern = aobs[key]
  if pattern == nil then
    error('Unknown Youth Academy AOB key: ' .. tostring(key))
  end

  local address, count = scan_unique(pattern)
  if address == nil then
    if count == nil then
      error('AOB not found for Youth Academy key: ' .. tostring(key))
    end
    error('AOB found ' .. tostring(count) .. ' matches for Youth Academy key: ' .. tostring(key) .. ' (expected 1)')
  end

  cachedAddresses[key] = address
  return address
end

function save_original_bytes(key, address, byteCount)
  originalBytes[key] = readBytes(address, byteCount, true)
end

function restore_original_bytes(key, address)
  local bytes = originalBytes[key]
  if bytes then
    writeBytes(address, unpack(bytes))
    originalBytes[key] = nil
  end
end

function get_youth_aob_keys()
  local keys = {}
  for key, _ in pairs(aobs) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

function get_youth_aob_pattern(key)
  return aobs[key]
end