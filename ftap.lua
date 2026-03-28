--[[
    XENO FTAP V6.8 - FULL SETTINGS & TOKRA DESYNC
    - Вернул настройки модулей (Alpha, Origin, Size)
    - Инвиз: Tokra Method (через Bloodman/Seat)
    - Anti-Grab: Режим Bloodman (авто-десинк при захвате)
    - Управление: Z - ТП, ЛКМ - Reach, RightShift - Меню
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ScriptActive = true
local Connections = {} 
local Tracers = {}
local NameTags = {}
local Highlights = {}

local Config = {
    ESP_Enabled = true,
    ESP_Transparency = 0.5,
    Tracers = false,
    Tracer_Origin = "Bottom",
    Names = false,
    Name_Size = 14,
    Teleport = false, 
    TP_Mode = "Cursor", -- "Cursor", "Distance", "MousePos"
    Stretch = false,
    Stretch_FOV = 90,
    MainColor = Color3.fromRGB(0, 255, 127),
    AntiGrab = false,
    AntiGrab_Mode = "Standard", -- "Standard", "Bloodman"
    Invis_Enabled = false,
    Invis_Mode = "Seat",
    Reach_Enabled = false,
    Max_World_Distance = 1500
}

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

local function GetClosestPlayerToCursor()
    local closest = nil
    local shortestMouseDist = math.huge
    local mousePos = UIS:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local lpHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if lpHrp then
                local worldDist = (hrp.Position - lpHrp.Position).Magnitude
                if worldDist <= Config.Max_World_Distance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if mouseDist < shortestMouseDist then
                            shortestMouseDist = mouseDist
                            closest = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerToChar()
    local closest = nil
    local shortestDist = math.huge
    local lpHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lpHrp then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - lpHrp.Position).Magnitude
            if dist < shortestDist and dist <= Config.Max_World_Distance then
                shortestDist = dist
                closest = hrp
            end
        end
    end
    return closest
end

local function TriggerBloodmanDesync()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local joint = char:FindFirstChild("RootJoint", true) or hrp:FindFirstChild("RootWeld")
        if joint then joint:Destroy() end
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
    end
end

-- МЕТОД TOKRA: Инвиз через Bloodman
local function TriggerTokraInvis()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    local targetSeat = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            if obj.Name:lower():find("blood") or (obj.Parent and obj.Parent.Name:lower():find("blood")) then
                if (obj.Position - hrp.Position).Magnitude < 30 then
                    targetSeat = obj
                    break
                end
            end
        end
    end

    if targetSeat then
        targetSeat:Sit(hum)
        local connection
        connection = targetSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
            if targetSeat.Occupant == hum then
                task.wait(0.15) 
                local weld = char:FindFirstChild("SeatWeld", true) or targetSeat:FindFirstChild("SeatWeld")
                if weld then weld:Destroy() end
                print("XENO: Tokra-Invis Activated!")
                connection:Disconnect()
            end
        end)
        task.delay(2, function() if connection then connection:Disconnect() end end)
    else
        warn("XENO: Bloodman не найден рядом!")
    end
end

-- === ESP СИСТЕМА ===
local function RemoveESP(player)
    if Tracers[player] then pcall(function() Tracers[player]:Remove() end); Tracers[player] = nil end
    if NameTags[player] then pcall(function() NameTags[player].Gui:Destroy() end); NameTags[player] = nil end
    if Highlights[player] then pcall(function() Highlights[player]:Destroy() end); Highlights[player] = nil end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local function Apply(char)
        RemoveESP(player)
        task.wait(0.5)
        local hl = Instance.new("Highlight", CoreGui)
        hl.Name = "Xeno_" .. player.Name; hl.Adornee = char; Highlights[player] = hl
        local head = char:WaitForChild("Head", 10)
        if head then
            local bg = Instance.new("BillboardGui", head)
            bg.Name = "XenoName"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 20); bg.ExtentsOffset = Vector3.new(0, 3, 0)
            local lbl = Instance.new("TextLabel", bg)
            lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, 0, 1, 0); lbl.TextColor3 = Config.MainColor; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = Config.Name_Size; lbl.Text = player.Name
            NameTags[player] = {Gui = bg, Label = lbl}
        end
        if pcall(function() return Drawing.new("Line") end) then
            local line = Drawing.new("Line"); line.Thickness = 1; line.Transparency = 1; Tracers[player] = line
        end
    end
    if player.Character then Apply(player.Character) end
    player.CharacterAdded:Connect(Apply)
end

-- === ГЛАВНЫЙ ЦИКЛ ===
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptActive then return end
    Camera.FieldOfView = Camera.FieldOfView + ((Config.Stretch and Config.Stretch_FOV or 70) - Camera.FieldOfView) * 0.2
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- Логика Anti-Grab
    if char and Config.AntiGrab and hrp then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("Weld") and obj.Name ~= "RootJoint" and obj.Name ~= "RightGrip" and obj.Name ~= "SeatWeld" then
                if Config.AntiGrab_Mode == "Bloodman" then
                    TriggerBloodmanDesync()
                else
                    obj:Destroy()
                end
            end
        end
    end

    -- Обновление ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Highlights[player] then
            Highlights[player].Enabled = Config.ESP_Enabled; Highlights[player].FillColor = Config.MainColor; Highlights[player].FillTransparency = Config.ESP_Transparency
        end
        if NameTags[player] then
            NameTags[player].Gui.Enabled = Config.Names; NameTags[player].Label.TextColor3 = Config.MainColor; NameTags[player].Label.TextSize = Config.Name_Size
        end
        if Tracers[player] and Config.Tracers and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                Tracers[player].Visible = true; Tracers[player].Color = Config.MainColor
                Tracers[player].From = (Config.Tracer_Origin == "Bottom") and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                Tracers[player].To = Vector2.new(pos.X, pos.Y)
            else Tracers[player].Visible = false end
        elseif Tracers[player] then Tracers[player].Visible = false end
    end
end))

-- === ИНТЕРФЕЙС ===
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Xeno_V6.8"; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.Position = UDim2.new(0.5, -110, 0.5, -270); MainFrame.Size = UDim2.new(0, 220, 0, 540); MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30); TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "XENO FTAP V6.8"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold

local SettingsFrame = Instance.new("Frame", MainFrame)
SettingsFrame.Size = UDim2.new(0, 180, 0, 280); SettingsFrame.Position = UDim2.new(1, 10, 0, 0); SettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); SettingsFrame.Visible = false; SettingsFrame.BorderSizePixel = 0
Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 10)
local SetTitle = Instance.new("TextLabel", SettingsFrame)
SetTitle.Size = UDim2.new(1, 0, 0, 30); SetTitle.Text = "SETTINGS"; SetTitle.TextColor3 = Color3.new(1,1,1); SetTitle.BackgroundTransparency = 1; SetTitle.Font = Enum.Font.GothamBold

local function CreateSlider(parent, name, y, color, default, callback)
    local sFrame = Instance.new("Frame", parent); sFrame.Size = UDim2.new(0.9, 0, 0, 30); sFrame.Position = UDim2.new(0.05, 0, 0, y); sFrame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", sFrame); label.Size = UDim2.new(0.2, 0, 1, 0); label.Text = name; label.TextColor3 = color; label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.TextSize = 10
    local bg = Instance.new("Frame", sFrame); bg.Size = UDim2.new(0.7, 0, 0, 4); bg.Position = UDim2.new(0.25, 0, 0.5, -2); bg.BackgroundColor3 = Color3.fromRGB(40,40,45); bg.BorderSizePixel = 0
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new(default, 0, 1, 0); fill.BackgroundColor3 = color; fill.BorderSizePixel = 0
    local knob = Instance.new("Frame", fill); knob.Size = UDim2.new(0, 8, 0, 8); knob.Position = UDim2.new(1, -4, 0.5, -4); knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local move = false
    local function Update()
        local percent = math.clamp((UIS:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0); callback(percent)
    end
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = true; Update() end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = false end end)
    UIS.InputChanged:Connect(function(i) if move and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
end

local function DrawSettings(moduleName, specificSettingsCallback)
    for _, child in pairs(SettingsFrame:GetChildren()) do if not child:IsA("UICorner") and child ~= SetTitle then child:Destroy() end end
    SetTitle.Text = moduleName:upper() .. " SETTINGS"
    
    -- Вызов специфичных настроек (кнопок)
    if specificSettingsCallback then specificSettingsCallback() end
    
    -- Глобальные ползунки цвета (всегда внизу)
    CreateSlider(SettingsFrame, "R", 130, Color3.new(1,0.4,0.4), Config.MainColor.R, function(p) Config.MainColor = Color3.new(p, Config.MainColor.G, Config.MainColor.B) end)
    CreateSlider(SettingsFrame, "G", 160, Color3.new(0.4,1,0.4), Config.MainColor.G, function(p) Config.MainColor = Color3.new(Config.MainColor.R, p, Config.MainColor.B) end)
    CreateSlider(SettingsFrame, "B", 190, Color3.new(0.4,0.4,1), Config.MainColor.B, function(p) Config.MainColor = Color3.new(Config.MainColor.R, Config.MainColor.G, p) end)
end

local function AddModule(name, y, configKey, settingsCB)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 65, 45) or Color3.fromRGB(35, 35, 40)
    b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.BorderSizePixel = 0; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        b.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 65, 45) or Color3.fromRGB(35, 35, 40)
    end)
    b.MouseButton2Click:Connect(function() DrawSettings(name, settingsCB); SettingsFrame.Visible = true end)
end

-- РЕГИСТРАЦИЯ МОДУЛЕЙ (С НАСТРОЙКАМИ!)
AddModule("ESP Master", 45, "ESP_Enabled", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "Alpha: " .. Config.ESP_Transparency; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Config.ESP_Transparency = (Config.ESP_Transparency >= 0.9) and 0 or Config.ESP_Transparency + 0.1; btn.Text = "Alpha: " .. string.format("%.1f", Config.ESP_Transparency) end)
end)

AddModule("Tracers", 85, "Tracers", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "Origin: " .. Config.Tracer_Origin; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Config.Tracer_Origin = (Config.Tracer_Origin == "Bottom") and "Center" or "Bottom"; btn.Text = "Origin: " .. Config.Tracer_Origin end)
end)

AddModule("Names", 125, "Names", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "Size: " .. Config.Name_Size; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Config.Name_Size = (Config.Name_Size >= 22) and 10 or Config.Name_Size + 2; btn.Text = "Size: " .. Config.Name_Size end)
end)

AddModule("Teleport (Z)", 165, "Teleport", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "Mode: " .. Config.TP_Mode; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if Config.TP_Mode == "Cursor" then Config.TP_Mode = "Distance" elseif Config.TP_Mode == "Distance" then Config.TP_Mode = "MousePos" else Config.TP_Mode = "Cursor" end
        btn.Text = "Mode: " .. Config.TP_Mode
    end)
end)

AddModule("Super Reach (LKM)", 205, "Reach_Enabled")

AddModule("Stretch Res", 245, "Stretch", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "FOV: " .. Config.Stretch_FOV; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Config.Stretch_FOV = (Config.Stretch_FOV >= 120) and 70 or Config.Stretch_FOV + 10; btn.Text = "FOV: " .. Config.Stretch_FOV end)
end)

AddModule("Anti-Grab", 285, "AntiGrab", function()
    local btn = Instance.new("TextButton", SettingsFrame); btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, 40); btn.Text = "Mode: " .. Config.AntiGrab_Mode; btn.BackgroundColor3 = Color3.fromRGB(40,40,50); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Config.AntiGrab_Mode = (Config.AntiGrab_Mode == "Standard") and "Bloodman" or "Standard"
        btn.Text = "Mode: " .. Config.AntiGrab_Mode
    end)
end)

AddModule("Invisibility", 325, "Invis_Enabled", function()
    local act = Instance.new("TextButton", SettingsFrame); act.Size = UDim2.new(0.9, 0, 0, 30); act.Position = UDim2.new(0.05, 0, 0, 40); act.Text = "ACTIVATE TOKRA-INVIS"; act.BackgroundColor3 = Color3.fromRGB(70,30,30); act.TextColor3 = Color3.new(1,1,1); act.Font = Enum.Font.GothamBold; Instance.new("UICorner", act)
    act.MouseButton1Click:Connect(function() TriggerTokraInvis() end)
end)

-- === ВВОД ===
table.insert(Connections, UIS.InputBegan:Connect(function(i, gpe)
    if gpe or not ScriptActive then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        local target = (MainFrame.Position.Y.Scale > 0.9) and UDim2.new(0.5, -110, 0.5, -270) or UDim2.new(0.5, -110, 1, 50)
        SettingsFrame.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
    end
    if i.KeyCode == Enum.KeyCode.Z and Config.Teleport then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if Config.TP_Mode == "Cursor" then
                local target = GetClosestPlayerToCursor()
                if target then hrp.CFrame = target.CFrame * CFrame.new(0, 0, 3) end
            elseif Config.TP_Mode == "Distance" then
                local target = GetClosestPlayerToChar()
                if target then hrp.CFrame = target.CFrame * CFrame.new(0, 0, 3) end
            elseif Config.TP_Mode == "MousePos" then
                local targetObj = Mouse.Target
                local topY = targetObj and (targetObj.Position.Y + (targetObj.Size.Y / 2) + 3) or (Mouse.Hit.Y + 3)
                hrp.CFrame = CFrame.new(Mouse.Hit.X, topY, Mouse.Hit.Z)
            end
        end
    end
    if i.UserInputType == Enum.UserInputType.MouseButton1 and Config.Reach_Enabled then
        local target = GetClosestPlayerToCursor()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if target and hrp then
            local old = hrp.CFrame; hrp.CFrame = target.CFrame * CFrame.new(0, 2, 0); task.wait(0.08); hrp.CFrame = old
        end
    end
end))

-- ВЫГРУЗКА
local UnloadBtn = Instance.new("TextButton", MainFrame)
UnloadBtn.Size = UDim2.new(0.9, 0, 0, 30); UnloadBtn.Position = UDim2.new(0.05, 0, 1, -40); UnloadBtn.Text = "UNLOAD"; UnloadBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30); UnloadBtn.TextColor3 = Color3.new(1,1,1); UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.BorderSizePixel = 0; Instance.new("UICorner", UnloadBtn)
UnloadBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    for _, conn in pairs(Connections) do if conn.Connected then conn:Disconnect() end end
    for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
    ScreenGui:Destroy(); Camera.FieldOfView = 70
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
table.insert(Connections, Players.PlayerAdded:Connect(CreateESP))
table.insert(Connections, Players.PlayerRemoving:Connect(RemoveESP))
