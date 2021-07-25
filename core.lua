local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

--[[
    Marker numbers:
        2 = Yellow 4-point Star; Rogue
        3 = Orange Circle; Druid
        4 = Purple Diamond; Lock, Paladin
        5 = Green Triangle; Hunter
        6 = White Crescent Moon; Mage
        7 = Blue Square; Shaman
        8 = Red "X" Cross; Warrior
        9 = White Skull; Priest
--]]


local unused_markers = {
    ["star"] = 2,
    ["circle"] = 3,
    ["diamond"] = 4,
    ["triangle"] = 5,
    ["moon"] = 6,
    ["square"] = 7,
    ["cross"] = 8,
    ["skull"] = 9
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

local function markPlayers(members)
    if members > 2 then
        ConvertToRaid()
        -- mark self
        if not GetRaidTargetIndex("player") then
            print("[ArenaMarker]: Marking the group.")
            setRaidTargetByClass("player")
        end
        -- mark party members
        for i=2, members-1 do
            if not GetRaidTargetIndex("party"..i) then
                setRaidTargetByClass("party"..i)
            end
        end
    end
end

local function markPets(members)
    for i=2, members-1 do
        if not GetRaidTargetIndex("party"..i.."pet") then
            findUsableMark(unused_markers, "party"..i.."pet")
            break
        end
    end
end

local function inArena(self, event, ...)
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            arg2 = ...
            local members = GetNumGroupMembers()
            if string.find(arg2, "One minute until the Arena battle begins!") or string.find(arg1, "Thirty seconds until the Arena battle begins!") or string.find(arg1, "Fifteen seconds until the Arena battle begins!") then
                markPlayers(members)
            elseif string.find(arg2, "The Arena battle has begun!") then
                markPets(members)
            end
        end
    end
end

frame:SetScript("OnEvent", inArena)