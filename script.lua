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
}):AddKeyPicker('AimKey', { Default = 'E', SyncToggleState = false, Mode = 'Hold', Text = 'Aimbot Key', NoUI = false })

AimbotGroup:AddDropdown('TargetPart', {
    Values = {'Head', 'HumanoidRootPart'},
    Default = 1,
    Text = 'Target Part',
})

-- ==================== PLAYER TAB ====================
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

-- ==================== SETTINGS TAB ====================
local MenuSettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu Customization')

MenuSettingsGroup:AddButton('Unload Script', function()
    Library:Unload()
end)

MenuSettingsGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { 
    Default = 'Insert', 
    NoUI = true, 
    Text = 'Menu Keybind' 
})

-- ==================== LÓGICA REAL DE LOS CHEATS ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Función para encontrar al jugador más cercano al cursor
local function GetClosestPlayer()
    local target = nil
    local shortestDist = math.huge

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local part = v.Character:FindFirstChild(Library.Options.TargetPart.Value)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = v
                    end
                end
            end
        end
    end
    return target
end

-- Hook para el Aimbot / Silent Aim en Da Hood
local mouse = LocalPlayer:GetMouse()
RunService.RenderStepped:Connect(function()
    -- Lógica de WalkSpeed
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if Library.Toggles.SpeedToggle.Value then
            character.Humanoid.WalkSpeed = Library.Options.SpeedValue.Value
        end
    end

    -- Lógica de Aimbot (se activa al mantener presionada la tecla configurada, por defecto 'E')
    if Library.Toggles.AimEnable.Value and Library.Options.AimKey:GetState() then
        local targetPlayer = GetClosestPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Library.Options.TargetPart.Value)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

Library:Notify('CRIME.CC Funcional cargado con éxito. Presiona Insert.')