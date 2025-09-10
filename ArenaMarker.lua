--------------------------------------
-- Namespace
--------------------------------------
local _, addon = ...;
local ArenaMarker = LibStub("AceAddon-3.0"):GetAddon(addon.name);
local members = GetNumGroupMembers;

--[[
    Marker numbers:
        1 = Yellow 4-point Star; Rogue
        2 = Orange Circle; Druid
        3 = Purple Diamond; Lock, Paladin, (Demon Hunter on Retail)
        4 = Green Triangle; Hunter, (Monk & Evoker on Retail)
        5 = White Crescent Moon; Mage
        6 = Blue Square; Shaman
        7 = Red "X" Cross; Warrior, (Death Knight on Retail)
        8 = White Skull; Priest
--]]
--------------------------------------
-- ArenaMarker functions
--------------------------------------
function ArenaMarker:SetMarkerAndRemove(unit, markerString)
    if not unit or not self.unusedMarkers[markerString] then return end
    SetRaidTarget(unit, self.unusedMarkers[markerString]);
    removeValue(self.unusedMarkers, markerString);
end

function ArenaMarker:FindUsableMark(unit)
    local unusedMarker = "";
    for marker, val in pairs(self.unusedMarkers) do
        if val then
            unusedMarker = marker;
            break;
        end
    end
    self:SetMarkerAndRemove(unit, unusedMarker);
end

function ArenaMarker:SetRaidTargetByClass(unit, ...)
    if not unit or GetRaidTargetIndex(unit) then return end
    local _, unitClass = UnitClass(unit);
    for class, markerList in pairs(self.relatives) do
        if class == unitClass then
            for _, marker in pairs(markerList) do
                if self.unusedMarkers[marker] then
                    return self:SetMarkerAndRemove(unit, marker);
                end
            end
        end
    end
    return self:FindUsableMark(unit);
end

function ArenaMarker:MarkPlayers()
    if members() > 5 then return end
    if not GetRaidTargetIndex("player") then
        self:Print("Marking the group.");
    end
    -- mark self
    self:SetRaidTargetByClass("player");
    -- mark party members
    for i = 1, members() - 1 do
        self:SetRaidTargetByClass("party" .. i);
    end
end

function ArenaMarker:MarkPetWithPriority(unit)
    if not unit or not UnitExists(unit .. "pet") then return end
    if GetRaidTargetIndex(unit .. "pet") then return end

    if self.unusedMarkers[self.markerStrings[self.db.profile.petDropDownMarkerID]] and unit == "player" then
        return self:SetMarkerAndRemove(unit .. "pet", self.markerStrings[self.db.profile.petDropDownMarkerID]);
    elseif self.unusedMarkers[self.markerStrings[self.db.profile.petDropDownTwoMarkerID]] then
        return self:SetMarkerAndRemove(unit .. "pet", self.markerStrings[self.db.profile.petDropDownTwoMarkerID]);
    elseif self.unusedMarkers[self.markerStrings[self.db.profile.petDropDownThreeMarkerID]] then
        return self:SetMarkerAndRemove(unit .. "pet", self.markerStrings[self.db.profile.petDropDownThreeMarkerID]);
    end
    return self:FindUsableMark(unit .. "pet");
end

function ArenaMarker:MarkPets()
    if members() > 5 then return end
    -- mark player's pet
    self:MarkPetWithPriority("player");
    -- mark party's pets
    for i = 1, members() - 1 do
        self:MarkPetWithPriority("party" .. i);
    end
end

function ArenaMarker:RepopulateUnusedMarkers()
    -- re-populate table if user clicks remove_mark button(s)
    for i, markerValue in ipairs(self.removedMarkers) do
        if not contains(self.unusedMarkers, markerValue) then
            for j = 1, #self.markerStrings do
                if markerValue == j then
                    self.unusedMarkers[self.markerStrings[markerValue]] = markerValue;
                    removeValue(self.removedMarkers, i);
                end
            end
        end
    end
end

function ArenaMarker:RemarkOnSpecificSpells(self, ...)
    local spellsToRemarkOn = {
        ["Shadowmeld"] = 58984,
        ["Mirror Image"] = 55342,
    };
    local unit, _, spellID = ...;
    if not unit or not spellID then return end
    if not contains(spellsToRemarkOn, spellID) then return end
    if unit:sub(1, #"nameplate") == "nameplate" then return end
    if unit:sub(1, #"raid") == "raid" then return end
    if not UnitInParty(unit) then return end
    local necessaryTimeToWaitToRemark = 4;
    C_Timer.After(necessaryTimeToWaitToRemark, function()
        ArenaMarker:CheckExistingMarks();
        ArenaMarker:SetRaidTargetByClass(unit);
    end);
end

function ArenaMarker:HandleUnitSpellCastSucceeded(self, ...)
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then return end
    ArenaMarker:PetCastEventHandler(self, ...);
    ArenaMarker:RemarkOnSpecificSpells(self, ...);
end

function ArenaMarker:UnmarkPets()
    if members() > 5 then return end
    if UnitExists("pet") then
        if GetRaidTargetIndex("pet") then
            table.insert(self.removedMarkers, GetRaidTargetIndex("pet"));
            SetRaidTarget("pet", 0);
        end
    end
    for i = 1, members() - 1 do
        if UnitExists("party" .. i .. "pet") then
            if GetRaidTargetIndex("party" .. i .. "pet") then
                table.insert(self.removedMarkers, GetRaidTargetIndex("party" .. i .. "pet"));
                SetRaidTarget("party" .. i .. "pet", 0);
            end
        end
    end
    self:RepopulateUnusedMarkers();
end

function ArenaMarker:UnmarkPlayers()
    if members() > 5 then return end
    -- unmark self
    if GetRaidTargetIndex("player") then
        self:Print("Unmarking the group.");
        table.insert(self.removedMarkers, GetRaidTargetIndex("player"));
        SetRaidTarget("player", 0);
    end
    -- unmark party members
    for i = 1, members() - 1 do
        if GetRaidTargetIndex("party" .. i) then
            table.insert(self.removedMarkers, GetRaidTargetIndex("party" .. i));
            SetRaidTarget("party" .. i, 0);
        end
    end
    self:RepopulateUnusedMarkers();
end

function ArenaMarker:PetCastEventHandler(self, ...)
    local unit, _, spellID = ...;
    if not self.db.profile.markSummonedPets then return end
    if unit:sub(1, #"raid") == "raid" then return end
    for summonSpellID, summonIsAllowed in pairs(self.summons) do
        if spellID == summonSpellID and summonIsAllowed then
            C_Timer.After(0.5, function() self:MarkPetWithPriority(unit) end);
        end
    end
end

function ArenaMarker:CheckExistingMarks()
    -- reset table
    for i = 1, #self.markerStrings do
        self.unusedMarkers[self.markerStrings[i]] = i;
    end
    local function removeMarkerFromTable(unit)
        if not GetRaidTargetIndex(unit) then return end
        if not self.unusedMarkers[self.markerStrings[GetRaidTargetIndex(unit)]] then return end
        removeValue(self.unusedMarkers, self.markerStrings[GetRaidTargetIndex(unit)]);
    end

    -- update which marks are currently being used on players and pets
    removeMarkerFromTable("player");
    removeMarkerFromTable("pet");
    for i = 1, members() - 1 do
        removeMarkerFromTable("party" .. i);
        removeMarkerFromTable("party" .. i .. "pet");
    end
end

function ArenaMarker:SetSummonsToTrueAfterGates(txt)
    for region, regionText in pairs(self.translations) do
        if GetLocale() == region then
            if txt:find(regionText) then
                for i in pairs(self.summons) do
                    if not self.summons[i] then
                        table.insert(self.summonAfterGates, i);
                        self.summons[i] = true;
                    end
                end
            end
        end
    end
end

function ArenaMarker:SetSummonsToFalse()
    for i in pairs(self.summons) do
        for j = 1, #self.summonAfterGates do
            if i == self.summonAfterGates[j] then
                self.summons[i] = false;
                removeValue(self.summonAfterGates, j);
            end
        end
    end
end

function ArenaMarker:MarkPetsWhenGatesOpen(txt)
    if not self.db.profile.allowPets then return end
    for region, regionText in pairs(self.translations) do
        if GetLocale() == region then
            if txt:find(regionText) then
                self:MarkPets();
                self:CheckExistingMarks();
            end
        end
    end
end

-- small helper funcs
function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false;
end

function removeValue(table, value)
	local key = table[value];
	table[value] = nil;
	return key;
end

function ArenaMarker:IsOutOfArena()
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then
        self:SetSummonsToFalse();
    end
end

function ArenaMarker:Main(txt, ...)
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() <= 1 then return end
    self:CheckExistingMarks();
    self:MarkPlayers();
    self:MarkPetsWhenGatesOpen(txt);
    self:SetSummonsToTrueAfterGates(txt);
end