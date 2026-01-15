-- Returns true if a player has obtained any amount of a particular item. If an amount is specfied, returns true if a player has obtained exactly that amount.
function has(item_id, amount)
    local count = Tracker:ProviderCountForCode(item_id)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count == amount
    end
end

------------------------
-- Level Access Rules --
------------------------

-- Tracker:FindObjectForCode("goal").CurrentStage - Need numeric mapping here for each of these

function SUMMIT()
    -- TODO
    return true
end
function SUMMITB()
    -- TODO
    return true
end
function SUMMITC()
    -- TODO
    return true
end

function EPILOGUE()
    -- TODO
    return BERRYREQ_IS_MET() -- and <goal level is completed>
end

function CORE()
    -- TODO - don't forget gates_vanilla and/or gates_disabled
    return true

end
function COREB()
    -- TODO - don't forget gates_vanilla and/or gates_disabled
    return true

end
function COREC()
    -- TODO - don't forget gates_vanilla and/or gates_disabled
    return true

end

function FAREWELL()
    -- TODO
    return true
end

---------------------------
-- Level Visibilty Rules --
---------------------------
function SUMMITB_IS_VISIBLE()
    -- TODO
    return true
end
function SUMMITC_IS_VISIBLE()
    -- TODO
    return true
end

function COREA_IS_VISIBLE()
    -- TODO
    return true
end
function COREB_IS_VISIBLE()
    -- TODO
    return true
end
function COREC_IS_VISIBLE()
    -- TODO
    return true
end

function FAREWELL_IS_VISIBLE()
    return FAREWELL_EMPTY_SPACE_IS_VISIBLE() or FAREWELL_FINALE_IS_VISIBLE()
end

function FAREWELL_EMPTY_SPACE_IS_VISIBLE()
    -- TODO
    return true
end

function FAREWELL_FINALE_IS_VISIBLE()
    -- TODO
    return true
end

----------------------------
-- Goal Requirement Rules --
----------------------------
function BERRYREQ_IS_MET()
    return checkRequirements("berries_required", "berries_obtained_total")
end
