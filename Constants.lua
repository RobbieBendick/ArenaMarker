local _, addon = ...;
local ArenaMarker = _G.LibStub("AceAddon-3.0"):NewAddon("ArenaMarker", "AceConsole-3.0", "AceEvent-3.0");
addon.name = "ArenaMarker";
ArenaMarker.name = "ArenaMarker";
ArenaMarker.removedMarkers = {};
ArenaMarker.summonAfterGates = {};
ArenaMarker.RAID_TARGET_COLORS = {
	[1] = "|c00FFFF00", -- Star (yellow)
	[2] = "|c00FF7F00", -- Circle (orange)
	[3] = "|cffd966ff", -- Diamond (purple)
	[4] = "|c0000FF00", -- Triangle (green)
	[5] = "|cffc7c7cf", -- slightly brighter gray (moon)
	[6] = "|c000080FF", -- Square (blue)
	[7] = "|c33FF0000", -- Cross (red)
	[8] = "|c00FFFFFF", -- Skull (white)
};
ArenaMarker.translations = {
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
ArenaMarker.markerValues = {
	["star"] = 1,
	["circle"] = 2,
	["diamond"] = 3,
	["triangle"] = 4,
	["moon"] = 5,
	["square"] = 6,
	["cross"] = 7,
	["skull"] = 8
};
ArenaMarker.unusedMarkers = {
	["star"] = 1,
	["circle"] = 2,
	["diamond"] = 3,
	["triangle"] = 4,
	["moon"] = 5,
	["square"] = 6,
	["cross"] = 7,
	["skull"] = 8
};
ArenaMarker.markerStrings = {
	"star",
	"circle",
	"diamond",
	"triangle",
	"moon",
	"square",
	"cross",
	"skull"
};
ArenaMarker.classes = {};
ArenaMarker.markerTexturePath = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_";

local options = {
	["config"] = "/am config",
	["hide"] = "/am hide",
	["show"] = "/am show",
}

local function createOptionsMessage()
	local optionsMessage = "Available commands: ";
	for _, slashCommand in pairs(options) do
		optionsMessage = optionsMessage .. slashCommand .. ", ";
	end
	optionsMessage = optionsMessage:sub(1, -3);
	return optionsMessage;
end

local optionsMessage = createOptionsMessage();

ArenaMarker.optionsHandlerTable = {
	["hide"] = function()
		if _G["LibDBIcon10_"..ArenaMarker.name]:IsShown() then
			_G["LibDBIcon10_"..ArenaMarker.name]:Hide();
		else
			ArenaMarker:Print("Minimap icon already hidden.");
		end
		ArenaMarker.hideMinimap = not _G["LibDBIcon10_"..ArenaMarker.name]:IsShown();
	end,
	["show"] = function()
		if not _G["LibDBIcon10_"..ArenaMarker.name]:IsShown() then
			_G["LibDBIcon10_"..ArenaMarker.name]:Show();
		else
			ArenaMarker:Print("Minimap icon already shown.")
		end
		ArenaMarker.db.profile.hideMinimap = not _G["LibDBIcon10_"..ArenaMarker.name]:IsShown();
	end,
	["options"] = function()
		ArenaMarker:Print(optionsMessage);
	end,
	["config"] = function()
		ArenaMarker:Toggle();
	end,
}

for key, _ in pairs(ArenaMarker.optionsHandlerTable) do
    table.insert(options, key);
end