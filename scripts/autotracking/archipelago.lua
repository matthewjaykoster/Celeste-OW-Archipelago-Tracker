ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/tab_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)

    log_debug("onClear: called with slot data: ")
    log_debug(dump_table(slot_data))
    -- Slot data reference can be found at: https://github.com/PoryGoneDev/Celeste-Archipelago-Open-World/blob/main/Source/ArchipelagoManager.cs

    SLOT_DATA = slot_data
    CUR_INDEX = -1

    -- reset locations
    for _, location_map in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_map) do
            if location then
                local obj = Tracker:FindObjectForCode(location)
                if obj then
                    log_debug_verbose(string.format('Resetting location %s', location))
                    log_debug_verbose(tostring(obj))
                    if location:sub(1, 1) == "@" then
                        obj.AvailableChestCount = obj.ChestCount
                    else
                        obj.Active = false
                    end
                end
            end
        end
    end

    log_debug("onClear: Locations reset successfully.")

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
                        log_debug_archipelago(string.format("onClear: unknown item type %s for code %s", item[2],
                            item[1]))
                    end
                else
                    log_debug_archipelago(string.format("onClear: could not find object for code %s", item[1]))
                end
            end
        end
    end

    log_debug("onClear: Items reset successfully.")

    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0

    log_debug("onClear: Player ID and Team Number reset successfully.")

    -- TODO add in other slot options tracking (sanities, etc)
    if slot_data["strawberries_required"] ~= nil then
        Tracker:FindObjectForCode("berries_required").AcquiredCount = tonumber(slot_data["strawberries_required"])
    end
    if slot_data["goal_level"] then
        Tracker:FindObjectForCode("goal").CurrentStage = slot_data["goal_level"]
    end

    log_debug("onClear: Goal tracking properties reset successfully.")

    if Archipelago.PlayerNumber > -1 then
        HINTS_ID = "_read_hints_" .. TEAM_NUMBER .. "_" .. PLAYER_ID

        log_debug(string.format("onClear: Setting hint notifications using Hint ID - %s.", HINTS_ID))
        log_debug(string.format("hints table dump: %s", dump_table(HINTS_ID)))

        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
        log_debug("onClear: Set hint notifications successfully.")
    end
end

function onItem(index, item_id, item_name, player_number)
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber

    log_debug(string.format("onItem called for local player: index %s, item_id %s, item_name %s", index, item_id,
        item_name))

    CUR_INDEX = index;
    local item_map = ITEM_MAPPING[item_id]
    for _, item in pairs(item_map) do
        if not item then
            log_debug_archipelago(string.format("onItem: could not find item mapping for id %s", item_id))
            return
        end
        if not item[1] then
            log_debug_archipelago(string.format("onItem: item entry found with missing first table entry for id %s",
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
                log_debug_archipelago(string.format("onItem: unknown item type %s for code %s", item[2], item[1]))
            end
        else
            log_debug_archipelago(string.format("onItem: could not find object for code %s", item[1]))
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
    log_debug(string.format("onLocation called: location_id %s, location_name %s", location_id, location_name))

    local location_mapping = LOCATION_MAPPING[location_id]
    if not location_mapping or not location_mapping[1] then
        log_debug(string.format("onLocation: could not find location mapping for id %s", location_id))
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
            log_debug(string.format("onLocation: could not find object for code %s", location))
        end
    end
end

function onNotify(key, value, old_value)
    log_debug(string.format("onNotify called: key %s, value %s, old_value %s", key, value, old_value))

    if value ~= old_value and key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if not hint.found then
                    updateHints(hint.location)
                else
                    if hint.found then
                        updateHintsClear(hint.location)
                    end
                end
            end
        end
    end
end

function onNotifyLaunch(key, value)
    log_debug(string.format("onNotifyLaunch called: key %s, value %s", key, value))

    if key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if not hint.found then
                    updateHints(hint.location)
                elseif hint.found then
                    updateHintsClear(hint.location)
                end
            end
        end
    end
end

function updateHints(locationID)
    log_debug_archipelago(string.format("called updateHints: %s", locationID))
end

function updateHintsClear(locationID)
    log_debug_archipelago(string.format("called updateHintsClear: %s", locationID))
end

function onScout(location_id, location_name, item_id, item_name, item_player)
    log_debug_archipelago(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id,
        item_name, item_player))
end

function onBounce(json)
    log_debug_archipelago(string.format("called onBounce: %s", dump_table(json)))
end

function updateTabs(raw_celeste_play_state)
    if raw_celeste_play_state ~= nil then

        log_debug(string.format("updateTabs called with raw celeste play state: %s", raw_celeste_play_state))

        local is_overworld, level, side, room = _parseRawCelestePlayState(raw_celeste_play_state)

        log_debug(string.format("Parsed celeste play state - IsOverworld: %d, Level: %d, Side: %d, Room: %s",
            is_overworld, level, side, room))

        local tabswitch = Tracker:FindObjectForCode("tab_switch")
        Tracker:FindObjectForCode("cur_level_id").CurrentStage = level

        if tabswitch.Active then
            if celeste_play_state ~= lastRoomID then
                local key = string.format("%d;%d;%d;%s", is_overworld, level, side, room)
                if TAB_MAPPING[key] then
                    local roomTabs = {}
                    for str in string.gmatch(TAB_MAPPING[key], "([^/]+)") do
                        table.insert(roomTabs, str)
                    end
                    if #roomTabs > 0 then
                        for _, tab in ipairs(roomTabs) do
                            log_debug(string.format("Updating ID %s to Tab %s", key, tab))
                            Tracker:UiHint("ActivateTab", tab)
                        end
                        lastRoomID = celeste_play_state
                    else
                        log_debug(string.format("Failed to find tabs for ID %s", key))
                    end
                else
                    log_debug(string.format("Failed to find Tab ID %s", key))
                end
            end
        end
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
