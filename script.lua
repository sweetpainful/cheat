local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = 'CRIME.CC | Da Hood Internal',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuKeybind = Enum.KeyCode.Insert
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Player = Window:AddTab('Player'),
    Settings = Window:AddTab('Settings')
}

-- ==================== COMBAT TAB ====================
local AimbotGroup = Tabs.Combat:AddLeftGroupbox('Silent Aim / Aimbot')

AimbotGroup:AddToggle('AimEnable', {
    Text = 'Enable Aimbot',
    Default = false,
}):AddKeyPicker('AimKey', { Default = 'MouseButton2', SyncToggleState = false, Mode = 'Hold', Text = 'Aimbot', NoUI = false })

AimbotGroup:AddDropdown('TargetPart', {
    Values = {'Head', 'HumanoidRootPart'},
    Default = 1,
    Text = 'Target Part',
})

AimbotGroup:AddToggle('WallCheck', {
    Text = 'Wall Check',
    Default = true,
})

-- ==================== VISUALS TAB (ESP) ====================
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Players')

ESPGroup:AddToggle('EspEnabled', {
    Text = 'Enable ESP Box',
    Default = false,
})

ESPGroup:AddToggle('EspName', {
    Text = 'Name Tags',
    Default = false,
})

ESPGroup:AddToggle('EspHealth', {
    Text = 'Health Bar',
    Default = false,
})

-- ==================== PLAYER TAB (MOVIMIENTO) ====================
local MovementGroup = Tabs.Player:AddLeftGroupbox('Movement & Misc')

MovementGroup:AddToggle('SpeedToggle', {
    Text = 'Custom WalkSpeed',
    Default = false,
})

MovementGroup:AddSlider('SpeedValue', {
    Text = 'Speed Value',
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
})

-- ==================== SETTINGS TAB (DISTRIBUIDO) ====================
local MenuSettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu Customization')

MenuSettingsGroup:AddButton('Unload Script', function()
    Library:Unload()
end)

MenuSettingsGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { 
    Default = 'Insert', 
    NoUI = true, 
    Text = 'Menu Keybind' 
})

local BackgroundGroup = Tabs.Settings:AddRightGroupbox('Custom Background')

BackgroundGroup:AddInput('CustomBgID', {
    Default = '',
    Numeric = false,
    Finished = true,
    Text = 'ID de Imagen (Decal)',
    Tooltip = 'Introduce el ID de Roblox de la imagen',
    Placeholder = 'rbxassetid://...',
})

-- Lógica del Fondo Personalizado
local MainFrame = Window.Holder 
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "CustomBackground"
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.ScaleType = Enum.ScaleType.Slice
BgImage.ZIndex = 0
BgImage.Parent = MainFrame

Library.Options.CustomBgID:OnChanged(function()
    local id = Library.Options.CustomBgID.Value
    if id ~= "" then
        if not id:find("rbxassetid://") then
            id = "rbxassetid://" .. id
        end
        BgImage.Image = id
        BgImage.Transparency = 0.3
    else
        BgImage.Image = ""
    end
end)

-- ==================== LOOPS DE LOS CHEATS ====================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if Library.Toggles.SpeedToggle.Value then
            character.Humanoid.WalkSpeed = Library.Options.SpeedValue.Value
        end
    end
end)

Library:Notify('CRIME.CC cargado con éxito. Presiona Insert.')