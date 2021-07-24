local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

--[[
    Marker numbers:
        1 = Yellow 4-point Star; Rogue
        2 = Orange Circle; Druid
        3 = Purple Diamond; Lock, Paladin
        4 = Green Triangle; Hunter
        5 = White Crescent Moon; Mage
        6 = Blue Square; Shaman
        7 = Red "X" Cross; Warrior
        8 = White Skull; Priest
--]]


local unused_markers = {
    ["star"] = 1,
    ["circle"] = 2,
    ["diamond"] = 3,
    ["triangle"] = 4,
    ["moon"] = 5,
    ["square"] = 6,
    ["cross"] = 7,
    ["skull"] = 8
}

local relatives = {
    ["star"] = "ROGUE",
    ["circle"] = "DRUID",
    ["diamond"] = "WARLOCK",
    ["diamond"] = "PALADIN",
    ["triangle"] = "HUNTER",
    ["moon"] = "MAGE",
    ["square"] = "SHAMAN",
    ["cross"] = "WARRIOR",
    ["skull"] = "PRIEST"
}

local function removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end


local function findUsableMark(table, target)
    local marker = ""
    for i,v in pairs(table) do
        if v ~= nil then
            marker = i
            break
        end
    end
    SetRaidTarget(target, table[marker])
    removeKey(table, marker)
end


local function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    for i,v in pairs(relatives) do
        if v == englishClass then
            if unused_markers[i] then
                SetRaidTarget(target, unused_markers[i])
                removeKey(unused_markers, i)
            else
                findUsableMark(unused_markers, target)
            end
        end
    end 
end

local function markTeammatesAndSelf(self, event, ...)
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        if string.find(arg1, "One minute until the Arena battle begins!") or string.find(arg1, "Thirty seconds until the Arena battle begins!") or string.find(arg1, "Fifteen seconds until the Arena battle begins!") or string.find(arg1, "The Arena battle has begun!") then
            local members = GetNumGroupMembers()
            if members > 1 then
                if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
                    ConvertToRaid()
                    -- mark self
                    if not GetRaidTargetIndex("player") then
                        print("[ArenaMarker]: Marking the group.")
                        setRaidTargetByClass("player")
                    end
                    -- mark party members
                    for i=1, members-1 do
                        if not GetRaidTargetIndex("party"..i) then
                            setRaidTargetByClass("party"..i)
                        end
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", markTeammatesAndSelf)
