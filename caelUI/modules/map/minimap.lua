local Map = unpack(select(2, ...)).NewModule("Minimap", true)

-- Setup the Minimap container frame.
Map:SetSize(130)
Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
Map:CreateBackdrop(Map:GetName())

local function Initialize (self)
    for _, object in next, {
        GameTimeFrame,
        MinimapBorder,
        MinimapZoomIn,
        MinimapZoomOut,
        MinimapNorthTag,
        MinimapBorderTop,
        MinimapToggleButton,
        MiniMapWorldMapButton,
        MinimapZoneTextButton,
        MiniMapBattlefieldBorder,
        MiniMapTrackingBackground,
        MiniMapTrackingIconOverlay,
        MiniMapTrackingButtonBorder,
        MinimapCompassTexture,
    } do
        if object and object.GetObjectType then
            if object:GetObjectType() == "Texture" then
                object:SetTexture("")
            else
                object:Hide()
            end
        end
    end

    -- Hide compass texture
    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)

    Minimap:EnableMouse(true)
    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(frame, direction)
        if direction > 0 then
            Minimap_ZoomIn()
        else
            Minimap_ZoomOut()
        end
    end)

    Minimap:ClearAllPoints()
    Minimap:SetParent(self)
    Minimap:SetFrameLevel(self:GetFrameLevel() + 1)
    Minimap:SetPoint("CENTER")
    Minimap:SetSize(self:GetSize())

    Minimap:SetMaskTexture(self:GetMedia().files.background)
    --Minimap:SetBlipTexture([=[Interface\Addons\caelUI\media\miscellaneous\charmed.tga]=])

    MinimapCluster:EnableMouse(false)

    if MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:Hide()
    end

    if MinimapCluster.ZoneTextButton then
        MinimapCluster.ZoneTextButton:Hide()
    end

    if MiniMapBattlefieldFrame then
        MiniMapBattlefieldFrame:SetParent(Minimap)
        MiniMapBattlefieldFrame:ClearAllPoints()
        MiniMapBattlefieldFrame:SetPoint("TOPRIGHT")
    end

    if MiniMapTracking then
        MiniMapTracking:SetParent(Minimap)
        MiniMapTracking:ClearAllPoints()
        MiniMapTracking:SetPoint("TOPLEFT")
        MiniMapTracking:SetAlpha(0)
        MiniMapTracking:SetScale(0.0001)
    end

    if MinimapCluster.Tracking then
        MinimapCluster.Tracking:SetAlpha(0)
        MinimapCluster.Tracking:SetScale(0.0001)
    end

    if MiniMapTrackingButton then
        MiniMapTrackingButton:SetHighlightTexture(nil)
        MiniMapTrackingButton:SetScript("OnEnter", function() if MiniMapTracking then MiniMapTracking:SetAlpha(1) end end)
        MiniMapTrackingButton:SetScript("OnLeave", function() if MiniMapTracking then MiniMapTracking:SetAlpha(0) end end)
    end

    if MiniMapInstanceDifficulty then
        MiniMapInstanceDifficulty:ClearAllPoints()
        MiniMapInstanceDifficulty:SetParent(Minimap)
        self.SetPoint(MiniMapInstanceDifficulty, "TOPRIGHT", -5, 0)
        self.SetScale(MiniMapInstanceDifficulty, 0.75)
    end

    if GuildInstanceDifficulty then
        GuildInstanceDifficulty:ClearAllPoints()
        GuildInstanceDifficulty:SetParent(Minimap)
        self.SetPoint(GuildInstanceDifficulty, "TOPRIGHT", -5, 0)
        self.SetScale(GuildInstanceDifficulty, 0.75)
    end

    if DurabilityFrame then
        DurabilityFrame:UnregisterAllEvents()
    end
    if MiniMapMailFrame then
        MiniMapMailFrame:UnregisterAllEvents()
    end

    -- Housing overlay
    if MinimapBackdrop and MinimapBackdrop.StaticOverlayTexture then
        MinimapBackdrop.StaticOverlayTexture:SetAllPoints(Minimap)
        MinimapBackdrop.StaticOverlayTexture:SetTexCoord(.2, .8, .2, .8)
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

Map:RegisterEvent("PLAYER_ENTERING_WORLD", Initialize(Map))

do
    local farm = false

    function SlashCmdList.FARMMODE(msg, editbox)
        if farm == false then
            Map:SetSize(250)
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("CENTER", UIParent, "CENTER", 0, -225)
            farm = true
        else
            Map:SetSize(130)
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
            farm = false
        end

        if msg == "reset" then
            Map:SetSize(caelPanel_DataFeedMinimap:GetWidth(), caelPanel_DataFeedMinimap:GetWidth())
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
            farm = false
        end
    end
    SLASH_FARMMODE1 = '/farmmode'
end