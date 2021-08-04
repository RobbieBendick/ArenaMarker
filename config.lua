--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace
local Config = core.Config;
local UIConfig;
core.allowPets = true; -- adds allowPets variable to addon namespace
core.pets = {};




--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:UnmarkPets()
	if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if GetNumGroupMembers() > 5 then return end
	if UnitExists("pet") then
		if GetRaidTargetIndex("pet") then
			table.insert(core.pets, GetRaidTargetIndex("pet"))
			SetRaidTarget("pet", 0)
		end
	end
	for i=1,GetNumGroupMembers()-1 do
		if UnitExists("party"..i.."pet") then
			if GetRaidTargetIndex("party"..i.."pet") then
				table.insert(core.pets, GetRaidTargetIndex("party"..i.."pet"))
				SetRaidTarget("party"..i.."pet", 0)
			end
		end
	end
end

function Config:CreateMenu()
	UIConfig = CreateFrame("Frame", "ArenaMarkerConfig", UIParent, "BasicFrameTemplateWithInset");
	UIConfig:SetSize(180, 180);
	UIConfig:SetPoint("CENTER", 150, 50);

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
	UIConfig.checkBtn1.text:SetText("Mark Pets");
    UIConfig.checkBtn1:SetChecked(true);
	UIConfig.checkBtn1:SetScript("OnClick", function() core.allowPets = UIConfig.checkBtn1:GetChecked() end);
	----------------------------------
	-- Unmark Pets Button
	----------------------------------
	UIConfig.unmarkPetButton = CreateFrame("Button", nil, UIConfig.checkBtn1, "GameMenuButtonTemplate");
	UIConfig.unmarkPetButton:SetPoint("CENTER", UIConfig.checkBtn1, "CENTER", 25, -50)
	UIConfig.unmarkPetButton:SetSize(110,30)
	UIConfig.unmarkPetButton:SetText("Unmark Pets")
	UIConfig.unmarkPetButton:SetScript("OnClick", Config.UnmarkPets);
	
	UIConfig:Hide();
	return UIConfig;
end
