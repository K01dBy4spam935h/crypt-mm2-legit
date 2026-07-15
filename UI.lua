-- Crypt-MM2-Legit | UI — all fixes

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInput       = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local Stats           = game:GetService("Stats")
local lp              = Players.LocalPlayer

local cfg        = _G.Config or {}
local TOGGLE_KEY = cfg.ToggleKey     or Enum.KeyCode.RightShift
local WIN_SIZE   = cfg.WindowSize    or UDim2.new(0, 560, 0, 440)
local ICON_SIZE  = cfg.IconSize      or UDim2.new(0, 54, 0, 54)
local START_POS  = cfg.StartPosition or UDim2.new(0.5, -280, 0.5, -220)

-- ── Executor Detector — identifyexecutor() primary, capability fingerprint fallback ──

local function detectExecutor()
    -- Method 1: native executor API (no list needed)
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return tostring(name) end
    end
    if getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name then return tostring(name) end
    end
    -- Method 2: fingerprint by capability tier
    local score = 0
    if hookfunction     then score = score + 2 end
    if newcclosure      then score = score + 2 end
    if writefile        then score = score + 1 end
    if readfile         then score = score + 1 end
    if setfpscap        then score = score + 1 end
    if getrawmetatable  then score = score + 1 end
    if Drawing          then score = score + 1 end
    if firetouchinterest then score = score + 2 end

    if score >= 8 then return "High-tier executor (Synapse-class)" end
    if score >= 5 then return "Mid-tier executor" end
    if score >= 2 then return "Basic executor" end
    return "Unknown executor"
end

local executorName = detectExecutor()

-- ── Image loader — proper method for executor context ─────────────────────────
-- IMPORTANT: This needs an IMAGE ID (create.roblox.com > Images)
-- Decal IDs will attempt auto-resolve via InsertService as fallback

local function loadImage(label, rawId)
    if not rawId or rawId == "" then return end
    local numId = tostring(rawId):match("(%d+)")
    if not numId or numId == "0" then return end

    task.spawn(function()
        -- Set image directly first
        label.Image = "rbxassetid://" .. numId
        ContentProvider:PreloadAsync({label})
        task.wait(2)

        -- Check if it loaded
        if label.IsLoaded then return end

        -- Fallback: InsertService resolve (works for Decal IDs)
        local ok, asset = pcall(function()
            return game:GetService("InsertService"):LoadAsset(tonumber(numId))
        end)
        if ok and asset then
            for _, d in ipairs(asset:GetDescendants()) do
                if d:IsA("Decal") and d.Texture ~= "" then
                    label.Image = d.Texture
                    ContentProvider:PreloadAsync({label})
                    asset:Destroy()
                    return
                end
            end
            asset:Destroy()
        end
    end)
end

-- ── GUI — PlayerGui only, never gethui() ──────────────────────────────────────

local gui = Instance.new("ScreenGui")
gui.Name           = "CryptMM2"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.Parent         = lp:WaitForChild("PlayerGui")

-- ── Main window ───────────────────────────────────────────────────────────────

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

local bgImg = Instance.new("ImageLabel")
bgImg.Image                  = ""
bgImg.Size                   = UDim2.new(1,0,1,0)
bgImg.BackgroundTransparency = 1
bgImg.ImageTransparency      = 0
bgImg.ScaleType              = Enum.ScaleType.Stretch
bgImg.ZIndex                 = 1
bgImg.Parent                 = main
if cfg.BackgroundDecal then loadImage(bgImg, cfg.BackgroundDecal) end

local wash = Instance.new("Frame"); wash.Size = UDim2.new(1,0,1,0); wash.BackgroundColor3 = Color3.fromRGB(0,0,0); wash.BackgroundTransparency = 0.5; wash.BorderSizePixel = 0; wash.ZIndex = 2; wash.Parent = main
local wc = Instance.new("UICorner"); wc.CornerRadius = UDim.new(0,14); wc.Parent = wash

-- ── Title bar ─────────────────────────────────────────────────────────────────

local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,40); tb.BackgroundColor3 = Color3.fromRGB(0,0,0); tb.BackgroundTransparency = 0.35; tb.BorderSizePixel = 0; tb.ZIndex = 5; tb.Parent = main
local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0,14); tbc.Parent = tb
local tbsq = Instance.new("Frame"); tbsq.Size = UDim2.new(1,0,0,14); tbsq.Position = UDim2.new(0,0,1,-14); tbsq.BackgroundColor3 = Color3.fromRGB(0,0,0); tbsq.BackgroundTransparency = 0.35; tbsq.BorderSizePixel = 0; tbsq.ZIndex = 5; tbsq.Parent = tb

local titleLbl = Instance.new("TextLabel"); titleLbl.Text = "⚰  Crypt MM2"; titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 14; titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.BackgroundTransparency = 1; titleLbl.Size = UDim2.new(1,-90,1,0); titleLbl.Position = UDim2.new(0,14,0,0); titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6; titleLbl.Parent = tb

local accentLine = Instance.new("Frame"); accentLine.Size = UDim2.new(1,0,0,1); accentLine.Position = UDim2.new(0,0,0,40); accentLine.BackgroundColor3 = Color3.fromRGB(255,255,255); accentLine.BackgroundTransparency = 0.8; accentLine.BorderSizePixel = 0; accentLine.ZIndex = 4; accentLine.Parent = main

local function circBtn(col, xOff)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0,14,0,14); b.Position = UDim2.new(1,xOff,0.5,-7); b.BackgroundColor3 = col; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 9; b.Parent = tb
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.35}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    return b
end
local closeBtn = circBtn(Color3.fromRGB(220,55,55), -28)
local minBtn   = circBtn(Color3.fromRGB(230,130,30), -48)

-- ── Minimized icon — FULLY manual drag, fixed ─────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size                   = ICON_SIZE
iconFrame.Position               = START_POS
iconFrame.BackgroundColor3       = Color3.fromRGB(10,10,14)
iconFrame.BackgroundTransparency = 0
iconFrame.BorderSizePixel        = 0
iconFrame.Active                 = true   -- must be true for InputBegan to fire
iconFrame.Visible                = false
iconFrame.ZIndex                 = 20
iconFrame.Parent                 = gui

local ifc = Instance.new("UICorner"); ifc.CornerRadius = UDim.new(0,12); ifc.Parent = iconFrame
local ifs = Instance.new("UIStroke"); ifs.Color = Color3.fromRGB(255,255,255); ifs.Thickness = 1; ifs.Transparency = 0.65; ifs.Parent = iconFrame

local iconImg = Instance.new("ImageLabel"); iconImg.Image = ""; iconImg.Size = UDim2.new(1,-8,1,-8); iconImg.Position = UDim2.new(0,4,0,4); iconImg.BackgroundTransparency = 1; iconImg.ScaleType = Enum.ScaleType.Fit; iconImg.ZIndex = 21; iconImg.Parent = iconFrame
if cfg.MinimizeIconDecal then loadImage(iconImg, cfg.MinimizeIconDecal) end

-- FIX: use iconFrame.InputBegan (fires only when clicking THIS frame)
-- use UDim2.fromOffset for pure pixel positioning
local iconDrag = {active=false, offX=0, offY=0, moved=false}

iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDrag.active = true
        iconDrag.moved  = false
        local mp = UserInput:GetMouseLocation()
        iconDrag.offX = mp.X - iconFrame.AbsolutePosition.X
        iconDrag.offY = mp.Y - iconFrame.AbsolutePosition.Y
    end
end)

iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if iconDrag.active and not iconDrag.moved then
        -- pure click — restore window
        iconFrame.Visible = false
        main.Position     = iconFrame.Position
        main.Visible      = true
        _G._CryptMinimized = false
    end
    iconDrag.active = false
end)

UserInput.InputChanged:Connect(function(input)
    if not iconDrag.active then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    iconDrag.moved = true
    local mp = UserInput:GetMouseLocation()
    iconFrame.Position = UDim2.fromOffset(mp.X - iconDrag.offX, mp.Y - iconDrag.offY)
end)

-- ── Minimize / Close ──────────────────────────────────────────────────────────

_G._CryptMinimized = false

local function minimize()
    _G._CryptMinimized = true
    iconFrame.Position  = main.Position
    main.Visible        = false
    iconFrame.Visible   = true
end

local function restore()
    _G._CryptMinimized  = false
    main.Position       = iconFrame.Position
    iconFrame.Visible   = false
    main.Visible        = true
end

minBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        if _G._CryptMinimized then restore() else minimize() end
    end
end)

-- ── Notification system — top center ─────────────────────────────────────────

local notifContainer = Instance.new("Frame")
notifContainer.Size                   = UDim2.new(0, 300, 0, 0)
notifContainer.Position               = UDim2.new(0.5, -150, 0, 14)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex                 = 200
notifContainer.AutomaticSize          = Enum.AutomaticSize.Y
notifContainer.Parent                 = gui

local notifLayout = Instance.new("UIListLayout"); notifLayout.Padding = UDim.new(0,6); notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; notifLayout.Parent = notifContainer

local notifN = 0
local typeCols = {
    success = Color3.fromRGB(50,200,80),
    error   = Color3.fromRGB(220,55,55),
    info    = Color3.fromRGB(100,170,255),
    warn    = Color3.fromRGB(230,160,30),
}
local typeIcons = {success="✓", error="✕", info="ℹ", warn="⚠"}

_G.Notify = function(msg, ntype)
    ntype = ntype or "info"
    local col  = typeCols[ntype]  or typeCols.info
    local icon = typeIcons[ntype] or "ℹ"
    notifN = notifN + 1

    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,48); card.BackgroundColor3 = Color3.fromRGB(10,10,16); card.BackgroundTransparency = 0.05; card.BorderSizePixel = 0; card.LayoutOrder = notifN; card.ZIndex = 201; card.Parent = notifContainer
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,10); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = col; cs.Thickness = 2; cs.Transparency = 0.15; cs.Parent = card
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,4,1,0); bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.ZIndex = 202; bar.Parent = card
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = bar
    local ico = Instance.new("TextLabel"); ico.Text = icon; ico.Font = Enum.Font.GothamBold; ico.TextSize = 16; ico.TextColor3 = col; ico.BackgroundTransparency = 1; ico.Size = UDim2.new(0,24,1,0); ico.Position = UDim2.new(0,10,0,0); ico.TextXAlignment = Enum.TextXAlignment.Center; ico.ZIndex = 202; ico.Parent = card
    local lbl = Instance.new("TextLabel"); lbl.Text = msg; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(235,235,235); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-40,1,0); lbl.Position = UDim2.new(0,36,0,0); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.ZIndex = 202; lbl.Parent = card

    TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)}):Play()
    card.Position = UDim2.new(0,0,0,-60)

    task.delay(3.2, function()
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency=1, Position=UDim2.new(0,0,0,-60)}):Play()
        task.wait(0.3); card:Destroy()
    end)
end

-- ── Widget helpers ────────────────────────────────────────────────────────────

local function sec(parent, text, order)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,0); c.AutomaticSize = Enum.AutomaticSize.Y; c.BackgroundColor3 = Color3.fromRGB(255,255,255); c.BackgroundTransparency = 0.92; c.BorderSizePixel = 0; c.LayoutOrder = order or 1; c.ZIndex = 5; c.Parent = parent
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = c
    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0,3); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Parent = c
    local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0,4); cp.PaddingBottom = UDim.new(0,6); cp.PaddingLeft = UDim.new(0,6); cp.PaddingRight = UDim.new(0,6); cp.Parent = c
    local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1,0,0,22); hdr.BackgroundTransparency = 1; hdr.LayoutOrder = 0; hdr.ZIndex = 6; hdr.Parent = c
    local hl = Instance.new("TextLabel"); hl.Text = text:upper(); hl.Font = Enum.Font.GothamBold; hl.TextSize = 10; hl.TextColor3 = Color3.fromRGB(255,255,255); hl.BackgroundTransparency = 1; hl.Size = UDim2.new(1,0,1,0); hl.TextXAlignment = Enum.TextXAlignment.Left; hl.ZIndex = 7; hl.Parent = hdr
    local hline = Instance.new("Frame"); hline.Size = UDim2.new(1,0,0,1); hline.Position = UDim2.new(0,0,1,-1); hline.BackgroundColor3 = Color3.fromRGB(255,255,255); hline.BackgroundTransparency = 0.8; hline.BorderSizePixel = 0; hline.ZIndex = 7; hline.Parent = hdr
    return c
end

local function tog(parent, label, default, cb, order)
    default = (default == true)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,32); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,6,0,0); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row
    local track = Instance.new("Frame"); track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(1,-40,0.5,-9); track.BackgroundColor3 = default and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50); track.BorderSizePixel = 0; track.ZIndex = 7; track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14); knob.Position = default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7); knob.BackgroundColor3 = default and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130); knob.BorderSizePixel = 0; knob.ZIndex = 8; knob.Parent = track
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob
    local state = default; local ti = TweenInfo.new(0.13, Enum.EasingStyle.Quad)
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track,ti,{BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50)}):Play()
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=state and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130)}):Play()
        if cb then cb(state) end
    end)
end

local function sld(parent, label, mn, mx, def, cb, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,46); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-10,0,20); lbl.Position = UDim2.new(0,6,0,4); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row
    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(1,-12,0,4); tbg.Position = UDim2.new(0,6,1,-12); tbg.BackgroundColor3 = Color3.fromRGB(45,45,50); tbg.BorderSizePixel = 0; tbg.ZIndex = 7; tbg.Parent = row
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(1,0); tbc.Parent = tbg
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BorderSizePixel = 0; fill.ZIndex = 8; fill.Parent = tbg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    local value = def; lbl.Text = label..":  "..value
    local dragging = false
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row
    local function upd(input) local rel = math.clamp((input.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1); value=math.floor(mn+rel*(mx-mn)); fill.Size=UDim2.new(rel,0,1,0); lbl.Text=label.."  "..value; if cb then cb(value) end end
    hit.MouseButton1Down:Connect(function() dragging=true end)
    UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local function lbl(parent, text, order)
    local l = Instance.new("TextLabel"); l.Text=text; l.Font=Enum.Font.Gotham; l.TextSize=11; l.TextColor3=Color3.fromRGB(150,150,165); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,16); l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=order or 99; l.ZIndex=7; l.Parent=parent
    return l
end

local function copyRow(parent, labelText, getValue, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,26); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl2 = Instance.new("TextLabel"); lbl2.Text=labelText; lbl2.Font=Enum.Font.Gotham; lbl2.TextSize=11; lbl2.TextColor3=Color3.fromRGB(175,175,190); lbl2.BackgroundTransparency=1; lbl2.Size=UDim2.new(1,-54,1,0); lbl2.Position=UDim2.new(0,4,0,0); lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.ZIndex=7; lbl2.Parent=row
    local cb = Instance.new("TextButton"); cb.Size=UDim2.new(0,46,0,20); cb.Position=UDim2.new(1,-48,0.5,-10); cb.BackgroundColor3=Color3.fromRGB(255,255,255); cb.BackgroundTransparency=0.82; cb.BorderSizePixel=0; cb.Font=Enum.Font.GothamBold; cb.TextSize=10; cb.TextColor3=Color3.fromRGB(255,255,255); cb.Text="COPY"; cb.AutoButtonColor=false; cb.ZIndex=8; cb.Parent=row
    local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,5); cc.Parent=cb
    cb.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(tostring(getValue())) end)
        cb.Text="✓"; lbl2.TextColor3=Color3.fromRGB(60,200,80)
        task.delay(1.5,function() cb.Text="COPY"; lbl2.TextColor3=Color3.fromRGB(175,175,190) end)
    end)
    return lbl2
end

-- ── Sidebar ───────────────────────────────────────────────────────────────────

local sidebar = Instance.new("Frame"); sidebar.Size=UDim2.new(0,118,1,-42); sidebar.Position=UDim2.new(0,0,0,41); sidebar.BackgroundColor3=Color3.fromRGB(0,0,0); sidebar.BackgroundTransparency=0.5; sidebar.BorderSizePixel=0; sidebar.ZIndex=4; sidebar.Parent=main
local sl = Instance.new("UIListLayout"); sl.Padding=UDim.new(0,4); sl.HorizontalAlignment=Enum.HorizontalAlignment.Center; sl.Parent=sidebar
local sp = Instance.new("UIPadding"); sp.PaddingTop=UDim.new(0,8); sp.PaddingLeft=UDim.new(0,5); sp.PaddingRight=UDim.new(0,5); sp.Parent=sidebar
local sdiv = Instance.new("Frame"); sdiv.Size=UDim2.new(0,1,1,-42); sdiv.Position=UDim2.new(0,118,0,41); sdiv.BackgroundColor3=Color3.fromRGB(255,255,255); sdiv.BackgroundTransparency=0.82; sdiv.BorderSizePixel=0; sdiv.ZIndex=4; sdiv.Parent=main

local contentArea = Instance.new("Frame"); contentArea.Size=UDim2.new(1,-126,1,-50); contentArea.Position=UDim2.new(0,122,0,46); contentArea.BackgroundTransparency=1; contentArea.ClipsDescendants=true; contentArea.ZIndex=4; contentArea.Parent=main

-- ── Tab builder ───────────────────────────────────────────────────────────────

local tabPages = {}

local function makeTab(name, iconId)
    local btn = Instance.new("Frame"); btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=Color3.fromRGB(255,255,255); btn.BackgroundTransparency=0.92; btn.BorderSizePixel=0; btn.ZIndex=6; btn.Parent=sidebar
    local bc = Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,7); bc.Parent=btn
    local ico = Instance.new("ImageLabel"); ico.Image=""; ico.Size=UDim2.new(0,14,0,14); ico.Position=UDim2.new(0,7,0.5,-7); ico.BackgroundTransparency=1; ico.ScaleType=Enum.ScaleType.Fit; ico.ZIndex=7; ico.Parent=btn
    if iconId and iconId ~= "rbxassetid://0" then loadImage(ico, iconId) end
    local bLbl = Instance.new("TextLabel"); bLbl.Text=name; bLbl.Font=Enum.Font.GothamSemibold; bLbl.TextSize=11; bLbl.TextColor3=Color3.fromRGB(140,140,140); bLbl.BackgroundTransparency=1; bLbl.Size=UDim2.new(1,-26,1,0); bLbl.Position=UDim2.new(0,24,0,0); bLbl.TextXAlignment=Enum.TextXAlignment.Left; bLbl.ZIndex=7; bLbl.Parent=btn
    local click = Instance.new("TextButton"); click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1; click.Text=""; click.ZIndex=8; click.Parent=btn

    local page = Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0; page.ScrollBarThickness=2; page.ScrollBarImageColor3=Color3.fromRGB(255,255,255); page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ZIndex=5; page.Visible=false; page.Parent=contentArea
    local pl = Instance.new("UIListLayout"); pl.Padding=UDim.new(0,6); pl.SortOrder=Enum.SortOrder.LayoutOrder; pl.Parent=page
    local pp = Instance.new("UIPadding"); pp.PaddingTop=UDim.new(0,8); pp.PaddingBottom=UDim.new(0,8); pp.PaddingLeft=UDim.new(0,5); pp.PaddingRight=UDim.new(0,8); pp.Parent=page

    tabPages[name] = {page=page, btn=btn, lbl=bLbl}

    click.MouseButton1Click:Connect(function()
        for _, t in pairs(tabPages) do t.page.Visible=false; t.btn.BackgroundTransparency=0.92; t.lbl.TextColor3=Color3.fromRGB(140,140,140) end
        page.Visible=true; btn.BackgroundTransparency=0.65; bLbl.TextColor3=Color3.fromRGB(255,255,255)
    end)
    return page
end

-- ── Tabs ──────────────────────────────────────────────────────────────────────

local mainPage    = makeTab("Main",        cfg.Icon_Main        or "rbxassetid://0")
local aimbotPage  = makeTab("Aimbot",      cfg.Icon_Aimbot      or "rbxassetid://0")
local visPage     = makeTab("Visuals",     cfg.Icon_Visuals     or "rbxassetid://0")
local lpPage      = makeTab("LocalPlayer", cfg.Icon_LocalPlayer or "rbxassetid://0")
local murdPage    = makeTab("Murderer",    cfg.Icon_Murderer    or "rbxassetid://0")
local sheriffPage = makeTab("Sheriff",     cfg.Icon_Sheriff     or "rbxassetid://0")
local farmPage    = makeTab("Farm",        cfg.Icon_Farm        or "rbxassetid://0")

tabPages["Main"].page.Visible=true; tabPages["Main"].btn.BackgroundTransparency=0.65; tabPages["Main"].lbl.TextColor3=Color3.fromRGB(255,255,255)

-- ── MAIN TAB ─────────────────────────────────────────────────────────────────

local wS = sec(mainPage, "Welcome", 1)
local wL = Instance.new("TextLabel"); wL.Text="Welcome,  "..lp.DisplayName; wL.Font=Enum.Font.GothamBold; wL.TextSize=16; wL.TextColor3=Color3.fromRGB(255,255,255); wL.BackgroundTransparency=1; wL.Size=UDim2.new(1,0,0,24); wL.TextXAlignment=Enum.TextXAlignment.Left; wL.LayoutOrder=1; wL.ZIndex=7; wL.Parent=wS
local uL = Instance.new("TextLabel"); uL.Text="@"..lp.Name; uL.Font=Enum.Font.Gotham; uL.TextSize=11; uL.TextColor3=Color3.fromRGB(130,130,145); uL.BackgroundTransparency=1; uL.Size=UDim2.new(1,0,0,16); uL.TextXAlignment=Enum.TextXAlignment.Left; uL.LayoutOrder=2; uL.ZIndex=7; uL.Parent=wS
local cL = Instance.new("TextLabel"); cL.Text="Created by Crypt0  |  "..executorName; cL.Font=Enum.Font.GothamBold; cL.TextSize=10; cL.TextColor3=Color3.fromRGB(90,90,110); cL.BackgroundTransparency=1; cL.Size=UDim2.new(1,0,0,14); cL.TextXAlignment=Enum.TextXAlignment.Left; cL.LayoutOrder=3; cL.ZIndex=7; cL.Parent=wS

-- Role indicator
local roleS = sec(mainPage, "Your Role", 2)
local roleLbl = Instance.new("TextLabel"); roleLbl.Text="Role: detecting…"; roleLbl.Font=Enum.Font.GothamBold; roleLbl.TextSize=14; roleLbl.TextColor3=Color3.fromRGB(200,200,200); roleLbl.BackgroundTransparency=1; roleLbl.Size=UDim2.new(1,0,0,26); roleLbl.TextXAlignment=Enum.TextXAlignment.Left; roleLbl.LayoutOrder=1; roleLbl.ZIndex=7; roleLbl.Parent=roleS

-- Server info
local srvS = sec(mainPage, "Server", 3)

-- Detect public/private
local serverType = "Public Server"
if game.PrivateServerId ~= "" then serverType = "Private Server" end

local stLbl = Instance.new("TextLabel"); stLbl.Text="Type:  "..serverType; stLbl.Font=Enum.Font.Gotham; stLbl.TextSize=11; stLbl.TextColor3=Color3.fromRGB(175,175,190); stLbl.BackgroundTransparency=1; stLbl.Size=UDim2.new(1,0,0,18); stLbl.TextXAlignment=Enum.TextXAlignment.Left; stLbl.LayoutOrder=0; stLbl.ZIndex=7; stLbl.Parent=srvS

local jobLbl   = copyRow(srvS, "Job ID:    loading…", function() return game.JobId   end, 1)
local placeLbl = copyRow(srvS, "Place ID:  loading…", function() return game.PlaceId end, 2)
local countLbl = copyRow(srvS, "Players:   loading…", function() return #Players:GetPlayers().."/"..Players.MaxPlayers end, 3)
local pingLbl  = copyRow(srvS, "Ping:      loading…", function()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms"
end, 4)

-- Live update
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            jobLbl.Text   = "Job ID:    "..tostring(game.JobId):sub(1,22).."…"
            placeLbl.Text = "Place ID:  "..tostring(game.PlaceId)
            countLbl.Text = "Players:   "..#Players:GetPlayers().."/"..Players.MaxPlayers
            pingLbl.Text  = "Ping:      "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms"
        end)
    end
end)

-- Role label update (driven by _G.MyRole set in ESP.lua)
task.spawn(function()
    while task.wait(0.5) do
        local r = _G.MyRole or "Unknown"
        if r == "Murderer" then
            roleLbl.Text = "Role:  🔴 MURDERER"
            roleLbl.TextColor3 = Color3.fromRGB(255,70,70)
        elseif r == "Sheriff" then
            roleLbl.Text = "Role:  🔵 SHERIFF"
            roleLbl.TextColor3 = Color3.fromRGB(60,200,255)
        elseif r == "Innocent" then
            roleLbl.Text = "Role:  ⚪ INNOCENT"
            roleLbl.TextColor3 = Color3.fromRGB(200,200,200)
        else
            roleLbl.Text = "Role:  detecting…"
            roleLbl.TextColor3 = Color3.fromRGB(150,150,150)
        end
    end
end)

-- ── AIMBOT TAB ────────────────────────────────────────────────────────────────

local abS = sec(aimbotPage,"Aimbot",1)
tog(abS,"Enable Aimbot",       false,function(v) _G.AimbotEnabled    = v end,1)
tog(abS,"Require Right Click", false,function(v) _G.AimbotRightClick = v end,2)

local tgtS = sec(aimbotPage,"Target",2)
tog(tgtS,"Aim Murderer",false,function(v) _G.AimMurderer=v end,1)
tog(tgtS,"Aim Sheriff", false,function(v) _G.AimSheriff =v end,2)
lbl(tgtS,"Both off = aim everyone",3)

local abSet = sec(aimbotPage,"Settings",3)
sld(abSet,"Smoothing",  1,15,2,  function(v) _G.AimbotSmoothing=v end,1)
sld(abSet,"FOV Radius", 20,600,250,function(v) _G.AimbotFOV=v end,2)
tog(abSet,"Show FOV",      false,function(v) _G.ShowFOV=v end,3)
tog(abSet,"FOV RGB",       false,function(v) _G.FovRGB=v end,4)
tog(abSet,"Target Tracer", false,function(v) _G.TargetTracer=v end,5)

local tbS = sec(aimbotPage,"Triggerbot",4)
tog(tbS,"Enable Triggerbot",false,function(v) _G.TriggerEnabled=v end,1)
tog(tbS,"Trigger Murderer", false,function(v) _G.TriggerMurd=v    end,2)
tog(tbS,"Trigger Sheriff",  false,function(v) _G.TriggerSheriff=v end,3)
lbl(tbS,"Both off = trigger all",4)
sld(tbS,"Trigger FOV",5,100,30,function(v) _G.TriggerFOV=v end,5)

_G.AimbotEnabled=false;_G.AimbotRightClick=false;_G.AimMurderer=false;_G.AimSheriff=false
_G.AimbotSmoothing=2;_G.AimbotFOV=250;_G.ShowFOV=false;_G.FovRGB=false
_G.TargetTracer=false;_G.TriggerEnabled=false;_G.TriggerMurd=false;_G.TriggerSheriff=false;_G.TriggerFOV=30

-- ── VISUALS TAB ───────────────────────────────────────────────────────────────

local espS = sec(visPage,"ESP",1)
tog(espS,"Box ESP",      false,function(v) _G.BoxESP=v      end,1)
tog(espS,"Chams ESP",    false,function(v) _G.ChamsESP=v    end,2)
tog(espS,"Name ESP",     false,function(v) _G.NameESP=v     end,3)
tog(espS,"Distance ESP", false,function(v) _G.DistanceESP=v end,4)
tog(espS,"Tracers",      false,function(v) _G.Tracers=v     end,5)

local xhS = sec(visPage,"Crosshair",2)
tog(xhS,"Custom Crosshair",  false,function(v) _G.CrosshairEnabled=v     end,1)
tog(xhS,"RGB Mode",           false,function(v) _G.CrosshairRGB=v        end,2)
tog(xhS,"Red On Player",      true, function(v) _G.CrosshairRedOnPlayer=v end,3)
sld(xhS,"Size",      4,30,14,function(v) _G.CrosshairSize=v  end,4)
sld(xhS,"Gap",       0,12,4, function(v) _G.CrosshairGap=v   end,5)
sld(xhS,"Thickness", 1,4, 1, function(v) _G.CrosshairThick=v end,6)
sld(xhS,"Spin Speed",1,20,5, function(v) _G.CrosshairSpin=v  end,7)

_G.BoxESP=false;_G.ChamsESP=false;_G.NameESP=false;_G.DistanceESP=false;_G.Tracers=false
_G.CrosshairEnabled=false;_G.CrosshairRGB=false;_G.CrosshairRedOnPlayer=true
_G.CrosshairSize=14;_G.CrosshairGap=4;_G.CrosshairThick=1;_G.CrosshairSpin=5

-- ── LOCAL PLAYER TAB ─────────────────────────────────────────────────────────

local mvS = sec(lpPage,"Movement",1)
tog(mvS,"Noclip",        false,function(v) _G.NoclipEnabled=v  end,1)
tog(mvS,"Speedhack",     false,function(v) _G.SpeedEnabled=v   end,2)
tog(mvS,"Infinite Jump", false,function(v) _G.InfJumpEnabled=v end,3)
tog(mvS,"Fly",           false,function(v) _G.FlyEnabled=v; if _G.SetFly then _G.SetFly(v) end end,4)
sld(mvS,"Speed Mult", 1,100,1,  function(v) _G.SpeedMultiplier=v end,5)
sld(mvS,"Fly Speed",  10,200,60,function(v) _G.FlySpeed=v        end,6)

local invisS = sec(lpPage,"Visibility",2)
tog(invisS,"Invisibility",false,function(v) _G.InvisEnabled=v end,1)
lbl(invisS,"Parts shrink to 0 — others see nothing",2)

local gunS = sec(lpPage,"Auto Gun",3)
tog(gunS,"Auto Collect Gun",false,function(v) _G.AutoGun=v end,1)
lbl(gunS,"Teleports GunDrop to you — instant",2)

local afkS = sec(lpPage,"Anti-AFK",4)
tog(afkS,"Anti-AFK",false,function(v) _G.AntiAFK=v end,1)
lbl(afkS,"VirtualUser mouse wiggle every 20s",2)

_G.NoclipEnabled=false;_G.SpeedEnabled=false;_G.InfJumpEnabled=false
_G.FlyEnabled=false;_G.SpeedMultiplier=1;_G.FlySpeed=60
_G.InvisEnabled=false;_G.AutoGun=false;_G.AntiAFK=false

-- ── MURDERER TAB ──────────────────────────────────────────────────────────────

local mkS = sec(murdPage,"Knife Tools",1)
tog(mkS,"Knife Aura",   false,function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if not hasKnife and _G.Notify then _G.Notify("No Knife found — you are not Murderer","warn") end
    end
    _G.KnifeAura=v
end,1)
sld(mkS,"Aura Range",5,60,15,function(v) _G.KnifeAuraRange=v end,2)
tog(mkS,"Auto Stab",false,function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if not hasKnife and _G.Notify then _G.Notify("No Knife found — you are not Murderer","warn") end
    end
    _G.AutoStab=v
end,3)

local hbS = sec(murdPage,"Hitbox Expander",2)
tog(hbS,"Enable Hitbox",false,function(v) _G.HitboxEnabled=v end,1)
sld(hbS,"Hitbox Size",2,20,6,function(v) _G.HitboxSize=v end,2)
lbl(hbS,"Expands innocent hitboxes — walk-through on",3)

local saS = sec(murdPage,"Silent Aim",3)
tog(saS,"Enable Silent Aim",false,function(v) _G.SilentAim=v end,1)
sld(saS,"Silent Aim Size",10,80,40,function(v) _G.SilentAimSize=v end,2)
lbl(saS,"Expands all targets hugely — hits through walls",3)

_G.KnifeAura=false;_G.KnifeAuraRange=15;_G.AutoStab=false
_G.HitboxEnabled=false;_G.HitboxSize=6;_G.SilentAim=false;_G.SilentAimSize=40

-- ── SHERIFF TAB ───────────────────────────────────────────────────────────────

local shS = sec(sheriffPage,"Sheriff Tools",1)
tog(shS,"Show Murderer Marker",false,function(v) _G.MurdererArrow=v end,1)

local shWarn = sec(sheriffPage,"Status",2)
local shStatusLbl = lbl(shWarn,"Checking role…",1)

task.spawn(function()
    while task.wait(1) do
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasGun  =(char and char:FindFirstChild("Gun"))   or (bp and bp:FindFirstChild("Gun"))
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if hasKnife then
            shStatusLbl.Text="You have: Knife (Murderer)"; shStatusLbl.TextColor3=Color3.fromRGB(255,80,80)
        elseif hasGun then
            shStatusLbl.Text="You have: Gun (Sheriff)"; shStatusLbl.TextColor3=Color3.fromRGB(60,210,255)
        else
            shStatusLbl.Text="No Gun or Knife — Innocent"; shStatusLbl.TextColor3=Color3.fromRGB(180,180,180)
        end
    end
end)

_G.MurdererArrow=false

-- ── FARM TAB ─────────────────────────────────────────────────────────────────

local cS = sec(farmPage,"Coin Farm",1)
tog(cS,"Auto Collect Coins",  false,function(v) _G.CoinFarm=v      end,1)
tog(cS,"Anti-Murderer Safety",true, function(v) _G.CoinAntiMurd=v  end,2)
sld(cS,"Safety Radius",5,40,15,function(v) _G.CoinSafetyRadius=v   end,3)
lbl(cS,"Noclip auto-on during farm",4)

_G.CoinFarm=false;_G.CoinAntiMurd=true;_G.CoinSafetyRadius=15

local hint=Instance.new("TextLabel"); hint.Text="Right Shift — toggle"; hint.Font=Enum.Font.Gotham; hint.TextSize=10; hint.TextColor3=Color3.fromRGB(70,70,80); hint.BackgroundTransparency=1; hint.Size=UDim2.new(1,0,0,14); hint.Position=UDim2.new(0,0,1,-16); hint.TextXAlignment=Enum.TextXAlignment.Center; hint.ZIndex=6; hint.Parent=main

local settingsPage = makeTab("Settings", "rbxassetid://0")

-- SETTINGS TAB ---------------------------------------------------------

-- Keybind changer
local kbS = sec(settingsPage, "Keybind", 1)
local kbLabel = lbl(kbS, "Toggle key: Right Control", 1)
local kbRow = Instance.new("Frame"); kbRow.Size=UDim2.new(1,0,0,32); kbRow.BackgroundTransparency=1; kbRow.LayoutOrder=2; kbRow.ZIndex=6; kbRow.Parent=kbS

local kbBtn = Instance.new("TextButton"); kbBtn.Size=UDim2.new(1,0,0,28); kbBtn.BackgroundColor3=Color3.fromRGB(255,255,255); kbBtn.BackgroundTransparency=0.85; kbBtn.BorderSizePixel=0; kbBtn.Font=Enum.Font.GothamBold; kbBtn.TextSize=12; kbBtn.TextColor3=Color3.fromRGB(255,255,255); kbBtn.Text="Click to rebind"; kbBtn.ZIndex=7; kbBtn.Parent=kbRow
local kbBtnC = Instance.new("UICorner"); kbBtnC.CornerRadius=UDim.new(0,6); kbBtnC.Parent=kbBtn

local bindingNow = false
kbBtn.MouseButton1Click:Connect(function()
    if bindingNow then return end
    bindingNow       = true
    kbBtn.Text       = "▶ Press any key..."
    kbBtn.TextColor3 = Color3.fromRGB(255, 220, 50)
end)

UserInput.InputBegan:Connect(function(input, gp)
    if not bindingNow then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    bindingNow             = false
    _G.ToggleKeyCode       = input.KeyCode
    kbBtn.Text             = input.KeyCode.Name
    kbBtn.TextColor3       = Color3.fromRGB(60, 220, 100)
    kbLabel.Text           = "Toggle key: " .. input.KeyCode.Name
    if _G.Notify then _G.Notify("Keybind set to " .. input.KeyCode.Name, "success") end
end)

-- Apply dynamic keybind in the toggle handler (override the static one)
-- Replace the static UserInput.InputBegan toggle connection with this:
UserInput.InputBegan:Connect(function(input, gp)
    if gp or bindingNow then return end
    local key = _G.ToggleKeyCode or TOGGLE_KEY
    if input.KeyCode == key then
        if _G._CryptMinimized then restore() else minimize() end
    end
end)
