local Timers = unpack(select(2, ...)).NewModule("ClassTimers", true)

local media = Timers:GetMedia()

local BAR_HEIGHT = 25

--[[
local aura_colors  = {
    ["Magic"]   = {r = 0.00, g = 0.25, b = 0.45}, 
    ["Disease"] = {r = 0.40, g = 0.30, b = 0.10}, 
    ["Poison"]  = {r = 0.00, g = 0.40, b = 0.10}, 
    ["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
    ["None"]    = {r = 0.69, g = 0.31, b = 0.31}
}
--]]

do 
    local frame = CreateFrame("Frame", Timers:GetName() .. "PlayerFrame", Timers)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", -278.5, 370)
    frame:SetSize(230, 600)
    frame:Show()

    frame = CreateFrame("Frame", Timers:GetName() .. "TargetFrame", Timers)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 278.5, 370)
    frame:SetSize(230, 600)
    frame:Show()
end

local bar_prototype = {
    __index = {},
    height = BAR_HEIGHT,
    width = 100
}

local bars = {}

local UpdateBars

do
    local timers_metatable = getmetatable(Timers).__index

    for key, value in next, timers_metatable do
        bar_prototype.__index[key] = value
    end
end

function bar_prototype.__index:Create(spellId, unit, buffType, playerOnly, autoColor, frame)
    local bar = CreateFrame("StatusBar", string.format(Timers:GetName() and Timers:GetName() .. "Bar%d" or "TimerBar%d", (#bars + 1 or 0)), _G[Timers:GetName() .. frame:gsub("%a", string.upper, 1) .. "Frame"])

    -- SmoothBar(bar)
    bar:SetPoint("BOTTOMRIGHT", bar:GetParent(), "BOTTOMRIGHT")
    bar:SetSize(bar:GetParent():GetWidth() - BAR_HEIGHT, BAR_HEIGHT)
    bar:CreateBackdrop(bar:GetName())

    bar.texture = bar:CreateTexture(nil, "ARTWORK")
    bar.texture:SetAllPoints()
    bar.texture:SetTexture(media.files.statusbar_g)

    bar.texture:SetVertexColor(51 / 255, 51 / 255, 51 / 255)
    -- if buffType == "debuff" then
    --     bar.texture:SetVertexColor(0.69, 0.31, 0.31, 1)
    -- else
    --     bar.texture:SetVertexColor(0.33, 0.59, 0.33, 1)
    -- end

    bar.icon = bar:CreateTexture("$parentIcon", "BACKGROUND")
    bar.icon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
    bar.icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
    bar.icon:SetTexture("")
    bar.icon:CreateBackdrop(bar.icon:GetName())

    bar:SetStatusBarTexture(bar.texture)

    bar.spell = bar:CreateFontString("$parentSpellName", "OVERLAY")
    bar.spell:SetFont(media.fonts.normal, 10)
    local spellName = GetSpellInfo(spellId)
    bar.spell:SetText(spellName or "Unknown")
    bar.spell:SetPoint("LEFT", bar, "LEFT", 3, 0)
    bar.spell:SetJustifyH("LEFT")

    bar.stacks = bar:CreateFontString("$parentStackCount", "OVERLAY")
    bar.stacks:SetFont(media.fonts.normal, 10)
    bar.stacks:SetPoint("LEFT", bar.spell, "RIGHT")
    bar.stacks:SetJustifyH("LEFT")

    bar.time = bar:CreateFontString("$parentTimer", "OVERLAY")
    bar.time:SetFont(media.fonts.normal, 10)
    bar.time:SetPoint("RIGHT", bar, "RIGHT", -3, 0)
    bar.time:SetJustifyH("RIGHT")

    bar.spark = bar:CreateTexture("$parentSpark", "OVERLAY")
    bar.spark:SetTexture([[Interface/CastingBar/UI-CastingBar-Spark]])
    bar.spark:SetSize(15, 25)
    bar.spark:SetBlendMode("ADD")
    bar.spark:Show()

    bar.spellId    = spellId
    bar.unit       = unit
    bar.buffType   = buffType
    bar.playerOnly = playerOnly
    bar.autoColor  = autoColor
    bar.count      = 0
    bar.active     = false
    bar.expiration = 0
    bar.duration   = 0
    bar.auraType   = buffType == "debuff" and "HARMFUL" or "HELPFUL"

    bar.Place = function(self, last)
        if not last then
            self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT")
        else
            self:SetPoint("BOTTOMRIGHT", last, "TOPRIGHT", 0, 5)
        end
    end

    bar.Update = function(self)
        local spellName = GetSpellInfo(self.spellId)
        if not spellName then return false end
        
        local filter = self.playerOnly and "PLAYER" or ""
        if self.auraType == "HARMFUL" then
            filter = filter == "" and "HARMFUL" or filter .. "|HARMFUL"
        else
            filter = filter == "" and "HELPFUL" or filter .. "|HELPFUL"
        end
        
        -- Search for the aura by name
        for index = 1, 100 do
            local name, icon, count, auraType, duration, expiration = UnitAura(self.unit, index, filter)
            
            if not name then
                break
            end
            
            if name == spellName then
                self.icon:SetTexture(icon)
                self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                self.count = count or 0
                self.expiration = expiration or 0
                self.duration = duration or 0

                if self.buffType == "debuff" and self.autoColor then
                    local debuffColor = DebuffTypeColor[auraType or "none"]
                    if debuffColor then
                        self.texture:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b, 1)
                    end
                end

                return true
            end
        end

        return false
    end

    bar.Enable = function(self, update_bars)
        self.active = true

        self:SetScript("OnUpdate", self.OnUpdate)

        self:Show()
    end

    bar.Disable = function(self, update_bars)
        self.count      = 0
        self.expiration = 0
        self.duration   = 0
        self.active     = false

        self:SetScript("OnUpdate", nil)

        self:Hide()
    end

    bar.OnUpdate = function(self)
        local remaining = self.expiration - GetTime()

        if remaining > 0 then
            self:SetValue(remaining)
            self:SetMinMaxValues(0, self.duration)

            self.stacks:SetText(string.format("%s", self.count > 1 and string.format(" - %d", self.count) or ""))
            self.time:SetText(string.format("%s", Timers:FormatTime(remaining)))

            self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * remaining / self.duration, 0)
        end
    end

    bar:SetScript("OnEvent", function(self, _, unit)
        if self.unit == unit then
            if not self:Update() then
                self:Disable()
            end

            UpdateBars(unit)
        end
    end)

    -- Make sure the bar gets hidden.
    bar:Hide()

    return bar
end

function UpdateBars(unit)

    -- Sort the bars.
    do
        local time = GetTime()
        local sorted

        repeat
            sorted = true

            for key, value in pairs(bars) do
                local nextBar = key + 1
                local nextBarValue = bars[nextBar]

                if nextBarValue == nil then
                    break
                end

                local currentRemaining = value.expiration == 0 and 4294967295 or math.max(value.expiration - time, 0)
                local nextRemaining = nextBarValue.expiration == 0 and 4294967295 or math.max(nextBarValue.expiration - time, 0)

                if currentRemaining < nextRemaining then
                    bars[key] = nextBarValue
                    bars[nextBar] = value
                    sorted = false
                end
            end

        until (sorted == true)
    end

    -- Redisplay the bars in the right location.
    do
        local last_player = nil
        local last_target = nil

        for _, bar in pairs(bars) do
            if bar.active then
                if bar:GetParent():GetName() == Timers:GetName() .. "PlayerFrame" then
                    bar:Place(last_player)
                    last_player = bar
                else
                    bar:Place(last_target)
                    last_target = bar
                end
            end
        end
    end
end

do
    local ids = {}

    function Timers:CreateList (list)
        local bar_table = setmetatable({}, bar_prototype)

        -- Create and save the bar we create to the bars table.
        for frame, barsList in pairs(list) do
            for _, bar in pairs(barsList) do
                if not tContains(ids, bar.spellId) then
                    table.insert(bars, bar_table:Create(bar.spellId, bar.unit, bar.buffType, bar.playerOnly, bar.autoColor, frame))
                    table.insert(ids, bar.spellId)
                end
            end
        end
    end
end

local displayed_ids = {}
local events_initialized = false

-- Initialize events once after addon is safely loaded
local function InitializeEvents()
    if events_initialized then
        return
    end
    events_initialized = true

    -- Register UNIT_AURA once for all bars
    Timers:RegisterEvent("UNIT_AURA", function(_, _, unit)
        for _, bar in pairs(bars) do
            if bar.active and bar.unit == unit then
                if not bar:Update() then
                    bar:Disable()
                end
            end
        end
    end)

    Timers:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, _, _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId)
        if spellId then

            if subEvent == "SPELL_AURA_APPLIED" then
                -- if UnitExists("focus") and not displayed_ids[spellId] then
                --     if (UnitIsFriend("player", "focus") and sourceGUID == UnitGUID("focus")) or (not UnitIsFriend("player", "focus") and destGUID == UnitGUID("focus")) then
                --     -- if (destGUID == UnitGUID("player")) then
                --         Timers:Print(string.format("Spell Name = %s :: Spell ID = %s", GetSpellInfo(spellId), spellId))
                --         displayed_ids[spellId] = true
                --     end
                -- end

                for _, bar in pairs(bars) do
                    if spellId == bar.spellId and destGUID == UnitGUID(bar.unit) then
                        bar:Update()
                        bar:Enable()

                        UpdateBars(bar.unit)
                        return
                    end
                end

            elseif subEvent == "SPELL_AURA_REFRESHED" then
                for _, bar in pairs(bars) do
                    if spellId == bar.spellId and (UnitExists(bar.unit) and destGUID == UnitGUID(bar.unit)) then
                        if bar:Update() then
                            bar:Enable()

                            UpdateBars(bar.unit)
                            return
                        end
                    end
                end

            -- This will handle special cases when a bar is being shown active but a debuff or buff overrides it providing the same benefit.
            elseif subEvent == "SPELL_AURA_REMOVED" then
                for _, bar in pairs(bars) do
                    if spellId == bar.spellId and (UnitExists(bar.unit) and destGUID == UnitGUID(bar.unit)) then
                        bar:Disable()
                        UpdateBars(bar.unit)
                        return
                    end
                end

            end

        end
    end)

    local function Update_Target (unit)
        if UnitExists(unit) then
            for _, bar in pairs(bars) do
                if bar.unit == unit then
                    if bar:Update() then
                        bar:Enable(false)
                    else
                        bar:Disable(false)
                    end
                end
            end
        else
            for _, bar in pairs(bars) do
                if bar.unit == unit then
                    bar:Disable(false)
                end
            end
        end

        if unit == "focus" then
            UpdateBars("player")
            UpdateBars("target")
        else
            UpdateBars(unit)
        end
    end

    Timers:RegisterEvent("PLAYER_TARGET_CHANGED", function() Update_Target("target") end)
    Timers:RegisterEvent("PLAYER_FOCUS_CHANGED", function() Update_Target("focus") end)
end

-- Create an initialization frame that doesn't use the event system during load
local init_frame = CreateFrame("Frame")
init_frame:RegisterEvent("ADDON_LOADED")
init_frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "caelUI" and not events_initialized then
        -- Now that we're in a safe context, initialize all events
        InitializeEvents()
        
        -- Register the PLAYER_ENTERING_WORLD handler
        Timers:RegisterEvent("PLAYER_ENTERING_WORLD", function()
            -- Handle bar updates for player
            for _, bar in pairs(bars) do
                if bar.unit == "player" and bar:Update() then
                    bar:Enable(false)
                end
            end

            UpdateBars("player")
        end)
        
        -- We only need to do this once
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

Timers:RegisterModule()
