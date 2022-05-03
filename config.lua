--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
core.removed_markers = {};
core.summonAfterGates = {};
local Config = core.Config;
local UIConfig;
members = GetNumGroupMembers;
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
core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) Config:Player_Login(self) end,
	["CHAT_MSG_BG_SYSTEM_NEUTRAL"] = function(self, ...) AM:Main(self, ...) end,
	["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) AM:PetCastEventHandler(self, ...) end,
	["ZONE_CHANGED_NEW_AREA"] = function(self) AM:IsOutOfArena(self) end,
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
	if ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 and menu:IsShown() then
		Config:SmallMenu();
	end
	if not (ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1) and menu:IsShown() then
		Config:LargeMenu();
	end
end

function Config:ChatFrame(t)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: " .. t);
end

function Config:CreateButton(relativeFrame, buttonText, funcName)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -45);
	btn:SetSize(110, 30);
	btn:SetText(buttonText);
	btn:SetScript("OnClick", funcName);
	return btn;
end

function Config:CreateCheckButton(relativeFrame, buttonText, DB_var)
	local checkbtn = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	checkbtn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -45);
	checkbtn.text:SetText(buttonText);
	checkbtn.text:SetFontObject("GameFontHighlight");
	checkbtn:SetChecked(DB_var);
	checkbtn:SetScript("OnClick", function() DB_var = checkbtn:GetChecked() end);
	return checkbtn;
end

function Config:CreateDropdownTitle(relativeFrame, dropText)
	local dropTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	dropTitle:SetText(dropText);
	dropTitle:SetPoint("CENTER", relativeFrame, 0, -32);
	return dropTitle;
end

function Config:CreateDropdownIcon(relativeFrame)
	local dropIcon = UIConfig:CreateTexture(nil, "MEDIUM", nil, 2);
	dropIcon:SetParent(relativeFrame);
	dropIcon:SetPoint("LEFT", relativeFrame, 25, 2);
	dropIcon:SetSize(16, 16);
	return dropIcon;
end

function Config:InitDropdown(dropdown, menu, clickID, markerID, frame)
	UIDropDownMenu_SetWidth(dropdown, 93);
	UIDropDownMenu_Initialize(dropdown, menu);
	UIDropDownMenu_SetSelectedID(dropdown, clickID);
	setDropdownIcon(frame, markerID);
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

	-- Options Close Button
	UIConfig.CloseButton:SetScript("OnClick", Config.Toggle);

	-- Options Title
	UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UIConfig.title:ClearAllPoints();
	UIConfig.title:SetFontObject("GameFontHighlight");
	UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
	UIConfig.title:SetText("|cff33ff99ArenaMarker|r Options");

	-- Mark Pets Check Button
	UIConfig.markPetsCheckButton = self:CreateCheckButton(UIConfig.TitleBg, "        Mark Pets\n      (when arena\n     gates open)", ArenaMarkerDB.allowPets)
	UIConfig.markPetsCheckButton:SetPoint("CENTER", UIConfig.TitleBg, "CENTER", -45, -40);
	UIConfig.markPetsCheckButton:SetScript("OnClick", function() ArenaMarkerDB.allowPets = UIConfig.markPetsCheckButton:GetChecked() end);

	-- Pet-Summon Check Button
	UIConfig.markPetsOnSummonCheckButton = self:CreateCheckButton(UIConfig.markPetsCheckButton, "  Mark Pets\n when summoned \n (in arena)", ArenaMarkerDB.markSummonedPets);
	UIConfig.markPetsOnSummonCheckButton:SetScript("OnClick", function() ArenaMarkerDB.markSummonedPets = UIConfig.markPetsOnSummonCheckButton:GetChecked() end);

	-- Mark Players Button
	UIConfig.markPlayersButton = self:CreateButton(UIConfig.markPetsOnSummonCheckButton, "Mark Players", AM.MarkPlayers);
	UIConfig.markPlayersButton:SetPoint("CENTER", UIConfig.markPetsOnSummonCheckButton, "CENTER", 58, -45);

	-- Unmark Players Button
	UIConfig.unmarkPlayersButton = self:CreateButton(UIConfig.markPlayersButton, "Unmark Players", AM.UnmarkPlayers);

	-- Mark Pets Button
	UIConfig.markPetsButton = self:CreateButton(UIConfig.unmarkPlayersButton, "Mark Pets", AM.MarkPets);

	-- Unmark Pets Button
	UIConfig.unmarkPetsButton = self:CreateButton(UIConfig.markPetsButton, "Unmark Pets", AM.UnmarkPets);

	function setDropdownText(dropdown, v) return UIDropDownMenu_SetText(dropdown, v) end

	function setDropdownCheck(dropdown, v) return UIDropDownMenu_SetSelectedID(dropdown, v) end

	function setDropdownIcon(frame, j) if j == -1 then return frame:SetTexture(nil) end return frame:SetTexture(core.texture_path .. j) end

	function Config:CreateDropdownMenu(disableOne, disableTwo, func)
		local info = UIDropDownMenu_CreateInfo();
		info.func = func;
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean;
			if i ~= nil then
				if i == disableOne or i == disableTwo then
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

	-- Self-Pet Priority Dropdown
	local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownMarkerID = j;
				ArenaMarkerDB.petDropDownClickID = self:GetID();
				break
			end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(UIConfig.dropDown, self.value);
		setDropdownCheck(UIConfig.dropDown, self:GetID());
		setDropdownIcon(UIConfig.dropDownIcon, j);
	end

	function ArenaMarkerDropDownMenu(frame, level, menuList)
		Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownTwoMarkerID, ArenaMarker_Pet_DropDown_OnClick);
	end

	UIConfig.dropDownTitle = self:CreateDropdownTitle(UIConfig.unmarkPetsButton, "Self-Pet Mark");
	UIConfig.dropDown = CreateFrame("Frame", "ArenaMarkerDropDown", UIConfig, "UIDropDownMenuTemplate");
	UIConfig.dropDown:SetPoint("CENTER", UIConfig.dropDownTitle, 0, -23);
	UIConfig.dropDownIcon = self:CreateDropdownIcon(UIConfig.dropDown);

	function Config:CreatePetDropdownOnClick(disableOne, markerID, clickID)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				markerID = j;
				clickID = self:GetID();
				if i == 9 and disableOne == -1 then
					Config:SmallMenu();
				else
					Config:LargeMenu();
				end
				break
			end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
	end

	--Second Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Two_OnClick(self, arg1, arg2, checked)
		Config:CreatePetDropdownOnClick(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownTwoMarkerID, ArenaMarkerDB.petDropDownTwoClickID)
		setDropdownText(UIConfig.dropDownTwo, self.value);
		setDropdownCheck(UIConfig.dropDownTwo, self:GetID());
		setDropdownIcon(UIConfig.dropDownIconTwo, j);
	end

	function ArenaMarkerDropDownMenuTwo(frame, level, menuList)
		Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownMarkerID, ArenaMarker_Pet_DropDown_Two_OnClick);
	end

	UIConfig.dropDownTitleTwo = self:CreateDropdownTitle(UIConfig.dropDown, "Party-Pet Mark");
	UIConfig.dropDownTwo = CreateFrame("Frame", "ArenaMarkerDropDownTwo", UIConfig, "UIDropDownMenuTemplate");
	UIConfig.dropDownTwo:SetPoint("CENTER", UIConfig.dropDownTitleTwo, 0, -23);
	UIConfig.dropDownIconTwo = self:CreateDropdownIcon(UIConfig.dropDownTwo);

	--Third Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Three_OnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				ArenaMarkerDB.petDropDownThreeMarkerID = j;
				ArenaMarkerDB.petDropDownThreeClickID = self:GetID();
				if i == 9 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 then
					Config:SmallMenu();
				else
					Config:LargeMenu();
				end
				break
			end
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		setDropdownText(UIConfig.dropDownThree, self.value);
		setDropdownCheck(UIConfig.dropDownThree, self:GetID());
		setDropdownIcon(UIConfig.dropDownIconThree, j);
	end

	function ArenaMarkerDropDownMenuThree(frame, level, menuList)
		Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownTwoMarkerID, ArenaMarkerDB.petDropDownMarkerID, ArenaMarker_Pet_DropDown_Three_OnClick);
	end

	UIConfig.dropDownTitleThree = self:CreateDropdownTitle(UIConfig.dropDownTwo, "Extra Party-Pet Mark");
	UIConfig.dropDownThree = CreateFrame("Frame", "ArenaMarkerDropDownThree", UIConfig, "UIDropDownMenuTemplate");
	UIConfig.dropDownThree:SetPoint("CENTER", UIConfig.dropDownTitleThree, 0, -23);
	UIConfig.dropDownIconThree = self:CreateDropdownIcon(UIConfig.dropDownThree);

	self:InitDropdown(UIConfig.dropDown, ArenaMarkerDropDownMenu, ArenaMarkerDB.petDropDownClickID, ArenaMarkerDB.petDropDownMarkerID, UIConfig.dropDownIcon);
	self:InitDropdown(UIConfig.dropDownTwo, ArenaMarkerDropDownMenuTwo, ArenaMarkerDB.petDropDownTwoClickID, ArenaMarkerDB.petDropDownTwoMarkerID, UIConfig.dropDownIconTwo);
	self:InitDropdown(UIConfig.dropDownThree, ArenaMarkerDropDownMenuThree, ArenaMarkerDB.petDropDownThreeClickID, ArenaMarkerDB.petDropDownThreeMarkerID, UIConfig.dropDownIconThree);

	UIConfig:Hide();
	return UIConfig;
end

-- Escape key functionality
tinsert(UISpecialFrames, "ArenaMarkerConfig");

function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false;
end

function Config:Player_Login()
	if not ArenaMarkerDB then
		ArenaMarkerDB = {};
		ArenaMarkerDB["allowPets"] = true;
		ArenaMarkerDB["markSummonedPets"] = true;
		ArenaMarkerDB["petDropDownMarkerID"] = -1;
		ArenaMarkerDB["petDropDownClickID"] = -1;
		ArenaMarkerDB["petDropDownTwoMarkerID"] = -1;
		ArenaMarkerDB["petDropDownTwoClickID"] = -1;
		ArenaMarkerDB["petDropDownThreeMarkerID"] = -1;
		ArenaMarkerDB["petDropDownThreeClickID"] = -1;
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r by |cff69CCF0Mageiden|r. Type |cff33ff99/am|r for additional options.");
end
