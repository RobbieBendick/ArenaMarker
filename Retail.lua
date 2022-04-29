local _, core = ...;

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

core.relatives = {
    ["ROGUE"] = "star",
    ["DRUID"] = "circle",
    ["WARLOCK"] = "diamond",
    ["PALADIN"] = "diamond",
    ["DEMONHUNTER"] = "diamond",
    ["HUNTER"] = "triangle",
    ["MONK"] = "triangle",
    ["MAGE"] = "moon",
    ["SHAMAN"] = "square",
    ["WARRIOR"] = "cross",
    ["DEATHKNIGHT"] = "cross",
    ["PRIEST"] = "skull"
}
core.summons = {
    [883] = 1, -- Call Pet 1
    [83242] = 1, -- Call pet 2
    [83243] = 1, -- Call pet 3
    [83244] = 1, -- Call pet 4
    [83245] = 1, -- Call pet 5
    [34433] = 1, -- Shadowfiend
    [31687] = 1, -- Water Elemental
    [688] = 0, -- Imp
    [691] = 0, -- Felhunter
    [697] = 0, -- Voidwalker
    [712] = 0, -- Succubus
}
