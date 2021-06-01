--[[ Globals ]]--

CEPGP_ChangeOfMind_Addon = "CEPGP_ChangeOfMind"

--[[ Code ]]--

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("ADDON_LOADED")

local function ResetFrame()
	local buttons = {CEPGP_respond_1, CEPGP_respond_2, CEPGP_respond_3, CEPGP_respond_4, CEPGP_respond_pass}
	for i = 1,#buttons do
		local b = buttons[i]
		b:SetEnabled(true)
	end
end

local function IsAnySelected()
	local buttons = {CEPGP_respond_1, CEPGP_respond_2, CEPGP_respond_3, CEPGP_respond_4, CEPGP_respond_pass}
	for i = 1,#buttons do
		local b = buttons[i]
		if not b:IsEnabled()
		then
			return true
		end
	end
	return false
end

local function OnButtonClick(frame)
	ResetFrame()
	frame:SetEnabled(false)
end

local function AddHook()
	if CEPGP_Info.Version.Number ~= "1.13.5"
	then
		print("WARNING: " .. CEPGP_ChangeOfMind_Addon .. " might be incompatible with this version of CEPGP!")
	end
	local buttons = {CEPGP_respond_1, CEPGP_respond_2, CEPGP_respond_3, CEPGP_respond_4, CEPGP_respond_pass}
	local point, relativeTo, relativePoint, xOfs, yOfs=CEPGP_respond_pass:GetPoint() 
	CEPGP_respond_pass:SetPoint(point, relativeTo, relativePoint, xOfs-20, yOfs) -- move pass button left
	local cb = CreateFrame("Button", nil, CEPGP_respond, "UIPanelCloseButton") -- add close button
	cb:SetSize(40 ,40)
	cb:SetText("Button")
	cb:SetPoint("CENTER")
	cb:SetPoint(point, relativeTo, relativePoint, 0, -1) 
	local show=CEPGP_respond.Show
	local hide=CEPGP_respond.Hide
	local isvisible=CEPGP_respond.IsVisible
	CEPGP_respond.Show=function(...)
		ResetFrame()
		show(...)
	end
	CEPGP_respond.Hide=function(...) -- do not hide it if resubmit is allowed
		if not CEPGP.Loot.Resubmit
		then
			hide(...)
		end
	end
	CEPGP_respond.IsVisible=function(...) -- hack to prevent auto pass when timer expires and have something selected
		local prevent = false
		local ret = isvisible(...)
		if CEPGP.Loot.Resubmit and CEPGP_distribute_time:GetText()=="Response Time Expired"
		then
			if IsAnySelected()
			then
				prevent = true
			end
		end
		if prevent
		then
			hide(CEPGP_respond) 
			return false
		end
		return ret
	end
	cb:SetScript("OnClick", function() if not IsAnySelected() then CEPGP_respond_pass:Click() end hide(CEPGP_respond) end)  -- use original hide, click pass if nothing was selected before
	for i = 1,#buttons do -- on button click disable that button to mark it was pressed
		local b = buttons[i]
		local click = b:GetScript("OnClick")
		b:SetScript("OnClick", function(...) click(...) OnButtonClick(...) end)
	end
end

function CEPGP_ChangeOfMind_AddPlugin()
	if (_G.CEPGP) 
	then
		CEPGP_addPlugin(CEPGP_ChangeOfMind_Addon, nil, true, function() print("This does nothing. Please disable the plugin in the AddOns!") end)
		AddHook()
	end
end

local function OnEvent(self, event, arg1)
	if arg1 ~= CEPGP_ChangeOfMind_Addon then return end
	if event == "ADDON_LOADED"
	then
		self:UnregisterEvent("ADDON_LOADED")
		CEPGP_ChangeOfMind_LoadedAddon = true
		CEPGP_ChangeOfMind_AddPlugin()
	end
end

frame:SetScript("OnEvent", OnEvent)