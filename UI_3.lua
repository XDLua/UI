-- ╔══════════════════════════════════════════════════════════════╗
-- ║  XDLuaUI  v3.0  ·  OBSIDIAN CRIMSON  ·  Mobile + PC        ║
-- ╚══════════════════════════════════════════════════════════════╝

local XDLuaUI   = {}
local TS        = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")
local CoreGui   = game:GetService("CoreGui")
local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")

-- ═══════════════════════════════════
-- DEVICE DETECTION
-- ═══════════════════════════════════
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ═══════════════════════════════════
-- THEME
-- ═══════════════════════════════════
local T = {
    -- Layers
    L0 = Color3.fromRGB(8,  8,  10),   -- darkest bg
    L1 = Color3.fromRGB(14, 14, 18),   -- main panel
    L2 = Color3.fromRGB(20, 20, 26),   -- elevated
    L3 = Color3.fromRGB(28, 28, 36),   -- card / component bg
    L4 = Color3.fromRGB(38, 38, 50),   -- hover

    -- Accent — crimson
    A0 = Color3.fromRGB(180, 18,  45),  -- dim
    A1 = Color3.fromRGB(220, 30,  60),  -- main accent
    A2 = Color3.fromRGB(255, 65, 100),  -- bright
    A3 = Color3.fromRGB(255,130, 155),  -- light tint

    -- Stroke
    S0 = Color3.fromRGB(35, 35, 46),
    S1 = Color3.fromRGB(55, 55, 72),
    S2 = Color3.fromRGB(80, 80,105),

    -- Text
    Tx = Color3.fromRGB(242, 242, 248),
    Tm = Color3.fromRGB(155, 155, 175),
    Td = Color3.fromRGB( 85,  85, 105),

    -- Status
    Green = Color3.fromRGB(45, 210, 110),
    Yellow= Color3.fromRGB(255, 195, 55),
    Red   = Color3.fromRGB(220, 55,  55),

    -- Radius
    R4  = UDim.new(0, 4),
    R6  = UDim.new(0, 6),
    R8  = UDim.new(0, 8),
    R10 = UDim.new(0, 10),
    R12 = UDim.new(0, 12),
    Rf  = UDim.new(1, 0),

    -- Tween speeds
    Q = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    N = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    S = TweenInfo.new(0.45, Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- ═══════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════
local function Tw(obj, goal, spd)
    local info = (spd=="q" and T.Q) or (spd=="s" and T.S) or (spd=="b" and T.Bounce) or T.N
    local t = TS:Create(obj, info, goal); t:Play(); return t
end

local function New(cls, props, parent)
    local o = Instance.new(cls)
    if parent then o.Parent = parent end
    for k,v in pairs(props or {}) do o[k] = v end
    return o
end

local function Corner(r, p)
    return New("UICorner",{CornerRadius=r or T.R8}, p)
end

local function Stroke(c, th, p)
    return New("UIStroke",{Color=c or T.S0, Thickness=th or 1}, p)
end

local function Pad(l,r,t,b, p)
    return New("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),  PaddingBottom=UDim.new(0,b or 0)
    }, p)
end

local function Shadow(parent, str)
    str = str or 0.55
    local s = New("ImageLabel",{
        Name="_Shadow", AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.new(0.5,0, 0.5,8),
        Size=UDim2.new(1,46, 1,46),
        ZIndex=math.max(1,(parent.ZIndex or 1)-1),
        Image="rbxassetid://6015897843",
        ImageColor3=Color3.fromRGB(0,0,0),
        ImageTransparency=str,
        ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450)
    }, parent)
    return s
end

local function GlowLine(parent, w, h, pos, col)
    local f = New("Frame",{
        Size=w, Position=pos,
        BackgroundColor3=col or T.A1,
        BorderSizePixel=0,
        ZIndex=(parent.ZIndex or 1)+1
    }, parent)
    Corner(T.Rf, f)
    -- Gradient glow
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.3, col or T.A1),
            ColorSequenceKeypoint.new(0.7, col or T.A1),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        }),
        Rotation=0
    }, f)
    return f
end

-- Draggable (Mouse + Touch)
local function Draggable(handle, target)
    local drag, inp, start, spos = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; inp=nil
            start=i.Position; spos=target.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then drag=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then inp=i end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i==inp then
            local d=i.Position-start
            target.Position=UDim2.new(
                spos.X.Scale, spos.X.Offset+d.X,
                spos.Y.Scale, spos.Y.Offset+d.Y)
        end
    end)
end

-- Ripple
local function Ripple(btn)
    btn.MouseButton1Click:Connect(function()
        local c=New("Frame",{
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=0.82,
            BorderSizePixel=0,
            ZIndex=(btn.ZIndex or 1)+5,
            AnchorPoint=Vector2.new(0.5,0.5)
        }, btn)
        Corner(T.Rf, c)
        local mp = UIS:GetMouseLocation() - btn.AbsolutePosition
        c.Position=UDim2.new(0,mp.X, 0,mp.Y)
        c.Size=UDim2.new(0,0,0,0)
        local sz=math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)*2.8
        Tw(c,{Size=UDim2.new(0,sz,0,sz), BackgroundTransparency=1},"n")
        task.delay(0.28, function() c:Destroy() end)
    end)
end

-- ═══════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════
local _notifParent = nil

local function EnsureNotif(sg)
    if _notifParent and _notifParent.Parent then return end
    _notifParent = New("Frame",{
        Name="_Notifs",
        Size=UDim2.new(0, IsMobile and 260 or 295, 1,0),
        Position=UDim2.new(1, IsMobile and -270 or -305, 0,0),
        BackgroundTransparency=1, ZIndex=200
    }, sg)
    local lay=New("UIListLayout",{
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        Padding=UDim.new(0,6)
    }, _notifParent)
    Pad(0,0,0,14, _notifParent)
end

function XDLuaUI:Notify(title, msg, ntype, dur)
    if not (_notifParent and _notifParent.Parent) then return end
    dur = dur or 4
    local palette = {
        info    = {T.A1,  "●"},
        success = {T.Green,"✓"},
        warning = {T.Yellow,"!"},
        error   = {T.Red,  "✕"},
    }
    local nt = ntype or "info"
    local col, ico = palette[nt][1], palette[nt][2]

    local card = New("Frame",{
        Size=UDim2.new(1,0, 0, IsMobile and 68 or 72),
        BackgroundColor3=T.L2,
        Position=UDim2.new(1.15,0, 0,0),
        ZIndex=201
    }, _notifParent)
    Corner(T.R10, card)
    Stroke(T.S0, 1, card)
    Shadow(card, 0.45)

    -- Left glow bar
    local bar = New("Frame",{
        Size=UDim2.new(0,3, 1,-16),
        Position=UDim2.new(0,0, 0,8),
        BackgroundColor3=col, BorderSizePixel=0, ZIndex=202
    }, card)
    Corner(T.Rf, bar)

    -- Icon badge
    local badge = New("Frame",{
        Size=UDim2.new(0,30, 0,30),
        Position=UDim2.new(0,14, 0.5,-15),
        BackgroundColor3=col, ZIndex=202
    }, card)
    Corner(T.R8, badge)
    Tw(badge, {BackgroundTransparency=0.78})
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0), Text=ico,
        TextColor3=col, Font=Enum.Font.GothamBlack,
        TextSize=14, BackgroundTransparency=1, ZIndex=203
    }, badge)

    -- Title
    New("TextLabel",{
        Size=UDim2.new(1,-56, 0,20),
        Position=UDim2.new(0,52, 0,11),
        Text=title, TextColor3=T.Tx,
        Font=Enum.Font.GothamBold, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1, ZIndex=202
    }, card)

    -- Message
    New("TextLabel",{
        Size=UDim2.new(1,-56, 0,26),
        Position=UDim2.new(0,52, 0,31),
        Text=msg, TextColor3=T.Tm,
        Font=Enum.Font.Gotham, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, BackgroundTransparency=1, ZIndex=202
    }, card)

    -- Progress
    local pbg = New("Frame",{
        Size=UDim2.new(1,-14,0,2),
        Position=UDim2.new(0,7,1,-4),
        BackgroundColor3=T.L3, BorderSizePixel=0, ZIndex=202
    }, card)
    Corner(T.Rf, pbg)
    local pf = New("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=col,
        BorderSizePixel=0, ZIndex=203
    }, pbg)
    Corner(T.Rf, pf)

    Tw(card, {Position=UDim2.new(0,0,0,0)}, "s")
    TS:Create(pf, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()

    task.delay(dur, function()
        Tw(card, {Position=UDim2.new(1.15,0,0,0)}, "n")
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ═══════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════
function XDLuaUI:CreateWindow(cfg)
    if type(cfg)=="string" then cfg={Title=cfg} end
    cfg = cfg or {}
    local TITLE   = cfg.Title or "CRIMSON SCRIPT"
    local SUB     = cfg.Sub   or "v3.0"
    local LOGO    = cfg.Logo  or "rbxassetid://111935661110067"

    -- Window size — adaptive
    local WIN_W = IsMobile and 340 or 530
    local WIN_H = IsMobile and 480 or 380
    local TAB_W = IsMobile and WIN_W or 138

    if CoreGui:FindFirstChild("XDLuaGUI") then
        CoreGui:FindFirstChild("XDLuaGUI"):Destroy()
    end

    local SG = New("ScreenGui",{
        Name="XDLuaGUI", IgnoreGuiInset=true,
        ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    }, CoreGui)
    EnsureNotif(SG)

    -- ═══════════════
    -- LOADING SCREEN
    -- ═══════════════
    local blur = Instance.new("BlurEffect", game.Lighting)
    blur.Size = 0
    Tw(blur, {Size=28}, "s")

    local overlay = New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.L0,
        BackgroundTransparency=0.2,
        BorderSizePixel=0, ZIndex=50
    }, SG)

    -- Scanlines texture overlay
    local scanlines = New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, ZIndex=51
    }, overlay)
    New("UIGradient",{
        Color=ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0)),
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.96),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation=90,
        Offset=Vector2.new(0, 0)
    }, scanlines)

    local card = New("Frame",{
        Size=UDim2.new(0, IsMobile and 280 or 340, 0, IsMobile and 220 or 230),
        Position=UDim2.new(0.5, IsMobile and -140 or -170, 0.5, IsMobile and -110 or -115),
        BackgroundColor3=T.L1,
        BackgroundTransparency=1, ZIndex=52
    }, SG)
    Corner(T.R12, card)

    local cstroke = Stroke(T.A1, 1.5, card)
    cstroke.Transparency = 1

    -- Corner accents
    local function CornerAccent(ancX, ancY, rotX, rotY)
        local cf = New("Frame",{
            Size=UDim2.new(0,18,0,18),
            AnchorPoint=Vector2.new(ancX,ancY),
            Position=UDim2.new(ancX,ancX==0 and 8 or -8, ancY, ancY==0 and 8 or -8),
            BackgroundTransparency=1, ZIndex=53
        }, card)
        New("Frame",{Size=UDim2.new(1,0,0,1.5),BackgroundColor3=T.A1,BorderSizePixel=0,ZIndex=54},cf)
        New("Frame",{Size=UDim2.new(0,1.5,1,0),BackgroundColor3=T.A1,BorderSizePixel=0,ZIndex=54},cf)
    end
    CornerAccent(0,0)
    CornerAccent(1,0)
    CornerAccent(0,1)
    CornerAccent(1,1)

    -- Logo
    local logoBg = New("Frame",{
        Size=UDim2.new(0,52,0,52),
        Position=UDim2.new(0.5,-26, 0,20),
        BackgroundColor3=T.L2, ZIndex=53
    }, card)
    Corner(T.R10, logoBg)
    Stroke(T.S1, 1, logoBg)
    New("ImageLabel",{
        Size=UDim2.new(0.72,0,0.72,0),
        Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1, Image=LOGO,
        ScaleType=Enum.ScaleType.Fit, ZIndex=54
    }, logoBg)

    -- Pulse ring animation
    local ring = New("Frame",{
        Size=UDim2.new(0,52,0,52),
        Position=UDim2.new(0.5,-26, 0,20),
        BackgroundTransparency=1, ZIndex=52
    }, card)
    Corner(T.Rf, ring)
    Stroke(T.A1, 1.5, ring)

    task.spawn(function()
        while ring.Parent do
            Tw(ring, {Size=UDim2.new(0,72,0,72), Position=UDim2.new(0.5,-36,0,10)}, "s")
            Tw(New("UIStroke",nil,ring), {Transparency=1}, "s")
            task.wait(0.5)
            ring.Size=UDim2.new(0,52,0,52)
            ring.Position=UDim2.new(0.5,-26,0,20)
            local str = ring:FindFirstChildOfClass("UIStroke")
            if str then str.Transparency=0.3 end
            task.wait(0.4)
        end
    end)

    local titleLoad = New("TextLabel",{
        Size=UDim2.new(1,0,0,28),
        Position=UDim2.new(0,0,0,82),
        Text=TITLE, TextColor3=T.Tx,
        TextTransparency=1, Font=Enum.Font.GothamBlack,
        TextSize=IsMobile and 18 or 20, BackgroundTransparency=1, ZIndex=53
    }, card)

    local subLoad = New("TextLabel",{
        Size=UDim2.new(1,0,0,16),
        Position=UDim2.new(0,0,0,112),
        Text=SUB, TextColor3=T.A1,
        TextTransparency=1, Font=Enum.Font.GothamMedium,
        TextSize=11, BackgroundTransparency=1, ZIndex=53
    }, card)

    -- Bar track
    local barTrack = New("Frame",{
        Size=UDim2.new(0.82,0, 0,3),
        Position=UDim2.new(0.09,0, 0, IsMobile and 148 or 158),
        BackgroundColor3=T.L3, BackgroundTransparency=1,
        ZIndex=53
    }, card)
    Corner(T.Rf, barTrack)
    Stroke(T.S0, 0.5, barTrack)

    local barFill = New("Frame",{
        Size=UDim2.new(0,0,1,0),
        BackgroundColor3=T.A1,
        BorderSizePixel=0, ZIndex=54
    }, barTrack)
    Corner(T.Rf, barFill)

    -- Glow on bar fill
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.A0),
            ColorSequenceKeypoint.new(0.6, T.A1),
            ColorSequenceKeypoint.new(1, T.A2),
        })
    }, barFill)

    local barDot = New("Frame",{
        Size=UDim2.new(0,7,0,7),
        Position=UDim2.new(1,-3.5, 0.5,-3.5),
        BackgroundColor3=T.A2, ZIndex=55
    }, barFill)
    Corner(T.Rf, barDot)

    local statusLoad = New("TextLabel",{
        Size=UDim2.new(1,0,0,16),
        Position=UDim2.new(0,0,0, IsMobile and 162 or 172),
        Text="กำลังเริ่มต้น...", TextColor3=T.Td,
        TextTransparency=1, Font=Enum.Font.Gotham,
        TextSize=10, BackgroundTransparency=1, ZIndex=53
    }, card)

    Shadow(card, 0.35)

    -- Fade In
    Tw(card,       {BackgroundTransparency=0},    "s")
    Tw(cstroke,    {Transparency=0.5},            "s")
    Tw(titleLoad,  {TextTransparency=0},          "s")
    Tw(subLoad,    {TextTransparency=0},          "s")
    Tw(barTrack,   {BackgroundTransparency=0},    "s")
    Tw(statusLoad, {TextTransparency=0},          "s")
    task.wait(0.55)

    -- Status cycling
    local statMsgs = {
        {0.6, "กำลังโหลดโมดูล..."},
        {1.0, "ตรวจสอบเวอร์ชัน..."},
        {1.6, "เตรียม UI Components..."},
        {2.4, "เกือบเสร็จแล้ว..."},
    }
    task.spawn(function()
        for _, v in ipairs(statMsgs) do
            task.wait(v[1])
            Tw(statusLoad, {TextTransparency=1}, "q")
            task.wait(0.1)
            statusLoad.Text = v[2]
            Tw(statusLoad, {TextTransparency=0}, "q")
        end
    end)

    local ft = TS:Create(barFill,
        TweenInfo.new(3.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Size=UDim2.new(1,0,1,0)})
    ft:Play(); ft.Completed:Wait()

    statusLoad.Text = "✓  พร้อมใช้งาน!"
    Tw(statusLoad, {TextColor3=T.Green})
    task.wait(0.55)

    -- Fade Out
    for _, o in ipairs({card, overlay}) do
        Tw(o, {BackgroundTransparency=1}, "n")
    end
    Tw(cstroke,   {Transparency=1}, "n")
    Tw(titleLoad, {TextTransparency=1}, "n")
    Tw(subLoad,   {TextTransparency=1}, "n")
    Tw(barTrack,  {BackgroundTransparency=1}, "n")
    Tw(statusLoad,{TextTransparency=1}, "n")
    Tw(blur,      {Size=0}, "n")
    task.wait(0.3)
    blur:Destroy(); card:Destroy(); overlay:Destroy()

    -- ═══════════════
    -- FLOATING LOGO BUTTON
    -- ═══════════════
    local logoBtn = New("TextButton",{
        Name="LogoBtn",
        Size=UDim2.new(0, IsMobile and 52 or 46, 0, IsMobile and 52 or 46),
        Position=UDim2.new(0.05,0, 0.1,0),
        BackgroundColor3=T.L1,
        Text="", AutoButtonColor=false, Active=true, ZIndex=10
    }, SG)
    Corner(T.R10, logoBtn)
    local lbStroke = Stroke(T.A1, 1.5, logoBtn)
    New("ImageLabel",{
        Size=UDim2.new(0.68,0,0.68,0),
        Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Image=LOGO, ScaleType=Enum.ScaleType.Fit, ZIndex=11
    }, logoBtn)
    Shadow(logoBtn, 0.42)
    Draggable(logoBtn, logoBtn)

    logoBtn.MouseEnter:Connect(function()
        Tw(logoBtn, {Size=UDim2.new(0, IsMobile and 58 or 52, 0, IsMobile and 58 or 52)}, "q")
        Tw(lbStroke, {Color=T.A2, Thickness=2}, "q")
    end)
    logoBtn.MouseLeave:Connect(function()
        Tw(logoBtn, {Size=UDim2.new(0, IsMobile and 52 or 46, 0, IsMobile and 52 or 46)}, "q")
        Tw(lbStroke, {Color=T.A1, Thickness=1.5}, "q")
    end)

    -- ═══════════════
    -- MAIN FRAME
    -- ═══════════════
    local mainFrame = New("Frame",{
        Name="MainFrame",
        Size=UDim2.new(0,WIN_W, 0,WIN_H),
        Position=UDim2.new(0.5,-WIN_W/2, 0.5,-WIN_H/2),
        BackgroundColor3=T.L1, ZIndex=3
    }, SG)
    Corner(T.R12, mainFrame)
    Stroke(T.S0, 1, mainFrame)
    Shadow(mainFrame, 0.30)

    -- Subtle background pattern (grid dots)
    local patternImg = New("ImageLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Image="rbxassetid://3570695787",
        ImageTransparency=0.97,
        ScaleType=Enum.ScaleType.Tile,
        TileSize=UDim2.new(0,32,0,32),
        ZIndex=3
    }, mainFrame)
    Corner(T.R12, patternImg)

    -- Top accent line (thin crimson)
    GlowLine(mainFrame,
        UDim2.new(0.55,0, 0,1.5),
        UDim2.new(0.225,0, 0,0))

    -- ═══════════════
    -- TITLE BAR
    -- ═══════════════
    local titleBar = New("Frame",{
        Size=UDim2.new(1,0, 0, IsMobile and 50 or 46),
        BackgroundColor3=T.L2, ZIndex=4
    }, mainFrame)
    -- Rounded top only
    Corner(T.R12, titleBar)
    local tbFix = New("Frame",{
        Size=UDim2.new(1,0, 0.5,0),
        Position=UDim2.new(0,0, 0.5,0),
        BackgroundColor3=T.L2, BorderSizePixel=0, ZIndex=4
    }, titleBar)
    -- Bottom separator
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.S0, BorderSizePixel=0, ZIndex=5
    }, titleBar)

    -- Logo mini in titlebar
    local tbLogo = New("ImageLabel",{
        Size=UDim2.new(0,22,0,22),
        Position=UDim2.new(0,12,0.5,-11),
        BackgroundTransparency=1, Image=LOGO,
        ScaleType=Enum.ScaleType.Fit, ZIndex=5
    }, titleBar)

    New("TextLabel",{
        Size=UDim2.new(0, IsMobile and 160 or 200, 1,0),
        Position=UDim2.new(0,40, 0,0),
        Text=TITLE, TextColor3=T.Tx,
        Font=Enum.Font.GothamBold,
        TextSize=IsMobile and 13 or 14,
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1, ZIndex=5
    }, titleBar)

    New("TextLabel",{
        Size=UDim2.new(0,50,1,0),
        Position=UDim2.new(0,40 + (IsMobile and 165 or 205), 0,0),
        Text=SUB, TextColor3=T.A1,
        Font=Enum.Font.GothamMedium, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1, ZIndex=5
    }, titleBar)

    -- Window control buttons
    local function WBtn(xOff, bg, txt)
        local b = New("TextButton",{
            Size=UDim2.new(0, IsMobile and 30 or 24, 0, IsMobile and 30 or 24),
            Position=UDim2.new(1, xOff, 0.5, IsMobile and -15 or -12),
            BackgroundColor3=bg, Text=txt,
            TextColor3=T.Tx, TextSize=IsMobile and 15 or 13,
            Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=5
        }, titleBar)
        Corner(T.R6, b)
        b.MouseEnter:Connect(function() Tw(b,{BackgroundTransparency=0.25},"q") end)
        b.MouseLeave:Connect(function() Tw(b,{BackgroundTransparency=0},"q") end)
        return b
    end

    local closeBtn = WBtn(IsMobile and -38 or -32, T.Red,   "×")
    local miniBtn  = WBtn(IsMobile and -76 or -62, T.L3,    "−")

    local minimized = false
    closeBtn.MouseButton1Click:Connect(function()
        Tw(mainFrame,{Size=UDim2.new(0,WIN_W,0,0), BackgroundTransparency=1},"n")
        task.wait(0.28); SG:Destroy()
    end)
    miniBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local h = minimized and (IsMobile and 50 or 46) or WIN_H
        Tw(mainFrame, {Size=UDim2.new(0,WIN_W,0,h)}, "n")
    end)
    Draggable(titleBar, mainFrame)

    logoBtn.MouseButton1Click:Connect(function()
        if mainFrame.Visible then
            Tw(mainFrame, {Size=UDim2.new(0,WIN_W,0,0)}, "n")
            task.wait(0.25); mainFrame.Visible=false
            mainFrame.Size=UDim2.new(0,WIN_W,0,WIN_H)
        else
            mainFrame.Visible=true
            mainFrame.Size=UDim2.new(0,WIN_W,0,0)
            Tw(mainFrame, {Size=UDim2.new(0,WIN_W,0,WIN_H)}, "b")
        end
    end)

    -- ═══════════════
    -- SIDEBAR (PC) / BOTTOM TABS (Mobile)
    -- ═══════════════
    local tabs = {}
    local activeTab = nil

    -- Mobile: bottom tab bar
    -- PC: left sidebar
    local sidebar, tabScrollFrame

    if IsMobile then
        -- Bottom tab row
        sidebar = New("Frame",{
            Size=UDim2.new(1,0, 0,50),
            Position=UDim2.new(0,0, 1,-50),
            BackgroundColor3=T.L2, ZIndex=4
        }, mainFrame)
        New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.S0,BorderSizePixel=0,ZIndex=5},sidebar)
        local sbFix=New("Frame",{
            Size=UDim2.new(1,0,0,12),
            BackgroundColor3=T.L2,BorderSizePixel=0,ZIndex=4
        },sidebar)
        tabScrollFrame = New("ScrollingFrame",{
            Size=UDim2.new(1,-8, 1,0),
            Position=UDim2.new(0,4, 0,0),
            BackgroundTransparency=1,
            ScrollBarThickness=0,
            ScrollingDirection=Enum.ScrollingDirection.X,
            AutomaticCanvasSize=Enum.AutomaticSize.X,
            ZIndex=5
        }, sidebar)
        New("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal,
            VerticalAlignment=Enum.VerticalAlignment.Center,
            Padding=UDim.new(0,4)
        }, tabScrollFrame)
        Pad(4,4,0,0, tabScrollFrame)
    else
        sidebar = New("Frame",{
            Size=UDim2.new(0,TAB_W, 1,-(IsMobile and 50 or 46)),
            Position=UDim2.new(0,0, 0, IsMobile and 0 or 46),
            BackgroundColor3=T.L2, ZIndex=4
        }, mainFrame)
        -- Right separator
        New("Frame",{
            Size=UDim2.new(0,1,1,0),
            Position=UDim2.new(1,-1,0,0),
            BackgroundColor3=T.S0, BorderSizePixel=0, ZIndex=5
        }, sidebar)
        -- Fix top corner
        New("Frame",{
            Size=UDim2.new(1,0,0,12),
            BackgroundColor3=T.L2, BorderSizePixel=0, ZIndex=4
        }, sidebar)
        tabScrollFrame = New("ScrollingFrame",{
            Size=UDim2.new(1,0, 1,-8),
            Position=UDim2.new(0,0, 0,8),
            BackgroundTransparency=1,
            ScrollBarThickness=0,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ZIndex=5
        }, sidebar)
        local tlay=New("UIListLayout",{
            Padding=UDim.new(0,3),
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder
        }, tabScrollFrame)
        Pad(0,0,6,6, tabScrollFrame)
    end

    -- ═══════════════
    -- CONTENT AREA
    -- ═══════════════
    local contentArea = New("Frame",{
        Size = IsMobile
            and UDim2.new(1,-8, 1,-(46+50+8))
            or  UDim2.new(1,-(TAB_W+12), 1,-(46+8)),
        Position = IsMobile
            and UDim2.new(0,4, 0,50)
            or  UDim2.new(0,TAB_W+6, 0,52),
        BackgroundColor3=T.L2,
        ZIndex=4
    }, mainFrame)
    Corner(T.R10, contentArea)
    Stroke(T.S0, 1, contentArea)

    -- ═══════════════
    -- ORDER TRACKER
    -- ═══════════════
    local function GetOrder(parent)
        for _, t in pairs(tabs) do
            if t.Content == parent then
                t._o = (t._o or 0) + 1; return t._o
            end
        end; return 0
    end

    -- ══════════════════════════════
    -- PUBLIC: AddTab
    -- ══════════════════════════════
    function XDLuaUI:AddTab(name, emoji)
        local isFirst = not next(tabs)
        local btn

        if IsMobile then
            -- Pill button (horizontal)
            btn = New("TextButton",{
                Size=UDim2.new(0,0, 0,38),
                AutomaticSize=Enum.AutomaticSize.X,
                BackgroundColor3=isFirst and T.L3 or T.L2,
                BackgroundTransparency=isFirst and 0 or 1,
                Text=(emoji or "▸").." "..name,
                TextColor3=isFirst and T.Tx or T.Tm,
                Font=Enum.Font.GothamMedium,
                TextSize=12, AutoButtonColor=false, ZIndex=6
            }, tabScrollFrame)
            Corner(T.R8, btn)
            Pad(10,10,0,0, btn)
        else
            btn = New("TextButton",{
                Size=UDim2.new(0.92,0, 0,36),
                BackgroundColor3=isFirst and T.L3 or T.L2,
                BackgroundTransparency=isFirst and 0 or 1,
                Text=(emoji or "▸").."  "..name,
                TextColor3=isFirst and T.Tx or T.Tm,
                Font=Enum.Font.GothamMedium,
                TextSize=12, AutoButtonColor=false, ZIndex=6
            }, tabScrollFrame)
            Corner(T.R8, btn)

            -- Active indicator dot
            local ind = New("Frame",{
                Size=UDim2.new(0,3, 0.55,0),
                Position=UDim2.new(0,0, 0.225,0),
                BackgroundColor3=T.A1,
                BorderSizePixel=0,
                Visible=isFirst, ZIndex=7
            }, btn)
            Corner(T.Rf, ind)
            tabs[name] = tabs[name] or {}
            tabs[name].Ind = ind
        end

        -- Content scroll
        local content = New("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=3,
            ScrollBarImageColor3=T.A1,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=isFirst, ZIndex=5,
            CanvasPosition=Vector2.zero
        }, contentArea)
        New("UIListLayout",{
            Padding=UDim.new(0,6),
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder
        }, content)
        Pad(0,0,8,8, content)

        local function Activate()
            for _, t in pairs(tabs) do
                Tw(t.Btn,{BackgroundTransparency=1, TextColor3=T.Tm},"q")
                t.Content.Visible=false
                if t.Ind then t.Ind.Visible=false end
            end
            Tw(btn,{BackgroundTransparency=0, TextColor3=T.Tx},"q")
            btn.BackgroundColor3=T.L3
            content.Visible=true
            if tabs[name] and tabs[name].Ind then tabs[name].Ind.Visible=true end
            activeTab=name
        end

        btn.MouseButton1Click:Connect(Activate)
        btn.MouseEnter:Connect(function()
            if activeTab~=name then Tw(btn,{BackgroundTransparency=0.65},"q") end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=name then Tw(btn,{BackgroundTransparency=1},"q") end
        end)

        tabs[name] = tabs[name] or {}
        tabs[name].Btn     = btn
        tabs[name].Content = content
        tabs[name]._o      = 0
        if isFirst then activeTab=name end

        return content
    end

    -- ══════════════════════════════
    -- COMPONENT HELPERS
    -- ══════════════════════════════

    local function BaseCard(parent, h)
        local f = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0, 0, h or 38),
            BackgroundColor3=T.L3, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, f)
        Stroke(T.S0, 0.8, f)
        return f
    end

    -- Section
    function XDLuaUI:AddSection(parent, text)
        local row = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0,24),
            BackgroundTransparency=1, ZIndex=parent.ZIndex+1
        }, parent)
        local lbl = New("TextLabel",{
            Size=UDim2.new(0,0,1,0),
            AutomaticSize=Enum.AutomaticSize.X,
            Text=("  "..text):upper(),
            TextColor3=T.A1,
            Font=Enum.Font.GothamBold, TextSize=9.5,
            TextXAlignment=Enum.TextXAlignment.Left,
            BackgroundTransparency=1, ZIndex=row.ZIndex+1
        }, row)
        task.defer(function()
            local line = New("Frame",{
                Size=UDim2.new(1, -(lbl.AbsoluteSize.X+8), 0, 1),
                Position=UDim2.new(0, lbl.AbsoluteSize.X+6, 0.5, 0),
                BackgroundColor3=T.S0, BorderSizePixel=0, ZIndex=row.ZIndex+1
            }, row)
            New("UIGradient",{
                Transparency=NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0),
                    NumberSequenceKeypoint.new(1,1)
                })
            }, line)
        end)
        return row
    end

    -- Label
    function XDLuaUI:AddLabel(parent, text, col)
        local lbl = New("TextLabel",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0,20),
            Text=text, TextColor3=col or T.Tm,
            Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true, BackgroundTransparency=1,
            ZIndex=parent.ZIndex+1
        }, parent)
        Pad(10,0,0,0,lbl)
        return lbl
    end

    -- Divider
    function XDLuaUI:AddDivider(parent)
        local d = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.9,0,0,1),
            BackgroundColor3=T.S0, BorderSizePixel=0,
            ZIndex=parent.ZIndex+1
        }, parent)
        New("UIGradient",{
            Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,1),
                NumberSequenceKeypoint.new(0.2,0),
                NumberSequenceKeypoint.new(0.8,0),
                NumberSequenceKeypoint.new(1,1)
            })
        }, d)
        return d
    end

    -- Button
    function XDLuaUI:AddButton(parent, text, callback)
        local btn = New("TextButton",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 42 or 37),
            BackgroundColor3=T.L3,
            Text="", AutoButtonColor=false, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, btn)
        local bStroke = Stroke(T.S0, 0.8, btn)

        New("TextLabel",{
            Size=UDim2.new(1,-10,1,0),
            Position=UDim2.new(0,10,0,0),
            Text=text, TextColor3=T.Tx,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Center,
            BackgroundTransparency=1, ZIndex=btn.ZIndex+1
        }, btn)

        -- Right arrow
        New("TextLabel",{
            Size=UDim2.new(0,20,1,0),
            Position=UDim2.new(1,-24,0,0),
            Text="›", TextColor3=T.A1,
            Font=Enum.Font.GothamBold, TextSize=18,
            BackgroundTransparency=1, ZIndex=btn.ZIndex+1
        }, btn)

        btn.MouseEnter:Connect(function()
            Tw(btn, {BackgroundColor3=T.L4}, "q")
            Tw(bStroke, {Color=T.A1}, "q")
        end)
        btn.MouseLeave:Connect(function()
            Tw(btn, {BackgroundColor3=T.L3}, "q")
            Tw(bStroke, {Color=T.S0}, "q")
        end)
        btn.MouseButton1Down:Connect(function()
            Tw(btn, {BackgroundColor3=T.L2}, "q")
        end)
        btn.MouseButton1Up:Connect(function()
            Tw(btn, {BackgroundColor3=T.L4}, "q")
        end)

        Ripple(btn)
        btn.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)
        return btn
    end

    -- Toggle
    function XDLuaUI:AddToggle(parent, text, default, callback)
        local on = default==true
        local row = New("TextButton",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 44 or 38),
            BackgroundColor3=T.L3,
            Text="", AutoButtonColor=false, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, row)
        Stroke(T.S0, 0.8, row)

        New("TextLabel",{
            Size=UDim2.new(1,-64,1,0),
            Position=UDim2.new(0,12,0,0),
            Text=text, TextColor3=on and T.Tx or T.Tm,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Left,
            BackgroundTransparency=1, ZIndex=row.ZIndex+1,
            Name="lbl"
        }, row)

        -- Pill
        local pillW, pillH = IsMobile and 44 or 38, IsMobile and 24 or 20
        local pill = New("Frame",{
            Size=UDim2.new(0,pillW, 0,pillH),
            Position=UDim2.new(1,-(pillW+10), 0.5,-pillH/2),
            BackgroundColor3=on and T.A1 or T.S1, ZIndex=row.ZIndex+1
        }, row)
        Corner(T.Rf, pill)

        -- Inner glow when on
        local pillGlow = New("UIStroke",{
            Color=T.A2, Thickness=1,
            Transparency=on and 0.5 or 1
        }, pill)

        local dotS = pillH-6
        local dot = New("Frame",{
            Size=UDim2.new(0,dotS,0,dotS),
            Position=on and UDim2.new(1,-(dotS+3), 0.5,-dotS/2)
                        or  UDim2.new(0,3, 0.5,-dotS/2),
            BackgroundColor3=T.Tx, ZIndex=pill.ZIndex+1
        }, pill)
        Corner(T.Rf, dot)

        local lbl = row:FindFirstChild("lbl")

        local function Set(val)
            on=val
            Tw(pill,{BackgroundColor3=on and T.A1 or T.S1},"q")
            Tw(pillGlow,{Transparency=on and 0.5 or 1},"q")
            Tw(dot,{Position=on and UDim2.new(1,-(dotS+3),0.5,-dotS/2)
                              or  UDim2.new(0,3,0.5,-dotS/2)},"q")
            if lbl then Tw(lbl,{TextColor3=on and T.Tx or T.Tm},"q") end
            if callback then pcall(callback, on) end
        end

        row.MouseButton1Click:Connect(function() Set(not on) end)
        row.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=T.L4},"q") end)
        row.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=T.L3},"q") end)

        local API={}
        function API:Set(v) Set(v) end
        function API:Get() return on end
        return API
    end

    -- Slider
    function XDLuaUI:AddSlider(parent, text, min, max, default, callback)
        min=min or 0; max=max or 100
        default=math.clamp(default or min, min, max)
        local cur=default

        local frame = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 58 or 52),
            BackgroundColor3=T.L3, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, frame)
        Stroke(T.S0, 0.8, frame)
        Pad(12,12,0,0,frame)

        New("TextLabel",{
            Size=UDim2.new(0.62,0, 0,24),
            Position=UDim2.new(0,0,0, IsMobile and 8 or 5),
            Text=text, TextColor3=T.Tm,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 13 or 12,
            TextXAlignment=Enum.TextXAlignment.Left,
            BackgroundTransparency=1, ZIndex=frame.ZIndex+1
        }, frame)

        local valLbl = New("TextLabel",{
            Size=UDim2.new(0.38,0, 0,24),
            Position=UDim2.new(0.62,0, 0, IsMobile and 8 or 5),
            Text=tostring(default),
            TextColor3=T.A2, Font=Enum.Font.GothamBold,
            TextSize=IsMobile and 13 or 12,
            TextXAlignment=Enum.TextXAlignment.Right,
            BackgroundTransparency=1, ZIndex=frame.ZIndex+1
        }, frame)

        local trackY = IsMobile and 36 or 32
        local track = New("Frame",{
            Size=UDim2.new(1,0, 0, IsMobile and 6 or 5),
            Position=UDim2.new(0,0, 0,trackY),
            BackgroundColor3=T.L2, ZIndex=frame.ZIndex+1
        }, frame)
        Corner(T.Rf, track)

        local fill = New("Frame",{
            Size=UDim2.new((default-min)/(max-min), 0, 1,0),
            BackgroundColor3=T.A1, ZIndex=track.ZIndex+1
        }, track)
        Corner(T.Rf, fill)
        New("UIGradient",{
            Color=ColorSequence.new(T.A0, T.A2)
        }, fill)

        local thumbSz = IsMobile and 16 or 14
        local thumb = New("Frame",{
            Size=UDim2.new(0,thumbSz,0,thumbSz),
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new((default-min)/(max-min), 0, 0.5,0),
            BackgroundColor3=T.Tx, ZIndex=track.ZIndex+2
        }, track)
        Corner(T.Rf, thumb)
        Stroke(T.A1, 1.5, thumb)

        local dragging=false
        local function Update(x)
            local pct=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            cur=math.floor(min+(max-min)*pct)
            fill.Size=UDim2.new(pct,0,1,0)
            thumb.Position=UDim2.new(pct,0,0.5,0)
            valLbl.Text=tostring(cur)
            if callback then pcall(callback,cur) end
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                Tw(thumb,{Size=UDim2.new(0,thumbSz+3,0,thumbSz+3)},"q")
                Update(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=false
                Tw(thumb,{Size=UDim2.new(0,thumbSz,0,thumbSz)},"q")
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
                Update(i.Position.X)
            end
        end)

        local API={}
        function API:Set(v)
            cur=math.clamp(v,min,max)
            local p=(cur-min)/(max-min)
            fill.Size=UDim2.new(p,0,1,0)
            thumb.Position=UDim2.new(p,0,0.5,0)
            valLbl.Text=tostring(cur)
        end
        function API:Get() return cur end
        return API
    end

    -- Dropdown
    function XDLuaUI:AddDropdown(parent, text, list, callback)
        local dropped=false
        local selected={}
        local curList=list or {}
        local OPEN_H = IsMobile and 200 or 170

        local wrap = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 42 or 38),
            BackgroundColor3=T.L3, ClipsDescendants=true,
            ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, wrap)
        local wStroke = Stroke(T.S0, 0.8, wrap)

        -- Header
        local hdr = New("Frame",{
            Size=UDim2.new(1,0,0, IsMobile and 42 or 38),
            BackgroundTransparency=1, ZIndex=wrap.ZIndex+1
        }, wrap)

        local hBtn = New("TextButton",{
            Size=UDim2.new(1,-30,1,0),
            BackgroundTransparency=1,
            Text=text, TextColor3=T.Tm,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=hdr.ZIndex+1
        }, hdr)
        Pad(12,0,0,0,hBtn)

        local arrow = New("TextLabel",{
            Size=UDim2.new(0,24,1,0),
            Position=UDim2.new(1,-28,0,0),
            Text="⌄", TextColor3=T.Td,
            Font=Enum.Font.GothamBold,
            TextSize=IsMobile and 16 or 14,
            BackgroundTransparency=1, ZIndex=hdr.ZIndex+1
        }, hdr)

        local sep = New("Frame",{
            Size=UDim2.new(1,-20,0,1),
            Position=UDim2.new(0,10,0, IsMobile and 42 or 38),
            BackgroundColor3=T.S0, BorderSizePixel=0, ZIndex=wrap.ZIndex+1
        }, wrap)

        local itemScroll = New("ScrollingFrame",{
            Size=UDim2.new(1,0,0,OPEN_H-42),
            Position=UDim2.new(0,0,0, (IsMobile and 42 or 38)+2),
            BackgroundTransparency=1,
            ScrollBarThickness=3, ScrollBarImageColor3=T.A1,
            ZIndex=wrap.ZIndex+1
        }, wrap)
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},itemScroll)
        Pad(6,6,4,4,itemScroll)

        local function UpdateHdr()
            local count=0
            for _ in pairs(selected) do count=count+1 end
            if count==0 then
                hBtn.Text=text; hBtn.TextColor3=T.Tm
            elseif count==1 then
                hBtn.Text=tostring(next(selected)); hBtn.TextColor3=T.Tx
            else
                hBtn.Text=text.." ("..count..")"; hBtn.TextColor3=T.Tx
            end
        end

        local function BuildItems(items)
            for _,c in ipairs(itemScroll:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
            end
            for i,item in ipairs(items) do
                local isOn = selected[item]
                local row = New("Frame",{
                    LayoutOrder=i,
                    Size=UDim2.new(1,0,0, IsMobile and 36 or 30),
                    BackgroundColor3=isOn and T.L4 or T.L2,
                    BackgroundTransparency=isOn and 0 or 1,
                    ZIndex=itemScroll.ZIndex+1
                }, itemScroll)
                Corner(T.R6, row)

                local ck = New("TextLabel",{
                    Size=UDim2.new(0,18,1,0),
                    Text=isOn and "✓" or "",
                    TextColor3=T.A1, Font=Enum.Font.GothamBold,
                    TextSize=10, BackgroundTransparency=1,
                    ZIndex=row.ZIndex+1
                }, row)

                New("TextLabel",{
                    Size=UDim2.new(1,-22,1,0),
                    Position=UDim2.new(0,20,0,0),
                    Text=tostring(item),
                    TextColor3=isOn and T.Tx or T.Tm,
                    Font=Enum.Font.Gotham,
                    TextSize=IsMobile and 13 or 12,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    BackgroundTransparency=1, ZIndex=row.ZIndex+1
                }, row)

                local rowBtn = New("TextButton",{
                    Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,
                    Text="", ZIndex=row.ZIndex+2
                }, row)
                rowBtn.MouseButton1Click:Connect(function()
                    if selected[item] then selected[item]=nil
                    else selected[item]=true end
                    BuildItems(curList); UpdateHdr()
                    local res={} for k in pairs(selected) do table.insert(res,k) end
                    if callback then pcall(callback,res) end
                end)
                rowBtn.MouseEnter:Connect(function()
                    if not selected[item] then Tw(row,{BackgroundTransparency=0.6},"q"); row.BackgroundColor3=T.L4 end
                end)
                rowBtn.MouseLeave:Connect(function()
                    if not selected[item] then Tw(row,{BackgroundTransparency=1},"q") end
                end)
            end
            itemScroll.CanvasSize=UDim2.new(0,0,0,#items*(IsMobile and 36 or 30)+8)
        end

        BuildItems(curList)

        local function Toggle()
            dropped=not dropped
            Tw(arrow,{Rotation=dropped and 180 or 0},"q")
            Tw(wStroke,{Color=dropped and T.A0 or T.S0},"q")
            local oh = IsMobile and 42 or 38
            Tw(wrap,{Size=UDim2.new(0.96,0,0,dropped and (oh+OPEN_H) or oh)},"n")
        end

        hBtn.MouseButton1Click:Connect(Toggle)
        arrow.MouseButton1Click:Connect(Toggle)
        hBtn.MouseEnter:Connect(function() if not dropped then Tw(hBtn,{TextColor3=T.Tx},"q") end end)
        hBtn.MouseLeave:Connect(function() if not dropped then Tw(hBtn,{TextColor3=T.Tm},"q") end end)

        local API={}
        function API:Refresh(l) curList=l or {}; BuildItems(curList) end
        function API:Set(v)
            selected={}; if v~=nil then selected[v]=true end
            BuildItems(curList); UpdateHdr()
            local res={}; for k in pairs(selected) do table.insert(res,k) end
            if callback then pcall(callback,res) end
        end
        function API:Clear() selected={}; BuildItems(curList); UpdateHdr() end
        function API:GetSelected() local r={}; for k in pairs(selected) do table.insert(r,k) end; return r end
        return API
    end

    -- Keybind
    function XDLuaUI:AddKeybind(parent, text, defaultKey, callback)
        local curKey = defaultKey and defaultKey.Name or "None"
        local binding=false

        local row = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 44 or 38),
            BackgroundColor3=T.L3, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, row)
        Stroke(T.S0, 0.8, row)

        New("TextLabel",{
            Size=UDim2.new(1,-88,1,0),
            Position=UDim2.new(0,12,0,0),
            Text=text, TextColor3=T.Tm,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Left,
            BackgroundTransparency=1, ZIndex=row.ZIndex+1
        }, row)

        local kbtn = New("TextButton",{
            Size=UDim2.new(0, IsMobile and 78 or 68, 0, IsMobile and 28 or 24),
            Position=UDim2.new(1,-(IsMobile and 86 or 76), 0.5, IsMobile and -14 or -12),
            BackgroundColor3=T.L2,
            Text=curKey, TextColor3=T.A1,
            Font=Enum.Font.GothamBold,
            TextSize=IsMobile and 11 or 10,
            AutoButtonColor=false, ZIndex=row.ZIndex+1
        }, row)
        Corner(T.R6, kbtn)
        Stroke(T.S1, 0.8, kbtn)

        kbtn.MouseButton1Click:Connect(function()
            binding=true; kbtn.Text="..."
            Tw(kbtn,{TextColor3=T.Yellow},"q")
        end)

        UIS.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if binding then
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    curKey=i.KeyCode.Name; kbtn.Text=curKey
                    Tw(kbtn,{TextColor3=T.A1},"q")
                    binding=false
                    if callback then pcall(callback, i.KeyCode) end
                end
            elseif i.UserInputType==Enum.UserInputType.Keyboard
            and i.KeyCode.Name==curKey then
                if callback then pcall(callback, i.KeyCode) end
            end
        end)

        local API={}
        function API:Set(k) curKey=k.Name; kbtn.Text=curKey end
        function API:Get() return curKey end
        return API
    end

    -- Textbox
    function XDLuaUI:AddTextbox(parent, placeholder, default, callback)
        local row = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 44 or 38),
            BackgroundColor3=T.L3, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, row)
        local rowStr = Stroke(T.S0, 0.8, row)

        local box = New("TextBox",{
            Size=UDim2.new(1,-24,1,-12),
            Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,
            Text=default or "",
            PlaceholderText=placeholder or "พิมพ์ที่นี่...",
            PlaceholderColor3=T.Td,
            TextColor3=T.Tx, Font=Enum.Font.Gotham,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Left,
            ClearTextOnFocus=false, ZIndex=row.ZIndex+1
        }, row)

        box.Focused:Connect(function()
            Tw(rowStr,{Color=T.A1, Thickness=1},"q")
        end)
        box.FocusLost:Connect(function(enter)
            Tw(rowStr,{Color=T.S0, Thickness=0.8},"q")
            if callback then pcall(callback, box.Text, enter) end
        end)

        return box
    end

    -- Color Picker (basic HSV)
    function XDLuaUI:AddColorPicker(parent, text, default, callback)
        default = default or T.A1
        local curCol = default
        local expanded = false

        local row = New("Frame",{
            LayoutOrder=GetOrder(parent),
            Size=UDim2.new(0.96,0,0, IsMobile and 44 or 38),
            BackgroundColor3=T.L3, ZIndex=parent.ZIndex+1
        }, parent)
        Corner(T.R8, row)
        Stroke(T.S0, 0.8, row)

        New("TextLabel",{
            Size=UDim2.new(1,-66,1,0),
            Position=UDim2.new(0,12,0,0),
            Text=text, TextColor3=T.Tm,
            Font=Enum.Font.GothamMedium,
            TextSize=IsMobile and 14 or 13,
            TextXAlignment=Enum.TextXAlignment.Left,
            BackgroundTransparency=1, ZIndex=row.ZIndex+1
        }, row)

        local swatch = New("TextButton",{
            Size=UDim2.new(0,40, 0, IsMobile and 26 or 22),
            Position=UDim2.new(1,-50, 0.5, IsMobile and -13 or -11),
            BackgroundColor3=default, Text="",
            AutoButtonColor=false, ZIndex=row.ZIndex+1
        }, row)
        Corner(T.R6, swatch)
        Stroke(T.S1, 0.8, swatch)

        local picker = nil
        swatch.MouseButton1Click:Connect(function()
            expanded=not expanded
            if picker then picker:Destroy(); picker=nil; return end

            local sp = swatch.AbsolutePosition
            picker = New("Frame",{
                Size=UDim2.new(0,180,0,130),
                Position=UDim2.new(0, sp.X-60, 0, sp.Y+30),
                BackgroundColor3=T.L2, ZIndex=100
            }, SG)
            Corner(T.R10, picker)
            Stroke(T.S1, 1, picker)
            Shadow(picker, 0.38)
            Pad(10,10,8,8,picker)

            local function Channel(ltext, yp, getter, setter)
                local lf=New("Frame",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,yp),BackgroundTransparency=1,ZIndex=101},picker)
                New("TextLabel",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,0,0,10),Text=ltext,TextColor3=T.Td,Font=Enum.Font.GothamBold,TextSize=9,BackgroundTransparency=1,ZIndex=102},lf)
                local tr=New("Frame",{Size=UDim2.new(1,-18,0,4),Position=UDim2.new(0,18,0,15),BackgroundColor3=T.L3,ZIndex=101},lf)
                Corner(T.Rf,tr)
                local fi=New("Frame",{Size=UDim2.new(getter(),0,1,0),BackgroundColor3=T.A1,ZIndex=102},tr)
                Corner(T.Rf,fi)
                local d2=false
                tr.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        d2=true
                        local p=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
                        fi.Size=UDim2.new(p,0,1,0); setter(p)
                    end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2=false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if d2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        local p=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
                        fi.Size=UDim2.new(p,0,1,0); setter(p)
                    end
                end)
            end

            local h,s,v=Color3.toHSV(curCol)
            Channel("H",0,  function()return h end, function(p)h=p;curCol=Color3.fromHSV(h,s,v);swatch.BackgroundColor3=curCol;if callback then pcall(callback,curCol)end end)
            Channel("S",35, function()return s end, function(p)s=p;curCol=Color3.fromHSV(h,s,v);swatch.BackgroundColor3=curCol;if callback then pcall(callback,curCol)end end)
            Channel("V",70, function()return v end, function(p)v=p;curCol=Color3.fromHSV(h,s,v);swatch.BackgroundColor3=curCol;if callback then pcall(callback,curCol)end end)
        end)

        local API={}
        function API:Set(c) curCol=c; swatch.BackgroundColor3=c; if callback then pcall(callback,c) end end
        function API:Get() return curCol end
        return API
    end

    -- AddDropdownBind (compat)
    function XDLuaUI:AddDropdownBind(parent, ddFunc, text, defKey, targetVal)
        self:AddKeybind(parent, text.." ("..tostring(targetVal)..")", defKey, function()
            ddFunc:Set(targetVal)
        end)
    end

    return XDLuaUI
end

return XDLuaUI
