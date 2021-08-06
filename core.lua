local _, core = ...; -- Namespace
core.AM = {};
AM = core.AM;
local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

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

core.unused_markers = {
    ["star"] = 1,
    ["circle"] = 2,
    ["diamond"] = 3,
    ["triangle"] = 4,
    ["moon"] = 5,
    ["square"] = 6,
    ["cross"] = 7,
    ["skull"] = 8
}

core.relatives = {
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

function removeValue(table, value)
    local key = table[value]
    table[value] = nil
    return key
end

function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false
end

function findUsableMark(table, target)
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

function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    for k,v in pairs(core.relatives) do
        if k == englishClass then
            if core.unused_markers[v] then
                SetRaidTarget(target, core.unused_markers[v])
                removeValue(core.unused_markers, v)
                break
            else
                findUsableMark(core.unused_markers, target)
                break
            end
        end
    end
end

function AM:MarkPlayers()
    local members = GetNumGroupMembers()
    -- mark self
    if not GetRaidTargetIndex("player") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Marking the group.")
        setRaidTargetByClass("player")
    end
    -- mark party members
    for i=1, members-1 do
        if not GetRaidTargetIndex("party"..i) then
            setRaidTargetByClass("party"..i)
        end
    end
end

function AM:MarkPets()
    local members = GetNumGroupMembers()
    if UnitExists("pet") then
        if not GetRaidTargetIndex("pet") then
            findUsableMark(core.unused_markers, "pet")
        end
    end
    for i=1, members-1 do
        if UnitExists("party"..i.."pet") then
            if not GetRaidTargetIndex("party"..i.."pet") then
                findUsableMark(core.unused_markers, "party"..i.."pet")
            end
        end
    end
end

local function inArena(self, event, ...)
    local inInstance, instanceType = IsInInstance()
    local members = GetNumGroupMembers()
    local isArena, isRegistered = IsActiveBattlefieldArena()

    if event == "ZONE_CHANGED_NEW_AREA" and instanceType == "arena" and not isRegistered then
       --reset table everytime user enter skirmishes
        core.unused_markers = {
            ["star"] = 1,
            ["circle"] = 2,
            ["diamond"] = 3,
            ["triangle"] = 4,
            ["moon"] = 5,
            ["square"] = 6,
            ["cross"] = 7,
            ["skull"] = 8
        }
    end
    if instanceType ~= "arena" then
        return
    end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
        return
    end
    if members <= 1 then
        return
    end
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        ConvertToRaid()
        AM.MarkPlayers()
        -- mark pets when gates open
        if core.allowPets then
            arg1 = ...
            for key,value in pairs(core.translations) do 
                if GetLocale() == key then
                    if string.find(arg1, value) then
                        AM.MarkPets()
                    end
                end
            end
        end
    end
end
frame:SetScript("OnEvent", inArena)