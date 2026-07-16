-- Crypt-MM2-Legit | UI

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInput       = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local InsertService   = game:GetService("InsertService")
local Stats           = game:GetService("Stats")
local RunService      = game:GetService("RunService")
local lp              = Players.LocalPlayer

local cfg        = _G.Config or {}
local TOGGLE_KEY = cfg.ToggleKey     or Enum.KeyCode.RightControl
local WIN_SIZE   = cfg.WindowSize    or UDim2.new(0, 560, 0, 440)
local ICON_SIZE  = cfg.IconSize      or UDim2.new(0, 54, 0, 54)
local START_POS  = cfg.StartPosition or UDim2.new(0.5, -280, 0.5, -220)

-- ── Executor Detector ─────────────────────────────────────────────────────────

local function detectExecutor()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return tostring(name) end
    end
    if getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name then return tostring(name) end
    end
    local score = 0
    if hookfunction      then score = score + 2 end
    if newcclosure       then score = score + 2 end
    if writefile         then score = score + 1 end
    if readfile          then score = score + 1 end
    if setfpscap         then score = score + 1 end
    if getrawmetatable   then score = score + 1 end
    if Drawing           then score = score + 1 end
    if firetouchinterest then score = score + 2 end
    if hookmetamethod    then score = score + 1 end
    if score >= 9 then return "Synapse-class (high tier)" end
    if score >= 5 then return "Mid-tier executor"         end
    if score >= 2 then return "Basic executor"            end
    return "Unknown"
end

local executorName = detectExecutor()

-- ── Image Loader — auto-resolves Decal IDs to Image IDs ──────────────────────

local function loadImage(label, rawId)
    if not rawId then return end
    local cleanId = tostring(rawId):match("%d+")
    if not cleanId or cleanId == "0" then return end

    -- rbxthumb format — works reliably from executor context
    label.Image = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"

    -- Listen for load confirmation
    label:GetPropertyChangedSignal("IsLoaded"):Connect(function()
        if label.IsLoaded then
            print("[Crypt] Image loaded: " .. cleanId)
        end
    end)

    -- Fallback: try direct rbxassetid after 3s if thumb didn't load
    task.delay(3, function()
        if not label.IsLoaded then
            label.Image = "rbxassetid://" .. cleanId
        end
    end)
end

-- ── Screen GUI ────────────────────────────────────────────────────────────────

local gui = Instance.new("ScreenGui")
gui.Name           = "CryptMM2"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.Parent         = lp:WaitForChild("PlayerGui")

-- ── Main Window ───────────────────────────────────────────────────────────────

local main = Instance.new("Frame")
main.Name                   = "Main"
main.Size                   = WIN_SIZE
main.Position               = START_POS
main.BackgroundColor3       = Color3.fromRGB(8, 8, 12)
main.BackgroundTransparency = 0
main.BorderSizePixel        = 0
main.Active                 = true
main.Draggable              = true
main.ClipsDescendants       = true
main.Parent                 = gui

local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0,14); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(255,255,255); ms.Thickness = 1.5; ms.Transparency = 0.65; ms.Parent = main

-- Background image
local bgImg = Instance.new("ImageLabel")
bgImg.Image                  = ""
bgImg.Size                   = UDim2.new(1,0,1,0)
bgImg.BackgroundTransparency = 1
bgImg.ImageTransparency      = 0
bgImg.ScaleType              = Enum.ScaleType.Stretch
bgImg.ZIndex                 = 1
bgImg.Parent                 = main
if cfg.BackgroundDecal then loadImage(bgImg, cfg.BackgroundDecal) end

local wash = Instance.new("Frame"); wash.Size=UDim2.new(1,0,1,0); wash.BackgroundColor3=Color3.fromRGB(0,0,0); wash.BackgroundTransparency=0.5; wash.BorderSizePixel=0; wash.ZIndex=2; wash.Parent=main
local wc = Instance.new("UICorner"); wc.CornerRadius=UDim.new(0,14); wc.Parent=wash

-- ── Title Bar ─────────────────────────────────────────────────────────────────

local tb = Instance.new("Frame"); tb.Size=UDim2.new(1,0,0,40); tb.BackgroundColor3=Color3.fromRGB(0,0,0); tb.BackgroundTransparency=0.35; tb.BorderSizePixel=0; tb.ZIndex=5; tb.Parent=main
local tbc = Instance.new("UICorner"); tbc.CornerRadius=UDim.new(0,14); tbc.Parent=tb
local tbsq = Instance.new("Frame"); tbsq.Size=UDim2.new(1,0,0,14); tbsq.Position=UDim2.new(0,0,1,-14); tbsq.BackgroundColor3=Color3.fromRGB(0,0,0); tbsq.BackgroundTransparency=0.35; tbsq.BorderSizePixel=0; tbsq.ZIndex=5; tbsq.Parent=tb

local titleLbl = Instance.new("TextLabel"); titleLbl.Text="⚰  Crypt MM2"; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=14; titleLbl.TextColor3=Color3.fromRGB(255,255,255); titleLbl.BackgroundTransparency=1; titleLbl.Size=UDim2.new(1,-90,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=6; titleLbl.Parent=tb

local accentLine = Instance.new("Frame"); accentLine.Size=UDim2.new(1,0,0,1); accentLine.Position=UDim2.new(0,0,0,40); accentLine.BackgroundColor3=Color3.fromRGB(255,255,255); accentLine.BackgroundTransparency=0.8; accentLine.BorderSizePixel=0; accentLine.ZIndex=4; accentLine.Parent=main

-- ── Circle buttons ────────────────────────────────────────────────────────────

local function circBtn(col, xOff)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,14,0,14); b.Position=UDim2.new(1,xOff,0.5,-7); b.BackgroundColor3=col; b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.ZIndex=9; b.Parent=tb
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.35}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    return b
end
local closeBtn = circBtn(Color3.fromRGB(220,55,55), -28)
local minBtn   = circBtn(Color3.fromRGB(230,130,30),-48)

-- ── Minimized Icon ────────────────────────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size=ICON_SIZE; iconFrame.Position=START_POS; iconFrame.BackgroundColor3=Color3.fromRGB(10,10,14); iconFrame.BackgroundTransparency=0; iconFrame.BorderSizePixel=0; iconFrame.Active=true; iconFrame.Visible=false; iconFrame.ZIndex=20; iconFrame.Parent=gui
local ifc=Instance.new("UICorner"); ifc.CornerRadius=UDim.new(0,12); ifc.Parent=iconFrame
local ifs=Instance.new("UIStroke"); ifs.Color=Color3.fromRGB(255,255,255); ifs.Thickness=1; ifs.Transparency=0.65; ifs.Parent=iconFrame

local iconImg=Instance.new("ImageLabel"); iconImg.Image=""; iconImg.Size=UDim2.new(1,-8,1,-8); iconImg.Position=UDim2.new(0,4,0,4); iconImg.BackgroundTransparency=1; iconImg.ScaleType=Enum.ScaleType.Fit; iconImg.ZIndex=21; iconImg.Parent=iconFrame
if cfg.MinimizeIconDecal then loadImage(iconImg, cfg.MinimizeIconDecal) end

-- Manual drag — cursor stays centered on icon
local iconDrag = {active=false, offX=0, offY=0, moved=false}

iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    iconDrag.active = true
    iconDrag.moved  = false
    -- Center offset so cursor is in middle of icon
    iconDrag.offX   = iconFrame.AbsoluteSize.X / 2
    iconDrag.offY   = iconFrame.AbsoluteSize.Y / 2
end)

iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if iconDrag.active and not iconDrag.moved then
        iconFrame.Visible = false; main.Position = iconFrame.Position; main.Visible = true; _G._CryptMinimized = false
    end
    iconDrag.active = false
end)

UserInput.InputChanged:Connect(function(input)
    if not iconDrag.active or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    iconDrag.moved = true
    local mp = UserInput:GetMouseLocation()
    iconFrame.Position = UDim2.fromOffset(mp.X - iconDrag.offX, mp.Y - iconDrag.offY)
end)

-- ── Minimize / Close ──────────────────────────────────────────────────────────

_G._CryptMinimized = false

local function minimize()
    _G._CryptMinimized=true; iconFrame.Position=main.Position; main.Visible=false; iconFrame.Visible=true
end
local function restore()
    _G._CryptMinimized=false; main.Position=iconFrame.Position; iconFrame.Visible=false; main.Visible=true
end

minBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Dynamic keybind support
_G.ToggleKeyCode = TOGGLE_KEY
UserInput.InputBegan:Connect(function(input, gp)
    if gp or (iconDrag.active and not iconDrag.moved) then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    -- Check if rebinding
    if _G._BindingKey then return end
    if input.KeyCode == (_G.ToggleKeyCode or TOGGLE_KEY) then
        if _G._CryptMinimized then restore() else minimize() end
    end
end)

-- ── Notification System ───────────────────────────────────────────────────────

local notifContainer = Instance.new("Frame")
notifContainer.Size                   = UDim2.new(0, 320, 1, 0)
notifContainer.Position               = UDim2.new(1, -330, 0, 0)  -- top RIGHT
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex                 = 200
notifContainer.AutomaticSize          = Enum.AutomaticSize.None
notifContainer.Parent                 = gui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Padding           = UDim.new(0, 8)
notifLayout.Parent            = notifContainer

local notifPad = Instance.new("UIPadding")
notifPad.PaddingTop   = UDim.new(0, 14)
notifPad.PaddingRight = UDim.new(0, 10)
notifPad.Parent       = notifContainer

local notifN = 0

_G.Notify = function(msg, ntype)
    ntype = ntype or "info"
    local barColors = {
        success = Color3.fromRGB(80, 200, 100),
        error   = Color3.fromRGB(220, 70, 70),
        info    = Color3.fromRGB(130, 180, 255),
        warn    = Color3.fromRGB(240, 170, 50),
    }
    local barCol = barColors[ntype] or barColors.info
    notifN = notifN + 1

    -- Card
    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3       = Color3.fromRGB(22, 22, 26)
    card.BackgroundTransparency = 0
    card.BorderSizePixel        = 0
    card.LayoutOrder            = notifN
    card.ZIndex                 = 201
    card.ClipsDescendants       = true
    card.Parent                 = notifContainer

    local cardC = Instance.new("UICorner"); cardC.CornerRadius = UDim.new(0,10); cardC.Parent = card
    local cardS = Instance.new("UIStroke"); cardS.Color = Color3.fromRGB(60,60,66); cardS.Thickness = 1; cardS.Parent = card

    -- Left bar
    local bar = Instance.new("Frame"); bar.Size=UDim2.new(0,4,1,0); bar.BackgroundColor3=barCol; bar.BorderSizePixel=0; bar.ZIndex=202; bar.Parent=card
    local barC = Instance.new("UICorner"); barC.CornerRadius=UDim.new(0,4); barC.Parent=bar

    -- Message
    local msgL = Instance.new("TextLabel")
    msgL.Text               = msg
    msgL.Font               = Enum.Font.GothamSemibold
    msgL.TextSize           = 13
    msgL.TextColor3         = Color3.fromRGB(230, 230, 235)
    msgL.BackgroundTransparency = 1
    msgL.Size               = UDim2.new(1,-14,0,20)
    msgL.Position           = UDim2.new(0,10,0,8)
    msgL.TextXAlignment     = Enum.TextXAlignment.Left
    msgL.TextWrapped        = true
    msgL.ZIndex             = 202
    msgL.Parent             = card

    -- Type label
    local typeL = Instance.new("TextLabel")
    typeL.Text              = ntype:upper()
    typeL.Font              = Enum.Font.GothamBold
    typeL.TextSize          = 10
    typeL.TextColor3        = barCol
    typeL.BackgroundTransparency = 1
    typeL.Size              = UDim2.new(1,-14,0,14)
    typeL.Position          = UDim2.new(0,10,0,29)
    typeL.TextXAlignment    = Enum.TextXAlignment.Left
    typeL.ZIndex            = 202
    typeL.Parent            = card

    -- Cooldown bar (shrinks over 3.2s)
    local coolBg = Instance.new("Frame")
    coolBg.Size             = UDim2.new(1,-8,0,2)
    coolBg.Position         = UDim2.new(0,4,1,-3)
    coolBg.BackgroundColor3 = Color3.fromRGB(50,50,55)
    coolBg.BorderSizePixel  = 0
    coolBg.ZIndex           = 202
    coolBg.Parent           = card
    local coolBgC = Instance.new("UICorner"); coolBgC.CornerRadius=UDim.new(1,0); coolBgC.Parent=coolBg

    local coolFill = Instance.new("Frame")
    coolFill.Size             = UDim2.new(1,0,1,0)
    coolFill.BackgroundColor3 = barCol
    coolFill.BorderSizePixel  = 0
    coolFill.ZIndex           = 203
    coolFill.Parent           = coolBg
    local coolFC = Instance.new("UICorner"); coolFC.CornerRadius=UDim.new(1,0); coolFC.Parent=coolFill

    -- Slide in from right
    card.Position = UDim2.new(1,10,0,0)
    TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- Cooldown bar shrinks
    TweenService:Create(coolFill, TweenInfo.new(3.2, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(3.2, function()
        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 10, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.25)
        card:Destroy()
    end)
end

-- ── Widget Builders ───────────────────────────────────────────────────────────

local function sec(parent, text, order)
    local c=Instance.new("Frame"); c.Size=UDim2.new(1,0,0,0); c.AutomaticSize=Enum.AutomaticSize.Y; c.BackgroundColor3=Color3.fromRGB(255,255,255); c.BackgroundTransparency=0.92; c.BorderSizePixel=0; c.LayoutOrder=order or 1; c.ZIndex=5; c.Parent=parent
    local cc=Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,8); cc.Parent=c
    local cl=Instance.new("UIListLayout"); cl.Padding=UDim.new(0,3); cl.SortOrder=Enum.SortOrder.LayoutOrder; cl.Parent=c
    local cp=Instance.new("UIPadding"); cp.PaddingTop=UDim.new(0,4); cp.PaddingBottom=UDim.new(0,6); cp.PaddingLeft=UDim.new(0,6); cp.PaddingRight=UDim.new(0,6); cp.Parent=c
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,22); hdr.BackgroundTransparency=1; hdr.LayoutOrder=0; hdr.ZIndex=6; hdr.Parent=c
    local hl=Instance.new("TextLabel"); hl.Text=text:upper(); hl.Font=Enum.Font.GothamBold; hl.TextSize=10; hl.TextColor3=Color3.fromRGB(255,255,255); hl.BackgroundTransparency=1; hl.Size=UDim2.new(1,0,1,0); hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=7; hl.Parent=hdr
    local hline=Instance.new("Frame"); hline.Size=UDim2.new(1,0,0,1); hline.Position=UDim2.new(0,0,1,-1); hline.BackgroundColor3=Color3.fromRGB(255,255,255); hline.BackgroundTransparency=0.8; hline.BorderSizePixel=0; hline.ZIndex=7; hline.Parent=hdr
    return c
end

local function tog(parent, label, default, cb, order)
    default=(default==true)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundTransparency=1; row.LayoutOrder=order or 1; row.ZIndex=6; row.Parent=parent
    local lbl=Instance.new("TextLabel"); lbl.Text=label; lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextColor3=Color3.fromRGB(225,225,225); lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-50,1,0); lbl.Position=UDim2.new(0,6,0,0); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=7; lbl.Parent=row
    local track=Instance.new("Frame"); track.Size=UDim2.new(0,36,0,18); track.Position=UDim2.new(1,-40,0.5,-9); track.BackgroundColor3=default and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50); track.BorderSizePixel=0; track.ZIndex=7; track.Parent=row
    local tc=Instance.new("UICorner"); tc.CornerRadius=UDim.new(1,0); tc.Parent=track
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14); knob.Position=default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7); knob.BackgroundColor3=default and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130); knob.BorderSizePixel=0; knob.ZIndex=8; knob.Parent=track
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob
    local state=default; local ti=TweenInfo.new(0.13,Enum.EasingStyle.Quad)
    local hit=Instance.new("TextButton"); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=9; hit.Parent=row
    hit.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(track,ti,{BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50)}):Play()
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=state and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130)}):Play()
        if cb then cb(state) end
    end)
end

local function sld(parent, label, mn, mx, def, cb, order)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,46); row.BackgroundTransparency=1; row.LayoutOrder=order or 1; row.ZIndex=6; row.Parent=parent
    local lbl=Instance.new("TextLabel"); lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextColor3=Color3.fromRGB(225,225,225); lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-10,0,20); lbl.Position=UDim2.new(0,6,0,4); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=7; lbl.Parent=row
    local tbg=Instance.new("Frame"); tbg.Size=UDim2.new(1,-12,0,4); tbg.Position=UDim2.new(0,6,1,-12); tbg.BackgroundColor3=Color3.fromRGB(45,45,50); tbg.BorderSizePixel=0; tbg.ZIndex=7; tbg.Parent=row
    local tbc=Instance.new("UICorner"); tbc.CornerRadius=UDim.new(1,0); tbc.Parent=tbg
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0); fill.BackgroundColor3=Color3.fromRGB(255,255,255); fill.BorderSizePixel=0; fill.ZIndex=8; fill.Parent=tbg
    local fc=Instance.new("UICorner"); fc.CornerRadius=UDim.new(1,0); fc.Parent=fill
    local value=def; lbl.Text=label.."  "..value
    local dragging=false
    local hit=Instance.new("TextButton"); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=9; hit.Parent=row
    local function upd(input) local rel=math.clamp((input.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1); value=math.floor(mn+rel*(mx-mn)); fill.Size=UDim2.new(rel,0,1,0); lbl.Text=label.."  "..value; if cb then cb(value) end end
    hit.MouseButton1Down:Connect(function() dragging=true end)
    UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local function lbl(parent, text, order)
    local l=Instance.new("TextLabel"); l.Text=text; l.Font=Enum.Font.Gotham; l.TextSize=11; l.TextColor3=Color3.fromRGB(150,150,165); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,16); l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=order or 99; l.ZIndex=7; l.Parent=parent
    return l
end

local function copyRow(parent, labelText, getValue, order)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.LayoutOrder=order or 1; row.ZIndex=6; row.Parent=parent
    local lbl2=Instance.new("TextLabel"); lbl2.Text=labelText; lbl2.Font=Enum.Font.Gotham; lbl2.TextSize=11; lbl2.TextColor3=Color3.fromRGB(175,175,190); lbl2.BackgroundTransparency=1; lbl2.Size=UDim2.new(1,-54,1,0); lbl2.Position=UDim2.new(0,4,0,0); lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.ZIndex=7; lbl2.Parent=row
    local cb=Instance.new("TextButton"); cb.Size=UDim2.new(0,46,0,20); cb.Position=UDim2.new(1,-48,0.5,-10); cb.BackgroundColor3=Color3.fromRGB(255,255,255); cb.BackgroundTransparency=0.82; cb.BorderSizePixel=0; cb.Font=Enum.Font.GothamBold; cb.TextSize=10; cb.TextColor3=Color3.fromRGB(255,255,255); cb.Text="COPY"; cb.AutoButtonColor=false; cb.ZIndex=8; cb.Parent=row
    local cc=Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,5); cc.Parent=cb
    cb.MouseButton1Click:Connect(function() pcall(function() setclipboard(tostring(getValue())) end); cb.Text="✓"; lbl2.TextColor3=Color3.fromRGB(60,200,80); task.delay(1.5,function() cb.Text="COPY"; lbl2.TextColor3=Color3.fromRGB(175,175,190) end) end)
    return lbl2
end

local function makeTpBtn(parent, label, order, action)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,34); row.BackgroundTransparency=1; row.LayoutOrder=order; row.ZIndex=6; row.Parent=parent
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,28); btn.BackgroundColor3=Color3.fromRGB(255,255,255); btn.BackgroundTransparency=0.88; btn.BorderSizePixel=0; btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3=Color3.fromRGB(225,225,225); btn.Text=label; btn.ZIndex=7; btn.Parent=row
    local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,7); bc.Parent=btn
    btn.MouseButton1Click:Connect(action)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.7}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.88}):Play() end)
end

-- ── Sidebar ───────────────────────────────────────────────────────────────────

local sidebar=Instance.new("Frame"); sidebar.Size=UDim2.new(0,118,1,-42); sidebar.Position=UDim2.new(0,0,0,41); sidebar.BackgroundColor3=Color3.fromRGB(0,0,0); sidebar.BackgroundTransparency=0.5; sidebar.BorderSizePixel=0; sidebar.ZIndex=4; sidebar.Parent=main
local sl=Instance.new("UIListLayout"); sl.Padding=UDim.new(0,4); sl.HorizontalAlignment=Enum.HorizontalAlignment.Center; sl.Parent=sidebar
local sp=Instance.new("UIPadding"); sp.PaddingTop=UDim.new(0,8); sp.PaddingLeft=UDim.new(0,5); sp.PaddingRight=UDim.new(0,5); sp.Parent=sidebar
local sdiv=Instance.new("Frame"); sdiv.Size=UDim2.new(0,1,1,-42); sdiv.Position=UDim2.new(0,118,0,41); sdiv.BackgroundColor3=Color3.fromRGB(255,255,255); sdiv.BackgroundTransparency=0.82; sdiv.BorderSizePixel=0; sdiv.ZIndex=4; sdiv.Parent=main

local contentArea=Instance.new("Frame"); contentArea.Size=UDim2.new(1,-126,1,-50); contentArea.Position=UDim2.new(0,122,0,46); contentArea.BackgroundTransparency=1; contentArea.ClipsDescendants=true; contentArea.ZIndex=4; contentArea.Parent=main

-- ── Tab Builder ───────────────────────────────────────────────────────────────

local tabPages={}

local function makeTab(name, iconId)
    local btn=Instance.new("Frame"); btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=Color3.fromRGB(255,255,255); btn.BackgroundTransparency=0.92; btn.BorderSizePixel=0; btn.ZIndex=6; btn.Parent=sidebar
    local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,7); bc.Parent=btn
    local ico=Instance.new("ImageLabel"); ico.Image=""; ico.Size=UDim2.new(0,14,0,14); ico.Position=UDim2.new(0,7,0.5,-7); ico.BackgroundTransparency=1; ico.ScaleType=Enum.ScaleType.Fit; ico.ZIndex=7; ico.Parent=btn
    if iconId and iconId~="rbxassetid://0" then loadImage(ico, iconId) end
    local bLbl=Instance.new("TextLabel"); bLbl.Text=name; bLbl.Font=Enum.Font.GothamSemibold; bLbl.TextSize=11; bLbl.TextColor3=Color3.fromRGB(140,140,140); bLbl.BackgroundTransparency=1; bLbl.Size=UDim2.new(1,-26,1,0); bLbl.Position=UDim2.new(0,24,0,0); bLbl.TextXAlignment=Enum.TextXAlignment.Left; bLbl.ZIndex=7; bLbl.Parent=btn
    local click=Instance.new("TextButton"); click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1; click.Text=""; click.ZIndex=8; click.Parent=btn
    local page=Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0; page.ScrollBarThickness=2; page.ScrollBarImageColor3=Color3.fromRGB(255,255,255); page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ZIndex=5; page.Visible=false; page.Parent=contentArea
    local pl=Instance.new("UIListLayout"); pl.Padding=UDim.new(0,6); pl.SortOrder=Enum.SortOrder.LayoutOrder; pl.Parent=page
    local pp=Instance.new("UIPadding"); pp.PaddingTop=UDim.new(0,8); pp.PaddingBottom=UDim.new(0,8); pp.PaddingLeft=UDim.new(0,5); pp.PaddingRight=UDim.new(0,8); pp.Parent=page
    tabPages[name]={page=page,btn=btn,lbl=bLbl}
    click.MouseButton1Click:Connect(function()
        for _,t in pairs(tabPages) do t.page.Visible=false; t.btn.BackgroundTransparency=0.92; t.lbl.TextColor3=Color3.fromRGB(140,140,140) end
        page.Visible=true; btn.BackgroundTransparency=0.65; bLbl.TextColor3=Color3.fromRGB(255,255,255)
    end)
    return page
end

-- ── Build Tabs ────────────────────────────────────────────────────────────────

local mainPage     = makeTab("Main",        cfg.Icon_Main        or "rbxassetid://0")
local aimbotPage   = makeTab("Aimbot",      cfg.Icon_Aimbot      or "rbxassetid://0")
local visPage      = makeTab("Visuals",     cfg.Icon_Visuals     or "rbxassetid://0")
local lpPage       = makeTab("LocalPlayer", cfg.Icon_LocalPlayer or "rbxassetid://0")
local murdPage     = makeTab("Murderer",    cfg.Icon_Murderer    or "rbxassetid://0")
local sheriffPage  = makeTab("Sheriff",     cfg.Icon_Sheriff     or "rbxassetid://0")
local farmPage     = makeTab("Farm",        cfg.Icon_Farm        or "rbxassetid://0")
local tpPage       = makeTab("Teleport",    cfg.Icon_Teleport    or "rbxassetid://0")
local settingsPage = makeTab("Settings",    cfg.Icon_Settings    or "rbxassetid://0")

tabPages["Main"].page.Visible=true; tabPages["Main"].btn.BackgroundTransparency=0.65; tabPages["Main"].lbl.TextColor3=Color3.fromRGB(255,255,255)

-- ─────────────────────────────────────────────────────────────────────────────
-- MAIN TAB
-- ─────────────────────────────────────────────────────────────────────────────

local wS=sec(mainPage,"Welcome",1)
local wL=Instance.new("TextLabel"); wL.Text="Welcome,  "..lp.DisplayName; wL.Font=Enum.Font.GothamBold; wL.TextSize=16; wL.TextColor3=Color3.fromRGB(255,255,255); wL.BackgroundTransparency=1; wL.Size=UDim2.new(1,0,0,24); wL.TextXAlignment=Enum.TextXAlignment.Left; wL.LayoutOrder=1; wL.ZIndex=7; wL.Parent=wS
local uL=Instance.new("TextLabel"); uL.Text="@"..lp.Name; uL.Font=Enum.Font.Gotham; uL.TextSize=11; uL.TextColor3=Color3.fromRGB(130,130,145); uL.BackgroundTransparency=1; uL.Size=UDim2.new(1,0,0,16); uL.TextXAlignment=Enum.TextXAlignment.Left; uL.LayoutOrder=2; uL.ZIndex=7; uL.Parent=wS
local cL=Instance.new("TextLabel"); cL.Text="Created by Crypt0  |  "..executorName; cL.Font=Enum.Font.GothamBold; cL.TextSize=10; cL.TextColor3=Color3.fromRGB(90,90,110); cL.BackgroundTransparency=1; cL.Size=UDim2.new(1,0,0,14); cL.TextXAlignment=Enum.TextXAlignment.Left; cL.LayoutOrder=3; cL.ZIndex=7; cL.Parent=wS

local roleS=sec(mainPage,"Your Role",2)
local roleLbl=Instance.new("TextLabel"); roleLbl.Text="Role: detecting…"; roleLbl.Font=Enum.Font.GothamBold; roleLbl.TextSize=14; roleLbl.TextColor3=Color3.fromRGB(200,200,200); roleLbl.BackgroundTransparency=1; roleLbl.Size=UDim2.new(1,0,0,26); roleLbl.TextXAlignment=Enum.TextXAlignment.Left; roleLbl.LayoutOrder=1; roleLbl.ZIndex=7; roleLbl.Parent=roleS

task.spawn(function()
    while task.wait(0.5) do
        local r=_G.MyRole or "Unknown"
        if r=="Murderer" then roleLbl.Text="🔴 MURDERER"; roleLbl.TextColor3=Color3.fromRGB(255,70,70)
        elseif r=="Sheriff" then roleLbl.Text="🔵 SHERIFF"; roleLbl.TextColor3=Color3.fromRGB(60,200,255)
        elseif r=="Innocent" then roleLbl.Text="⚪ INNOCENT"; roleLbl.TextColor3=Color3.fromRGB(200,200,200)
        else roleLbl.Text="Role: detecting…"; roleLbl.TextColor3=Color3.fromRGB(150,150,150) end
    end
end)

local srvS=sec(mainPage,"Server",3)
local serverType="Public Server"
if game.PrivateServerId~="" then serverType="Private Server" end
local stLbl=Instance.new("TextLabel"); stLbl.Text="Type:  "..serverType; stLbl.Font=Enum.Font.Gotham; stLbl.TextSize=11; stLbl.TextColor3=Color3.fromRGB(175,175,190); stLbl.BackgroundTransparency=1; stLbl.Size=UDim2.new(1,0,0,18); stLbl.TextXAlignment=Enum.TextXAlignment.Left; stLbl.LayoutOrder=0; stLbl.ZIndex=7; stLbl.Parent=srvS
local jobLbl  =copyRow(srvS,"Job ID:    loading…", function() return game.JobId   end,1)
local placeLbl=copyRow(srvS,"Place ID:  loading…", function() return game.PlaceId end,2)
local countLbl=copyRow(srvS,"Players:   loading…", function() return #Players:GetPlayers().."/"..Players.MaxPlayers end,3)
local pingLbl =copyRow(srvS,"Ping:      loading…", function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms" end,4)

-- After roleS section:

local execS = sec(mainPage, "Executor", 4)

local execNameL = Instance.new("TextLabel"); execNameL.Text="Your Executor:  loading…"; execNameL.Font=Enum.Font.GothamBold; execNameL.TextSize=12; execNameL.TextColor3=Color3.fromRGB(230,230,230); execNameL.BackgroundTransparency=1; execNameL.Size=UDim2.new(1,0,0,18); execNameL.TextXAlignment=Enum.TextXAlignment.Left; execNameL.LayoutOrder=1; execNameL.ZIndex=7; execNameL.Parent=execS

-- UNC checker
local uncFunctions = {
    "firetouchinterest","fireclickdetector","fireproximityprompt",
    "getconnections","getrawmetatable","setreadonly","hookfunction",
    "newcclosure","clonefunction","decompile","getscripts",
    "getsenv","getcallstack","getupvalues","setupvalue",
    "writefile","readfile","listfiles","makefolder","isfile","isfolder",
    "Drawing","getgenv","getrenv","getreg",
    "setidentity","setthreadidentity","getthreadidentity",
    "mouse1click","mouse2click","keypress","keyrelease",
}

local uncPass = 0
for _, fn in ipairs(uncFunctions) do
    if _G[fn] ~= nil or (type(_G[fn]) == "function") then
        uncPass = uncPass + 1
    end
    -- Also check global env
    pcall(function()
        local env = getgenv and getgenv() or {}
        if env[fn] ~= nil then uncPass = uncPass + 1 end
    end)
end
-- Avoid double counting
uncPass = math.min(uncPass, #uncFunctions)
local uncPct = math.floor((uncPass / #uncFunctions) * 100)

-- Compatibility tier
local compat, compatCol
if uncPct >= 85 then compat="Excellent"; compatCol=Color3.fromRGB(60,200,80)
elseif uncPct >= 65 then compat="Good"; compatCol=Color3.fromRGB(100,200,255)
elseif uncPct >= 45 then compat="Fair"; compatCol=Color3.fromRGB(240,170,50)
else compat="Poor"; compatCol=Color3.fromRGB(220,70,70) end

local uncL = Instance.new("TextLabel"); uncL.Font=Enum.Font.Gotham; uncL.TextSize=11; uncL.TextColor3=compatCol; uncL.BackgroundTransparency=1; uncL.Size=UDim2.new(1,0,0,16); uncL.TextXAlignment=Enum.TextXAlignment.Left; uncL.LayoutOrder=2; uncL.ZIndex=7; uncL.Parent=execS
local compatL = Instance.new("TextLabel"); compatL.Text="Compatibility:  "..compat; compatL.Font=Enum.Font.GothamBold; compatL.TextSize=11; compatL.TextColor3=compatCol; compatL.BackgroundTransparency=1; compatL.Size=UDim2.new(1,0,0,16); compatL.TextXAlignment=Enum.TextXAlignment.Left; compatL.LayoutOrder=3; compatL.ZIndex=7; compatL.Parent=execS

task.spawn(function()
    task.wait(0.5)  -- wait for AntiDetect to run
    execNameL.Text = "Your Executor:  " .. (_G.DetectedExecutor or "Unknown")
    uncL.Text = "UNC:  " .. uncPct .. "% (" .. uncPass .. "/" .. #uncFunctions .. " functions)"
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            jobLbl.Text  ="Job ID:    "..tostring(game.JobId):sub(1,22).."…"
            placeLbl.Text="Place ID:  "..tostring(game.PlaceId)
            countLbl.Text="Players:   "..#Players:GetPlayers().."/"..Players.MaxPlayers
            pingLbl.Text ="Ping:      "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms"
        end)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- VISUALS TAB
-- ─────────────────────────────────────────────────────────────────────────────

local espS=sec(visPage,"ESP",1)
tog(espS,"Box ESP",      false,function(v) _G.BoxESP=v      end,1)
tog(espS,"Chams ESP",    false,function(v) _G.ChamsESP=v    end,2)
tog(espS,"Name ESP",     false,function(v) _G.NameESP=v     end,3)
tog(espS,"Distance ESP", false,function(v) _G.DistanceESP=v end,4)
tog(espS,"Tracers",      false,function(v) _G.Tracers=v     end,5)
tog(espS,"Gun Drop ESP", false,function(v) _G.GunESP=v      end,6)

local xhS=sec(visPage,"Crosshair",2)
tog(xhS,"Custom Crosshair", false,function(v) _G.CrosshairEnabled=v      end,1)
tog(xhS,"RGB Mode",          false,function(v) _G.CrosshairRGB=v          end,2)
tog(xhS,"Red On Player",     true, function(v) _G.CrosshairRedOnPlayer=v  end,3)
sld(xhS,"Size",      4,30,14,function(v) _G.CrosshairSize=v  end,4)
sld(xhS,"Gap",       0,12,4, function(v) _G.CrosshairGap=v   end,5)
sld(xhS,"Thickness", 1,4, 1, function(v) _G.CrosshairThick=v end,6)
sld(xhS,"Spin Speed",1,20,5, function(v) _G.CrosshairSpin=v  end,7)

local rtS = sec(visPage, "Round Info", 3)
tog(rtS, "Show Round Timer", false, function(v) _G.ShowRoundTimer = v end, 1)
tog(rtS, "Gun Drop Notifier", false, function(v) _G.GunESP = v end, 2)  -- already in ESP but toggleable here
_G.ShowRoundTimer = false

-- Round timer Drawing object (add after widget builders section)

_G.BoxESP=false;_G.ChamsESP=false;_G.NameESP=false;_G.DistanceESP=false;_G.Tracers=false;_G.GunESP=false
_G.CrosshairEnabled=false;_G.CrosshairRGB=false;_G.CrosshairRedOnPlayer=true
_G.CrosshairSize=14;_G.CrosshairGap=4;_G.CrosshairThick=1;_G.CrosshairSpin=5

-- ─────────────────────────────────────────────────────────────────────────────
-- LOCAL PLAYER TAB
-- ─────────────────────────────────────────────────────────────────────────────

local mvS=sec(lpPage,"Movement",1)
tog(mvS,"Noclip",        false,function(v) _G.NoclipEnabled=v  end,1)
tog(mvS,"Speedhack",     false,function(v) _G.SpeedEnabled=v   end,2)
tog(mvS,"Infinite Jump", false,function(v) _G.InfJumpEnabled=v end,3)
tog(mvS,"Fly",           false,function(v) _G.FlyEnabled=v; if _G.SetFly then _G.SetFly(v) end end,4)
sld(mvS,"Speed Mult", 1,100,1,  function(v) _G.SpeedMultiplier=v end,5)
sld(mvS,"Fly Speed",  10,200,60,function(v) _G.FlySpeed=v        end,6)

local invisS=sec(lpPage,"Visibility",2)
tog(invisS,"Invisibility",false,function(v) _G.InvisEnabled=v end,1)
lbl(invisS,"Reapplied every frame — wins against MM2 reset",2)
lbl(invisS,"You see white outline of self",3)

local gunS=sec(lpPage,"Auto Gun",3)
tog(gunS,"Auto Collect Gun",false,function(v) _G.AutoGun=v end,1)
lbl(gunS,"Continuous loop — grabs GunDrop instantly",2)

local afkS=sec(lpPage,"Anti-AFK",4)
tog(afkS,"Anti-AFK",false,function(v) _G.AntiAFK=v end,1)

_G.NoclipEnabled=false;_G.SpeedEnabled=false;_G.InfJumpEnabled=false
_G.FlyEnabled=false;_G.SpeedMultiplier=1;_G.FlySpeed=60
_G.InvisEnabled=false;_G.AutoGun=false;_G.AntiAFK=false

-- ─────────────────────────────────────────────────────────────────────────────
-- MURDERER TAB
-- ─────────────────────────────────────────────────────────────────────────────

local mkS=sec(murdPage,"Knife Tools",1)
tog(mkS,"Knife Aura",false,function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if not ((char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))) then
            if _G.Notify then _G.Notify("No Knife — you are not Murderer","warn") end
        end
    end
    _G.KnifeAura=v
end,1)
sld(mkS,"Aura Range",5,60,15,function(v) _G.KnifeAuraRange=v end,2)
tog(mkS,"Auto Stab",false,function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if not ((char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))) then
            if _G.Notify then _G.Notify("No Knife — you are not Murderer","warn") end
        end
    end
    _G.AutoStab=v
end,3)

local hbS=sec(murdPage,"Hitbox Expander",2)
tog(hbS,"Enable Hitbox",false,function(v) _G.HitboxEnabled=v end,1)
sld(hbS,"Hitbox Size",2,20,6,function(v) _G.HitboxSize=v end,2)
lbl(hbS,"Expands ALL parts — full spherical coverage",3)

local murdStatusS=sec(murdPage,"My Status",3)
local murdStatusLbl=lbl(murdStatusS,"Checking…",1)
task.spawn(function()
    while task.wait(1) do
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if hasKnife then murdStatusLbl.Text="✓ Knife equipped — Murderer"; murdStatusLbl.TextColor3=Color3.fromRGB(255,80,80)
        else murdStatusLbl.Text="No Knife detected"; murdStatusLbl.TextColor3=Color3.fromRGB(150,150,150) end
    end
end)

_G.KnifeAura=false;_G.KnifeAuraRange=15;_G.AutoStab=false;_G.HitboxEnabled=false;_G.HitboxSize=6

-- ─────────────────────────────────────────────────────────────────────────────
-- SHERIFF TAB
-- ─────────────────────────────────────────────────────────────────────────────

local shS=sec(sheriffPage,"Sheriff Tools",1)
tog(shS,"Show Murderer Marker",false,function(v) _G.MurdererArrow=v end,1)

local shWarn=sec(sheriffPage,"My Status",2)
local shStatusLbl=lbl(shWarn,"Checking role…",1)
task.spawn(function()
    while task.wait(1) do
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasGun  =(char and char:FindFirstChild("Gun"))   or (bp and bp:FindFirstChild("Gun"))
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if hasKnife then shStatusLbl.Text="You have: Knife (Murderer)"; shStatusLbl.TextColor3=Color3.fromRGB(255,80,80)
        elseif hasGun then shStatusLbl.Text="You have: Gun (Sheriff)"; shStatusLbl.TextColor3=Color3.fromRGB(60,210,255)
        else shStatusLbl.Text="No tool — Innocent"; shStatusLbl.TextColor3=Color3.fromRGB(180,180,180) end
    end
end)

_G.MurdererArrow=false

-- Add to sheriff tab in UI.lua:

local saS = sec(sheriffPage, "Silent Aim", 2)
tog(saS, "Enable Silent Aim", false, function(v) _G.SilentAim = v end, 1)
sld(saS, "Silent Aim Size", 5, 60, 30, function(v) _G.SilentAimSize = v end, 2)
lbl(saS, "Expands murderer hitbox — no camera movement", 3)

_G.SilentAim     = false
_G.SilentAimSize = 30

-- Aimbot section in Sheriff tab
local abShS = sec(sheriffPage, "Aimbot", 3)
tog(abShS, "Enable Aimbot",       false, function(v) _G.AimbotEnabled    = v end, 1)
tog(abShS, "Require Right Click", false, function(v) _G.AimbotRightClick = v end, 2)
sld(abShS, "Smoothing",    1, 15, 2,   function(v) _G.AimbotSmoothing = v end, 3)
sld(abShS, "FOV Radius",  20,600, 250, function(v) _G.AimbotFOV       = v end, 4)
tog(abShS, "Show FOV",    false, function(v) _G.ShowFOV = v end, 5)
tog(abShS, "FOV RGB",     false, function(v) _G.FovRGB  = v end, 6)

local tbShS = sec(sheriffPage, "Triggerbot", 4)
tog(tbShS, "Enable Triggerbot", false, function(v) _G.TriggerEnabled = v end, 1)
sld(tbShS, "Trigger FOV",    5, 100, 30, function(v) _G.TriggerFOV   = v end, 2)
sld(tbShS, "Trigger Delay",  0, 800, 180, function(v) _G.TriggerDelay = v/1000 end, 3)
-- ^ delay goes to 0 now
lbl(tbShS, "0ms = instant fire, raise for high-ping servers", 4)

-- ─────────────────────────────────────────────────────────────────────────────
-- FARM TAB
-- ─────────────────────────────────────────────────────────────────────────────

local cS=sec(farmPage,"Coin Farm",1)
tog(cS,"Auto Collect Coins",  false,function(v) _G.CoinFarm=v      end,1)
tog(cS,"Anti-Murderer Safety",true, function(v) _G.CoinAntiMurd=v  end,2)
sld(cS,"Safety Radius",5,40,15,function(v) _G.CoinSafetyRadius=v   end,3)
lbl(cS,"Noclip auto-enables during farm",4)

_G.CoinFarm=false;_G.CoinAntiMurd=true;_G.CoinSafetyRadius=15

-- ─────────────────────────────────────────────────────────────────────────────
-- TELEPORT TAB
-- ─────────────────────────────────────────────────────────────────────────────

local tpS=sec(tpPage,"Teleport",1)
makeTpBtn(tpS,"Teleport to Murderer",1,function()
    if _G.TeleportToRole then _G.TeleportToRole("Murderer") end
end)
makeTpBtn(tpS,"Teleport to Sheriff", 2,function()
    if _G.TeleportToRole then _G.TeleportToRole("Sheriff") end
end)
makeTpBtn(tpS,"Teleport to Map Center",3,function()
    if _G.TeleportToMap then _G.TeleportToMap() end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- SETTINGS TAB
-- ─────────────────────────────────────────────────────────────────────────────

local kbS=sec(settingsPage,"Keybind",1)
local kbLabel=lbl(kbS,"Toggle key:  "..(_G.ToggleKeyCode or TOGGLE_KEY).Name,1)

local kbRow=Instance.new("Frame"); kbRow.Size=UDim2.new(1,0,0,32); kbRow.BackgroundTransparency=1; kbRow.LayoutOrder=2; kbRow.ZIndex=6; kbRow.Parent=kbS
local kbBtn=Instance.new("TextButton"); kbBtn.Size=UDim2.new(1,0,0,28); kbBtn.BackgroundColor3=Color3.fromRGB(255,255,255); kbBtn.BackgroundTransparency=0.85; kbBtn.BorderSizePixel=0; kbBtn.Font=Enum.Font.GothamBold; kbBtn.TextSize=12; kbBtn.TextColor3=Color3.fromRGB(255,255,255); kbBtn.Text="Click to rebind"; kbBtn.ZIndex=7; kbBtn.Parent=kbRow
local kbBtnC=Instance.new("UICorner"); kbBtnC.CornerRadius=UDim.new(0,6); kbBtnC.Parent=kbBtn

_G._BindingKey=false
kbBtn.MouseButton1Click:Connect(function()
    if _G._BindingKey then return end
    _G._BindingKey=true; kbBtn.Text="▶ Press any key…"; kbBtn.TextColor3=Color3.fromRGB(255,220,50)
end)

UserInput.InputBegan:Connect(function(input, gp)
    if not _G._BindingKey then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    _G._BindingKey=false; _G.ToggleKeyCode=input.KeyCode
    kbBtn.Text=input.KeyCode.Name; kbBtn.TextColor3=Color3.fromRGB(60,220,100)
    kbLabel.Text="Toggle key:  "..input.KeyCode.Name
    if _G.Notify then _G.Notify("Keybind → "..input.KeyCode.Name,"success") end
end)

local adS=sec(settingsPage,"Anti-Detect",2)
tog(adS,"Randomize Timings",   true, function(v) _G.ADRandomTimings=v end,1)
tog(adS,"Obfuscate Globals",   true, function(v) _G.ADObfuscate=v     end,2)
lbl(adS,"Both on by default — keep them on",3)

_G.ADRandomTimings=true;_G.ADObfuscate=true

-- Background dropdown
local bgS = sec(settingsPage, "Background", 2)

local bgLabel = lbl(bgS, "Background:  "..((cfg.Backgrounds and cfg.Backgrounds[cfg.ActiveBackground or 1] and cfg.Backgrounds[cfg.ActiveBackground or 1].Name) or "Default"), 1)

if cfg.Backgrounds and #cfg.Backgrounds > 1 then
    local bgIdx = cfg.ActiveBackground or 1
    local function applyBG(idx)
        local entry = cfg.Backgrounds[idx]
        if not entry then return end
        bgIdx = idx
        bgLabel.Text = "Background:  " .. entry.Name
        local cleanId = tostring(entry.Id):match("%d+")
        if cleanId and cleanId ~= "0" then
            bgImg.Image = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"
        else
            bgImg.Image = ""
        end
    end

    local prevBtn = Instance.new("TextButton"); prevBtn.Size=UDim2.new(0,40,0,26); prevBtn.BackgroundColor3=Color3.fromRGB(255,255,255); prevBtn.BackgroundTransparency=0.85; prevBtn.BorderSizePixel=0; prevBtn.Font=Enum.Font.GothamBold; prevBtn.TextSize=14; prevBtn.TextColor3=Color3.fromRGB(255,255,255); prevBtn.Text="‹"; prevBtn.LayoutOrder=2; prevBtn.ZIndex=7; prevBtn.Parent=bgS
    local nc = Instance.new("UICorner"); nc.CornerRadius=UDim.new(0,6); nc.Parent=prevBtn

    local nextBtn = Instance.new("TextButton"); nextBtn.Size=UDim2.new(0,40,0,26); nextBtn.BackgroundColor3=Color3.fromRGB(255,255,255); nextBtn.BackgroundTransparency=0.85; nextBtn.BorderSizePixel=0; nextBtn.Font=Enum.Font.GothamBold; nextBtn.TextSize=14; nextBtn.TextColor3=Color3.fromRGB(255,255,255); nextBtn.Text="›"; nextBtn.LayoutOrder=3; nextBtn.ZIndex=7; nextBtn.Parent=bgS
    local nc2 = Instance.new("UICorner"); nc2.CornerRadius=UDim.new(0,6); nc2.Parent=nextBtn

    prevBtn.MouseButton1Click:Connect(function()
        bgIdx = ((bgIdx - 2) % #cfg.Backgrounds) + 1
        applyBG(bgIdx)
    end)
    nextBtn.MouseButton1Click:Connect(function()
        bgIdx = (bgIdx % #cfg.Backgrounds) + 1
        applyBG(bgIdx)
    end)
end

-- Minimize icon dropdown
local iconS = sec(settingsPage, "Minimize Icon", 3)
local iconLabel = lbl(iconS, "Icon:  Default", 1)

if cfg.MinimizeIcons and #cfg.MinimizeIcons > 1 then
    local icoIdx = cfg.ActiveMinimizeIcon or 1
    local function applyIcon(idx)
        local entry = cfg.MinimizeIcons[idx]
        if not entry then return end
        icoIdx = idx
        iconLabel.Text = "Icon:  " .. entry.Name
        local cleanId = tostring(entry.Id):match("%d+")
        if cleanId and cleanId ~= "0" then
            iconImg.Image = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"
        else
            iconImg.Image = ""
        end
    end
    local ip=Instance.new("TextButton"); ip.Size=UDim2.new(0,40,0,26); ip.BackgroundColor3=Color3.fromRGB(255,255,255); ip.BackgroundTransparency=0.85; ip.BorderSizePixel=0; ip.Font=Enum.Font.GothamBold; ip.TextSize=14; ip.TextColor3=Color3.fromRGB(255,255,255); ip.Text="‹"; ip.LayoutOrder=2; ip.ZIndex=7; ip.Parent=iconS
    local ic = Instance.new("UICorner"); ic.CornerRadius=UDim.new(0,6); ic.Parent=ip
    local in2=Instance.new("TextButton"); in2.Size=UDim2.new(0,40,0,26); in2.BackgroundColor3=Color3.fromRGB(255,255,255); in2.BackgroundTransparency=0.85; in2.BorderSizePixel=0; in2.Font=Enum.Font.GothamBold; in2.TextSize=14; in2.TextColor3=Color3.fromRGB(255,255,255); in2.Text="›"; in2.LayoutOrder=3; in2.ZIndex=7; in2.Parent=iconS
    local ic2 = Instance.new("UICorner"); ic2.CornerRadius=UDim.new(0,6); ic2.Parent=in2
    ip.MouseButton1Click:Connect(function() icoIdx=((icoIdx-2)%#cfg.MinimizeIcons)+1; applyIcon(icoIdx) end)
    in2.MouseButton1Click:Connect(function() icoIdx=(icoIdx%#cfg.MinimizeIcons)+1; applyIcon(icoIdx) end)
end

-- ── Footer hint ───────────────────────────────────────────────────────────────

local hint=Instance.new("TextLabel"); hint.Text="Right Control — toggle"; hint.Font=Enum.Font.Gotham; hint.TextSize=10; hint.TextColor3=Color3.fromRGB(70,70,80); hint.BackgroundTransparency=1; hint.Size=UDim2.new(1,0,0,14); hint.Position=UDim2.new(0,0,1,-16); hint.TextXAlignment=Enum.TextXAlignment.Center; hint.ZIndex=6; hint.Parent=main
