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
local TOGGLE_KEY = cfg.ToggleKey    or Enum.KeyCode.RightShift
local WIN_SIZE   = cfg.WindowSize   or UDim2.new(0, 560, 0, 440)
local ICON_SIZE  = cfg.IconSize     or UDim2.new(0, 54, 0, 54)
local START_POS  = cfg.StartPosition or UDim2.new(0.5, -280, 0.5, -220)

-- ── DECAL AUTO-RESOLVER ───────────────────────────────────────────────────────
-- Decal IDs and Image IDs are different assets.
-- This extracts the real image texture from a decal wrapper automatically.

local function resolveImageId(inputId)
    local numId = tostring(inputId):match("(%d+)")
    if not numId or numId == "0" then return nil end

    -- Try InsertService to load decal and extract texture
    local ok, asset = pcall(function()
        return InsertService:LoadAsset(tonumber(numId))
    end)

    if ok and asset then
        for _, desc in ipairs(asset:GetDescendants()) do
            if desc:IsA("Decal") and desc.Texture ~= "" then
                local tex = desc.Texture
                asset:Destroy()
                return tex   -- e.g. "rbxassetid://REAL_IMAGE_ID"
            end
        end
        asset:Destroy()
    end

    -- Fallback: might already be an image ID
    return "rbxassetid://" .. numId
end

local function setImageAsync(imageLabel, rawId)
    task.spawn(function()
        local resolved = resolveImageId(rawId)
        if resolved then
            imageLabel.Image = resolved
            -- Preload after setting
            ContentProvider:PreloadAsync({imageLabel})
        end
    end)
end

-- ── Screen GUI — must use PlayerGui NOT gethui() ──────────────────────────────

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

local mainC = Instance.new("UICorner"); mainC.CornerRadius = UDim.new(0,14); mainC.Parent = main
local mainS = Instance.new("UIStroke"); mainS.Color = Color3.fromRGB(255,255,255); mainS.Thickness = 1.5; mainS.Transparency = 0.65; mainS.Parent = main

-- Background image
local bgImg = Instance.new("ImageLabel")
bgImg.Name                  = "BG"
bgImg.Image                 = ""          -- set async below
bgImg.Size                  = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.ImageTransparency     = 0
bgImg.ScaleType             = Enum.ScaleType.Stretch
bgImg.ZIndex                = 1
bgImg.Parent                = main

-- Resolve and load decal image asynchronously
if cfg.BackgroundDecal then
    setImageAsync(bgImg, cfg.BackgroundDecal)
end

local wash = Instance.new("Frame")
wash.Size                   = UDim2.new(1, 0, 1, 0)
wash.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
wash.BackgroundTransparency = 0.5
wash.BorderSizePixel        = 0
wash.ZIndex                 = 2
wash.Parent                 = main
local washC = Instance.new("UICorner"); washC.CornerRadius = UDim.new(0,14); washC.Parent = wash

-- ── Title Bar ─────────────────────────────────────────────────────────────────

local tb = Instance.new("Frame")
tb.Size = UDim2.new(1,0,0,40); tb.BackgroundColor3 = Color3.fromRGB(0,0,0); tb.BackgroundTransparency = 0.35; tb.BorderSizePixel = 0; tb.ZIndex = 5; tb.Parent = main
local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(0,14); tbC.Parent = tb
local tbSq = Instance.new("Frame"); tbSq.Size = UDim2.new(1,0,0,14); tbSq.Position = UDim2.new(0,0,1,-14); tbSq.BackgroundColor3 = Color3.fromRGB(0,0,0); tbSq.BackgroundTransparency = 0.35; tbSq.BorderSizePixel = 0; tbSq.ZIndex = 5; tbSq.Parent = tb

local titleLbl = Instance.new("TextLabel"); titleLbl.Text = "⚰  Crypt MM2"; titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 14; titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.BackgroundTransparency = 1; titleLbl.Size = UDim2.new(1,-90,1,0); titleLbl.Position = UDim2.new(0,14,0,0); titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6; titleLbl.Parent = tb

local accentLine = Instance.new("Frame"); accentLine.Size = UDim2.new(1,0,0,1); accentLine.Position = UDim2.new(0,0,0,40); accentLine.BackgroundColor3 = Color3.fromRGB(255,255,255); accentLine.BackgroundTransparency = 0.8; accentLine.BorderSizePixel = 0; accentLine.ZIndex = 4; accentLine.Parent = main

-- ── Circle Buttons ────────────────────────────────────────────────────────────

local function circBtn(col, xOff)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0,14,0,14); b.Position = UDim2.new(1,xOff,0.5,-7); b.BackgroundColor3 = col; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 9; b.Parent = tb
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.35}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    return b
end
local closeBtn = circBtn(Color3.fromRGB(220,55,55),   -28)
local minBtn   = circBtn(Color3.fromRGB(230,130,30),  -48)

-- ── Minimized Icon — fully manual drag ────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size = ICON_SIZE; iconFrame.Position = START_POS; iconFrame.BackgroundColor3 = Color3.fromRGB(10,10,14); iconFrame.BackgroundTransparency = 0; iconFrame.BorderSizePixel = 0; iconFrame.Visible = false; iconFrame.ZIndex = 20; iconFrame.Parent = gui
local iconFC = Instance.new("UICorner"); iconFC.CornerRadius = UDim.new(0,12); iconFC.Parent = iconFrame
local iconFS = Instance.new("UIStroke"); iconFS.Color = Color3.fromRGB(255,255,255); iconFS.Thickness = 1; iconFS.Transparency = 0.65; iconFS.Parent = iconFrame

local iconImg = Instance.new("ImageLabel")
iconImg.Image = ""; iconImg.Size = UDim2.new(1,-8,1,-8); iconImg.Position = UDim2.new(0,4,0,4); iconImg.BackgroundTransparency = 1; iconImg.ScaleType = Enum.ScaleType.Fit; iconImg.ZIndex = 21; iconImg.Parent = iconFrame
if cfg.MinimizeIconDecal then setImageAsync(iconImg, cfg.MinimizeIconDecal) end

-- Manual drag implementation (Draggable unreliable in executor context)
local iconDrag = {active=false, startMouse=nil, startPos=nil, moved=false}

UserInput.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    -- Check if mouse is over iconFrame
    local mp = UserInput:GetMouseLocation()
    local ap = iconFrame.AbsolutePosition
    local as = iconFrame.AbsoluteSize
    if mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y then
        if not iconFrame.Visible then return end
        iconDrag.active     = true
        iconDrag.startMouse = mp
        iconDrag.startPos   = iconFrame.Position
        iconDrag.moved      = false
    end
end)

UserInput.InputChanged:Connect(function(input)
    if not iconDrag.active then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local mp    = UserInput:GetMouseLocation()
    local delta = mp - iconDrag.startMouse
    if delta.Magnitude > 3 then iconDrag.moved = true end
    iconFrame.Position = UDim2.new(
        iconDrag.startPos.X.Scale,
        iconDrag.startPos.X.Offset + delta.X,
        iconDrag.startPos.Y.Scale,
        iconDrag.startPos.Y.Offset + delta.Y
    )
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if iconDrag.active and not iconDrag.moved then
        -- It was a click not a drag — restore window
        if iconFrame.Visible then
            local minimized_state = true -- will trigger restore below
            minimized_state = false
            main.Position     = iconFrame.Position
            iconFrame.Visible = false
            main.Visible      = true
        end
    end
    iconDrag.active = false
end)

-- ── Minimize / Close Logic ────────────────────────────────────────────────────

local minimized = false

local function minimize()
    minimized          = true
    iconFrame.Position = main.Position
    main.Visible       = false
    iconFrame.Visible  = true
end

local function restore()
    minimized          = false
    main.Position      = iconFrame.Position
    iconFrame.Visible  = false
    main.Visible       = true
end

minBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        if minimized then restore() else minimize() end
    end
end)

-- ── NOTIFICATION SYSTEM — top center, large and noticeable ───────────────────

local notifContainer = Instance.new("Frame")
notifContainer.Size                   = UDim2.new(0, 300, 0, 0)
notifContainer.Position               = UDim2.new(0.5, -150, 0, 12)   -- top center
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex                 = 200
notifContainer.AutomaticSize          = Enum.AutomaticSize.Y
notifContainer.Parent                 = gui

local notifLayout = Instance.new("UIListLayout")
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notifLayout.SortOrder           = Enum.SortOrder.LayoutOrder
notifLayout.Padding             = UDim.new(0, 6)
notifLayout.Parent              = notifContainer

local notifCount = 0
local typeData = {
    success = {col = Color3.fromRGB(50,  200,  80),  icon = "✓"},
    error   = {col = Color3.fromRGB(220, 55,   55),  icon = "✕"},
    info    = {col = Color3.fromRGB(100, 170, 255),  icon = "ℹ"},
    warn    = {col = Color3.fromRGB(230, 160,  30),  icon = "⚠"},
}

_G.Notify = function(message, ntype)
    ntype = ntype or "info"
    local td  = typeData[ntype] or typeData.info
    notifCount = notifCount + 1

    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3       = Color3.fromRGB(12, 12, 18)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel        = 0
    card.LayoutOrder            = notifCount
    card.ZIndex                 = 201
    card.Parent                 = notifContainer

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,10); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = td.col; cs.Thickness = 2; cs.Transparency = 0.2; cs.Parent = card

    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,4,1,0); bar.BackgroundColor3 = td.col; bar.BorderSizePixel = 0; bar.ZIndex = 202; bar.Parent = card
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = bar

    local iconLbl = Instance.new("TextLabel"); iconLbl.Text = td.icon; iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 16; iconLbl.TextColor3 = td.col; iconLbl.BackgroundTransparency = 1; iconLbl.Size = UDim2.new(0,24,1,0); iconLbl.Position = UDim2.new(0,10,0,0); iconLbl.TextXAlignment = Enum.TextXAlignment.Center; iconLbl.ZIndex = 202; iconLbl.Parent = card

    local msgLbl = Instance.new("TextLabel"); msgLbl.Text = message; msgLbl.Font = Enum.Font.Gotham; msgLbl.TextSize = 13; msgLbl.TextColor3 = Color3.fromRGB(240,240,240); msgLbl.BackgroundTransparency = 1; msgLbl.Size = UDim2.new(1,-40,1,0); msgLbl.Position = UDim2.new(0,36,0,0); msgLbl.TextXAlignment = Enum.TextXAlignment.Left; msgLbl.TextWrapped = true; msgLbl.ZIndex = 202; msgLbl.Parent = card

    -- drop in from top
    card.Position = UDim2.new(0, 0, 0, -60)
    TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(3.2, function()
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -60)
        }):Play()
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ── Widget Builders ───────────────────────────────────────────────────────────

local function makeSection(parent, text, order)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,0); c.AutomaticSize = Enum.AutomaticSize.Y; c.BackgroundColor3 = Color3.fromRGB(255,255,255); c.BackgroundTransparency = 0.92; c.BorderSizePixel = 0; c.LayoutOrder = order or 1; c.ZIndex = 5; c.Parent = parent
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = c
    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0,3); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Parent = c
    local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0,4); cp.PaddingBottom = UDim.new(0,6); cp.PaddingLeft = UDim.new(0,6); cp.PaddingRight = UDim.new(0,6); cp.Parent = c

    local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1,0,0,22); hdr.BackgroundTransparency = 1; hdr.LayoutOrder = 0; hdr.ZIndex = 6; hdr.Parent = c
    local hl = Instance.new("TextLabel"); hl.Text = text:upper(); hl.Font = Enum.Font.GothamBold; hl.TextSize = 10; hl.TextColor3 = Color3.fromRGB(255,255,255); hl.BackgroundTransparency = 1; hl.Size = UDim2.new(1,0,1,0); hl.TextXAlignment = Enum.TextXAlignment.Left; hl.ZIndex = 7; hl.Parent = hdr
    local hline = Instance.new("Frame"); hline.Size = UDim2.new(1,0,0,1); hline.Position = UDim2.new(0,0,1,-1); hline.BackgroundColor3 = Color3.fromRGB(255,255,255); hline.BackgroundTransparency = 0.8; hline.BorderSizePixel = 0; hline.ZIndex = 7; hline.Parent = hdr
    return c
end

local function makeToggle(parent, label, default, cb, order)
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
    return function() return state end
end

local function makeSlider(parent, label, mn, mx, def, cb, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,46); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-10,0,20); lbl.Position = UDim2.new(0,6,0,4); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row
    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(1,-12,0,4); tbg.Position = UDim2.new(0,6,1,-12); tbg.BackgroundColor3 = Color3.fromRGB(45,45,50); tbg.BorderSizePixel = 0; tbg.ZIndex = 7; tbg.Parent = row
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(1,0); tbc.Parent = tbg
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BorderSizePixel = 0; fill.ZIndex = 8; fill.Parent = tbg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    local value = def; lbl.Text = label .. ":  " .. value
    local dragging = false
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row
    local function upd(input)
        local rel = math.clamp((input.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
        value = math.floor(mn+rel*(mx-mn)); fill.Size = UDim2.new(rel,0,1,0); lbl.Text = label.."  "..value
        if cb then cb(value) end
    end
    hit.MouseButton1Down:Connect(function() dragging=true end)
    UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return function() return value end
end

local function makeLabel(parent, text, order)
    local l = Instance.new("TextLabel"); l.Text = text; l.Font = Enum.Font.Gotham; l.TextSize = 11; l.TextColor3 = Color3.fromRGB(150,150,165); l.BackgroundTransparency = 1; l.Size = UDim2.new(1,0,0,16); l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = order or 99; l.ZIndex = 7; l.Parent = parent
    return l
end

local function makeCopyRow(parent, labelText, getValue, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,26); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Text = labelText; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(175,175,190); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-54,1,0); lbl.Position = UDim2.new(0,4,0,0); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row
    local cb = Instance.new("TextButton"); cb.Size = UDim2.new(0,46,0,20); cb.Position = UDim2.new(1,-48,0.5,-10); cb.BackgroundColor3 = Color3.fromRGB(255,255,255); cb.BackgroundTransparency = 0.82; cb.BorderSizePixel = 0; cb.Font = Enum.Font.GothamBold; cb.TextSize = 10; cb.TextColor3 = Color3.fromRGB(255,255,255); cb.Text = "COPY"; cb.AutoButtonColor = false; cb.ZIndex = 8; cb.Parent = row
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,5); cc.Parent = cb
    cb.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(tostring(getValue())) end)
        cb.Text = "✓"; lbl.TextColor3 = Color3.fromRGB(60,200,80)
        task.delay(1.5, function() cb.Text = "COPY"; lbl.TextColor3 = Color3.fromRGB(175,175,190) end)
    end)
    return lbl
end

-- ── Sidebar ───────────────────────────────────────────────────────────────────

local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0,118,1,-42); sidebar.Position = UDim2.new(0,0,0,41); sidebar.BackgroundColor3 = Color3.fromRGB(0,0,0); sidebar.BackgroundTransparency = 0.5; sidebar.BorderSizePixel = 0; sidebar.ZIndex = 4; sidebar.Parent = main
local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0,4); sl.HorizontalAlignment = Enum.HorizontalAlignment.Center; sl.Parent = sidebar
local sp = Instance.new("UIPadding"); sp.PaddingTop = UDim.new(0,8); sp.PaddingLeft = UDim.new(0,5); sp.PaddingRight = UDim.new(0,5); sp.Parent = sidebar
local sdiv = Instance.new("Frame"); sdiv.Size = UDim2.new(0,1,1,-42); sdiv.Position = UDim2.new(0,118,0,41); sdiv.BackgroundColor3 = Color3.fromRGB(255,255,255); sdiv.BackgroundTransparency = 0.82; sdiv.BorderSizePixel = 0; sdiv.ZIndex = 4; sdiv.Parent = main

local contentArea = Instance.new("Frame"); contentArea.Size = UDim2.new(1,-126,1,-50); contentArea.Position = UDim2.new(0,122,0,46); contentArea.BackgroundTransparency = 1; contentArea.ClipsDescendants = true; contentArea.ZIndex = 4; contentArea.Parent = main

-- ── Tab Builder ───────────────────────────────────────────────────────────────

local tabPages = {}

local function makeTab(name, iconId)
    local btn = Instance.new("Frame"); btn.Size = UDim2.new(1,0,0,32); btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.92; btn.BorderSizePixel = 0; btn.ZIndex = 6; btn.Parent = sidebar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,7); bc.Parent = btn
    local ico = Instance.new("ImageLabel"); ico.Size = UDim2.new(0,14,0,14); ico.Position = UDim2.new(0,7,0.5,-7); ico.BackgroundTransparency = 1; ico.ScaleType = Enum.ScaleType.Fit; ico.ZIndex = 7; ico.Parent = btn
    if iconId and iconId ~= "rbxassetid://0" then setImageAsync(ico, iconId) end
    local bLbl = Instance.new("TextLabel"); bLbl.Text = name; bLbl.Font = Enum.Font.GothamSemibold; bLbl.TextSize = 11; bLbl.TextColor3 = Color3.fromRGB(140,140,140); bLbl.BackgroundTransparency = 1; bLbl.Size = UDim2.new(1,-26,1,0); bLbl.Position = UDim2.new(0,24,0,0); bLbl.TextXAlignment = Enum.TextXAlignment.Left; bLbl.ZIndex = 7; bLbl.Parent = btn
    local click = Instance.new("TextButton"); click.Size = UDim2.new(1,0,1,0); click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 8; click.Parent = btn

    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Color3.fromRGB(255,255,255); page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ZIndex = 5; page.Visible = false; page.Parent = contentArea
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,6); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0,8); pp.PaddingBottom = UDim.new(0,8); pp.PaddingLeft = UDim.new(0,5); pp.PaddingRight = UDim.new(0,8); pp.Parent = page

    tabPages[name] = {page=page, btn=btn, lbl=bLbl}

    click.MouseButton1Click:Connect(function()
        for _, t in pairs(tabPages) do t.page.Visible=false; t.btn.BackgroundTransparency=0.92; t.lbl.TextColor3=Color3.fromRGB(140,140,140) end
        page.Visible=true; btn.BackgroundTransparency=0.65; bLbl.TextColor3=Color3.fromRGB(255,255,255)
    end)
    return page
end

-- ── Build All Tabs ────────────────────────────────────────────────────────────

local mainPage     = makeTab("Main",         cfg.Icon_Main        or "rbxassetid://0")
local aimbotPage   = makeTab("Aimbot",       cfg.Icon_Aimbot      or "rbxassetid://0")
local visPage      = makeTab("Visuals",      cfg.Icon_Visuals     or "rbxassetid://0")
local lpPage       = makeTab("LocalPlayer",  cfg.Icon_LocalPlayer or "rbxassetid://0")
local murdPage     = makeTab("Murderer",     cfg.Icon_Murderer    or "rbxassetid://0")
local sheriffPage  = makeTab("Sheriff",      cfg.Icon_Sheriff     or "rbxassetid://0")
local farmPage     = makeTab("Farm",         cfg.Icon_Farm        or "rbxassetid://0")

-- open Main tab
tabPages["Main"].page.Visible=true; tabPages["Main"].btn.BackgroundTransparency=0.65; tabPages["Main"].lbl.TextColor3=Color3.fromRGB(255,255,255)

-- ── Main Tab ──────────────────────────────────────────────────────────────────

local wS = makeSection(mainPage, "Welcome", 1)
local wL = Instance.new("TextLabel"); wL.Text="Welcome,  "..lp.DisplayName; wL.Font=Enum.Font.GothamBold; wL.TextSize=16; wL.TextColor3=Color3.fromRGB(255,255,255); wL.BackgroundTransparency=1; wL.Size=UDim2.new(1,0,0,24); wL.TextXAlignment=Enum.TextXAlignment.Left; wL.LayoutOrder=1; wL.ZIndex=7; wL.Parent=wS
local uL = Instance.new("TextLabel"); uL.Text="@"..lp.Name; uL.Font=Enum.Font.Gotham; uL.TextSize=11; uL.TextColor3=Color3.fromRGB(130,130,145); uL.BackgroundTransparency=1; uL.Size=UDim2.new(1,0,0,16); uL.TextXAlignment=Enum.TextXAlignment.Left; uL.LayoutOrder=2; uL.ZIndex=7; uL.Parent=wS
local cL = Instance.new("TextLabel"); cL.Text="Created by Crypt0"; cL.Font=Enum.Font.GothamBold; cL.TextSize=10; cL.TextColor3=Color3.fromRGB(90,90,110); cL.BackgroundTransparency=1; cL.Size=UDim2.new(1,0,0,14); cL.TextXAlignment=Enum.TextXAlignment.Left; cL.LayoutOrder=3; cL.ZIndex=7; cL.Parent=wS

local srvS = makeSection(mainPage, "Server", 2)
local jobLbl   = makeCopyRow(srvS, "Job ID:    loading…",  function() return game.JobId   end, 1)
local placeLbl = makeCopyRow(srvS, "Place ID:  loading…",  function() return game.PlaceId end, 2)
local countLbl = makeLabel(srvS, "Players:   loading…", 3)
local pingLbl  = makeCopyRow(srvS, "Ping:      loading…",  function()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
end, 4)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            jobLbl.Text   = "Job ID:    " .. tostring(game.JobId):sub(1,20) .. "…"
            placeLbl.Text = "Place ID:  " .. tostring(game.PlaceId)
            countLbl.Text = "Players:   " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
            pingLbl.Text  = "Ping:      " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        end)
    end
end)

-- ── Aimbot Tab ────────────────────────────────────────────────────────────────

local abS = makeSection(aimbotPage, "Aimbot", 1)
makeToggle(abS, "Enable Aimbot",       false, function(v) _G.AimbotEnabled    = v end, 1)
makeToggle(abS, "Require Right Click", false, function(v) _G.AimbotRightClick = v end, 2)

local tgtS = makeSection(aimbotPage, "Target", 2)
makeToggle(tgtS, "Aim Murderer", false, function(v) _G.AimMurderer = v end, 1)
makeToggle(tgtS, "Aim Sheriff",  false, function(v) _G.AimSheriff  = v end, 2)
makeLabel(tgtS,  "Both off = aim everyone", 3)

local abSet = makeSection(aimbotPage, "Settings", 3)
makeSlider(abSet, "Smoothing",  1,  15,  2,   function(v) _G.AimbotSmoothing = v end, 1)
makeSlider(abSet, "FOV Radius", 20, 600, 250, function(v) _G.AimbotFOV       = v end, 2)
makeToggle(abSet, "Show FOV",        false, function(v) _G.ShowFOV       = v end, 3)
makeToggle(abSet, "FOV RGB",         false, function(v) _G.FovRGB        = v end, 4)
makeToggle(abSet, "Target Tracer",   false, function(v) _G.TargetTracer  = v end, 5)

local tbS = makeSection(aimbotPage, "Triggerbot", 4)
makeToggle(tbS, "Enable Triggerbot", false, function(v) _G.TriggerEnabled = v end, 1)
makeToggle(tbS, "Trigger Murderer",  false, function(v) _G.TriggerMurd    = v end, 2)
makeToggle(tbS, "Trigger Sheriff",   false, function(v) _G.TriggerSheriff = v end, 3)
makeLabel(tbS,   "Both off = trigger all", 4)
makeSlider(tbS, "Trigger FOV", 5, 100, 30, function(v) _G.TriggerFOV = v end, 5)

_G.AimbotEnabled=false;_G.AimbotRightClick=false;_G.AimMurderer=false;_G.AimSheriff=false
_G.AimbotSmoothing=2;_G.AimbotFOV=250;_G.ShowFOV=false;_G.FovRGB=false
_G.TargetTracer=false;_G.TriggerEnabled=false;_G.TriggerMurd=false
_G.TriggerSheriff=false;_G.TriggerFOV=30

-- ── Visuals Tab ───────────────────────────────────────────────────────────────

local espS = makeSection(visPage, "ESP", 1)
makeToggle(espS, "Box ESP",      false, function(v) _G.BoxESP      = v end, 1)
makeToggle(espS, "Chams ESP",    false, function(v) _G.ChamsESP    = v end, 2)
makeToggle(espS, "Name ESP",     false, function(v) _G.NameESP     = v end, 3)
makeToggle(espS, "Distance ESP", false, function(v) _G.DistanceESP = v end, 4)
makeToggle(espS, "Tracers",      false, function(v) _G.Tracers     = v end, 5)

local xhS = makeSection(visPage, "Crosshair", 2)
makeToggle(xhS, "Custom Crosshair", false, function(v) _G.CrosshairEnabled = v end, 1)
makeToggle(xhS, "RGB Mode",         false, function(v) _G.CrosshairRGB     = v end, 2)
makeToggle(xhS, "Red on Player",    true,  function(v) _G.CrosshairRedOnPlayer = v end, 3)
makeSlider(xhS, "Size",       4,  30, 14, function(v) _G.CrosshairSize  = v end, 4)
makeSlider(xhS, "Gap",        0,  12, 4,  function(v) _G.CrosshairGap   = v end, 5)
makeSlider(xhS, "Thickness",  1,  4,  1,  function(v) _G.CrosshairThick = v end, 6)
makeSlider(xhS, "Spin Speed", 1,  20, 5,  function(v) _G.CrosshairSpin  = v end, 7)

_G.BoxESP=false;_G.ChamsESP=false;_G.NameESP=false;_G.DistanceESP=false;_G.Tracers=false
_G.CrosshairEnabled=false;_G.CrosshairRGB=false;_G.CrosshairRedOnPlayer=true
_G.CrosshairSize=14;_G.CrosshairGap=4;_G.CrosshairThick=1;_G.CrosshairSpin=5

-- ── Local Player Tab ──────────────────────────────────────────────────────────

local mvS = makeSection(lpPage, "Movement", 1)
makeToggle(mvS, "Noclip",        false, function(v) _G.NoclipEnabled  = v end, 1)
makeToggle(mvS, "Speedhack",     false, function(v) _G.SpeedEnabled   = v end, 2)
makeToggle(mvS, "Infinite Jump", false, function(v) _G.InfJumpEnabled = v end, 3)
makeSlider(mvS, "Speed Mult",  1, 100, 1, function(v) _G.SpeedMultiplier = v end, 4)

local invS = makeSection(lpPage, "Visibility", 2)
makeToggle(invS, "Invisibility",       false, function(v) _G.InvisEnabled = v end, 1)
makeLabel(invS,  "Server-side: others see nothing", 2)
makeLabel(invS,  "You see your own outline", 3)

local gunS = makeSection(lpPage, "Auto Gun", 3)
makeToggle(gunS, "Auto Collect Gun", false, function(v) _G.AutoGun = v end, 1)
makeLabel(gunS,  "firetouchinterest — instant, no lag", 2)

local afkS = makeSection(lpPage, "Anti-AFK", 4)
makeToggle(afkS, "Anti-AFK", false, function(v) _G.AntiAFK = v end, 1)
makeLabel(afkS,  "Uses VirtualUser input — reliable", 2)

_G.NoclipEnabled=false;_G.SpeedEnabled=false;_G.InfJumpEnabled=false;_G.SpeedMultiplier=1
_G.InvisEnabled=false;_G.AutoGun=false;_G.AntiAFK=false

-- ── Murderer Tab ──────────────────────────────────────────────────────────────

local mkS = makeSection(murdPage, "Knife Tools", 1)
makeToggle(mkS, "Knife Aura",   false, function(v) _G.KnifeAura = v end, 1)
makeSlider(mkS, "Aura Range", 5, 50, 15, function(v) _G.KnifeAuraRange = v end, 2)
makeToggle(mkS, "Auto Stab",    false, function(v) _G.AutoStab  = v end, 3)

local hbS = makeSection(murdPage, "Hitbox Expander", 2)
makeToggle(hbS, "Enable Hitbox", false, function(v) _G.HitboxEnabled = v end, 1)
makeSlider(hbS, "Hitbox Size", 2, 15, 6, function(v) _G.HitboxSize    = v end, 2)
makeLabel(hbS,  "Expands enemy hitboxes client-side", 3)
makeLabel(hbS,  "Walk-through enabled automatically", 4)

_G.KnifeAura=false;_G.KnifeAuraRange=15;_G.AutoStab=false;_G.HitboxEnabled=false;_G.HitboxSize=6

-- ── Sheriff Tab ───────────────────────────────────────────────────────────────

local shS = makeSection(sheriffPage, "Sheriff Tools", 1)
makeToggle(shS, "Auto Shoot Murderer",  false, function(v) _G.AutoShoot     = v end, 1)
makeToggle(shS, "Show Murderer Marker", false, function(v) _G.MurdererArrow = v end, 2)
makeSlider(shS, "Auto Shoot Range", 10, 200, 60, function(v) _G.AutoShootRange = v end, 3)

local shWarn = makeSection(sheriffPage, "Status", 2)
local shStatusLbl = makeLabel(shWarn, "Role status: checking…", 1)

_G.AutoShoot=false;_G.MurdererArrow=false;_G.AutoShootRange=60

-- Update role status labels
task.spawn(function()
    while task.wait(2) do
        local char = lp.Character
        local bp   = lp:FindFirstChild("Backpack")
        local hasGun   = (char and char:FindFirstChild("Gun"))   or (bp and bp:FindFirstChild("Gun"))
        local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if hasKnife then
            shStatusLbl.Text = "You are: Murderer (knife found)"
            shStatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif hasGun then
            shStatusLbl.Text = "You are: Sheriff (gun found)"
            shStatusLbl.TextColor3 = Color3.fromRGB(60, 210, 255)
        else
            shStatusLbl.Text = "You are: Innocent — no Gun/Knife tool"
            shStatusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)

-- ── Farm Tab ──────────────────────────────────────────────────────────────────

local coinS = makeSection(farmPage, "Coin Farm", 1)
makeToggle(coinS, "Auto Collect Coins",   false, function(v) _G.CoinFarm       = v end, 1)
makeToggle(coinS, "Anti-Murderer Safety", true,  function(v) _G.CoinAntiMurd   = v end, 2)
makeSlider(coinS, "Safety Radius", 5, 40, 15, function(v) _G.CoinSafetyRadius = v end, 3)
makeLabel(coinS,  "Noclip auto-enables during farm", 4)

_G.CoinFarm=false;_G.CoinAntiMurd=true;_G.CoinSafetyRadius=15

-- Hint
local hint = Instance.new("TextLabel"); hint.Text="Right Shift — toggle"; hint.Font=Enum.Font.Gotham; hint.TextSize=10; hint.TextColor3=Color3.fromRGB(70,70,80); hint.BackgroundTransparency=1; hint.Size=UDim2.new(1,0,0,14); hint.Position=UDim2.new(0,0,1,-16); hint.TextXAlignment=Enum.TextXAlignment.Center; hint.ZIndex=6; hint.Parent=main
