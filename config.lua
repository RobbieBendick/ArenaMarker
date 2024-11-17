local _, addon = ...;
local ArenaMarker = LibStub("AceAddon-3.0"):GetAddon(addon.name);
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata;
local LibDBIcon = LibStub("LibDBIcon-1.0");
local members = GetNumGroupMembers;


function ArenaMarker:Toggle()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addon.name);
    else
        InterfaceOptionsFrame_OpenToCategory(addon.name);
        InterfaceOptionsFrame_OpenToCategory(addon.name);
    end
end

function ArenaMarker:CreateMenu()
	local version = GetAddOnMetadata(self.name, "Version") or "Unknown";
	local author = GetAddOnMetadata(self.name, "Author") or "Mageiden";
	
	local options = {
		type = "group",
		name = self.name,
		args = {
			info = {
				order = 1,
				type = "description",
				name = "|cffffd700Version|r " .. version .. "\n|cffffd700 Author|r " .. author,
			},
			settingsGroup = {
				order = 2,
				type = "group",
				name = "Auto Mark Pets",
				inline = true,
				args = {
					markPets = {
						order = 1,
						type = "toggle",
						name = "Mark Pets When Arena Gates Open",
						desc = "Enable or disable marking pets when the arena gates open.",
						get = function(info) return self.db.profile.allowPets end,
						set = function(info, value) self.db.profile.allowPets = value end,
					},
					markSummonedPets = {
						order = 2,
						type = "toggle",
						name = "Mark Pets When Summoned In Arena",
						desc = "Enable or disable marking pets when they are summoned.",
						get = function(info) return self.db.profile.markSummonedPets end,
						set = function(info, value) self.db.profile.markSummonedPets = value end,
					},
				},
			},
			partyPetsGroup = {
				order = 3,
				type = "group",
				name = "Party Pet Settings",
				inline = true,
				args = {
					selfPetDropdown = {
						order = 1,
						type = "select",
						name = "Self-Pet Mark",
						desc = "Select a marker for your pet.",
						values = function()
							local markers = {[-1] = "None"};
							for name, id in pairs(self.markerValues) do
								local color = self.RAID_TARGET_COLORS[id] or "|cFFFFFFFF";
								local icon = "|T" .. self.markerTexturePath .. id .. ":16|t";
								local label = self.markerStrings[id];
								
								if id == self.db.profile.petDropDownTwoMarkerID or id == self.db.profile.petDropDownThreeMarkerID then
									-- grey out this option to show it's disabled
									markers[id] = "|cff808080" .. icon .. " " .. label .. "|r";
								else
									markers[id] = color .. icon .. " " .. label .. "|r";
								end
							end
							return markers;
						end,
						get = function(info) return self.db.profile.petDropDownMarkerID end,
						set = function(info, value) 
							if value ~= self.db.profile.petDropDownTwoMarkerID and value ~= self.db.profile.petDropDownThreeMarkerID then
								self.db.profile.petDropDownMarkerID = value;
							else
								self:Print("|cffff0000This marker is already in use. Please choose a different one or adjust other pet marker settings.|r");
							end
							LibStub("AceConfigRegistry-3.0"):NotifyChange(self.name);
						end,
					},
					partyPetDropdown = {
						order = 2,
						type = "select",
						name = "Party-Pet Mark",
						desc = "Select a marker for party pets.",
						values = function()
							local markers = {[-1] = "None"};
							for name, id in pairs(self.markerValues) do
								local color = self.RAID_TARGET_COLORS[id] or "|cFFFFFFFF";
								local icon = "|T" .. self.markerTexturePath .. id .. ":16|t";
								local label = self.markerStrings[id];
								
								if id == self.db.profile.petDropDownMarkerID or id == self.db.profile.petDropDownThreeMarkerID then
									-- grey out this option to show it's disabled
									markers[id] = "|cff808080" .. icon .. " " .. label .. "|r";
								else
									markers[id] = color .. icon .. " " .. label .. "|r";
								end
							end
							return markers;
						end,
						get = function(info) return self.db.profile.petDropDownTwoMarkerID end,
						set = function(info, value) 
							if value ~= self.db.profile.petDropDownMarkerID and value ~= self.db.profile.petDropDownThreeMarkerID then
								self.db.profile.petDropDownTwoMarkerID = value;
							else
								self:Print("|cffff0000This marker is already in use. Please choose a different one or adjust other pet marker settings.|r");
							end
							LibStub("AceConfigRegistry-3.0"):NotifyChange(self.name);
						end,
					},
					extraPartyPetDropdown = {
						order = 3,
						type = "select",
						name = "Extra Party-Pet Mark",
						desc = "Select a marker for additional party pets.",
						values = function()
							local markers = {[-1] = "None"};
							for name, id in pairs(self.markerValues) do
								local color = self.RAID_TARGET_COLORS[id] or "|cFFFFFFFF";
								local icon = "|T" .. self.markerTexturePath .. id .. ":16|t";
								local label = self.markerStrings[id];
								
								if id == self.db.profile.petDropDownMarkerID or id == self.db.profile.petDropDownTwoMarkerID then
									-- grey out this option to show it's disabled
									markers[id] = "|cff808080" .. icon .. " " .. label .. "|r";
								else
									markers[id] = color .. icon .. " " .. label .. "|r";
								end
							end
							return markers;
						end,
						get = function(info) return self.db.profile.petDropDownThreeMarkerID end,
						set = function(info, value) 
							if value ~= self.db.profile.petDropDownMarkerID and value ~= self.db.profile.petDropDownTwoMarkerID then
								self.db.profile.petDropDownThreeMarkerID = value;
							else
								self:Print("|cffff0000This marker is already in use. Please choose a different one or adjust other pet marker settings.|r");
							end
							LibStub("AceConfigRegistry-3.0"):NotifyChange(self.name);
						end,
					}
					
				},
			},
			classSettingsGroup = {
				order = 5,
				type = "group",
				name = "Class Priority Markers",
				inline = true,
				args = {
					classDropdown = {
						order = 1,
						type = "select",
						name = "Class",
						desc = "Select a class to set priority markers.",
						values = function()
							local classes = {};
							for _, class in ipairs(self.classes) do
								local color = RAID_CLASS_COLORS[class:upper()].colorStr;
								local classText = class:sub(1,1) .. class:sub(2):lower();
								classes[class] = "|c" .. color .. classText .. "|r";
							end
							return classes;
						end,
						get = function(info) return self.db.profile.selectedClass end,
						set = function(info, value) self.db.profile.selectedClass = value end,
					},
					priorityMarkerDropdown = {
						order = 2,
						type = "select",
						name = "Priority Marker",
						desc = "Select a priority marker for the selected class.",
						values = function()
							local markers = {};
							for name, id in pairs(self.markerValues) do
								local color = self.RAID_TARGET_COLORS[id] or "|cFFFFFFFF";
								local icon = "|T" .. self.markerTexturePath .. id .. ":16|t";
								local label = self.markerStrings[id];
								markers[name] = color .. icon .. " " .. label .. "|r";
							end
							return markers;
						end,
						get = function(info)
							local selectedClass = self.db.profile.selectedClass;
							if selectedClass and self.db.profile.classMarkers[selectedClass] and self.db.profile.classMarkers[selectedClass][1] then
								return self.db.profile.classMarkers[selectedClass][1];
							else
								return self.db.profile.priorityMarkerSelection;
							end
						end,
						set = function(info, value)
							self.db.profile.priorityMarkerSelection = value;
							ArenaMarker:UpdatePriorityMarker(self.db.profile.selectedClass, value);
						end,
					},
					spacer = {
                        order = 3,
                        type = "description",
                        name = " ",
                        width = 0.08,
                    },
					resetPriorityMarkers = {
						order = 4,
						type = "execute",
						name = "Reset Class Markers",
						desc = "Resets the class priority markers to their default values.",
						func = function() StaticPopup_Show("RESET_ALL_CONFIRM") end,
					},
				},
			},
			actionButtonsGroup = {
				order = 6,
				type = "group",
				name = "Manual Actions",
				inline = true,
				args = {
					markPlayersButton = {
						type = "execute",
						name = "Mark Players",
						func = function() self:MarkPlayers() end,
						order = 1,
					},
					divider = {
                        type = "description",
                        name = " ",
                        width = 0.2,
						order = 2,
                    },
					markPetsButton = {
						type = "execute",
						name = "Mark Pets",
						func = function() self:MarkPets() end,
						order = 3,
					},
					spacerr = {
                        order = 4,
                        type = "description",
                        name = " ",
                        width = "full",
						order = 4,
                    },
					unmarkPlayersButton = {
						type = "execute",
						name = "Unmark Players",
						func = function() self:UnmarkPlayers() end,
						order = 5,
					},
					dividerr = {
                        type = "description",
                        name = " ",
                        width = 0.2,
						order = 6,
                    },
					unmarkPetsButton = {
						type = "execute",
						name = "Unmark Pets",
						func = function() self:UnmarkPets() end,
						order = 7,
					},
				},
			},
		},
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name, self.name);
end

function ArenaMarker:HandleResetClick()
	-- loop through all settings and reset them to their default values
	for class, markerList in pairs(ArenaMarker.defaultClassMarkers) do
		ArenaMarker.db.profile.classMarkers[class] = deepCopy(markerList);
        ArenaMarker.relatives[class] = deepCopy(markerList);
	end

	LibStub("AceConfigRegistry-3.0"):NotifyChange("ArenaMarker");

	ArenaMarker:Print('Successfully reset all class priority markers to default settings.');
end


function ArenaMarker:RemoveSpaces(string)
    return string:gsub("%s+", "");
end


function ArenaMarker:GetClasses()
	for class in pairs(self.relatives) do
		table.insert(self.classes, class);
	end
end

function ArenaMarker:CapitalizeFirstLetter(str)
	return str:gsub("^%l", string.upper);
end

function ArenaMarker:CreateMinimapIcon()
	LibDBIcon:Register(self.name, {
		icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		OnClick = self.Toggle,
		OnTooltipShow = function(tt)
			tt:AddLine(self.name .. " |cff808080" .. GetAddOnMetadata(self.name, "Version"));
			tt:AddLine("|cffCCCCCCClick|r to open options");
			tt:AddLine("|cffCCCCCCDrag|r to move this button");
		end,
		text = self.name,
		iconCoords = {0.05, 0.95, 0.05, 0.95},
	});
	
	C_Timer.After(0.25, function ()
		if #self.db.profile.minimapCoords > 0 then
			LibDBIcon:GetMinimapButton(self.name):SetPoint(unpack(self.db.profile.minimapCoords));
		end
		LibDBIcon:GetMinimapButton(self.name):SetScript("OnDragStop", function (self)
			self:SetScript("OnUpdate", nil);
			self.isMouseDown = false;
			self.icon:UpdateCoord();
			self:UnlockHighlight();

			local point, relativeFrame, relativePoint, x, y = self:GetPoint();
			ArenaMarker.db.profile.minimapCoords = {point, relativeFrame:GetName(), relativePoint, x, y};
		end);
		LibDBIcon:GetMinimapButton(self.name):SetShown(not self.db.profile.hideMinimap);
	end);
end

local defaults = {
    profile = {
		allowPets = true,
		markSummonedPets = true,
		petDropDownMarkerID = -1,
		petDropDownTwoMarkerID = -1,
		petDropDownThreeMarkerID = -1,
		classMarkerDropDownMarkerID = -1,
		selectedClass = "",
		classMarkers = {},
		minimapCoords = {},
		hideMinimap = false,
    }
};

function ArenaMarker:LoadStaticDialogs()
	StaticPopupDialogs["RESET_ALL_CONFIRM"] = {
		text = "Are you sure you want to reset class priority marker options?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = ArenaMarker.HandleResetClick,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	};
end

function ArenaMarker:Options(txt)
	if txt == "" then return self.optionsHandlerTable['options']() end
	for option, func in pairs(self.optionsHandlerTable) do
		if option == txt then
			func();
		end
	end
end


function ArenaMarker:OnInitialize()
	-- initialize saved variables with defaults
	self.db = LibStub("AceDB-3.0"):New(self.name.."DB", defaults, true);

	-- events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "IsOutOfArena");
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "Main");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "HandleUnitSpellCastSucceeded");
	
	SLASH_ARENAMARKER1 = "/am";
    SLASH_ARENAMARKER2 = "/arenamarker";
    SlashCmdList["ARENAMARKER"] = function(msg)
        self:Options(msg);
    end

	if not self.db.profile.classMarkers then
		for class, markerList in pairs(self.relatives) do
			self.db.profile.classMarkers[class] = deepCopy(markerList);
		end
	end
	
	-- place all class/marker combinations into relatives
	for class, markerList in pairs(self.db.profile.classMarkers) do
		self.relatives[class] = markerList;
	end

	self:GetClasses();
	self:CreateMenu();
	self:LoadStaticDialogs();
	self:HandleLogin();
	
	self:CreateMinimapIcon();
end

function ArenaMarker:UpdatePriorityMarker(class, newMarker)
	class = self:RemoveSpaces(class):upper();
	-- if the new marker is already prioritized, do nothing
	if self.relatives[class][1] == newMarker then return end

	self.relatives[class][1] = newMarker;

	-- update the DB
	self.db.profile.classMarkers[class][1] = self.relatives[class][1];

	-- get class/marker color combo
	local classColor = "|c" .. RAID_CLASS_COLORS[class].colorStr;

	local markerColor = self.RAID_TARGET_COLORS[self.markerValues[newMarker]];

	self:Print('Updated priority marker for ' .. classColor .. class:sub(1,1) .. class:sub(2):lower() .. '|r to '.. markerColor .. newMarker:sub(1,1):upper() .. newMarker:sub(2) .. "|r.");
end

function ArenaMarker:HandleLogin()
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" ..
		self.name ..
		"|r by " ..
		"|cff69CCF0" ..
		GetAddOnMetadata(self.name, "Author") ..
		"|r." ..
    	" Type |cff33ff99/am|r for the available commands."
	);
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

function deepCopy(orig)
    local orig_type = type(orig);
    local copy;
    if orig_type == 'table' then
        copy = {};
        for origKey, origValue in next, orig, nil do
            copy[deepCopy(origKey)] = deepCopy(origValue);
        end
        setmetatable(copy, deepCopy(getmetatable(orig)));
    else -- number, string, boolean, etc
        copy = orig;
    end
    return copy;
end
