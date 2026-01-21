ENABLE_DEBUG_LOG = true
ENABLE_DEBUG_LOG_VERBOSE = true

-- Functions
ScriptHost:LoadScript("scripts/utils.lua")
ScriptHost:LoadScript("scripts/logic.lua")

-- JSON Loads
ScriptHost:LoadScript("scripts/items.lua")
ScriptHost:LoadScript("scripts/locations.lua")
ScriptHost:LoadScript("scripts/layouts.lua")
Tracker:AddMaps("maps/maps.json")

-- Autotracking
ScriptHost:LoadScript("scripts/autotracking.lua")
