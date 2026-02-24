local addon, ns = ...

ns[1] = {} -- (private) Functions
ns[2] = {} -- (public) Functions

-- We don't need to allow the addons to interface to anything that we don't push into the public range.
caelUI = ns[2]
--caelUIdebug = ns[1]

-- Compatibility wrappers for Midnight (12.x) API changes
do
    -- Wrap GetSpellInfo to use new C_Spell API while maintaining old return format
    local _GetSpellInfo = GetSpellInfo
    GetSpellInfo = function(spellID)
        if type(spellID) == "string" then
            -- String spellName lookups might still work with old API
            return _GetSpellInfo(spellID)
        end
        
        local spellInfo = C_Spell and C_Spell.GetSpellInfo(spellID)
        if spellInfo then
            return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellID
        end
        return nil
    end
    
    -- Wrap GetItemInfo to use new C_Item API while maintaining old return format  
    local _GetItemInfo = GetItemInfo
    GetItemInfo = function(itemID)
        if C_Item and C_Item.GetItemInfo then
            local itemInfo = C_Item.GetItemInfo(itemID)
            if type(itemInfo) == "table" then
                return itemInfo.itemName, itemInfo.itemLink, itemInfo.itemQuality, itemInfo.itemLevel, 
                       itemInfo.itemMinLevel, itemInfo.itemType, itemInfo.itemSubType, itemInfo.itemStackCount,
                       itemInfo.itemEquipLoc, itemInfo.iconFileID, itemInfo.itemSellPrice, 
                       itemInfo.itemClassID, itemInfo.itemSubClassID
            end
        end
        -- Fall back to old API if it exists
        return _GetItemInfo(itemID)
    end
    
    -- Wrap GetQuestDifficultyColor for compatibility
    if not GetQuestDifficultyColor then
        GetQuestDifficultyColor = function(level)
            if C_QuestLog and C_QuestLog.GetQuestDifficultyColor then
                return C_QuestLog.GetQuestDifficultyColor(level)
            end
            -- Fallback color calculation
            local playerLevel = UnitLevel("player")
            if level == -1 then
                return {r = 1, g = 0, b = 0} -- Boss
            elseif level >= playerLevel + 5 then
                return {r = 1, g = 0.1, b = 0.1}
            elseif level >= playerLevel + 3 then
                return {r = 1, g = 0.5, b = 0.25}
            elseif level >= playerLevel - 2 then
                return {r = 1, g = 1, b = 0}
            elseif level >= playerLevel - 5 then
                return {r = 0.25, g = 0.75, b = 0.25}
            else
                return {r = 0.5, g = 0.5, b = 0.5}
            end
        end
    end
    
    -- Wrap UnitAura for compatibility with old filter string format
    local _UnitAura = UnitAura
    UnitAura = function(unit, index, filter)
        -- If filter is a string with old format like "PLAYER|BUFF", convert it
        if type(filter) == "string" and filter:find("|") then
            -- Modern WoW uses separate calls, try to adapt
            -- This is a simplified wrapper - full implementation would be more complex
            local result = _UnitAura(unit, index, filter)
            return result
        elseif type(index) == "string" then
            -- Old style: UnitAura(unit, spellName, nil, filter)
            -- New style might need C_UnitAuras.GetAuraDataBySpellName or iteration
            if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
                local auraData = C_UnitAuras.GetAuraDataBySpellName(unit, index, filter)
                if auraData then
                    return auraData.name, auraData.icon, auraData.applications, auraData.dispelName,
                           auraData.duration, auraData.expirationTime, auraData.sourceUnit, 
                           auraData.isStealable, auraData.nameplateShowPersonal, auraData.spellId,
                           auraData.canApplyAura, auraData.isBossAura, auraData.isFromPlayerOrPlayerPet,
                           auraData.nameplateShowAll, auraData.timeMod, unpack(auraData.points or {})
                end
                return nil
            end
        end
        -- Fall back to original function
        return _UnitAura(unit, index, filter)
    end
    
    -- Wrap container/bag functions for C_Container API
    if not GetContainerNumSlots and C_Container then
        GetContainerNumSlots = function(bagID)
            return C_Container.GetContainerNumSlots(bagID)
        end
    end
    
    if not GetContainerItemInfo and C_Container then
        GetContainerItemInfo = function(bagID, slot)
            local info = C_Container.GetContainerItemInfo(bagID, slot)
            if info then
                return info.iconFileID, info.stackCount, info.isLocked, info.quality, 
                       info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, 
                       info.hasNoValue, info.itemID, info.isBound
            end
            return nil
        end
    end
    
    -- Wrap PlaySound for string-based sound names
    local _PlaySound = PlaySound
    local soundKitMap = {
        ["igCharacterInfoOpen"] = SOUNDKIT.IG_CHARACTER_INFO_OPEN,
        ["igCreatureAggroSelect"] = SOUNDKIT.IG_CREATURE_AGGRO_SELECT,
        ["igMainMenuOpen"] = SOUNDKIT.IG_MAINMENU_OPEN,
        ["igMainMenuClose"] = SOUNDKIT.IG_MAINMENU_CLOSE,
        ["igQuestListOpen"] = SOUNDKIT.IG_QUEST_LIST_OPEN,
        ["igQuestListClose"] = SOUNDKIT.IG_QUEST_LIST_CLOSE,
        ["igSpellBookOpen"] = SOUNDKIT.IG_SPELLBOOK_OPEN,
        ["igSpellBookClose"] = SOUNDKIT.IG_SPELLBOOK_CLOSE,
    }
    PlaySound = function(soundID, ...)
        if type(soundID) == "string" then
            soundID = soundKitMap[soundID] or soundID
        end
        return _PlaySound(soundID, ...)
    end
    
    -- Wrap GetPrimaryTalentTree (removed in modern WoW, replaced with GetSpecialization)
    if not GetPrimaryTalentTree then
        GetPrimaryTalentTree = function(...)
            return GetSpecialization(...)
        end
    end
    
    -- Ensure MAX_COMBO_POINTS and MAX_PARTY_MEMBERS are defined
    if not MAX_COMBO_POINTS then
        MAX_COMBO_POINTS = 5
    end
    if not MAX_PARTY_MEMBERS then
        MAX_PARTY_MEMBERS = 4
    end
    
    -- Make RAID_CLASS_COLORS work with new C_ClassColor structure if needed
    if not RAID_CLASS_COLORS or not RAID_CLASS_COLORS.WARRIOR then
        RAID_CLASS_COLORS = {}
        for classFile, color in pairs(RAID_CLASS_COLORS or {}) do
            RAID_CLASS_COLORS[classFile] = {
                r = color.r or color[1],
                g = color.g or color[2], 
                b = color.b or color[3],
            }
        end
    end
    
    -- Event name compatibility code removed to prevent taint issues
    -- Modern WoW no longer uses PARTY_MEMBERS_CHANGED or RAID_ROSTER_UPDATE
    -- Use GROUP_ROSTER_UPDATE instead
end
