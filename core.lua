local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

local function markAndRaidAssistTeammates(self, event, ...)
    local members = GetNumGroupMembers()
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        arg1 = ...
        if IsActiveBattlefieldArena() and (string.find(arg1, "Thirty seconds until the Arena battle begins!") or (string.find(arg1, "Fifteen seconds until the Arena battle begins!"))) then
            if members > 1 then
                if UnitIsGroupLeader("player") then
                    ConvertToRaid()
                    if GetRaidTargetIndex("player") == nil then
                        SetRaidTarget("player", 8)
                    end
                    for i=1,4 do
                        --give assist
                        SendChatMessage("/assist "..UnitName("party"..i))
                        --mark party members
                        if GetRaidTargetIndex("party"..i) == nil then
                            SetRaidTarget("party"..i, i)
                        end
                    end
                end
            end
	end
    end
end

frame:SetScript("OnEvent", markAndRaidAssistTeammates)
