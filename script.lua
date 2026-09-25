local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = 'CRIME.CC | Da Hood ESP',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuKeybind = Enum.KeyCode.Insert
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings')
}

-- ==================== VISUALS TAB (ESP) ====================
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

ESPGroup:AddToggle('EspEnabled', {
    Text = 'Enable Box ESP',
    Default = false,
})

ESPGroup:AddToggle('EspName', {
    Text = 'Name Tags',
    Default = false,
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

-- ==================== LÓGICA DEL ESP ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espCache = {}

local function removeEsp(player)
    if espCache[player] then
        if espCache[player].Box then espCache[player].Box:Remove() end
        if espCache[player].Name then espCache[player].Name:Remove() end
        espCache[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")

            if Library.Toggles.EspEnabled.Value and character and humanoidRootPart and humanoid and humanoid.Health > 0 then
                if not espCache[player] then
                    espCache[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text")
                    }
                    espCache[player].Box.Visible = false
                    espCache[player].Box.Thickness = 1
                    espCache[player].Box.Color = Color3.fromRGB(255, 255, 255)
                    espCache[player].Box.Filled = false

                    espCache[player].Name.Visible = false
                    espCache[player].Name.Size = 14
                    espCache[player].Name.Center = true
                    espCache[player].Name.Outline = true
                    espCache[player].Name.Color = Color3.fromRGB(255, 255, 255)
                end

                local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local head = character:FindFirstChild("Head")
                    local topVector = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                    local legVector = Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(topVector.Y - legVector.Y)
                    local width = height / 2

                    -- Dibujar Caja
                    local box = espCache[player].Box
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(vector.X - width / 2, topVector.Y)
                    box.Visible = true

                    -- Dibujar Nombre
                    local name = espCache[player].Name
                    if Library.Toggles.EspName.Value then
                        name.Text = player.Name
                        name.Position = Vector2.new(vector.X, topVector.Y - 18)
                        name.Visible = true
                    else
                        name.Visible = false
                    end
                else
                    if espCache[player] then
                        espCache[player].Box.Visible = false
                        espCache[player].Name.Visible = false
                    end
                end
            else
                removeEsp(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

Library:Notify('CRIME.CC ESP cargado con éxito. Presiona Insert.')