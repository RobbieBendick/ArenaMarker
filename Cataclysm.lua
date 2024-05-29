local _, core = ...;
local TEMP_WOW_CATA_CLASSIC_ID = 14;

if WOW_PROJECT_ID ~= TEMP_WOW_CATA_CLASSIC_ID then return end

core.relatives = {
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

core.defaultClassMarkers = {
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
core.summons = {
    [883] = true,   -- Call Pet
    [34433] = true, -- Shadowfiend
    [31687] = true, -- Water Elemental
    [46584] = true, -- Ghoul
    [688] = false,  -- Imp
    [691] = false,  -- Felhunter
    [697] = false,  -- Voidwalker
    [712] = false,  -- Succubus
};
