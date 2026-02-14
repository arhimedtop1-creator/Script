local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rayfield Example Window",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- <--- ЗДЕСЬ БЫЛА ПРОПУЩЕНА ЗАПЯТАЯ!
   
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Создание вкладок
local Tab1 = Window:CreateTab("Tab Example 1", "rewind")  -- иконка как текст
local Tab2 = Window:CreateTab("Tab Example 2", 4483362458) -- иконка как ID картинки

-- Добавим немного контента, чтобы вкладки не были пустыми
local Section = Tab1:CreateSection("Пример секции")

Tab1:CreateButton({
   Name = "Тестовая кнопка",
   Callback = function()
      print("Кнопка нажата!")
      Rayfield:Notify({
         Title = "Уведомление",
         Content = "Кнопка работает!",
         Duration = 2.5
      })
   end
})

Tab2:CreateButton({
   Name = "Еще кнопка",
   Callback = function()
      print("Работает!")
   end
})
