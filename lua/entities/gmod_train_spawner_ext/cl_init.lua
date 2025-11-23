include("shared.lua")
local utils = include("utils.lua")
local SidebarPanel = include("elements/sidebar_panel.lua")
local ListOption = include("elements/list_option.lua")
local CheckboxOption = include("elements/checkbox_option.lua")
local SliderOption = include("elements/slider_option.lua")
local PresetCreatorDialog = include("elements/preset_creator_dialog.lua")
local PresetManagerDialog = include("elements/preset_manager_dialog.lua")
-- used then there is no spawnmenu image for entity
local BACKUP_TRAIN_IMAGE = "vgui/entities/gmod_subway_none"
local DEFAULT_WIDTH = utils.resizeWidth(655)
local DEFAULT_HEIGHT = utils.resizeHeight(700)
local currentSettings = {
	options = {}
}

local panelRegistry = {}
local entityTypes = {}
local entityTypesIndexes = {}
surface.CreateFont("Arial15Bold", {
	font = "Arial",
	extended = true,
	size = 15,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("Arial17", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer.
	extended = true,
	size = 17,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("Arial20Bold", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer.
	extended = true,
	size = 20,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("Arial30Bold", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer.
	extended = true,
	size = 30,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local function saveLatestSettings()
	utils.preset.saveLatest(currentSettings)
end

local function drawMenuBar(frame)
	panelRegistry.menuBar = vgui.Create("DMenuBar", frame)
	panelRegistry.menuBar:DockMargin(-3, -6, -3, 0)
	panelRegistry.presetsMenu = panelRegistry.menuBar:AddMenu(Metrostroi.GetPhrase("Spawner.Presets"))
end

local function getEntityTypes()
	for i, class in pairs(MEL.TrainClasses) do
		local entityTable = MEL.getEntTable(class)
		if not entityTable.Spawner or not entityTable.SubwayTrain then continue end
		local entityList = list.Get("SpawnableEntities")[class]
		local displayName = nil
		if entityList then
			displayName = entityList.PrintName
		elseif entityTable.Spawner and entityTable.Spawner.Name then
			displayName = entityTable.Spawner.Name
		else
			displayName = string.format("%s (%s)", entityTable.SubwayTrain.Name, entityTable.SubwayTrain.Manufacturer)
		end

		entityTypes[class] = displayName
	end
end

local optionsPanelsRegistry = {}
local optionsRegistry = {}
local isAllDraw = false
local function updateListSettingsDecorator(name, callback)
	return function(self, index, value, data)
		if isAllDraw and callback then callback(self, optionsPanelsRegistry) end
		local mappedValue = nil
		local mapping = MEL.SpawnerFieldMappings[currentSettings.entityClass][name]
		if mapping then mappedValue = mapping.list_elements_indexed[data] end
		currentSettings.options[name] = mappedValue or data
	end
end

local function createList(option)
	local elements = option.Elements
	if isfunction(elements) then elements = elements() end
	-- Don't create empty or invalid list since it can break something
	if not istable(elements) or #elements == 0 and table.Count(elements) == 0 then return end
	local setting = panelRegistry.layout:Add(ListOption)
	setting.ComboBox.OnSelect = updateListSettingsDecorator(option.Name, option.ChangeCallback)
	setting:SetText(option.Translation)
	for i, value in pairs(elements) do
		if not setting.FirstId then setting.FirstId = i end
		setting:AddChoice(value, i)
	end
	return setting
end

local function updateCheckboxSettingsDecorator(name)
	return function(self, value) currentSettings.options[name] = value end
end

local function createCheckbox(option)
	local setting = panelRegistry.layout:Add(CheckboxOption)
	setting:SetText(option.Translation)
	setting.CheckBox.OnChange = updateCheckboxSettingsDecorator(option.Name)
	return setting
end

local function updateSliderSettingsDecorator(name, callback)
	return function(self, value)
		if isAllDraw and callback then callback(self, optionsPanelsRegistry) end
		currentSettings.options[name] = value
	end
end

local function createSlider(option)
	local setting = panelRegistry.layout:Add(SliderOption)
	setting:SetText(option.Translation)
	setting:SetDecimals(option.Decimals)
	setting:SetMin(option.Min)
	setting:SetMax(option.Max)
	setting.Slider.OnValueChanged = updateSliderSettingsDecorator(option.Name, option.ChangeCallback)
	if option.Default then setting:SetDefaultValue(option.Default) end
	return setting
end

local function aggregateBySection(spawner)
	local bySection = {
		Default = {}
	}

	for i, option in pairs(spawner) do
		if not option.Section then
			option.Section = "Default"
		elseif not bySection[option.Section] then
			bySection[option.Section] = {}
		end

		-- TODO: refactor. ugly... maybe do it recursivly as tree?
		if not option.Subsection then option.Subsection = "Default" end
		if not bySection[option.Section][option.Subsection] then bySection[option.Section][option.Subsection] = {} end
		table.insert(bySection[option.Section][option.Subsection], option)
	end
	return bySection
end

local function drawOptions(options)
	if not options then
		-- TODO: why?
		return
	end

	-- First pass: create and not call any callbacks
	for _, option in pairs(options) do
		createFunction = nil
		if option.Name == "SpawnMode" then
			-- special case for spawnMode combobox
			-- without this Metrostroi Advanced would break everything
			panelRegistry.spawnMode:Clear()
			-- just in case
			optionsPanelsRegistry.SpawnMode = panelRegistry.spawnMode
			for i, value in pairs(option.Elements) do
				panelRegistry.spawnMode:AddChoice(value, i)
			end

			-- FIXME: forgive me god wtf is this shit lol
			local mapping = MEL.SpawnerFieldMappings[currentSettings.entityClass][option.Name]
			local valueID = mapping and mapping.list_elements[currentSettings.options[option.Name]] or nil
			panelRegistry.spawnMode:ChooseOptionID(valueID or option.Default or 1)
			panelRegistry.spawnMode.OnSelect = updateListSettingsDecorator(option.Name)
			continue
		end

		if option.Type == "List" then
			createFunction = createList
		elseif option.Type == "Boolean" then
			createFunction = createCheckbox
		elseif option.Type == "Slider" then
			createFunction = createSlider
		else
			continue
		end

		local panel = createFunction(option)
		if not panel then continue end
		optionsPanelsRegistry[option.Name] = panel
		optionsRegistry[option.Name] = option
	end
end

local function getSectionTranslation(sectionName)
	return Metrostroi.GetPhrase(Format("Entities.%s.Spawner.Section.%s", currentSettings.entityClass, sectionName))
end

local function drawSubsections(subsections)
	-- draw Default subsection first without section label
	drawOptions(subsections.Default)
	subsections.Default = nil
	-- draw all other subsections
	for sectionName, options in pairs(subsections) do
		local subsectionPanel = panelRegistry.layout:Add("DPanel")
		subsectionPanel.OwnLine = true
		subsectionPanel:SetPaintBackground(false)
		subsectionPanel:SetTall(utils.resizeHeight(30))
		subsectionPanel:SetWide(utils.resizeWidth(200))
		subsectionLabel = subsectionPanel:Add("DLabel")
		subsectionLabel:SetText(getSectionTranslation(sectionName))
		subsectionLabel:SetFont("Arial20Bold")
		subsectionLabel:Dock(BOTTOM)
		drawOptions(options)
	end
end

local function drawSections(sections)
	isAllDraw = false
	optionsPanelsRegistry = {}
	optionsRegistry = {}
	-- draw Default section first without section label
	drawSubsections(sections.Default)
	sections.Default = nil
	-- draw all other sections
	for sectionName, subsections in pairs(sections) do
		local sectionPanel = panelRegistry.layout:Add("DPanel")
		sectionPanel.OwnLine = true
		sectionPanel:SetPaintBackground(false)
		sectionPanel:SetTall(utils.resizeHeight(60))
		sectionPanel:SetWide(utils.resizeWidth(200))
		sectionLabel = sectionPanel:Add("DLabel")
		sectionLabel:SetText(getSectionTranslation(sectionName))
		sectionLabel:SetFont("Arial30Bold")
		sectionLabel:Dock(BOTTOM)
		drawSubsections(subsections)
	end

	-- Some trains rely on this (e.g. Ezh3 RU1)
	optionsPanelsRegistry.WagNum = panelRegistry.wagonCount
	isAllDraw = true
	-- Second pass: create and call all of callbacks, select values and of that shit
	for name, setting in pairs(optionsPanelsRegistry) do
		if name == "SpawnMode" or name == "WagNum" then continue end
		local option = optionsRegistry[name]
		if not setting or not option then continue end
		if option.ChangeCallback then option.ChangeCallback(setting.ComboBox or setting.Slider or setting.CheckBox, optionsPanelsRegistry) end
		-- FIXME: Dynamically created options (e.g. Attach508t on RU1) are not saving their value
		-- Possibly because they populate their list after that invocation below
		local defaultValue = nil
		-- remember that we can deal with boolean values. so if we can't really use one-liner here
		if currentSettings.options[name] ~= nil then
			defaultValue = currentSettings.options[name]
		elseif option.Default ~= nil then
			defaultValue = option.Default
		elseif setting.FirstId then
			defaultValue = setting.FirstId
		else
			defaultValue = 1
		end

		setting:SetValue(defaultValue)
	end
end

local function applyPresetFactory(presetName)
	return function()
		local preset_table = utils.preset.presets[currentSettings.entityClass][presetName]
		for option_name, option_value in pairs(preset_table.options) do
			local option_panel = optionsPanelsRegistry[option_name]
			if option_panel then
				local panel_name = option_panel:GetName()
				local mapping = MEL.SpawnerFieldMappings[currentSettings.entityClass][option_name]
				local mapping_value = mapping and mapping.list_elements[option_value] or nil
				local discovered_value = nil
				if panel_name == "ExtSpawnerCheckboxOption" or panel_name == "ExtSpawnerSliderOption" then
					discovered_value = option_value
				elseif mapping_value then
					discovered_value = mapping_value
				elseif option_panel.OptionByData and option_panel.OptionByData[option_value] then
					discovered_value = option_value
				end

				if discovered_value ~= nil then
					if option_name == "SpawnMode" then
						-- FIXME: weird special case...
						option_panel:ChooseOptionID(discovered_value)
					else
						option_panel:SetValue(discovered_value)
					end
				end
			end
		end

		notification.AddLegacy(Metrostroi.GetPhrase("Spawner.PresetApplied"), NOTIFY_HINT, 2)
	end
end

local drawPresets
local function createPreset(_, name)
	presetSettings = table.Copy(currentSettings)
	presetSettings.name = name
	utils.preset.saveNew(Format("preset_%s", os.date("%Y_%m_%d-%H_%M_%S", os.time())), presetSettings)
	-- TODO: Not so efficient :)
	drawPresets()
end

function drawPresets()
	utils.preset.discover()
	panelRegistry.presetsMenu:Clear()

	for name, presetTable in pairs(utils.preset.presets[currentSettings.entityClass] or {}) do
		panelRegistry.presetsMenu:AddOption(presetTable.name or name, applyPresetFactory(name))
	end

	panelRegistry.presetsMenu:AddSpacer()

	panelRegistry.createNewPreset = panelRegistry.presetsMenu:AddOption(Metrostroi.GetPhrase("Spawner.NewPreset"), function()
		local presetCreatorDialog = vgui.CreateFromTable(PresetCreatorDialog, panelRegistry.rootFrame)
		presetCreatorDialog.OnCreatePressed = createPreset
	end)
	panelRegistry.createNewPreset:SetIcon("icon16/add.png")

	panelRegistry.presetsManageMenu = panelRegistry.presetsMenu:AddOption(Metrostroi.GetPhrase("Spawner.ManagePresets"), function ()
		local presetManagerDialog = vgui.CreateFromTable(PresetManagerDialog, panelRegistry.rootFrame)
		for name, presetTable in pairs(utils.preset.presets[currentSettings.entityClass] or {}) do
			presetManagerDialog:AddPreset(presetTable.name or name, presetTable)
		end
		presetManagerDialog.UpdateCallback = function()
			drawPresets()
		end
	end)
	panelRegistry.presetsManageMenu:SetIcon("icon16/cog_edit.png")
end

local function entityTypeCallback(self, index, value)
	if currentSettings.entityClass then saveLatestSettings() end
	currentSettings.entityClass = self:GetOptionData(index)
	panelRegistry.rootFrame:SetCookie("lastEntityType", currentSettings.entityClass)
	currentSettings.options = {}
	-- try to load saved settings
	local savedSettings = utils.preset.loadLatest(currentSettings.entityClass)
	if savedSettings then currentSettings = savedSettings end
	-- if this is custom entity we should use spawnmenu image of original entity
	local image = string.format("vgui/entities/%s", currentSettings.entityClass)
	image = string.Replace(image, "_custom", "")
	panelRegistry.entityImage:SetImage(image, BACKUP_TRAIN_IMAGE)
	panelRegistry.layout:Clear()

	drawPresets()

	local spawner = MEL.getEntTable(currentSettings.entityClass).Spawner
	local sections = aggregateBySection(utils.convertToNamedFormat(spawner))
	drawSections(sections)
	-- FIXME: really weird hack here...
	-- do not even ask why that works and why IconLayout doesn't want to work right without this
	panelRegistry.rootFrame:SetTall(panelRegistry.rootFrame:GetTall() - 1)
	timer.Simple(0, function() panelRegistry.rootFrame:SetTall(panelRegistry.rootFrame:GetTall() + 1) end)
end

local function updateWagonCount(numSlider)
	-- sometimes SetMax is not present while numSlider is... weird
	if numSlider and numSlider.SetMax then numSlider:SetMax(MaxWagonsOnPlayer) end
end

local function drawSidebar(frame)
	local panel = vgui.Create("DPanel", frame)
	panel:SetPaintBackground(false)
	panel:Dock(LEFT)
	panel:SetSize(utils.resizeWidth(200), 0)
	-- Image of wagon type
	panelRegistry.entityImage = vgui.Create("DImage", panel)
	panelRegistry.entityImage:SetSize(utils.resizeWidth(150), utils.resizeWidth(150))
	panelRegistry.entityImage:DockMargin(utils.resizeWidth(25), utils.resizeHeight(10), utils.resizeWidth(25), 0)
	panelRegistry.entityImage:Dock(TOP)
	panelRegistry.entityImage:SetImage("vgui/entities/gmod_subway_81-717_mvm")
	-- PANEL Entity type chooser
	local entityTypePanel = panel:Add(SidebarPanel)
	entityTypePanel:SetText(Metrostroi.GetPhrase("Common.Spawner.Type"))
	panelRegistry.entityTypeComboBox = vgui.Create("DComboBox", entityTypePanel)
	panelRegistry.entityTypeComboBox:Dock(TOP)
	panelRegistry.entityTypeComboBox:DockMargin(0, 10, 0, 0)
	panelRegistry.entityTypeComboBox:SetSize(0, utils.resizeHeight(30))
	panelRegistry.entityTypeComboBox:SetFont("Arial15Bold")
	panelRegistry.entityTypeComboBox:SetTextColor()
	local counter = 1
	for entityType, displayName in pairs(entityTypes) do
		entityTypesIndexes[entityType] = counter
		panelRegistry.entityTypeComboBox:AddChoice(displayName, entityType)
		counter = counter + 1
	end

	panelRegistry.entityTypeComboBox.OnSelect = entityTypeCallback
	-- PANEL Wagon count chooser
	local wagonCountPanel = panel:Add(SidebarPanel)
	wagonCountPanel:SetText(Metrostroi.GetPhrase("Spawner.WagNum"))
	panelRegistry.wagonCount = vgui.Create("DNumSlider", wagonCountPanel)
	panelRegistry.wagonCount:Dock(TOP)
	panelRegistry.wagonCount:SetDecimals(0)
	panelRegistry.wagonCount:SetMin(1)
	updateWagonCount(panelRegistry.wagonCount)
	panelRegistry.wagonCount:SetValue(math.Clamp(panelRegistry.rootFrame:GetCookie("wagonCount", 2), 1, MaxWagonsOnPlayer))
	-- WARNING: HACKS AHEAD!
	-- We don't need label here, cause we got it on top as wagonCountLabel. Can we reuse this label? probably.
	panelRegistry.wagonCount.Label:SetSize(0, 0)
	-- Default TextArea is tooooooo wide (45 pixels). Wagon count is usually in single digit values, so 16 pixels is enough
	panelRegistry.wagonCount.TextArea:SetWide(utils.resizeWidth(16))
	-- PerformLayout of DNumSlider resets size of Label again
	-- https://github.com/Facepunch/garrysmod/blob/2303e61a5ea696dba22140cdda0549bb6a1a2487/garrysmod/lua/vgui/dnumslider.lua#L159
	function panelRegistry.wagonCount.PerformLayout()
	end

	function panelRegistry.wagonCount:OnValueChanged(value)
		value = math.Round(value, 0)
		panelRegistry.rootFrame:SetCookie("wagonCount", value)
		self:SetValue(value)
	end

	-- PANEL Spawn mode chooser
	local spawnModePanel = panel:Add(SidebarPanel)
	spawnModePanel:SetText(Metrostroi.GetPhrase("Common.Spawner.SpawnMode"))
	panelRegistry.spawnMode = vgui.Create("DComboBox", spawnModePanel)
	panelRegistry.spawnMode:Dock(TOP)
	panelRegistry.spawnMode:DockMargin(0, 10, 0, 0)
	panelRegistry.spawnMode:SetSize(0, utils.resizeHeight(30))
	panelRegistry.spawnMode:SetFont("Arial15Bold")
	panelRegistry.spawnMode:SetTextColor()
end

local function drawMain(frame)
	local panel = vgui.Create("DScrollPanel", frame)
	panel:SetPaintBackground(true)
	panel:SetBackgroundColor(derma.Color("bg_color_sleep", panel))
	panel:Dock(FILL)
	panelRegistry.layout = vgui.Create("DIconLayout", panel)
	panelRegistry.layout:SetZPos(10)
	panelRegistry.layout:Dock(FILL)
	panelRegistry.layout:SetBorder(10)
	panelRegistry.layout:SetSpaceX(utils.resizeWidth(6))
	panelRegistry.layout:SetSpaceY(utils.resizeHeight(6))
	panelRegistry.layout:SetStretchWidth(true)
	panelRegistry.layout:SetStretchHeight(true)
	-- FIXME: why without this it doesn't work???
	for i = 1, 100 do
		local listItem = panelRegistry.layout:Add("DPanel")
		listItem:SetSize(200, 40)
		listItem:SetPaintBackground(false)
	end
end

local function spawn()
	saveLatestSettings()
	local settings = table.Copy(currentSettings)
	settings.Train = panelRegistry.entityTypeComboBox:GetOptionData(panelRegistry.entityTypeComboBox:GetSelectedID())
	settings.AutoCouple = true
	settings.wagonCount = math.Round(panelRegistry.wagonCount:GetValue(), 0)
	for name, value in pairs(settings.options) do
		local mapping = MEL.SpawnerFieldMappings[currentSettings.entityClass][name]
		if mapping then
			settings.options[name] = mapping.list_elements[value]
		else
			settings.options[name] = value
		end
	end

	-- needed for Metrostroi Advanced
	settings.WagNum = settings.wagonCount
	net.Start("train_spawner_open_ext")
	net.WriteTable(settings)
	net.SendToServer()
	local tool = LocalPlayer():GetTool("train_spawner_ext")
	tool.Settings = settings
	local ENT = MEL.getEntTable(tool.Settings.Train)
	if ENT and ENT.Spawner then tool.Train = ENT end
	panelRegistry.rootFrame:Close()
end

local function drawActionbar(frame)
	local panel = vgui.Create("DPanel", frame)
	panel:SetPaintBackground(false)
	panel:Dock(BOTTOM)
	panel:SetHeight(utils.resizeHeight(40))
	panel:DockMargin(utils.resizeWidth(10), 0, utils.resizeWidth(10), 0)
	local closeButton = vgui.Create("DButton", panel)
	closeButton:SetText(Metrostroi.GetPhrase("Spawner.Close"))
	closeButton:Dock(LEFT)
	closeButton:DockMargin(0, utils.resizeHeight(5), 0, utils.resizeHeight(5))
	closeButton:SetWide(utils.resizeWidth(100))
	closeButton:SetIcon("icon16/cross.png")
	closeButton:SetFont("Arial15Bold")
	closeButton.DoClick = function()
		saveLatestSettings()
		panelRegistry.rootFrame:Close()
	end

	local spawnButton = vgui.Create("DButton", panel)
	spawnButton:SetText(Metrostroi.GetPhrase("Spawner.Spawn"))
	spawnButton:Dock(RIGHT)
	spawnButton:DockMargin(0, utils.resizeHeight(5), 0, utils.resizeHeight(5))
	spawnButton:SetWide(utils.resizeWidth(150))
	spawnButton:SetIcon("icon16/accept.png")
	spawnButton:SetFont("Arial15Bold")
	spawnButton.DoClick = spawn
end

local function draw(frame)
	-- TODO: we don't need this right now, cause actionbar is not usable
	drawMenuBar(frame)
	drawActionbar(frame)
	drawSidebar(frame)
	drawMain(frame)
	local entityTypeIndex = entityTypesIndexes[panelRegistry.rootFrame:GetCookie("lastEntityType")] or 1
	-- FIXME: if we call this in same tick, max amount of options that we can have would be limited to amount of options on first draw.. wtf
	timer.Simple(0, function() panelRegistry.entityTypeComboBox:ChooseOptionID(entityTypeIndex) end)
end

local function createRootFrame()
	getEntityTypes()
	if not panelRegistry.rootFrame or not panelRegistry.rootFrame:IsValid() then
		panelRegistry.rootFrame = vgui.Create("DFrame", nil, "metrostroi_ext_spawner")
		panelRegistry.rootFrame:SetDeleteOnClose(true)
		panelRegistry.rootFrame:SetTitle(Metrostroi.GetPhrase("Spawner.Title"))
		panelRegistry.rootFrame:SetDraggable(true)
		panelRegistry.rootFrame:SetMinWidth(DEFAULT_WIDTH)
		panelRegistry.rootFrame:SetMinHeight(DEFAULT_HEIGHT)
		panelRegistry.rootFrame:SetSizable(true)
		panelRegistry.rootFrame:MakePopup()
		panelRegistry.rootFrame:ShowCloseButton(false)
		panelRegistry.rootFrame.LoadCookies = function(self)
			-- overengineering?
			-- i wanted to preserve size of spawner window, but
			-- i changed my monitor and can't access "close" button now cause it's outside of my screen
			-- i hate bad UX, so i wrote this
			local width = self:GetCookie("width", DEFAULT_WIDTH)
			local height = self:GetCookie("height", DEFAULT_HEIGHT)
			self:SetWide(math.Clamp(width, DEFAULT_WIDTH, ScrW()))
			self:SetTall(math.Clamp(height, DEFAULT_HEIGHT, ScrH()))
		end

		panelRegistry.rootFrame:SetCookieName("MetrostroiExtSpawnerRoot")
		draw(panelRegistry.rootFrame)
		panelRegistry.rootFrame:Center()
		panelRegistry.rootFrame.OnSizeChanged = function(self)
			self:SetCookie("width", self:GetWide())
			self:SetCookie("height", self:GetTall())
		end
	end
end

net.Receive("MetrostroiTrainSpawner", createRootFrame)
net.Receive("MetrostroiMaxWagons", function()
	-- TODO: i hate this logic... seems very wrong
	MaxWagonsOnPlayer = GetGlobalInt("metrostroi_maxtrains_onplayer") * GetGlobalInt("metrostroi_maxwagons")
	updateWagonCount(panelRegistry.wagonCount)
end)
-- TODO: should we even do anything on this train count update?
-- net.Receive("MetrostroiTrainCount", function() if trainTypeT and trainTypeT:IsValid() then trainTypeT:SetText(Format("%s(%d/%d)\n%s:%d", Metrostroi.GetPhrase("Spawner.Trains1"), GetGlobalInt("metrostroi_train_count"), MaxWagons, Metrostroi.GetPhrase("Spawner.Trains2"), MaxWagonsOnPlayer)) end end)
