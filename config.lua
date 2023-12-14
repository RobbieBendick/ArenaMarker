--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
local LibDBIcon = LibStub("LibDBIcon-1.0");
local addon_name = "ArenaMarker";
core.Config = {};
local Config = core.Config;
local AMConfig;
local members = GetNumGroupMembers;

core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) Config:Player_Login(self) end,
	["CHAT_MSG_BG_SYSTEM_NEUTRAL"] = function(self, ...) AM:Main(self, ...) end,
	["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) AM:HandleUnitSpellCastSucceeded(self, ...) end,
	["ZONE_CHANGED_NEW_AREA"] = function(self) AM:IsOutOfArena(self) end,
};
--------------------------------------
-- Config functions
--------------------------------------

function Config:Toggle()
	if AMConfig:IsShown() then
		_G.SettingsPanel:Hide();
	end
	InterfaceOptionsFrame_OpenToCategory(AMConfig);
	InterfaceOptionsFrame_OpenToCategory(AMConfig);
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
	local checkbtn = CreateFrame("CheckButton", nil, AMConfig, "UICheckButtonTemplate");
	checkbtn:SetPoint("CENTER", relativeFrame, "CENTER", 0, -35);
	checkbtn.Text:SetText(" " .. buttonText);
	checkbtn.Text:SetFontObject("GameFontHighlight");
	checkbtn:SetChecked(DB_var);
	checkbtn:SetScript("OnClick", function(self) DB_var = self:GetChecked() end);
	return checkbtn;
end

function Config:CreateDropdownTitle(relativeFrame, dropText)
	local dropTitle = AMConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	dropTitle:SetText(dropText);
	dropTitle:SetPoint("CENTER", relativeFrame, 0, -32);
	return dropTitle;
end

function Config:CreateDropdown(relativeFrame, frameName)
	local dropDown = CreateFrame("Frame", frameName or nil, AMConfig, "UIDropDownMenuTemplate");
	dropDown:SetPoint("CENTER", relativeFrame, 0, -23);
	return dropDown;
end

function Config:CreateDropdownIcon(relativeFrame)
	local dropIcon = AMConfig:CreateTexture(nil, "ARTWORK", nil, 2);
	dropIcon:SetParent(relativeFrame);
	dropIcon:SetPoint("LEFT", relativeFrame, 25, 2);
	dropIcon:SetSize(16, 16);
	return dropIcon;
end

function Config:InitDropdown(dropdown, menu, clickID, markerID, frame)
	UIDropDownMenu_SetWidth(dropdown, 93);
	UIDropDownMenu_Initialize(dropdown, menu);
	UIDropDownMenu_SetSelectedID(dropdown, clickID);

	if not markerID then return end
	if markerID == -1 then
		frame:SetTexture(nil);
	else
		frame:SetTexture(core.markerTexturePath .. markerID);
	end
end

function Config:SmallMenu()
	AMConfig.dropDownTitleThree:Hide();
	AMConfig.dropDownThree:Hide();
end

function Config:LargeMenu()
	AMConfig.dropDownTitleThree:Show();
	AMConfig.dropDownThree:Show();
end

function Config:CheckMenu()
	-- both party-pet options are 'none'
	if ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1 then
		return Config:SmallMenu();
	end
	-- atleast 1 other party-pet option isnt 'none'
	if not (ArenaMarkerDB.petDropDownThreeMarkerID == -1 and ArenaMarkerDB.petDropDownTwoMarkerID == -1) then
		return Config:LargeMenu();
	end
end

function Config:ChatFrame(t) return DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: " .. t); end

function Config:CreateMenu()
	-- Menu
	AMConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent);

	AMConfig.name = "ArenaMarker";

	-- Options Title
	AMConfig.title = AMConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	AMConfig.title:SetParent(AMConfig);
	AMConfig.title:SetPoint("TOPLEFT", 16, -16);
	AMConfig.title:SetText(AMConfig.name);

	-- Mark Pets Check Button
	AMConfig.markPetsCheckButton = self:CreateCheckButton(AMConfig.title,
		"Mark Pets When Arena Gates Open", ArenaMarkerDB.allowPets)
	AMConfig.markPetsCheckButton:SetPoint("BOTTOMLEFT", AMConfig.title, "BOTTOMLEFT", 0, -45);
	AMConfig.markPetsCheckButton:SetScript("OnClick",
		function() ArenaMarkerDB.allowPets = AMConfig.markPetsCheckButton:GetChecked() end);

	-- Pet-Summon Check Button
	AMConfig.markPetsOnSummonCheckButton = self:CreateCheckButton(AMConfig.markPetsCheckButton,
		"Mark Pets When Summoned In Arena", ArenaMarkerDB.markSummonedPets);
	AMConfig.markPetsOnSummonCheckButton:SetScript("OnClick",
		function() ArenaMarkerDB.markSummonedPets = AMConfig.markPetsOnSummonCheckButton:GetChecked() end);

	-- Mark Players Button
	AMConfig.markPlayersButton = self:CreateButton(AMConfig.markPetsOnSummonCheckButton, "Mark Players", AM.MarkPlayers,
		44
		, -40);

	-- Unmark Players Button
	AMConfig.unmarkPlayersButton = self:CreateButton(AMConfig.markPlayersButton, "Unmark Players", AM.UnmarkPlayers, 120,
		0);

	-- Mark Pets Button
	AMConfig.markPetsButton = self:CreateButton(AMConfig.markPlayersButton, "Mark Pets", AM.MarkPets, 0, -45);

	-- Unmark Pets Button
	AMConfig.unmarkPetsButton = self:CreateButton(AMConfig.markPetsButton, "Unmark Pets", AM.UnmarkPets, 120, 0);

	function Config:SetDropdownInfo(dropdown, textVal, selectedVal, iconFrame, j)
		UIDropDownMenu_SetText(dropdown, textVal);
		UIDropDownMenu_SetSelectedID(dropdown, selectedVal);
		if not iconFrame then return end
		if j == -1 then
			iconFrame:SetTexture(nil);
		else
			iconFrame:SetTexture(core.markerTexturePath .. j);
		end
	end

	function Config:CreateDropdownMenu(disableOne, disableTwo, func)
		local info = UIDropDownMenu_CreateInfo();
		info.func = func;
		local function AddMark(marker, i)
			info.text, info.checked = marker, false;
			if i then
				if i == disableOne or i == disableTwo then
					info.disabled = true;

					-- remove color codes
					marker = marker:gsub("|c........", ""):gsub("|r", "")

					-- set text to non color coded text
					info.text = Config:CapitalizeFirstLetter(marker);
				else
					info.disabled = false;
				end
				info.icon = core.markerTexturePath .. i;
			else
				info.icon = nil;
				info.disabled = false;
			end
			return UIDropDownMenu_AddButton(info);
		end

		for i = #core.markerStrings, 1, -1 do
			AddMark(core.RAID_TARGET_COLORS[i] .. Config:CapitalizeFirstLetter(core.markerStrings[i]), i);
		end
		AddMark("None", false, nil);
	end

	function Config:CreatePetDropdownOnClick(self, disableOne, markerIDString, clickIDString, frame, iconFrame)
		local j = -1;
		for i = #core.markerStrings + 1, 1, -1 do
			if self:GetID() == i then
				-- set marker & click ID
				ArenaMarkerDB[markerIDString] = j;
				ArenaMarkerDB[clickIDString] = self:GetID();
				break;
			end
			-- j is finding the MarkerID from the ClickID
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame, j);
		Config:CheckMenu();
	end

	-- Self-Pet Priority Dropdown
	local function arenaMarkerPetDropDownOnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, nil, "petDropDownMarkerID", "petDropDownClickID", AMConfig.dropDown,
			AMConfig.dropDownIcon);
	end

	function Config:ArenaMarkerDropDownMenu(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownTwoMarkerID,
			arenaMarkerPetDropDownOnClick);
	end

	AMConfig.dropDownTitle = self:CreateDropdownTitle(AMConfig.markPetsButton, "Self-Pet Mark");
	AMConfig.dropDown = self:CreateDropdown(AMConfig.dropDownTitle, "ArenaMarkerDropDown");
	AMConfig.dropDownIcon = self:CreateDropdownIcon(AMConfig.dropDown);

	-- Second Prio Pet Dropdown
	local function arenaMarkerPetDropDownTwoOnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, ArenaMarkerDB.petDropDownThreeMarkerID, "petDropDownTwoMarkerID",
			"petDropDownTwoClickID", AMConfig.dropDownTwo, AMConfig.dropDownIconTwo);
	end

	function Config:ArenaMarkerDropDownMenuTwo(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownMarkerID,
			arenaMarkerPetDropDownTwoOnClick);
	end

	AMConfig.dropDownTitleTwo = self:CreateDropdownTitle(AMConfig.dropDown, "Party-Pet Mark");
	AMConfig.dropDownTwo = self:CreateDropdown(AMConfig.dropDownTitleTwo);
	AMConfig.dropDownIconTwo = self:CreateDropdownIcon(AMConfig.dropDownTwo);

	-- Third Prio Pet Dropdown
	local function arenaMarkerPetDropDownThreeOnClick(self, arg1, arg2, checked)
		return Config:CreatePetDropdownOnClick(self, ArenaMarkerDB.petDropDownTwoMarkerID, "petDropDownThreeMarkerID",
			"petDropDownThreeClickID", AMConfig.dropDownThree, AMConfig.dropDownIconThree);
	end

	function Config:ArenaMarkerDropDownMenuThree(frame, level, menuList)
		return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownTwoMarkerID, ArenaMarkerDB.petDropDownMarkerID,
			arenaMarkerPetDropDownThreeOnClick);
	end

	AMConfig.dropDownTitleThree = self:CreateDropdownTitle(AMConfig.dropDownTwo, "Extra Party-Pet Mark");
	AMConfig.dropDownThree = self:CreateDropdown(AMConfig.dropDownTitleThree);
	AMConfig.dropDownIconThree = self:CreateDropdownIcon(AMConfig.dropDownThree);

	-- Class Dropdown
	AMConfig.classDropDownTitle = self:CreateDropdownTitle(AMConfig.dropDown, "Priority Class Marks");
	AMConfig.classDropDownTitle:SetPoint("TOPRIGHT", AMConfig.dropDown, "TOPRIGHT", 128, 13);
	AMConfig.classDropDown = self:CreateDropdown(AMConfig.classDropDownTitle, "ArenaMarkerClassDropDown");
	AMConfig.classDropDownIcon = self:CreateDropdownIcon(AMConfig.classDropDown);
	AMConfig.classDropDownIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES");

	-- Class Marker Dropdown
	AMConfig.classMarkerDropDownTitle = self:CreateDropdownTitle(AMConfig.classDropDown, "Priority Marker");
	AMConfig.classMarkerDropDownTitle:SetPoint("CENTER", AMConfig.classDropDown, "CENTER", 0, -24);
	AMConfig.classMarkerDropDown = self:CreateDropdown(AMConfig.classMarkerDropDownTitle,
		"ArenaMarkerClassMarkerDropDown");
	AMConfig.classMarkerDropDownIcon = self:CreateDropdownIcon(AMConfig.classMarkerDropDown);

	-- Reset Class Markers Button
	AMConfig.resetClassMarkersButton = self:CreateButton(AMConfig.classMarkerDropDown, "Reset To Default",
		function() StaticPopup_Show("RESET_ALL_CONFIRM") end, 0, -25);

	AMConfig.resetClassMarkersButton:SetSize(118, 23);

	-- Class Marker Dropdown Onclick function
	local function arenaMarkerClassMarkerDropDownOnClick(self, arg1, arg2, checked)
		local j = -1;
		for i = #core.markerStrings + 1, 1, -1 do
			if self:GetID() == i then
				-- set marker & click ID
				ArenaMarkerDB["classMarkerDropDownClickID"] = self:GetID();
				ArenaMarkerDB["classMarkerDropDownMarkerID"] = j;
				break;
			end
			-- j is finding the MarkerID from the ClickID
			if j == -1 then
				j = j + 2;
			else
				j = j + 1;
			end
		end
		-- set dropdown info
		Config:SetDropdownInfo(AMConfig.classMarkerDropDown, self.value, self:GetID(), AMConfig.classMarkerDropDownIcon,
			j);

		-- find selected id from class dropdown
		local classID = UIDropDownMenu_GetSelectedID(AMConfig.classDropDown);

		-- prioritize marker
		if classID == 1 then
			Config:UpdatePriorityMarker(core.classes[classID]:upper(), core.markerStrings[j]);
		else
			Config:UpdatePriorityMarker(ArenaMarkerDB["classString"], core.markerStrings[j]);
		end
	end

	-- Class Marker Dropdown Menu
	local function arenaMarkerClassMarkerDropDownMenu(frame, level, menuList)
		-- Create the dropdown menu
		local info = UIDropDownMenu_CreateInfo();
		info.func = arenaMarkerClassMarkerDropDownOnClick;
		local function AddDropDownValue(marker, markerID)
			info.text, info.checked = marker, false;
			if markerID then
				info.icon = core.markerTexturePath .. markerID;
			else
				info.icon = nil;
			end
			local markerColor = core.RAID_TARGET_COLORS[markerID];

			if markerColor then
				info.colorCode = markerColor;
			end

			return UIDropDownMenu_AddButton(info);
		end

		for i = #core.markerStrings, 1, -1 do
			AddDropDownValue(Config:CapitalizeFirstLetter(core.markerStrings[i]), i);
		end
	end

	local function arenaMarkerClassDropDownOnClick(self, arg1, arg2, checked)
		for i = 1, #core.relatives do
			if self:GetID() == i then
				-- Set marker & click ID
				ArenaMarkerDB["classDropDownClickID"] = self:GetID();
				break;
			end
		end

		local newSelfValue = Config:RemoveSpaces(self.value):upper();
		ArenaMarkerDB["classString"] = self.value:upper();

		-- get the coordinates of the class icon we want to use
		local coords = CLASS_ICON_TCOORDS[newSelfValue];

		-- set the coordinates of our texture
		AMConfig.classDropDownIcon:SetTexCoord(unpack(coords));

		-- set class dropdown stuff
		UIDropDownMenu_SetText(AMConfig.classDropDown, self.value);
		UIDropDownMenu_SetSelectedID(AMConfig.classDropDown, self:GetID());
		UIDropDownMenu_SetSelectedValue(AMConfig.classDropDown, self.value);

		-- set class marker dropdown stuff
		UIDropDownMenu_SetSelectedID(AMConfig.classMarkerDropDown,
			core.reversedMarkerValues[core.relatives[newSelfValue][1]]);

		local selectedMarkerID = core.markerValues[core.relatives[newSelfValue][1]];

		UIDropDownMenu_SetText(AMConfig.classMarkerDropDown,
			core.RAID_TARGET_COLORS[selectedMarkerID] ..
			Config:CapitalizeFirstLetter(core.relatives[newSelfValue][1]));

		AMConfig.classMarkerDropDownIcon:SetTexture(core.markerTexturePath ..
			core.markerValues[core.relatives[newSelfValue][1]]);
	end

	local function arenaMarkerClassDropDownMenu(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo();
		info.func = arenaMarkerClassDropDownOnClick;
		local function AddDropDownValue(marker, coords)
			info.text, info.checked, info.icon = marker, false,
				"Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES";

			-- DK/DH spaces
			marker = Config:RemoveSpaces(marker);

			-- get the color string for the class
			if RAID_CLASS_COLORS[marker:upper()] then
				info.colorCode = "|c" .. RAID_CLASS_COLORS[marker:upper()].colorStr;
			end

			-- set the coordinates of our texture
			if coords then
				info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom = unpack(coords);
			end

			return UIDropDownMenu_AddButton(info);
		end
		for i, class in ipairs(core.classes) do
			local coords = CLASS_ICON_TCOORDS[Config:RemoveSpaces(class:upper())];
			AddDropDownValue(class, coords);
		end
	end

	function Config:HandleResetClick()
		-- loop through all settings and reset them to their default values
		for class, markerList in pairs(core.defaultClassMarkers) do
			-- set the new values in the database
			ArenaMarkerDB.classMarkers[class] = markerList;

			-- set the new values in the relatives table
			core.relatives[class][1] = markerList[1];
		end

		-- find what value is currently selected on the class dropdown
		local dropdownValue = UIDropDownMenu_GetText(AMConfig.classDropDown);

		-- remove color codes from the dropdown value
		dropdownValue = dropdownValue:gsub("|c........", ""):gsub("|r", "")
		dropdownValue = Config:RemoveSpaces(dropdownValue);

		-- get the first marker from the class we have selected
		local newMarker = core.relatives[dropdownValue:upper()][1];

		-- get the color of the marker and capitalize the first letter
		local coloredMarkerText = core.RAID_TARGET_COLORS[core.markerValues[newMarker]] ..
			Config:CapitalizeFirstLetter(newMarker);

		-- set click id of the marker dropdown
		UIDropDownMenu_SetSelectedID(AMConfig.classMarkerDropDown, core.reversedMarkerValues[newMarker]);

		-- set the marker icon on the classID we have selected
		AMConfig.classMarkerDropDownIcon:SetTexture(core.markerTexturePath .. core.markerValues[newMarker]);

		-- set the marker dropdown text on the classID we have selected
		UIDropDownMenu_SetText(AMConfig.classMarkerDropDown, coloredMarkerText);

		-- notify the user that settings have been reset
		Config:ChatFrame("Class priority markers have been reset to their default values.");
	end

	-- init Dropdowns
	self:InitDropdown(AMConfig.dropDown, Config.ArenaMarkerDropDownMenu, ArenaMarkerDB.petDropDownClickID,
		ArenaMarkerDB.petDropDownMarkerID, AMConfig.dropDownIcon);
	self:InitDropdown(AMConfig.dropDownTwo, Config.ArenaMarkerDropDownMenuTwo, ArenaMarkerDB.petDropDownTwoClickID,
		ArenaMarkerDB.petDropDownTwoMarkerID, AMConfig.dropDownIconTwo);
	self:InitDropdown(AMConfig.dropDownThree, Config.ArenaMarkerDropDownMenuThree, ArenaMarkerDB.petDropDownThreeClickID,
		ArenaMarkerDB.petDropDownThreeMarkerID, AMConfig.dropDownIconThree);

	self:InitDropdown(AMConfig.classDropDown, arenaMarkerClassDropDownMenu, 1, nil,
		nil);
	UIDropDownMenu_SetWidth(AMConfig.classDropDown, 110);

	self:InitDropdown(AMConfig.classMarkerDropDown, arenaMarkerClassMarkerDropDownMenu,
		nil, nil, nil);

	-- set default values for class dropdown (hunter = default because its the first class in the dropdown)
	local defaultClass = "HUNTER";
	local coords = CLASS_ICON_TCOORDS[defaultClass];
	AMConfig.classDropDownIcon:SetTexCoord(unpack(coords));
	UIDropDownMenu_SetText(AMConfig.classMarkerDropDown, core.relatives[defaultClass][1]);

	AMConfig.classMarkerDropDownIcon:SetTexture(core.markerTexturePath ..
		core.markerValues[core.relatives[defaultClass][1]]);

	UIDropDownMenu_SetSelectedID(AMConfig.classMarkerDropDown,
		core.reversedMarkerValues[core.relatives[defaultClass][1]]);

	self:CheckMenu();

	AMConfig:Hide();
	return InterfaceOptions_AddCategory(AMConfig);
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

function Config:RemoveSpaces(string)
    return string:gsub("%s+", "");
end

function Config:GetClasses()
	for class in pairs(core.relatives) do
		table.insert(core.classes, class);
	end
	for i, class in ipairs(core.classes) do
		core.classes[i] = Config:CapitalizeFirstLetter(class:lower());

		if core.classes[i]:upper() == "DEATHKNIGHT" then
			core.classes[i] = "Death Knight";
		elseif core.classes[i]:upper() == "DEMONHUNTER" then
			core.classes[i] = "Demon Hunter";
		end
	end
end

function Config:CapitalizeFirstLetter(str)
	return str:gsub("^%l", string.upper);
end

function Config:CreateMinimapIcon()
	LibDBIcon:Register(addon_name, {
		icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		OnClick = self.Toggle,
		OnTooltipShow = function(tt)
			tt:AddLine(addon_name .. " |cff808080" .. GetAddOnMetadata(AMConfig.name, "Version"));
			tt:AddLine("|cffCCCCCCClick|r to open options");
			tt:AddLine("|cffCCCCCCDrag|r to move this button");
		end,
		text = addon_name,
		iconCoords = {0.05, 0.95, 0.05, 0.95},
	});

	-- update position
	if #ArenaMarkerDB.minimapCoords > 0 then
		LibDBIcon:GetMinimapButton(addon_name):SetPoint(unpack(ArenaMarkerDB.minimapCoords));
	end
end

function Config:OnInitialize()
	if not ArenaMarkerDB then
		ArenaMarkerDB = {};
	end

	-- check if saved variables have the expected structure for the current version of the addon
	if not ArenaMarkerDB.minimapCoords then
		-- saved variables are outdated, perform update
		ArenaMarkerDB.allowPets = true;
		ArenaMarkerDB.markSummonedPets = true;
		ArenaMarkerDB.petDropDownMarkerID = -1;
		ArenaMarkerDB.petDropDownClickID = -1;
		ArenaMarkerDB.petDropDownTwoMarkerID = -1;
		ArenaMarkerDB.petDropDownTwoClickID = -1;
		ArenaMarkerDB.petDropDownThreeMarkerID = -1;
		ArenaMarkerDB.petDropDownThreeClickID = -1;
		ArenaMarkerDB.classDropDownClickID = -1;
		ArenaMarkerDB.classMarkerDropDownClickID = -1;
		ArenaMarkerDB.classMarkerDropDownMarkerID = -1;
		ArenaMarkerDB.classString = "none";
		ArenaMarkerDB.classMarkers = {};
		ArenaMarkerDB.minimapCoords = {};
	end

	-- place all class/marker combinations into relatives
	for class, markerList in pairs(ArenaMarkerDB.classMarkers) do
		core.relatives[class] = markerList;
	end

	Config:GetClasses();
	Config:CreateMenu();

	-- define reset class marker priorty dialog box
	StaticPopupDialogs["RESET_ALL_CONFIRM"] = {
		text = "Are you sure you want to reset class priority marker options?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = Config.HandleResetClick,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	};

	self:CreateMinimapIcon();

	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" ..
		AMConfig.name ..
		"|r by " ..
		"|cff69CCF0" ..
		GetAddOnMetadata(AMConfig.name, "Author") ..
		"|r. Type |cff33ff99/am|r for additional options.");
end

function Config:UpdatePriorityMarker(class, newMarker)
	class = Config:RemoveSpaces(class);

	-- if the new marker is already prioritized, do nothing
	if core.relatives[class][1] == newMarker then return end

	-- update the priority marker for the class
	core.relatives[class][1] = newMarker;

	-- update the DB
	ArenaMarkerDB.classMarkers[class] = core.relatives[class];

	-- get class/marker color combo
	local classColor = "|c" .. RAID_CLASS_COLORS[class:upper()].colorStr;
	local markerColor = core.RAID_TARGET_COLORS[core.markerValues[newMarker]];

	-- notify the user
	self:ChatFrame("Updated priority marker for " ..
		classColor .. Config:CapitalizeFirstLetter(class:lower()) .. "|r" ..
		" to " .. markerColor .. Config:CapitalizeFirstLetter(newMarker) .. "|r" .. ".");
end

-- init DB & menu
function Config:Player_Login()
	Config:OnInitialize();
end
