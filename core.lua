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
function AM:SetMarkerAndRemove(unit, markerString)
    if not unit or not core.unusedMarkers[markerString] then return end
    SetRaidTarget(unit, core.unusedMarkers[markerString]);
    removeValue(core.unusedMarkers, markerString);
end

function AM:FindUsableMark(target)
    local unusedMarker = "";
    for marker, val in pairs(core.unusedMarkers) do
        if val then
            unusedMarker = marker;
            break;
        end
    end
    AM:SetMarkerAndRemove(target, unusedMarker);
end

function AM:SetRaidTargetByClass(unit, ...)
    if not unit or GetRaidTargetIndex(unit) then return end
    local _, unitClass = UnitClass(unit);
    for class, markerList in pairs(core.relatives) do
        if class == unitClass then
            for _, marker in pairs(markerList) do
                if core.unusedMarkers[marker] then
                    return AM:SetMarkerAndRemove(unit, marker);
                end
            end
        end
    end
    return AM:FindUsableMark(unit);
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

    if core.unusedMarkers[core.markerStrings[ArenaMarkerDB.petDropDownMarkerID]] and unit == "player" then
        return AM:SetMarkerAndRemove(unit .. "pet", core.markerStrings[ArenaMarkerDB.petDropDownMarkerID]);
    elseif core.unusedMarkers[core.markerStrings[ArenaMarkerDB.petDropDownTwoMarkerID]] then
        return AM:SetMarkerAndRemove(unit .. "pet", core.markerStrings[ArenaMarkerDB.petDropDownTwoMarkerID]);
    elseif core.unusedMarkers[core.markerStrings[ArenaMarkerDB.petDropDownThreeMarkerID]] then
        return AM:SetMarkerAndRemove(unit .. "pet", core.markerStrings[ArenaMarkerDB.petDropDownThreeMarkerID]);
    end

    return AM:FindUsableMark(unit .. "pet");
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
    for i, markerValue in ipairs(core.removedMarkers) do
        if not contains(core.unusedMarkers, markerValue) then
            for j = 1, #core.markerStrings do
                if markerValue == j then
                    core.unusedMarkers[core.markerStrings[markerValue]] = markerValue;
                    removeValue(core.removedMarkers, i);
                end
            end
        end
    end
end

function AM:RemarkShadowmeld(self, ...)
    local unit, _, spellID = ...;
    if not unit or not spellID then return end
    if unit:sub(1, #"nameplate") == "nameplate" then return end
    if unit:sub(1, #"raid") == "raid" then return end
    if not UnitInParty(unit) then return end

    local shadowmeldSpellID = 58984;

    if spellID == shadowmeldSpellID then
        C_Timer.After(1.6, function()
            AM:CheckExistingMarks();
            AM:SetRaidTargetByClass(unit);
        end);
    end
end

function AM:HandleUnitSpellCastSucceeded(self, ...)
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then return end
    AM:PetCastEventHandler(self, ...);
    AM:RemarkShadowmeld(self, ...);
end

function AM:UnmarkPets()
    if members() > 5 then return end
    if UnitExists("pet") then
        if GetRaidTargetIndex("pet") then
            table.insert(core.removedMarkers, GetRaidTargetIndex("pet"));
            SetRaidTarget("pet", 0);
        end
    end
    for i = 1, members() - 1 do
        if UnitExists("party" .. i .. "pet") then
            if GetRaidTargetIndex("party" .. i .. "pet") then
                table.insert(core.removedMarkers, GetRaidTargetIndex("party" .. i .. "pet"));
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
        table.insert(core.removedMarkers, GetRaidTargetIndex("player"));
        SetRaidTarget("player", 0);
    end
    -- unmark party members
    for i = 1, members() - 1 do
        if GetRaidTargetIndex("party" .. i) then
            table.insert(core.removedMarkers, GetRaidTargetIndex("party" .. i));
            SetRaidTarget("party" .. i, 0);
        end
    end
    AM:RepopulateUnusedMarkers();
end

function AM:PetCastEventHandler(self, ...)
    local unit, _, spellID = ...;
    if not ArenaMarkerDB.markSummonedPets then return end
    if unit:sub(1, #"raid") == "raid" then return end
    for summonSpellID, summonIsAllowed in pairs(core.summons) do
        if spellID == summonSpellID and summonIsAllowed then
            C_Timer.After(0.5, function() AM:MarkPetWithPriority(unit) end);
        end
    end
end

function AM:CheckExistingMarks()
    -- reset table
    for i = 1, #core.markerStrings do
        core.unusedMarkers[core.markerStrings[i]] = i;
    end
    local function removeMarkerFromTable(unit)
        if not GetRaidTargetIndex(unit) then return end
        if not core.unusedMarkers[core.markerStrings[GetRaidTargetIndex(unit)]] then return end
        removeValue(core.unusedMarkers, core.markerStrings[GetRaidTargetIndex(unit)]);
    end

    -- update which marks are currently being used on players and pets
    removeMarkerFromTable("player");
    removeMarkerFromTable("pet");
    for i = 1, members() - 1 do
        removeMarkerFromTable("party" .. i);
        removeMarkerFromTable("party" .. i .. "pet");
    end
end

function AM:SetSummonsToTrueAfterGates(txt)
    for region, regionText in pairs(core.translations) do
        if GetLocale() == region then
            if txt:find(regionText) then
                for i in pairs(core.summons) do
                    if not core.summons[i] then
                        table.insert(core.summonAfterGates, i);
                        core.summons[i] = true;
                    end
                end
            end
        end
    end
end

function AM:SetSummonsToFalse()
    for i in pairs(core.summons) do
        for j = 1, #core.summonAfterGates do
            if i == core.summonAfterGates[j] then
                core.summons[i] = false;
                removeValue(core.summonAfterGates, j);
            end
        end
    end
end

function AM:MarkPetsWhenGatesOpen(txt)
    if not ArenaMarkerDB.allowPets then return end
    for region, regionText in pairs(core.translations) do
        if GetLocale() == region then
            if txt:find(regionText) then
                AM:MarkPets();
                AM:CheckExistingMarks();
            end
        end
    end
end

function AM:IsOutOfArena()
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then
        AM:SetSummonsToFalse();
    end
end

function AM:Main(self, txt, ...)
    local _, instanceType = IsInInstance();
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
