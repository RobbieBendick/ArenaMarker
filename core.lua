local _, core = ...; -- Namespace
core.AM = {};
AM = core.AM;
members = GetNumGroupMembers;
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

-- HERE IS WHERE YOU WOULD CHANGE THE CLASS MARKER COMBINATIONS
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
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
    -- mark self
    if not GetRaidTargetIndex("player") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Marking the group.")
        setRaidTargetByClass("player")
    end
    -- mark party members
    for i=1, members()-1 do
        if not GetRaidTargetIndex("party"..i) then
            setRaidTargetByClass("party"..i)
        end
    end
end

function AM:MarkPets()
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
    if UnitExists("pet") then
        if not GetRaidTargetIndex("pet") then
            --check if prio marks are aviailable
            if core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownID]] then
                SetRaidTarget("pet", ArenaMarkerDB.petDropDownID)
                removeValue(unused_markers, core.marker_strings[ArenaMarkerDB.petDropDownID])
            else
                findUsableMark(core.unused_markers, "pet")
            end
        end
    end
    for i=1, members()-1 do
         if UnitExists("party"..i.."pet") then
            if not GetRaidTargetIndex("party"..i.."pet") then
                --check if prio marks are aviailable
                if core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownID]] then
                    SetRaidTarget("party"..i.."pet", ArenaMarkerDB.petDropDownID)
                    removeValue(unused_markers, core.marker_strings[ArenaMarkerDB.petDropDownID])
                else
                    findUsableMark(core.unused_markers, "party"..i.."pet")
                end
            end
        end
    end
end

function AM:CheckExistingMarksOnPlayers()
    -- reset table
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
    --update which marks are currently being used on players(not pets)
    if GetRaidTargetIndex("player") then
        local marker = core.marker_strings[GetRaidTargetIndex("player")]
        if core.unused_markers[marker] then
            core.unused_markers[marker] = nil;
        end
    end
    for i=1,members()-1 do
        if GetRaidTargetIndex("party"..i) then
            local marker = core.marker_strings[GetRaidTargetIndex("party"..i)]
            if core.unused_markers[marker] then
                core.unused_markers[marker] = nil;
            end
        end
    end
end

function AM:MarkPetsWhenGatesOpen()
    if not ArenaMarkerDB.allowPets then return end
    for key,value in pairs(core.translations) do 
        if GetLocale() == key then
            if string.find(arg1, value) then
                AM.MarkPets()
            end
        end
    end
end

local function inArena(self, event, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() <= 1 then return end
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        AM.CheckExistingMarksOnPlayers()
        AM.MarkPlayers()
        AM.MarkPetsWhenGatesOpen()
    end
end
frame:SetScript("OnEvent", inArena)