local Players = game:GetService("Players") -- Исправлено: local с маленькой буквы
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Аннигиляция старого интерфейса 🗑️
if playerGui:FindFirstChild("MobileHighlighterDraggable") then
    playerGui:FindFirstChild("MobileHighlighterDraggable"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileHighlighterDraggable"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

---------------------------------------------------------
-- ⏳ УЛЬТРА-DRAG & DROP (Зажим 2.5 сек) 🚀
---------------------------------------------------------
local function makeDraggable(guiObject)
    local dragging = false
    local dragStart, startPos
    local holdTimer = 0
    local isReadyToDrag = false
    local holdDuration = 2.5 

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local currentHold = tick()
            holdTimer = currentHold
            isReadyToDrag = false
            
            -- Эффект "зарядки" 🔥
            local tweenLoad = TweenService:Create(guiObject, TweenInfo.new(holdDuration, Enum.EasingStyle.Linear), {
                BackgroundColor3 = Color3.fromRGB(255, 50, 50),
                Rotation = 5
            })
            tweenLoad:Play()

            task.delay(holdDuration, function()
                if holdTimer == currentHold then
                    isReadyToDrag = true
                    -- Взлетаем! 🚀
                    TweenService:Create(guiObject, TweenInfo.new(0.3), {
                        BackgroundColor3 = Color3.fromRGB(0, 255, 100),
                        Rotation = 0,
                        Size = guiObject.Size + UDim2.new(0, 10, 0, 10)
                    }):Play()
                end
            end)
        end
    end)

    -- Привязываем изменение ввода к конкретному объекту
    UserInputService.InputChanged:Connect(function(input)
        if isReadyToDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if not dragging then
                dragging = true
                dragStart = input.Position
                startPos = guiObject.Position
            end

            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holdTimer = 0
            isReadyToDrag = false
            dragging = false
            
            -- Возврат в нормальное состояние 🌈
            TweenService:Create(guiObject, TweenInfo.new(0.3), {
                BackgroundColor3 = (guiObject.Name == "ToggleButton") and (isEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)) or Color3.fromRGB(80, 80, 80),
                Size = (guiObject.Name == "SettingsButton") and UDim2.new(0, 50, 0, 50) or UDim2.new(0, 140, 0, 50),
                Rotation = 0
            }):Play()
        end
    end)
end

---------------------------------------------------------
-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (Красота!) ✨
---------------------------------------------------------

-- Кнопка ВКЛ/ВЫКЛ
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 140, 0, 50)
toggleButton.Position = UDim2.new(0.5, -150, 0.5, 0)
toggleButton.Text = "🌟 ВКЛ"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Parent = screenGui
makeDraggable(toggleButton)

-- Кнопка Настроек
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 50, 0, 50)
settingsButton.Position = UDim2.new(0.5, 10, 0.5, 0)
settingsButton.Text = "⚙️"
settingsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
settingsButton.TextColor3 = Color3.new(1, 1, 1)
settingsButton.Font = Enum.Font.SourceSansBold
settingsButton.TextSize = 25
settingsButton.Parent = screenGui
makeDraggable(settingsButton)

-- Панель настроек
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 180, 0, 100)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsFrame.Position = UDim2.new(0.5, 10, 0.5, 60)
settingsFrame.Visible = false
settingsFrame.Parent = screenGui

local colorButton = Instance.new("TextButton")
colorButton.Size = UDim2.new(1, -10, 0, 40)
colorButton.Position = UDim2.new(0, 5, 0, 5)
colorButton.Text = "Цвет: 🔴"
colorButton.Parent = settingsFrame

local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(1, -10, 0, 40)
transparencyButton.Position = UDim2.new(0, 5, 0, 50)
transparencyButton.Text = "Прозрачность: 50%"
transparencyButton.Parent = settingsFrame

---------------------------------------------------------
-- ЛОГИКА ESP (Магия вне Хогвартса) 🪄
---------------------------------------------------------
local colors = {
    {emoji = "🔴", color = Color3.fromRGB(255, 50, 50)},
    {emoji = "🟢", color = Color3.fromRGB(50, 255, 50)},
    {emoji = "🔵", color = Color3.fromRGB(50, 50, 255)}
}
local currentColorIndex = 1
local currentTransparency = 0.5
isEnabled = false -- Переменная теперь видна везде

local function createHighlight(plr)
    if plr == player or not plr.Character then return end
    local char = plr.Character
    local h = char:FindFirstChild("PlayerHighlight") or Instance.new("Highlight")
    h.Name = "PlayerHighlight"
    h.Adornee = char
    h.FillColor = colors[currentColorIndex].color
    h.OutlineColor = Color3.new(1, 1, 1)
    h.FillTransparency = currentTransparency
    h.Enabled = isEnabled
    h.Parent = char
end

local function updateAll()
    for _, plr in pairs(Players:GetPlayers()) do
        createHighlight(plr)
    end
end

toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleButton.Text = isEnabled and "🌟 ВЫКЛ" or "🌟 ВКЛ"
    toggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)
    updateAll()
end)

settingsButton.MouseButton1Click:Connect(function()
    -- Обновляем позицию фрейма относительно кнопки
    settingsFrame.Position = UDim2.new(settingsButton.Position.X.Scale, settingsButton.Position.X.Offset, settingsButton.Position.Y.Scale, settingsButton.Position.Y.Offset + 60)
    settingsFrame.Visible = not settingsFrame.Visible
end)

colorButton.MouseButton1Click:Connect(function()
    currentColorIndex = currentColorIndex % #colors + 1
    colorButton.Text = "Цвет: "..colors[currentColorIndex].emoji
    updateAll()
end)

transparencyButton.MouseButton1Click:Connect(function()
    currentTransparency = currentTransparency + 0.2
    if currentTransparency > 1 then currentTransparency = 0 end
    transparencyButton.Text = "Прозрачность: "..math.floor((1-currentTransparency)*100).."%"
    updateAll()
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        createHighlight(plr)
    end)
end)

updateAll() -- Запускаем первичную проверку
print("ESP Скрипт успешно загружен! Трафик потребляется, код пилится! 🛠️⚡")
