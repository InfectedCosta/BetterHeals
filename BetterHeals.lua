local addonName, BetterHeals = ...

BetterHeals.frame = CreateFrame("Frame")

local function Debug(msg)
    if BetterHeals.db and BetterHeals.db.profile.debug then
        print(string.format("|cff33ff99%s|r %s", addonName, msg))
    end
end

local function RefreshRecommendations()
    if not BetterHeals.db.profile.enabled then
        return
    end

    local state = BetterHeals.Context:BuildState()
    local recommendations = BetterHeals.Rotation:GetRecommendations(state)
    BetterHeals.UI:Update(recommendations, state)

    if recommendations[1] then
        Debug(string.format("Next: %s (%s)", recommendations[1].name or "unknown", recommendations[1].tag or "-"))
    end
end

local function HandleSlashCommand(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if msg == "lock" then
        BetterHealsMainFrame:EnableMouse(false)
        print("BetterHeals: UI locked.")
        return
    end

    if msg == "unlock" then
        BetterHealsMainFrame:EnableMouse(true)
        print("BetterHeals: UI unlocked for dragging.")
        return
    end

    if msg == "raid" then
        BetterHeals.db.profile.mode.forced = BetterHeals.Context.MODES.RAID
        print("BetterHeals: Forced mode set to RAID.")
        RefreshRecommendations()
        return
    end

    if msg == "m+" or msg == "mythic" then
        BetterHeals.db.profile.mode.forced = BetterHeals.Context.MODES.MYTHIC_PLUS
        print("BetterHeals: Forced mode set to MYTHIC_PLUS.")
        RefreshRecommendations()
        return
    end

    if msg == "auto" then
        BetterHeals.db.profile.mode.forced = nil
        print("BetterHeals: Auto mode detection enabled.")
        RefreshRecommendations()
        return
    end

    if msg == "debug" then
        BetterHeals.db.profile.debug = not BetterHeals.db.profile.debug
        print("BetterHeals: Debug set to " .. tostring(BetterHeals.db.profile.debug))
        return
    end

    print("BetterHeals commands: /bh unlock, /bh lock, /bh raid, /bh m+, /bh auto, /bh debug")
end

SLASH_BETTERHEALS1 = "/betterheals"
SLASH_BETTERHEALS2 = "/bh"
SlashCmdList.BETTERHEALS = HandleSlashCommand

BetterHeals.frame:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" then
        BetterHeals:InitializeDatabase()
        BetterHeals.UI:CreateMainFrame()
        RefreshRecommendations()
        Debug("Addon loaded")
        return
    end

    RefreshRecommendations()
end)

BetterHeals.frame:RegisterEvent("ADDON_LOADED")
BetterHeals.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
BetterHeals.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
BetterHeals.frame:RegisterEvent("UNIT_HEALTH")
BetterHeals.frame:RegisterEvent("UNIT_AURA")
BetterHeals.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
BetterHeals.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
BetterHeals.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
