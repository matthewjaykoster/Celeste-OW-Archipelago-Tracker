ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/tab_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)

    logDebug("onClear: called with slot data: ")
    logDebug(dumpTable(slot_data))
    -- Slot data reference can be found at: https://github.com/PoryGoneDev/Celeste-Archipelago-Open-World/blob/main/Source/ArchipelagoManager.cs

    SLOT_DATA = slot_data
    CUR_INDEX = -1

    -- reset locations
    for _, location_map in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_map) do
            if location then
                local obj = Tracker:FindObjectForCode(location)
                if obj then
                    logDebugVerbose(string.format('Resetting location %s', location))
                    logDebugVerbose(tostring(obj))
                    if location:sub(1, 1) == "@" then
                        obj.AvailableChestCount = obj.ChestCount
                    else
                        obj.Active = false
                    end
                end
            end
        end
    end

    logDebug("onClear: Locations reset successfully.")

    -- reset items
    for _, item_map in pairs(ITEM_MAPPING) do
        for _, item in pairs(item_map) do
            if item[1] and item[2] then
                local obj = Tracker:FindObjectForCode(item[1])
                if obj then
                    if item[2] == "toggle" then
                        obj.Active = false
                    elseif item[2] == "progressive" then
                        obj.CurrentStage = 0
                        obj.Active = false
                    elseif item[2] == "consumable" then
                        obj.AcquiredCount = 0
                    else
                        logDebugVerbose(string.format("onClear: unknown item type %s for code %s", item[2], item[1]))
                    end
                else
                    logDebugVerbose(string.format("onClear: could not find object for code %s", item[1]))
                end
            end
        end
    end

    logDebug("onClear: Items reset successfully.")

    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0

    logDebug("onClear: Player ID and Team Number reset successfully.")

    -- Settings: Game Options
    if slot_data["death_link"] ~= nil and slot_data["death_link"] ~= 0 and slot_data["death_link_amnesty"] ~= nil then
        Tracker:FindObjectForCode("death_link").AcquiredCount = tonumber(slot_data["death_link_amnesty"])
    else
        Tracker:FindObjectForCode("death_link").AcquiredCount = 0
    end
    if slot_data["trap_link"] ~= nil then
        Tracker:FindObjectForCode("trap_link").Active = tonumber(slot_data["trap_link"])
    end

    -- Settings: Goal Options
    if slot_data["strawberries_required"] ~= nil then
        Tracker:FindObjectForCode("berries_required").AcquiredCount = tonumber(slot_data["strawberries_required"])
    end
    if slot_data["lock_goal_area"] ~= nil then
        Tracker:FindObjectForCode("lock_goal_area").Active = tonumber(slot_data["lock_goal_area"])
    end
    if slot_data["goal_area_checkpointsanity"] ~= nil then
        Tracker:FindObjectForCode("goal_area_checkpointsanity").Active = tonumber(
            slot_data["goal_area_checkpointsanity"])
    end
    if slot_data["goal_area"] then
        Tracker:FindObjectForCode("goal").CurrentStage = _mapSlotGoalAreaCodeToGoalObjectIndex(slot_data["goal_area"])
    end

    -- Settings: Location Options/-sanities
    if slot_data["binosanity"] ~= nil then
        Tracker:FindObjectForCode("binosanity").Active = tonumber(slot_data["binosanity"])
    end
    if slot_data["carsanity"] ~= nil then
        Tracker:FindObjectForCode("carsanity").Active = tonumber(slot_data["carsanity"])
    end
    if slot_data["checkpointsanity"] ~= nil then
        Tracker:FindObjectForCode("checkpointsanity").Active = tonumber(slot_data["checkpointsanity"])
    end
    if slot_data["gemsanity"] ~= nil then
        Tracker:FindObjectForCode("gemsanity").Active = tonumber(slot_data["gemsanity"])
    end
    if slot_data["keysanity"] ~= nil then
        Tracker:FindObjectForCode("keysanity").Active = tonumber(slot_data["keysanity"])
    end
    if slot_data["roomsanity"] ~= nil then
        Tracker:FindObjectForCode("roomsanity").Active = tonumber(slot_data["roomsanity"])
    end

    -- Settings: Location Options/checks
    if slot_data["include_goldens"] ~= nil then
        Tracker:FindObjectForCode("include_goldens").Active = tonumber(slot_data["include_goldens"])
    end
    if slot_data["include_core"] ~= nil then
        Tracker:FindObjectForCode("include_core").Active = tonumber(slot_data["include_core"])
    end
    if slot_data["include_farewell"] ~= nil then
        -- 0 == "None", 1 == "Empty Space", 2 == "Farewell"
        Tracker:FindObjectForCode("include_farewell").CurrentStage = tonumber(slot_data["include_farewell"])
    end
    if slot_data["include_b_sides"] ~= nil then
        Tracker:FindObjectForCode("include_b_sides").Active = tonumber(slot_data["include_b_sides"])
    end
    if slot_data["include_c_sides"] ~= nil then
        Tracker:FindObjectForCode("include_c_sides").Active = tonumber(slot_data["include_c_sides"])
    end

    logDebug("onClear: Settings and goals reset completed.")
end

function onItem(index, item_id, item_name, player_number)
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber

    logDebug(string.format("onItem called for local player: index %s, item_id %s, item_name %s", index, item_id,
        item_name))

    CUR_INDEX = index;
    local item_map = ITEM_MAPPING[item_id]
    for _, item in pairs(item_map) do
        if not item then
            logDebugArchipelago(string.format("onItem: could not find item mapping for id %s", item_id))
            return
        end
        if not item[1] then
            logDebugArchipelago(string.format("onItem: item entry found with missing first table entry for id %s",
                item_id))
            return
        end
        local obj = Tracker:FindObjectForCode(item[1])
        if obj then
            if item[2] == "toggle" then
                obj.Active = true
            elseif item[2] == "progressive" then
                if obj.Active then
                    obj.CurrentStage = obj.CurrentStage + 1
                else
                    obj.Active = true
                end
            elseif item[2] == "consumable" then
                obj.AcquiredCount = obj.AcquiredCount + obj.Increment
            else
                logDebugArchipelago(string.format("onItem: unknown item type %s for code %s", item[2], item[1]))
            end
        else
            logDebugArchipelago(string.format("onItem: could not find object for code %s", item[1]))
        end
        if is_local then
            if LOCAL_ITEMS[item[1]] then
                LOCAL_ITEMS[item[1]] = LOCAL_ITEMS[item[1]] + 1
            else
                LOCAL_ITEMS[item[1]] = 1
            end
        else
            if GLOBAL_ITEMS[item[1]] then
                GLOBAL_ITEMS[item[1]] = GLOBAL_ITEMS[item[1]] + 1
            else
                GLOBAL_ITEMS[item[1]] = 1
            end
        end
    end
end

function onLocation(location_id, location_name)
    logDebug(string.format("onLocation called: location_id %s, location_name %s", location_id, location_name))

    local location_mapping = LOCATION_MAPPING[location_id]
    if not location_mapping or not location_mapping[1] then
        logDebug(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_mapping) do
        local obj = Tracker:FindObjectForCode(location)
        if obj then
            if location:sub(1, 1) == "@" then
                obj.AvailableChestCount = obj.AvailableChestCount - 1
            else
                obj.Active = true
            end
        else
            logDebug(string.format("onLocation: could not find object for code %s", location))
        end
    end
end

function onNotify(key, value, old_value)
    logDebug(string.format("onNotify called: key %s, value %s, old_value %s", key, value, old_value))
end

function onNotifyLaunch(key, value)
    logDebug(string.format("onNotifyLaunch called: key %s, value %s", key, value))
end

function updateHints(locationID)
    logDebugArchipelago(string.format("called updateHints: %s", locationID))
end

function updateHintsClear(locationID)
    logDebugArchipelago(string.format("called updateHintsClear: %s", locationID))
end

function onScout(location_id, location_name, item_id, item_name, item_player)
    logDebugArchipelago(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id,
        item_name, item_player))
end

function onBounce(json)
    logDebugArchipelago(string.format("called onBounce: %s", dumpTable(json)))
end

function updateTabs(raw_celeste_play_state)
    logDebug(string.format("updateTabs called with raw celeste play state: %s", raw_celeste_play_state))

    -- if raw_celeste_play_state ~= nil then

    --     local is_overworld, level, side, room = _parseRawCelestePlayState(raw_celeste_play_state)

    --     logDebug(string.format("Parsed celeste play state - IsOverworld: %d, Level: %d, Side: %d, Room: %s",
    --         is_overworld, level, side, room))

    --     local tabswitch = Tracker:FindObjectForCode("tab_switch")
    --     Tracker:FindObjectForCode("cur_level_id").CurrentStage = level

    --     if tabswitch.Active then
    --         if celeste_play_state ~= lastRoomID then
    --             local key = string.format("%d;%d;%d;%s", is_overworld, level, side, room)
    --             if TAB_MAPPING[key] then
    --                 local roomTabs = {}
    --                 for str in string.gmatch(TAB_MAPPING[key], "([^/]+)") do
    --                     table.insert(roomTabs, str)
    --                 end
    --                 if #roomTabs > 0 then
    --                     for _, tab in ipairs(roomTabs) do
    --                         logDebug(string.format("Updating ID %s to Tab %s", key, tab))
    --                         Tracker:UiHint("ActivateTab", tab)
    --                     end
    --                     lastRoomID = celeste_play_state
    --                 else
    --                     logDebug(string.format("Failed to find tabs for ID %s", key))
    --                 end
    --             else
    --                 logDebug(string.format("Failed to find Tab ID %s", key))
    --             end
    --         end
    --     end
    -- end
end

--- Maps a level code (e.g. 10c) to its name code (e.g. farewell_golden).
---@param level_code string
function _mapSlotGoalAreaCodeToGoalObjectIndex(level_code)
    if level_code == "7a" then
        return 0
        -- return "the_summit_a"
    elseif level_code == "7b" then
        return 1
        -- return "the_summit_b"
    elseif level_code == "7c" then
        return 2
        -- return "the_summit_c"
    elseif level_code == "9a" then
        return 3
        -- return "core_a"
    elseif level_code == "9b" then
        return 4
        -- return "core_b"
    elseif level_code == "9c" then
        return 5
        -- return "core_c"
    elseif level_code == "10a" then
        return 6
        -- return "empty_space"
    elseif level_code == "10b" then
        return 7
        -- return "farewell"
    elseif level_code == "10c" then
        return 8
        -- return "farewell_golden"
    else
        logDebug(string.format(
            'Error: Found invalid Goal Area level code (%s) when mapping to name code. Defaulting to Summit A'),
            level_code);
        return 0
        -- return "the_summit_a"
    end
end

--- Parse a raw celeste play state string into usable variables.
---@param raw_celeste_play_state string
function _parseRawCelestePlayState(raw_celeste_play_state)
    local is_overworld, level, side, room = string.format(raw_celeste_play_state:match("^(%d);(%d+);(%d+);(.+)$"))
    is_overworld = tonumber(is_overworld)
    level = tonumber(level)
    side = tonumber(side)
    return is_overworld, level, side, room
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)
