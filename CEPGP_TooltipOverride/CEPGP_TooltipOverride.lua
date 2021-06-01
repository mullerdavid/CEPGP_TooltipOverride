--[[ Globals ]]--

CEPGP_TooltipOverride_Addon = "CEPGP_TooltipOverride"
CEPGP_TooltipOverride_Panel = nil
CEPGP_TooltipOverride_LoadedPanel = false
CEPGP_TooltipOverride_LoadedAddon = false
CEPGP_TooltipOverride_Loaded = false
CEPGP_TooltipOverride_HookOriginalFunction = nil
CEPGP_TooltipOverride_Options  = {
	[1] = { value="always", text = "Always"},
	[2] = { value="alt", text = "When Alt is pressed"},
	[3] = { value="shift", text = "When Shift is pressed"},
	[4] = { value="control", text = "When Ctrl is pressed"},
	[5] = { value="notalt", text = "When Alt is NOT pressed"},
	[6] = { value="notshift", text = "When Shift is NOT pressed"},
	[7] = { value="notcontrol", text = "When Ctrl is NOT pressed"},
	[8] = { value="never", text = "Never"}
};

--[[ SAVED VARIABLES ]]--

CEPGP_TooltipOverride_tooltips = nil;

--[[ Code ]]--

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("ADDON_LOADED")

local function LoadSettings(self)
	local found = false
	for index, value in ipairs(CEPGP_TooltipOverride_Options) 
	do
		if value.value == CEPGP_TooltipOverride_tooltips
		then
			UIDropDownMenu_SetSelectedValue(CEPGP_TooltipOverride_options_tooltips, value.value)
			found = true
		end
	end
	if not found 
	then
		UIDropDownMenu_SetSelectedValue(CEPGP_TooltipOverride_options_tooltips, CEPGP_TooltipOverride_Options[1].value)
	end
end

local function SaveSettings(self)
	if CEPGP_TooltipOverride_options_tooltips 
	then
		CEPGP_TooltipOverride_tooltips = UIDropDownMenu_GetSelectedValue(CEPGP_TooltipOverride_options_tooltips)
	end
end

function CEPGP_TooltipOverride_SetDropDown(frame, level, menuList)
	for index, value in ipairs(CEPGP_TooltipOverride_Options)
	do
		local info = {
			text = value.text,
			value = value.value,
			func = function(self, value) 
				UIDropDownMenu_SetSelectedValue(CEPGP_TooltipOverride_options_tooltips, self.value)
			end
		};
		local entry = UIDropDownMenu_AddButton(info);
		
	end
	LoadSettings()
end

function IsTooltipEnabled()
	local setting = CEPGP_TooltipOverride_tooltips
	if setting == "alt" 
	then
		return IsAltKeyDown()
    elseif setting == "shift" 
	then 
		return IsShiftKeyDown()
    elseif setting == "control" 
	then 
		return IsControlKeyDown()
    elseif setting == "notalt" 
	then 
		return not IsAltKeyDown()
    elseif setting == "notshift" 
	then 
		return not IsShiftKeyDown()
    elseif setting == "notcontrol" 
	then 
		return not IsControlKeyDown()
    elseif setting == "never" 
	then 
		return false
    else
		return true
	end
end

function CEPGP_TooltipOverride_HookNewFunction(arg1)
	return IsTooltipEnabled()
end

function CEPGP_TooltipOverride_HookNewFunctionCompat(arg1)
	local stack = debugstack()
	--for line in stack:gmatch("([^\n]*)\n?") do print(line) end
	if string.match(stack, "GameTooltip_UpdateStyle") or string.match(stack, "ChatFrame_OnHyperlinkShow")
	then
		return IsTooltipEnabled()
	else 
		return CEPGP_TooltipOverride_HookOriginalFunction(arg1) 
	end
end

local function AddHook()
	if (CEPGP_TooltipOverride_HookOriginalFunction == nil)
	then
		if (_G.CEPGP_isGPTooltip)
		then
			CEPGP_TooltipOverride_HookOriginalFunction = _G.CEPGP_isGPTooltip
			_G.CEPGP_isGPTooltip = CEPGP_TooltipOverride_HookNewFunction
		else
			CEPGP_TooltipOverride_HookOriginalFunction = _G.CEPGP_itemExists
			_G.CEPGP_itemExists = CEPGP_TooltipOverride_HookNewFunctionCompat
		end
	end
end

function CEPGP_TooltipOverride_AddPlugin()
	if (_G.CEPGP) 
	then
		CEPGP_addPlugin(CEPGP_TooltipOverride_Addon, CEPGP_TooltipOverride_Panel, true, function() print("This does nothing. Please disable the plugin in the AddOns!") end)
		AddHook()
	end
end

local function Init()
	if (not CEPGP_TooltipOverride_Loaded) and CEPGP_TooltipOverride_LoadedPanel and CEPGP_TooltipOverride_LoadedAddon 
	then
		CEPGP_TooltipOverride_Loaded = true
		LoadSettings()
		CEPGP_TooltipOverride_AddPlugin()
	end
end

function CEPGP_TooltipOverride_LoadOptions(panel)
	panel.name = "Classic EPGP Tooltip"
	panel.okay = SaveSettings
	InterfaceOptions_AddCategory(panel)
	CEPGP_TooltipOverride_Panel = panel
	CEPGP_TooltipOverride_LoadedPanel = true
	Init()
end

local function OnEvent(self, event, arg1)
if arg1 ~= CEPGP_TooltipOverride_Addon then return end
	if event == "ADDON_LOADED"
	then
		self:UnregisterEvent("ADDON_LOADED")
		CEPGP_TooltipOverride_LoadedAddon = true
		Init()
	end
end

frame:SetScript("OnEvent", OnEvent)