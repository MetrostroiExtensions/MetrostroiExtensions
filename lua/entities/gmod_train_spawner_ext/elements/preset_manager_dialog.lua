local utils = include("entities/gmod_train_spawner_ext/utils.lua")
PANEL = {}
function PANEL:Init()
    self:Center()
    self:SetDrawOnTop(true)
    self:SetTall(utils.resizeHeight(300))
    self:SetWide(utils.resizeWidth(500))
    self:SetTitle(Metrostroi.GetPhrase("Spawner.PresetManager.Title"))

    self.listView = self:Add("DListView")
    self.listView:Dock(TOP)
    self.listView:SetTall(utils.resizeHeight(230))
    self.listView:AddColumn(Metrostroi.GetPhrase("Spawner.PresetManager.NameColumn"))
    self.listView:SetMultiSelect(false)
    self.listView.OnRowSelected = function(listView, row)
        self.deleteButton:SetDisabled(false)
        -- self.overwriteButton:SetDisabled(false)
    end

    self.buttonsPanel = self:Add("DPanel")
    self.buttonsPanel:SetPaintBackground(false)
    self.buttonsPanel:Dock(BOTTOM)
    self.deleteButton = self.buttonsPanel:Add("DButton")
    self.deleteButton:SetWide(utils.resizeWidth(90))
    self.deleteButton:Dock(RIGHT)
    self.deleteButton:SetText(Metrostroi.GetPhrase("Spawner.PresetManager.DeleteButton"))
    self.deleteButton:SetIcon("icon16/table_delete.png")
    self.deleteButton:SetDisabled(true)
    self.deleteButton.DoClick = function()
        self:OnDelete()
    end
    -- self.overwriteButton = self.buttonsPanel:Add("DButton")
    -- self.overwriteButton:SetWide(utils.resizeWidth(90))
    -- self.overwriteButton:DockMargin(10, 0, 10, 0)
    -- self.overwriteButton:Dock(RIGHT)
    -- self.overwriteButton:SetText("Overwrite")
    -- self.overwriteButton:SetIcon("icon16/table_edit.png")
    -- self.overwriteButton:SetDisabled(true)
end

function PANEL:UpdateCallback()
end

function PANEL:OnDelete()
    local index, line = self.listView:GetSelectedLine()
    utils.preset.delete(line.presetTable.fileName)
    self.listView:RemoveLine(index)
    -- TODO: not so efficient
    self:UpdateCallback()
end

function PANEL:AddPreset(presetName, presetTable)
    local line = self.listView:AddLine(presetName)
    line.presetTable = presetTable
end

return vgui.Register("ExtSpawnerPresetManagerDialog", PANEL, "DFrame")
