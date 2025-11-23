PANEL = {}

function PANEL:Init()
	self:SetName("ExtSpawnerCheckboxOption")
	self:SetSize(200, 50)
	self:SetPaintBackground(false)
	self.Label = vgui.Create("DLabel", self)
	self.Label:Dock(TOP)
	self.CheckBox = vgui.Create("DCheckBox", self)
	self.CheckBox:SetPos(0, 20)
end

function PANEL:SetText(text)
	self.Label:SetText(text)
	self:SetTooltip(text)
	self:SetTooltipDelay(1)
end

function PANEL:SetValue(checked)
	self.CheckBox:SetValue(checked)
end

return vgui.Register("ExtSpawnerCheckboxOption", PANEL, "DPanel")
