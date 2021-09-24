--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
local Config = core.Config;
local UIConfig;
members = GetNumGroupMembers;
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
	ArenaMarkerDropDown:SetShown(menu:IsShown())
end

function Config:UnmarkPlayers()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
	-- unmark self
	if GetRaidTargetIndex("player") then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Unmarking the group.")
		table.insert(core.removedMarkers, GetRaidTargetIndex("player"))
		SetRaidTarget("player", 0)
	end
	-- unmark party members
	for i=1, members()-1 do
		if GetRaidTargetIndex("party"..i) then
			table.insert(core.removedMarkers, GetRaidTargetIndex("party"..i))
			SetRaidTarget("party"..i, 0)
		end
	end
end

function Config:UnmarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
	if UnitExists("pet") then
		if GetRaidTargetIndex("pet") then
			table.insert(core.removedMarkers, GetRaidTargetIndex("pet"))
			SetRaidTarget("pet", 0)
		end
	end
	for i=1,members()-1 do
		if UnitExists("party"..i.."pet") then
			if GetRaidTargetIndex("party"..i.."pet") then
				table.insert(core.removedMarkers, GetRaidTargetIndex("party"..i.."pet"))
				SetRaidTarget("party"..i.."pet", 0)
			end
		end
	end
end

function Config:CreateButton(relativeFrame, buttonText, funcName)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -45);
	btn:SetSize(110,30);
	btn:SetText(buttonText);
	btn:SetScript("OnClick", funcName);
	return btn
end

function Config:CreateMenu()
	-- Menu
	UIConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent, "BasicFrameTemplateWithInset");
	UIConfig:SetSize(180, 325);
	UIConfig:SetPoint("CENTER", 150, 50);

	UIConfig.CloseButton:SetScript("OnClick", function ()
		ArenaMarkerConfig:Hide()
		ArenaMarkerDropDown:Hide()
	end)

	-- Options Title
	UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.title:ClearAllPoints();
    UIConfig.title:SetFontObject("GameFontHighlight");
	UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
	UIConfig.title:SetText("ArenaMarker Options");

	-- Check Button
	UIConfig.markPetsCheckButton = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	UIConfig.markPetsCheckButton:ClearAllPoints();
	UIConfig.markPetsCheckButton:SetPoint("CENTER", UIConfig.TitleBg, "CENTER", -15, -40);
	UIConfig.markPetsCheckButton.text:SetText("  Mark Pets\n (when arena\n gates open)");
	UIConfig.markPetsCheckButton:SetChecked(ArenaMarkerDB.allowPets);
    UIConfig.markPetsCheckButton.text:SetFontObject("GameFontHighlight");
	UIConfig.markPetsCheckButton:SetScript("OnClick", function() ArenaMarkerDB.allowPets = UIConfig.markPetsCheckButton:GetChecked() end);

	-- Mark Players Button
	UIConfig.markPlayersButton = self:CreateButton(UIConfig.markPetsCheckButton, "Mark Players", AM.MarkPlayers);
	UIConfig.markPlayersButton:SetPoint("CENTER", UIConfig.markPetsCheckButton, "CENTER",  28, -45);
	
	-- Unmark Players Button
	UIConfig.unmarkPlayersButton = self:CreateButton(UIConfig.markPlayersButton, "Unmark Players", Config.UnmarkPlayers);

	-- Mark Pets Button
	UIConfig.markPetsButton = self:CreateButton(UIConfig.unmarkPlayersButton, "Mark Pets", AM.MarkPets);

	-- Unmark Pets Button
	UIConfig.unmarkPetsButton = self:CreateButton(UIConfig.markPetsButton, "Unmark Pets", Config.UnmarkPets);

	local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
		setDropdownText(self.value)
		setDropdownCheck(self:GetID())
		if self:GetID() == 9 then
			ArenaMarkerDB.petDropDownID = -1;
		else
			ArenaMarkerDB.petDropDownID = self:GetID()
		end
	end
	   function ArenaMarkerDropDownMenu(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = ArenaMarker_Pet_DropDown_OnClick
		local function AddMark(marker, boolean)
			info.text, info.checked = marker, boolean
			return UIDropDownMenu_AddButton(info)
		end
		for i=1,#core.marker_strings do
			AddMark(core.marker_strings[i], false)
		end
		AddMark("none", false)
	end
	UIConfig.dropDownTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.dropDownTitle:SetText("Prioritized Pet Mark")
	UIConfig.dropDownTitle:SetPoint("CENTER", UIConfig.dropDown, 153, -56)
	UIConfig.dropDown = CreateFrame("Frame", "ArenaMarkerDropDown", UIParent, "UIDropDownMenuTemplate")
	UIConfig.dropDown:SetPoint("CENTER", UIConfig.dropDownTitle, 0, -27)

	function setDropdownText(arg1)
		return UIDropDownMenu_SetText(UIConfig.dropDown, arg1)
	end

	function setDropdownCheck(arg1)
		return UIDropDownMenu_SetSelectedID(UIConfig.dropDown, arg1)
	end
	UIDropDownMenu_SetWidth(UIConfig.dropDown, 93)
	UIDropDownMenu_Initialize(UIConfig.dropDown, ArenaMarkerDropDownMenu)
	UIDropDownMenu_SetSelectedID(UIConfig.dropDown, ArenaMarkerDB.petDropDownID)

	UIConfig:Hide();
	return UIConfig;
end

-- Escape key functionality
tinsert(UISpecialFrames, "ArenaMarkerConfig")
tinsert(UISpecialFrames, "ArenaMarkerDropDown")

local update = CreateFrame("FRAME")
local function removedMarkHandler()
	--exit function if removedMarkers doesnt have a valid value
	local c = 0;
	for _,k in pairs(core.removedMarkers) do if k ~= nil then c = c + 1 end end if c == 0 then return end
	for i,v in pairs(core.removedMarkers) do
		if not contains(core.unused_markers, v) then
			-- re-populate table if user clicks remove_mark button(s)
			for j=1,#core.marker_strings do
				if v == j then
					core.unused_markers[core.marker_strings[j]] = j;
					removeValue(core.removedMarkers, i);
				end
			end
		end
    end
end
update:SetScript("OnUpdate", removedMarkHandler)

local function login(event)
	if not ArenaMarkerDB then
		ArenaMarkerDB = {};
		ArenaMarkerDB["allowPets"] = true;
		ArenaMarkerDB["petDropDownID"] = -1;
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: /am for additional options.");
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