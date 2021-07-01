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
        5 = White Crescent Moon; Priest, Mage
        6 = Blue Square; Mage, Shaman
        7 = Red "X" Cross; Filler?
        8 = White Skull; Warrior
--]]

--[[
    TODO: Recursive function &/or duplicates not working
          Breaks when setting assist
--]]

classes = {
    ["Rogue"] = 1,
    ["Druid"] = 2,
    ["Warlock"] = 3,
    ["Paladin"] = 3,
    ["Hunter"] = 4,
    ["Mage"] = 5,
    ["Shaman"] = 6,
    ["Warrior"] = 7,
    ["Priest"] = 8,
}


usedMarkers = {
    star = false,
    circle = false,
    diamond = false,
    triangle = false,
    moon = false,
    square = false,
    cross = false,
    skull = false
}
priority = {}
duplicates = {}
MissingTable = {}

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    print(count)
    return count
end

local function chooseMarker(target, duplicates, table, i, ...)
    if i == 1 then
        if not table.star then
            SetRaidTarget(target, i)
            table.star = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 2 then
        if not table.circle then
            SetRaidTarget(target, i)
            table.circle = true
        else          
            table.insert(duplicates, i)
        end
    end
    if i == 3 then
        if not table.diamond then
            SetRaidTarget(target, i)
            table.diamond = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 4 then
        if not table.triangle then
            SetRaidTarget(target, i)
            table.triangle = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 5 then
        if not table.moon then
            SetRaidTarget(target, i)
            table.moon = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 6 then
        if not table.square then
            SetRaidTarget(target, i)
            table.square = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 7 then
        if not table.cross then
            SetRaidTarget(target, i)
            table.cross = true
        else
            table.insert(duplicates, i)
        end
    end
    if i == 8 then
        if not table.skull then
            SetRaidTarget(target, 8)
            table.skull = true
        else
            table.insert(duplicates, i)
        end
    end
end

local function setRaidTargetByClass(target, duplicates, table, i, ...)
    _, englishClass, _ = UnitClass(target);
    print("target: " .. target .. "\nclass: " .. englishClass)

    if englishClass == "ROGUE" then
        chooseMarker(target, duplicates, table, 1)
    end
    if englishClass == "DRUID" then
        chooseMarker(target, duplicates, table, 2)
    end
    if englishClass == "WARLOCK" then
        chooseMarker(target, duplicates, table, 3)
    end
    if englishClass == "PALADIN" then
        chooseMarker(target, duplicates, table, 3)
    end
    if englishClass == "HUNTER" then
        chooseMarker(target, duplicates, table, 4)
    end
    if englishClass == "MAGE" then
        chooseMarker(target, duplicates, table, 5)
    end
    if englishclass == "SHAMAN" then
        chooseMarker(target, duplicates, table, 6)
    end
    if englishClass == "WARRIOR" then
        chooseMarker(target, duplicates, table, 7)
    end
    if englishClass == "PRIEST" then
        chooseMarker(target, duplicates, table, 8)
    end
end

local function recursiveChooseMarker(target, duplicates, table, i, ...)
    if i == 1 then
        if not table.star then
            SetRaidTarget(target, i)
            table.star = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 2 then
        if not table.circle then
            SetRaidTarget(target, i)
            table.circle = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 3 then
        if not table.diamond then
            SetRaidTarget(target, i)
            table.diamond = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 4 then
        if not table.triangle then
            SetRaidTarget(target, i)
            table.triangle = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 5 then
        if not table.moon then
            SetRaidTarget(target, i)
            table.moon = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 6 then
        if not table.square then
            SetRaidTarget(target, i)
            table.square = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 7 then
        if not table.cross then
            SetRaidTarget(target, i)
            table.cross = true
        else
            recursiveChooseMarker(target, duplicates, table, i + 1)
        end
    end
    if i == 8 then
        if not table.skull then
            SetRaidTarget(target, i)
            table.skull = true
        end
    end
end


function getMissingMarkers(table, minNumber, maxNumber)
    for i = minNumber, maxNumber do
        -- check which marks are set to false
        if not table.star then
        table.insert(MissingTable, i)
        end
    end
end

local function markAndRaidAssistTeammates(self, event, ...)
    local members = GetNumGroupMembers()
    
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        if (string.find(arg1, "Thirty seconds until the Arena battle begins!") or
            string.find(arg1, "Fifteen seconds until the Arena battle begins!")) then
            members = GetNumGroupMembers()
            if members > 1 then
                if UnitIsGroupLeader("player") then
                    ConvertToRaid()
                    -- mark player
                    setRaidTargetByClass("player", duplicates, usedMarkers, i)
                    for i = 1, members do
                        -- give assist
                        -- mark party members
                        print("No marker on party" .. i)
                        setRaidTargetByClass("party" .. i, duplicates, usedMarkers, i)
                        -- SendChatMessage("/assist " .. UnitName(target))
                    end
                    numDuplicates = tablelength(duplicates)
                    print(numDuplicates)
                    if numDuplicates > 0 then
                        getMissingMarkers(usedMarkers, 1, numDuplicates);
                        for i=1, members do
                            if GetRaidTargetIndex("party"..i) == nil then
                                SetRaidTarget("party"..i, MissingTable[i])
                            end
                        end
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", markAndRaidAssistTeammates)
