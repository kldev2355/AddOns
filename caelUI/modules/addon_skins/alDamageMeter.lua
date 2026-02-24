local alDamageMeterSkin = unpack(select(2, ...)).NewModule("alDamageMeterSkin")

if not C_AddOns.IsAddOnLoaded("alDamageMeter") then return end

local PixelScale = alDamageMeterSkin.PixelScale

local function SkinBar (self)

end

alDamageMeterSkin:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Clear the backdrop as we manage that with our own panel creation system.
    if alDamageMeterFrame and alDamageMeterFrame.bg then
        if not alDamageMeterFrame.bg.SetBackdrop then
            pcall(Mixin, alDamageMeterFrame.bg, BackdropTemplateMixin)
        end
        if alDamageMeterFrame.bg.SetBackdropColor then
            alDamageMeterFrame.bg:SetBackdropColor(0, 0, 0, 0)
            alDamageMeterFrame.bg:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end

    -- Reposition and size the frame.
    if alDamageMeterFrame then
        alDamageMeterFrame:ClearAllPoints()

        -- Position and Size
        if caelPanel_DamageMeter then
            alDamageMeterFrame:SetSize(caelPanel_DamageMeter:GetSize())
            alDamageMeterFrame:SetPoint("TOPLEFT", caelPanel_DamageMeter, "TOPLEFT", 0, -PixelScale(10))
            alDamageMeterFrame:SetPoint("BOTTOMRIGHT", caelPanel_DamageMeter, "BOTTOMRIGHT")
        end
    end
end)