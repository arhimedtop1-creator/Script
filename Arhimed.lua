local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   Icon = 0,
   LoadingTitle = "Загрузка...",
   LoadingSubtitle = "ESP",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "ESP_Settings"
   }
})

-- Создаем вкладку ESP
local ESPTab = Window:CreateTab("ESP", "eye")

-- Переменные ESP (ВСЕ ВЫКЛЮЧЕНЫ ПО УМОЛЧАНИЮ)
local ESP = {
   Enabled = false,           -- ESP выключен
   ShowBox = false,           -- Боксы выключены
   ShowName = false,          -- Имена выключены
   ShowDistance = false,      -- Дистанция выключена
   ShowTracer = false,        -- Трейсеры выключены
   TeamColor = Color3.new(0, 1, 0),    -- Зеленый для команды
   EnemyColor = Color3.new(1, 0, 0),    -- Красный для врагов
   MaxDistance = 2000
}

-- Хранилище для объектов ESP
local ESPObjects = {}

-- Функция создания ESP для игрока
local function CreateESP(player)
   if player == game.Players.LocalPlayer then return end
   
   -- Создаем объекты ESP
   local esp = {
      Box = {
         Top = Drawing.new("Line"),
         Bottom = Drawing.new("Line"),
         Left = Drawing.new("Line"),
         Right = Drawing.new("Line")
      },
      Name = Drawing.new("Text"),
      Distance = Drawing.new("Text"),
      Tracer = Drawing.new("Line")
   }
   
   -- Настройка бокса
   for _, line in pairs(esp.Box) do
      line.Thickness = 2
      line.Transparency = 1
      line.Color = ESP.TeamColor
      line.Visible = false  -- Изначально невидимы
   end
   
   -- Настройка имени
   esp.Name.Size = 16
   esp.Name.Center = true
   esp.Name.Outline = true
   esp.Name.Color = Color3.new(1, 1, 1)
   esp.Name.Visible = false  -- Изначально невидимо
   
   -- Настройка дистанции
   esp.Distance.Size = 14
   esp.Distance.Center = true
   esp.Distance.Outline = true
   esp.Distance.Color = Color3.new(1, 1, 1)
   esp.Distance.Visible = false  -- Изначально невидимо
   
   -- Настройка трейсера
   esp.Tracer.Thickness = 2
   esp.Tracer.Transparency = 0.7
   esp.Tracer.Visible = false  -- Изначально невидимо
   
   ESPObjects[player.Name] = esp
end

-- Функция проверки команды
local function IsTeam(player)
   if player.TeamColor == game.Players.LocalPlayer.TeamColor then
      return true
   end
   return false
end

-- Функция обновления ESP
local function UpdateESP()
   if not ESP.Enabled then 
      -- Скрываем все если ESP выключен
      for _, esp in pairs(ESPObjects) do
         for _, line in pairs(esp.Box) do line.Visible = false end
         esp.Name.Visible = false
         esp.Distance.Visible = false
         esp.Tracer.Visible = false
      end
      return 
   end
   
   local camera = workspace.CurrentCamera
   local viewport = camera.ViewportSize
   local localPlayer = game.Players.LocalPlayer
   
   for _, player in ipairs(game.Players:GetPlayers()) do
      if player ~= localPlayer then
         local esp = ESPObjects[player.Name]
         local character = player.Character
         
         if esp and character then
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            
            if head and humanoid and root and humanoid.Health > 0 then
               -- Проверка дистанции
               local headPos = head.Position
               local distance = (camera.CFrame.Position - headPos).Magnitude
               
               if distance < ESP.MaxDistance then
                  -- Определяем цвет (команда или враг)
                  local color = IsTeam(player) and ESP.TeamColor or ESP.EnemyColor
                  
                  -- Получаем позицию на экране
                  local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                  
                  if onScreen then
                     local pos2d = Vector2.new(screenPos.X, screenPos.Y)
                     
                     -- БОКС (рамка) - показываем только если включен
                     if ESP.ShowBox then
                        local boxSize = math.clamp(500 / distance, 30, 80)
                        
                        -- Верхняя линия
                        esp.Box.Top.From = Vector2.new(pos2d.X - boxSize, pos2d.Y - boxSize)
                        esp.Box.Top.To = Vector2.new(pos2d.X + boxSize, pos2d.Y - boxSize)
                        esp.Box.Top.Color = color
                        esp.Box.Top.Visible = true
                        
                        -- Правая линия
                        esp.Box.Right.From = Vector2.new(pos2d.X + boxSize, pos2d.Y - boxSize)
                        esp.Box.Right.To = Vector2.new(pos2d.X + boxSize, pos2d.Y + boxSize)
                        esp.Box.Right.Color = color
                        esp.Box.Right.Visible = true
                        
                        -- Нижняя линия
                        esp.Box.Bottom.From = Vector2.new(pos2d.X + boxSize, pos2d.Y + boxSize)
                        esp.Box.Bottom.To = Vector2.new(pos2d.X - boxSize, pos2d.Y + boxSize)
                        esp.Box.Bottom.Color = color
                        esp.Box.Bottom.Visible = true
                        
                        -- Левая линия
                        esp.Box.Left.From = Vector2.new(pos2d.X - boxSize, pos2d.Y + boxSize)
                        esp.Box.Left.To = Vector2.new(pos2d.X - boxSize, pos2d.Y - boxSize)
                        esp.Box.Left.Color = color
                        esp.Box.Left.Visible = true
                     else
                        for _, line in pairs(esp.Box) do line.Visible = false end
                     end
                     
                     -- ИМЯ - показываем только если включен
                     if ESP.ShowName then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(pos2d.X, pos2d.Y - 50)
                        esp.Name.Visible = true
                     else
                        esp.Name.Visible = false
                     end
                     
                     -- ДИСТАНЦИЯ - показываем только если включен
                     if ESP.ShowDistance then
                        esp.Distance.Text = tostring(math.floor(distance)) .. " studs"
                        esp.Distance.Position = Vector2.new(pos2d.X, pos2d.Y - 30)
                        esp.Distance.Visible = true
                     else
                        esp.Distance.Visible = false
                     end
                     
                     -- ТРЕЙСЕР - показываем только если включен
                     if ESP.ShowTracer then
                        esp.Tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
                        esp.Tracer.To = pos2d
                        esp.Tracer.Color = color
                        esp.Tracer.Visible = true
                     else
                        esp.Tracer.Visible = false
                     end
                  else
                     -- Если игрок не на экране
                     for _, line in pairs(esp.Box) do line.Visible = false end
                     esp.Name.Visible = false
                     esp.Distance.Visible = false
                     esp.Tracer.Visible = false
                  end
               else
                  -- Если слишком далеко
                  for _, line in pairs(esp.Box) do line.Visible = false end
                  esp.Name.Visible = false
                  esp.Distance.Visible = false
                  esp.Tracer.Visible = false
               end
            else
               -- Если персонаж мертв
               for _, line in pairs(esp.Box) do line.Visible = false end
               esp.Name.Visible = false
               esp.Distance.Visible = false
               esp.Tracer.Visible = false
            end
         end
      end
   end
end

-- Создаем ESP для всех игроков (НО ОНИ ВСЕ НЕВИДИМЫ)
for _, player in ipairs(game.Players:GetPlayers()) do
   CreateESP(player)
end

-- Отслеживаем новых игроков
game.Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      wait(0.5)
      CreateESP(player)
   end)
end)

-- Запускаем цикл обновления
game:GetService("RunService"):BindToRenderStep("ESPUpdate", 200, UpdateESP)

-- Создаем интерфейс
local Section = ESPTab:CreateSection("Настройки ESP")

-- Включение/выключение ESP (ПО УМОЛЧАНИЮ ВЫКЛЮЧЕНО)
ESPTab:CreateToggle({
   Name = "Включить ESP",
   CurrentValue = false,  -- ВЫКЛЮЧЕНО
   Callback = function(value)
      ESP.Enabled = value
      Rayfield:Notify({
         Title = "ESP",
         Content = value and "ESP включен" or "ESP выключен",
         Duration = 1.5
      })
   end
})

-- Боксы (ПО УМОЛЧАНИЮ ВЫКЛЮЧЕНО)
ESPTab:CreateToggle({
   Name = "Показывать боксы",
   CurrentValue = false,  -- ВЫКЛЮЧЕНО
   Callback = function(value)
      ESP.ShowBox = value
   end
})

-- Имена (ПО УМОЛЧАНИЮ ВЫКЛЮЧЕНО)
ESPTab:CreateToggle({
   Name = "Показывать имена",
   CurrentValue = false,  -- ВЫКЛЮЧЕНО
   Callback = function(value)
      ESP.ShowName = value
   end
})

-- Дистанция (ПО УМОЛЧАНИЮ ВЫКЛЮЧЕНО)
ESPTab:CreateToggle({
   Name = "Показывать дистанцию",
   CurrentValue = false,  -- ВЫКЛЮЧЕНО
   Callback = function(value)
      ESP.ShowDistance = value
   end
})

-- Трейсеры (ПО УМОЛЧАНИЮ ВЫКЛЮЧЕНО)
ESPTab:CreateToggle({
   Name = "Показывать трейсеры",
   CurrentValue = false,  -- ВЫКЛЮЧЕНО
   Callback = function(value)
      ESP.ShowTracer = value
   end
})

-- Цвет команды
ESPTab:CreateButton({
   Name = "Цвет команды (зеленый)",
   Callback = function()
      ESP.TeamColor = Color3.new(0, 1, 0)
      Rayfield:Notify({
         Title = "Цвет",
         Content = "Цвет команды: зеленый",
         Duration = 1
      })
   end
})

-- Цвет врагов
ESPTab:CreateButton({
   Name = "Цвет врагов (красный)",
   Callback = function()
      ESP.EnemyColor = Color3.new(1, 0, 0)
      Rayfield:Notify({
         Title = "Цвет",
         Content = "Цвет врагов: красный",
         Duration = 1
      })
   end
})

ESPTab:CreateButton({
   Name = "Цвет врагов (синий)",
   Callback = function()
      ESP.EnemyColor = Color3.new(0, 0, 1)
      Rayfield:Notify({
         Title = "Цвет",
         Content = "Цвет врагов: синий",
         Duration = 1
      })
   end
})

-- Дистанция
ESPTab:CreateSlider({
   Name = "Макс. дистанция",
   Range = {500, 5000},
   Increment = 100,
   Suffix = "studs",
   CurrentValue = 2000,
   Callback = function(value)
      ESP.MaxDistance = value
   end
})

-- Информация
ESPTab:CreateLabel("Нажмите K чтобы скрыть меню")
ESPTab:CreateLabel("Все функции ESP выключены по умолчанию")
