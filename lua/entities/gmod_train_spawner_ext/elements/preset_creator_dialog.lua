local utils = include("entities/gmod_train_spawner_ext/utils.lua")
PANEL = {}
function PANEL:Init()
    self:Center()
    self:SetDrawOnTop(true)
    self:SetTall(utils.resizeHeight(100))
    self:SetWide(utils.resizeWidth(300))
    self:SetTitle(Metrostroi.GetPhrase("Spawner.PresetCreator.Title"))

    self.namePanel = self:Add("DPanel")
    self.namePanel:SetPaintBackground(false)
    self.namePanel:Dock(TOP)
    self.nameLabel = self.namePanel:Add("DLabel")
    self.nameLabel:Dock(LEFT)
    self.nameLabel:SetText(Metrostroi.GetPhrase("Spawner.PresetCreator.NameLabel"))
    self.nameEdit = self.namePanel:Add("DTextEntry")
    self.nameEdit:Dock(RIGHT)
    self.nameEdit:SetWide(utils.resizeWidth(200))
    self.nameEdit:SetPlaceholderText(Metrostroi.GetPhrase("Spawner.PresetCreator.NamePlaceholder"))

    self.nameEdit.OnChange = function(nameEdit)
        self.createButton:SetDisabled(nameEdit:GetValue() == "")
    end

    self.createButton = self:Add("DButton")
    self.createButton:Dock(BOTTOM)
    self.createButton:SetWide(160)
    self.createButton:SetText(Metrostroi.GetPhrase("Spawner.PresetCreator.CreateButton"))
    self.createButton:SetIcon("icon16/add.png")
    self.createButton:SetDisabled(true)

    self.createButton.DoClick = function()
        self:OnCreatePressed(self.nameEdit:GetValue())
        self:Close()
    end
end

function PANEL:OnCreatePressed(name) end

return vgui.Register("ExtSpawnerPresetCreatorDialog", PANEL, "DFrame")
