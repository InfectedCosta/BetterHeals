local _, BetterHeals = ...

BetterHeals.Context = {}

local Context = BetterHeals.Context

local MODE_OPEN_WORLD = "OPEN_WORLD"
local MODE_RAID = "RAID"
local MODE_MYTHIC_PLUS = "MYTHIC_PLUS"
local SPELLS = {
    REJUVENATION = 774,
    LIFEBLOOM = 33763,
}

local function GetSafeSpellName(spellID)
    if not spellID then
        return nil
    end

    return C_Spell.GetSpellName(spellID)
end

local function IsSafeNumber(value)
    return type(value) == "number"
end

local function SafeUnitHealth(unit)
    local current = UnitHealth(unit)
    local max = UnitHealthMax(unit)

    if not IsSafeNumber(current) or not IsSafeNumber(max) then
        return nil, nil
    end

    current = current + 0
    max = max + 0

    return current, max
end

local function GetGroupHealthSnapshot()
    local members = {}
    local totalMissing = 0

    local count = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    if count == 0 then
        local currentHealth, maxHealth = SafeUnitHealth("player")
        if not currentHealth or not maxHealth or maxHealth <= 0 then
            return {
                members = 1,
                lowCount = 0,
                totalMissing = 0,
                averageMissing = 0,
                injured = 0,
            }
        end

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
            local currentHealth, maxHealth = SafeUnitHealth(unit)
            if currentHealth and maxHealth and maxHealth > 0 then
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

    local _, instanceType = GetInstanceInfo()
    if instanceType == "raid" then
        return MODE_RAID
    end

    if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive() then
        return MODE_MYTHIC_PLUS
    end

    return MODE_OPEN_WORLD
end

function Context:BuildState()
    local snapshot = GetGroupHealthSnapshot()
    local lifebloomName = GetSafeSpellName(SPELLS.LIFEBLOOM)
    local rejuvenationName = GetSafeSpellName(SPELLS.REJUVENATION)

    return {
        mode = self:GetContentMode(),
        inCombat = UnitAffectingCombat("player"),
        mana = UnitPower("player", Enum.PowerType.Mana),
        maxMana = UnitPowerMax("player", Enum.PowerType.Mana),
        hasLifebloom = lifebloomName and AuraUtil.FindAuraByName(lifebloomName, "target", "HELPFUL") ~= nil or false,
        hasRejuv = rejuvenationName and AuraUtil.FindAuraByName(rejuvenationName, "target", "HELPFUL") ~= nil or false,
        health = snapshot,
    }
end

Context.MODES = {
    OPEN_WORLD = MODE_OPEN_WORLD,
    RAID = MODE_RAID,
    MYTHIC_PLUS = MODE_MYTHIC_PLUS,
}
