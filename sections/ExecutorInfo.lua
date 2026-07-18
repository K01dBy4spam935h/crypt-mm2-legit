-- Main tab: Welcome + Server + Executor + Module Health

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

-- Role indicator
local roleS = _G.UI:MakeSection(page, "Your Role", 2)
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

-- Executor + compatibility
local execS = _G.UI:MakeSection(page, "Executor", 3)
local execL = _G.UI:Label(execS, "Your Executor:  detecting…", 1)

local uncFns = {
    "firetouchinterest","fireclickdetector","getconnections","getrawmetatable",
    "setreadonly","hookfunction","newcclosure","clonefunction","decompile",
    "getscripts","getsenv","writefile","readfile","setidentity","setthreadidentity",
    "getthreadidentity","Drawing","getgenv","getrenv","getreg","mouse1click",
    "mouse2click","keypress","keyrelease","hookmetamethod","checkcaller"
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
if uncPct>=90 then compat="Excellent (Full Support)"; compatCol=Color3.fromRGB(60,200,80)
elseif uncPct>=70 then compat="Good (Most Features)"; compatCol=Color3.fromRGB(100,200,255)
elseif uncPct>=50 then compat="Fair (Some Limits)"; compatCol=Color3.fromRGB(240,170,50)
else compat="Poor (Major Limits)"; compatCol=Color3.fromRGB(220,70,70) end

local uncL = _G.UI:Label(execS, "UNC:  "..uncPct.."% ("..uncPass.."/"..#uncFns..")", 2)
uncL.TextColor3 = compatCol
local compatL = _G.UI:Label(execS, "Compat:  "..compat, 3)
compatL.TextColor3 = compatCol

-- Key feature availability
local featS = _G.UI:MakeSection(page, "Feature Availability", 4)
local features = {
    {"Silent Aim Hook",    function() return hookmetamethod ~= nil and checkcaller ~= nil end},
    {"Touch Simulation",   function() return firetouchinterest ~= nil end},
    {"Drawing API",        function() return Drawing ~= nil end},
    {"File System",        function() return writefile ~= nil and readfile ~= nil end},
    {"Identity Spoof",     function() return setidentity ~= nil or setthreadidentity ~= nil end},
    {"Clipboard",          function() return setclipboard ~= nil end},
}
for i, feat in ipairs(features) do
    local avail = pcall(function() return feat[2]() end) and feat[2]()
    local fl = _G.UI:Label(featS, (avail and "✓ " or "✕ ") .. feat[1], i)
    fl.TextColor3 = avail and Color3.fromRGB(80,200,80) or Color3.fromRGB(200,80,80)
end

-- Module health checker
local modS = _G.UI:MakeSection(page, "Module Health", 5)
local modSummaryL = _G.UI:Label(modS, "Loading module report…", 1)

task.spawn(function()
    task.wait(3)  -- wait for all modules to finish loading and verification
    local execName = _G.DetectedExecutor or "Unknown"
    execL.Text = "Your Executor:  " .. execName

    if not _G.ModuleStatus then
        modSummaryL.Text = "Module status unavailable"
        return
    end

    local total, ok, fail, crash, silent = 0, 0, 0, 0, 0
    for name, status in pairs(_G.ModuleStatus) do
        total = total + 1
        if status.loaded and not status.crashed then
            ok = ok + 1
        elseif status.crashed and status.loaded then
            silent = silent + 1
        elseif status.crashed then
            crash = crash + 1
        else
            fail = fail + 1
        end
    end

    modSummaryL.Text = string.format("Modules: %d/%d OK  |  %d fail  |  %d crash  |  %d silent", ok, total, fail, crash, silent)
    if ok == total then
        modSummaryL.TextColor3 = Color3.fromRGB(80,200,80)
    elseif crash > 0 or fail > 0 then
        modSummaryL.TextColor3 = Color3.fromRGB(220,70,70)
    else
        modSummaryL.TextColor3 = Color3.fromRGB(240,170,50)
    end

    -- Individual module status rows for any that aren't clean
    local order = 2
    for name, status in pairs(_G.ModuleStatus) do
        if not status.loaded or status.crashed then
            local state = status.crashed and (status.loaded and "SILENT" or "CRASH") or "FAIL"
            local fl = _G.UI:Label(modS, state .. ": " .. name, order)
            fl.TextColor3 = state=="SILENT" and Color3.fromRGB(240,170,50) or Color3.fromRGB(220,70,70)
            if status.error then
                local el = _G.UI:Label(modS, "  → " .. tostring(status.error):sub(1,60), order+1)
                el.TextColor3 = Color3.fromRGB(160,100,100); el.TextSize = 10
                order = order + 1
            end
            order = order + 1
        end
    end
end)

-- Server info
local srvS = _G.UI:MakeSection(page, "Server", 6)
local serverType = game.PrivateServerId ~= "" and "Private Server" or "Public Server"
_G.UI:Label(srvS, "Type:  " .. serverType, 0)
local jobLbl   = _G.UI:CopyRow(srvS, "Job ID:    …",   function() return game.JobId   end, 1)
local placeLbl = _G.UI:CopyRow(srvS, "Place ID:  …",   function() return game.PlaceId end, 2)
local countLbl = _G.UI:CopyRow(srvS, "Players:   …",   function() return #Players:GetPlayers().."/"..Players.MaxPlayers end, 3)
local pingLbl  = _G.UI:CopyRow(srvS, "Ping:      …",   function()
    local ok,v=pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    return ok and (v.." ms") or "N/A"
end, 4)

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
