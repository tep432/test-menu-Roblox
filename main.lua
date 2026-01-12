--[[
    Heaven Menu - Fluent UI
    by tep432
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Heaven Menu",
    SubTitle = "by tep432",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift,
    DisableMaximize = true,
    DisableResize = true
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

Window:SelectTab(1)

Fluent:Notify({
    Title = "Heaven Menu",
    Content = "Loaded!",
    Duration = 3
})
