local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local X = Material.Load({
    Title = "White Hub | by whitesnaker",
    Style = 3,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark",
    ColorOverrides = {
        MainFrame = Color3.fromRGB(235, 235, 235)
    }
})

local aimEnabled = false
local espEnabled = false
local camera = game.Workspace.CurrentCamera
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local espBoxes = {}

-- Имена игроков, которых нужно исключить
local excludedPlayerNames = {
    ["ghoulsssrrank7"] = true,
    ["mksdns"] = true
}

-- Функция для поиска ближайшего игрока
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localChar = localPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end

    local localPos = localChar.HumanoidRootPart.Position

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not excludedPlayerNames[player.Name] then -- Проверка на исключение
                local playerPos = player.Character.HumanoidRootPart.Position
                local distance = (localPos - playerPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Функция для наведения камеры на ближайшего игрока
local function aimAtClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local head = closestPlayer.Character.Head
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
        print("Камера наведена на: " .. closestPlayer.Name)
    else
        print("Игрок не найден или он в списке исключений")
    end
end

-- Функция для переключения AIM
local function toggleAIM()
    aimEnabled = not aimEnabled
    if aimEnabled then
        print("AIM включен")
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if aimEnabled then
                aimAtClosestPlayer()
            else
                connection:Disconnect() -- Отключаем соединение, когда AIM выключен
            end
        end)
    else
        print("AIM выключен")
        camera.CameraType = Enum.CameraType.Custom -- Возвращаем камеру к стандартному режиму
    end
end

-- Функция для создания ESP
local function createESP(player)
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Adornee = player.Character.HumanoidRootPart
    espBox.ZIndex = 0
    espBox.Size = Vector3.new(4, 5, 1) -- Размер коробки ESP
    espBox.Transparency = 0.65
    espBox.Color3 = Color3.fromRGB(255, 48, 48) -- Цвет ESP
    espBox.AlwaysOnTop = true
    espBox.Name = "EspBox"
    espBox.Parent = player.Character.HumanoidRootPart
    espBoxes[player] = espBox
end

-- Функция для обновления ESP
local function updateESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not excludedPlayerNames[player.Name] then -- Проверка на исключение
                if not espBoxes[player] then
                    createESP(player)
                end
            elseif espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
        end
    end
end

-- Функция для переключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("ESP включен")
        game:GetService("RunService").RenderStepped:Connect(function()
            updateESP()
        end)
    else
        print("ESP выключен")
        for _, box in pairs(espBoxes) do
            if box then
                box:Destroy()
            end
        end
        espBoxes = {}
    end
end

-- Страница для AIM
local Page2 = X.New({
    Title = "Aim"
})

-- Кнопка для включения/выключения AIM
local MyButton2 = Page2.Button({
    Text = "Toggle AIM",
    Callback = function()
        toggleAIM()
    end
})

-- Страница для ESP
local Page3 = X.New({
    Title = "ESP"
})

-- Кнопка для включения/выключения ESP
local MyButton3 = Page3.Button({
    Text = "Toggle ESP",
    Callback = function()
        toggleESP()
    end
})

-- Обработка нажатия клавиш
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- Игнорировать, если событие обрабатывается игрой

    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        if aimEnabled then
            toggleAIM() -- Выключаем AIM
            print("AIM выключен с клавиши Alt")
        end
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        if not aimEnabled then
            toggleAIM() -- Включаем AIM
            print("AIM включен с клавиши Ctrl")
        end
    elseif input.KeyCode == Enum.KeyCode.E then
        toggleESP() -- Включаем/выключаем ESP при нажатии на 'E'
    end
end)
