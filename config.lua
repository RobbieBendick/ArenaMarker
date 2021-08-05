--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace
local Config = core.Config;
local UIConfig;
core.allowPets = true; -- adds allowPets variable to addon namespace
core.pets = {};
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

local function contains(table, x)
	for _, v in pairs(table) do
		if v == x then return true end
	end
	return false
end

local function removeValue(table, value)
    local key = table[value]
    table[value] = nil
    return key
end

local function findUsableMark(table, target)
    local marker = ""
    for k,v in pairs(table) do
        if v ~= nil then
            marker = k
            break
        end
    end
    SetRaidTarget(target, table[marker])
    removeValue(table, marker)
end

--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:UnmarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
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

function Config:MarkPets()
	-- if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
	if GetNumGroupMembers() > 5 then return end
	if UnitExists("pet") then
		if not GetRaidTargetIndex("pet") then
			findUsableMark(core.unused_markers, "pet")
		end
	end
	for i=1,GetNumGroupMembers()-1 do
		if UnitExists("party"..i.."pet") then
			if not GetRaidTargetIndex("party"..i.."pet") then
				findUsableMark(core.unused_markers, "party"..i.."pet")
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
	UIConfig.checkBtn1.text:SetText("  Mark Pets\n (when arena\n gates open)");
    UIConfig.checkBtn1.text:SetFontObject("GameFontHighlight");
    UIConfig.checkBtn1:SetChecked(true);
	UIConfig.checkBtn1:SetScript("OnClick", function() core.allowPets = UIConfig.checkBtn1:GetChecked() end);
	----------------------------------
	-- Unmark Pets Button
	----------------------------------
	UIConfig.unmarkPetsButton = CreateFrame("Button", nil, UIConfig.checkBtn1, "GameMenuButtonTemplate");
	UIConfig.unmarkPetsButton:SetPoint("CENTER", UIConfig.checkBtn1, "CENTER", 25, -45)
	UIConfig.unmarkPetsButton:SetSize(110,30)
	UIConfig.unmarkPetsButton:SetText("Unmark Pets")
	UIConfig.unmarkPetsButton:SetScript("OnClick", Config.UnmarkPets);
	----------------------------------
	-- Mark Pets Button
	----------------------------------
	UIConfig.markPetsButton = CreateFrame("Button", nil, UIConfig.unmarkPetsButton, "GameMenuButtonTemplate");
	UIConfig.markPetsButton:SetPoint("CENTER", UIConfig.unmarkPetsButton, "CENTER", 0, -45)
	UIConfig.markPetsButton:SetSize(110,30)
	UIConfig.markPetsButton:SetText("Mark Pets")
	UIConfig.markPetsButton:SetScript("OnClick", Config.MarkPets);

	
	UIConfig:Hide();
	return UIConfig;
end

local update = CreateFrame("FRAME")
local function updateHandler()
    if core.pets then
        for i,v in pairs(core.pets) do
            if not contains(core.unused_markers, v) then
                -- populate table, we placed the marker back.
                if v == 1 then
                    core.unused_markers["star"] = 1;
                    removeValue(core.pets, i);
                end
                if v == 2 then
                    core.unused_markers["circle"] = 2;
                    removeValue(core.pets, i);
                end
                if v == 3 then
                    core.unused_markers["diamond"] = 3;
                    removeValue(core.pets, i);
                end
                if v == 4 then
                    core.unused_markers["triangle"] = 4;
                    removeValue(core.pets, i);
                end
                if v == 5 then
                    core.unused_markers["moon"] = 5;
                    removeValue(core.pets, i);
                end
                if v == 6 then
                    core.unused_markers["square"] = 6;
                    removeValue(core.pets, i);
                end
                if v == 7 then
                    core.unused_markers["cross"] = 7;
                    removeValue(core.pets, i);
                end
                if v == 8 then
                    core.unused_markers["skull"] = 8;
                    removeValue(core.pets, i);
                end
            end
        end
    end
end
update:SetScript("OnUpdate", updateHandler)

local function login()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: /am for additional options.")
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