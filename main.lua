--[[
    Heaven Menu
]]

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/tep432/test-menu-Roblox/main/Heven.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Heaven Menu",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift
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
