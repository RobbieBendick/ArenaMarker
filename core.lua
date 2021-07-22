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

function removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end


local function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    
    if englishClass == "ROGUE" then
        if unused_markers["star"] then
            SetRaidTarget(target, 1)
            removeKey(unused_markers, "star")
        end
    end
    if englishClass == "DRUID" then
        if unused_markers["circle"] then
            SetRaidTarget(target, 2)
            removeKey(unused_markers, "circle")
        end 
    end
    if englishClass == "WARLOCK" then
        if unused_markers["diamond"] then
            SetRaidTarget(target, 3)
            removeKey(unused_markers, "diamond")
        end 
    end
    if englishClass == "PALADIN" then
        if unused_markers["diamond"] then
            SetRaidTarget(target, 3)
            removeKey(unused_markers, "diamond")
        end 
    end
    if englishClass == "HUNTER" then
        if unused_markers["triangle"] then
            SetRaidTarget(target, 4)
            removeKey(unused_markers, "triangle")
        end 
    end
    if englishClass == "MAGE" then
        if unused_markers["moon"] then
            SetRaidTarget(target, 5)
            removeKey(unused_markers, "moon")
        end 
    end
    if englishclass == "SHAMAN" then
        if unused_markers["square"] then
            SetRaidTarget(target, 6)
            removeKey(unused_markers, "square")
        end 
    end
    if englishClass == "WARRIOR" then
        if unused_markers["cross"] then
            SetRaidTarget(target, 7)
            removeKey(unused_markers, "cross")
        end 
    end
    if englishClass == "PRIEST" then
        if unused_markers["skull"] then
            SetRaidTarget(target, 8)
            removeKey(unused_markers, "skull")
        end 
    end
end

local function markTeammatesAndSelf(self, event, ...)
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        if string.find(arg1, "One minute until the Arena battle begins!") or string.find(arg1, "Thirty seconds until the Arena battle begins!") or string.find(arg1, "Fifteen seconds until the Arena battle begins!") or string.find(arg1, "The Arena battle has begun!") then
            local members = GetNumGroupMembers()
            if members > 1 then
                if UnitIsGroupLeader("player") then
                    ConvertToRaid()
                    -- mark self
                    if GetRaidTargetIndex("player") == nil then
                        print("[ArenaMarker]: Marking the group.")
                        setRaidTargetByClass("player")
                    end
                    -- mark party members
                    for i=1, members-1 do
                        if GetRaidTargetIndex("party"..i) == nil then
                            setRaidTargetByClass("party"..i)
                        end
                    end
                    -- mark duplicate class members
                    local marker = ""
                    for j=1, members-1 do
                        if GetRaidTargetIndex("party"..j) == nil then
                            for i,v in pairs(unused_markers) do
                                if v ~= nil then
                                    marker = i
                                    break
                                end
                            end
                            SetRaidTarget("party"..j, unused_markers[marker])
                        end
                    end
                end
            end
        end
    end
end

frame:SetScript("OnEvent", markTeammatesAndSelf)
