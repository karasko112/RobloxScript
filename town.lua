-- KARA HUB V18 - cleaned build (FIXED by Grok)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Character
local Humanoid
local RootPart

local DrawingLib = rawget(_G, "Drawing") or Drawing
local MoveMouseRelative = rawget(_G, "mousemoverel") or mousemoverel

local Connections = {}
local ESPHighlights = {}
local ESPBoxes = {}

local FlyBodyVelocity
local FlyBodyGyro
local GhostModel
local FakeLagMarker
local BindConnection

local DesyncModes = {"Anchor", "CFrame", "Velocity"}
local CurrentModeIndex = 1
local DesyncActive = false
local FakeCFrame = nil

local function addConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function getCharacter()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Character = character
    Humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 15)
    RootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 15)
end

addConnection(LocalPlayer.CharacterAdded:Connect(getCharacter))
getCharacter()

local Config = {
    Visuals = {
        Enabled = false,
        Boxes = false,
        Names = true,
        Health = true,
        Outline = true,
        Color = Color3.fromRGB(0, 170, 255),
        R = 0,
        G = 170,
        B = 255,
        LookTracers = false,      -- ← ИСПРАВЛЕНО
        PlayerTracers = false,    -- ← ИСПРАВЛЕНО
    },
    Combat = {
        Enabled = false,
        FOV = 150,
        ShowFOV = true,
        Smoothness = 20,
        TargetPart = "Head",
        WallCheck = true,
        FriendCheck = false,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOV_R = 255,
        FOV_G = 255,
        FOV_B = 255,
    },
    Movement = {
        SpeedEnabled = false,
        SpeedMultiplier = 4,
        FlyEnabled = false,
        FlySpeed = 120,
        FlyKey = Enum.KeyCode.F,
        Noclip = false,
        TPOnZ = true,
        TPHeight = 3,
        TPToTop = false,
        FakeLagEnabled = false,
        FakeLagKey = Enum.KeyCode.Y,
    },
    World = {
        TimeEnabled = false,
        Time = 12,
    },
}

local function updateColor()
    Config.Visuals.Color = Color3.fromRGB(Config.Visuals.R, Config.Visuals.G, Config.Visuals.B)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaraHub_V18_Cleaned"
ScreenGui.ResetOnSpawn = false

local parentOk = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not parentOk then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 520, 0, 550)
Main.Position = UDim2.new(0.5, -260, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "KARA HUB V18 | CLEANED + FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

local NavBar = Instance.new("Frame")
NavBar.Parent = Main
NavBar.Size = UDim2.new(0, 140, 1, -70)
NavBar.Position = UDim2.new(0, 10, 0, 60)
NavBar.BackgroundTransparency = 1
Instance.new("UIListLayout", NavBar).Padding = UDim.new(0, 8)

local PageContainer = Instance.new("Frame")
PageContainer.Parent = Main
PageContainer.Size = UDim2.new(1, -170, 1, -70)
PageContainer.Position = UDim2.new(0, 160, 0, 60)
PageContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
PageContainer.BorderSizePixel = 0
Instance.new("UICorner", PageContainer)

local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Parent = PageContainer
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
    return page
end

local function createSubMenu(titleText, sizeY)
    local popup = Instance.new("Frame")
    popup.Parent = Main
    popup.Size = UDim2.new(0, 260, 0, sizeY)
    popup.Position = UDim2.new(1, 15, 0, 0)
    popup.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    popup.BorderSizePixel = 0
    popup.Visible = false
    Instance.new("UICorner", popup)

    local title = Instance.new("TextLabel")
    title.Parent = popup
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = string.upper(titleText)
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16

    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = popup
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)

    return popup, scroll
end

local function resetContainer(container)
    container:ClearAllChildren()
    Instance.new("UIListLayout", container).Padding = UDim.new(0, 8)
end

local PageV = createPage()
local PageC = createPage()
local PageM = createPage()
local PageW = createPage()

local PopV, ScrollV = createSubMenu("ESP Config", 450)
local PopC, ScrollC = createSubMenu("Aim Config", 350)
local PopM, ScrollM = createSubMenu("Move Config", 400)
local PopFL, ScrollFL = createSubMenu("Fake Lag Config", 150)
local AllPopups = { PopV, PopC, PopM, PopFL }

local function hidePopups()
    for _, popup in ipairs(AllPopups) do
        popup.Visible = false
    end
end

local function addToggle(parent, text, defaultValue, callback, rightClickCallback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1

    local button = Instance.new("TextButton")
    button.Parent = frame
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 15
    Instance.new("UICorner", button)

    local state = defaultValue
    local function render()
        button.Text = text .. ": " .. (state and "ON" or "OFF")
    end

    render()

    button.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    if rightClickCallback then
        button.MouseButton2Click:Connect(function()
            hidePopups()
            rightClickCallback()
        end)
    end
end

local function addSlider(parent, text, minValue, maxValue, defaultValue, callback, fillColor)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 15

    local background = Instance.new("Frame")
    background.Parent = frame
    background.Size = UDim2.new(1, 0, 0, 10)
    background.Position = UDim2.new(0, 0, 0, 30)
    background.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    background.BorderSizePixel = 0
    Instance.new("UICorner", background)

    local fill = Instance.new("Frame")
    fill.Parent = background
    fill.BackgroundColor3 = fillColor or Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill)

    local currentValue = defaultValue

    local function render(value)
        local alpha = 0
        if maxValue ~= minValue then
            alpha = (value - minValue) / (maxValue - minValue)
        end

        fill.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
    end

    render(currentValue)

    background.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        local dragConnection
        dragConnection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                dragConnection:Disconnect()
                return
            end

            local alpha = math.clamp(
                (UserInputService:GetMouseLocation().X - background.AbsolutePosition.X) / background.AbsoluteSize.X,
                0,
                1
            )

            local rawValue = minValue + (maxValue - minValue) * alpha
            currentValue = math.floor(rawValue + 0.5)
            render(currentValue)
            callback(currentValue)
        end)
    end)
end

local function addKeybind(parent, text, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1

    local button = Instance.new("TextButton")
    button.Parent = frame
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(55, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 15
    Instance.new("UICorner", button)

    local currentKey = defaultKey
    button.Text = text .. ": " .. currentKey.Name

    button.MouseButton1Click:Connect(function()
        button.Text = "Press any key..."

        if BindConnection then
            BindConnection:Disconnect()
        end

        BindConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            currentKey = input.KeyCode
            button.Text = text .. ": " .. currentKey.Name
            callback(currentKey)

            if BindConnection then
                BindConnection:Disconnect()
                BindConnection = nil
            end
        end)
    end)
end

local function removeFakeLagMarker()
    if FakeLagMarker then
        FakeLagMarker:Destroy()
        FakeLagMarker = nil
    end
end

-- ==================== ИСПРАВЛЕННАЯ ФУНКЦИЯ DESYNC ====================
local function toggleDesync(state)
    DesyncActive = state
    if DesyncActive then
        if not RootPart then return end
        FakeCFrame = RootPart.CFrame
        
        Character.Archivable = true
        GhostModel = Character:Clone()
        for _, obj in ipairs(GhostModel:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Anchored = true
                obj.CanCollide = false
                obj.Transparency = 0.45
                obj.Material = Enum.Material.ForceField
                obj.Color = Config.Visuals.Color
            elseif not obj:IsA("Decal") and not obj:IsA("Script") and not obj:IsA("LocalScript") then
                obj:Destroy()
            end
        end
        GhostModel.Parent = workspace
    else
        if GhostModel then GhostModel:Destroy() GhostModel = nil end
        if RootPart then RootPart.Anchored = false end
        FakeCFrame = nil
    end
end

local function toggleFlyState(state)
    Config.Movement.FlyEnabled = state

    if not RootPart or not Humanoid then
        return
    end

    if state then
        if not FlyBodyVelocity then
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyVelocity.Velocity = Vector3.zero
            FlyBodyVelocity.Parent = RootPart
        end

        if not FlyBodyGyro then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyGyro.P = 9000
            FlyBodyGyro.Parent = RootPart
        end

        Humanoid.PlatformStand = true
        return
    end

    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end

    if FlyBodyGyro then
        FlyBodyGyro:Destroy()
        FlyBodyGyro = nil
    end

    Humanoid.PlatformStand = false
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

addToggle(PageV, "ESP Master", false, function(value)
    Config.Visuals.Enabled = value
end, function()
    PopV.Visible = true
end)

addToggle(ScrollV, "2D Boxes", false, function(value)
    Config.Visuals.Boxes = value
end)

addToggle(ScrollV, "Show Outline", true, function(value)
    Config.Visuals.Outline = value
end)

addToggle(ScrollV, "Show Health", true, function(value)
    Config.Visuals.Health = value
end)

addToggle(ScrollV, "Show Names", true, function(value)
    Config.Visuals.Names = value
end)

addToggle(ScrollV, "Look Tracers", false, function(value)
    Config.Visuals.LookTracers = value
end)

addToggle(ScrollV, "Player Tracers", false, function(value)
    Config.Visuals.PlayerTracers = value
end)

addSlider(ScrollV, "Color R", 0, 255, 0, function(value)
    Config.Visuals.R = value
    updateColor()
end, Color3.fromRGB(220, 50, 50))

addSlider(ScrollV, "Color G", 0, 255, 170, function(value)
    Config.Visuals.G = value
    updateColor()
end, Color3.fromRGB(50, 220, 50))

addSlider(ScrollV, "Color B", 0, 255, 255, function(value)
    Config.Visuals.B = value
    updateColor()
end, Color3.fromRGB(50, 150, 255))

addToggle(PageC, "Aimbot (Hold RMB)", false, function(value)
    Config.Combat.Enabled = value
end, function()
    PopC.Visible = true
    resetContainer(ScrollC)
    
    addToggle(ScrollC, "Friend Check", Config.Combat.FriendCheck, function(value)
        Config.Combat.FriendCheck = value
    end)

    addToggle(ScrollC, "Wall Check", Config.Combat.WallCheck, function(value)
        Config.Combat.WallCheck = value
    end)

    addToggle(ScrollC, "Show FOV Circle", Config.Combat.ShowFOV, function(value)
        Config.Combat.ShowFOV = value
    end)

    local TargetParts = {"Head", "Torso", "HumanoidRootPart"}
    local partBtn = Instance.new("TextButton")
    partBtn.Parent = ScrollC
    partBtn.Size = UDim2.new(1, 0, 0, 45)
    partBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    partBtn.Text = "Target: " .. Config.Combat.TargetPart
    partBtn.TextColor3 = Color3.new(1, 1, 1)
    partBtn.Font = Enum.Font.GothamSemibold
    partBtn.TextSize = 14
    Instance.new("UICorner", partBtn)

    partBtn.MouseButton1Click:Connect(function()
        local currentIndex = table.find(TargetParts, Config.Combat.TargetPart) or 1
        currentIndex = currentIndex + 1
        if currentIndex > #TargetParts then currentIndex = 1 end
        Config.Combat.TargetPart = TargetParts[currentIndex]
        partBtn.Text = "Target: " .. Config.Combat.TargetPart
    end)

    addSlider(ScrollC, "Aimbot FOV", 10, 800, Config.Combat.FOV, function(value)
        Config.Combat.FOV = value
    end)

    addSlider(ScrollC, "Smoothness", 1, 100, Config.Combat.Smoothness, function(value)
        Config.Combat.Smoothness = value
    end)

    addSlider(ScrollC, "FOV Color R", 0, 255, Config.Combat.FOV_R, function(value)
        Config.Combat.FOV_R = value
    end, Color3.fromRGB(220, 50, 50))

    addSlider(ScrollC, "FOV Color G", 0, 255, Config.Combat.FOV_G, function(value)
        Config.Combat.FOV_G = value
    end, Color3.fromRGB(50, 220, 50))

    addSlider(ScrollC, "FOV Color B", 0, 255, Config.Combat.FOV_B, function(value)
        Config.Combat.FOV_B = value
    end, Color3.fromRGB(50, 150, 255))
end)

addToggle(PageM, "Speed Boost", false, function(value)
    Config.Movement.SpeedEnabled = value
end, function()
    PopM.Visible = true
    resetContainer(ScrollM)
    addSlider(ScrollM, "Speed Mult", 1, 15, Config.Movement.SpeedMultiplier, function(value)
        Config.Movement.SpeedMultiplier = value
    end)
end)

addToggle(PageM, "Fly Mode", false, function(value)
    toggleFlyState(value)
end, function()
    PopM.Visible = true
    resetContainer(ScrollM)
    addSlider(ScrollM, "Fly Speed", 10, 500, Config.Movement.FlySpeed, function(value)
        Config.Movement.FlySpeed = value
    end)
    addKeybind(ScrollM, "Fly Key", Config.Movement.FlyKey, function(key)
        Config.Movement.FlyKey = key
    end)
end)

addToggle(PageM, "Desync (Fake Lag)", false, function(value)
    toggleDesync(value)
end, function()
    PopFL.Visible = true
    resetContainer(ScrollFL)
    
    local modeBtn = Instance.new("TextButton")
    modeBtn.Parent = ScrollFL
    modeBtn.Size = UDim2.new(1, 0, 0, 45)
    modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    modeBtn.Text = "Mode: " .. DesyncModes[CurrentModeIndex]
    modeBtn.TextColor3 = Color3.new(1, 1, 1)
    modeBtn.Font = Enum.Font.GothamSemibold
    modeBtn.TextSize = 14
    Instance.new("UICorner", modeBtn)
    
    modeBtn.MouseButton1Click:Connect(function()
        CurrentModeIndex = CurrentModeIndex + 1
        if CurrentModeIndex > #DesyncModes then CurrentModeIndex = 1 end
        modeBtn.Text = "Mode: " .. DesyncModes[CurrentModeIndex]
    end)
    
    addKeybind(ScrollFL, "Desync Key", Config.Movement.FakeLagKey, function(key)
        Config.Movement.FakeLagKey = key
    end)
end)

addToggle(PageM, "Noclip", false, function(value)
    Config.Movement.Noclip = value
end)

addToggle(PageM, "Z-Teleport", true, function(value)
    Config.Movement.TPOnZ = value
end, function()
    PopM.Visible = true
    resetContainer(ScrollM)
    addSlider(ScrollM, "TP Height", 1, 10, Config.Movement.TPHeight, function(value)
        Config.Movement.TPHeight = value
    end)
    addToggle(ScrollM, "TP To Top Part", false, function(value)
        Config.Movement.TPToTop = value
    end)
end)

addToggle(PageW, "Freeze Custom Time", false, function(value)
    Config.World.TimeEnabled = value
end)

addSlider(PageW, "Clock Time", 0, 24, 12, function(value)
    Config.World.Time = value
end)

local FOVCircle
if DrawingLib and DrawingLib.new then
    FOVCircle = DrawingLib.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Visible = false
end

local function getTarget()
    local closestPart
    local closestDistance = Config.Combat.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Config.Combat.FriendCheck and player:IsFriendsWith(LocalPlayer.UserId) then
                continue
            end

            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Config.Combat.TargetPart)

            if targetHumanoid and targetHumanoid.Health > 0 and targetPart then
                local screenPosition, visible = Camera:WorldToViewportPoint(targetPart.Position)
                if visible then
                    local mousePosition = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude

                    if distance < closestDistance then
                        if Config.Combat.WallCheck then
                            local result = workspace:Raycast(
                                Camera.CFrame.Position,
                                (targetPart.Position - Camera.CFrame.Position).Unit * 1000
                            )

                            if result and result.Instance and result.Instance:IsDescendantOf(player.Character) then
                                closestDistance = distance
                                closestPart = targetPart
                            end
                        else
                            closestDistance = distance
                            closestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestPart
end

addConnection(RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = Config.Combat.Enabled and Config.Combat.ShowFOV
        FOVCircle.Radius = Config.Combat.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Color = Color3.fromRGB(Config.Combat.FOV_R, Config.Combat.FOV_G, Config.Combat.FOV_B)
    end

    if Config.Combat.Enabled and MoveMouseRelative and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        if target then
            local position = Camera:WorldToViewportPoint(target.Position)
            local mousePosition = UserInputService:GetMouseLocation()
            local smoothFactor = Config.Combat.Smoothness / 100
            MoveMouseRelative((position.X - mousePosition.X) * smoothFactor, (position.Y - mousePosition.Y) * smoothFactor)
        end
    end

    for player, drawingInfo in pairs(ESPBoxes) do
        local box = drawingInfo.Box
        if box then
            local targetCharacter = player.Character
            local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
            local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

            if Config.Visuals.Enabled and Config.Visuals.Boxes and targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
                local position, visible = Camera:WorldToViewportPoint(targetRoot.Position)

                if visible and position.Z > 0 then
                    local scale = 1000 / position.Z
                    box.Size = Vector2.new(4 * scale, 6 * scale)
                    box.Position = Vector2.new(position.X - (box.Size.X / 2), position.Y - (box.Size.Y / 2))
                    box.Color = Config.Visuals.Color
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end

    for player, drawingInfo in pairs(ESPBoxes) do
        local look = drawingInfo.LookTracer
        local ptr = drawingInfo.PlayerTracer
        local targetCharacter = player.Character
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter and targetCharacter:FindFirstChild("Head")

        if DrawingLib and DrawingLib.new and targetRoot and Config.Visuals.Enabled then
            local pos, vis = Camera:WorldToViewportPoint(targetRoot.Position)
            if vis and pos.Z > 0 then
                local screenPos = Vector2.new(pos.X, pos.Y)
                local viewportSize = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y)
                local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                local bottom = Vector2.new(center.X, viewportSize.Y)

                if look then
                    look.From = center
                    look.To = screenPos
                    look.Color = Config.Visuals.Color
                    look.Visible = Config.Visuals.LookTracers or false
                end

                if ptr then
                    ptr.From = bottom
                    ptr.To = screenPos
                    ptr.Color = Config.Visuals.Color
                    ptr.Visible = Config.Visuals.PlayerTracers or false
                end
            else
                if look then look.Visible = false end
                if ptr then ptr.Visible = false end
            end
        else
            if look then look.Visible = false end
            if ptr then ptr.Visible = false end
        end
    end

    for player, highlightInfo in pairs(ESPHighlights) do
        local targetCharacter = player.Character
        local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

        if targetHumanoid and targetHumanoid.Health > 0 then
            highlightInfo.Highlight.Enabled = Config.Visuals.Enabled
            highlightInfo.Highlight.FillColor = Config.Visuals.Color
            highlightInfo.Highlight.OutlineColor = Config.Visuals.Color
            highlightInfo.Highlight.OutlineTransparency = Config.Visuals.Outline and 0 or 1
            highlightInfo.Label.Enabled = Config.Visuals.Enabled and Config.Visuals.Names
            highlightInfo.Text.Text = player.Name .. (Config.Visuals.Health and (" [" .. math.floor(targetHumanoid.Health) .. "]") or "")
            highlightInfo.Text.TextColor3 = Config.Visuals.Color
        else
            highlightInfo.Highlight.Enabled = false
            highlightInfo.Label.Enabled = false
        end
    end

    if Config.World.TimeEnabled then
        Lighting.ClockTime = Config.World.Time
    end
end))

addConnection(RunService.Heartbeat:Connect(function()
    if not RootPart or not Humanoid then
        return
    end

    if Config.Movement.SpeedEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if Humanoid.MoveDirection.Magnitude > 0 then
            RootPart.CFrame = RootPart.CFrame + (Humanoid.MoveDirection * (Config.Movement.SpeedMultiplier * 0.15))
        end
    end

    if Config.Movement.FlyEnabled and FlyBodyVelocity and FlyBodyGyro then
        FlyBodyGyro.CFrame = Camera.CFrame

        local moveDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0, 1, 0) end

        FlyBodyVelocity.Velocity = moveDirection.Magnitude > 0 and (moveDirection.Unit * Config.Movement.FlySpeed) or Vector3.zero
    end
end))

-- ==================== ИСПРАВЛЕННЫЙ DESYNC (CFrame теперь работает) ====================
addConnection(RunService.Heartbeat:Connect(function()
    if not DesyncActive or not RootPart then return end
    
    local mode = DesyncModes[CurrentModeIndex]
    local realPos = RootPart.CFrame

    if mode == "Anchor" then
        RootPart.Anchored = true
        RunService.RenderStepped:Wait()
        RootPart.Anchored = false

    elseif mode == "CFrame" then
        RootPart.CFrame = FakeCFrame
        RunService.RenderStepped:Wait()
        RootPart.CFrame = realPos

        FakeCFrame = realPos

        if GhostModel then
            local root = GhostModel:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = FakeCFrame end
        end

    elseif mode == "Velocity" then
        local oldVel = RootPart.Velocity
        RootPart.Velocity = Vector3.new(9e9, 9e9, 9e9)
        RunService.RenderStepped:Wait()
        RootPart.Velocity = oldVel
    end
end))

addConnection(RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and Character then
        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.CanCollide then
                descendant.CanCollide = false
            end
        end
    end
end))

local function createESP(player)
    if player == LocalPlayer then
        return
    end

    local box
    if DrawingLib and DrawingLib.new then
        box = DrawingLib.new("Square")
        box.Thickness = 1.5
        box.Filled = false
        box.Visible = false
    end

    ESPBoxes[player] = { Box = box }

    local lookTracer, playerTracer
    if DrawingLib and DrawingLib.new then
        lookTracer = DrawingLib.new("Line")
        lookTracer.Thickness = 1
        lookTracer.Color = Config.Visuals.Color
        lookTracer.Visible = false

        playerTracer = DrawingLib.new("Line")
        playerTracer.Thickness = 1
        playerTracer.Color = Config.Visuals.Color
        playerTracer.Visible = false
    end

    ESPBoxes[player].LookTracer = lookTracer
    ESPBoxes[player].PlayerTracer = playerTracer

    local function setupHighlight(character)
        if not character then return end

        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.Enabled = false

        local billboard = Instance.new("BillboardGui")
        billboard.Parent = character
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        billboard.Enabled = false

        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.GothamBold
        text.TextSize = 15

        ESPHighlights[player] = {
            Highlight = highlight,
            Label = billboard,
            Text = text,
        }
    end

    addConnection(player.CharacterAdded:Connect(setupHighlight))
    if player.Character then
        setupHighlight(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

addConnection(Players.PlayerAdded:Connect(createESP))

addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        if not Main.Visible then hidePopups() end
    end

    if input.KeyCode == Config.Movement.FlyKey then
        toggleFlyState(not Config.Movement.FlyEnabled)
    end

    if input.KeyCode == Config.Movement.FakeLagKey then
        toggleDesync(not DesyncActive)
    end

    if input.KeyCode == Enum.KeyCode.Z and Config.Movement.TPOnZ and RootPart then
        local ray = Camera:ViewportPointToRay(Mouse.X, Mouse.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 2000)

        if result then
            local position = result.Position
            if Config.Movement.TPToTop and result.Instance and result.Instance:IsA("BasePart") then
                position = Vector3.new(position.X, result.Instance.Position.Y + (result.Instance.Size.Y / 2), position.Z)
            end
            RootPart.CFrame = CFrame.new(position + Vector3.new(0, Config.Movement.TPHeight, 0))
        end
    end
end))

local function unloadHub()
    removeFakeLagMarker()

    for _, connection in ipairs(Connections) do
        if connection then connection:Disconnect() end
    end

    if BindConnection then
        BindConnection:Disconnect()
        BindConnection = nil
    end

    if FOVCircle then FOVCircle:Remove() end

    for _, drawingInfo in pairs(ESPBoxes) do
        if drawingInfo.Box then drawingInfo.Box:Remove() end
    end

    for _, highlightInfo in pairs(ESPHighlights) do
        if highlightInfo.Highlight then highlightInfo.Highlight:Destroy() end
        if highlightInfo.Label then highlightInfo.Label:Destroy() end
    end

    if Humanoid then Humanoid.PlatformStand = false end

    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if GhostModel then GhostModel:Destroy() GhostModel = nil end

    ScreenGui:Destroy()
end

local function addTab(name, page)
    local button = Instance.new("TextButton")
    button.Parent = NavBar
    button.Size = UDim2.new(1, 0, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    Instance.new("UICorner", button)

    button.MouseButton1Click:Connect(function()
        PageV.Visible = false
        PageC.Visible = false
        PageM.Visible = false
        PageW.Visible = false
        page.Visible = true
        hidePopups()
    end)
end

addTab("Visuals", PageV)
addTab("Combat", PageC)
addTab("Movement", PageM)
addTab("World", PageW)
PageV.Visible = true

local UnloadButton = Instance.new("TextButton")
UnloadButton.Parent = NavBar
UnloadButton.Size = UDim2.new(1, 0, 0, 45)
UnloadButton.LayoutOrder = 99
UnloadButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
UnloadButton.Text = "UNLOAD HUB"
UnloadButton.TextColor3 = Color3.new(1, 1, 1)
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 15
Instance.new("UICorner", UnloadButton)

addConnection(UnloadButton.MouseButton1Click:Connect(function()
    unloadHub()
    print("KARA HUB V18 CLEANED + FIXED BUILD UNLOADED")
end))

print("KARA HUB V18 CLEANED + FIXED BUILD LOADED")
print("Keybinds: Y=Desync, F=Fly, Z=TP, RightShift=UI")
