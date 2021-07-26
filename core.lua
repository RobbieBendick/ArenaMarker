local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
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

local function markPlayers(members)
    if members > 1 then
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

local function markPets(members)
    if not GetRaidTargetIndex(UnitName("player").."-pet") then
        findUsableMark(unused_markers, UnitName("player").."-pet")
    end
    for i=1, members-1 do
        if not GetRaidTargetIndex("party"..i.."pet") then
            findUsableMark(unused_markers, "party"..i.."pet")
            break
        end
    end
end

local function inArena(self, event, ...)
    local inInstance, instanceType = IsInInstance()
    local members = GetNumGroupMembers()
    if instanceType ~= "arena" then
        return
    end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
        return
    end
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        markPlayers(members)
        for key,value in pairs(translations) do
            if GetLocale() == key then
                if string.find(arg1, value) then
                    markPets(members)
                end
            end
        end
    end
end

frame:SetScript("OnEvent", inArena)