# Restoration Druid Priority Model (Starter)

This file defines **why** BetterHeals recommends a spell.

## Core language used by the addon

- **RAMP**: Build HoTs and throughput multipliers before/at the start of incoming damage.
- **DUMP**: Convert prepared HoTs and buffs into immediate healing via Regrowth/Swiftmend.
- **MAINTAIN**: Keep mandatory effects up (Lifebloom/Rejuvenation).
- **STABILIZE/DEFENSIVE**: Prevent deaths first (Ironbark, Swiftmend, externals).

## Raid baseline priorities

1. If many players are low -> `Wild Growth` then `Flourish` (ramp).
2. If deaths are likely in next globals -> `Swiftmend` / spot heal (stabilize).
3. Keep `Rejuvenation` and `Lifebloom` coverage active (maintain).
4. `Regrowth` becomes dump when triage is required.

## Mythic+ baseline priorities

1. Detect group spike damage -> mini-ramp with `Wild Growth`.
2. Protect tank/focus target with `Ironbark`.
3. Use `Regrowth` dumps for emergency single target recovery.
4. Keep `Lifebloom` and `Rejuvenation` running for mastery + efficiency.

## Warcraft Logs integration target

Future versions will load encounter fingerprints from Warcraft Logs and annotate:

- expected heavy damage windows,
- healer cooldown overlap zones,
- mechanic-specific ramp offsets (e.g., ramp 8s before event),
- high-value targets for externals.

Those insights should override generic priority timing while preserving the same recommendation tags.
