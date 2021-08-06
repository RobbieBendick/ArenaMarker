--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
local Config = core.Config;
local UIConfig;
core.allowPets = true;
core.removedMarkers = {};
core.translations = {
    ["enUS"] = "The Arena battle has begun!",
    ["enGB"] = "The Arena battle has begun!",
    ["frFR"] = "Le combat d'arène commence !",
    ["deDE"] = "Der Arenakampf hat begonnen!",
    ["ptBR"] = "A batalha na Arena começou!",
    ["esES"] = "¡La batalla en arena ha comenzado!",
    ["esMX"] = "¡La batalla en arena ha comenzado!",
    ["ruRU"] = "Бой начался!",
    ["zhCN"] = "竞技场的战斗开始了！",
    ["zhTW"] = "競技場戰鬥開始了!",
    ["koKR"] = "투기장 전투가 시작되었습니다!",
}
core.marker_strings = {
	"star",
	"circle",
	"diamond",
	"triangle",
	"moon",
	"square",
	"cross",
	"skull"
}
--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:UnmarkPlayers()
    local members = GetNumGroupMembers()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members > 5 then return end
	    -- unmark self
		if GetRaidTargetIndex("player") then
			DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Unmarking the group.")
			table.insert(core.removedMarkers, GetRaidTargetIndex("player"))
			SetRaidTarget("player", 0)
		end
		-- unmark party members
		for i=1, members-1 do
			if GetRaidTargetIndex("party"..i) then
				table.insert(core.removedMarkers, GetRaidTargetIndex("party"..i))
				SetRaidTarget("party"..i, 0)
			end
		end
end

function Config:UnmarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if GetNumGroupMembers() > 5 then return end
	if UnitExists("pet") then
		if GetRaidTargetIndex("pet") then
			table.insert(core.removedMarkers, GetRaidTargetIndex("pet"))
			SetRaidTarget("pet", 0)
		end
	end
	for i=1,GetNumGroupMembers()-1 do
		if UnitExists("party"..i.."pet") then
			if GetRaidTargetIndex("party"..i.."pet") then
				table.insert(core.removedMarkers, GetRaidTargetIndex("party"..i.."pet"))
				SetRaidTarget("party"..i.."pet", 0)
			end
		end
	end
end

function Config:MarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if GetNumGroupMembers() > 5 then return end
	if UnitExists("pet") then
		if not GetRaidTargetIndex("pet") then
			findUsableMark(core.unused_markers, "pet")
		end
	end
	for i=1,GetNumGroupMembers()-1 do
		if UnitExists("party"..i.."pet") then
			if not GetRaidTargetIndex("party"..i.."pet") then
				findUsableMark(core.unused_markers, "party"..i.."pet")
			end
		end
	end
end

function Config:CreateMenu()
	UIConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent, "BasicFrameTemplateWithInset");
	UIConfig:SetSize(180, 280);
	UIConfig:SetPoint("CENTER", 150, 50);
	----------------------------------
	-- Options Title
	----------------------------------
	UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.title:ClearAllPoints();
    UIConfig.title:SetFontObject("GameFontHighlight");
	UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
	UIConfig.title:SetText("ArenaMarker Options");
	----------------------------------
	-- Check Button
	----------------------------------
	UIConfig.checkBtn1 = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	UIConfig.checkBtn1:ClearAllPoints();
	UIConfig.checkBtn1:SetPoint("CENTER", UIConfig.TitleBg, "CENTER", -15, -40);
	UIConfig.checkBtn1.text:SetText("  Mark Pets\n (when arena\n gates open)");
    UIConfig.checkBtn1.text:SetFontObject("GameFontHighlight");
    UIConfig.checkBtn1:SetChecked(true);
	UIConfig.checkBtn1:SetScript("OnClick", function() core.allowPets = UIConfig.checkBtn1:GetChecked() end);
	----------------------------------
	-- Mark Players Button
	----------------------------------
	UIConfig.markPlayersButton = CreateFrame("Button", nil, UIConfig.checkBtn1, "GameMenuButtonTemplate");
	UIConfig.markPlayersButton:SetPoint("CENTER", UIConfig.checkBtn1, "CENTER", 30, -45)
	UIConfig.markPlayersButton:SetSize(110,30)
	UIConfig.markPlayersButton:SetText("Mark Players")
	UIConfig.markPlayersButton:SetScript("OnClick", AM.MarkPlayers);
	----------------------------------
	-- Unmark Players Button
	----------------------------------
	UIConfig.unmarkPlayersButton = CreateFrame("Button", nil, UIConfig.markPlayersButton, "GameMenuButtonTemplate");
	UIConfig.unmarkPlayersButton:SetPoint("CENTER", UIConfig.markPlayersButton, "CENTER", 0, -45)
	UIConfig.unmarkPlayersButton:SetSize(110,30)
	UIConfig.unmarkPlayersButton:SetText("Unmark Players")
	UIConfig.unmarkPlayersButton:SetScript("OnClick", Config.UnmarkPlayers);
	----------------------------------
	-- Mark Pets Button
	----------------------------------
	UIConfig.markPetsButton = CreateFrame("Button", nil, UIConfig.unmarkPlayersButton, "GameMenuButtonTemplate");
	UIConfig.markPetsButton:SetPoint("CENTER", UIConfig.unmarkPlayersButton, "CENTER", 0, -45)
	UIConfig.markPetsButton:SetSize(110,30)
	UIConfig.markPetsButton:SetText("Mark Pets")
	UIConfig.markPetsButton:SetScript("OnClick", Config.MarkPets);
	----------------------------------
	-- Unmark Pets Button
	----------------------------------
	UIConfig.unmarkPetsButton = CreateFrame("Button", nil, UIConfig.markPetsButton, "GameMenuButtonTemplate");
	UIConfig.unmarkPetsButton:SetPoint("CENTER", UIConfig.markPetsButton, "CENTER", 0, -45)
	UIConfig.unmarkPetsButton:SetSize(110,30)
	UIConfig.unmarkPetsButton:SetText("Unmark Pets")
	UIConfig.unmarkPetsButton:SetScript("OnClick", Config.UnmarkPets);

	UIConfig:Hide();
	return UIConfig;
end

local update = CreateFrame("FRAME")
local function removedMarkHandler()
    if not core.removedMarkers then return end
	for i,v in pairs(core.removedMarkers) do
		if not contains(core.unused_markers, v) then
			-- re-populate table if user clicks remove_mark button(s)
			for j=1,#core.marker_strings do
				if v == j then
					core.unused_markers[core.marker_strings[v]] = v;
					removeValue(core.removedMarkers, i);
				end
			end
		end
    end
end
update:SetScript("OnUpdate", removedMarkHandler)

local function login()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: /am for additional options.")
end

enterWorld = CreateFrame("FRAME");
enterWorld:RegisterEvent("PLAYER_LOGIN");
enterWorld:SetScript("OnEvent", login);

local function init()
    SLASH_ARENAMARKER1 = "/am";
    SlashCmdList.ARENAMARKER = core.Config.Toggle;

end
local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", init);