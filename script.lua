-- =================================================================
-- DEATH NOTE HUB | ELITE SUITE v15.0 (OPTIMIZED & LIGHTWEIGHT)
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("DeathNoteUI") then
    CoreGui.DeathNoteUI:Destroy()
end

-- =================================================================
-- CONFIGURACIÓN GLOBAL & ESTADOS
-- =================================================================
local Config = {
    MenuKey = Enum.KeyCode.Insert,
    AccentColor = Color3.fromRGB(115, 80, 160),

    -- Movement & Misc
    WalkSpeed = 16,
    SpeedEnabled = false,
    JumpPower = 50,
    JumpEnabled = false,
    Gravity = 196.2,
    GravityEnabled = false,
    Noclip = false,
    SpinBot = false,
    SpinSpeed = 20,
    FlyEnabled = false,
    FlySpeed = 50,
    RapidFire = false,
    RageBullets = false,

    -- Orbit Settings
    OrbitEnabled = false,
    OrbitSpeed = 15,
    OrbitRadius = 5,

    -- Keybinds
    Keys = {
        ESP = Enum.KeyCode.E,
        Speed = Enum.KeyCode.Q,
        Fly = Enum.KeyCode.F,
        Jump = Enum.KeyCode.J,
        Gravity = Enum.KeyCode.G,
        SpinBot = Enum.KeyCode.Z,
        Orbit = Enum.KeyCode.X
    },

    -- ESP Options
    ESP_Enabled = false,
    ESP_Boxes = false,
    ESP_Names = false,
    ESP_HealthBar = false,
    ESP_Tracers = false,
    ESP_Skeleton = false,
    ESP_Thickness = 1,
    ESP_BoxColor = Color3.fromRGB(255, 255, 255),
    ESP_NameColor = Color3.fromRGB(255, 255, 255),
    ESP_TracerColor = Color3.fromRGB(255, 255, 255),
    ESP_TargetColor = Color3.fromRGB(255, 0, 255),
    Fullbright = false,

    -- Aimbot Options
    Aimbot_Enabled = false,
    Aimbot_Key = Enum.UserInputType.MouseButton2,
    Aimbot_Smoothness = 0.15,
    Aimbot_FOV = 90,
    Aimbot_ShowFOV = false,
    Aimbot_TargetPart = "Head",

    -- Hitbox Expander
    Hitbox_Enabled = false,
    Hitbox_Size = 5,
    Hitbox_Preview = false,

    -- Listas
    Whitelist = {},
    Blacklist = {},
    LockedTarget = nil,
    OrbitTarget = nil, -- Objetivo fijado para el Orbit automático
    SpectatingPlayer = nil
}

local Connections = {}
local ESP_Cache = {}
local ToggleCallbacks = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Visible = false

local function UnloadScript()
    for _, conn in ipairs(Connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    
    pcall(function() FOVCircle:Remove() end)

    for _, esp in pairs(ESP_Cache) do
        pcall(function()
            esp.Box:Remove()
            esp.HealthOutline:Remove()
            esp.HealthBar:Remove()
            esp.Name:Remove()
            esp.Tracer:Remove()
            for _, line in pairs(esp.Skeleton) do line:Remove() end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 0
                hrp.CanCollide = true
                hrp.Color = Color3.fromRGB(163, 162, 165)
            end
        end
    end

    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or Camera.CameraSubject

    if CoreGui:FindFirstChild("DeathNoteUI") then
        CoreGui.DeathNoteUI:Destroy()
    end
end

-- =================================================================
-- SISTEMA DE LOGIN
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeathNoteUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local LoginFrame = Instance.new("Frame")
LoginFrame.Name = "LoginFrame"
LoginFrame.Size = UDim2.new(0, 320, 0, 160)
LoginFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
LoginFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
LoginFrame.BorderSizePixel = 0
LoginFrame.Active = true
LoginFrame.Draggable = true
LoginFrame.Parent = ScreenGui

local LoginStroke = Instance.new("UIStroke")
LoginStroke.Color = Color3.fromRGB(50, 45, 65)
LoginStroke.Thickness = 1
LoginStroke.Parent = LoginFrame

local LoginTopBar = Instance.new("Frame")
LoginTopBar.Size = UDim2.new(1, 0, 0, 24)
LoginTopBar.BackgroundColor3 = Color3.fromRGB(28, 25, 36)
LoginTopBar.BorderSizePixel = 0
LoginTopBar.Parent = LoginFrame

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, -10, 1, 0)
LoginTitle.Position = UDim2.new(0, 8, 0, 0)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Text = "Misty - Autenticación"
LoginTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
LoginTitle.Font = Enum.Font.Code
LoginTitle.TextSize = 11
LoginTitle.TextXAlignment = Enum.TextXAlignment.Left
LoginTitle.Parent = LoginTopBar

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(0, 280, 0, 30)
PassBox.Position = UDim2.new(0.5, -140, 0, 45)
PassBox.BackgroundColor3 = Color3.fromRGB(15, 13, 20)
PassBox.BorderSizePixel = 0
PassBox.Text = ""
PassBox.PlaceholderText = "Contraseña (24)"
PassBox.PlaceholderColor3 = Color3.fromRGB(90, 85, 110)
PassBox.TextColor3 = Color3.fromRGB(220, 220, 230)
PassBox.Font = Enum.Font.Code
PassBox.TextSize = 11
PassBox.ClearTextOnFocus = false
PassBox.Parent = LoginFrame

local PassStroke = Instance.new("UIStroke")
PassStroke.Color = Color3.fromRGB(45, 40, 60)
PassStroke.Thickness = 1
PassStroke.Parent = PassBox

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(0, 280, 0, 30)
LoginBtn.Position = UDim2.new(0.5, -140, 0, 95)
LoginBtn.BackgroundColor3 = Color3.fromRGB(115, 80, 160)
LoginBtn.BorderSizePixel = 0
LoginBtn.Text = "INGRESAR"
LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.Font = Enum.Font.Code
LoginBtn.TextSize = 11
LoginBtn.Parent = LoginFrame

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 45, 65)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

LoginBtn.MouseButton1Click:Connect(function()
    if PassBox.Text == "24" then
        TweenService:Create(LoginFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -160, 1.5, 0)}):Play()
        task.wait(0.3)
        LoginFrame:Destroy()
        MainFrame.Visible = true
    else
        PassBox.Text = ""
        PassBox.PlaceholderText = "Contraseña Incorrecta"
        PassBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

-- =================================================================
-- INTERFAZ PRINCIPAL CON PESTAÑAS SUPERIORES HORIZONTALES
-- =================================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(28, 25, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(0, 200, 1, 0)
BrandLabel.Position = UDim2.new(0, 12, 0, 0)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "Misty // DEATH NOTE HUB"
BrandLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
BrandLabel.Font = Enum.Font.Code
BrandLabel.TextSize = 11
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 25, 36)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 11
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local MainTabsBar = Instance.new("ScrollingFrame")
MainTabsBar.Size = UDim2.new(1, -16, 0, 30)
MainTabsBar.Position = UDim2.new(0, 8, 0, 36)
MainTabsBar.BackgroundColor3 = Color3.fromRGB(15, 13, 20)
MainTabsBar.BorderSizePixel = 0
MainTabsBar.ScrollBarThickness = 1
MainTabsBar.CanvasSize = UDim2.new(0, 700, 0, 0)
MainTabsBar.Parent = MainFrame

local MainTabsLayout = Instance.new("UIListLayout")
MainTabsLayout.FillDirection = Enum.FillDirection.Horizontal
MainTabsLayout.Padding = UDim.new(0, 3)
MainTabsLayout.Parent = MainTabsBar

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -16, 1, -78)
Container.Position = UDim2.new(0, 8, 0, 70)
Container.BackgroundColor3 = Color3.fromRGB(15, 13, 20)
Container.BorderSizePixel = 0
Container.Parent = MainFrame

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(35, 30, 48)
ContainerStroke.Thickness = 1
ContainerStroke.Parent = Container

local Pages = {}

local function UpdateUIColors()
    LoginStroke.Color = Config.AccentColor
    LoginBtn.BackgroundColor3 = Config.AccentColor
    MainStroke.Color = Config.AccentColor
    for _, tab in pairs(Pages) do
        if tab.View.Visible then
            tab.Button.BackgroundColor3 = Config.AccentColor
        end
    end
end

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 90, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 175)
    TabBtn.Font = Enum.Font.Code
    TabBtn.TextSize = 10
    TabBtn.Parent = MainTabsBar

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Config.AccentColor
    Page.Visible = false
    Page.Parent = Container
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.PaddingRight = UDim.new(0, 10)
    PagePadding.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end)

    Pages[name] = {Button = TabBtn, View = Page}

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Pages) do
            tab.View.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
            tab.Button.TextColor3 = Color3.fromRGB(150, 150, 175)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Config.AccentColor
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return Page
end

local CombatTab   = CreateTab("Aimbot")
local VisualsTab  = CreateTab("Visuals")
local RageTab     = CreateTab("Rage")
local PlayerTab   = CreateTab("Player")
local PlayersTab  = CreateTab("Players")
local ConfigTab   = CreateTab("Config")
local ColorsTab   = CreateTab("Colors")

Pages["Aimbot"].View.Visible = true
Pages["Aimbot"].Button.BackgroundColor3 = Config.AccentColor
Pages["Aimbot"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

local function AddToggle(parent, text, defaultState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 18)
    Btn.Position = UDim2.new(1, -50, 0.5, -9)
    Btn.BackgroundColor3 = defaultState and Config.AccentColor or Color3.fromRGB(35, 30, 48)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.Parent = Frame

    local state = defaultState
    local function SetState(newState)
        state = newState
        Btn.BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(35, 30, 48)
        callback(state)
    end

    Btn.MouseButton1Click:Connect(function()
        SetState(not state)
    end)

    return SetState
end

local function AddSlider(parent, text, min, max, default, decimals, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValLabel.Position = UDim2.new(0.7, -12, 0, 6)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Config.AccentColor
    ValLabel.Font = Enum.Font.Code
    ValLabel.TextSize = 11
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = Frame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -24, 0, 5)
    SliderBar.Position = UDim2.new(0, 12, 0, 34)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 30, 48)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Config.AccentColor
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local dragging = false
    local function UpdateInput(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * pos
        if decimals then
            value = tonumber(string.format("%.2f", value))
        else
            value = math.floor(value)
        end
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateInput(input)
        end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(26, 23, 34)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 11
    Btn.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function AddKeybind(parent, text, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0, 85, 0, 22)
    BindBtn.Position = UDim2.new(1, -95, 0.5, -11)
    BindBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
    BindBtn.BorderSizePixel = 0
    BindBtn.Text = typeof(defaultKey) == "EnumItem" and defaultKey.Name or tostring(defaultKey)
    BindBtn.TextColor3 = Config.AccentColor
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 11
    BindBtn.Parent = Frame

    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "..."
        BindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if listening then
            local key = nil
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or 
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                key = input.UserInputType
            end

            if key then
                listening = false
                BindBtn.Text = key.Name
                BindBtn.TextColor3 = Config.AccentColor
                callback(key)
            end
        end
    end)
end

local function AddColorPalette(parent, text, defaultColor, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 56)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ScrollPal = Instance.new("ScrollingFrame")
    ScrollPal.Size = UDim2.new(0, 220, 0, 32)
    ScrollPal.Position = UDim2.new(1, -230, 0.5, -16)
    ScrollPal.BackgroundTransparency = 1
    ScrollPal.CanvasSize = UDim2.new(0, 340, 0, 0)
    ScrollPal.ScrollBarThickness = 1
    ScrollPal.Parent = Frame

    local UIList = Instance.new("UIListLayout")
    UIList.FillDirection = Enum.FillDirection.Horizontal
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = ScrollPal

    local colors = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(115, 80, 160),
        Color3.fromRGB(60, 150, 255),
        Color3.fromRGB(170, 60, 255),
        Color3.fromRGB(255, 60, 180),
        Color3.fromRGB(255, 140, 40),
        Color3.fromRGB(255, 230, 60),
        Color3.fromRGB(100, 100, 100)
    }

    for _, col in ipairs(colors) do
        local ColorBtn = Instance.new("TextButton")
        ColorBtn.Size = UDim2.new(0, 26, 0, 26)
        ColorBtn.BackgroundColor3 = col
        ColorBtn.BorderSizePixel = 0
        ColorBtn.Text = ""
        ColorBtn.Parent = ScrollPal

        ColorBtn.MouseButton1Click:Connect(function() callback(col) end)
    end
end

local function AddDropdown(parent, text, options, defaultOption, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 30, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == defaultOption then currentIndex = i end
    end

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 110, 0, 22)
    DropBtn.Position = UDim2.new(1, -120, 0.5, -11)
    DropBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
    DropBtn.BorderSizePixel = 0
    DropBtn.Text = options[currentIndex]
    DropBtn.TextColor3 = Config.AccentColor
    DropBtn.Font = Enum.Font.Code
    DropBtn.TextSize = 11
    DropBtn.Parent = Frame

    DropBtn.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        local selected = options[currentIndex]
        DropBtn.Text = selected
        callback(selected)
    end)
end

-- =================================================================
-- LLENADO DE PESTAÑAS
-- =================================================================
AddToggle(CombatTab, "Aimbot", Config.Aimbot_Enabled, function(s) Config.Aimbot_Enabled = s end)
AddKeybind(CombatTab, "Tecla de Aimbot", Config.Aimbot_Key, function(k) Config.Aimbot_Key = k end)
AddDropdown(CombatTab, "Parte del cuerpo", {"Head", "HumanoidRootPart", "UpperTorso"}, Config.Aimbot_TargetPart, function(v) Config.Aimbot_TargetPart = v end)
AddSlider(CombatTab, "Suavidad", 0.01, 1.0, Config.Aimbot_Smoothness, true, function(v) Config.Aimbot_Smoothness = v end)
AddToggle(CombatTab, "Mostrar FOV", Config.Aimbot_ShowFOV, function(s) Config.Aimbot_ShowFOV = s end)
AddSlider(CombatTab, "Radio FOV", 5, 500, Config.Aimbot_FOV, false, function(v) Config.Aimbot_FOV = v end)

ToggleCallbacks.ESP = AddToggle(VisualsTab, "ESP General", Config.ESP_Enabled, function(s) Config.ESP_Enabled = s end)
AddKeybind(VisualsTab, "Tecla ESP", Config.Keys.ESP, function(k) Config.Keys.ESP = k end)
AddToggle(VisualsTab, "Cajas", Config.ESP_Boxes, function(s) Config.ESP_Boxes = s end)
AddToggle(VisualsTab, "Nombres", Config.ESP_Names, function(s) Config.ESP_Names = s end)
AddToggle(VisualsTab, "Barra de vida", Config.ESP_HealthBar, function(s) Config.ESP_HealthBar = s end)
AddToggle(VisualsTab, "Líneas de visión", Config.ESP_Tracers, function(s) Config.ESP_Tracers = s end)
AddToggle(VisualsTab, "Esqueleto", Config.ESP_Skeleton, function(s) Config.ESP_Skeleton = s end)
AddSlider(VisualsTab, "Grosor de líneas", 1, 5, Config.ESP_Thickness, false, function(v) Config.ESP_Thickness = v end)
AddToggle(VisualsTab, "Iluminación total", Config.Fullbright, function(s) Config.Fullbright = s end)

AddColorPalette(VisualsTab, "Color de Cajas", Config.ESP_BoxColor, function(c) Config.ESP_BoxColor = c end)
AddColorPalette(VisualsTab, "Color de Nombres", Config.ESP_NameColor, function(c) Config.ESP_NameColor = c end)
AddColorPalette(VisualsTab, "Color de Líneas", Config.ESP_TracerColor, function(c) Config.ESP_TracerColor = c end)

AddToggle(RageTab, "Ampliar hitboxes (Rage)", Config.Hitbox_Enabled, function(s) Config.Hitbox_Enabled = s end)
AddToggle(RageTab, "Previsualizar hitboxes", Config.Hitbox_Preview, function(s) Config.Hitbox_Preview = s end)
AddSlider(RageTab, "Tamaño de hitbox", 1, 50, Config.Hitbox_Size, false, function(v) Config.Hitbox_Size = v end)
AddToggle(RageTab, "Disparo automático rápido", Config.RapidFire, function(s) Config.RapidFire = s end)
AddToggle(RageTab, "Redirección de balas", Config.RageBullets, function(s) Config.RageBullets = s end)

-- Opciones de Player
ToggleCallbacks.Speed = AddToggle(PlayerTab, "Velocidad de movimiento", Config.SpeedEnabled, function(s) Config.SpeedEnabled = s end)
AddKeybind(PlayerTab, "Tecla de velocidad", Config.Keys.Speed, function(k) Config.Keys.Speed = k end)
AddSlider(PlayerTab, "Valor de velocidad", 16, 800, Config.WalkSpeed, false, function(v) Config.WalkSpeed = v end)

ToggleCallbacks.Jump = AddToggle(PlayerTab, "Salto potenciado", Config.JumpEnabled, function(s) Config.JumpEnabled = s end)
AddKeybind(PlayerTab, "Tecla de salto", Config.Keys.Jump, function(k) Config.Keys.Jump = k end)
AddSlider(PlayerTab, "Valor de salto", 50, 300, Config.JumpPower, false, function(v) Config.JumpPower = v end)

AddToggle(PlayerTab, "Atravesar paredes", Config.Noclip, function(s) Config.Noclip = s end)

ToggleCallbacks.Gravity = AddToggle(PlayerTab, "Modificar gravedad", Config.GravityEnabled, function(s) Config.GravityEnabled = s end)
AddKeybind(PlayerTab, "Tecla de gravedad", Config.Keys.Gravity, function(k) Config.Keys.Gravity = k end)
AddSlider(PlayerTab, "Valor de gravedad", 0, 196, Config.Gravity, false, function(v) Config.Gravity = v end)

ToggleCallbacks.SpinBot = AddToggle(PlayerTab, "Giro automático", Config.SpinBot, function(s) Config.SpinBot = s end)
AddKeybind(PlayerTab, "Tecla de giro", Config.Keys.SpinBot, function(k) Config.Keys.SpinBot = k end)
AddSlider(PlayerTab, "Velocidad de giro", 1, 100, Config.SpinSpeed, false, function(v) Config.SpinSpeed = v end)

ToggleCallbacks.Fly = AddToggle(PlayerTab, "Vuelo libre", Config.FlyEnabled, function(s) Config.FlyEnabled = s end)
AddKeybind(PlayerTab, "Tecla de vuelo", Config.Keys.Fly, function(k) Config.Keys.Fly = k end)
AddSlider(PlayerTab, "Velocidad de vuelo", 10, 500, Config.FlySpeed, false, function(v) Config.FlySpeed = v end)

-- Orbit Controls (Fijar objetivo al presionar la tecla)
AddToggle(PlayerTab, "Orbit Target (Fijar con tecla)", Config.OrbitEnabled, function(s) Config.OrbitEnabled = s end)
AddKeybind(PlayerTab, "Tecla de Orbit", Config.Keys.Orbit, function(k) Config.Keys.Orbit = k end)
AddSlider(PlayerTab, "Velocidad de Orbit", 1, 50, Config.OrbitSpeed, false, function(v) Config.OrbitSpeed = v end)
AddSlider(PlayerTab, "Radio de Orbit (Cerca/Lejos)", 0.1, 15, Config.OrbitRadius, true, function(v) Config.OrbitRadius = v end)

-- Players Tab Logic
local PlayersScroll = Instance.new("ScrollingFrame")
PlayersScroll.Size = UDim2.new(1, 0, 1, 0)
PlayersScroll.BackgroundTransparency = 1
PlayersScroll.ScrollBarThickness = 3
PlayersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayersScroll.Parent = PlayersTab

local PlayersLayout = Instance.new("UIListLayout")
PlayersLayout.Padding = UDim.new(0, 6)
PlayersLayout.Parent = PlayersScroll

PlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PlayersScroll.CanvasSize = UDim2.new(0, 0, 0, PlayersLayout.AbsoluteContentSize.Y + 15)
end)

local function RefreshPlayerList()
    for _, child in ipairs(PlayersScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local PFrame = Instance.new("Frame")
            PFrame.Size = UDim2.new(1, -10, 0, 40)
            PFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
            PFrame.BorderSizePixel = 0
            PFrame.Parent = PlayersScroll

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(35, 30, 48)
            Stroke.Thickness = 1
            Stroke.Parent = PFrame

            local PName = Instance.new("TextLabel")
            PName.Size = UDim2.new(0, 110, 1, 0)
            PName.Position = UDim2.new(0, 12, 0, 0)
            PName.BackgroundTransparency = 1
            PName.Text = p.Name
            PName.TextColor3 = Color3.fromRGB(220, 220, 235)
            PName.Font = Enum.Font.Code
            PName.TextSize = 11
            PName.TextXAlignment = Enum.TextXAlignment.Left
            PName.Parent = PFrame

            local TpBtn = Instance.new("TextButton")
            TpBtn.Size = UDim2.new(0, 36, 0, 24)
            TpBtn.Position = UDim2.new(1, -170, 0.5, -12)
            TpBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
            TpBtn.BorderSizePixel = 0
            TpBtn.Text = "TP"
            TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TpBtn.Font = Enum.Font.Code
            TpBtn.TextSize = 11
            TpBtn.Parent = PFrame

            TpBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end)

            local SpecBtn = Instance.new("TextButton")
            SpecBtn.Size = UDim2.new(0, 44, 0, 24)
            SpecBtn.Position = UDim2.new(1, -130, 0.5, -12)
            SpecBtn.BackgroundColor3 = Config.SpectatingPlayer == p and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(30, 26, 40)
            SpecBtn.BorderSizePixel = 0
            SpecBtn.Text = "SPEC"
            SpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpecBtn.Font = Enum.Font.Code
            SpecBtn.TextSize = 10
            SpecBtn.Parent = PFrame

            SpecBtn.MouseButton1Click:Connect(function()
                if Config.SpectatingPlayer == p then
                    Config.SpectatingPlayer = nil
                    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                else
                    Config.SpectatingPlayer = p
                    if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                        Camera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
                    end
                end
            end)

            local WlBtn = Instance.new("TextButton")
            WlBtn.Size = UDim2.new(0, 36, 0, 24)
            WlBtn.Position = UDim2.new(1, -82, 0.5, -12)
            WlBtn.BackgroundColor3 = Config.Whitelist[p] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(30, 26, 40)
            WlBtn.BorderSizePixel = 0
            WlBtn.Text = "WL"
            WlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            WlBtn.Font = Enum.Font.Code
            WlBtn.TextSize = 11
            WlBtn.Parent = PFrame

            WlBtn.MouseButton1Click:Connect(function()
                if Config.Whitelist[p] then
                    Config.Whitelist[p] = nil
                    WlBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
                else
                    Config.Whitelist[p] = true
                    Config.Blacklist[p] = nil
                    WlBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
            end)

            local BlBtn = Instance.new("TextButton")
            BlBtn.Size = UDim2.new(0, 36, 0, 24)
            BlBtn.Position = UDim2.new(1, -42, 0.5, -12)
            BlBtn.BackgroundColor3 = Config.Blacklist[p] and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(30, 26, 40)
            BlBtn.BorderSizePixel = 0
            BlBtn.Text = "BL"
            BlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            BlBtn.Font = Enum.Font.Code
            BlBtn.TextSize = 11
            BlBtn.Parent = PFrame

            BlBtn.MouseButton1Click:Connect(function()
                if Config.Blacklist[p] then
                    Config.Blacklist[p] = nil
                    BlBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
                else
                    Config.Blacklist[p] = true
                    Config.Whitelist[p] = nil
                    BlBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                end
            end)
        end
    end
end

RefreshPlayerList()
table.insert(Connections, Players.PlayerAdded:Connect(RefreshPlayerList))
table.insert(Connections, Players.PlayerRemoving:Connect(RefreshPlayerList))

AddKeybind(ConfigTab, "Tecla del menú", Config.MenuKey, function(k) Config.MenuKey = k end)
AddColorPalette(ConfigTab, "Color principal", Config.AccentColor, function(c) 
    Config.AccentColor = c 
    UpdateUIColors()
end)
AddButton(ConfigTab, "Cerrar / Destruir script", function()
    UnloadScript()
end)

-- =================================================================
-- BUCLE PRINCIPAL & ORBIT LOGIC (FIJADO AUTOMÁTICO POR TECLA)
-- =================================================================
local flyKeys = {W = false, S = false, A = false, D = false, Space = false, Shift = false}
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
        if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
        if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
        if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
        if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
end))

-- Función para encontrar al jugador más cercano al mouse en el momento de pulsar la tecla
local function GetClosestPlayerToMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local flyBodyVel, flyBodyGyro
local orbitAngle = 0
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoid then
                if Config.SpeedEnabled then humanoid.WalkSpeed = Config.WalkSpeed end
                if Config.JumpEnabled then 
                    humanoid.UseJumpPower = true 
                    humanoid.JumpPower = Config.JumpPower 
                end
            end

            if Config.Noclip then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end

            -- Lógica de Orbit Automática con el objetivo fijado
            if Config.OrbitEnabled and Config.OrbitTarget and Config.OrbitTarget.Character and Config.OrbitTarget.Character:FindFirstChild("HumanoidRootPart") and rootPart then
                local targetHrp = Config.OrbitTarget.Character.HumanoidRootPart
                orbitAngle = orbitAngle + (Config.OrbitSpeed * dt)
                local x = targetHrp.Position.X + math.cos(orbitAngle) * Config.OrbitRadius
                local z = targetHrp.Position.Z + math.sin(orbitAngle) * Config.OrbitRadius
                local y = targetHrp.Position.Y
                rootPart.CFrame = CFrame.new(Vector3.new(x, y, z), targetHrp.Position)
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end

            if Config.SpinBot and rootPart and not Config.OrbitEnabled then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
            end

            if Config.FlyEnabled and rootPart and not Config.OrbitEnabled then
                if not flyBodyVel then
                    flyBodyVel = Instance.new("BodyVelocity", rootPart)
                    flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBodyGyro = Instance.new("BodyGyro", rootPart)
                    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                end
                flyBodyGyro.CFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                if flyKeys.W then moveDir = moveDir + Camera.CFrame.LookVector end
                if flyKeys.S then moveDir = moveDir - Camera.CFrame.LookVector end
                if flyKeys.A then moveDir = moveDir - Camera.CFrame.RightVector end
                if flyKeys.D then moveDir = moveDir + Camera.CFrame.RightVector end
                if flyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if flyKeys.Shift then moveDir = moveDir - Vector3.new(0, 1, 0) end
                flyBodyVel.Velocity = moveDir * Config.FlySpeed
            else
                if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
                if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            end
        end

        if Config.GravityEnabled then Workspace.Gravity = Config.Gravity end

        if Config.RapidFire and character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
        end

        if Config.Hitbox_Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:IsA("BasePart") then
                        hrp.Size = Vector3.new(Config.Hitbox_Size * 2, Config.Hitbox_Size * 2, Config.Hitbox_Size * 2)
                        hrp.CanCollide = false
                        hrp.Transparency = Config.Hitbox_Preview and 0.5 or 1
                        hrp.Color = Color3.fromRGB(255, 50, 50)
                    end
                end
            end
        end
    end)
end))

-- =================================================================
-- AIMBOT
-- =================================================================
local function GetTarget()
    local mousePos = UserInputService:GetMouseLocation()

    if Config.LockedTarget and Config.LockedTarget.Character and Config.LockedTarget.Character:FindFirstChild(Config.Aimbot_TargetPart) then
        local part = Config.LockedTarget.Character[Config.Aimbot_TargetPart]
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist <= Config.Aimbot_FOV + 100 then
                return Config.LockedTarget
            end
        end
    end

    local closestPlayer = nil
    local shortestDistance = Config.Aimbot_FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Config.Whitelist[player] and player.Character and player.Character:FindFirstChild(Config.Aimbot_TargetPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local part = player.Character[Config.Aimbot_TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if Config.Blacklist[player] then distance = 0 end

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    Config.LockedTarget = closestPlayer
    return closestPlayer
end

local function IsKeyPressed(key)
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(key)
        elseif key.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(key)
        end
    end
    return false
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    pcall(function()
        local mousePos = UserInputService:GetMouseLocation()
        
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Config.Aimbot_FOV
        FOVCircle.Color = Config.AccentColor
        FOVCircle.Visible = Config.Aimbot_ShowFOV and Config.Aimbot_Enabled

        if not IsKeyPressed(Config.Aimbot_Key) then
            Config.LockedTarget = nil
        end

        local target = GetTarget()
        if Config.Aimbot_Enabled and IsKeyPressed(Config.Aimbot_Key) and target then
            local targetPos = target.Character[Config.Aimbot_TargetPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot_Smoothness)
        end

        if Config.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        end
    end)
end))

-- =================================================================
-- ESP
-- =================================================================
local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Filled = false
    box.Visible = false

    local healthOutline = Drawing.new("Square")
    healthOutline.Filled = true
    healthOutline.Color = Color3.fromRGB(0, 0, 0)
    healthOutline.Visible = false

    local healthBar = Drawing.new("Square")
    healthBar.Filled = true
    healthBar.Color = Color3.fromRGB(255, 255, 255)
    healthBar.Visible = false

    local name = Drawing.new("Text")
    name.Text = player.Name
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false

    local skeleton = {
        HeadToTorso = Drawing.new("Line"),
        LeftArm = Drawing.new("Line"),
        RightArm = Drawing.new("Line"),
        LeftLeg = Drawing.new("Line"),
        RightLeg = Drawing.new("Line")
    }
    for _, line in pairs(skeleton) do line.Visible = false end

    ESP_Cache[player] = {Box = box, HealthOutline = healthOutline, HealthBar = healthBar, Name = name, Tracer = tracer, Skeleton = skeleton}
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        pcall(function()
            ESP_Cache[player].Box:Remove()
            ESP_Cache[player].HealthOutline:Remove()
            ESP_Cache[player].HealthBar:Remove()
            ESP_Cache[player].Name:Remove()
            ESP_Cache[player].Tracer:Remove()
            for _, line in pairs(ESP_Cache[player].Skeleton) do line:Remove() end
        end)
        ESP_Cache[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end

table.insert(Connections, Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end))
table.insert(Connections, Players.PlayerRemoving:Connect(RemoveESP))

table.insert(Connections, RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESP_Cache) do
        pcall(function()
            local currentBoxColor = Config.ESP_BoxColor
            local currentTracerColor = Config.ESP_TracerColor
            
            local currentNameColor = Config.ESP_NameColor
            if player == Config.LockedTarget or Config.Whitelist[player] or Config.Blacklist[player] or player == Config.OrbitTarget then
                currentNameColor = Color3.fromRGB(0, 255, 0)
            end

            if Config.ESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    local t = Config.ESP_Thickness

                    if Config.ESP_Boxes then
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        esp.Box.Color = currentBoxColor
                        esp.Box.Thickness = t
                        esp.Box.Visible = true
                    else esp.Box.Visible = false end

                    if Config.ESP_HealthBar then
                        local healthPct = humanoid.Health / humanoid.MaxHealth
                        esp.HealthOutline.Size = Vector2.new(4, height)
                        esp.HealthOutline.Position = Vector2.new(vector.X - width / 2 - 6, vector.Y - height / 2)
                        esp.HealthOutline.Visible = true

                        esp.HealthBar.Size = Vector2.new(2, height * healthPct)
                        esp.HealthBar.Position = Vector2.new(vector.X - width / 2 - 5, vector.Y + height / 2 - (height * healthPct))
                        esp.HealthBar.Color = Color3.fromRGB(255, 255, 255)
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthOutline.Visible = false
                        esp.HealthBar.Visible = false
                    end

                    if Config.ESP_Names then
                        esp.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 16)
                        esp.Name.Color = currentNameColor
                        esp.Name.Visible = true
                    else esp.Name.Visible = false end

                    if Config.ESP_Tracers then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(vector.X, vector.Y + height / 2)
                        esp.Tracer.Color = currentTracerColor
                        esp.Tracer.Thickness = t
                        esp.Tracer.Visible = true
                    else esp.Tracer.Visible = false end

                    if Config.ESP_Skeleton and head and (player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")) then
                        local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                        local la = player.Character:FindFirstChild("LeftUpperArm") or player.Character:FindFirstChild("Left Arm")
                        local ra = player.Character:FindFirstChild("RightUpperArm") or player.Character:FindFirstChild("Right Arm")
                        local ll = player.Character:FindFirstChild("LeftUpperLeg") or player.Character:FindFirstChild("Left Leg")
                        local rl = player.Character:FindFirstChild("RightUpperLeg") or player.Character:FindFirstChild("Right Leg")

                        local function drawBone(boneLine, p1, p2)
                            if p1 and p2 then
                                local v1, s1 = Camera:WorldToViewportPoint(p1.Position)
                                local v2, s2 = Camera:WorldToViewportPoint(p2.Position)
                                if s1 and s2 then
                                    boneLine.From = Vector2.new(v1.X, v1.Y)
                                    boneLine.To = Vector2.new(v2.X, v2.Y)
                                    boneLine.Color = currentBoxColor
                                    boneLine.Thickness = t
                                    boneLine.Visible = true
                                    return
                                end
                            end
                            boneLine.Visible = false
                        end

                        drawBone(esp.Skeleton.HeadToTorso, head, torso)
                        drawBone(esp.Skeleton.LeftArm, torso, la)
                        drawBone(esp.Skeleton.RightArm, torso, ra)
                        drawBone(esp.Skeleton.LeftLeg, torso, ll)
                        drawBone(esp.Skeleton.RightLeg, torso, rl)
                    else
                        for _, line in pairs(esp.Skeleton) do line.Visible = false end
                    end
                else
                    esp.Box.Visible = false
                    esp.HealthOutline.Visible = false
                    esp.HealthBar.Visible = false
                    esp.Name.Visible = false
                    esp.Tracer.Visible = false
                    for _, line in pairs(esp.Skeleton) do line.Visible = false end
                end
            else
                esp.Box.Visible = false
                esp.HealthOutline.Visible = false
                esp.HealthBar.Visible = false
                esp.Name.Visible = false
                esp.Tracer.Visible = false
                for _, line in pairs(esp.Skeleton) do line.Visible = false end
            end
        end)
    end
end))

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if (typeof(Config.MenuKey) == "EnumItem" and input.KeyCode == Config.MenuKey) or (input.UserInputType == Config.MenuKey) then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == Config.Keys.Orbit then
            Config.OrbitEnabled = not Config.OrbitEnabled
            if Config.OrbitEnabled then
                Config.OrbitTarget = GetClosestPlayerToMouse()
            else
                Config.OrbitTarget = nil
            end
        elseif input.KeyCode == Config.Keys.ESP then
            Config.ESP_Enabled = not Config.ESP_Enabled
            if ToggleCallbacks.ESP then ToggleCallbacks.ESP(Config.ESP_Enabled) end
        elseif input.KeyCode == Config.Keys.Speed then
            Config.SpeedEnabled = not Config.SpeedEnabled
            if ToggleCallbacks.Speed then ToggleCallbacks.Speed(Config.SpeedEnabled) end
        elseif input.KeyCode == Config.Keys.Fly then
            Config.FlyEnabled = not Config.FlyEnabled
            if ToggleCallbacks.Fly then ToggleCallbacks.Fly(Config.FlyEnabled) end
        elseif input.KeyCode == Config.Keys.Jump then
            Config.JumpEnabled = not Config.JumpEnabled
            if ToggleCallbacks.Jump then ToggleCallbacks.Jump(Config.JumpEnabled) end
        elseif input.KeyCode == Config.Keys.Gravity then
            Config.GravityEnabled = not Config.GravityEnabled
            if ToggleCallbacks.Gravity then ToggleCallbacks.Gravity(Config.GravityEnabled) end
        elseif input.KeyCode == Config.Keys.SpinBot then
            Config.SpinBot = not Config.SpinBot
            if ToggleCallbacks.SpinBot then ToggleCallbacks.SpinBot(Config.SpinBot) end
        end
    end
end))