local _, BetterHeals = ...

BetterHeals.Rotation = {}

local Rotation = BetterHeals.Rotation
local MODES = BetterHeals.Context.MODES

local SPELLS = {
    REJUVENATION = 774,
    LIFEBLOOM = 33763,
    WILD_GROWTH = 48438,
    SWIFTMEND = 18562,
    REGROWTH = 8936,
    FLOURISH = 197721,
    TRANQUILITY = 740,
    CENARION_WARD = 102351,
    IRONBARK = 102342,
}

local function GetSafeSpellInfo(spellID)
    if not spellID then
        return nil
    end

    return C_Spell.GetSpellInfo(spellID)
end

local function GetSafeSpellName(spellID)
    if not spellID then
        return nil
    end

    return C_Spell.GetSpellName(spellID)
end

local function IsCastable(spellID)
    local usable, noMana = C_Spell.IsSpellUsable(spellID)
    local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
    local startTime = cooldownInfo and cooldownInfo.startTime or 0
    local duration = cooldownInfo and cooldownInfo.duration or 0
    local onCooldown = startTime > 0 and duration > 0 and (startTime + duration - GetTime()) > 0
    return usable and not noMana and not onCooldown
end

local function Recommendation(spellID, reason, tag)
    local spellInfo = GetSafeSpellInfo(spellID)
    return {
        spellID = spellID,
        icon = spellInfo and spellInfo.iconID,
        name = GetSafeSpellName(spellID),
        reason = reason,
        tag = tag,
    }
end

local function BuildRaidPriority(state)
    local list = {}
    local health = state.health
    local heavyRaidDamage = health.lowCount >= 4 or health.injured >= 8

    if heavyRaidDamage and IsCastable(SPELLS.FLOURISH) then
        list[#list + 1] = Recommendation(
            SPELLS.FLOURISH,
            "Amplify current HoTs before incoming raid damage windows.",
            "RAMP"
        )
    end

    if heavyRaidDamage and IsCastable(SPELLS.WILD_GROWTH) then
        list[#list + 1] = Recommendation(
            SPELLS.WILD_GROWTH,
            "Spread fast HoTs across injured raid members to start a healing ramp.",
            "RAMP"
        )
    end

    if health.lowCount >= 2 and IsCastable(SPELLS.SWIFTMEND) then
        list[#list + 1] = Recommendation(
            SPELLS.SWIFTMEND,
            "Use emergency spot stabilization before dumping Regrowth casts.",
            "STABILIZE"
        )
    end

    if IsCastable(SPELLS.REJUVENATION) and not state.hasRejuv then
        list[#list + 1] = Recommendation(
            SPELLS.REJUVENATION,
            "Keep Rejuvenation rolling to prep mastery and later Flourish value.",
            "RAMP"
        )
    end

    if health.lowCount >= 1 and IsCastable(SPELLS.REGROWTH) then
        list[#list + 1] = Recommendation(
            SPELLS.REGROWTH,
            "Dump Regrowth when players are in immediate danger after your HoT setup.",
            "DUMP"
        )
    end

    if #list == 0 and IsCastable(SPELLS.LIFEBLOOM) and not state.hasLifebloom then
        list[#list + 1] = Recommendation(
            SPELLS.LIFEBLOOM,
            "Maintain Lifebloom to power future Regrowth and sustain tank throughput.",
            "MAINTAIN"
        )
    end

    return list
end

local function BuildMythicPlusPriority(state)
    local list = {}
    local health = state.health
    local groupUnderPressure = health.lowCount >= 2 or health.averageMissing > 250000

    if groupUnderPressure and IsCastable(SPELLS.WILD_GROWTH) then
        list[#list + 1] = Recommendation(
            SPELLS.WILD_GROWTH,
            "Party-wide pressure detected; use Wild Growth to start a mini-ramp.",
            "RAMP"
        )
    end

    if health.lowCount >= 1 and IsCastable(SPELLS.IRONBARK) then
        list[#list + 1] = Recommendation(
            SPELLS.IRONBARK,
            "Protect a critical target before committing globals to Regrowth spam.",
            "DEFENSIVE"
        )
    end

    if health.lowCount >= 1 and IsCastable(SPELLS.REGROWTH) then
        list[#list + 1] = Recommendation(
            SPELLS.REGROWTH,
            "Dump Regrowth for immediate single-target recovery during dungeon spikes.",
            "DUMP"
        )
    end

    if IsCastable(SPELLS.LIFEBLOOM) and not state.hasLifebloom then
        list[#list + 1] = Recommendation(
            SPELLS.LIFEBLOOM,
            "Refresh Lifebloom to support tank healing and mana efficiency.",
            "MAINTAIN"
        )
    end

    if IsCastable(SPELLS.REJUVENATION) and not state.hasRejuv then
        list[#list + 1] = Recommendation(
            SPELLS.REJUVENATION,
            "Apply Rejuvenation for proactive mastery coverage.",
            "MAINTAIN"
        )
    end

    return list
end

function Rotation:GetRecommendations(state)
    if not state or not state.inCombat then
        return {
            Recommendation(SPELLS.REJUVENATION, "Out of combat: pre-HoT targets before pull.", "PREP"),
            Recommendation(SPELLS.LIFEBLOOM, "Out of combat: keep Lifebloom rolling on tank target.", "PREP"),
            Recommendation(SPELLS.CENARION_WARD, "Out of combat: preload ward for predictable damage.", "PREP"),
        }
    end

    if state.mode == MODES.RAID then
        return BuildRaidPriority(state)
    end

    if state.mode == MODES.MYTHIC_PLUS then
        return BuildMythicPlusPriority(state)
    end

    return {
        Recommendation(SPELLS.REJUVENATION, "General mode fallback: maintain HoTs.", "MAINTAIN"),
        Recommendation(SPELLS.REGROWTH, "General mode fallback: reactively top low targets.", "DUMP"),
    }
end
