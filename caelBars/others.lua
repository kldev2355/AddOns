local _, caelBars = ...

local PixelScale = caelUI.config.PixelScale

-----------------------------------------------
-- Hide default Blizzard frames we don't need
-----------------------------------------------

do
    -- Hide main action bar art
    if MainMenuBar then
        MainMenuBar:SetAlpha(0)
        MainMenuBar:SetScale(0.001)
        if MainMenuBar.UnregisterAllEvents then
            MainMenuBar:UnregisterAllEvents()
        end
    end
    
    -- Hide art frames
    local artFrames = {
        MainMenuBarArtFrame,
        MainMenuBarArtFrameBackground,
        MainMenuBarLeftEndCap,
        MainMenuBarRightEndCap,
        MainMenuBarTexture0,
        MainMenuBarTexture1,
        MainMenuBarTexture2,
        MainMenuBarTexture3,
        ActionBarPageNumber,
        StanceBarLeft,
        StanceBarMiddle,
        StanceBarRight,
        SlidingActionBarTexture0,
        SlidingActionBarTexture1,
        ActionBarDownButton,
        ActionBarUpButton,
        MainMenuBarBackpackButton,
        -- Micro buttons (old names)
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        AchievementMicroButton,
        QuestLogMicroButton,
        GuildMicroButton,
        LFDMicroButton,
        CollectionsMicroButton,
        EJMicroButton,
        StoreMicroButton,
        MainMenuMicroButton,
        -- Micro buttons (new names for 12.0+)
        ProfessionMicroButton,
        PlayerSpellsMicroButton,
        HelpMicroButton,
        -- Micro button containers
        MicroButtonAndBagsBar,
        MicroMenu,
        BagsBar,
    }
    
    for _, frame in pairs(artFrames) do
        if frame then
            frame.Show = frame.Hide
            frame:Hide()
            if frame.UnregisterAllEvents then
                frame:UnregisterAllEvents()
            end
        end
    end
    
    -- Hide other action bar related frames
    local actionFrames = {
        MainActionBarFrame,
        BonusActionBarFrame,
        VehicleMenuBar,
        PossessBarFrame,
        OverrideActionBar,
        StatusTrackingBarManager,
        MainMenuBarVehicleLeaveButton,
    }
    
    for _, frame in pairs(actionFrames) do
        if frame then
            frame.Show = frame.Hide
            frame:Hide()
            if frame.UnregisterAllEvents then
                frame:UnregisterAllEvents()
            end
        end
    end

    -- UI Parent Manager frame nil'ing
    if UIPARENT_MANAGED_FRAME_POSITIONS then
        for _, frame in next, {
            "MultiBarLeft", "MultiBarRight", "MultiBarBottomLeft", "MultiBarBottomRight",
            "ShapeshiftBarFrame",
            "PossessBarFrame", "PETACTIONBAR_YPOS",
            "MultiCastActionBarFrame", "MULTICASTACTIONBAR_YPOS",
        } do
            UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
        end
    end
end


---------------------------------
-- Toggle for mouseover on bars
---------------------------------

function caelBars.MouseOverBar(panel, bar, button, alpha)
    if bar ~= nil then
        bar:SetAlpha(alpha)
    end

    if panel ~= nil then
        panel:SetAlpha(alpha)
    end

    if button ~= nil then
        for index = 1, 12 do
            _G[button .. index]:SetAlpha(alpha)
        end
    end
end

----------------------
-- Setup button grid
----------------------

local buttonGrid = CreateFrame("Frame")
buttonGrid:RegisterEvent("PLAYER_ENTERING_WORLD")
buttonGrid:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    SetActionBarToggles(1, 1, 1, 1)

    if caelBars.settings.showGrid == true then
        for index = 1, 12 do
            local button = _G[format("ActionButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end

            button = _G[format("BonusActionButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end

            button = _G[format("MultiBarRightButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end

            button = _G[format("MultiBarBottomRightButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end

            button = _G[format("MultiBarLeftButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end

            button = _G[format("MultiBarBottomLeftButton%d", index)]
            if button then button:SetAttribute("showgrid", 1) end
        end
    end
end)

-------------------
-- SHAPESHIFT BAR
-------------------

if ShapeshiftBarFrame then
    local barShift = CreateFrame("Frame", "barShift", UIParent)
    barShift:ClearAllPoints()
    barShift:SetPoint("BOTTOMLEFT", caelPanel_ActionBar1, "TOPLEFT",  PixelScale(3), 0)
    barShift:SetWidth(29)
    barShift:SetHeight(58)

    -- Place buttons in the bar frame and set the barShift as the parent frame
    -- ShapeshiftBarFrame:GetParent():Hide()
    ShapeshiftBarFrame:SetParent(barShift)
    --ShapeshiftBarFrame:SetWidth(0.00001)
    for index = 1, NUM_SHAPESHIFT_SLOTS do
        local button = _G["ShapeshiftButton" .. index]
        local buttonPrev = _G["ShapeshiftButton" .. index - 1]
        button:ClearAllPoints()
        button:SetScale(0.68625)
        if index == 1 then
            button:SetPoint("BOTTOMLEFT", barShift, 0, PixelScale(2))
        else
            button:SetPoint("LEFT", buttonPrev, "RIGHT", PixelScale(2), 0)
        end
    end

    -- Hook the updating of the shapeshift bar
    local function MoveShapeshift()
        ShapeshiftButton1:SetPoint("BOTTOMLEFT", barShift, 0, PixelScale(2))
    end
    hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)
end

------------
-- PET BAR
------------

if PetActionBarFrame and _G["PetActionButton1"] then
    -- Create pet bar frame and put it into place
    local barPet = CreateFrame("Frame", "barPet", UIParent, "SecureHandlerStateTemplate")
    barPet:ClearAllPoints()
    barPet:SetWidth(PixelScale(120))
    barPet:SetHeight(PixelScale(47))
    barPet:SetPoint("BOTTOM", UIParent, PixelScale(-337), PixelScale(359))

    -- Setup Blizzard pet action bar.
    PetActionBarFrame:SetParent(barPet)
    PetActionBarFrame:SetWidth(0.01)

    -- Show grid for pet actionbar
    if caelBars.settings.showPetGrid == true then
        PetActionBar_ShowGrid()
    end

    -- function to toggle the display of the pet bar
    local function togglePetBar(alpha)
        for index = 1, NUM_PET_ACTION_SLOTS do
            local button = _G["PetActionButton" .. index]
            if button then
                button:SetAlpha(alpha)
            end
        end
    end

    do
        local button1 = _G["PetActionButton1"]
        for index = 1, NUM_PET_ACTION_SLOTS do
            local button = _G["PetActionButton" .. index]
            local buttonPrev = _G["PetActionButton" .. index - 1]

            if button then
                button:ClearAllPoints()

                -- Set Parent for position purposes
                button:SetParent(barPet)

                -- Set Scale for the button size.
                button:SetScale(0.63) 

                if index == 1 then
                    button:SetPoint("TOPLEFT", barPet, PixelScale(4.5), PixelScale(-4.5))
                elseif index == ((NUM_PET_ACTION_SLOTS / 2) + 1) then -- Get our middle button + 1 to make the rows even
                    button:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, PixelScale(-5))
                else
                    button:SetPoint("LEFT", buttonPrev, "RIGHT", PixelScale(4.5), 0)
                end

                -- Toggle buttons if mouse over is turned on.
                if caelBars.settings.mouseOverPetBar == true then
                    button:SetAlpha(0)
                    button:HookScript("OnEnter", function(self) togglePetBar(1) end)
                    button:HookScript("OnLeave", function(self) togglePetBar(0) end)
                end
            end
        end
    end

    -- Toggle pet bar if mouse over is turned on.
    if caelBars.settings.mouseOverPetBar == true then
        barPet:EnableMouse(true)
        barPet:SetScript("OnEnter", function(self) togglePetBar(1) end)
        barPet:SetScript("OnLeave", function(self) togglePetBar(0) end)
    end
end

--------------
-- TOTEMS BAR
--------------
local totemBar = _G["MultiCastActionBarFrame"]

if totemBar then
    totemBar:SetScript("OnUpdate", nil)
    totemBar:SetScript("OnShow", nil)
    totemBar:SetScript("OnHide", nil)
    totemBar:SetParent(caelPanel_ActionBar1)
    totemBar:ClearAllPoints()
    totemBar:SetPoint("BOTTOMLEFT", caelPanel_ActionBar1, "TOPLEFT", 0, PixelScale(2))
    totemBar:SetScale(0.75)

    hooksecurefunc("MultiCastActionButton_Update", function(self)
        if not InCombatLockdown() then
            self:SetAllPoints(self.slotButton)
        end
    end)
end

------------
-- VEHICLE
------------

-- Vehicle button
local vehicleExitButton = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")

vehicleExitButton:SetSize(PixelScale(33), PixelScale(33))
vehicleExitButton:SetPoint("BOTTOM", PixelScale(-146), PixelScale(263))

vehicleExitButton:RegisterForClicks("AnyUp")
vehicleExitButton:SetScript("OnClick", function() VehicleExit() end)

vehicleExitButton:SetNormalTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]=])
vehicleExitButton:SetPushedTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])
vehicleExitButton:SetHighlightTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])

vehicleExitButton:RegisterEvent("UNIT_ENTERING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicleExitButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
vehicleExitButton:SetScript("OnEvent", function(self, event, arg1)
    if (((event == "UNIT_ENTERING_VEHICLE") or (event == "UNIT_ENTERED_VEHICLE"))
        and arg1 == "player") then
        vehicleExitButton:SetAlpha(1)
    elseif (
        (
        (event == "UNIT_EXITING_VEHICLE") or (event == "UNIT_EXITED_VEHICLE")
        ) and
        arg1 == "player") or (
        event == "ZONE_CHANGED_NEW_AREA" and not UnitHasVehicleUI("player")
        ) then
        vehicleExitButton:SetAlpha(0)
    end
end)

vehicleExitButton:SetAlpha(0)
