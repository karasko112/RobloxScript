-- KARA HUB new gen
local Players, RunService, UserInputService, Lighting, Stats, CoreGui =
    game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"),
    game:GetService("Lighting"), game:GetService("Stats"), game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Character, Humanoid, RootPart
local DrawingLib = rawget(_G, "Drawing") or Drawing
local MoveMouseRelative = rawget(_G, "mousemoverel") or mousemoverel
local Connections = {}
local ESPHighlights = {}
local ESPBoxes = {}
local FlyBodyVelocity, FlyBodyGyro, GhostModel, FakeLagMarker, BindConnection
local originalMaterials = {}
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient
local HealthBars = {}
local DesyncModes = {"Anchor", "CFrame", "Velocity"}
local CurrentModeIndex = 1
local DesyncActive = false
local FakeCFrame = nil

local function addConnection(conn)
    table.insert(Connections, conn)
    return conn
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
        Enabled = false, Boxes = false, Names = true, Health = true, Outline = true,
        Color = Color3.fromRGB(0, 170, 255), R = 0, G = 170, B = 255,
        LookTracers = false, PlayerTracers = false,
    },
    Combat = {
        Enabled = false, FOV = 150, ShowFOV = true, Smoothness = 20,
        TargetPart = "Head", WallCheck = true, FriendCheck = false,
        FOVColor = Color3.fromRGB(255, 255, 255), FOV_R = 255, FOV_G = 255, FOV_B = 255,
    },
    Movement = {
        SpeedEnabled = false, SpeedMultiplier = 4, SpeedKey = Enum.KeyCode.LeftShift,
        FlyEnabled = false, FlySpeed = 120, FlyKey = Enum.KeyCode.F,
        Noclip = false, NoclipKey = Enum.KeyCode.N,
        TPOnZ = true, TeleportKey = Enum.KeyCode.Z,
        FakeLagEnabled = false, FakeLagKey = Enum.KeyCode.Y,
    },
    World = { TimeEnabled = false, Time = 12 },
    Utilities = { NightVisionEnabled = false, FPSBoostEnabled = false, HealthBarsEnabled = false },
}

local function updateColor()
    Config.Visuals.Color = Color3.fromRGB(Config.Visuals.R, Config.Visuals.G, Config.Visuals.B)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaraHub_V18_Final"
ScreenGui.ResetOnSpawn = false
local parentOk = pcall(function() ScreenGui.Parent = CoreGui end)
if not parentOk then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
Title.Text = "KARA HUB V18 | SUBMENUS + KEYS"
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
local PageWM = createPage()
local PageA = createPage()

-- Submenus
local PopV, ScrollV = createSubMenu("ESP Config", 450)
local PopC, ScrollC = createSubMenu("Aim Config", 350)
local PopSpeed, ScrollSpeed = createSubMenu("Speed Config", 200)
local PopFly, ScrollFly = createSubMenu("Fly Config", 250)
local PopFL, ScrollFL = createSubMenu("Fake Lag Config", 150)
local AllPopups = { PopV, PopC, PopSpeed, PopFly, PopFL }

local function hidePopups()
    for _, popup in ipairs(AllPopups) do popup.Visible = false end
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
    local function render() button.Text = text .. ": " .. (state and "ON" or "OFF") end
    render()
    button.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)
    if rightClickCallback then
        button.MouseButton2Click:Connect(function()
            rightClickCallback(button) -- передаём button для контекста (не используется)
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
        if maxValue ~= minValue then alpha = (value - minValue) / (maxValue - minValue) end
        fill.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
    end
    render(currentValue)
    background.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local dragConnection
        dragConnection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                dragConnection:Disconnect()
                return
            end
            local alpha = math.clamp(
                (UserInputService:GetMouseLocation().X - background.AbsolutePosition.X) / background.AbsoluteSize.X,
                0, 1)
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
        if BindConnection then BindConnection:Disconnect() end
        BindConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            currentKey = input.KeyCode
            button.Text = text .. ": " .. currentKey.Name
            callback(currentKey)
            if BindConnection then BindConnection:Disconnect(); BindConnection = nil end
        end)
    end)
end

-- ==================== WEAPON MODIFICATION SYSTEM ====================
local MOD_CONFIG = {
    PerfectAccuracy = { params = {"scatter"}, active_value = 999, default_value = 1, display_name = "Perfect Accuracy" },
    NoRecoil = { params = {"GunRecoilX", "GunRecoil"}, active_value = 0, default_value = 1, display_name = "No Recoil" },
    InsatntEquip = { params = {"EquipSpeed"}, active_value = 0.0000001, default_value = 1, display_name = "Instant Equip" },
    PerfectFirerate = { params = {"waittime"}, active_value = 0.00001, default_value = 1, display_name = "Perfect Firerate" },
    ReloadSpeed = { params = {"ReloadSpeed", "ReloadSpeed2"}, active_value = 0.00001, default_value = 1, display_name = "Reload Speed" },
    NoAimSway = { params = {"AimSway"}, active_value = 0.00001, default_value = 1, display_name = "No Aim Sway" },
    FastAiming = { params = {"AimSpeed"}, active_value = 0.00001, default_value = 1, display_name = "Fast Aiming" },
}

local ModStates = {}
for modName in pairs(MOD_CONFIG) do ModStates[modName] = false end
local OriginalValues = {}
local TrackedTools = {}

local function GetValidPlayerTools()
    local tools = {}
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do
            if item:IsA("Tool") and item:FindFirstChild("AttachmentFolder") then
                table.insert(tools, item)
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("AttachmentFolder") then
                table.insert(tools, item)
            end
        end
    end
    return tools
end

local function SetupToolStructure(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local attachmentFolder = tool:FindFirstChild("AttachmentFolder")
    if not attachmentFolder then return false end
    local innerTool = attachmentFolder:FindFirstChild("Tool") or Instance.new("Tool")
    innerTool.Name = "Tool"
    innerTool.Parent = attachmentFolder
    if not innerTool:FindFirstChild("IsAttachment") then
        local isAttachment = Instance.new("StringValue")
        isAttachment.Name = "IsAttachment"
        isAttachment.Value = "Gripp"
        isAttachment.Parent = innerTool
    end
    if not innerTool:FindFirstChild("Weight") then
        local weight = Instance.new("NumberValue")
        weight.Name = "Weight"
        weight.Value = 0.1
        weight.Parent = innerTool
        local originalWeight = Instance.new("NumberValue")
        originalWeight.Name = "OriginalWeight"
        originalWeight.Value = 0.1
        originalWeight.Parent = weight
    end
    local statsFolder = innerTool:FindFirstChild("Stats") or Instance.new("Folder")
    statsFolder.Name = "Stats"
    statsFolder.Parent = innerTool
    return true
end

local function ProcessWeapon(tool)
    if not SetupToolStructure(tool) then return end
    local innerTool = tool.AttachmentFolder:FindFirstChild("Tool")
    if not innerTool then return end
    local statsFolder = innerTool:FindFirstChild("Stats")
    if not statsFolder then return end
    for modName, config in pairs(MOD_CONFIG) do
        for _, paramName in ipairs(config.params) do
            if not OriginalValues[tool] then OriginalValues[tool] = {} end
            if OriginalValues[tool][paramName] == nil then
                local currentValue = statsFolder:FindFirstChild(paramName)
                OriginalValues[tool][paramName] = currentValue and currentValue.Value or config.default_value
            end
            local valueToSet = ModStates[modName] and config.active_value or OriginalValues[tool][paramName]
            local param = statsFolder:FindFirstChild(paramName) or Instance.new("NumberValue")
            param.Name = paramName
            param.Value = valueToSet
            param.Parent = statsFolder
        end
    end
end

local function ApplyModifications()
    for _, tool in ipairs(GetValidPlayerTools()) do
        ProcessWeapon(tool)
    end
end

-- INSTA HEAL/WRENCH
local healingActive = false
local repairingActive = false
local autoHealCoroutine = nil
local autoRepairCoroutine = nil
local function stopHealing()
    if autoHealCoroutine then coroutine.close(autoHealCoroutine); autoHealCoroutine = nil end
end
local function startHealing()
    stopHealing()
    healingActive = true
    autoHealCoroutine = coroutine.create(function()
        while healingActive do
            while healingActive and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0) do task.wait(0.5) end
            if not healingActive then break end
            while healingActive and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Medkit") do task.wait(0.5) end
            if not healingActive then break end
            while healingActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 and LocalPlayer.Character:FindFirstChild("Medkit") do
                local success, err = pcall(function()
                    local args = {"heal", LocalPlayer.Character}
                    LocalPlayer.Character.Medkit.ActionMain:FireServer(unpack(args))
                end)
                if not success then break end
                task.wait(0.0001)
            end
            task.wait(0.1)
        end
    end)
    coroutine.resume(autoHealCoroutine)
end
local function stopRepairing()
    if autoRepairCoroutine then coroutine.close(autoRepairCoroutine); autoRepairCoroutine = nil end
end
local function startRepairing()
    stopRepairing()
    repairingActive = true
    autoRepairCoroutine = coroutine.create(function()
        while repairingActive do
            while repairingActive and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0) do task.wait(0.5) end
            if not repairingActive then break end
            while repairingActive and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Wrench") do task.wait(0.5) end
            if not repairingActive then break end
            while repairingActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 and LocalPlayer.Character:FindFirstChild("Wrench") do
                local success, err = pcall(function()
                    local args = {"heal", LocalPlayer.Character}
                    LocalPlayer.Character.Wrench.ActionMain:FireServer(unpack(args))
                end)
                if not success then break end
                task.wait(0.0001)
            end
            task.wait(0.1)
        end
    end)
    coroutine.resume(autoRepairCoroutine)
end

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
        if GhostModel then GhostModel:Destroy(); GhostModel = nil end
        if RootPart then RootPart.Anchored = false end
        FakeCFrame = nil
    end
end

local function toggleFlyState(state)
    Config.Movement.FlyEnabled = state
    if not RootPart or not Humanoid then return end
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
    if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
    Humanoid.PlatformStand = false
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- ==================== AURA SYSTEM ====================
local AuraSystem = {
    MedkitAura = { Enabled = false, HealRate = 1, TargetPlayers = {}, Running = false },
    WrenchAura = { Enabled = false, HealRate = 1, TargetPlayers = {}, Running = false },
    PickaxeAura = { Enabled = false, AttackRate = 1, ExcludedPlayers = {}, Running = false },
}

local function StartMedkitAura()
    if AuraSystem.MedkitAura.Running then return end
    AuraSystem.MedkitAura.Running = true
    coroutine.wrap(function()
        while AuraSystem.MedkitAura.Running do
            if AuraSystem.MedkitAura.Enabled then
                for _, targetPlayer in pairs(Players:GetPlayers()) do
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local character = targetPlayer.Character
                        local medkit = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Medkit")
                        if medkit and medkit:FindFirstChild("ActionMain") then
                            medkit.ActionMain:FireServer("heal", character)
                        end
                    end
                end
            end
            local waitTime = AuraSystem.MedkitAura.HealRate == 1 and 0.0001 or AuraSystem.MedkitAura.HealRate / 1000
            task.wait(waitTime)
        end
    end)()
end

local function StopMedkitAura() AuraSystem.MedkitAura.Running = false end
local function StartWrenchAura()
    if AuraSystem.WrenchAura.Running then return end
    AuraSystem.WrenchAura.Running = true
    coroutine.wrap(function()
        while AuraSystem.WrenchAura.Running do
            if AuraSystem.WrenchAura.Enabled then
                for _, targetPlayer in pairs(Players:GetPlayers()) do
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local character = targetPlayer.Character
                        local wrench = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Wrench")
                        if wrench and wrench:FindFirstChild("ActionMain") then
                            wrench.ActionMain:FireServer("heal", character)
                        end
                    end
                end
            end
            local waitTime = AuraSystem.WrenchAura.HealRate == 1 and 0.0001 or AuraSystem.WrenchAura.HealRate / 1000
            task.wait(waitTime)
        end
    end)()
end
local function StopWrenchAura() AuraSystem.WrenchAura.Running = false end
local function StartPickaxeAura()
    if AuraSystem.PickaxeAura.Running then return end
    AuraSystem.PickaxeAura.Running = true
    coroutine.wrap(function()
        while AuraSystem.PickaxeAura.Running do
            if AuraSystem.PickaxeAura.Enabled then
                for _, targetPlayer in pairs(Players:GetPlayers()) do
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local character = targetPlayer.Character
                        local pickaxe = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Pickaxe")
                        if pickaxe and pickaxe:FindFirstChild("ActionMain") then
                            pickaxe.ActionMain:FireServer("attack", 900, 1, 45)
                        end
                    end
                end
            end
            local waitTime = AuraSystem.PickaxeAura.AttackRate == 1 and 0.0001 or AuraSystem.PickaxeAura.AttackRate / 1000
            task.wait(waitTime)
        end
    end)()
end
local function StopPickaxeAura() AuraSystem.PickaxeAura.Running = false end

-- ==================== INFINITE AMMO ====================
local InfiniteAmmoEnabled = false
local infAmmoConnections = {}
local function GetAllPlayerTools()
    local tools = {}
    if LocalPlayer.Backpack then for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    if LocalPlayer.Character then for _, t in ipairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    return tools
end
local function FindWeaponInWorkspace(tool)
    if not tool then return nil end
    local folder = workspace:FindFirstChild(LocalPlayer.Name)
    if not folder then return nil end
    return folder:FindFirstChild(tool.Name, true)
end
local function IsWeaponReady(weapon)
    return weapon and weapon:FindFirstChild("GunScript") and weapon.GunScript:FindFirstChild("ClientAmmo")
end
local function freezeAmmo(weapon)
    local gs = weapon.GunScript
    local ammo = gs.ClientAmmo
    local orig = ammo.Value
    local conn = ammo.Changed:Connect(function() if ammo.Value ~= orig then ammo.Value = orig end end)
    table.insert(infAmmoConnections, conn)
    ammo.Value = orig
end
local function forceReload(character)
    for _, tool in ipairs(character:GetDescendants()) do
        if tool:IsA("Tool") then
            local weapon = FindWeaponInWorkspace(tool)
            if weapon then
                local rev = weapon:FindFirstChild("ReloadEvent")
                if rev then
                    rev:FireServer({[11]="startReload"})
                    rev:FireServer({[14]=0, [11]="magMath"})
                    rev:FireServer({[14]=3, [11]="insertMag"})
                    rev:FireServer({[14]=3, [11]="stopReload"})
                end
            end
        end
    end
end
local function cleanupInfAmmo()
    for _, c in ipairs(infAmmoConnections) do c:Disconnect() end
    infAmmoConnections = {}
end
local function processWeapons(character)
    for _, tool in ipairs(character:GetDescendants()) do
        if tool:IsA("Tool") then
            local weapon = FindWeaponInWorkspace(tool)
            if weapon and IsWeaponReady(weapon) then freezeAmmo(weapon) end
        end
    end
    forceReload(character)
end

-- ==================== UI CONTENT ====================

-- Visuals Page
addToggle(PageV, "ESP Master", false, function(v) Config.Visuals.Enabled = v end, function()
    if PopV.Visible then PopV.Visible = false; return end
    hidePopups()
    PopV.Visible = true
    resetContainer(ScrollV)
    addToggle(ScrollV, "2D Boxes", Config.Visuals.Boxes, function(v2) Config.Visuals.Boxes = v2 end)
    addToggle(ScrollV, "Show Outline", Config.Visuals.Outline, function(v2) Config.Visuals.Outline = v2 end)
    addToggle(ScrollV, "Show Health", Config.Visuals.Health, function(v2) Config.Visuals.Health = v2 end)
    addToggle(ScrollV, "Show Names", Config.Visuals.Names, function(v2) Config.Visuals.Names = v2 end)
    addToggle(ScrollV, "Look Tracers", Config.Visuals.LookTracers, function(v2) Config.Visuals.LookTracers = v2 end)
    addToggle(ScrollV, "Player Tracers", Config.Visuals.PlayerTracers, function(v2) Config.Visuals.PlayerTracers = v2 end)
    addSlider(ScrollV, "Color R", 0, 255, Config.Visuals.R, function(v2) Config.Visuals.R = v2; updateColor() end, Color3.fromRGB(220, 50, 50))
    addSlider(ScrollV, "Color G", 0, 255, Config.Visuals.G, function(v2) Config.Visuals.G = v2; updateColor() end, Color3.fromRGB(50, 220, 50))
    addSlider(ScrollV, "Color B", 0, 255, Config.Visuals.B, function(v2) Config.Visuals.B = v2; updateColor() end, Color3.fromRGB(50, 150, 255))
end)

addToggle(PageV, "Night Vision", false, function(value)
    Config.Utilities.NightVisionEnabled = value
    if value then
        Lighting.Brightness = 5; Lighting.Ambient = Color3.fromRGB(180,255,180); Lighting.OutdoorAmbient = Color3.fromRGB(180,255,180)
    else
        Lighting.Brightness = originalBrightness; Lighting.Ambient = originalAmbient; Lighting.OutdoorAmbient = originalOutdoor
    end
end)
addToggle(PageV, "FPS Boost", false, function(value)
    Config.Utilities.FPSBoostEnabled = value
    if value then
        Lighting.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                originalMaterials[v] = v.Material
                v.Material = Enum.Material.Plastic
            end
        end
    else
        Lighting.GlobalShadows = true
        for part, mat in pairs(originalMaterials) do if part and part.Parent then part.Material = mat end end
        originalMaterials = {}
    end
end)
addToggle(PageV, "Health Bars", false, function(value)
    Config.Utilities.HealthBarsEnabled = value
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if value then createHealthBar(player.Character) else removeHealthBar(player.Character) end
        end
    end
end)

-- Combat Page
addToggle(PageC, "Aimbot (Hold RMB)", false, function(value) Config.Combat.Enabled = value end, function()
    if PopC.Visible then PopC.Visible = false; return end
    hidePopups()
    PopC.Visible = true
    resetContainer(ScrollC)
    addToggle(ScrollC, "Friend Check", Config.Combat.FriendCheck, function(v) Config.Combat.FriendCheck = v end)
    addToggle(ScrollC, "Wall Check", Config.Combat.WallCheck, function(v) Config.Combat.WallCheck = v end)
    addToggle(ScrollC, "Show FOV Circle", Config.Combat.ShowFOV, function(v) Config.Combat.ShowFOV = v end)
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
        local idx = table.find(TargetParts, Config.Combat.TargetPart) or 1
        idx = idx + 1
        if idx > #TargetParts then idx = 1 end
        Config.Combat.TargetPart = TargetParts[idx]
        partBtn.Text = "Target: " .. Config.Combat.TargetPart
    end)
    addSlider(ScrollC, "Aimbot FOV", 10, 800, Config.Combat.FOV, function(v) Config.Combat.FOV = v end)
    addSlider(ScrollC, "Smoothness", 1, 100, Config.Combat.Smoothness, function(v) Config.Combat.Smoothness = v end)
    addSlider(ScrollC, "FOV Color R", 0, 255, Config.Combat.FOV_R, function(v) Config.Combat.FOV_R = v end, Color3.fromRGB(220, 50, 50))
    addSlider(ScrollC, "FOV Color G", 0, 255, Config.Combat.FOV_G, function(v) Config.Combat.FOV_G = v end, Color3.fromRGB(50, 220, 50))
    addSlider(ScrollC, "FOV Color B", 0, 255, Config.Combat.FOV_B, function(v) Config.Combat.FOV_B = v end, Color3.fromRGB(50, 150, 255))
end)

-- Insta Heal / Wrench (оставляем в Combat)
local InstaSection = Instance.new("Frame")
InstaSection.Parent = PageC
InstaSection.Size = UDim2.new(1, 0, 0, 100)
InstaSection.BackgroundTransparency = 1
local InstaLabel = Instance.new("TextLabel")
InstaLabel.Parent = InstaSection
InstaLabel.Size = UDim2.new(1, 0, 0, 30)
InstaLabel.BackgroundTransparency = 1
InstaLabel.Text = "Insta Heal / Wrench"
InstaLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
InstaLabel.Font = Enum.Font.GothamBold
InstaLabel.TextSize = 18
local HealBtn = Instance.new("TextButton")
HealBtn.Parent = InstaSection
HealBtn.Size = UDim2.new(0.48, 0, 0, 40)
HealBtn.Position = UDim2.new(0, 0, 0, 35)
HealBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 45)
HealBtn.Text = "Insta Heal"
HealBtn.TextColor3 = Color3.new(1, 1, 1)
HealBtn.Font = Enum.Font.GothamBold
HealBtn.TextSize = 16
Instance.new("UICorner", HealBtn)
HealBtn.MouseButton1Click:Connect(function()
    if not healingActive then startHealing(); HealBtn.Text = "Stop Heal"
    else healingActive = false; stopHealing(); HealBtn.Text = "Insta Heal" end
end)
local WrenchBtn = Instance.new("TextButton")
WrenchBtn.Parent = InstaSection
WrenchBtn.Size = UDim2.new(0.48, 0, 0, 40)
WrenchBtn.Position = UDim2.new(0.52, 0, 0, 35)
WrenchBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 45)
WrenchBtn.Text = "Insta Wrench"
WrenchBtn.TextColor3 = Color3.new(1, 1, 1)
WrenchBtn.Font = Enum.Font.GothamBold
WrenchBtn.TextSize = 16
Instance.new("UICorner", WrenchBtn)
WrenchBtn.MouseButton1Click:Connect(function()
    if not repairingActive then startRepairing(); WrenchBtn.Text = "Stop Wrench"
    else repairingActive = false; stopRepairing(); WrenchBtn.Text = "Insta Wrench" end
end)

-- Movement Page
addToggle(PageM, "Speed Boost", false, function(value) Config.Movement.SpeedEnabled = value end, function()
    if PopSpeed.Visible then PopSpeed.Visible = false; return end
    hidePopups()
    PopSpeed.Visible = true
    resetContainer(ScrollSpeed)
    addSlider(ScrollSpeed, "Speed Mult", 1, 15, Config.Movement.SpeedMultiplier, function(v) Config.Movement.SpeedMultiplier = v end)
    addKeybind(ScrollSpeed, "Speed Key", Config.Movement.SpeedKey, function(key) Config.Movement.SpeedKey = key end)
end)

addToggle(PageM, "Fly Mode", false, toggleFlyState, function()
    if PopFly.Visible then PopFly.Visible = false; return end
    hidePopups()
    PopFly.Visible = true
    resetContainer(ScrollFly)
    addSlider(ScrollFly, "Fly Speed", 10, 500, Config.Movement.FlySpeed, function(v) Config.Movement.FlySpeed = v end)
    addKeybind(ScrollFly, "Fly Key", Config.Movement.FlyKey, function(key) Config.Movement.FlyKey = key end)
end)

addToggle(PageM, "Desync (Fake Lag)", false, toggleDesync, function()
    if PopFL.Visible then PopFL.Visible = false; return end
    hidePopups()
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
    addKeybind(ScrollFL, "Desync Key", Config.Movement.FakeLagKey, function(key) Config.Movement.FakeLagKey = key end)
end)

addToggle(PageM, "Noclip", false, function(v) Config.Movement.Noclip = v end)
addKeybind(PageM, "Noclip Key", Config.Movement.NoclipKey, function(key) Config.Movement.NoclipKey = key end)

addToggle(PageM, "Z-Teleport", true, function(v) Config.Movement.TPOnZ = v end)
addKeybind(PageM, "Teleport Key", Config.Movement.TeleportKey, function(key) Config.Movement.TeleportKey = key end)

-- World Page
addToggle(PageW, "Freeze Custom Time", false, function(v) Config.World.TimeEnabled = v end)
addSlider(PageW, "Clock Time", 0, 24, 12, function(v) Config.World.Time = v end)

-- Weapon Mods Page
for modName, config in pairs(MOD_CONFIG) do
    addToggle(PageWM, config.display_name, false, function(state)
        ModStates[modName] = state
        ApplyModifications() -- всегда применяем сразу
    end)
end
addToggle(PageWM, "Infinite Ammo", false, function(state)
    InfiniteAmmoEnabled = state
    if state then
        cleanupInfAmmo()
        if LocalPlayer.Character then forceReload(LocalPlayer.Character) end
        coroutine.wrap(function()
            while InfiniteAmmoEnabled do
                processWeapons(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
                task.wait(0.1)
            end
        end)()
    else
        cleanupInfAmmo()
    end
end)

-- Auras Page
addToggle(PageA, "Medkit Aura", false, function(state)
    AuraSystem.MedkitAura.Enabled = state
    if state then StartMedkitAura() else StopMedkitAura() end
end)
addSlider(PageA, "Medkit Rate (ms)", 1, 9000, 1, function(v) AuraSystem.MedkitAura.HealRate = v end, Color3.fromRGB(0, 255, 0))
addToggle(PageA, "Wrench Aura", false, function(state)
    AuraSystem.WrenchAura.Enabled = state
    if state then StartWrenchAura() else StopWrenchAura() end
end)
addSlider(PageA, "Wrench Rate (ms)", 1, 9000, 1, function(v) AuraSystem.WrenchAura.HealRate = v end, Color3.fromRGB(0, 255, 255))
addToggle(PageA, "Pickaxe Aura", false, function(state)
    AuraSystem.PickaxeAura.Enabled = state
    if state then StartPickaxeAura() else StopPickaxeAura() end
end)
addSlider(PageA, "Pickaxe Rate (ms)", 1, 9000, 1, function(v) AuraSystem.PickaxeAura.AttackRate = v end, Color3.fromRGB(255, 0, 0))

-- Tabs
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
        PageWM.Visible = false
        PageA.Visible = false
        page.Visible = true
        hidePopups()
    end)
end

addTab("Visuals", PageV)
addTab("Combat", PageC)
addTab("Movement", PageM)
addTab("World", PageW)
addTab("Weapon Mods", PageWM)
addTab("Auras", PageA)
PageV.Visible = true

-- Health bar functions
local function createHealthBar(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return end
    if head:FindFirstChild("HealthBar") then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "HealthBar"
    gui.Size = UDim2.new(4,0,1,0)
    gui.StudsOffset = Vector3.new(0,3,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 10000
    gui.Parent = head
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,0.4,0)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bg.BorderSizePixel = 0
    bg.Parent = gui
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,1,0)
    bar.BorderSizePixel = 0
    bar.Parent = bg
    local function updateHealth()
        local hp = humanoid.Health / humanoid.MaxHealth
        bar.Size = UDim2.new(hp,0,1,0)
        if hp > 0.6 then bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        elseif hp > 0.3 then bar.BackgroundColor3 = Color3.fromRGB(255,200,0)
        else bar.BackgroundColor3 = Color3.fromRGB(255,0,0) end
    end
    updateHealth()
    humanoid.HealthChanged:Connect(updateHealth)
    HealthBars[character] = gui
end

local function removeHealthBar(character)
    local head = character:FindFirstChild("Head")
    if head then local hb = head:FindFirstChild("HealthBar") if hb then hb:Destroy() end end
    HealthBars[character] = nil
end

local function setupHealthBars(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        if Config.Utilities.HealthBarsEnabled then task.wait(0.5); createHealthBar(char) end
    end)
end
for _, player in ipairs(Players:GetPlayers()) do setupHealthBars(player) end
Players.PlayerAdded:Connect(setupHealthBars)

-- FPS/Ping
local fpsCounter = 0
local lastFpsTime = tick()
local fpsLabel = Instance.new("TextLabel", ScreenGui)
fpsLabel.Size = UDim2.new(0,150,0,25); fpsLabel.Position = UDim2.new(0,10,0,10)
fpsLabel.BackgroundColor3 = Color3.fromRGB(18,18,18); fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextSize = 16; fpsLabel.BorderSizePixel = 0
Instance.new("UICorner", fpsLabel)

local pingLabel = Instance.new("TextLabel", ScreenGui)
pingLabel.Size = UDim2.new(0,150,0,25); pingLabel.Position = UDim2.new(0,10,0,40)
pingLabel.BackgroundColor3 = Color3.fromRGB(18,18,18); pingLabel.TextColor3 = Color3.new(1,1,1)
pingLabel.Font = Enum.Font.GothamBold; pingLabel.TextSize = 16; pingLabel.BorderSizePixel = 0
Instance.new("UICorner", pingLabel)

addConnection(RunService.RenderStepped:Connect(function()
    fpsCounter += 1
    if tick() - lastFpsTime >= 1 then
        fpsLabel.Text = "FPS: " .. fpsCounter; fpsCounter = 0; lastFpsTime = tick()
    end
end))
addConnection(RunService.Heartbeat:Connect(function()
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    pingLabel.Text = "Ping: " .. math.floor(ping) .. " ms"
end))

-- Aimbot rendering
local FOVCircle
if DrawingLib and DrawingLib.new then
    FOVCircle = DrawingLib.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Visible = false
end

local function getTarget()
    local closestPart, closestDistance = nil, Config.Combat.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Config.Combat.FriendCheck and player:IsFriendsWith(LocalPlayer.UserId) then continue end
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Config.Combat.TargetPart)
            if targetHumanoid and targetHumanoid.Health > 0 and targetPart then
                local screenPosition, visible = Camera:WorldToViewportPoint(targetPart.Position)
                if visible then
                    local mousePosition = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                    if distance < closestDistance then
                        if Config.Combat.WallCheck then
                            local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                            if result and result.Instance and result.Instance:IsDescendantOf(player.Character) then
                                closestDistance = distance; closestPart = targetPart
                            end
                        else
                            closestDistance = distance; closestPart = targetPart
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
                    box.Color = Config.Visuals.Color; box.Visible = true
                else box.Visible = false end
            else box.Visible = false end
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
                if look then look.From = center; look.To = screenPos; look.Color = Config.Visuals.Color; look.Visible = Config.Visuals.LookTracers or false end
                if ptr then ptr.From = bottom; ptr.To = screenPos; ptr.Color = Config.Visuals.Color; ptr.Visible = Config.Visuals.PlayerTracers or false end
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
            highlightInfo.Highlight.Enabled = false; highlightInfo.Label.Enabled = false
        end
    end
    if Config.World.TimeEnabled then Lighting.ClockTime = Config.World.Time end
end))

addConnection(RunService.Heartbeat:Connect(function()
    if not RootPart or not Humanoid then return end
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

addConnection(RunService.Heartbeat:Connect(function()
    if not DesyncActive or not RootPart then return end
    local mode = DesyncModes[CurrentModeIndex]
    local realPos = RootPart.CFrame
    if mode == "Anchor" then
        RootPart.Anchored = true; RunService.RenderStepped:Wait(); RootPart.Anchored = false
    elseif mode == "CFrame" then
        RootPart.CFrame = FakeCFrame; RunService.RenderStepped:Wait(); RootPart.CFrame = realPos
        FakeCFrame = realPos
        if GhostModel then local root = GhostModel:FindFirstChild("HumanoidRootPart") if root then root.CFrame = FakeCFrame end end
    elseif mode == "Velocity" then
        local oldVel = RootPart.Velocity
        RootPart.Velocity = Vector3.new(9e9, 9e9, 9e9); RunService.RenderStepped:Wait(); RootPart.Velocity = oldVel
    end
end))

addConnection(RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and Character then
        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.CanCollide then descendant.CanCollide = false end
        end
    end
end))

local function createESP(player)
    if player == LocalPlayer then return end
    local box
    if DrawingLib and DrawingLib.new then
        box = DrawingLib.new("Square"); box.Thickness = 1.5; box.Filled = false; box.Visible = false
    end
    ESPBoxes[player] = { Box = box }
    local lookTracer, playerTracer
    if DrawingLib and DrawingLib.new then
        lookTracer = DrawingLib.new("Line"); lookTracer.Thickness = 1; lookTracer.Color = Config.Visuals.Color; lookTracer.Visible = false
        playerTracer = DrawingLib.new("Line"); playerTracer.Thickness = 1; playerTracer.Color = Config.Visuals.Color; playerTracer.Visible = false
    end
    ESPBoxes[player].LookTracer = lookTracer
    ESPBoxes[player].PlayerTracer = playerTracer
    local function setupHighlight(character)
        if not character then return end
        local highlight = Instance.new("Highlight"); highlight.Parent = character; highlight.Enabled = false
        local billboard = Instance.new("BillboardGui"); billboard.Parent = character; billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 150, 0, 40); billboard.ExtentsOffset = Vector3.new(0, 3, 0); billboard.Enabled = false
        local text = Instance.new("TextLabel"); text.Parent = billboard; text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1; text.Font = Enum.Font.GothamBold; text.TextSize = 15
        ESPHighlights[player] = { Highlight = highlight, Label = billboard, Text = text }
    end
    addConnection(player.CharacterAdded:Connect(setupHighlight))
    if player.Character then setupHighlight(player.Character) end
end

for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
addConnection(Players.PlayerAdded:Connect(createESP))

-- Keybinds processing
addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        if not Main.Visible then hidePopups() end
    end
    if input.KeyCode == Config.Movement.SpeedKey then
        Config.Movement.SpeedEnabled = not Config.Movement.SpeedEnabled
    end
    if input.KeyCode == Config.Movement.FlyKey then
        toggleFlyState(not Config.Movement.FlyEnabled)
    end
    if input.KeyCode == Config.Movement.NoclipKey then
        Config.Movement.Noclip = not Config.Movement.Noclip
    end
    if input.KeyCode == Config.Movement.TeleportKey and Config.Movement.TPOnZ and RootPart then
        local ray = Camera:ViewportPointToRay(Mouse.X, Mouse.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 2000)
        if result then
            RootPart.CFrame = CFrame.new(result.Position)
        end
    end
    if input.KeyCode == Config.Movement.FakeLagKey then
        toggleDesync(not DesyncActive)
    end
end))

local function unloadHub()
    removeFakeLagMarker()
    for _, connection in ipairs(Connections) do if connection then connection:Disconnect() end end
    if BindConnection then BindConnection:Disconnect(); BindConnection = nil end
    if FOVCircle then FOVCircle:Remove() end
    for _, drawingInfo in pairs(ESPBoxes) do
        if drawingInfo.Box then drawingInfo.Box:Remove() end
    end
    for _, highlightInfo in pairs(ESPHighlights) do
        if highlightInfo.Highlight then highlightInfo.Highlight:Destroy() end
        if highlightInfo.Label then highlightInfo.Label:Destroy() end
    end
    if Humanoid then Humanoid.PlatformStand = false end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
    if GhostModel then GhostModel:Destroy(); GhostModel = nil end
    ScreenGui:Destroy()
end

local ResetButton = Instance.new("TextButton")
ResetButton.Parent = NavBar
ResetButton.Size = UDim2.new(1, 0, 0, 45)
ResetButton.LayoutOrder = 98
ResetButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
ResetButton.Text = "RESET CHAR"
ResetButton.TextColor3 = Color3.new(1, 1, 1)
ResetButton.Font = Enum.Font.GothamBold
ResetButton.TextSize = 15
Instance.new("UICorner", ResetButton)
ResetButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

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
addConnection(UnloadButton.MouseButton1Click:Connect(unloadHub))

-- Init
for _, tool in ipairs(GetValidPlayerTools()) do SetupToolStructure(tool) end

print("KARA HUB Loadded")
