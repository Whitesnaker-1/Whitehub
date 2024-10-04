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

local Page1 = X.New({
    Title = "Farm"
})

-- Флаг для контроля автофарма
local isFarming = false

-- Функция для телепортации к объекту
local function teleportToObject(object)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = object.CFrame
        print("Персонаж телепортирован к " .. object.Name)
    else
        print("Не удалось найти HumanoidRootPart или персонаж.")
    end
end

-- Функция для симуляции нажатия клавиши E
local function pressE(objectName)
    if not isFarming then return end  -- Проверка перед выполнением действия
    local item = workspace:FindFirstChild("Vfx") and workspace.Vfx:FindFirstChild(objectName)

    if item and item:IsA("Model") then
        local handle = item:FindFirstChild("Handle")
        if handle then
            teleportToObject(handle)
        else
            print("Объект Handle не найден в " .. objectName)
        end
    else
        print("Объект " .. objectName .. " не найден в Vfx")
    end
end

-- Функция для автоматического выполнения действия
local function autoPressE(objectName)
    isFarming = true -- Включаем автофарм
    while isFarming do
        wait(2) -- Увеличение интервала перед выполнением действия
        pressE(objectName)
    end
    print("Автофарм остановлен.")
end

-- Создание кнопки для автофарма стрел
local MyButton = Page1.Button({
    Text = "AutoFarm arrows",
    Callback = function(value)
        spawn(function() autoPressE("Stand Arrow") end) -- Запуск автофарма стрел
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Insert then
                isFarming = false -- Останавливаем фарм
            end
        end)
    end
})

-- Создание второй кнопки для автофарма (с объектом "Rokakaka")
local MyButton2 = Page1.Button({
    Text = "AutoFarm Rokakaka",
    Callback = function(value)
        spawn(function() autoPressE("Rokakaka") end) -- Запуск автофарма Рокакаки
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Insert then
                isFarming = false -- Останавливаем фарм
            end
        end)
    end
})

local Page2 = X.New({
    Title = "ESP"
})

-- Флаг для контроля ESP
local isESPEnabled = false
local espBoxes = {}  -- Таблица для хранения объектов ESP

local MyButton3 = Page2.Button({
    Text = "ESP players",
    Callback = function(value)
        isESPEnabled = not isESPEnabled
        if isESPEnabled then
            for _, childrik in ipairs(workspace:GetDescendants()) do
                if childrik:FindFirstChild("Humanoid") and childrik ~= game.Players.LocalPlayer.Character then
                    if not childrik:FindFirstChild("EspBox") then
                        local esp = Instance.new("BoxHandleAdornment")
                        esp.Adornee = childrik
                        esp.ZIndex = 0
                        esp.Size = Vector3.new(4, 5, 1)
                        esp.Transparency = 0.65
                        esp.Color3 = Color3.fromRGB(255, 48, 48)
                        esp.AlwaysOnTop = true
                        esp.Name = "EspBox"
                        esp.Parent = childrik
                        espBoxes[childrik] = esp  -- Сохраняем ссылку на объект ESP
                    end
                end
            end
        else
            -- Удаляем все ESP объекты
            for _, box in pairs(espBoxes) do
                if box then
                    box:Destroy()
                end
            end
            espBoxes = {}  -- Очищаем таблицу
        end
    end
})

-- Оптимизация: периодическое обновление ESP объектов
game:GetService("RunService").RenderStepped:Connect(function()
    if isESPEnabled then
        for player, esp in pairs(espBoxes) do
            if player:FindFirstChild("Humanoid") then
                esp.Adornee = player
            else
                esp:Destroy()
                espBoxes[player] = nil  -- Удаляем ESP из таблицы, если игрока нет
            end
        end
    end
end)

local Page3 = X.New({
    Title = "Teleport"
})

local MyButton4 = Page3.Button({  
    Text = "Teleport to Storage", 
    Callback = function(value)
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        -- Функция телепортации к NPC Pop Cat
        local function teleportToNPC()
            local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild("Pop_Cat")
            
            if npc and npc:FindFirstChild("HumanoidRootPart") then
                local character = player.Character or player.CharacterAdded:Wait()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame
                    print("Персонаж телепортирован к NPC Pop Cat")
                else
                    print("Не удалось найти HumanoidRootPart у персонажа.")
                end
            else
                print("NPC Pop Cat не найден или не имеет HumanoidRootPart.")
            end
        end

        teleportToNPC()
    end
})

local MyButton5 = Page3.Button({
    Text = "Teleport to Merchant AU (not work)",  
    Callback = function(value)
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        local function teleportToNPC()
            local npc = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPCs") and workspace.Map.NPCs:FindFirstChild("MerchantAU")
            
            if npc and npc:FindFirstChild("HumanoidRootPart") then
                local character = player.Character or player.CharacterAdded:Wait()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame
                    print("Персонаж телепортирован к NPC Merchant AU")
                else
                    print("Не удалось найти HumanoidRootPart у персонажа.")
                end
            else
                print("NPC Merchant AU не найден или не имеет HumanoidRootPart.")
            end
        end

        teleportToNPC()
    end
})

-- Шестая кнопка для телепортации на workspace.Map.ChancesBoards.NormalArrowChances
local MyButton6 = Page3.Button({
    Text = "Teleport to Arrow chances",  
    Callback = function(value)
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        -- Функция телепортации к объекту NormalArrowChances
        local function teleportToBoard()
            local object = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ChancesBoards") and workspace.Map.ChancesBoards:FindFirstChild("NormalArrowChances")
            
            if object then
                local character = player.Character or player.CharacterAdded:Wait()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = object.CFrame
                    print("Персонаж телепортирован к NormalArrowChances")
                else
                    print("Не удалось найти HumanoidRootPart у персонажа.")
                end
            else
                print("Объект NormalArrowChances не найден.")
            end
        end

        teleportToBoard()
    end
})
