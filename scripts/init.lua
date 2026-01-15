ENABLE_DEBUG_LOG = true
ENABLE_DEBUG_LOG_VERBOSE = true

ScriptHost:LoadScript("scripts/utils.lua")
ScriptHost:LoadScript("scripts/items.lua")
ScriptHost:LoadScript("scripts/locations.lua")
ScriptHost:LoadScript("scripts/layouts.lua")
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/autotracking.lua")

Tracker:AddMaps("maps/maps.json")
