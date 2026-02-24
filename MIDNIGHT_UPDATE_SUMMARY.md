# caelUI Midnight (12.0.2) Update Summary

## Overview
This addon collection has been updated from Cataclysm (Interface 40300/40000) to WoW Midnight (Interface 120002).

## Major Changes

### 1. TOC Files (32 files updated)
All `.toc` files have been updated from `## Interface: 40300` or `40000` to `## Interface: 120002`

### 2. API Compatibility Layer (`caelUI/engine.lua`)
Added comprehensive compatibility wrappers for deprecated APIs:

#### Spell & Item Info
- `GetSpellInfo()` → Wrapped to use `C_Spell.GetSpellInfo()` with old return format
- `GetItemInfo()` → Wrapped to use `C_Item.GetItemInfo()` with old return format

#### Party/Raid Functions  
- `GetNumPartyMembers()` → Replaced with `IsInGroup()` and `GetNumGroupMembers()`
- `GetNumRaidMembers()` → Replaced with `IsInRaid()` and `GetNumGroupMembers()`
- Event redirects: `PARTY_MEMBERS_CHANGED` → `GROUP_ROSTER_UPDATE`
- Event redirects: `RAID_ROSTER_UPDATE` → `GROUP_ROSTER_UPDATE`

#### Power & Resources
- `GetComboPoints()` → Replaced with `UnitPower(unit, Enum.PowerType.ComboPoints)`
- `UnitMana()` / `UnitManaMax()` → Replaced with `UnitPower(unit, 0)` / `UnitPowerMax(unit, 0)`

#### UI & Display
- `GetQuestDifficultyColor()` → Added wrapper for `C_QuestLog.GetQuestDifficultyColor()`
- `PlaySound()` → Added mapping for string-based sound names to SOUNDKIT IDs
- `UnitAura()` → Added compatibility wrapper for new C_UnitAuras API

#### Container/Bags
- `GetContainerNumSlots()` → Wrapped to use `C_Container.GetContainerNumSlots()`
- `GetContainerItemInfo()` → Wrapped to use `C_Container.GetContainerItemInfo()`

#### Talents & Specs
- `GetPrimaryTalentTree()` → Wrapped to use `GetSpecialization()`

#### Constants
- Ensured `MAX_COMBO_POINTS = 5`
- Ensured `MAX_PARTY_MEMBERS = 4`

### 3. Direct Code Updates

#### Party/Raid Function Replacements
- **recThreatMeter/recThreatMeter.lua**: Updated group member iteration logic
- **caelLoot/caelLoot.lua**: Updated solo detection
- **caelInterrupt/caelInterrupt.lua**: Updated group member checking
- **caelCCBreak/caelCCBreak.lua**: Updated party member count
- **caelBossWhisperer/caelBossWhisperer.lua**: Updated raid member iteration
- **caelUI/modules/miscellaneous/commands.lua**: Updated group disband and raid assist commands
- **caelUI/modules/miscellaneous/auto_loot.lua**: Updated solo detection
- **caelThreat/caelThreat.lua**: Updated group detection

#### Power/Combo Point Updates
- **caelCombatLog/caelCombatLog.lua**: Updated combo point detection
- **fComboBar/fComboBar.lua**: Updated combo point retrieval
- **oUF_Caellian/main.lua**: Updated mana/power access

#### Spell Info Updates
- **caelUI/core/functions.lua**: Updated `GetSpellName()` helper to use `C_Spell.GetSpellInfo()`

## Class-Specific Mechanics

### Still Supported (with compatibility)
- **Death Knight**: Runes system (may need additional oUF updates)
- **Paladin**: Holy Power
- **Warlock**: Soul Shards
- **Shaman**: Totem Bar (via oUF_TotemBar addon)

### Deprecated/Removed
- **Druid**: Eclipse Bar (removed in Legion, code remains but won't function)

## Known Limitations

1. **Eclipse Bar** - Druid Eclipse mechanics were removed in Legion (7.x). The UI code remains but will not display.
2. **Totem System** - Shaman totem mechanics changed significantly. The oUF_TotemBar may need updates.
3. **Class-Specific Resources** - Some Cataclysm-era class mechanics may not work as expected in Midnight.
4. **UnitAura** - The wrapper provides basic compatibility but complex aura filtering may need testing.

## Testing Recommendations

1. Test all addons in-game with various classes
2. Verify party/raid functionality with actual groups
3. Check class-specific resource displays (Holy Power, Soul Shards, etc.)
4. Validate spell and item tooltips display correctly
5. Test bag/container functionality
6. Verify sound effects play correctly

## Files Modified

### TOC Files (32)
All addon .toc files in the collection

### Lua Files (12)
- caelUI/engine.lua (major compatibility layer)
- caelUI/core/functions.lua
- recThreatMeter/recThreatMeter.lua
- caelLoot/caelLoot.lua
- caelInterrupt/caelInterrupt.lua
- caelCCBreak/caelCCBreak.lua
- caelBossWhisperer/caelBossWhisperer.lua
- caelUI/modules/miscellaneous/commands.lua
- caelUI/modules/miscellaneous/auto_loot.lua
- caelThreat/caelThreat.lua
- caelCombatLog/caelCombatLog.lua
- fComboBar/fComboBar.lua
- oUF_Caellian/main.lua

## Next Steps

1. **In-Game Testing**: Load the addons in WoW Midnight and test basic functionality
2. **oUF Updates**: Consider updating to the latest oUF version for better Midnight compatibility
3. **Class Review**: Test each class to ensure resource displays work correctly
4. **Performance**: Monitor for any performance issues with the compatibility wrappers

## Compatibility Notes

The compatibility layer in `engine.lua` provides backward compatibility for most deprecated APIs. This approach:
- ✅ Minimizes code changes across the addon collection
- ✅ Maintains original addon logic and structure  
- ✅ Automatically handles event name redirects
- ⚠️ May have slight performance overhead from wrapper functions
- ⚠️ Some complex APIs (like UnitAura) may need additional refinement

---
*Update completed: February 24, 2026*
*Target Version: WoW Midnight (Interface 120002)*
