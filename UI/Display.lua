local _, BetterHeals = ...

BetterHeals.UI = {}

local UI = BetterHeals.UI
local frame
local slots = {}

local function CreateIcon(parent, index, size)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(size, size)

    if index == 1 then
        button:SetPoint("CENTER", parent, "CENTER")
    elseif index == 2 then
        button:SetPoint("RIGHT", slots[1], "LEFT", -BetterHeals.db.profile.ui.spacing, 0)
    else
        button:SetPoint("LEFT", slots[1], "RIGHT", BetterHeals.db.profile.ui.spacing, 0)
    end

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexture(134400)

    button.overlay = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.overlay:SetPoint("BOTTOM", button, "TOP", 0, 2)
    button.overlay:SetText("")

    button.reason = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.reason:SetPoint("TOP", button, "BOTTOM", 0, -3)
    button.reason:SetWidth(size * 2)
    button.reason:SetJustifyH("CENTER")
    button.reason:SetTextColor(0.8, 1, 0.8)
    button.reason:SetText("")

    return button
end

function UI:CreateMainFrame()
    frame = CreateFrame("Frame", "BetterHealsMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(240, 100)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        local ui = BetterHeals.db.profile.ui
        ui.position.point = point
        ui.position.relativePoint = relativePoint
        ui.position.x = x
        ui.position.y = y
    end)

    local ui = BetterHeals.db.profile.ui
    frame:SetPoint(ui.position.point, UIParent, ui.position.relativePoint, ui.position.x, ui.position.y)
    frame:SetAlpha(ui.alpha)

    slots[1] = CreateIcon(frame, 1, ui.iconSize)
    slots[2] = CreateIcon(frame, 2, ui.iconSize)
    slots[3] = CreateIcon(frame, 3, ui.iconSize)

    frame.header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.header:SetPoint("TOP", frame, "TOP", 0, -4)
    frame.header:SetText("BetterHeals: Next Cast")

    frame.modeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.modeLabel:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)

    frame:Show()
end

function UI:Update(recommendations, state)
    if not frame then
        return
    end

    for i = 1, 3 do
        local rec = recommendations and recommendations[i] or nil
        local slot = slots[i]

        if rec then
            slot.icon:SetTexture(rec.icon or 134400)
            slot.overlay:SetText(rec.tag or "")
            slot.reason:SetText(i == 1 and (rec.reason or "") or "")
            slot:Show()
        else
            slot.icon:SetTexture(134400)
            slot.overlay:SetText("")
            slot.reason:SetText("")
            slot:Show()
        end
    end

    frame.modeLabel:SetText(string.format("Mode: %s", state.mode or "UNKNOWN"))
end
