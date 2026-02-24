--[[    Hiding the vehicle seat indicator    ]]

if VehicleSeatIndicator then
    VehicleSeatIndicator:UnregisterAllEvents()
    if VehicleSeatIndicator_UnloadTextures then
        VehicleSeatIndicator_UnloadTextures()
    end
    VehicleSeatIndicator:Hide()
end
