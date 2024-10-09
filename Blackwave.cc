local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local X = Material.Load({
    Title = "BlackWave.cc | by whitesnaker | For War Tycoon",
    Style = 3,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark",
    ColorOverrides = {
        MainFrame = Color3.fromRGB(235, 235, 235)
    }
})


local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();
ESP.Enabled = true
ESP.ShowBox = true
ESP.BoxType = "Corner Box Esp"
ESP.ShowName = true
ESP.ShowHealth = true
ESP.ShowTracer = true
ESP.ShowDistance = true


local aimEnabled = false
local smoothAimEnabled = false
local camera = game:GetService("Workspace").CurrentCamera
local aimConnection 
local textLabel 

-- Список исключений
local exceptions = {
    "ilovewartycoonbyrust",
    "ponosik32121",
    "adol1grizrel12345",  -- Исключенный пользователь
    "giontdk2"             -- Новый исключенный пользователь
}


local function smoothAim(player)
    local character = player.Character
    if character and character:FindFirstChild("Head") then
        local head = character.Head
       
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.new(camera.CFrame.Position, head.Position)
        local lerpSpeed = 0.3 -- 

       
        camera.CFrame = currentCFrame:Lerp(targetCFrame, lerpSpeed)
    end
end


local function quickAim(player)
    local character = player.Character
    if character and character:FindFirstChild("Head") then
        local head = character.Head
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
    end
end


local function toggleSmoothAIM()
    smoothAimEnabled = not smoothAimEnabled
    if smoothAimEnabled then
        print("Плавный AIM включен")
        aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if smoothAimEnabled then
                local closestPlayer = nil
                local closestDistance = math.huge
                local players = game.Players:GetPlayers()

                for _, player in ipairs(players) do
                    if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        if not excludedPlayers[player.Name] then
                            local distance = (player.Character.Head.Position - camera.CFrame.Position).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end

                if closestPlayer then
                    smoothAim(closestPlayer)
                end
            end
        end)
    else
        print("Плавный AIM выключен")
        if aimConnection then
            aimConnection:Disconnect()
        end
    end
end

-- Функция для быстрого AIM
local function toggleQuickAIM()
    aimEnabled = not aimEnabled
    if aimEnabled then
        print("Быстрый AIM включен")
        aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if aimEnabled then
                local closestPlayer = nil
                local closestDistance = math.huge
                local players = game.Players:GetPlayers()

                for _, player in ipairs(players) do
                    if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        if not excludedPlayers[player.Name] then
                            local distance = (player.Character.Head.Position - camera.CFrame.Position).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end

                if closestPlayer then
                    quickAim(closestPlayer)
                end
            end
        end)
    else
        print("Быстрый AIM выключен")
        if aimConnection then
            aimConnection:Disconnect()
        end
    end
end


local function createTextLabel()
    
    if textLabel then
        textLabel:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false -- Сохраняем GUI после возрождения
    textLabel = Instance.new("TextLabel")

    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    textLabel.Parent = screenGui

    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.Size = UDim2.new(0, 300, 0, 200)
    textLabel.TextColor3 = Color3.fromRGB(128, 0, 128) -- Фиолетовый цвет
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 24 -- Увеличиваем размер текста
end

-- Функция для обновления текстовой метки
local function updateFunctionList()
    local enabledFunctions = {}

    if smoothAimEnabled then
        table.insert(enabledFunctions, "Плавный AIM (Alt)")
    end

    if aimEnabled then
        table.insert(enabledFunctions, "Быстрый AIM (Ctrl)")
    end

    if ESP.Enabled then
        table.insert(enabledFunctions, "ESP (E)")
    end

    textLabel.Text = table.concat(enabledFunctions, "\n") 
end


createTextLabel()
updateFunctionList()


local pageAIM = X.New({
    Title = "AIM"
})

local MySmoothAimButton = pageAIM.Button({
    Text = "Toggle Smooth AIM",
    Callback = function(value)
        toggleSmoothAIM()
        updateFunctionList()
    end
})

local MyQuickAimButton = pageAIM.Button({
    Text = "Toggle Quick AIM",
    Callback = function(value)
        toggleQuickAIM()
        updateFunctionList()
    end
})

local pageESP = X.New({
    Title = "ESP"
})

local MyESPButton = pageESP.Button({
    Text = "Toggle ESP",
    Callback = function(value)
        ESP.Enabled = not ESP.Enabled
        updateFunctionList()
    end
})

-- Подключаем событие для нажатия клавиши Alt (включение/выключение плавного AIM) и Ctrl (быстрый AIM)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed then
        toggleSmoothAIM() -- Переключение плавного AIM на Alt
        updateFunctionList()
    elseif input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
        toggleQuickAIM() -- Включение быстрого AIM на Ctrl
        updateFunctionList()
    end
end)


local teleportButtons = {
    "Sierra", "Echo", "Delta", "Omega", "Foxtrot",
    "Alpha", "Bravo", "Charlie", "Golf", "Hotel",
    "Kilo", "Lima", "Victor", "Zulu", "Tango", "Romeo", "Центр"
}

-- Функция для телепортации игрока к базе
local function teleportToBase(baseName)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local target = workspace.Tycoon.TycoonFloor:FindFirstChild(baseName)

    if target then
       
        character:SetPrimaryPartCFrame(target.CFrame + Vector3.new(0, 5, 0))
        print("Телепортировано к базе " .. baseName)
    else
        print("База " .. baseName .. " не найдена!")
    end
end


local PageTeleport = X.New({
    Title = "Teleport to Bases"
})


for _, baseName in ipairs(teleportButtons) do
    PageTeleport.Button({
        Text = "Teleport to " .. baseName,
        Callback = function(value)
            teleportToBase(baseName)
        end
    })
end




print("Скрипт загружен успешно!")
