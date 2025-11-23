PANEL = {}

function PANEL:Init()
	self:SetName("ExtSpawnerSliderOption")
	self:SetSize(200, 50)
	self:SetPaintBackground(false)
	self.Label = vgui.Create("DLabel", self)
	self.Label:Dock(TOP)
	self.Slider = vgui.Create("DNumSlider", self)
	self.Slider:Dock(TOP)
	self.Slider:SetSize(0, 30)
	-- WARNING: HACKS AHEAD!
	-- We don't need label here, cause we got it on top. Can we reuse this label? probably
	self.Slider.Label:SetSize(0, 0)
	-- PerformLayout of DNumSlider resets size of Label again
	-- https://github.com/Facepunch/garrysmod/blob/2303e61a5ea696dba22140cdda0549bb6a1a2487/garrysmod/lua/vgui/dnumslider.lua#L159
	function self.Slider.PerformLayout()
	end
end

function PANEL:SetText(text)
	self.Label:SetText(text)
	self:SetTooltip(text)
	self:SetTooltipDelay(1)
end

function PANEL:SetDecimals(decimals)
	self.Slider:SetDecimals(decimals)
end

function PANEL:SetMin(min)
	self.Slider:SetMin(min)
end

function PANEL:SetMax(max)
	self.Slider:SetMax(max)
end

function PANEL:SetDefaultValue(default)
	self.Slider:SetDefaultValue(default)
end

function PANEL:SetValue(value)
	self.Slider:SetValue(value)
end

return vgui.Register("ExtSpawnerSliderOption", PANEL, "DPanel")
