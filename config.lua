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

core.summons = {
	31687, -- Water Elemental
	883, -- Call Pet
}

--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
	ArenaMarkerDropDown:SetShown(menu:IsShown())
end

function Config:ChatFrame(t)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: "..t)
end

function Config:UnmarkPlayers()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
	-- unmark self
	if GetRaidTargetIndex("player") then
		Config:ChatFrame("Unmarking the group.")
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
	UIConfig:SetSize(180, 355);
	UIConfig:SetPoint("CENTER", 150, 50);

	-- Make Menu Movable
	UIConfig:SetMovable(true);
	UIConfig:EnableMouse(true);
	UIConfig:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true;
		end
	end)
	UIConfig:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end)
	UIConfig:SetScript("OnHide", function(self)
		if self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end)
	UIConfig.CloseButton:SetScript("OnClick", function ()
		ArenaMarkerConfig:Hide();
		ArenaMarkerDropDown:Hide();
	end)
	-- Options Title
	UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.title:ClearAllPoints();
    UIConfig.title:SetFontObject("GameFontHighlight");
	UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
	UIConfig.title:SetText("|cff33ff99ArenaMarker|r Options");

	-- Check Button
	UIConfig.markPetsCheckButton = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	UIConfig.markPetsCheckButton:ClearAllPoints();
	UIConfig.markPetsCheckButton:SetPoint("CENTER", UIConfig.TitleBg, "CENTER", -45, -40);
	UIConfig.markPetsCheckButton.text:SetText("        Mark Pets\n      (when arena\n     gates open)");
    UIConfig.markPetsCheckButton.text:SetFontObject("GameFontHighlight");
	UIConfig.markPetsCheckButton:SetChecked(ArenaMarkerDB.allowPets);
	UIConfig.markPetsCheckButton:SetScript("OnClick", function() ArenaMarkerDB.allowPets = UIConfig.markPetsCheckButton:GetChecked() end);

	-- Pet-Summon Check Button
	UIConfig.markPetsOnSummonCheckButton = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	UIConfig.markPetsOnSummonCheckButton:ClearAllPoints();
	UIConfig.markPetsOnSummonCheckButton:SetPoint("CENTER", UIConfig.markPetsCheckButton, "CENTER", 0, -45);
	UIConfig.markPetsOnSummonCheckButton.text:SetText("  Mark Pets\n when summoned \n (|cff69CCF0MAGE|r/|cffABD473HUNTER|r)");
	UIConfig.markPetsOnSummonCheckButton.text:SetFontObject("GameFontHighlight");
	UIConfig.markPetsOnSummonCheckButton:SetChecked(ArenaMarkerDB.markSummonedPets);
	UIConfig.markPetsOnSummonCheckButton:SetScript("OnClick", function() ArenaMarkerDB.markSummonedPets = UIConfig.markPetsOnSummonCheckButton:GetChecked() end);

	-- Mark Players Button
	UIConfig.markPlayersButton = self:CreateButton(UIConfig.markPetsOnSummonCheckButton, "Mark Players", AM.MarkPlayers);
	UIConfig.markPlayersButton:SetPoint("CENTER", UIConfig.markPetsOnSummonCheckButton, "CENTER",  58, -45);
	
	-- Unmark Players Button
	UIConfig.unmarkPlayersButton = self:CreateButton(UIConfig.markPlayersButton, "Unmark Players", Config.UnmarkPlayers);

	-- Mark Pets Button
	UIConfig.markPetsButton = self:CreateButton(UIConfig.unmarkPlayersButton, "Mark Pets", AM.MarkPets);

	-- Unmark Pets Button
	UIConfig.unmarkPetsButton = self:CreateButton(UIConfig.markPetsButton, "Unmark Pets", Config.UnmarkPets);

	local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i=#core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownMarkerID = j;
				ArenaMarkerDB.petDropDownClickID = self:GetID();
				break;
			end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(self.value)
		setDropdownCheck(self:GetID())
	end
	function ArenaMarkerDropDownMenu(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = ArenaMarker_Pet_DropDown_OnClick
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean
			if i ~= nil then
				local texturePath = [[Interface\AddOns\ArenaMarker\icons\UI-RaidTargetingIcon_]];
				info.icon = texturePath..i;
			else
				info.icon = nil;
			end
			return UIDropDownMenu_AddButton(info)
		end
		for i=#core.marker_strings,1,-1 do
			AddMark(core.marker_strings[i], false, i)
		end
		AddMark("none", false, nil)
	end
	UIConfig.dropDownTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.dropDownTitle:SetText("Prioritized Pet Mark");
	UIConfig.dropDownTitle:SetPoint("CENTER", UIConfig.unmarkPetsButton, 0, -32);
	UIConfig.dropDown = CreateFrame("Frame", "ArenaMarkerDropDown", UIParent, "UIDropDownMenuTemplate");
	UIConfig.dropDown:SetPoint("CENTER", UIConfig.dropDownTitle, 0, -23);

	function setDropdownText(v) return UIDropDownMenu_SetText(UIConfig.dropDown, v) end
	function setDropdownCheck(v) return UIDropDownMenu_SetSelectedID(UIConfig.dropDown, v) end

	UIDropDownMenu_SetWidth(UIConfig.dropDown, 93)
	UIDropDownMenu_Initialize(UIConfig.dropDown, ArenaMarkerDropDownMenu)
	UIDropDownMenu_SetSelectedID(UIConfig.dropDown, ArenaMarkerDB.petDropDownClickID)

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

function Config:Player_Login()
	if not ArenaMarkerDB then
		ArenaMarkerDB = {};
		ArenaMarkerDB["allowPets"] = true;
		ArenaMarkerDB["markSummonedPets"] = false;
		ArenaMarkerDB["petDropDownMarkerID"] = -1;
		ArenaMarkerDB["petDropDownClickID"] = -1;
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r by |cff69CCF0Mageiden|r. Type |cff33ff99/am|r for additional options.");
end
local enterWorld = CreateFrame("Frame");
enterWorld:RegisterEvent("PLAYER_LOGIN");
enterWorld:SetScript("OnEvent", Config.Player_Login);

function Config:Addon_Loaded()
    SLASH_ARENAMARKER1 = "/am";
    SlashCmdList.ARENAMARKER = Config.Toggle;
end
local addonLoadedEvent = CreateFrame("Frame");
addonLoadedEvent:RegisterEvent("ADDON_LOADED");
addonLoadedEvent:SetScript("OnEvent", Config.Addon_Loaded);