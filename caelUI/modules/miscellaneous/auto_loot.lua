-- We automatically confirm loot if we are not in a party or raid.
StaticPopupDialogs["LOOT_BIND"].OnCancel = function(_, slot)
    if not IsInGroup() then
        ConfirmLootSlot(slot)
    end
end
