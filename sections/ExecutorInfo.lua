-- Main tab: Welcome + Server + Executor sections

local Players = game:GetService("Players")
local Stats   = game:GetService("Stats")
local lp      = Players.LocalPlayer
local page    = _G.Pages["Main"].page

-- Welcome
local wS = _G.UI:MakeSection(page, "Welcome", 1)
local wL = _G.UI:Label(wS, "Welcome,  " .. lp.DisplayName, 1)
wL.TextSize = 16; wL.Font = Enum.Font.GothamBold; wL.TextColor3 = Color3.fromRGB(255,255,255); wL.Size = UDim2.new(1,0,0,24)
_G.UI:Label(wS, "@" .. lp.Name, 2)
_G.UI:Label(wS, "Created by Crypt0", 3)

-- Executor
local execS = _G.UI:MakeSection(page, "Executor", 2)
local execL  = _G.UI:Label(execS, "Your Executor:  detecting…", 1)

local uncFns = {
    "firetouchinterest","fireclickdetector","getconnections","getrawmetatable",
    "setreadonly","hookfunction","newcclosure","clonefunction","decompile",
    "getscripts","getsenv","writefile","readfile","setidentity","setthreadidentity",
    "getthreadidentity","Drawing","getgenv","getrenv","getreg","mouse1click",
    "mouse2click","keypress","keyrelease","getconnections"
}
local uncPass = 0
for _, fn in ipairs(uncFns) do
    pcall(function()
        local env = (getgenv and getgenv()) or {}
        if env[fn] ~= nil or _G[fn] ~= nil then uncPass = uncPass + 1 end
    end)
end
uncPass = math.min(uncPass, #uncFns)
local uncPct = math.floor((uncPass / #uncFns) * 100)
local compat, compatCol
if uncPct>=85 then compat="Excellent"; compatCol=Color3.fromRGB(60,200,80)
elseif uncPct>=65 then compat="Good"; compatCol=Color3.fromRGB(100,200,255)
elseif uncPct>=45 then compat="Fair"; compatCol=Color3.fromRGB(240,170,50)
else compat="Poor"; compatCol=Color3.fromRGB(220,70,70) end

local uncL = _G.UI:Label(execS, "UNC:  " .. uncPct .. "% — " .. compat, 2)
uncL.TextColor3 = compatCol
local compatL = _G.UI:Label(execS, "Compatibility:  " .. compat, 3)
compatL.TextColor3 = compatCol

task.spawn(function()
    task.wait(0.8)
    execL.Text = "Your Executor:  " .. (_G.DetectedExecutor or "Unknown")
end)

-- Server
local srvS = _G.UI:MakeSection(page, "Server", 3)
local serverType = game.PrivateServerId ~= "" and "Private Server" or "Public Server"
_G.UI:Label(srvS, "Type:  " .. serverType, 0)

local jobLbl   = _G.UI:CopyRow(srvS, "Job ID:    …",    function() return game.JobId    end, 1)
local placeLbl = _G.UI:CopyRow(srvS, "Place ID:  …",    function() return game.PlaceId  end, 2)
local countLbl = _G.UI:CopyRow(srvS, "Players:   …",    function() return #Players:GetPlayers().."/"..Players.MaxPlayers end, 3)
local pingLbl  = _G.UI:CopyRow(srvS, "Ping:      …",    function()
    local ok,v=pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    return ok and (v.." ms") or "N/A"
end, 4)

-- Role indicator
local roleS = _G.UI:MakeSection(page, "Your Role", 4)
local roleLbl = _G.UI:Label(roleS, "Role:  detecting…", 1)
roleLbl.TextSize = 14; roleLbl.Font = Enum.Font.GothamBold

task.spawn(function()
    while task.wait(0.5) do
        local r = _G.MyRole or "Unknown"
        if r=="Murderer" then roleLbl.Text="🔴 MURDERER"; roleLbl.TextColor3=Color3.fromRGB(255,70,70)
        elseif r=="Sheriff" then roleLbl.Text="🔵 SHERIFF"; roleLbl.TextColor3=Color3.fromRGB(60,200,255)
        elseif r=="Innocent" then roleLbl.Text="⚪ INNOCENT"; roleLbl.TextColor3=Color3.fromRGB(200,200,200)
        else roleLbl.Text="Role:  detecting…"; roleLbl.TextColor3=Color3.fromRGB(150,150,150) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            jobLbl.Text   = "Job ID:    " .. tostring(game.JobId):sub(1,22) .. "…"
            placeLbl.Text = "Place ID:  " .. tostring(game.PlaceId)
            countLbl.Text = "Players:   " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            local ok,v=pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            pingLbl.Text  = "Ping:      " .. (ok and (v.." ms") or "N/A")
        end)
    end
end)
