-- Settings tab: Background + Icon dropdowns

local cfg   = _G.Config or {}
local page  = _G.Pages["Settings"].page

-- Background dropdown
local bgS = _G.UI:MakeSection(page, "Background", 2)
local bgs = cfg.Backgrounds or {}
local bgIdx = cfg.ActiveBackground or 1

local bgLabel = _G.UI:Label(bgS, "BG:  " .. ((bgs[bgIdx] and bgs[bgIdx].Name) or "Default"), 1)

if #bgs > 1 then
    local function applyBG(idx)
        local entry=bgs[idx]; if not entry then return end
        bgIdx=idx; bgLabel.Text="BG:  "..entry.Name
        local cleanId=tostring(entry.Id):match("%d+")
        if _G.UI and _G.UI.BgImg then
            if cleanId and cleanId~="0" then
                _G.UI.BgImg.Image="rbxthumb://type=Asset&id="..cleanId.."&w=420&h=420"
            else _G.UI.BgImg.Image="" end
        end
    end
    _G.UI:Button(bgS, "‹ Prev", 2, function() bgIdx=((bgIdx-2)%#bgs)+1; applyBG(bgIdx) end)
    _G.UI:Button(bgS, "› Next", 3, function() bgIdx=(bgIdx%#bgs)+1;     applyBG(bgIdx) end)
end

-- Icon dropdown
local icoS  = _G.UI:MakeSection(page, "Minimize Icon", 3)
local icons = cfg.MinimizeIcons or {}
local icoIdx = cfg.ActiveMinimizeIcon or 1

local icoLabel = _G.UI:Label(icoS, "Icon:  " .. ((icons[icoIdx] and icons[icoIdx].Name) or "Default"), 1)

if #icons > 1 then
    local function applyIcon(idx)
        local entry=icons[idx]; if not entry then return end
        icoIdx=idx; icoLabel.Text="Icon:  "..entry.Name
        local cleanId=tostring(entry.Id):match("%d+")
        if _G.UI and _G.UI.IconImg then
            if cleanId and cleanId~="0" then
                _G.UI.IconImg.Image="rbxthumb://type=Asset&id="..cleanId.."&w=420&h=420"
            else _G.UI.IconImg.Image="" end
        end
    end
    _G.UI:Button(icoS, "‹ Prev", 2, function() icoIdx=((icoIdx-2)%#icons)+1; applyIcon(icoIdx) end)
    _G.UI:Button(icoS, "› Next", 3, function() icoIdx=(icoIdx%#icons)+1;     applyIcon(icoIdx) end)
end

-- Anti-detect settings
local adS = _G.UI:MakeSection(page, "Anti-Detect", 4)
_G.UI:Toggle(adS, "Randomize Timings", true, function(v) _G.ADRandomTimings=v end, 1)
_G.UI:Label(adS,  "Keep ON — breaks AC timing analysis", 2)
