local _, core = ...;

if WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return end

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
core.summons = {
    [883] = 1, -- Call Pet
    [34433] = 1, -- Shadowfiend
    [31687] = 1, -- Water Elemental
    [688] = 0, -- Imp
    [691] = 0, -- Felhunter
    [697] = 0, -- Voidwalker
    [712] = 0, -- Succubus
}
