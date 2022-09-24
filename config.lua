--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
core.removed_markers = {};
core.summon_after_gates = {};
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
--------------------------------------
-- Config functions
--------------------------------------

function Config:Toggle()
	UIConfig:SetShown(not UIConfig:IsShown());
	InterfaceOptionsFrame_OpenToCategory(UIConfig);
	InterfaceOptionsFrame_OpenToCategory(UIConfig);

	Config:CheckMenu();
end

function Config:CreateButton(relativeFrame, buttonText, funcName, xOff, yOff)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetPoint("CENTER", relativeFrame, "CENTER", xOff, yOff);
	btn:SetSize(110, 30);
	btn:SetText(buttonText);
	btn:SetScript("OnClick", funcName);
	return btn;
end

function Config:CreateCheckButton(relativeFrame, buttonText, DB_var)
	local checkbtn = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate");
	checkbtn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -35);
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

function Config:CreateDropdown(relativeFrame, frameName)
	local dropDown = CreateFrame("Frame", frameName, UIConfig, "UIDropDownMenuTemplate");
	dropDown:SetPoint("CENTER", relativeFrame, 0, -23);
	return dropDown;
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
	if markerID == -1 then
		frame:SetTexture(nil);
	else
		frame:SetTexture(core.texture_path .. markerID);
	end
end

function Config:SmallMenu()
	UIConfig.dropDownTitleThree:Hide();
	UIConfig.dropDownThree:Hide();
end

function Config:LargeMenu()
	UIConfig.dropDownTitleThree:Show();
	UIConfig.dropDownThree:Show();
end

function Config:CheckMenu()
	-- both party-pet options are 'none'
	if ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 and UIConfig:IsShown() then
		return Config:SmallMenu();
	end
	-- atleast 1 other party-pet option isnt 'none'
	if not (ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1) and
		UIConfig:IsShown() then
		return Config:LargeMenu();
	end
end

function Config:ChatFrame(t)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: " .. t);
end

function Config:CreateMenu()
	-- Menu
	UIConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent);

	UIConfig.name = "ArenaMarker";

	-- Options Title
	UIConfig.title = UIConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	UIConfig.title:SetParent(UIConfig);
	UIConfig.title:SetPoint("TOPLEFT", 16, -16);
	UIConfig.title:SetText("|cff33ff99" .. UIConfig.name .. "|r");
	UIConfig.title:SetJustifyH("LEFT");

	-- Mark Pets Check Button
	UIConfig.markPetsCheckButton = self:CreateCheckButton(UIConfig.title,
		"Mark Pets (when arena gates open)", ArenaMarkerDB.allowPets)
	UIConfig.markPetsCheckButton:SetPoint("BOTTOMLEFT", UIConfig.title, "BOTTOMLEFT", 0, -45);
	UIConfig.markPetsCheckButton:SetScript("OnClick",
		function() ArenaMarkerDB.allowPets = UIConfig.markPetsCheckButton:GetChecked() end);

	-- Pet-Summon Check Button
	UIConfig.markPetsOnSummonCheckButton = self:CreateCheckButton(UIConfig.markPetsCheckButton,
		"Mark Pets when summoned (in arena)", ArenaMarkerDB.markSummonedPets);
	UIConfig.markPetsOnSummonCheckButton:SetScript("OnClick",
		function() ArenaMarkerDB.markSummonedPets = UIConfig.markPetsOnSummonCheckButton:GetChecked() end);

	-- Mark Players Button
	UIConfig.markPlayersButton = self:CreateButton(UIConfig.markPetsOnSummonCheckButton, "Mark Players", AM.MarkPlayers, 44
		, -40);

	-- Unmark Players Button
	UIConfig.unmarkPlayersButton = self:CreateButton(UIConfig.markPlayersButton, "Unmark Players", AM.UnmarkPlayers, 120, 0);

	-- Mark Pets Button
	UIConfig.markPetsButton = self:CreateButton(UIConfig.markPlayersButton, "Mark Pets", AM.MarkPets, 0, -45);

	-- Unmark Pets Button
	UIConfig.unmarkPetsButton = self:CreateButton(UIConfig.markPetsButton, "Unmark Pets", AM.UnmarkPets, 120, 0);

	function Config:SetDropdownInfo(dropdown, textVal, selectedVal, iconFrame, j)
		UIDropDownMenu_SetText(dropdown, textVal);
		UIDropDownMenu_SetSelectedID(dropdown, selectedVal);
		if j == -1 then
			iconFrame:SetTexture(nil);
		else
			iconFrame:SetTexture(core.texture_path .. j);
		end
	end

	function Config:CreateDropdownMenu(disableOne, disableTwo, func)
		local info = UIDropDownMenu_CreateInfo();
		info.func = func;
		local function AddMark(marker, boolean, i)
			info.text, info.checked = marker, boolean;
			if i then
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

	function Config:CreatePetDropdownOnClick(self, disableOne, markerIDString, clickIDString, frame, iconFrame)
		local j = -1;
		for i = #core.marker_strings + 1, 1, -1 do
			if self:GetID() == i then
				-- set marker & click ID
				ArenaMarkerDB[markerIDString] = j;
				ArenaMarkerDB[clickIDString] = self:GetID();
				if frame:GetName() == "ArenaMarkerDropDown" then break end
				-- check which menu we need
				if i == 9 and disableOne == -1 then
					Config:SmallMenu();
				else
					Config:LargeMenu();
				end
				break
			end
			-- j is finding the MarkerID from the ClickID
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame, j);
	end

	-- Self-Pet Priority Dropdown
	local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, nil, "petDropDownMarkerID", "petDropDownClickID", UIConfig.dropDown,
			UIConfig.dropDownIcon);
	end

	function ArenaMarkerDropDownMenu(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownTwoMarkerID,
			ArenaMarker_Pet_DropDown_OnClick);
	end

	UIConfig.dropDownTitle = self:CreateDropdownTitle(UIConfig.markPetsButton, "Self-Pet Mark");
	UIConfig.dropDown = self:CreateDropdown(UIConfig.dropDownTitle, "ArenaMarkerDropDown");
	UIConfig.dropDownIcon = self:CreateDropdownIcon(UIConfig.dropDown);

	-- Second Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Two_OnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, ArenaMarkerDB.petDropDownThreeMarkerID, "petDropDownTwoMarkerID",
			"petDropDownTwoClickID", UIConfig.dropDownTwo, UIConfig.dropDownIconTwo);
	end

	function ArenaMarkerDropDownMenuTwo(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownMarkerID,
			ArenaMarker_Pet_DropDown_Two_OnClick);
	end

	UIConfig.dropDownTitleTwo = self:CreateDropdownTitle(UIConfig.dropDown, "Party-Pet Mark");
	UIConfig.dropDownTwo = self:CreateDropdown(UIConfig.dropDownTitleTwo, "ArenaMarkerDropDownTwo");
	UIConfig.dropDownIconTwo = self:CreateDropdownIcon(UIConfig.dropDownTwo);

	-- Third Prio Pet Dropdown
	local function ArenaMarker_Pet_DropDown_Three_OnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, ArenaMarkerDB.petDropDownTwoMarkerID, "petDropDownThreeMarkerID",
			"petDropDownThreeClickID", UIConfig.dropDownThree, UIConfig.dropDownIconThree);
	end

	function ArenaMarkerDropDownMenuThree(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownTwoMarkerID, ArenaMarkerDB.petDropDownMarkerID,
			ArenaMarker_Pet_DropDown_Three_OnClick);
	end

	UIConfig.dropDownTitleThree = self:CreateDropdownTitle(UIConfig.dropDownTwo, "Extra Party-Pet Mark");
	UIConfig.dropDownThree = self:CreateDropdown(UIConfig.dropDownTitleThree, "ArenaMarkerDropDownThree");
	UIConfig.dropDownIconThree = self:CreateDropdownIcon(UIConfig.dropDownThree);

	self:InitDropdown(UIConfig.dropDown, ArenaMarkerDropDownMenu, ArenaMarkerDB.petDropDownClickID,
		ArenaMarkerDB.petDropDownMarkerID, UIConfig.dropDownIcon);
	self:InitDropdown(UIConfig.dropDownTwo, ArenaMarkerDropDownMenuTwo, ArenaMarkerDB.petDropDownTwoClickID,
		ArenaMarkerDB.petDropDownTwoMarkerID, UIConfig.dropDownIconTwo);
	self:InitDropdown(UIConfig.dropDownThree, ArenaMarkerDropDownMenuThree, ArenaMarkerDB.petDropDownThreeClickID,
		ArenaMarkerDB.petDropDownThreeMarkerID, UIConfig.dropDownIconThree);

	self:CheckMenu();

	UIConfig:Hide();
	return InterfaceOptions_AddCategory(UIConfig);
end

-- small helper funcs
function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false;
end

function removeValue(table, value)
	local key = table[value];
	table[value] = nil;
	return key;
end

-- init DB & menu
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
	Config:CreateMenu();
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r by |cff69CCF0Mageiden|r. Type |cff33ff99/am|r for additional options.");
end
