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
    TODO: Breaks when setting assist
          Marks self at 15 seconds instead of 30
--]]

unused_markers = {1,2,3,4,5,6,7,8}  

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

local function chooseMarker(target, i, ...)
    -- check if mark is in unused_markers
    local item;
    for v in pairs(unused_markers) do
        if v == i then
            item = v
        end
    end
    SetRaidTarget(target, item)
    table.remove(unused_markers, item)
end

local function setRaidTargetByClass(target, i, ...)
    _, englishClass, _ = UnitClass(target);
    print("target: " .. target .. "\nclass: " .. englishClass)
    
    if englishClass == "ROGUE" then
        chooseMarker(target, 1)
    end
    if englishClass == "DRUID" then
        chooseMarker(target, 2)
    end
    if englishClass == "WARLOCK" then
        chooseMarker(target, 3)
    end
    if englishClass == "PALADIN" then
        chooseMarker(target, 3)
    end
    if englishClass == "HUNTER" then
        chooseMarker(target, 4)
    end
    if englishClass == "MAGE" then
        chooseMarker(target, 5)
    end
    if englishclass == "SHAMAN" then
        chooseMarker(target, 6)
    end
    if englishClass == "WARRIOR" then
        chooseMarker(target, 7)
    end
    if englishClass == "PRIEST" then
        chooseMarker(target, 8)
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
                    if GetRaidTargetIndex("player") == nil then
                        setRaidTargetByClass("player")
                    end
                    for i = 1, members-1 do
                        -- mark party members
                        if GetRaidTargetIndex("party"..i) == nil then
                            setRaidTargetByClass("party" .. i)
                        end
                        -- give assist
                        -- SendChatMessage("/assist " .. UnitName(target))
                    end
                    for i=1, members-1 do
                        local randomIndexOfTable = math.random(tablelength(unused_markers))
                        if GetRaidTargetIndex("party"..i) == nil then
                            print("RandomIndexOfTable: " .. randomIndexOfTable)
                            SetRaidTarget("party"..i, unused_markers[randomIndexOfTable])
                            table.remove(randomIndexOfTable)
                        end
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", markAndRaidAssistTeammates)
