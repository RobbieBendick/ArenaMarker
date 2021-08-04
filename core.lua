local _, core = ...; -- Namespace

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

local translations = {
    ["enUS"] = "The Arena battle has begun!",
    ["enGB"] = "The Arena battle has begun!",
    ["frFR"] = "Le combat d'arène commence !",
    ["deDE"] = "Der Arenakampf hat begonnen!",
    ["ptBR"] = "A batalha na Arena começou!",
    ["esES"] = "¡La batalla en arena ha comenzado!",
    ["esMX"] = "¡La batalla en arena ha comenzado!",
    ["ruRU"] = "Бой начался!",
    ["zhCN"] = "竞技场的战斗开始了！",
    ["zhTW"] = "競技場戰鬥開始了!",
    ["koKR"] = "투기장 전투가 시작되었습니다!",
}

local function removeMark(table, value)
    local key = table[value]
    table[value] = nil
    return key
end

local function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false
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
    removeMark(table, marker)
end

local function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    for k,v in pairs(relatives) do
        if k == englishClass then
            if unused_markers[v] then
                SetRaidTarget(target, unused_markers[v])
                removeMark(unused_markers, v)
                break
            else
                findUsableMark(unused_markers, target)
                break
            end
        end
    end
end

local function markPlayers(members)
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

local function markPets(members)
    if UnitExists("pet") then
        if not GetRaidTargetIndex("pet") then
            findUsableMark(unused_markers, "pet")
        end
    end
    for i=1, members-1 do
        if UnitExists("party"..i.."pet") then
            if not GetRaidTargetIndex("party"..i.."pet") then
                findUsableMark(unused_markers, "party"..i.."pet")
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
        unused_markers = {
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
        if core.pets then
            for i,v in pairs(core.pets) do
                if not contains(unused_markers, v) then
                    -- populate table, we placed the marker back.
                    if v == 1 then
                        unused_markers["star"] = 1;
                    end
                    if v == 2 then
                        unused_markers["circle"] = 2;
                    end
                    if v == 3 then
                        unused_markers["diamond"] = 3;
                    end
                    if v == 4 then
                        unused_markers["triangle"] = 4;
                    end
                    if v == 5 then
                        unused_markers["moon"] = 5;
                    end
                    if v == 6 then
                        unused_markers["square"] = 6;
                    end
                    if v == 7 then
                        unused_markers["cross"] = 7;
                    end
                    if v == 8 then
                        unused_markers["skull"] = 8;
                    end
                end
            end
        end
        arg1 = ...
        ConvertToRaid()
        markPlayers(members)
        -- mark pets when gates open
        if core.allowPets then
            for key,value in pairs(translations) do 
                if GetLocale() == key then
                    if string.find(arg1, value) then
                        markPets(members)
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", inArena)

local function init()
    SLASH_ARENAMARKER1 = "/am";
    SlashCmdList.ARENAMARKER = core.Config.Toggle;
end
local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", init);

local function login()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: /am for additional options")
end

enterWorld = CreateFrame("FRAME");
enterWorld:RegisterEvent("PLAYER_LOGIN");
enterWorld:SetScript("OnEvent", login);