local function makeDraggable(guiObject)
	local dragging = false
	local dragStart, startPos
	local holdTimer = 0
	local isReadyToDrag = false
	local holdDuration = 2.5 -- Твои 2.5 секунды

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local currentHold = tick()
			holdTimer = currentHold
			isReadyToDrag = false
			
			-- Визуальный эффект: кнопка начинает "пульсировать" или краснеть, пока жмешь
			local tweenLoad = TweenService:Create(guiObject, TweenInfo.new(holdDuration, Enum.EasingStyle.Linear), {
				BackgroundColor3 = Color3.fromRGB(255, 0, 0), -- Краснеет при зарядке
				Rotation = 5 -- Слегка наклоняется
			})
			tweenLoad:Play()

			task.delay(holdDuration, function()
				if holdTimer == currentHold then
					isReadyToDrag = true
					-- Кнопка готова! Даем знать звуком или вспышкой
					TweenService:Create(guiObject, TweenInfo.new(0.3), {
						BackgroundColor3 = Color3.fromRGB(0, 255, 100), -- Зеленая = можно тащить
						Rotation = 0,
						Size = guiObject.Size + UDim2.new(0, 10, 0, 10)
					}):Play()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isReadyToDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			if not dragging then
				dragging = true
				dragStart = input.Position
				startPos = guiObject.Position
			end

			local delta = input.Position - dragStart
			-- Тут можно оставить плавность из прошлого шага
			TweenService:Create(guiObject, TweenInfo.new(0.2), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)

	guiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			holdTimer = 0
			isReadyToDrag = false
			dragging = false
			
			-- Возвращаем всё в исходный вид
			TweenService:Create(guiObject, TweenInfo.new(0.3), {
				BackgroundColor3 = Color3.fromRGB(80, 80, 80), -- Твой стандартный цвет
				Size = UDim2.new(0, 50, 0, 50), -- Твой стандартный размер
				Rotation = 0
			}):Play()
		end
	end)
end
