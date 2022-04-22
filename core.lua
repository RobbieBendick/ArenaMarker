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

function findUsableMark(table, target)
    local marker = "";
    for k, v in pairs(table) do
        if v ~= nil then
            marker = k;
            break
        end
    end
    SetRaidTarget(target, table[marker]);
    removeValue(table, marker);
end

function setRaidTargetByClass(target, ...)
    local _, englishClass, _ = UnitClass(target);
    for k, v in pairs(core.relatives) do
        if k == englishClass then
            if core.unused_markers[v] then
                SetRaidTarget(target, core.unused_markers[v]);
                removeValue(core.unused_markers, v);
                break
            else
                findUsableMark(core.unused_markers, target);
                break
            end
        end
    end
end

function AM:MarkPlayers()
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() > 5 then return end
    -- mark self
    if not GetRaidTargetIndex("player") then
        Config:ChatFrame("Marking the group.");
        setRaidTargetByClass("player");
    end
    -- mark party members
    for i = 1, members() - 1 do
        if not GetRaidTargetIndex("party" .. i) then
            setRaidTargetByClass("party" .. i);
        end
    end
end

function AM:MarkPetWithPriority(unit)
    if not unit or not UnitExists(unit .. "pet") then return end
    if GetRaidTargetIndex(unit .. "pet") then return end
    local function setMark(markerID)
        SetRaidTarget(unit .. "pet", markerID);
        removeValue(core.unused_markers, core.marker_strings[markerID]);
    end

    local ans;
    if core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownMarkerID]] and unit == "player" then
        ans = setMark(ArenaMarkerDB.petDropDownMarkerID);
    elseif core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownTwoMarkerID]] then
        ans = setMark(ArenaMarkerDB.petDropDownTwoMarkerID);
    elseif core.unused_markers[core.marker_strings[ArenaMarkerDB.petDropDownThreeMarkerID]] then
        ans = setMark(ArenaMarkerDB.petDropDownThreeMarkerID);
    else
        ans = findUsableMark(core.unused_markers, unit .. "pet");
    end
    return ans;
end

function AM:MarkPets()
    -- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() > 5 then return end
    -- Mark Player's Pet
    AM.MarkPetWithPriority(self, "player");
    -- Mark Party's Pets
    for i = 1, members() - 1 do
        AM.MarkPetWithPriority(self, "party" .. i);
    end
end

local petCastEvent = CreateFrame("FRAME")
petCastEvent:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

function AM:PetCastEventHandler(caster, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if not ArenaMarkerDB.markSummonedPets then return end
    if caster == "raid1" then return end
    local _, spellID = ...;
    for key, val in pairs(core.summons) do
        if spellID == key and val > 0 then
            C_Timer.After(0.5, function() AM.MarkPetWithPriority(self, caster) end);
        end
    end
end

function AM:CheckExistingMarksOnPlayers()
    -- reset table
    core.unused_markers = {
        ["star"] = 1,
        ["circle"] = 2,
        ["diamond"] = 3,
        ["triangle"] = 4,
        ["moon"] = 5,
        ["square"] = 6,
        ["cross"] = 7,
        ["skull"] = 8
    }
    --update which marks are currently being used on players(not pets)
    if GetRaidTargetIndex("player") then
        local marker = core.marker_strings[GetRaidTargetIndex("player")];
        if core.unused_markers[marker] then
            core.unused_markers[marker] = nil;
        end
    end
    for i = 1, members() - 1 do
        if GetRaidTargetIndex("party" .. i) then
            local marker = core.marker_strings[GetRaidTargetIndex("party" .. i)];
            if core.unused_markers[marker] then
                core.unused_markers[marker] = nil;
            end
        end
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

function AM:SetSummonsToOne(self)
    core.summons = {
        [883] = 1, -- Call Pet
        [34433] = 1, -- Shadowfiend
        [697] = 1, -- Voidwalker
        [691] = 1, -- Felhunter
        [31687] = 1, -- Water Elemental
    }
end

function AM:SetSummonsToZero(self)
    core.summons = {
        [883] = 1, -- Call Pet
        [34433] = 1, -- Shadowfiend
        [697] = 0, -- Voidwalker
        [691] = 0, -- Felhunter
        [31687] = 1, -- Water Elemental
    }
end

function AM:MarkPetsWhenGatesOpen(self, txt, ...)
    if not ArenaMarkerDB.allowPets then return end
    for k, v in pairs(core.translations) do
        if GetLocale() == k then
            if string.find(txt, v) then
                AM.MarkPets();
                AM.SetSummonsToOne();
            end
        end
    end
end

function AM:IsOutOfArena()
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then
        AM.SetSummonsToZero();
    end
end

function AM:Main(txt, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
    if members() <= 1 then return end
    AM.CheckExistingMarksOnPlayers();
    AM.MarkPlayers();
    AM.MarkPetsWhenGatesOpen(self, nil, txt, ...);
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
