local _, addon = ...;
local ArenaMarker = LibStub("AceAddon-3.0"):GetAddon(addon.name);
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

ArenaMarker.relatives = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond" },
    ["DEMONHUNTER"] = { "diamond" },
    ["HUNTER"] = { "triangle" },
    ["MONK"] = { "triangle" },
    ["EVOKER"] = { "triangle" },
    ["MAGE"] = { "moon" },
    ["SHAMAN"] = { "square" },
    ["WARRIOR"] = { "cross" },
    ["DEATHKNIGHT"] = { "cross" },
    ["PRIEST"] = { "skull" }
};

ArenaMarker.defaultClassMarkers = {
    ["ROGUE"] = { "star" },
    ["DRUID"] = { "circle" },
    ["WARLOCK"] = { "diamond" },
    ["PALADIN"] = { "diamond" },
    ["DEMONHUNTER"] = { "diamond" },
    ["HUNTER"] = { "triangle" },
    ["MONK"] = { "triangle" },
    ["EVOKER"] = { "triangle" },
    ["MAGE"] = { "moon" },
    ["SHAMAN"] = { "square" },
    ["WARRIOR"] = { "cross" },
    ["DEATHKNIGHT"] = { "cross" },
    ["PRIEST"] = { "skull" }
};

-- false = dont mark in arena starting zone
ArenaMarker.summons = {
    [883] = true,   -- Call Pet 1
    [83242] = true, -- Call pet 2
    [83243] = true, -- Call pet 3
    [83244] = true, -- Call pet 4
    [83245] = true, -- Call pet 5
    [34433] = true, -- Shadowfiend
    [31687] = true, -- Water Elemental
    [688] = false,  -- Imp
    [691] = false,  -- Felhunter
    [697] = false,  -- Voidwalker
    [712] = false,  -- Succubus
};
