local _, caelBars = ...

---------------------------------------------
-- Hide and disable Blizzard action bars
-- Adapted from NDui Hide_blizzart.lua
---------------------------------------------

local scripts = {
	"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local framesToHide = {
	MainActionBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5, MultiBar6, MultiBar7, OverrideActionBar, PossessActionBar, PetActionBar, StanceBar
}

local framesToDisable = {
	MainActionBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5, MultiBar6, MultiBar7, PossessActionBar, PetActionBar, StanceBar,
	MicroButtonAndBagsBar, StatusTrackingBarManager, MainMenuBarVehicleLeaveButton,
	OverrideActionBar,
	OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
}

local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function buttonEventsRegisterFrame(self, added)
	local frames = self.frames
	for index = #frames, 1, -1 do
		local frame = frames[index]
		local wasAdded = frame == added
		if not added or wasAdded then
			if not strmatch(frame:GetName(), "ExtraActionButton%d") then
				self.frames[index] = nil
			end

			if wasAdded then
				break
			end
		end
	end
end

local function DisableDefaultBarEvents()
	-- Shut down some events for things we don't use
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- needed for page controller to spawn properly
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- needed to let the ExtraActionBar show
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()
	-- Used for ExtraActionButton and TotemBar (on wrath)
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- needed to let the ExtraActionButton show and Totems to swap
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- needed for cooldowns
	hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
	buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)
end

local function HideBlizzard()
	for _, frame in next, framesToHide do
		if frame then
			frame:SetParent(nil)
			frame:Hide()
		end
	end

	for _, frame in next, framesToDisable do
		if frame then
			frame:UnregisterAllEvents()
			DisableAllScripts(frame)
		end
	end

	DisableDefaultBarEvents()
	
	-- Fix maw block anchor
	if MainMenuBarVehicleLeaveButton then
		MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	
	-- Update token panel
	if SetCVar then
		SetCVar("showTokenFrame", 1)
	end
	
	-- Hide blizzard expbar
	if StatusTrackingBarManager then
		StatusTrackingBarManager:UnregisterAllEvents()
		StatusTrackingBarManager:Hide()
	end
end

-- Run on addon load
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		HideBlizzard()
		self:UnregisterAllEvents()
	end
end)
