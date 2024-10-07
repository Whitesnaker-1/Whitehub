local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local X = Material.Load({
    Title = "White Hub | by whitesnaker | For War Tycoon",
    Style = 3,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark",
    ColorOverrides = {
        MainFrame = Color3.fromRGB(235, 235, 235)
    }
})

-- Переменные для ESP
local espEnabled = false
local espBoxes = {}

-- Переменные для AIM
local aimEnabled = false
local camera = game:GetService("Workspace").CurrentCamera
local aimConnection -- Переменная для хранения соединения с RenderStepped

-- Флаг для проверки увеличен ли хитбокс
local hitboxIncreased = false

-- Список исключений
local excludedPlayers = {
    ["ghoulsssrrank7"] = true,
    ["mksdns"] = true,
    ["sasiska09876543211"] = true,
    ["adol1grizler12345"] = true,
    ["adol1grizrel12345"] = true, -- Добавлен новый ник
}

-- Увеличение хитбокса HumanoidRootPart у всех игроков
local function increaseHitbox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hrp.Size = Vector3.new(20, 20, 20) -- Увеличиваем хитбокс до 20
        print("Хитбокс HumanoidRootPart увеличен у игрока: " .. player.Name)
        
        -- Обновляем ESP, чтобы отобразить новый хитбокс
        createESP(player)
    end
end

-- Функция для наведения камеры на Head игрока
local function focusCameraOnHead(player)
    local character = player.Character
    if character and character:FindFirstChild("Head") then
        local head = character.Head
        -- Устанавливаем камеру так, чтобы она смотрела на Head игрока
        camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
    end
end

-- Функция для включения/выключения AIM
local function toggleAIM()
    aimEnabled = not aimEnabled
    if aimEnabled then
        print("AIM включен")
        if aimConnection then
            aimConnection:Disconnect()
        end
        aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if aimEnabled then
                local closestPlayer = nil
                local closestDistance = math.huge
                local players = game.Players:GetPlayers()
                
                for _, player in ipairs(players) do
                    if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        if excludedPlayers[player.Name] then
                            print("Игнорируем игрока: " .. player.Name)
                        else
                            local distance = (player.Character.Head.Position - camera.CFrame.Position).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
                
                if closestPlayer then
                    focusCameraOnHead(closestPlayer) -- Наведение на ближайшего игрока
                end
            end
        end)
    else
        print("AIM выключен")
        camera.CameraType = Enum.CameraType.Custom -- Возвращаем камеру к стандартному режиму
        if aimConnection then
            aimConnection:Disconnect() -- Отключаем событие
        end
    end
end

-- Функция для создания ESP
local function createESP(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Adornee = player.Character.HumanoidRootPart
        espBox.Size = Vector3.new(20, 20, 20) -- Размер хитбокса (измененный на 20)
        espBox.Transparency = 0.5 -- Прозрачность
        espBox.Color3 = Color3.fromRGB(128, 0, 128) -- Фиолетовый цвет ESP
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 0
        espBox.Parent = player.Character.HumanoidRootPart
        
        espBoxes[player] = espBox
    end
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

local function updateESP()
    if espEnabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] and not excludedPlayers[player.Name] then
                    createESP(player)
                end
            end
        end

        -- Удаление ESP для игроков, которые уже недоступны
        for player, espBox in pairs(espBoxes) do
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                removeESP(player)
            end
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("ESP включен")
        game:GetService("RunService").RenderStepped:Connect(updateESP)
    else
        print("ESP выключен")
        for player, espBox in pairs(espBoxes) do
            removeESP(player)
        end
    end
end

-- Функция для телепортации
local function teleportToBase(baseName)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local target = workspace.Tycoon.TycoonFloor:FindFirstChild(baseName)

    if target then
        character:SetPrimaryPartCFrame(target.CFrame + Vector3.new(0, 5, 0)) -- Поднимаем на 5 единиц
        print("Телепортировано к базе " .. baseName)
    else
        print("База " .. baseName .. " не найдена!")
    end
end

-- Создаем список кнопок телепортации
local teleportButtons = {
    "Sierra",
    "Echo",
    "Delta",
    "Omega",
    "Foxtrot",
    "Alpha",
    "Bravo",
    "Charlie",
    "Golf",
    "Hotel",
    "Kilo",
    "Lima",
    "Victor",
    "Zulu",
    "Tango",
    "Romeo",
    "Центр"
}

-- Создаем страницу для телепортации
local Page4 = X.New({
    Title = "Teleport to bases"
})

-- Динамически создаем кнопки для каждой базы в списке
for _, baseName in ipairs(teleportButtons) do
    Page4.Button({
        Text = "Teleport to " .. baseName,
        Callback = function(value)
            teleportToBase(baseName)
        end
    })
end

-- Подключаем событие для нажатия кнопок Ctrl (включение AIM), Alt (выключение AIM), и E (ESP)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
        toggleAIM()
    elseif input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed then
        toggleAIM()
    elseif input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        toggleESP()
    end
end)

-- Создаем страницу для AIM
local Page2 = X.New({
    Title = "Aim"
})

-- Создаем кнопку для AIM на второй странице
local MyButton2 = Page2.Button({
    Text = "Toggle AIM",
    Callback = function(value)
        toggleAIM()
    end
})

-- Создаем кнопку для увеличения хитбоксов
local MyButtonIncreaseHitbox = Page2.Button({
    Text = "Toggle Hitboxes",
    Callback = function(value)
        hitboxIncreased = not hitboxIncreased
        if hitboxIncreased then
            for _, player in ipairs(game.Players:GetPlayers()) do
                increaseHitbox(player)
            end
            print("Запущено увеличение хитбоксов")
        else
            print("Увеличение хитбоксов остановлено")
            -- Удаляем хитбоксы и ESP
            for _, player in ipairs(game.Players:GetPlayers()) do
                removeESP(player)
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 2) -- Вернем в исходное состояние
                end
            end
        end
    end
})

-- Завершение работы скрипта
print("Скрипт загружен успешно!")
