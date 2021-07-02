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
    TODO: When there's 2 of the same classes, and you happen to be one of those two players, places mark on self first, then instantly swaps to party1, then vice-versa at 15 seconds.
          Still need to find a way to give raid-assistant to party members.
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
    -- check if the marker we are going to use is available
    for v in pairs(unused_markers) do
        if v == i then
            print("[ChooseMarker] Value:"..v.."[ChooseMarker] Item:"..i)
            SetRaidTarget(target, v)
            table.remove(unused_markers, v)
        end
    end
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


function sleep(n)
    local t = os.clock()
    while os.clock() - t <= n do
      -- nothing
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
                    -- mark self
                    if GetRaidTargetIndex("player") == nil then
                        print("marking myself")
                        setRaidTargetByClass("player")
                    end
                    for i = 1, members-1 do
                        -- mark party members                        
                        if GetRaidTargetIndex("party"..i) == nil then
                            print("marker on party" .. i .. " should be out")
                            setRaidTargetByClass("party" .. i)
                        end
                        -- SendChatMessage("/assist " .. UnitName(target))
                    end

                    -- delay 2 seconds, or else GetRaidTargetIndex will return nil and it will instantly throw a random mark on party members.
                    sleep(2)
                    for i=1, members-1 do
                        local randomIndexOfTable = math.random(tablelength(unused_markers))
                        if GetRaidTargetIndex("party"..i) == nil then
                            print("RandomIndexOfTable: " .. randomIndexOfTable .. "\n The extra marks should be on aswell!")
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
