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
toggle
