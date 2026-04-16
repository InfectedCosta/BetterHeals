# BetterHeals

A World of Warcraft Retail addon that acts as a **Restoration Druid healing companion**.

## Current baseline (v0.1 scaffold)

- Detects content mode: **Raid**, **Mythic+**, or open world.
- Renders a center-screen **3-icon recommendation strip**:
  - middle icon = best next spell,
  - left/right icons = follow-up options.
- Provides initial recommendation reasoning tags:
  - `RAMP`, `DUMP`, `MAINTAIN`, `STABILIZE`, `DEFENSIVE`, `PREP`.
- Includes a starter restoration druid priority model with rationale.

## Addon files

- `BetterHeals.toc`
- `BetterHeals.lua`
- `Config/Defaults.lua`
- `Core/Context.lua`
- `Core/Rotation.lua`
- `UI/Display.lua`
- `Docs/RESTO_DRUID_PRIORITIES.md`

## Slash commands

- `/bh unlock` -> drag UI
- `/bh lock` -> lock UI
- `/bh raid` -> force raid mode
- `/bh m+` -> force mythic+ mode
- `/bh auto` -> auto detect mode
- `/bh debug` -> debug logging

## Next milestones

1. Warcraft Logs ingestion layer (per-encounter timelines and damage windows).
2. Fight package format to map logs patterns into ramp windows.
3. Config UI for editing priority thresholds and spell ordering in-game.
4. Cooldown manager timeline panel synced to recommendation engine.
