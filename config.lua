--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace
local Config = core.Config;
local UIConfig;
core.allowPets = true; -- adds allowPets variable to addon namespace


--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
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
	UIConfig:Hide();
	return UIConfig;
end
