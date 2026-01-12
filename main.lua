--[[
    Heven Menu
]]

local Heven = loadstring(game:HttpGet("https://raw.githubusercontent.com/tep432/test-menu-Roblox/main/Heven.lua"))()

local Window = Heven:CreateWindow({
    Title = "Heven Menu",
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

Heven:Notify({
    Title = "Heven Menu",
    Content = "Loaded!",
    Duration = 3
})
