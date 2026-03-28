--[[
    XENO FTAP V6.9 - EXTREME (TOKRA INSPIRED)
    - REMOVED: Super Reach, Old Invis
    - ADDED: Ultimate Anti-Grab, Character Desync, Speed/Fly
]]

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    ESP_Enabled = true,
    MainColor = Color3.fromRGB(0, 255, 127),
    AntiGrab = true,
    Invis_Active = false,
    WalkSpeed = 16,
    Fly_Enabled = false
}

local Connections = {}

-- === КОР-ФУНКЦИИ (ГРЯЗНЫЕ ХАКИ) ===

-- Функция десинка (Инвиз из Tokra)
local function ToggleDesync(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        -- Создаем фейковый хитбокс, пока основной улетает в десинк
        local fake = hrp:Clone()
        fake.Parent = char
        fake.Transparency = 0.5
        fake.CanCollide = false
        
        -- Разрываем связь с сервером для координат
        settings().Physics.AllowSleep = false
        RunService.Stepped:Connect(function()
            if Config.Invis_Active then
                hrp.Velocity = Vector3.new(0, 0, 0) -- Замораживаем позицию для сервера
            end
        end)
    end
end

-- Мощный Anti-Grab
local function ApplyAntiGrab()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("Snap") then
            if v.Name ~= "RootJoint" and not v.Parent:IsA("Tool") then
                v:Destroy()
            end
        end
        if v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") then
            v:Destroy()
        end
    end
end

-- === ГЛАВНЫЙ ЦИКЛ ===
RunService.Heartbeat:Connect(function()
    if Config.AntiGrab then ApplyAntiGrab() end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = Config.WalkSpeed
    end
end)

-- === ИНТЕРФЕЙС (УПРОЩЕННЫЙ ПОД НОВЫЕ ЗАДАЧИ) ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 300); Main.Position = UDim2.new(0.5, -100, 0.5, -150); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "XENO EXTREME V6.9"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold

local function CreateToggle(name, y, configKey, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = name; b.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        b.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(30, 30, 35)
        if callback then callback(Config[configKey]) end
    end)
end

CreateToggle("ULTIMATE ANTI-GRAB", 50, "Anti_Grab")
CreateToggle("DESYNC INVIS", 100, "Invis_Active", function(s) ToggleDesync(s) end)

-- Ползунок скорости (Speedhack)
local SpeedBtn = Instance.new("TextButton", Main)
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40); SpeedBtn.Position = UDim2.new(0.05, 0, 0, 150)
SpeedBtn.Text = "SPEED: " .. Config.WalkSpeed; SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); SpeedBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedBtn)
SpeedBtn.MouseButton1Click:Connect(function()
    Config.WalkSpeed = (Config.WalkSpeed >= 100) and 16 or Config.WalkSpeed + 20
    SpeedBtn.Text = "SPEED: " .. Config.WalkSpeed
end)

-- Кнопка закрытия
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0.9, 0, 0, 30); Close.Position = UDim2.new(0.05, 0, 1, -40); Close.Text = "CLOSE MENU"; Close.BackgroundColor3 = Color3.fromRGB(80, 30, 30); Close.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
