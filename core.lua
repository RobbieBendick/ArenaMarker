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
    ["ROGUE"] = "star",
    ["DRUID"] = "circle",
    ["WARLOCK"] = "diamond",
    ["PALADIN"] = "diamond",
    ["HUNTER"] = "triangle",
    ["MAGE"] = "moon",
    ["SHAMAN"] = "square",
    ["WARRIOR"] = "cross",
    ["PRIEST"] = "skull"
}

local function removeValue(table, value)
    local key = table[value]
    table[value] = nil
    return key
end


local function findUsableMark(table, target)
    local marker = ""
    for k,v in pairs(table) do
        if v ~= nil then
            marker = k
            break
        end
    end
    SetRaidTarget(target, table[marker])
    removeValue(table, marker)
end


local function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    for k,v in pairs(relatives) do
        if k == englishClass then
            if unused_markers[v] then
                SetRaidTarget(target, unused_markers[v])
                removeValue(unused_markers, v)
                break
            else
                findUsableMark(unused_markers, target)
                break
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
