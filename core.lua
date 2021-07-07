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

unused_markers = {1,2,3,4,5,6,7,8}  

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function sleep(n)
    local t = os.clock()
    while os.clock() - t <= n do
      -- nothing
    end
end

local function chooseMarker(target, i, ...)
    -- check if the marker we are going to use is available
    for v in pairs(unused_markers) do
        if v == i then
            SetRaidTarget(target, v)
            table.remove(unused_markers, v)
        end
    end
end

local function setRaidTargetByClass(target, i, ...)
    local _, englishClass, _ = UnitClass(target);
    
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

local function markTeammatesAndSelf(self, event, ...)
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        if (string.find(arg1, "One minute until the Arena battle begins!") or
            string.find(arg1, "Thirty seconds until the Arena battle begins!") or
            string.find(arg1, "Fifteen seconds until the Arena battle begins!") or
            string.find(arg1, "The Arena battle has begun!")) then
            local members = GetNumGroupMembers()
            if members > 1 then
                if UnitIsGroupLeader("player") then
                    ConvertToRaid()
                    -- mark self
                    if GetRaidTargetIndex("player") == nil then
                        setRaidTargetByClass("player")
                    end
                    for i = 1, members-1 do
                        -- mark party members                        
                        if GetRaidTargetIndex("party"..i) == nil then
                            setRaidTargetByClass("party"..i)
                        end
                    end
                    -- delay for a second, else GetRaidTargetIndex will return nil.
                    sleep(1)
                    for i=1, members-1 do
                        local randomIndexOfTable = math.random(tablelength(unused_markers))
                        if GetRaidTargetIndex("party"..i) == nil then
                            SetRaidTarget("party"..i, unused_markers[randomIndexOfTable])
                            table.remove(randomIndexOfTable)
                        end
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", markTeammatesAndSelf)
