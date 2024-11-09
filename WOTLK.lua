local _, addon = ...;
local ArenaMarker = LibStub("AceAddon-3.0"):GetAddon(addon.name);
if WOW_PROJECT_ID ~= WOW_PROJECT_WRATH_CLASSIC then return end

ArenaMarker.relatives = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle", "star" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond", "star" },
    ["HUNTER"] = { "triangle" },
    ["MAGE"] = { "moon", "square" },
    ["SHAMAN"] = { "square", "moon" },
    ["WARRIOR"] = { "cross", "skull" },
    ["DEATHKNIGHT"] = { "cross", "skull" },
    ["PRIEST"] = { "skull", "moon" },
};

ArenaMarker.defaultClassMarkers = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle", "star" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond", "star" },
    ["HUNTER"] = { "triangle" },
    ["MAGE"] = { "moon", "square" },
    ["SHAMAN"] = { "square", "moon" },
    ["WARRIOR"] = { "cross", "skull" },
    ["DEATHKNIGHT"] = { "cross", "skull" },
    ["PRIEST"] = { "skull", "moon" },
};

-- false = dont mark in arena starting zone
ArenaMarker.summons = {
    [883] = true,   -- Call Pet
    [34433] = true, -- Shadowfiend
    [31687] = true, -- Water Elemental
    [46584] = true, -- Ghoul
    [49206] = true, -- Gargoyle
    [688] = false,  -- Imp
    [691] = false,  -- Felhunter
    [697] = false,  -- Voidwalker
    [712] = false,  -- Succubus
};
