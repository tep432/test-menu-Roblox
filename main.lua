--[[
    My Custom Menu - Built with Fluent UI Library
    السورس الخاص بك - مبني على مكتبة Fluent
    
    قم بتغيير المعلومات حسب رغبتك!
]]

-- ========================================
-- تحميل المكتبات
-- ========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ========================================
-- إعدادات المنيو - غيّرها حسب رغبتك!
-- ========================================
local MENU_SETTINGS = {
    Title = "My Menu",           -- اسم المنيو
    SubTitle = "by Your Name",   -- اسمك
    Version = "v1.0",            -- الإصدار
    Theme = "Dark",              -- الثيم: Dark, Light, Amethyst, Aqua, Rose
    MinimizeKey = Enum.KeyCode.RightControl,  -- زر إخفاء المنيو
    ConfigFolder = "MyMenu"      -- مجلد حفظ الإعدادات
}

-- ========================================
-- إنشاء النافذة الرئيسية
-- ========================================
local Window = Fluent:CreateWindow({
    Title = MENU_SETTINGS.Title .. " " .. MENU_SETTINGS.Version,
    SubTitle = MENU_SETTINGS.SubTitle,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = MENU_SETTINGS.Theme,
    MinimizeKey = MENU_SETTINGS.MinimizeKey
})

-- ========================================
-- إنشاء التابات (الأقسام)
-- ========================================
local Tabs = {
    Main = Window:AddTab({ Title = "الرئيسية", Icon = "home" }),
    Player = Window:AddTab({ Title = "اللاعب", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "التيليبورت", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "متنوع", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "الإعدادات", Icon = "cog" })
}

local Options = Fluent.Options

-- ========================================
-- القسم الرئيسي
-- ========================================
Tabs.Main:AddParagraph({
    Title = "مرحباً بك!",
    Content = "هذا المنيو الخاص بك.\nقم بتعديل الكود حسب احتياجاتك!"
})

Tabs.Main:AddButton({
    Title = "زر تجريبي",
    Description = "اضغط هنا لتجربة الزر",
    Callback = function()
        Fluent:Notify({
            Title = "نجاح!",
            Content = "تم الضغط على الزر بنجاح",
            Duration = 3
        })
    end
})

local Toggle1 = Tabs.Main:AddToggle("MainToggle", {
    Title = "تفعيل الميزة",
    Default = false
})

Toggle1:OnChanged(function()
    print("Toggle changed:", Options.MainToggle.Value)
end)

-- ========================================
-- قسم اللاعب
-- ========================================
local SpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "سرعة المشي",
    Description = "تغيير سرعة اللاعب",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

local JumpSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "قوة القفز",
    Description = "تغيير قوة القفز",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})

Tabs.Player:AddToggle("InfiniteJump", {
    Title = "قفز لانهائي",
    Default = false,
    Callback = function(Value)
        -- يمكنك إضافة كود القفز اللانهائي هنا
    end
})

Tabs.Player:AddToggle("Noclip", {
    Title = "نوكليب (المشي عبر الجدران)",
    Default = false,
    Callback = function(Value)
        -- يمكنك إضافة كود النوكليب هنا
    end
})

-- ========================================
-- قسم التيليبورت
-- ========================================
Tabs.Teleport:AddButton({
    Title = "التيليبورت للاعب",
    Description = "انتقل إلى اللاعب المحدد",
    Callback = function()
        -- يمكنك إضافة كود التيليبورت هنا
        Fluent:Notify({
            Title = "تيليبورت",
            Content = "اختر لاعب من القائمة",
            Duration = 3
        })
    end
})

-- قائمة اللاعبين
local PlayerList = {}
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        table.insert(PlayerList, player.Name)
    end
end

if #PlayerList > 0 then
    Tabs.Teleport:AddDropdown("TargetPlayer", {
        Title = "اختر لاعب",
        Values = PlayerList,
        Multi = false,
        Default = 1,
    })
end

-- ========================================
-- قسم متنوع
-- ========================================
Tabs.Misc:AddButton({
    Title = "إعادة تشغيل السكريبت",
    Description = "إعادة تحميل المنيو",
    Callback = function()
        Window:Dialog({
            Title = "تأكيد",
            Content = "هل تريد إعادة تشغيل السكريبت؟",
            Buttons = {
                {
                    Title = "نعم",
                    Callback = function()
                        Fluent:Destroy()
                        loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL_HERE"))()
                    end
                },
                {
                    Title = "لا"
                }
            }
        })
    end
})

Tabs.Misc:AddKeybind("ToggleKeybind", {
    Title = "زر إخفاء المنيو",
    Mode = "Toggle",
    Default = "RightControl",
    Callback = function()
        -- يتم التعامل معه تلقائياً
    end
})

Tabs.Misc:AddInput("CustomInput", {
    Title = "إدخال مخصص",
    Default = "",
    Placeholder = "اكتب هنا...",
    Callback = function(Value)
        print("Input:", Value)
    end
})

-- ========================================
-- إعدادات الحفظ والتحميل
-- ========================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder(MENU_SETTINGS.ConfigFolder)
SaveManager:SetFolder(MENU_SETTINGS.ConfigFolder .. "/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ========================================
-- التهيئة النهائية
-- ========================================
Window:SelectTab(1)

Fluent:Notify({
    Title = MENU_SETTINGS.Title,
    Content = "تم تحميل المنيو بنجاح!",
    SubContent = MENU_SETTINGS.Version,
    Duration = 5
})

-- تحميل الإعدادات المحفوظة تلقائياً
SaveManager:LoadAutoloadConfig()

print("[" .. MENU_SETTINGS.Title .. "] Loaded successfully!")
