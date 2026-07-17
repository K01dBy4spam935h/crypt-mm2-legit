-- Visuals tab: Round timer drawing

local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera

local timerLbl = Drawing.new("Text"); timerLbl.Size=20; timerLbl.Font=Drawing.Fonts.Plex
timerLbl.Center=true; timerLbl.Outline=true; timerLbl.Color=Color3.fromRGB(255,255,255)
timerLbl.Visible=false; timerLbl.Transparency=1

local roundTimeLeft=0; local roundTimerActive=false; local lastRoundActive=false

task.spawn(function()
    while task.wait(0.1) do
        local nowActive=_G.RoundActive or false
        if nowActive and not lastRoundActive then
            roundTimeLeft=180; roundTimerActive=true
        elseif not nowActive and lastRoundActive then
            roundTimerActive=false; roundTimeLeft=0
        end
        lastRoundActive=nowActive
        if roundTimerActive and roundTimeLeft>0 then
            roundTimeLeft=roundTimeLeft-0.1
        elseif roundTimerActive and roundTimeLeft<=0 then
            roundTimerActive=false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.ShowRoundTimer or not roundTimerActive or roundTimeLeft<=0 then timerLbl.Visible=false; return end
    local secs=math.max(0,math.floor(roundTimeLeft)); local mins=math.floor(secs/60); local rem=secs%60
    timerLbl.Text=string.format("⏱  %d:%02d",mins,rem)
    timerLbl.Position=Vector2.new(camera.ViewportSize.X/2,22)
    timerLbl.Color=secs<=30 and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,255,255)
    timerLbl.Visible=true
end)
