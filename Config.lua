-- Crypt-MM2-Legit | Config
-- IMAGE IDs: create.roblox.com > Create > Development Items > Images
-- Upload your PNG there, copy the NUMBER from the URL — use rbxassetid://NUMBER

_G.Config = {
    BackgroundDecal    = "0",   -- replace 0 with your Image ID
    MinimizeIconDecal  = "0",   -- replace 0 with your Image ID

        -- In Config.lua add:
    Backgrounds = {
        {Name = "Default Dark",  Id = "0"},
        {Name = "Dark Anime Girl", Id = "rbxassetid://10341849885"},
        {Name = "Smiling Dark Anime Girl", Id = "rbxassetid://6311243701"},
        {Name = "Aesthetic Dark Anime Girl", Id = "rbxassetid://10039645009"},
        {Name = "Scary Smily Face", Id = "rbxassetid://7255938910"},
        {Name = "Funny Troll Face", Id = "rbxassetid://73840582821028"},
        {Name = "Chainsaw Man Girl", Id = "rbxassetid://11778372953"},
        -- Add more: {Name = "Name", Id = "rbxassetid://ID"},
    },
    ActiveBackground = 1,  -- index into Backgrounds table

    MinimizeIcons = {
        {Name = "Default",    Id = "0"},
        {Name = "Black Hair Anime Girl",    Id = "rbxassetid://7043301688"},
        {Name = "Anime Girl Heart Eye",    Id = "rbxassetid://8942361531"},
        {Name = "Aesthetic Pink Anime Girl",    Id = "rbxassetid://10983517742"},
        {Name = "Scary White Face",    Id = "rbxassetid://1452754142"},
        {Name = "Funny Weird Face",    Id = "rbxassetid://668752955"},
    },
    ActiveMinimizeIcon = 1,

    Icon_Main          = "rbxassetid://13060262582",
    Icon_Aimbot        = "rbxassetid://11738671951",
    Icon_Visuals       = "rbxassetid://13321848342",
    Icon_LocalPlayer   = "rbxassetid://124871982298256",
    Icon_Murderer      = "rbxassetid://6187718258",
    Icon_Sheriff       = "rbxassetid://15571371474",
    Icon_Farm          = "rbxassetid://3609651069",
    Icon_Teleport      = "rbxassetid://6723742959",
    Icon_Settings      = "rbxassetid://11932591121",

    ToggleKey          = Enum.KeyCode.RightControl,
    WindowSize         = UDim2.new(0, 560, 0, 440),
    IconSize           = UDim2.new(0, 54, 0, 54),
    StartPosition      = UDim2.new(0.5, -280, 0.5, -220),
}
