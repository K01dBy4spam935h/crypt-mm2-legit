-- Crypt-MM2-Legit | Round Timer
-- Reads MM2's own PlayerGui.MainGui.Game.Timer — 100% accurate
-- Falls back to our own 180s countdown if not found

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer
local camera     = workspace.CurrentCamera

local timerLbl = Drawing.new("Text")
timerLbl.Size        = 18
timerLbl.Font        = Drawing.Fonts.Plex
timerLbl.Center      = true
timerLbl.Outline     = true
timerLbl.Color       = Color3.fromRGB(255, 255, 255)
timerLbl.Visible     = false
timerLbl.Transparency = 1

-- Fallback countdown (only used if MM2's own timer isn't found)
local fallbackTime   = 0
local fallbackActive = false
local lastRoundState = false

task.spawn(function()
    while task.wait(0.1) do
        local now = _G.RoundActive or false
        if now and not lastRoundState then
            fallbackTime   = 180
            fallbackActive = true
        elseif not now and lastRoundState then
            fallbackActive = false; fallbackTime = 0
        end
        lastRoundState = now
        if fallbackActive and fallbackTime > 0 then
            fallbackTime = fallbackTime - 0.1
        end
    end
end)

-- Reads MM2's real timer text (exact path from reference)
local function getMM2TimerText()
    local localGui  = lp:FindFirstChild("PlayerGui"); if not localGui then return nil end
    local mainGui   = localGui:FindFirstChild("MainGui"); if not mainGui then return nil end
    local gameUI    = mainGui:FindFirstChild("Game"); if not gameUI then return nil end
    local timerText = gameUI:FindFirstChild("Timer")
    if timerText and timerText:IsA("TextLabel") then
        return timerText.Text
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not _G.ShowRoundTimer then timerLbl.Visible = false; return end

    local vp = camera.ViewportSize
    -- Position: BOTTOM of screen above the hint text, not in the way of the main UI
    timerLbl.Position = Vector2.new(vp.X / 2, vp.Y - 32)

    local mm2Text = getMM2TimerText()

    if mm2Text then
        -- Use MM2's exact timer — perfectly accurate
        local text = mm2Text:upper()
        if text == "00:00" or text:find("LOBBY") or text:find("WAITING") then
            -- Round ended
            timerLbl.Visible = false
            if _G.RoundActive then
                _G.RoundActive = false
                _G.MyRole = nil
                _G.RoleCache = {}
            end
            return
        end
        timerLbl.Text    = "⏱  " .. mm2Text
        timerLbl.Color   = (mm2Text:find("^0:") or mm2Text:find("^00:0")) 
            and Color3.fromRGB(255, 80, 80) 
            or  Color3.fromRGB(255, 255, 255)
        timerLbl.Visible = true
    elseif fallbackActive and fallbackTime > 0 then
        -- Fallback countdown
        local secs = math.max(0, math.floor(fallbackTime))
        local mins = math.floor(secs / 60); local rem = secs % 60
        timerLbl.Text    = string.format("⏱  %d:%02d", mins, rem)
        timerLbl.Color   = secs <= 30 and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
        timerLbl.Visible = true
    else
        timerLbl.Visible = false
    end
end)
