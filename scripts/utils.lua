-- Writes a message to console if debug logging is enabled.
function log_debug(message)
    if ENABLE_DEBUG_LOG then
        print(message)
    end
end

-- Writes a message to console if archipelago debug logging is enabled.
function log_debug_archipelago(message)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(message)
    end
end

-- Writes a message to console if verbose debug logging is enabled.
function log_debug_verbose(message)
    if ENABLE_DEBUG_LOG_VERBOSE then
        print(message)
    end
end

-- from https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- dumps a table in a readable string
function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function checkRequirements(required_count_reference, obtained_count_reference)
    local required_count = Tracker:ProviderCountForCode(required_count_reference)
    local obtained_count = Tracker:ProviderCountForCode(obtained_count_reference)

    if obtained_count >= required_count then
        return 1
    else
        return 0
    end
end

function HEART(hearts_obtained_total, count)
    if Tracker:FindObjectForCode(hearts_obtained_total).AcquiredCount >= tonumber(count) then
        return true
    else
        return false
    end
end

function GATESWITCH()
    if Tracker:FindObjectForCode("gateshidden").CurrentStage == 1 then
        log_debug("Switching gates to to hidden.")
        Tracker:FindObjectForCode("gates").CurrentStage = 0
    elseif Tracker:FindObjectForCode("gateshidden").CurrentStage == 0 then
        log_debug("Switching gates to to visible.")
        Tracker:FindObjectForCode("gates").CurrentStage = 1
    end
end

ScriptHost:AddWatchForCode("gates handler", "gateshidden", GATESWITCH)
