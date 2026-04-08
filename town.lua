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
    FOVThickness = 1,
    Smoothing = 0.25,
    WallCheck = true,
    TargetPart = "Head", -- "Head" или "HumanoidRootPart" (Torso)
    Priority = "Distance" -- "Distance" или "Health"
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
FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Transparency = 1; FOVCircle.Visible = false

--// GUI BUILD
local guiParent = pcall(function() return game.CoreGui.Name end) and game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "KaraHub_V15"; ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 420); Main.Position = UDim2.new(0.5, -190, 0.5, -210); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "Kara Hub V15"; Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 24

local VisualFrame = Instance.new("Frame", Main); VisualFrame.Size = UDim2.new(1, -20, 1, -120); VisualFrame.Position = UDim2.new(0, 10, 0, 110); VisualFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", VisualFrame).Padding = UDim.new(0, 10)

local AimFrame = Instance.new("Frame", Main); AimFrame.Size = VisualFrame.Size; AimFrame.Position = VisualFrame.Position; AimFrame.BackgroundTransparency = 1; AimFrame.Visible = false
Instance.new("UIListLayout", AimFrame).Padding = UDim.new(0, 10)

local function CreateSubPanel()
    local p = Instance.new("Frame", ScreenGui); p.Size = UDim2.new(0, 250, 0, 380); p.Position = UDim2.new(0.5, 200, 0.5, -190); p.BackgroundColor3 = Color3.fromRGB(25, 25, 25); p.Visible = false; Instance.new("UICorner", p)
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0, 6); l.HorizontalAlignment = Enum.HorizontalAlignment.Center
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
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95, 0, 0, 42); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 18); l.Text = name .. ": " .. string.format("%.1f", def); l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1; l.TextSize = 12
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 22); bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn; conn = RunService.RenderStepped:Connect(function()
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
                local pct = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0); local val = min + (max - min) * pct; l.Text = name .. ": " .. string.format("%.1f", val); cb(val)
            end)
        end
    end)
    return f
end

local function Selector(parent, name, options, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
    local i = 1; b.Text = name .. ": " .. options[i]
    b.MouseButton1Click:Connect(function() i = i + 1; if i > #options then i = 1 end; b.Text = name .. ": " .. options[i]; cb(options[i]) end)
    return b
end

--// TABS
local VisualTab = Instance.new("TextButton", Main); VisualTab.Size = UDim2.new(0, 120, 0, 40); VisualTab.Position = UDim2.new(0, 10, 0, 60); VisualTab.Text = "Visual"; VisualTab.TextColor3 = Color3.new(1, 1, 1); VisualTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", VisualTab)
local AimTab = Instance.new("TextButton", Main); AimTab.Size = UDim2.new(0, 120, 0, 40); AimTab.Position = UDim2.new(0, 140, 0, 60); AimTab.Text = "Aim"; AimTab.TextColor3 = Color3.new(1, 1, 1); AimTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", AimTab)

VisualTab.MouseButton1Click:Connect(function() VisualFrame.Visible = true; AimFrame.Visible = false; VisualTab.BackgroundColor3 = Color3.fromRGB(40,40,40); AimTab.BackgroundColor3 = Color3.fromRGB(30,30,30) end)
AimTab.MouseButton1Click:Connect(function() VisualFrame.Visible = false; AimFrame.Visible = true; VisualTab.BackgroundColor3 = Color3.fromRGB(30,30,30); AimTab.BackgroundColor3 = Color3.fromRGB(40,40,40) end)

--// CONTENT
local ESPBtn = Toggle(VisualFrame, "Player ESP", false, function(v) ESP.Enabled = v end)
ESPBtn.MouseButton2Click:Connect(function() ESPPanel.Visible = not ESPPanel.Visible; AimPanel.Visible = false; TimeSubPanel.Visible = false end)
Toggle(VisualFrame, "ESP Outline", true, function(v) ESP.Outline = v end)

local CustomTimeBtn = Toggle(VisualFrame, "Custom Time", false, function(v) TimeSettings.Enabled = v end)
CustomTimeBtn.MouseButton2Click:Connect(function() TimeSubPanel.Visible = not TimeSubPanel.Visible; ESPPanel.Visible = false; AimPanel.Visible = false end)

local AimBtnMain = Toggle(AimFrame, "Aimbot (RMB)", false, function(v) AimSettings.Enabled = v end)
AimBtnMain.MouseButton2Click:Connect(function() AimPanel.Visible = not AimPanel.Visible; ESPPanel.Visible = false; TimeSubPanel.Visible = false end)
Toggle(AimFrame, "Triggerbot", false, function(v) AimSettings.Triggerbot = v end)

--// ESP PANEL
Toggle(ESPPanel, "Show Info", true, function(v) ESP.ShowInfo = v end)
Slider(ESPPanel, "Red", 0, 255, 0, function(v) ESP.Color = Color3.fromRGB(v, ESP.Color.G * 255, ESP.Color.B * 255) end)
Slider(ESPPanel, "Green", 0, 255, 170, function(v) ESP.Color = Color3.fromRGB(ESP.Color.R * 255, v, ESP.Color.B * 255) end)
Slider(ESPPanel, "Blue", 0, 255, 255, function(v) ESP.Color = Color3.fromRGB(ESP.Color.R * 255, ESP.Color.G * 255, v) end)
Slider(ESPPanel, "Transparency", 0, 100, 50, function(v) ESP.Transparency = v / 100 end)

--// AIM PANEL (REBUILT)
Toggle(AimPanel, "Show FOV", true, function(v) AimSettings.ShowFOV = v end)
Toggle(AimPanel, "Wall Check", true, function(v) AimSettings.WallCheck = v end)
Slider(AimPanel, "FOV Size", 10, 800, 150, function(v) AimSettings.FOV = v end)
Slider(AimPanel, "FOV Thickness", 1, 10, 1, function(v) AimSettings.FOVThickness = v end)
Slider(AimPanel, "Smoothing", 0.01, 1, 0.25, function(v) AimSettings.Smoothing = v end)
Selector(AimPanel, "Target Part", {"Head", "Torso"}, function(v) AimSettings.TargetPart = (v == "Torso" and "HumanoidRootPart" or "Head") end)
Selector(AimPanel, "Priority", {"Distance", "Health"}, function(v) AimSettings.Priority = v end)

Slider(TimeSubPanel, "Clock Time", 0, 24, 12, function(v) TimeSettings.Time = v end)

--// AIM ENGINE
local function GetClosestTarget()
    local target, nearest = nil, AimSettings.FOV; local mouseLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and not IsFriend(p) then
            local part = p.Character:FindFirstChild(AimSettings.TargetPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if dist < nearest then
                        if AimSettings.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            if workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character}) then continue end
                        end
                        
                        if AimSettings.Priority == "Distance" then
                            nearest = dist; target = part
                        elseif AimSettings.Priority == "Health" then
                            local hp = p.Character.Humanoid.Health
                            if not target or hp < target.Parent.Humanoid.Health then target = part; nearest = dist end
                        end
                    end
                end
            end
        end
    end
    return target
end

--// ESP CREATION
local function CreateESP(p)
    if p == LocalPlayer then return end
    local function Apply(char)
        if not char then return end
        local head = char:WaitForChild("Head", 10)
        for _, obj in pairs(char:GetChildren()) do if obj.Name == "KaraHighlight" or obj.Name == "KaraBillboard" then obj:Destroy() end end
        local h = Instance.new("Highlight", char); h.Name = "KaraHighlight"; h.Enabled = false
        local b = Instance.new("BillboardGui", char); b.Name = "KaraBillboard"; b.AlwaysOnTop = true; b.Size = UDim2.new(0, 200, 0, 50); b.Adornee = head; b.Enabled = false
        local t = Instance.new("TextLabel", b); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1, 1, 1); t.Font = "GothamBold"; t.TextSize = 14; t.Text = ""
        ESPCache[p] = {H = h, B = b, T = t, Char = char}
    end
    p.CharacterAdded:Connect(Apply); if p.Character then Apply(p.Character) end
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

--// MAIN LOOP
AddConnection(RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    FOVCircle.Visible = AimSettings.Enabled and AimSettings.ShowFOV; FOVCircle.Radius = AimSettings.FOV; FOVCircle.Position = mouseLoc; FOVCircle.Thickness = AimSettings.FOVThickness

    if AimSettings.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosestTarget()
        if t then
            local p = Camera:WorldToViewportPoint(t.Position)
            mousemoverel((p.X - mouseLoc.X) * AimSettings.Smoothing, (p.Y - mouseLoc.Y) * AimSettings.Smoothing)
        end
    end

    for p, c in pairs(ESPCache) do
        if c.Char and c.Char.Parent and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local f = IsFriend(p)
            if ESP.Enabled or ESP.Outline then
                c.H.Enabled = true; c.H.FillColor = f and Color3.new(0,1,0) or ESP.Color
                c.H.FillTransparency = ESP.Enabled and ESP.Transparency or 1
                c.H.OutlineTransparency = ESP.Outline and 0 or 1; c.H.OutlineColor = Color3.new(1,1,1)
            else c.H.Enabled = false end
            if ESP.Enabled and ESP.ShowInfo then
                c.B.Enabled = true; c.T.Text = (f and "[FRIEND] " or "") .. p.Name .. "\n" .. math.floor(p.Character.Humanoid.Health) .. " HP"
            else c.B.Enabled = false end
        else if c.H then c.H.Enabled = false end if c.B then c.B.Enabled = false end end
    end
    if TimeSettings.Enabled then Lighting.ClockTime = TimeSettings.Time end
end))

--// UNLOAD
local Unload = Instance.new("TextButton", ScreenGui); Unload.Size = UDim2.new(0, 140, 0, 45); Unload.Position = UDim2.new(1, -150, 1, -60); Unload.Text = "Unload"; Unload.TextColor3 = Color3.new(1, 1, 1); Unload.BackgroundColor3 = Color3.fromRGB(70, 20, 20); Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    for _, c in pairs(Connections) do c:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("KaraHighlight"); local b = p.Character:FindFirstChild("KaraBillboard")
            if h then h:Destroy() end if b then b:Destroy() end
        end
    end
    FOVCircle:Remove(); ScreenGui:Destroy()
end)

--// SHOW/HIDE
local Visible = true; local SavedMainPos = Main.Position
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then
        Visible = not Visible; local targetY = Visible and SavedMainPos.Y.Offset or 800
        ESPPanel.Visible = false; AimPanel.Visible = false; TimeSubPanel.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(SavedMainPos.X.Scale, SavedMainPos.X.Offset, SavedMainPos.Y.Scale, targetY)}):Play()
        TweenService:Create(Unload, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -150, 1, targetY == 800 and 1000 or -60)}):Play()
    end
end)
