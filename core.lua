local _, core = ...;  -- Namespace
local Config = core.Config;
core.AM = {};
AM = core.AM;
members = GetNumGroupMembers;
local frame = CreateFrame("FRAME", "ArenaMarker")

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
    local key = table[value];
    table[value] = nil;
    return key;
end

function contains(table, x)
    for _, v in pairs(table) do
        if v == x then return true end
    end
    return false;
end

function AM:SetMarkerAndRemove(unit, marker_string)
    if not unit or not core.unused_markers[marker_string] then return end
    SetRaidTarget(unit, core.unused_markers[marker_string]);
    removeValue(core.unused_markers, marker_string);
end

function AM:FindUsableMark(target)
    local marker = "";
    for k, v in pairs(table) do
        if v ~= nil then
            marker = k;
            break
        end
    end
    AM:SetMarkerAndRemove(target, marker)
end

function AM:SetRaidTargetByClass(unit, ...)
    if not unit or GetRaidTargetIndex(unit) then return end
    local _, englishClass, _ = UnitClass(unit);
    for k, v in pairs(core.relatives) do
        if k == englishClass then
            if core.unused_markers[v] then
                AM:SetMarkerAndRemove(unit, v)
            else
                AM:FindUsableMark(unit);
            end
            break
        end
    end
end

function AM:MarkPlayers()
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() > 5 then return end
    if not GetRaidTargetIndex("player") then
        Config:ChatFrame("Marking the group.");
    end
    -- mark self
    AM:SetRaidTargetByClass("player");
    -- mark party members
    for i = 1, members() - 1 do
        AM:SetRaidTargetByClass("party" .. i);
    end
end

function AM:MarkPetWithPriority(unit)
    if not unit or not UnitExists(unit .. "pet") then return end
    if GetRaidTargetIndex(unit .. "pet") then return end

    local ans;
    if core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownMarkerID]] and unit == "player" then
        ans = AM:SetMarkerAndRemove(unit .. "pet", core.marker_strings[ArenaMarkerDB.petDropDownMarkerID])
    elseif core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownTwoMarkerID]] then
        ans = AM:SetMarkerAndRemove(unit .. "pet", core.marker_strings[ArenaMarkerDB.petDropDownTwoMarkerID]);
    elseif core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownThreeMarkerID]] then
        ans = AM:SetMarkerAndRemove(unit .. "pet", core.marker_strings[ArenaMarkerDB.petDropDownThreeMarkerID]);
    else
        ans = AM:FindUsableMark(unit .. "pet");
    end
    return ans;
end

function AM:MarkPets()
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() > 5 then return end
    -- mark player's pet
    AM:MarkPetWithPriority("player");
    -- mark party's pets
    for i = 1, members() - 1 do
        AM:MarkPetWithPriority("party" .. i);
    end
end

local petCastEvent = CreateFrame("FRAME")
petCastEvent:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

function AM:PetCastEventHandler(self, caster, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if not ArenaMarkerDB.markSummonedPets then return end
    if caster == "raid1" then return end
    local _, spellID = ...;
    for key, val in pairs(core.summons) do
        if spellID == key and val > 0 then
            C_Timer.After(0.5, function() AM:MarkPetWithPriority(caster) end);
        end
    end
end

function AM:CheckExistingMarks()
    -- reset table
    for i = 1, #core.marker_strings do
        core.unused_markers[core.marker_strings[i]] = i;
    end
    -- update which marks are currently being used on players and pets
    local function Remove(unit)
        if not GetRaidTargetIndex(unit) then return end
        if not core.unused_markers[core.marker_strings[GetRaidTargetIndex(unit)]] then return end
        removeValue(core.unused_markers, core.marker_strings[GetRaidTargetIndex(unit)]);
    end

    -- Player and Player's pet
    Remove("player");
    Remove("pet");
    -- Party and Party Pets
    for i = 1, members() - 1 do
        Remove("party" .. i);
        Remove("party" .. i .. "pet");
    end
end

local update = CreateFrame("Frame")
function AM:Removed_Mark_Handler()
    -- exit function if removed_markers doesnt have a valid value
    local c = 0;
    for _, k in pairs(core.removed_markers) do if k ~= nil then c = c + 1 end end
    if c == 0 then return end
    for i, v in pairs(core.removed_markers) do
        if not contains(core.unused_markers, v) then
            -- re-populate table if user clicks remove_mark button(s)
            for j = 1, #core.marker_strings do
                if v == j then
                    core.unused_markers[core.marker_strings[j]] = j;
                    removeValue(core.removed_markers, i);
                end
            end
        end
    end
end

update:SetScript("OnUpdate", AM.Removed_Mark_Handler);

function AM:SetSummonsToOneAfterGates(txt)
    for k, v in pairs(core.translations) do
        if GetLocale() == k then
            if string.find(txt, v) then
                for i, _ in pairs(core.summons) do
                    core.summons[i] = 1;
                end
            end
        end
    end
end

function AM:SetSummonsToZero()
    for i, _ in pairs(core.summons) do
        for j = 1, #core.summonAfterGates do
            if i == core.summonAfterGates[j] then
                core.summons[i] = 0;
            end
        end
    end
end

function AM:MarkPetsWhenGatesOpen(txt)
    if not ArenaMarkerDB.allowPets then return end
    for k, v in pairs(core.translations) do
        if GetLocale() == k then
            if string.find(txt, v) then
                AM:MarkPets();
                AM:CheckExistingMarks();
            end
        end
    end
end

function AM:IsOutOfArena()
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then
        AM:SetSummonsToZero();
    end
end

function AM:Main(self, txt, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() <= 1 then return end
    AM:CheckExistingMarks();
    AM:MarkPlayers();
    AM:MarkPetsWhenGatesOpen(txt);
    AM:SetSummonsToOneAfterGates(txt);
end

local addonLoadedFrame = CreateFrame("Frame");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
local eventFrame = CreateFrame("Frame");
function AM:Addon_Loaded()
    -- Register all relevant events
    for event, func in pairs(core.eventHandlerTable) do
        eventFrame:RegisterEvent(event);
    end
    SLASH_ARENAMARKER1 = "/am";
    SlashCmdList.ARENAMARKER = Config.Toggle;
end

-- Event Handler
function AM:EventHandler(event, ...)
    return core.eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", AM.Addon_Loaded);
eventFrame:SetScript("OnEvent", AM.EventHandler);
