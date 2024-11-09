local _, addon = ...;
local ArenaMarker = LibStub("AceAddon-3.0"):GetAddon(addon.name);

if WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return end

ArenaMarker.relatives = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond" },
    ["HUNTER"] = { "triangle" },
    ["MAGE"] = { "moon" },
    ["SHAMAN"] = { "square" },
    ["WARRIOR"] = { "cross" },
    ["PRIEST"] = { "skull" }
};

ArenaMarker.defaultClassMarkers = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond" },
    ["HUNTER"] = { "triangle" },
    ["MAGE"] = { "moon" },
    ["SHAMAN"] = { "square" },
    ["WARRIOR"] = { "cross" },
    ["PRIEST"] = { "skull" }
};

-- false = dont mark in arena starting zone
ArenaMarker.summons = {
    [883] = true,   -- Call Pet
    [34433] = true, -- Shadowfiend
    [31687] = true, -- Water Elemental
    [688] = false,  -- Imp
    [691] = false,  -- Felhunter
    [697] = false,  -- Voidwalker
    [712] = false,  -- Succubus
};
