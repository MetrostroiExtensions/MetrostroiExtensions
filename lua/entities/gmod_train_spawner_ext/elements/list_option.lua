PANEL = {}

function PANEL:Init()
	self:SetName("ExtSpawnerListOption")
	self.OptionByData = {}
	self.FirstId = nil
	self:SetSize(200, 50)
	self:SetPaintBackground(false)
	self.Label = vgui.Create("DLabel", self)
	self.Label:Dock(TOP)
	self.ComboBox = vgui.Create("DComboBox", self)
	self.ComboBox:Dock(TOP)
	self.ComboBox:SetSize(0, 30)
	self.ComboBox:SetSortItems(false)
end

function PANEL:SetText(text)
	self.Label:SetText(text)
	self:SetTooltip(text)
	self:SetTooltipDelay(1)
end

function PANEL:SetValue(data)
	-- Set and select default value
	if self.OptionByData[data] then
		self.ComboBox:ChooseOptionID(self.OptionByData[data])
	else
		-- Some trains dynamically change the list contents
		-- This often depends on skin registry, or wagon count (Ezh3 RU1 with older wagons coupled)
		-- So we want to set something here, if the saved option was not found
		self.ComboBox:ChooseOptionID(1)
	end
end

function PANEL:AddChoice(value, data)
	self.OptionByData[data] = self.ComboBox:AddChoice(value, data)
end

return vgui.Register("ExtSpawnerListOption", PANEL, "DPanel")
