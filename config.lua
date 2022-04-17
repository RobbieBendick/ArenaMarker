--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
local Config = core.Config;
local UIConfig;
members = GetNumGroupMembers;
core.removed_markers = {};
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
	34433, -- Shadowfiend
}
core.texture_path = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_";
MENU_WIDTH, MENU_HEIGHT, LARGE_MENU_HEIGHT = 180, 410, 470;
--------------------------------------
-- Config functions
--------------------------------------
function Config:SmallMenu()
	UIConfig.dropDownTitleThree:Hide();
	ArenaMarkerDropDownThree:Hide();
	UIConfig:SetSize(MENU_WIDTH, MENU_HEIGHT);
end

function Config:LargeMenu()
	UIConfig.dropDownTitleThree:Show();
	ArenaMarkerDropDownThree:Show();
	UIConfig:SetSize(MENU_WIDTH, LARGE_MENU_HEIGHT);
end

function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
	ArenaMarkerDropDown:SetShown(menu:IsShown());
	ArenaMarkerDropDownTwo:SetShown(menu:IsShown());
	ArenaMarkerDropDownThree:SetShown(menu:IsShown());
	if ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 and menu:IsShown() then
		Config.SmallMenu();
	end
	if not (ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1) and menu:IsShown() then
		Config.LargeMenu();
	end
end

function Config:ChatFrame(t)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: " .. t);
end

function Config:UnmarkPlayers()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
	-- unmark self
	if GetRaidTargetIndex("player") then
		Config:ChatFrame("Unmarking the group.");
		table.insert(core.removed_markers, GetRaidTargetIndex("player"));
		SetRaidTarget("player", 0);
	end
	-- unmark party members
	for i = 1, members() - 1 do
		if GetRaidTargetIndex("party" .. i) then
			table.insert(core.removed_markers, GetRaidTargetIndex("party" .. i));
			SetRaidTarget("party" .. i, 0);
		end
	end
end

function Config:UnmarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if members() > 5 then return end
	if UnitExists("pet") then
		if GetRaidTargetIndex("pet") then
			table.insert(core.removed_markers, GetRaidTargetIndex("pet"));
			SetRaidTarget("pet", 0);
		end
	end
	for i = 1, members() - 1 do
		if UnitExists("party" .. i .. "pet") then
			if GetRaidTargetIndex("party" .. i .. "pet") then
				table.insert(core.removed_markers, GetRaidTargetIndex("party" .. i .. "pet"));
				SetRaidTarget("party" .. i .. "pet", 0);
			end
		end
	end
end

function Config:CreateButton(relativeFrame, buttonText, funcName)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -45);
	btn:SetSize(110, 30);
	btn:SetText(buttonText);
	btn:SetScript("OnClick", funcName);
	return btn
end

function Config:CreateDropdownTitle(relativeFrame, dropText)
	local dropTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	dropTitle:SetText(dropText);
	dropTitle:SetPoint("CENTER", relativeFrame, 0, -32);
	return dropTitle;
end

function Config:CreateDropdownIcon(relativeFrame, textureName)
	local dropIcon = UIConfig:CreateTexture(textureName, "MEDIUM", nil, 2);
	dropIcon:SetPoint("LEFT", relativeFrame, 25, 2);
	dropIcon:SetSize(16, 16);
	return dropIcon;
end

function Config:InitDropdown(dropdown, menu, clickID, markerID, funcName)
	UIDropDownMenu_SetWidth(dropdown, 93);
	UIDropDownMenu_Initialize(dropdown, menu);
	UIDropDownMenu_SetSelectedID(dropdown, clickID);
	funcName(markerID);
end

function Config:CreateMenu()
	-- Menu
	UIConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent, "BasicFrameTemplateWithInset");
	UIConfig:SetSize(MENU_WIDTH, MENU_HEIGHT);
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

	-- Options Close-Button
	UIConfig.CloseButton:SetScript("OnClick", Config.Toggle);

	-- Options Title
	UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.title:ClearAllPoints();
	UIConfig.title:SetFontObject("GameFontHighlight");
	UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
	UIConfig.title:SetText("|cff33ff99ArenaMarker|r Options");

	-- Mark Pets Check Button
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
	UIConfig.markPlayersButton:SetPoint("CENTER", UIConfig.markPetsOnSummonCheckButton, "CENTER", 58, -45);

	-- Unmark Players Button
	UIConfig.unmarkPlayersButton = self:CreateButton(UIConfig.markPlayersButton, "Unmark Players", Config.UnmarkPlayers);

	-- Mark Pets Button
	UIConfig.markPetsButton = self:CreateButton(UIConfig.unmarkPlayersButton, "Mark Pets", AM.MarkPets);

	-- Unmark Pets Button
	UIConfig.unmarkPetsButton = self:CreateButton(UIConfig.markPetsButton, "Unmark Pets", Config.UnmarkPets);

	-- Pet-Priority Dropdown
	local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownMarkerID = j;
				ArenaMarkerDB.petDropDownClickID = self:GetID();
				break
				; end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(UIConfig.dropDown, self.value);
		setDropdownCheck(UIConfig.dropDown, self:GetID());
		setDropdownIcon(j);
	end

	function ArenaMarkerDropDownMenu(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = ArenaMarker_Pet_DropDown_OnClick
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean
			if i ~= nil then
				if i == ArenaMarkerDB.petDropDownThreeMarkerID or i == ArenaMarkerDB.petDropDownTwoMarkerID then
					info.disabled = true;
				else
					info.disabled = false;
				end
				info.icon = core.texture_path .. i;
			else
				info.icon = nil;
				info.disabled = false;
			end
			return UIDropDownMenu_AddButton(info);
		end

		for i = #core.marker_strings, 1, -1 do
			AddMark(core.marker_strings[i], false, i);
		end
		AddMark("none", false, nil);
	end

	function setDropdownText(dropdown, v) return UIDropDownMenu_SetText(dropdown, v) end

	function setDropdownCheck(dropdown, v) return UIDropDownMenu_SetSelectedID(dropdown, v) end

	function setDropdownIcon(j) if j == -1 then return UIConfig.dropDownIcon:SetTexture(nil) end return UIConfig.dropDownIcon:SetTexture(core.texture_path .. j) end

	function setDropdownIconTwo(j) if j == -1 then return UIConfig.dropDownIconTwo:SetTexture(nil) end return UIConfig.dropDownIconTwo:SetTexture(core.texture_path .. j) end

	function setDropdownIconThree(j) if j == -1 then return UIConfig.dropDownIconThree:SetTexture(nil) end return UIConfig.dropDownIconThree:SetTexture(core.texture_path .. j) end

	UIConfig.dropDownTitle = self:CreateDropdownTitle(UIConfig.unmarkPetsButton, "Self-Pet Mark");
	UIConfig.dropDown = CreateFrame("Frame", "ArenaMarkerDropDown", UIParent, "UIDropDownMenuTemplate");
	UIConfig.dropDown:SetPoint("CENTER", UIConfig.dropDownTitle, 0, -23);
	UIConfig.dropDownIcon = self:CreateDropdownIcon(UIConfig.dropDown, "ArenaMarkerIcon");

	--Second Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Two_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownTwoMarkerID = j;
				ArenaMarkerDB.petDropDownTwoClickID = self:GetID();
				if i == 9 and ArenaMarkerDB.petDropDownThreeMarkerID == -1 then
					Config.SmallMenu();
				else
					Config.LargeMenu();
				end
				break
				; end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(UIConfig.dropDownTwo, self.value);
		setDropdownCheck(UIConfig.dropDownTwo, self:GetID());
		setDropdownIconTwo(j);
	end

	function ArenaMarkerDropDownMenuTwo(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = ArenaMarker_Pet_DropDown_Two_OnClick
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean
			if i ~= nil then
				if i == ArenaMarkerDB.petDropDownThreeMarkerID or i == ArenaMarkerDB.petDropDownMarkerID then
					info.disabled = true;
				else
					info.disabled = false;
				end
				info.icon = core.texture_path .. i;
			else
				info.icon = nil;
				info.disabled = false;
			end
			return UIDropDownMenu_AddButton(info);
		end

		for i = #core.marker_strings, 1, -1 do
			AddMark(core.marker_strings[i], false, i);
		end
		AddMark("none", false, nil);
	end

	UIConfig.dropDownTitleTwo = self:CreateDropdownTitle(UIConfig.dropDown, "Party-Pet Mark");
	UIConfig.dropDownTwo = CreateFrame("Frame", "ArenaMarkerDropDownTwo", UIParent, "UIDropDownMenuTemplate");
	UIConfig.dropDownTwo:SetPoint("CENTER", UIConfig.dropDownTitleTwo, 0, -23);
	UIConfig.dropDownIconTwo = self:CreateDropdownIcon(UIConfig.dropDownTwo, "ArenaMarkerIconTwo");

	--Third Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Three_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownThreeMarkerID = j;
				ArenaMarkerDB.petDropDownThreeClickID = self:GetID();
				if i == 9 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 then
					Config.SmallMenu();
				else
					Config.LargeMenu();
				end
				break
				; end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(UIConfig.dropDownThree, self.value);
		setDropdownCheck(UIConfig.dropDownThree, self:GetID());
		setDropdownIconThree(j);
	end

	function ArenaMarkerDropDownMenuThree(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = ArenaMarker_Pet_DropDown_Three_OnClick
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean
			if i ~= nil then
				if i == ArenaMarkerDB.petDropDownTwoMarkerID or i == ArenaMarkerDB.petDropDownMarkerID then
					info.disabled = true;
				else
					info.disabled = false;
				end
				info.icon = core.texture_path .. i;
			else
				info.icon = nil;
				info.disabled = false;
			end
			return UIDropDownMenu_AddButton(info);
		end

		for i = #core.marker_strings, 1, -1 do
			AddMark(core.marker_strings[i], false, i);
		end
		AddMark("none", false, nil);
	end

	UIConfig.dropDownTitleThree = self:CreateDropdownTitle(UIConfig.dropDownTwo, "Extra Party-Pet Mark");
	UIConfig.dropDownThree = CreateFrame("Frame", "ArenaMarkerDropDownThree", UIParent, "UIDropDownMenuTemplate");
	UIConfig.dropDownThree:SetPoint("CENTER", UIConfig.dropDownTitleThree, 0, -23);
	UIConfig.dropDownIconThree = self:CreateDropdownIcon(UIConfig.dropDownThree, "ArenaMarkerIconThree");

	self:InitDropdown(UIConfig.dropDown, ArenaMarkerDropDownMenu, ArenaMarkerDB.petDropDownClickID, ArenaMarkerDB.petDropDownMarkerID, setDropdownIcon);
	self:InitDropdown(UIConfig.dropDownTwo, ArenaMarkerDropDownMenuTwo, ArenaMarkerDB.petDropDownTwoClickID, ArenaMarkerDB.petDropDownTwoMarkerID, setDropdownIconTwo);
	self:InitDropdown(UIConfig.dropDownThree, ArenaMarkerDropDownMenuThree, ArenaMarkerDB.petDropDownThreeClickID, ArenaMarkerDB.petDropDownThreeMarkerID, setDropdownIconThree);

	UIConfig:Hide();
	return UIConfig;
end

-- Escape key functionality
tinsert(UISpecialFrames, "ArenaMarkerConfig");
tinsert(UISpecialFrames, "ArenaMarkerDropDown");
tinsert(UISpecialFrames, "ArenaMarkerDropDownTwo");
tinsert(UISpecialFrames, "ArenaMarkerDropDownThree");

local update = CreateFrame("Frame")
local function Removed_Mark_Handler()
	-- exit function if removed_markers doesnt have a valid value
	local c = 0;
	for _, k in pairs(core.removed_markers) do if k ~= nil then c = c + 1 end end
	if c == 0 then return end
	for i, v in pairs(core.removed_markers) do
		if not contains(core.unused_markers, v) then
			-- re-populate table if user clicks remove_mark button(s)
			for j = 1, #core.marker_strings do
				if v == j then
					core.unused_markers[core.marker_strings[j]] = j;
					removeValue(core.removed_markers, i);
				end
			end
		end
	end
end

update:SetScript("OnUpdate", Removed_Mark_Handler);

function Config:Player_Login()
	if not ArenaMarkerDB then
		ArenaMarkerDB = {};
		ArenaMarkerDB["allowPets"] = true;
		ArenaMarkerDB["markSummonedPets"] = false;
		ArenaMarkerDB["petDropDownMarkerID"] = -1;
		ArenaMarkerDB["petDropDownClickID"] = -1;
		ArenaMarkerDB["petDropDownTwoMarkerID"] = -1;
		ArenaMarkerDB["petDropDownTwoClickID"] = -1;
		ArenaMarkerDB["petDropDownThreeMarkerID"] = -1;
		ArenaMarkerDB["petDropDownThreeClickID"] = -1;
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
