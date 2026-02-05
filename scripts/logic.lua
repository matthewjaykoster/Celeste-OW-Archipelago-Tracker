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
--   Settings Rules   --
------------------------
function KEYSANITY_IS_DISABLED()
    if not has("keysanity") then
        return true
    end

    return false
end

------------------------
-- Level Access Rules --
------------------------

-- Tracker:FindObjectForCode("goal").CurrentStage - Need numeric mapping here for each of these

function CORE_A_ACCESS()
    if not IS_GOAL("core_a") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end
function CORE_B_ACCESS()
    if not IS_GOAL("core_b") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end
function CORE_C_ACCESS()
    if not IS_GOAL("core_c") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end

function EPILOGUE_ACCESS()
    -- TODO
    return BERRYREQ_IS_MET() -- and <goal level is completed>
end

function FAREWELL_ACCESS()
    -- TODO
    return true
end

function SUMMIT_A_ACCESS()
    if not IS_GOAL("the_summit_a") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end
function SUMMIT_B_ACCESS()
    if not IS_GOAL("the_summit_b") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end
function SUMMIT_C_ACCESS()
    if not IS_GOAL("the_summit_c") then
        return true
    end

    if not has("lock_goal_area") then
        return true
    end

    return BERRYREQ_IS_MET()
end

---------------------------
-- Level Visibilty Rules --
---------------------------
function CORE_A_IS_VISIBLE()
    return IS_GOAL("core_a") or has("include_core")
end
function CORE_B_IS_VISIBLE()
    return IS_GOAL("core_b") or (has("include_core") and has("include_b_sides"))
end
function CORE_C_IS_VISIBLE()
    return IS_GOAL("core_c") or (has("include_core") and has("include_c_sides"))
end

function FAREWELL_EMPTY_SPACE_IS_VISIBLE()
    return IS_GOAL("empty_space") or has("include_farewell_empty_space")
end

function FAREWELL_FINALE_IS_VISIBLE()
    return IS_GOAL("farewell") or IS_GOAL("farewell_golden") or has("include_farewell_farewell")
end

function FAREWELL_IS_VISIBLE()
    return FAREWELL_EMPTY_SPACE_IS_VISIBLE() or FAREWELL_FINALE_IS_VISIBLE()
end

function SUMMIT_B_IS_VISIBLE()
    return has("include_b_sides") or has("the_summit_b")
end
function SUMMIT_C_IS_VISIBLE()
    return has("include_c_sides") or has("the_summit_c")
end

----------------------------
-- Goal Requirement Rules --
----------------------------
function IS_GOAL(level_name)
    -- Enumerated Options from Slot Data.
    --  the_summit_a, the_summit_b, the_summit_c, core_a, core_b, core_c, empty_space, farewell, farewell_golden

    -- The player should only ever have one of the above options. Could load from SLOT_DATA if AP Autotracking - but
    -- we won't have that during manual operation, so we have to go to the Tracker rather than SLOT_DATA, even though
    -- that technically just makes this another "has" function.
    return has(level_name)
end

function BERRYREQ_IS_MET()
    return checkAmountMetOrExceeds("berries_required", "berries_obtained_total")
end
