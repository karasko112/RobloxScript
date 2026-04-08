--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// STORAGE
local Connections = {}
local ESPCache = {}
local FriendCache = {}

local function AddConnection(c) table.insert(Connections, c) end

--// SETTINGS
local ESP = {
    Enabled = false,
    Color = Color3.fromRGB(0, 170, 255),
    Transparency = 0.5,
    Outline = true,
    ShowInfo = true
}

local AimSettings = {
    Enabled = false,
    Triggerbot = false,
    FOV = 150,
    ShowFOV = true,
    Smoothing = 0.25,
    WallCheck = true,
    TargetPart = "Head"
}

local TimeSettings = { Enabled = false, Time = 12 }

--// FRIEND CHECK
local function IsFriend(player)
    if not player or player == LocalPlayer then return false end
    if FriendCache[player.UserId] ~= nil then return FriendCache[player.UserId] end
    local s, r = pcall(function() return player:IsFriendsWith(LocalPlayer.UserId) end)
    if s then FriendCache[player.UserId] = r return r end
    return false
end

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Thickness = 1; FOVCircle.Transparency = 1; FOVCircle.Visible = false

--// GUI BUILD
local guiParent = pcall(function() return game.CoreGui.Name end) and game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "KaraHub_V13"; ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 420); Main.Position = UDim2.new(0.5, -190, 0.5, -210); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "Kara Hub V13"; Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 24

local VisualFrame = Instance.new("Frame", Main); VisualFrame.Size = UDim2.new(1, -20, 1, -120); VisualFrame.Position = UDim2.new(0, 10, 0, 110); VisualFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", VisualFrame).Padding = UDim.new(0, 10)

local AimFrame = Instance.new("Frame", Main); AimFrame.Size = VisualFrame.Size; AimFrame.Position = VisualFrame.Position; AimFrame.BackgroundTransparency = 1; AimFrame.Visible = false
Instance.new("UIListLayout", AimFrame).Padding = UDim.new(0, 10)

local function CreateSubPanel()
    local p = Instance.new("Frame", ScreenGui); p.Size = UDim2.new(0, 250, 0, 350); p.Position = UDim2.new(0.5, 200, 0.5, -175); p.BackgroundColor3 = Color3.fromRGB(25, 25, 25); p.Visible = false; Instance.new("UICorner", p)
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0, 5); l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return p
end
local ESPPanel = CreateSubPanel(); local AimPanel = CreateSubPanel(); local TimeSubPanel = CreateSubPanel()

-- UI HELPERS
local function Toggle(parent, name, default, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = name .. ": " .. (default and "ON" or "OFF"); b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", b)
    local s = default; b.MouseButton1Click:Connect(function() s = not s; b.Text = name .. ": " .. (s and "ON" or "OFF"); cb(s) end)
    return b
end

local function Slider(parent, name, min, max, def, cb)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95, 0, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = name .. ": " .. math.floor(def); l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1; l.TextSize = 13
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, 0, 0, 8); bar.Position = UDim2.new(0, 0, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
                local pct = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0); local val = min + (max - min) * pct; l.Text = name .. ": " .. math.floor(val); cb(val)
            end)
        end
    end)
    return f
end

--// TABS CONTROLS
local VisualTab = Instance.new("TextButton", Main); VisualTab.Size = UDim2.new(0, 120, 0, 40); VisualTab.Position = UDim2.new(0, 10, 0, 60); VisualTab.Text = "Visual"; VisualTab.TextColor3 = Color3.new(1, 1, 1); VisualTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", VisualTab)
local AimTab = Instance.new("TextButton", Main); AimTab.Size = UDim2.new(0, 120, 0, 40); AimTab.Position = UDim2.new(0, 140, 0, 60); AimTab.Text = "Aim"; AimTab.TextColor3 = Color3.new(1, 1, 1); AimTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", AimTab)

VisualTab.MouseButton1Click:Connect(function() VisualFrame.Visible = true; AimFrame.Visible = false; VisualTab.BackgroundColor3 = Color3.fromRGB(40,40,40); AimTab.BackgroundColor3 = Color3.fromRGB(30,30,30) end)
AimTab.MouseButton1Click:Connect(function() VisualFrame.Visible = false; AimFrame.Visible = true; VisualTab.BackgroundColor3 = Color3.fromRGB(30,30,30); AimTab.BackgroundColor3 = Color3.fromRGB(40,40,40) end)

--// MENU CONTENT
local ESPBtn = Toggle(VisualFrame, "Player ESP", false, function(v) ESP.Enabled = v end)
ESPBtn.MouseButton2Click:Connect(function() ESPPanel.Visible = not ESPPanel.Visible; AimPanel.Visible = false; TimeSubPanel.Visible = false end)

Toggle(VisualFrame, "ESP Outline", true, function(v) ESP.Outline = v end)

local CustomTimeBtn = Toggle(VisualFrame, "Custom Time", false, function(v) TimeSettings.Enabled = v end)
CustomTimeBtn.MouseButton2Click:Connect(function() TimeSubPanel.Visible = not TimeSubPanel.Visible; ESPPanel.Visible = false; AimPanel.Visible = false end)

local AimBtn = Toggle(AimFrame, "Aimbot (RMB)", false, function(v) AimSettings.Enabled = v end)
AimBtn.MouseButton2Click:Connect(function() AimPanel.Visible = not AimPanel.Visible; ESPPanel.Visible = false; TimeSubPanel.Visible = false end)

Toggle(ESPPanel, "Show Info", true, function(v) ESP.ShowInfo = v end)
Slider(ESPPanel, "Red", 0, 255, 0, function(v) ESP.Color = Color3.fromRGB(v, ESP.Color.G * 255, ESP.Color.B * 255) end)
Slider(ESPPanel, "Green", 0, 255, 170, function(v) ESP.Color = Color3.fromRGB(ESP.Color.R * 255, v, ESP.Color.B * 255) end)
Slider(ESPPanel, "Blue", 0, 255, 255, function(v) ESP.Color = Color3.fromRGB(ESP.Color.R * 255, ESP.Color.G * 255, v) end)
Slider(ESPPanel, "Transparency", 0, 100, 50, function(v) ESP.Transparency = v / 100 end)
Slider(TimeSubPanel, "Clock Time", 0, 24, 12, function(v) TimeSettings.Time = v end)

--// ESP ENGINE (FIXED LABEL/RED SPAWN)
local function CreateESP(p)
    if p == LocalPlayer then return end
    local function Apply(char)
        if not char then return end
        local head = char:WaitForChild("Head", 10)
        
        -- Сразу удаляем мусор, если он есть
        for _, obj in pairs(char:GetChildren()) do
            if obj.Name == "KaraHighlight" or obj.Name == "KaraBillboard" then obj:Destroy() end
        end

        -- Создаем объекты ВЫКЛЮЧЕННЫМИ по умолчанию
        local h = Instance.new("Highlight", char)
        h.Name = "KaraHighlight"
        h.Enabled = false 
        h.FillTransparency = 1
        h.OutlineTransparency = 1

        local b = Instance.new("BillboardGui", char)
        b.Name = "KaraBillboard"; b.AlwaysOnTop = true; b.Size = UDim2.new(0, 200, 0, 50); b.Adornee = head
        b.Enabled = false 
        
        local t = Instance.new("TextLabel", b)
        t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1, 1, 1); t.Font = "GothamBold"; t.TextSize = 14
        t.Text = "" -- Пустой текст вместо "Label"

        ESPCache[p] = {H = h, B = b, T = t, Char = char}
    end
    p.CharacterAdded:Connect(Apply); if p.Character then Apply(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

--// MAIN LOOP
AddConnection(RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    FOVCircle.Visible = AimSettings.Enabled and AimSettings.ShowFOV; FOVCircle.Radius = AimSettings.FOV; FOVCircle.Position = mouseLoc

    for p, c in pairs(ESPCache) do
        if c.Char and c.Char.Parent and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local f = IsFriend(p)
            
            -- Логика Highlight (Заливка и Окантовка)
            if ESP.Enabled or ESP.Outline then
                c.H.Enabled = true
                c.H.FillColor = f and Color3.new(0,1,0) or ESP.Color
                c.H.FillTransparency = ESP.Enabled and ESP.Transparency or 1
                c.H.OutlineTransparency = ESP.Outline and 0 or 1
                c.H.OutlineColor = Color3.new(1,1,1)
            else
                c.H.Enabled = false
            end
            
            -- Логика Billboard (Ник + ХП)
            if ESP.Enabled and ESP.ShowInfo then
                c.B.Enabled = true
                c.T.Text = (f and "[FRIEND] " or "") .. p.Name .. "\n" .. math.floor(p.Character.Humanoid.Health) .. " HP"
            else
                c.B.Enabled = false
                c.T.Text = "" -- На всякий случай зачищаем текст
            end
        else
            -- Если игрока нет или он мертв — всё выключаем
            if c.H then c.H.Enabled = false end
            if c.B then c.B.Enabled = false end
        end
    end

    if TimeSettings.Enabled then Lighting.ClockTime = TimeSettings.Time end
end))

--// UNLOAD
local Unload = Instance.new("TextButton", ScreenGui); Unload.Size = UDim2.new(0, 140, 0, 45); Unload.Position = UDim2.new(1, -150, 1, -60); Unload.Text = "Unload"; Unload.TextColor3 = Color3.new(1, 1, 1); Unload.BackgroundColor3 = Color3.fromRGB(70, 20, 20); Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    for _, c in pairs(Connections) do c:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("KaraHighlight")
            local b = p.Character:FindFirstChild("KaraBillboard")
            if h then h:Destroy() end
            if b then b:Destroy() end
        end
    end
    FOVCircle:Remove(); ScreenGui:Destroy()
end)

--// SHOW/HIDE MENU
local Visible = true; local SavedMainPos = Main.Position
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then
        Visible = not Visible; local targetY = Visible and SavedMainPos.Y.Offset or 800
        ESPPanel.Visible = false; AimPanel.Visible = false; TimeSubPanel.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(SavedMainPos.X.Scale, SavedMainPos.X.Offset, SavedMainPos.Y.Scale, targetY)}):Play()
        TweenService:Create(Unload, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -150, 1, targetY == 800 and 1000 or -60)}):Play()
    end
end)
