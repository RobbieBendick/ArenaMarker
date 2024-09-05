local _, core = ...;

local TEMP_WOW_CATA_CLASSIC_ID = 14;
if WOW_PROJECT_ID == TEMP_WOW_CATA_CLASSIC_ID then return end

core.Config = {};
local Config = core.Config;

function Config:Player_Login()
	Config:OnInitialize();
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
		ArenaMarkerDB.hideMinimap = false;
	end

	-- place all class/marker combinations into relatives
	for class, markerList in pairs(ArenaMarkerDB.classMarkers) do
		core.relatives[class] = markerList;
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" ..
		"ArenaMarker" ..
		"|r by " ..
		"|cff69CCF0" ..
		C_AddOns.GetAddOnMetadata("ArenaMarker", "Author") ..
		"|r loaded.");
end

