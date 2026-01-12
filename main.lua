--[[
    Heven Menu - النسخة العربية المتقدمة
    تم التطوير بواسطة Heven
]]

-- تحميل مكتبة Heven UI
local Heven = loadstring(game:HttpGet("https://raw.githubusercontent.com/tep432/test-menu-Roblox/main/Heven.lua"))()

-- الخدمات
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VoiceChatService = game:GetService("VoiceChatService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- معلومات اللاعب
local LocalPlayer = Players.LocalPlayer
local StartTime = os.time()
local Camera = workspace.CurrentCamera

-- متغيرات عامة
getgenv().HevenMenu = getgenv().HevenMenu or {}
getgenv().HevenMenu.LaunchCount = (getgenv().HevenMenu.LaunchCount or 0) + 1
getgenv().HevenMenu.Flying = false
getgenv().HevenMenu.Noclip = false
getgenv().HevenMenu.InfiniteJump = false
getgenv().HevenMenu.ESP = false
getgenv().HevenMenu.Fullbright = false

local LaunchCount = getgenv().HevenMenu.LaunchCount

-- دالة لمعرفة نوع الجهاز
local function GetDeviceType()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "جوال"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "يد تحكم"
    elseif UserInputService.VREnabled then
        return "VR"
    else
        return "كمبيوتر"
    end
end

-- دالة لمعرفة حالة المايك
local function GetMicStatus()
    local success, result = pcall(function()
        return VoiceChatService:IsVoiceEnabledForUserIdAsync(LocalPlayer.UserId)
    end)
    if success and result then
        return "مفعّل"
    else
        return "غير مفعّل"
    end
end

-- دالة لحساب وقت التشغيل
local function GetUptime()
    local elapsed = os.time() - StartTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = elapsed % 60
    
    if hours > 0 then
        return string.format("%d ساعة %d دقيقة", hours, minutes)
    elseif minutes > 0 then
        return string.format("%d دقيقة %d ثانية", minutes, seconds)
    else
        return string.format("%d ثانية", seconds)
    end
end

-- دالة لمعرفة ريجن السيرفر
local function GetServerRegion()
    local region = "غير معروف"
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local response = game:HttpGet("http://ip-api.com/json/")
        local data = HttpService:JSONDecode(response)
        if data then
            local regionNames = {
                -- الدول العربية
                ["Saudi Arabia"] = "السعودية",
                ["United Arab Emirates"] = "الإمارات",
                ["Egypt"] = "مصر",
                ["Qatar"] = "قطر",
                ["Kuwait"] = "الكويت",
                ["Bahrain"] = "البحرين",
                ["Oman"] = "عُمان",
                ["Jordan"] = "الأردن",
                ["Lebanon"] = "لبنان",
                ["Iraq"] = "العراق",
                ["Morocco"] = "المغرب",
                ["Algeria"] = "الجزائر",
                ["Tunisia"] = "تونس",
                ["Libya"] = "ليبيا",
                ["Sudan"] = "السودان",
                ["Yemen"] = "اليمن",
                ["Syria"] = "سوريا",
                ["Palestine"] = "فلسطين",
                -- دول أخرى
                ["United States"] = "أمريكا",
                ["Germany"] = "ألمانيا",
                ["United Kingdom"] = "بريطانيا",
                ["France"] = "فرنسا",
                ["Netherlands"] = "هولندا",
                ["Singapore"] = "سنغافورة",
                ["Japan"] = "اليابان",
                ["Australia"] = "أستراليا",
                ["Brazil"] = "البرازيل",
                ["India"] = "الهند",
                ["Turkey"] = "تركيا",
                ["Russia"] = "روسيا",
                ["China"] = "الصين",
                ["South Korea"] = "كوريا الجنوبية",
                ["Canada"] = "كندا",
                ["Mexico"] = "المكسيك",
                ["Italy"] = "إيطاليا",
                ["Spain"] = "إسبانيا",
                ["Poland"] = "بولندا",
                ["Sweden"] = "السويد"
            }
            local country = data.country or "Unknown"
            local city = data.city or ""
            region = (regionNames[country] or country) .. " - " .. city
        end
    end)
    return region
end

-- دالة الطيران
local function SetupFly()
    local flySpeed = 50
    local flying = false
    local bodyGyro, bodyVelocity
    
    return function(enabled, speed)
        flySpeed = speed or flySpeed
        flying = enabled
        
        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if enabled then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 1000000
            bodyGyro.Parent = humanoidRootPart
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = humanoidRootPart
            
            spawn(function()
                while flying and humanoidRootPart and bodyVelocity do
                    local moveDirection = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDirection = moveDirection + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDirection = moveDirection - Vector3.new(0, 1, 0)
                    end
                    
                    if moveDirection.Magnitude > 0 then
                        bodyVelocity.Velocity = moveDirection.Unit * flySpeed
                    else
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    bodyGyro.CFrame = Camera.CFrame
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end
end

local FlyFunction = SetupFly()

-- إنشاء النافذة
local Window = Heven:CreateWindow({
    Title = "Heven Menu",
    SubTitle = "النسخة العربية",
    TabWidth = 140,
    Size = UDim2.fromOffset(540, 440),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- إنشاء الأقسام
local Tabs = {
    Home = Window:AddTab({ Title = "الرئيسية", Icon = "home" }),
    Player = Window:AddTab({ Title = "اللاعب", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "التنقل", Icon = "map-pin" }),
    Visual = Window:AddTab({ Title = "المرئيات", Icon = "eye" }),
    Server = Window:AddTab({ Title = "السيرفر", Icon = "globe" }),
    Settings = Window:AddTab({ Title = "الإعدادات", Icon = "settings" })
}

--[[ ═══════════════════════════════════════
     قسم الرئيسية
═══════════════════════════════════════ ]]

local AccountSection = Tabs.Home:AddSection("معلومات الحساب")

AccountSection:AddParagraph({
    Title = LocalPlayer.DisplayName,
    Content = "الاسم: @" .. LocalPlayer.Name .. "\nالـ ID: " .. LocalPlayer.UserId
})

AccountSection:AddParagraph({
    Title = "نوع الجهاز",
    Content = GetDeviceType()
})

AccountSection:AddParagraph({
    Title = "حالة المايك",
    Content = GetMicStatus()
})

local StatsSection = Tabs.Home:AddSection("إحصائيات المنيو")

StatsSection:AddParagraph({
    Title = "مرات التشغيل",
    Content = tostring(LaunchCount) .. " مرة"
})

local UptimeParagraph = StatsSection:AddParagraph({
    Title = "وقت التشغيل",
    Content = "0 ثانية"
})

local ServerSection = Tabs.Home:AddSection("معلومات اللعبة")

local gameName = "غير معروف"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

ServerSection:AddParagraph({
    Title = "اللعبة",
    Content = gameName
})

ServerSection:AddParagraph({
    Title = "عدد اللاعبين",
    Content = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
})

ServerSection:AddParagraph({
    Title = "ريجن السيرفر",
    Content = GetServerRegion()
})

ServerSection:AddParagraph({
    Title = "بينق السيرفر",
    Content = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
})

--[[ ═══════════════════════════════════════
     قسم اللاعب
═══════════════════════════════════════ ]]

local MovementSection = Tabs.Player:AddSection("الحركة")

MovementSection:AddSlider("WalkSpeed", {
    Title = "سرعة المشي",
    Description = "غيّر سرعة مشي شخصيتك",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end
})

MovementSection:AddSlider("JumpPower", {
    Title = "قوة القفز",
    Description = "غيّر قوة قفز شخصيتك",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end)
    end
})

MovementSection:AddToggle("InfiniteJump", {
    Title = "قفز لا نهائي",
    Description = "اقفز في الهواء بدون حدود",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.InfiniteJump = Value
    end
})

local FlySection = Tabs.Player:AddSection("الطيران")

local FlySpeedSlider
FlySection:AddToggle("Fly", {
    Title = "تفعيل الطيران",
    Description = "طِر في الهواء بحرية",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.Flying = Value
        FlyFunction(Value, FlySpeedSlider and Heven.Options.FlySpeed.Value or 50)
    end
})

FlySpeedSlider = FlySection:AddSlider("FlySpeed", {
    Title = "سرعة الطيران",
    Description = "غيّر سرعة الطيران",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        -- يتم تطبيقها تلقائياً
    end
})

local NoclipSection = Tabs.Player:AddSection("الاختراق")

NoclipSection:AddToggle("Noclip", {
    Title = "اختراق الجدران",
    Description = "اخترق أي جدار أو عائق",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.Noclip = Value
    end
})

-- تفعيل Noclip
RunService.Stepped:Connect(function()
    if getgenv().HevenMenu.Noclip then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- تفعيل القفز اللانهائي
UserInputService.JumpRequest:Connect(function()
    if getgenv().HevenMenu.InfiniteJump then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

--[[ ═══════════════════════════════════════
     قسم التنقل
═══════════════════════════════════════ ]]

local TeleportSection = Tabs.Teleport:AddSection("التنقل للاعبين")

local SelectedPlayer = nil
TeleportSection:AddDropdown("PlayerSelect", {
    Title = "اختر لاعب",
    Description = "اختر اللاعب للتنقل إليه",
    Values = (function()
        local names = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        return names
    end)(),
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

TeleportSection:AddButton({
    Title = "انتقل للاعب",
    Description = "انتقل للاعب المحدد",
    Callback = function()
        if SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                Heven:Notify({
                    Title = "تم التنقل",
                    Content = "انتقلت إلى " .. SelectedPlayer,
                    Duration = 2
                })
            end
        end
    end
})

local PositionSection = Tabs.Teleport:AddSection("حفظ المواقع")

local SavedPositions = {}
PositionSection:AddButton({
    Title = "حفظ الموقع الحالي",
    Description = "احفظ موقعك الحالي للعودة إليه",
    Callback = function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        table.insert(SavedPositions, pos)
        Heven:Notify({
            Title = "تم الحفظ",
            Content = "تم حفظ الموقع #" .. #SavedPositions,
            Duration = 2
        })
    end
})

PositionSection:AddButton({
    Title = "العودة للموقع الأخير",
    Description = "ارجع لآخر موقع محفوظ",
    Callback = function()
        if #SavedPositions > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPositions[#SavedPositions])
            Heven:Notify({
                Title = "تم التنقل",
                Content = "رجعت للموقع المحفوظ",
                Duration = 2
            })
        else
            Heven:Notify({
                Title = "خطأ",
                Content = "لا يوجد مواقع محفوظة",
                Duration = 2
            })
        end
    end
})

--[[ ═══════════════════════════════════════
     قسم المرئيات
═══════════════════════════════════════ ]]

local VisualSection = Tabs.Visual:AddSection("الإضاءة")

VisualSection:AddToggle("Fullbright", {
    Title = "إضاءة كاملة",
    Description = "اجعل كل شي واضح حتى في الظلام",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.Fullbright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

VisualSection:AddSlider("FieldOfView", {
    Title = "مجال الرؤية (FOV)",
    Description = "وسّع أو ضيّق مجال الرؤية",
    Default = 70,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

local ESPSection = Tabs.Visual:AddSection("تتبع اللاعبين")

ESPSection:AddToggle("PlayerESP", {
    Title = "إظهار أسماء اللاعبين",
    Description = "اظهر أسماء اللاعبين فوق رؤوسهم",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.ESP = Value
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local existing = head:FindFirstChild("HevenESP")
                    if Value then
                        if not existing then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "HevenESP"
                            billboard.Size = UDim2.new(0, 100, 0, 40)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = head
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = player.DisplayName
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextScaled = true
                            label.Parent = billboard
                        end
                    else
                        if existing then
                            existing:Destroy()
                        end
                    end
                end
            end
        end
    end
})

--[[ ═══════════════════════════════════════
     قسم السيرفر
═══════════════════════════════════════ ]]

local ServerInfoSection = Tabs.Server:AddSection("معلومات السيرفر")

ServerInfoSection:AddParagraph({
    Title = "معرف السيرفر",
    Content = game.JobId
})

ServerInfoSection:AddParagraph({
    Title = "معرف اللعبة",
    Content = tostring(game.PlaceId)
})

local ServerActionsSection = Tabs.Server:AddSection("إجراءات")

ServerActionsSection:AddButton({
    Title = "إعادة الانضمام",
    Description = "اخرج وادخل السيرفر من جديد",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

ServerActionsSection:AddButton({
    Title = "سيرفر جديد",
    Description = "ادخل سيرفر مختلف",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, "", LocalPlayer)
    end
})

ServerActionsSection:AddButton({
    Title = "نسخ رابط السيرفر",
    Description = "انسخ رابط للانضمام لهذا السيرفر",
    Callback = function()
        local link = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
        setclipboard(link)
        Heven:Notify({
            Title = "تم النسخ",
            Content = "تم نسخ الرابط للحافظة",
            Duration = 2
        })
    end
})

--[[ ═══════════════════════════════════════
     قسم الإعدادات
═══════════════════════════════════════ ]]

local SettingsSection = Tabs.Settings:AddSection("مظهر المنيو")

SettingsSection:AddDropdown("Theme", {
    Title = "المظهر",
    Description = "غيّر ألوان المنيو",
    Values = {"Darker", "Dark", "Aqua", "Amethyst", "Rose", "Light"},
    Default = "Darker",
    Callback = function(Value)
        Heven:SetTheme(Value)
    end
})

local ControlsSection = Tabs.Settings:AddSection("التحكم")

ControlsSection:AddKeybind("MinimizeKey", {
    Title = "زر الإخفاء",
    Description = "غيّر زر إظهار/إخفاء المنيو",
    Default = "RightShift"
})

local CloseSection = Tabs.Settings:AddSection("إغلاق")

CloseSection:AddButton({
    Title = "إغلاق المنيو نهائياً",
    Description = "اضغط لإغلاق وحذف المنيو",
    Callback = function()
        -- إزالة ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local esp = head:FindFirstChild("HevenESP")
                    if esp then esp:Destroy() end
                end
            end
        end
        Heven:Destroy()
    end
})

-- تحديث وقت التشغيل
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            UptimeParagraph:SetDesc(GetUptime())
        end)
    end
end)

-- اختيار القسم الأول
Window:SelectTab(1)

-- إشعار الترحيب
Heven:Notify({
    Title = "اهلا " .. LocalPlayer.DisplayName,
    Content = "تم تحميل Heven Menu بنجاح!",
    Duration = 4
})
