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

local function GetGroupHealthSnapshot()
    local memberCount = 1

    if IsInRaid() then
        memberCount = GetNumGroupMembers()
    elseif IsInGroup() then
        memberCount = GetNumSubgroupMembers() + 1
    end

    return {
        members = memberCount,
        lowCount = 0,
        totalMissing = 0,
        averageMissing = 0,
        injured = 0,
        healthDataAvailable = false,
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

    local hasLifebloom = false
    local hasRejuv = false

    if lifebloomName then
        hasLifebloom = AuraUtil.FindAuraByName(lifebloomName, "target", "HELPFUL") ~= nil
    end

    if rejuvenationName then
        hasRejuv = AuraUtil.FindAuraByName(rejuvenationName, "target", "HELPFUL") ~= nil
    end

    return {
        mode = self:GetContentMode(),
        inCombat = UnitAffectingCombat("player"),
        mana = UnitPower("player", Enum.PowerType.Mana),
        maxMana = UnitPowerMax("player", Enum.PowerType.Mana),
        hasLifebloom = hasLifebloom,
        hasRejuv = hasRejuv,
        health = snapshot,
    }
end

Context.MODES = {
    OPEN_WORLD = MODE_OPEN_WORLD,
    RAID = MODE_RAID,
    MYTHIC_PLUS = MODE_MYTHIC_PLUS,
}
