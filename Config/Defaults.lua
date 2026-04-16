local addonName, BetterHeals = ...

BetterHeals.Defaults = {
    profile = {
        enabled = true,
        ui = {
            iconSize = 52,
            spacing = 10,
            position = {
                point = "CENTER",
                relativePoint = "CENTER",
                x = 0,
                y = -120,
            },
            alpha = 1,
        },
        mode = {
            autoDetect = true,
            forced = nil,
        },
        debug = false,
    },
}

function BetterHeals:InitializeDatabase()
    BetterHealsDB = BetterHealsDB or {}
    BetterHealsDB.profile = BetterHealsDB.profile or {}

    for key, value in pairs(self.Defaults.profile) do
        if BetterHealsDB.profile[key] == nil then
            if type(value) == "table" then
                BetterHealsDB.profile[key] = CopyTable(value)
            else
                BetterHealsDB.profile[key] = value
            end
        end
    end

    self.db = BetterHealsDB
end
