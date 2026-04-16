local _, BetterHeals = ...

BetterHeals.Context = {}

local Context = BetterHeals.Context

local MODE_OPEN_WORLD = "OPEN_WORLD"
local MODE_RAID = "RAID"
local MODE_MYTHIC_PLUS = "MYTHIC_PLUS"

local function AsNumber(value)
    return tonumber(value) or 0
end

local function GetGroupHealthSnapshot()
    local members = {}
    local totalMissing = 0

    local count = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    if count == 0 then
        local maxHealth = AsNumber(UnitHealthMax("player"))
        local currentHealth = AsNumber(UnitHealth("player"))
        local missing = maxHealth - currentHealth
        return {
            members = 1,
            lowCount = (currentHealth / math.max(maxHealth, 1)) < 0.70 and 1 or 0,
            totalMissing = missing,
            averageMissing = missing,
            injured = missing > 0 and 1 or 0,
        }
    end

    local lowCount = 0
    local injured = 0

    for i = 1, count do
        local unit = IsInRaid() and ("raid" .. i) or ("party" .. i)
        if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
            local maxHealth = AsNumber(UnitHealthMax(unit))
            local currentHealth = AsNumber(UnitHealth(unit))
            local missing = maxHealth - currentHealth
            local hpPercent = currentHealth / math.max(maxHealth, 1)

            totalMissing = totalMissing + missing
            injured = injured + (missing > 0 and 1 or 0)

            if hpPercent < 0.70 then
                lowCount = lowCount + 1
            end

            members[#members + 1] = {
                unit = unit,
                hpPercent = hpPercent,
                missing = missing,
            }
        end
    end

    return {
        members = math.max(#members, 1),
        lowCount = lowCount,
        totalMissing = totalMissing,
        averageMissing = totalMissing / math.max(#members, 1),
        injured = injured,
    }
end

function Context:GetContentMode()
    if BetterHeals.db.profile.mode.forced then
        return BetterHeals.db.profile.mode.forced
    end

    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "raid" then
        return MODE_RAID
    end

    if instanceType == "party" and difficultyID == 8 then
        return MODE_MYTHIC_PLUS
    end

    return MODE_OPEN_WORLD
end

function Context:BuildState()
    local snapshot = GetGroupHealthSnapshot()

    return {
        mode = self:GetContentMode(),
        inCombat = UnitAffectingCombat("player"),
        mana = UnitPower("player", Enum.PowerType.Mana),
        maxMana = UnitPowerMax("player", Enum.PowerType.Mana),
        hasLifebloom = AuraUtil.FindAuraByName(GetSpellInfo(33763), "target", "HELPFUL") ~= nil,
        hasRejuv = AuraUtil.FindAuraByName(GetSpellInfo(774), "target", "HELPFUL") ~= nil,
        health = snapshot,
    }
end

Context.MODES = {
    OPEN_WORLD = MODE_OPEN_WORLD,
    RAID = MODE_RAID,
    MYTHIC_PLUS = MODE_MYTHIC_PLUS,
}
