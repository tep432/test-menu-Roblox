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

-- نظام الطيران السلس
local FlyEnabled = false
local FlySpeed = 50
local FlyConnection = nil
local CurrentVelocity = Vector3.new(0, 0, 0)
local Smoothness = 0.08 -- للسلاسة

local function ToggleFly(enabled, speed)
    FlySpeed = speed or FlySpeed
    
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid then return end
    
    -- إيقاف أي طيران سابق
    if FlyConnection then
        pcall(function() FlyConnection:Disconnect() end)
        FlyConnection = nil
    end
    
    -- حذف أي BodyVelocity قديم
    for _, child in pairs(hrp:GetChildren()) do
        if child.Name == "HevenFlyBV" then
            child:Destroy()
        end
    end
    
    if enabled then
        FlyEnabled = true
        CurrentVelocity = Vector3.new(0, 0, 0)
        
        -- إنشاء BodyVelocity
        local bv = Instance.new("BodyVelocity")
        bv.Name = "HevenFlyBV"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        -- لوب التحكم السلس
        FlyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled then return end
            if not hrp or not hrp.Parent then return end
            
            -- اتجاه الكاميرا
            local cf = Camera.CFrame
            local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
            local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
            
            -- حساب الاتجاه المستهدف
            local targetVel = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                targetVel = targetVel + forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                targetVel = targetVel - forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                targetVel = targetVel - right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                targetVel = targetVel + right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                targetVel = targetVel + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                targetVel = targetVel - Vector3.new(0, 1, 0)
            end
            
            -- تطبيق السرعة مع السلاسة
            if targetVel.Magnitude > 0 then
                targetVel = targetVel.Unit * FlySpeed
            end
            
            -- Lerp للحركة السلسة
            CurrentVelocity = CurrentVelocity:Lerp(targetVel, Smoothness)
            
            -- إضافة طفو خفيف عند الثبات
            if CurrentVelocity.Magnitude < 1 then
                bv.Velocity = Vector3.new(0, math.sin(tick() * 2) * 0.5, 0)
            else
                bv.Velocity = CurrentVelocity
            end
            
            -- منع السقوط
            humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        end)
        
    else
        FlyEnabled = false
        CurrentVelocity = Vector3.new(0, 0, 0)
        
        -- إيقاف الـ Connection
        if FlyConnection then
            pcall(function() FlyConnection:Disconnect() end)
            FlyConnection = nil
        end
        
        -- حذف BodyVelocity
        for _, child in pairs(hrp:GetChildren()) do
            if child.Name == "HevenFlyBV" then
                child:Destroy()
            end
        end
        
        -- إرجاع الحالة الطبيعية
        task.spawn(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

-- متغير للتوافق
local FlySystem = {
    Enabled = false,
    Speed = 50
}

local FlyFunction = function(enabled, speed)
    FlySystem.Enabled = enabled
    FlySystem.Speed = speed or 50
    FlySpeed = speed or 50
    ToggleFly(enabled, speed)
end


local FlyFunction = SetupFly()

-- إنشاء النافذة
local Window = Heven:CreateWindow({
    Title = "Heven Menu",
    SubTitle = "",
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

local PingParagraph = ServerSection:AddParagraph({
    Title = "بينق السيرفر",
    Content = "جاري القياس..."
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

MovementSection:AddKeybind("InfiniteJumpKey", {
    Title = "زر القفز اللانهائي",
    Description = "اضغط لتفعيل/تعطيل",
    Default = "J",
    Callback = function()
        local current = getgenv().HevenMenu.InfiniteJump
        getgenv().HevenMenu.InfiniteJump = not current
        Heven.Options.InfiniteJump:SetValue(not current)
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

FlySection:AddKeybind("FlyKey", {
    Title = "زر الطيران",
    Description = "اضغط لتفعيل/تعطيل",
    Default = "F",
    Callback = function()
        local current = getgenv().HevenMenu.Flying
        getgenv().HevenMenu.Flying = not current
        Heven.Options.Fly:SetValue(not current)
        FlyFunction(not current, Heven.Options.FlySpeed.Value or 50)
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
        FlySystem.Speed = Value
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

NoclipSection:AddKeybind("NoclipKey", {
    Title = "زر الاختراق",
    Description = "اضغط لتفعيل/تعطيل",
    Default = "N",
    Callback = function()
        local current = getgenv().HevenMenu.Noclip
        getgenv().HevenMenu.Noclip = not current
        Heven.Options.Noclip:SetValue(not current)
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

-- دالة لإنشاء ESP للاعب
local function CreateESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoidRootPart or not head then return end
    
    -- حذف ESP القديم
    local oldESP = character:FindFirstChild("HevenESPBox")
    local oldName = head:FindFirstChild("HevenESPName")
    if oldESP then oldESP:Destroy() end
    if oldName then oldName:Destroy() end
    
    -- ESP Names
    if getgenv().HevenMenu.ESPNames then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HevenESPName"
        billboard.Size = UDim2.new(0, 150, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.Parent = billboard
    end
    
    -- ESP Box
    if getgenv().HevenMenu.ESPBox then
        local highlight = Instance.new("Highlight")
        highlight.Name = "HevenESPBox"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end
end

-- دالة لحذف ESP
local function RemoveESP(player)
    if player.Character then
        local esp = player.Character:FindFirstChild("HevenESPBox")
        local name = player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("HevenESPName")
        if esp then esp:Destroy() end
        if name then name:Destroy() end
    end
end

-- تحديث ESP لكل اللاعبين
local function UpdateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        RemoveESP(player)
        if getgenv().HevenMenu.ESPNames or getgenv().HevenMenu.ESPBox then
            CreateESP(player)
        end
    end
end

getgenv().HevenMenu.ESPNames = false
getgenv().HevenMenu.ESPBox = false

ESPSection:AddToggle("ESPNames", {
    Title = "إظهار الأسماء",
    Description = "اظهر أسماء اللاعبين فوق رؤوسهم",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.ESPNames = Value
        UpdateAllESP()
    end
})

ESPSection:AddToggle("ESPBox", {
    Title = "ESP شفاف",
    Description = "اظهر اللاعبين بهايلايت أبيض شفاف",
    Default = false,
    Callback = function(Value)
        getgenv().HevenMenu.ESPBox = Value
        UpdateAllESP()
    end
})

-- تحديث ESP عند دخول لاعب جديد
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().HevenMenu.ESPNames or getgenv().HevenMenu.ESPBox then
            CreateESP(player)
        end
    end)
end)

-- تحديث ESP عند ظهور شخصية لاعب موجود
for _, player in pairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().HevenMenu.ESPNames or getgenv().HevenMenu.ESPBox then
            CreateESP(player)
        end
    end)
end


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
        -- إيقاف كل الـ loops
        getgenv().HevenMenuRunning = false
        
        -- إيقاف الطيران
        pcall(function()
            FlyEnabled = false
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in pairs(hrp:GetChildren()) do
                    if child.Name == "HevenFlyBV" then child:Destroy() end
                end
            end
        end)
        
        -- إيقاف باقي الميزات
        getgenv().HevenMenu.Flying = false
        getgenv().HevenMenu.Noclip = false
        getgenv().HevenMenu.InfiniteJump = false
        getgenv().HevenMenu.Fullbright = false
        getgenv().HevenMenu.ESPNames = false
        getgenv().HevenMenu.ESPBox = false
        
        -- إرجاع الإضاءة
        pcall(function()
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Camera.FieldOfView = 70
        end)
        
        -- إزالة ESP
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local espBox = player.Character:FindFirstChild("HevenESPBox")
                    if espBox then espBox:Destroy() end
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        for _, child in pairs(head:GetChildren()) do
                            if child.Name:match("ESP") then child:Destroy() end
                        end
                    end
                end
            end
        end)
        
        -- حذف المنيو
        pcall(function()
            Heven:Destroy()
        end)
    end
})

-- متغير للتحكم بالـ loops
getgenv().HevenMenuRunning = true

-- تحديث وقت التشغيل والبينق
task.spawn(function()
    while getgenv().HevenMenuRunning and task.wait(1) do
        pcall(function()
            if UptimeParagraph then
                UptimeParagraph:SetDesc(GetUptime())
            end
            if PingParagraph then
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                PingParagraph:SetDesc(tostring(ping) .. " ms")
            end
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
