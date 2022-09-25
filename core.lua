--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
local Config = core.Config;
core.AM = {};
AM = core.AM;
members = GetNumGroupMembers;

--[[
    Marker numbers:
        1 = Yellow 4-point Star; Rogue
        2 = Orange Circle; Druid
        3 = Purple Diamond; Lock, Paladin, (Demon Hunter on Retail)
        4 = Green Triangle; Hunter, (Monk on Retail)
        5 = White Crescent Moon; Mage
        6 = Blue Square; Shaman
        7 = Red "X" Cross; Warrior, (Death Knight on Retail)
        8 = White Skull; Priest
--]]

--------------------------------------
-- AM functions
--------------------------------------
function AM:SetMarkerAndRemove(unit, marker_string)
    if not unit or not core.unused_markers[marker_string] then return end
    SetRaidTarget(unit, core.unused_markers[marker_string]);
    removeValue(core.unused_markers, marker_string);
end

function AM:FindUsableMark(target)
    local marker = "";
    for k, v in pairs(core.unused_markers) do
        if v then
            marker = k;
            break;
        end
    end
    AM:SetMarkerAndRemove(target, marker);
end

function AM:SetRaidTargetByClass(unit, ...)
    if not unit or GetRaidTargetIndex(unit) then return end
    local _, englishClass, _ = UnitClass(unit);
    for k, v in pairs(core.relatives) do
        if k == englishClass then
            if core.unused_markers[v] then
                AM:SetMarkerAndRemove(unit, v);
            else
                AM:FindUsableMark(unit);
            end
            break;
        end
    end
end

function AM:MarkPlayers()
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
        ans = AM:SetMarkerAndRemove(unit .. "pet", core.marker_strings[ArenaMarkerDB.petDropDownMarkerID]);
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
    if members() > 5 then return end
    -- mark player's pet
    AM:MarkPetWithPriority("player");
    -- mark party's pets
    for i = 1, members() - 1 do
        AM:MarkPetWithPriority("party" .. i);
    end
end

function AM:RepopulateUnusedMarkers()
    -- re-populate table if user clicks remove_mark button(s)
    for i, v in pairs(core.removed_markers) do
        if not contains(core.unused_markers, v) then
            for j = 1, #core.marker_strings do
                if v == j then
                    core.unused_markers[core.marker_strings[j]] = j;
                    removeValue(core.removed_markers, i);
                end
            end
        end
    end
end

function AM:UnmarkPets()
    if members() > 5 then return end
    if UnitExists("pet") then
        if GetRaidTargetIndex("pet") then
            table.insert(core.removed_markers, GetRaidTargetIndex("pet"));
            SetRaidTarget("pet", 0);
        end
    end
    for i = 1, members() - 1 do
        if UnitExists("party" .. i .. "pet") then
            if GetRaidTargetIndex("party" .. i .. "pet") then
                table.insert(core.removed_markers, GetRaidTargetIndex("party" .. i .. "pet"));
                SetRaidTarget("party" .. i .. "pet", 0);
            end
        end
    end
    AM:RepopulateUnusedMarkers();
end

function AM:UnmarkPlayers()
    if members() > 5 then return end
    -- unmark self
    if GetRaidTargetIndex("player") then
        Config:ChatFrame("Unmarking the group.");
        table.insert(core.removed_markers, GetRaidTargetIndex("player"));
        SetRaidTarget("player", 0);
    end
    -- unmark party members
    for i = 1, members() - 1 do
        if GetRaidTargetIndex("party" .. i) then
            table.insert(core.removed_markers, GetRaidTargetIndex("party" .. i));
            SetRaidTarget("party" .. i, 0);
        end
    end
    AM:RepopulateUnusedMarkers();
end

function AM:PetCastEventHandler(self, caster, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if not ArenaMarkerDB.markSummonedPets then return end
    if caster == "raid1" then return end
    local _, spellID = ...;
    for key, val in pairs(core.summons) do
        if spellID == key and val then
            C_Timer.After(0.5, function() AM:MarkPetWithPriority(caster) end);
        end
    end
end

function AM:CheckExistingMarks()
    -- reset table
    for i = 1, #core.marker_strings do
        core.unused_markers[core.marker_strings[i]] = i;
    end
    local function Remove(unit)
        if not GetRaidTargetIndex(unit) then return end
        if not core.unused_markers[core.marker_strings[GetRaidTargetIndex(unit)]] then return end
        removeValue(core.unused_markers, core.marker_strings[GetRaidTargetIndex(unit)]);
    end

    -- update which marks are currently being used on players and pets
    Remove("player");
    Remove("pet");
    for i = 1, members() - 1 do
        Remove("party" .. i);
        Remove("party" .. i .. "pet");
    end
end

function AM:SetSummonsToTrueAfterGates(txt)
    for k, v in pairs(core.translations) do
        if GetLocale() == k then
            if string.find(txt, v) then
                for i, _ in pairs(core.summons) do
                    if not core.summons[i] then
                        table.insert(core.summon_after_gates, i);
                        core.summons[i] = true;
                    end
                end
            end
        end
    end
end

function AM:SetSummonsToFalse()
    for i, _ in pairs(core.summons) do
        for j = 1, #core.summon_after_gates do
            if i == core.summon_after_gates[j] then
                core.summons[i] = false;
                removeValue(core.summon_after_gates, j);
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
        AM:SetSummonsToFalse();
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
    AM:SetSummonsToTrueAfterGates(txt);
end

local addonLoadedFrame = CreateFrame("Frame");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
local eventFrame = CreateFrame("Frame");
function AM:Addon_Loaded()
    -- register all relevant events
    for event, func in pairs(core.eventHandlerTable) do
        eventFrame:RegisterEvent(event);
    end
    SLASH_ARENAMARKER1 = "/am";
    SlashCmdList.ARENAMARKER = Config.Toggle;
end

-- event handler
function AM:EventHandler(event, ...)
    return core.eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", AM.Addon_Loaded);
eventFrame:SetScript("OnEvent", AM.EventHandler);
