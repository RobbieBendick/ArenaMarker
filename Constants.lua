local _, core = ...;

core.addonName = "ArenaMarker";
core.removedMarkers = {};
core.summonAfterGates = {};
core.RAID_TARGET_COLORS = {
	[1] = "|c00FFFF00", -- Star (yellow)
	[2] = "|c00FF7F00", -- Circle (orange)
	[3] = "|cffd966ff", -- Diamond (purple)
	[4] = "|c0000FF00", -- Triangle (green)
	[5] = "|cffc7c7cf", -- slightly brighter gray (moon)
	[6] = "|c000080FF", -- Square (blue)
	[7] = "|c33FF0000", -- Cross (red)
	[8] = "|c00FFFFFF", -- Skull (white)
};
core.translations = {
	["enUS"] = "The Arena battle has begun!",
	["enGB"] = "The Arena battle has begun!",
	["frFR"] = "Le combat d'arène commence !",
	["deDE"] = "Der Arenakampf hat begonnen!",
	["ptBR"] = "A batalha na Arena começou!",
	["esES"] = "¡La batalla en arena ha comenzado!",
	["esMX"] = "¡La batalla en arena ha comenzado!",
	["ruRU"] = "Бой начался!",
	["zhCN"] = "竞技场的战斗开始了！",
	["zhTW"] = "競技場戰鬥開始了!",
	["koKR"] = "투기장 전투가 시작되었습니다!",
};
core.reversedMarkerValues = {
	["star"] = 8,
	["circle"] = 7,
	["diamond"] = 6,
	["triangle"] = 5,
	["moon"] = 4,
	["square"] = 3,
	["cross"] = 2,
	["skull"] = 1
};
core.markerValues = {
	["star"] = 1,
	["circle"] = 2,
	["diamond"] = 3,
	["triangle"] = 4,
	["moon"] = 5,
	["square"] = 6,
	["cross"] = 7,
	["skull"] = 8
};
core.unusedMarkers = {
	["star"] = 1,
	["circle"] = 2,
	["diamond"] = 3,
	["triangle"] = 4,
	["moon"] = 5,
	["square"] = 6,
	["cross"] = 7,
	["skull"] = 8
};
core.markerStrings = {
	"star",
	"circle",
	"diamond",
	"triangle",
	"moon",
	"square",
	"cross",
	"skull"
};
core.classes = {};
core.markerTexturePath = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_";

core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) core.Config:Player_Login(self) end,
	["CHAT_MSG_BG_SYSTEM_NEUTRAL"] = function(self, ...) AM:Main(self, ...) end,
	["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) AM:HandleUnitSpellCastSucceeded(self, ...) end,
	["ZONE_CHANGED_NEW_AREA"] = function(self) AM:IsOutOfArena(self) end,
};
local options = {
	["config"] = "/am config",
	["hide"] = "/am hide",
	["show"] = "/am show",
}
local message = "Available commands: ";
for _, slashCommand in pairs(options) do
    message = message .. slashCommand .. ", ";
end
message = message:sub(1, -3)

core.optionsHandlerTable = {
	["hide"] = function()
		if _G["LibDBIcon10_"..core.addonName]:IsShown() then
			_G["LibDBIcon10_"..core.addonName]:Hide();
		else
			core.Config:ChatFrame("Minimap icon already hidden.")
		end
		ArenaMarkerDB.hideMinimap = not _G["LibDBIcon10_"..core.addonName]:IsShown();
	end,
	["show"] = function()
		if not _G["LibDBIcon10_"..core.addonName]:IsShown() then
			_G["LibDBIcon10_"..core.addonName]:Show();
		else
			core.Config:ChatFrame("Minimap icon already shown.")
		end
		ArenaMarkerDB.hideMinimap = not _G["LibDBIcon10_"..core.addonName]:IsShown();
	end,
	["options"] = function()
		core.Config:ChatFrame(message);
	end,
	["config"] = function() core.Config.Toggle() end,
}

for key, _ in pairs(core.optionsHandlerTable) do
    table.insert(options, key);
end