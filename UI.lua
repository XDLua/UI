local XDLuaUI = {}

-- [Services]
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local Players         = game:GetService("Players")

-- [Theme Configuration]
local Theme = {
    Main        = Color3.fromRGB(12, 12, 14),
    Secondary   = Color3.fromRGB(20, 20, 24),
    Tertiary    = Color3.fromRGB(28, 28, 34),
    Accent      = Color3.fromRGB(220, 30, 60),
    AccentDim   = Color3.fromRGB(140, 20, 40),
    AccentGlow  = Color3.fromRGB(255, 60, 90),
    Text        = Color3.fromRGB(240, 240, 245),
    TextDark    = Color3.fromRGB(160, 160, 175),
    TextMuted   = Color3.fromRGB(90, 90, 105),
    Stroke      = Color3.fromRGB(40, 40, 50),
    StrokeLight = Color3.fromRGB(60, 60, 75),
    Success     = Color3.fromRGB(40, 200, 100),
    Warning     = Color3.fromRGB(255, 190, 50),
    Rounding    = UDim.new(0, 8),
    FastTween   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NormTween   = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SlowTween   = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
}

-- ═══════════════════════════════════════
-- [Helper Functions]
-- ═══════════════════════════════════════

local function Tween(obj, goal, speed)
    local info = speed == "fast" and Theme.FastTween
               or speed == "slow" and Theme.SlowTween
               or Theme.NormTween
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local function MakeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function AddShadow(parent, size)
    local shadow = Instance.new("ImageLabel", parent)
    shadow.Name = "_Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, size or 6)
    shadow.Size = UDim2.new(1, (size or 6) * 4, 1, (size or 6) * 4)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    return shadow
end

local function MakeRipple(btn)
    btn.MouseButton1Click:Connect(function()
        local circle = Instance.new("Frame", btn)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BackgroundTransparency = 0.8
        circle.BorderSizePixel = 0
        circle.ZIndex = btn.ZIndex + 1
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local mp = UserInputService:GetMouseLocation()
        local rel = mp - btn.AbsolutePosition
        circle.Size = UDim2.new(0, 0, 0, 0)
        circle.Position = UDim2.new(0, rel.X, 0, rel.Y)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)

        local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
        Tween(circle, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }, "norm")
        task.delay(0.3, function() circle:Destroy() end)
    end)
end

-- ═══════════════════════════════════════
-- [Notification System]
-- ═══════════════════════════════════════

local notifHolder = nil

local function EnsureNotifHolder(screenGui)
    if notifHolder and notifHolder.Parent then return end
    notifHolder = Instance.new("Frame", screenGui)
    notifHolder.Name = "_NotifHolder"
    notifHolder.Size = UDim2.new(0, 280, 1, 0)
    notifHolder.Position = UDim2.new(1, -290, 0, 0)
    notifHolder.BackgroundTransparency = 1
    notifHolder.ZIndex = 100
    local layout = Instance.new("UIListLayout", notifHolder)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 8)
    Instance.new("UIPadding", notifHolder).PaddingBottom = UDim.new(0, 12)
end

function XDLuaUI:Notify(title, message, notifType, duration)
    if not notifHolder or not notifHolder.Parent then return end
    duration = duration or 4

    local colors = {
        info    = Theme.Accent,
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Color3.fromRGB(220, 60, 60),
    }
    local icons = { info="ℹ", success="✓", warning="⚠", error="✕" }
    local c = colors[notifType or "info"] or Theme.Accent
    local ico = icons[notifType or "info"] or "ℹ"

    local card = Instance.new("Frame", notifHolder)
    card.Size = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = Theme.Secondary
    card.BackgroundTransparency = 0
    card.Position = UDim2.new(1.1, 0, 0, 0)
    card.ZIndex = 100
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local leftBar = Instance.new("Frame", card)
    leftBar.Size = UDim2.new(0, 3, 1, -12)
    leftBar.Position = UDim2.new(0, 0, 0, 6)
    leftBar.BackgroundColor3 = c
    leftBar.BorderSizePixel = 0
    Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1, 0)

    local icoLabel = Instance.new("TextLabel", card)
    icoLabel.Size = UDim2.new(0, 28, 0, 28)
    icoLabel.Position = UDim2.new(0, 12, 0.5, -14)
    icoLabel.Text = ico
    icoLabel.TextColor3 = c
    icoLabel.Font = Enum.Font.GothamBold
    icoLabel.TextSize = 16
    icoLabel.BackgroundColor3 = Color3.fromRGB(c.R*255*0.15, c.G*255*0.15, c.B*255*0.15)
    icoLabel.BackgroundTransparency = 0.7
    Instance.new("UICorner", icoLabel).CornerRadius = UDim.new(0, 6)

    local titleL = Instance.new("TextLabel", card)
    titleL.Size = UDim2.new(1, -55, 0, 20)
    titleL.Position = UDim2.new(0, 50, 0, 12)
    titleL.Text = title
    titleL.TextColor3 = Theme.Text
    titleL.Font = Enum.Font.GothamBold
    titleL.TextSize = 13
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.BackgroundTransparency = 1

    local msgL = Instance.new("TextLabel", card)
    msgL.Size = UDim2.new(1, -55, 0, 28)
    msgL.Position = UDim2.new(0, 50, 0, 32)
    msgL.Text = message
    msgL.TextColor3 = Theme.TextDark
    msgL.Font = Enum.Font.Gotham
    msgL.TextSize = 11
    msgL.TextXAlignment = Enum.TextXAlignment.Left
    msgL.TextWrapped = true
    msgL.BackgroundTransparency = 1

    -- Progress line ด้านล่าง
    local progBg = Instance.new("Frame", card)
    progBg.Size = UDim2.new(1, -12, 0, 2)
    progBg.Position = UDim2.new(0, 6, 1, -4)
    progBg.BackgroundColor3 = Theme.Stroke
    progBg.BorderSizePixel = 0
    Instance.new("UICorner", progBg).CornerRadius = UDim.new(1, 0)

    local prog = Instance.new("Frame", progBg)
    prog.Size = UDim2.new(1, 0, 1, 0)
    prog.BackgroundColor3 = c
    prog.BorderSizePixel = 0
    Instance.new("UICorner", prog).CornerRadius = UDim.new(1, 0)

    AddShadow(card, 8)

    -- Slide In
    Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, "slow")
    Tween(prog, {Size = UDim2.new(0, 0, 1, 0)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    task.delay(duration, function()
        Tween(card, {Position = UDim2.new(1.1, 0, 0, 0)}, "norm")
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ═══════════════════════════════════════
-- [Main Window]
-- ═══════════════════════════════════════

function XDLuaUI:CreateWindow(config)
    -- รองรับทั้ง config table และ string (backward compat)
    if type(config) == "string" then
        config = { Title = config }
    end
    config = config or {}

    local title      = config.Title   or "CRIMSON SCRIPT"
    local subtitle   = config.Sub     or "v2.0"
    local logoId     = config.Logo    or "rbxassetid://111935661110067"

    -- ล้าง GUI เก่า
    if CoreGui:FindFirstChild("XDLuaGUI") then
        CoreGui:FindFirstChild("XDLuaGUI"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "XDLuaGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    EnsureNotifHolder(screenGui)

    -- ══════════════════════════════
    -- [Loading Screen]
    -- ══════════════════════════════
    local blur = Instance.new("BlurEffect", game.Lighting)
    blur.Size = 0
    Tween(blur, {Size = 24}, "slow")

    -- Overlay มืด
    local overlay = Instance.new("Frame", screenGui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 10

    local loadCard = Instance.new("Frame", screenGui)
    loadCard.Size = UDim2.new(0, 360, 0, 200)
    loadCard.Position = UDim2.new(0.5, -180, 0.5, -100)
    loadCard.BackgroundColor3 = Theme.Main
    loadCard.BackgroundTransparency = 1
    loadCard.ZIndex = 11
    Instance.new("UICorner", loadCard).CornerRadius = UDim.new(0, 14)

    -- Border gradient glow
    local cardStroke = Instance.new("UIStroke", loadCard)
    cardStroke.Color = Theme.Accent
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 1

    -- Logo icon
    local logoContainer = Instance.new("Frame", loadCard)
    logoContainer.Size = UDim2.new(0, 56, 0, 56)
    logoContainer.Position = UDim2.new(0.5, -28, 0, 24)
    logoContainer.BackgroundColor3 = Theme.Secondary
    logoContainer.ZIndex = 12
    Instance.new("UICorner", logoContainer).CornerRadius = UDim.new(0, 12)
    local logoStroke2 = Instance.new("UIStroke", logoContainer)
    logoStroke2.Color = Theme.AccentDim
    logoStroke2.Thickness = 1

    local logoImg = Instance.new("ImageLabel", logoContainer)
    logoImg.Size = UDim2.new(0.75, 0, 0.75, 0)
    logoImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoImg.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = logoId
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = 12

    local titleLbl = Instance.new("TextLabel", loadCard)
    titleLbl.Size = UDim2.new(1, 0, 0, 28)
    titleLbl.Position = UDim2.new(0, 0, 0, 90)
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextTransparency = 1
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 22
    titleLbl.BackgroundTransparency = 1
    titleLbl.ZIndex = 12

    local subLbl = Instance.new("TextLabel", loadCard)
    subLbl.Size = UDim2.new(1, 0, 0, 18)
    subLbl.Position = UDim2.new(0, 0, 0, 118)
    subLbl.Text = subtitle
    subLbl.TextColor3 = Theme.Accent
    subLbl.TextTransparency = 1
    subLbl.Font = Enum.Font.GothamMedium
    subLbl.TextSize = 12
    subLbl.BackgroundTransparency = 1
    subLbl.ZIndex = 12

    -- Loading bar bg
    local barBg = Instance.new("Frame", loadCard)
    barBg.Size = UDim2.new(0.82, 0, 0, 4)
    barBg.Position = UDim2.new(0.09, 0, 0, 158)
    barBg.BackgroundColor3 = Theme.Secondary
    barBg.BackgroundTransparency = 1
    barBg.ZIndex = 12
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Theme.Accent
    bar.ZIndex = 13
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    -- Glow dot ที่ปลาย bar
    local barDot = Instance.new("Frame", bar)
    barDot.Size = UDim2.new(0, 8, 0, 8)
    barDot.Position = UDim2.new(1, -4, 0.5, -4)
    barDot.BackgroundColor3 = Theme.AccentGlow
    barDot.ZIndex = 14
    Instance.new("UICorner", barDot).CornerRadius = UDim.new(1, 0)

    local statusLbl = Instance.new("TextLabel", loadCard)
    statusLbl.Size = UDim2.new(1, 0, 0, 16)
    statusLbl.Position = UDim2.new(0, 0, 0, 174)
    statusLbl.Text = "กำลังเริ่มต้น..."
    statusLbl.TextColor3 = Theme.TextMuted
    statusLbl.TextTransparency = 1
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 11
    statusLbl.BackgroundTransparency = 1
    statusLbl.ZIndex = 12

    AddShadow(loadCard, 20)

    -- Fade In
    Tween(loadCard, {BackgroundTransparency = 0}, "slow")
    Tween(cardStroke, {Transparency = 0.3}, "slow")
    Tween(titleLbl, {TextTransparency = 0}, "slow")
    Tween(subLbl, {TextTransparency = 0}, "slow")
    Tween(barBg, {BackgroundTransparency = 0}, "slow")
    Tween(statusLbl, {TextTransparency = 0}, "slow")
    task.wait(0.6)

    -- Status messages
    local msgs = {
        {t=0.5, m="กำลังโหลดโมดูล..."},
        {t=1.0, m="ตรวจสอบเวอร์ชั่น..."},
        {t=1.8, m="เตรียม UI..."},
        {t=2.5, m="เกือบเสร็จแล้ว..."},
    }
    task.spawn(function()
        for _, v in ipairs(msgs) do
            task.wait(v.t)
            Tween(statusLbl, {TextTransparency = 1}, "fast")
            task.wait(0.12)
            statusLbl.Text = v.m
            Tween(statusLbl, {TextTransparency = 0}, "fast")
        end
    end)

    local fillTween = Tween(bar, {Size = UDim2.new(1, 0, 1, 0)},
        TweenInfo.new(3.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut))
    fillTween.Completed:Wait()

    statusLbl.Text = "✓  พร้อมใช้งาน!"
    Tween(statusLbl, {TextColor3 = Theme.Success})
    task.wait(0.5)

    -- Fade Out
    for _, obj in ipairs({loadCard, overlay}) do
        Tween(obj, {BackgroundTransparency = 1}, "norm")
    end
    Tween(cardStroke, {Transparency = 1}, "norm")
    Tween(titleLbl, {TextTransparency = 1}, "norm")
    Tween(subLbl, {TextTransparency = 1}, "norm")
    Tween(statusLbl, {TextTransparency = 1}, "norm")
    Tween(barBg, {BackgroundTransparency = 1}, "norm")
    Tween(bar, {BackgroundTransparency = 1}, "norm")
    Tween(blur, {Size = 0}, "norm")

    task.wait(0.35)
    blur:Destroy()
    loadCard:Destroy()
    overlay:Destroy()

    -- ══════════════════════════════
    -- [Logo Button (Floating)]
    -- ══════════════════════════════
    local logoBtn = Instance.new("TextButton", screenGui)
    logoBtn.Name = "LogoButton"
    logoBtn.Size = UDim2.new(0, 46, 0, 46)
    logoBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    logoBtn.BackgroundColor3 = Theme.Main
    logoBtn.Text = ""
    logoBtn.AutoButtonColor = false
    logoBtn.Active = true
    logoBtn.ZIndex = 5
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0, 10)

    local logoBtnStroke = Instance.new("UIStroke", logoBtn)
    logoBtnStroke.Color = Theme.Accent
    logoBtnStroke.Thickness = 1.5

    local logoBtnImg = Instance.new("ImageLabel", logoBtn)
    logoBtnImg.Size = UDim2.new(0.7, 0, 0.7, 0)
    logoBtnImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoBtnImg.AnchorPoint = Vector2.new(0.5, 0.5)
    logoBtnImg.BackgroundTransparency = 1
    logoBtnImg.Image = logoId
    logoBtnImg.ScaleType = Enum.ScaleType.Fit
    logoBtnImg.ZIndex = 6

    AddShadow(logoBtn, 10)
    MakeDraggable(logoBtn, logoBtn)

    logoBtn.MouseEnter:Connect(function()
        Tween(logoBtn, {Size = UDim2.new(0, 52, 0, 52)}, "fast")
        Tween(logoBtnStroke, {Color = Theme.AccentGlow, Thickness = 2}, "fast")
    end)
    logoBtn.MouseLeave:Connect(function()
        Tween(logoBtn, {Size = UDim2.new(0, 46, 0, 46)}, "fast")
        Tween(logoBtnStroke, {Color = Theme.Accent, Thickness = 1.5}, "fast")
    end)

    -- ══════════════════════════════
    -- [Main Frame]
    -- ══════════════════════════════
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 520, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    mainFrame.BackgroundColor3 = Theme.Main
    mainFrame.ZIndex = 2
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", mainFrame).Color = Theme.Stroke

    AddShadow(mainFrame, 24)

    -- TitleBar
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 46)
    titleBar.BackgroundColor3 = Theme.Secondary
    titleBar.ZIndex = 3
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    -- Square off the bottom corners
    local titleBarFix = Instance.new("Frame", titleBar)
    titleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleBarFix.BackgroundColor3 = Theme.Secondary
    titleBarFix.BorderSizePixel = 0
    titleBarFix.ZIndex = 3

    local titleAccentLine = Instance.new("Frame", titleBar)
    titleAccentLine.Size = UDim2.new(0, 3, 0, 22)
    titleAccentLine.Position = UDim2.new(0, 14, 0.5, -11)
    titleAccentLine.BackgroundColor3 = Theme.Accent
    titleAccentLine.BorderSizePixel = 0
    titleAccentLine.ZIndex = 4
    Instance.new("UICorner", titleAccentLine).CornerRadius = UDim.new(1, 0)

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, -120, 1, 0)
    titleText.Position = UDim2.new(0, 26, 0, 0)
    titleText.Text = title
    titleText.TextColor3 = Theme.Text
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 15
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.ZIndex = 4

    local subText = Instance.new("TextLabel", titleBar)
    subText.Size = UDim2.new(0, 80, 1, 0)
    subText.Position = UDim2.new(0, 26 + titleText.TextBounds.X + 8, 0, 0)
    subText.Text = subtitle
    subText.TextColor3 = Theme.Accent
    subText.Font = Enum.Font.GothamMedium
    subText.TextSize = 11
    subText.TextXAlignment = Enum.TextXAlignment.Left
    subText.BackgroundTransparency = 1
    subText.ZIndex = 4

    -- Window Buttons
    local function MakeWinBtn(offsetX, clr, ico)
        local b = Instance.new("TextButton", titleBar)
        b.Size = UDim2.new(0, 22, 0, 22)
        b.Position = UDim2.new(1, offsetX, 0.5, -11)
        b.BackgroundColor3 = clr
        b.Text = ico
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.ZIndex = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.2}, "fast") end)
        b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0}, "fast") end)
        return b
    end

    local closeBtn    = MakeWinBtn(-34, Color3.fromRGB(200, 55, 55), "×")
    local minimizeBtn = MakeWinBtn(-62, Color3.fromRGB(50, 50, 60), "−")

    closeBtn.MouseButton1Click:Connect(function()
        Tween(mainFrame, {Size = UDim2.new(0, 520, 0, 0), BackgroundTransparency = 1}, "norm")
        task.wait(0.3)
        screenGui:Destroy()
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(mainFrame, {Size = UDim2.new(0, 520, 0, 46)}, "norm")
        else
            Tween(mainFrame, {Size = UDim2.new(0, 520, 0, 360)}, "norm")
        end
    end)

    MakeDraggable(titleBar, mainFrame)

    -- Logo button toggle
    logoBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- ══════════════════════════════
    -- [Tab Sidebar]
    -- ══════════════════════════════
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 130, 1, -46)
    sidebar.Position = UDim2.new(0, 0, 0, 46)
    sidebar.BackgroundColor3 = Theme.Secondary
    sidebar.ZIndex = 3
    -- fix top-left corner only
    local sidebarFix = Instance.new("Frame", sidebar)
    sidebarFix.Size = UDim2.new(1, 0, 0, 12)
    sidebarFix.BackgroundColor3 = Theme.Secondary
    sidebarFix.BorderSizePixel = 0
    sidebarFix.ZIndex = 3

    local sidebarStroke = Instance.new("Frame", sidebar)
    sidebarStroke.Size = UDim2.new(0, 1, 1, 0)
    sidebarStroke.Position = UDim2.new(1, 0, 0, 0)
    sidebarStroke.BackgroundColor3 = Theme.Stroke
    sidebarStroke.BorderSizePixel = 0
    sidebarStroke.ZIndex = 4

    local tabScroll = Instance.new("ScrollingFrame", sidebar)
    tabScroll.Size = UDim2.new(1, 0, 1, -8)
    tabScroll.Position = UDim2.new(0, 0, 0, 8)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
    tabScroll.ZIndex = 4
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", tabScroll).PaddingTop = UDim.new(0, 4)

    -- ══════════════════════════════
    -- [Content Area]
    -- ══════════════════════════════
    local contentBg = Instance.new("Frame", mainFrame)
    contentBg.Size = UDim2.new(1, -138, 1, -54)
    contentBg.Position = UDim2.new(0, 134, 0, 50)
    contentBg.BackgroundColor3 = Theme.Tertiary
    contentBg.ZIndex = 3
    Instance.new("UICorner", contentBg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", contentBg).Color = Theme.Stroke

    -- ══════════════════════════════
    -- [Tab/Component Logic]
    -- ══════════════════════════════
    local tabs = {}
    local activeTab = nil

    local function GetOrder(parent)
        for _, t in pairs(tabs) do
            if t.Content == parent then
                t._order = (t._order or 0) + 1
                return t._order
            end
        end
        return 0
    end

    -- ══════════════════════════════
    -- PUBLIC: AddTab
    -- ══════════════════════════════
    function XDLuaUI:AddTab(tabName, emoji)
        local isFirst = not next(tabs)

        local tabBtn = Instance.new("TextButton", tabScroll)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 36)
        tabBtn.BackgroundColor3 = Theme.Tertiary
        tabBtn.BackgroundTransparency = isFirst and 0 or 1
        tabBtn.Text = (emoji or "▸") .. "  " .. tabName
        tabBtn.TextColor3 = isFirst and Theme.Text or Theme.TextDark
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 5
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 7)

        -- Active indicator
        local indicator = Instance.new("Frame", tabBtn)
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 6
        indicator.Visible = isFirst
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        -- Content scroll
        local content = Instance.new("ScrollingFrame", contentBg)
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Theme.Accent
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Visible = isFirst
        content.ZIndex = 4
        content.CanvasPosition = Vector2.zero

        local cLayout = Instance.new("UIListLayout", content)
        cLayout.Padding = UDim.new(0, 7)
        cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder

        Instance.new("UIPadding", content).PaddingTop = UDim.new(0, 8)

        local function Activate()
            for _, t in pairs(tabs) do
                Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}, "fast")
                t.Indicator.Visible = false
                t.Content.Visible = false
            end
            Tween(tabBtn, {BackgroundTransparency = 0, TextColor3 = Theme.Text}, "fast")
            indicator.Visible = true
            content.Visible = true
            activeTab = tabName
        end

        tabBtn.MouseButton1Click:Connect(Activate)
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn, {BackgroundTransparency = 0.7}, "fast")
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn, {BackgroundTransparency = 1}, "fast")
            end
        end)

        tabs[tabName] = {Btn = tabBtn, Content = content, Indicator = indicator, _order = 0}
        if isFirst then activeTab = tabName end

        return content
    end

    -- ══════════════════════════════
    -- PUBLIC: AddSection
    -- ══════════════════════════════
    function XDLuaUI:AddSection(parent, text)
        local f = Instance.new("Frame", parent)
        f.LayoutOrder = GetOrder(parent)
        f.Size = UDim2.new(0.95, 0, 0, 26)
        f.BackgroundTransparency = 1
        f.ZIndex = parent.ZIndex + 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.Text = text:upper()
        lbl.TextColor3 = Theme.Accent
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = f.ZIndex + 1
        Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0, 2)

        task.defer(function()
            local line = Instance.new("Frame", f)
            line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 10), 0, 1)
            line.Position = UDim2.new(0, lbl.AbsoluteSize.X + 8, 0.5, 0)
            line.BackgroundColor3 = Theme.Stroke
            line.BorderSizePixel = 0
            line.ZIndex = f.ZIndex + 1
        end)

        return f
    end

    -- ══════════════════════════════
    -- PUBLIC: AddLabel
    -- ══════════════════════════════
    function XDLuaUI:AddLabel(parent, text, color)
        local lbl = Instance.new("TextLabel", parent)
        lbl.LayoutOrder = GetOrder(parent)
        lbl.Size = UDim2.new(0.95, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Theme.TextDark
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.ZIndex = parent.ZIndex + 1
        Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0, 8)
        return lbl
    end

    -- ══════════════════════════════
    -- PUBLIC: AddButton
    -- ══════════════════════════════
    function XDLuaUI:AddButton(parent, text, callback)
        local btn = Instance.new("TextButton", parent)
        btn.LayoutOrder = GetOrder(parent)
        btn.Size = UDim2.new(0.95, 0, 0, 36)
        btn.BackgroundColor3 = Theme.Secondary
        btn.Text = text
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Theme.Stroke

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Tertiary}, "fast")
            Tween(bStroke, {Color = Theme.Accent}, "fast")
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Secondary}, "fast")
            Tween(bStroke, {Color = Theme.Stroke}, "fast")
        end)
        btn.MouseButton1Down:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Main}, "fast")
        end)
        btn.MouseButton1Up:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Tertiary}, "fast")
        end)

        MakeRipple(btn)
        btn.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[XDLuaUI] Button callback error:", err) end
            end
        end)

        return btn
    end

    -- ══════════════════════════════
    -- PUBLIC: AddToggle
    -- ══════════════════════════════
    function XDLuaUI:AddToggle(parent, text, default, callback)
        local toggled = default == true
        local row = Instance.new("TextButton", parent)
        row.LayoutOrder = GetOrder(parent)
        row.Size = UDim2.new(0.95, 0, 0, 36)
        row.BackgroundColor3 = Theme.Secondary
        row.Text = ""
        row.AutoButtonColor = false
        row.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", row).Color = Theme.Stroke

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = toggled and Theme.Text or Theme.TextDark
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.ZIndex = row.ZIndex + 1

        -- Switch pill
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 36, 0, 20)
        pill.Position = UDim2.new(1, -46, 0.5, -10)
        pill.BackgroundColor3 = toggled and Theme.Accent or Theme.Stroke
        pill.ZIndex = row.ZIndex + 1
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", pill)
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        dot.BackgroundColor3 = Theme.Text
        dot.ZIndex = row.ZIndex + 2
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function SetToggle(val)
            toggled = val
            Tween(pill, {BackgroundColor3 = toggled and Theme.Accent or Theme.Stroke}, "fast")
            Tween(dot, {
                Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            }, "fast")
            Tween(lbl, {TextColor3 = toggled and Theme.Text or Theme.TextDark}, "fast")
            if callback then
                local ok, err = pcall(callback, toggled)
                if not ok then warn("[XDLuaUI] Toggle callback error:", err) end
            end
        end

        row.MouseButton1Click:Connect(function() SetToggle(not toggled) end)

        local ToggleAPI = {}
        function ToggleAPI:Set(v) SetToggle(v) end
        function ToggleAPI:Get() return toggled end

        return ToggleAPI
    end

    -- ══════════════════════════════
    -- PUBLIC: AddSlider
    -- ══════════════════════════════
    function XDLuaUI:AddSlider(parent, text, min, max, default, callback)
        min = min or 0
        max = max or 100
        default = math.clamp(default or min, min, max)

        local slider = Instance.new("Frame", parent)
        slider.LayoutOrder = GetOrder(parent)
        slider.Size = UDim2.new(0.95, 0, 0, 52)
        slider.BackgroundColor3 = Theme.Secondary
        slider.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", slider).Color = Theme.Stroke

        local textRow = Instance.new("Frame", slider)
        textRow.Size = UDim2.new(1, 0, 0, 26)
        textRow.BackgroundTransparency = 1
        textRow.ZIndex = slider.ZIndex + 1

        local lbl = Instance.new("TextLabel", textRow)
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = Theme.TextDark
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = slider.ZIndex + 2

        local valLbl = Instance.new("TextLabel", textRow)
        valLbl.Size = UDim2.new(0.3, -12, 1, 0)
        valLbl.Position = UDim2.new(0.7, 0, 0, 0)
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = Theme.Accent
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.BackgroundTransparency = 1
        valLbl.ZIndex = slider.ZIndex + 2

        local trackBg = Instance.new("Frame", slider)
        trackBg.Size = UDim2.new(0.9, 0, 0, 5)
        trackBg.Position = UDim2.new(0.05, 0, 0, 34)
        trackBg.BackgroundColor3 = Theme.Tertiary
        trackBg.ZIndex = slider.ZIndex + 1
        Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", trackBg).Color = Theme.Stroke

        local fill = Instance.new("Frame", trackBg)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.ZIndex = trackBg.ZIndex + 1
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local thumb = Instance.new("Frame", trackBg)
        thumb.Size = UDim2.new(0, 13, 0, 13)
        thumb.BackgroundColor3 = Theme.Text
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
        thumb.ZIndex = trackBg.ZIndex + 2
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
        local thumbStroke = Instance.new("UIStroke", thumb)
        thumbStroke.Color = Theme.Accent
        thumbStroke.Thickness = 1.5

        local dragging = false
        local currentVal = default

        local function UpdateSlider(inputX)
            local pct = math.clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
            currentVal = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, 0, 0.5, 0)
            valLbl.Text = tostring(currentVal)
            if callback then
                local ok, err = pcall(callback, currentVal)
                if not ok then warn("[XDLuaUI] Slider callback error:", err) end
            end
        end

        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Tween(thumb, {Size = UDim2.new(0, 15, 0, 15)}, "fast")
                UpdateSlider(inp.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                Tween(thumb, {Size = UDim2.new(0, 13, 0, 13)}, "fast")
            end
        end)

        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(inp.Position.X)
            end
        end)

        local SliderAPI = {}
        function SliderAPI:Set(v)
            currentVal = math.clamp(v, min, max)
            local pct = (currentVal - min) / (max - min)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, 0, 0.5, 0)
            valLbl.Text = tostring(currentVal)
        end
        function SliderAPI:Get() return currentVal end

        return SliderAPI
    end

    -- ══════════════════════════════
    -- PUBLIC: AddDropdown
    -- ══════════════════════════════
    function XDLuaUI:AddDropdown(parent, text, list, callback)
        local dropped = false
        local selectedItems = {}
        local currentList = list or {}

        local wrap = Instance.new("Frame", parent)
        wrap.LayoutOrder = GetOrder(parent)
        wrap.Size = UDim2.new(0.95, 0, 0, 36)
        wrap.BackgroundColor3 = Theme.Secondary
        wrap.ClipsDescendants = true
        wrap.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 7)
        local wStroke = Instance.new("UIStroke", wrap)
        wStroke.Color = Theme.Stroke

        local header = Instance.new("Frame", wrap)
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundTransparency = 1
        header.ZIndex = wrap.ZIndex + 1

        local btn = Instance.new("TextButton", header)
        btn.Size = UDim2.new(1, -36, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = Theme.TextDark
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = header.ZIndex + 1
        Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 12)

        local arrow = Instance.new("TextLabel", header)
        arrow.Size = UDim2.new(0, 24, 1, 0)
        arrow.Position = UDim2.new(1, -28, 0, 0)
        arrow.Text = "▾"
        arrow.TextColor3 = Theme.TextMuted
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14
        arrow.BackgroundTransparency = 1
        arrow.ZIndex = header.ZIndex + 1

        local divider = Instance.new("Frame", wrap)
        divider.Size = UDim2.new(1, -24, 0, 1)
        divider.Position = UDim2.new(0, 12, 0, 36)
        divider.BackgroundColor3 = Theme.Stroke
        divider.BorderSizePixel = 0
        divider.ZIndex = wrap.ZIndex + 1

        local itemScroll = Instance.new("ScrollingFrame", wrap)
        itemScroll.Size = UDim2.new(1, 0, 0, 130)
        itemScroll.Position = UDim2.new(0, 0, 0, 37)
        itemScroll.BackgroundTransparency = 1
        itemScroll.ScrollBarThickness = 3
        itemScroll.ScrollBarImageColor3 = Theme.Accent
        itemScroll.ZIndex = wrap.ZIndex + 1

        local itemLayout = Instance.new("UIListLayout", itemScroll)
        itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", itemScroll).PaddingLeft = UDim.new(0, 8)

        local function UpdateBtnText()
            local count = 0
            for _ in pairs(selectedItems) do count = count + 1 end
            if count == 0 then
                btn.Text = text
                btn.TextColor3 = Theme.TextDark
            elseif count == 1 then
                local sel = next(selectedItems)
                btn.Text = tostring(sel)
                btn.TextColor3 = Theme.Text
            else
                btn.Text = text .. " (" .. count .. ")"
                btn.TextColor3 = Theme.Text
            end
        end

        local function BuildItems(items)
            for _, c in ipairs(itemScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i, item in ipairs(items) do
                local row = Instance.new("TextButton", itemScroll)
                row.LayoutOrder = i
                row.Size = UDim2.new(1, -16, 0, 30)
                row.BackgroundColor3 = selectedItems[item] and Theme.Tertiary or Color3.fromRGB(0,0,0)
                row.BackgroundTransparency = selectedItems[item] and 0 or 1
                row.Text = ""
                row.AutoButtonColor = false
                row.ZIndex = itemScroll.ZIndex + 1
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

                local check = Instance.new("TextLabel", row)
                check.Size = UDim2.new(0, 16, 1, 0)
                check.Text = selectedItems[item] and "✓" or ""
                check.TextColor3 = Theme.Accent
                check.Font = Enum.Font.GothamBold
                check.TextSize = 11
                check.BackgroundTransparency = 1
                check.ZIndex = row.ZIndex + 1

                local itemLbl = Instance.new("TextLabel", row)
                itemLbl.Size = UDim2.new(1, -20, 1, 0)
                itemLbl.Position = UDim2.new(0, 18, 0, 0)
                itemLbl.Text = tostring(item)
                itemLbl.TextColor3 = selectedItems[item] and Theme.Text or Theme.TextDark
                itemLbl.Font = Enum.Font.Gotham
                itemLbl.TextSize = 12
                itemLbl.TextXAlignment = Enum.TextXAlignment.Left
                itemLbl.BackgroundTransparency = 1
                itemLbl.ZIndex = row.ZIndex + 1

                row.MouseEnter:Connect(function()
                    if not selectedItems[item] then
                        Tween(row, {BackgroundTransparency = 0.7}, "fast")
                        row.BackgroundColor3 = Theme.Tertiary
                    end
                end)
                row.MouseLeave:Connect(function()
                    if not selectedItems[item] then
                        Tween(row, {BackgroundTransparency = 1}, "fast")
                    end
                end)

                row.MouseButton1Click:Connect(function()
                    if selectedItems[item] then
                        selectedItems[item] = nil
                    else
                        selectedItems[item] = true
                    end
                    BuildItems(currentList)
                    UpdateBtnText()
                    local result = {}
                    for k in pairs(selectedItems) do table.insert(result, k) end
                    if callback then pcall(callback, result) end
                end)
            end
            itemScroll.CanvasSize = UDim2.new(0, 0, 0, #items * 30)
        end

        BuildItems(currentList)

        local function Toggle()
            dropped = not dropped
            Tween(arrow, {Rotation = dropped and 180 or 0}, "fast")
            Tween(wStroke, {Color = dropped and Theme.AccentDim or Theme.Stroke}, "fast")
            local target = dropped and UDim2.new(0.95, 0, 0, 170) or UDim2.new(0.95, 0, 0, 36)
            Tween(wrap, {Size = target}, "norm")
        end

        btn.MouseButton1Click:Connect(Toggle)
        arrow.MouseButton1Click:Connect(Toggle) -- click arrow juga bisa

        local DropAPI = {}
        function DropAPI:Refresh(newList)
            currentList = newList or {}
            BuildItems(currentList)
        end
        function DropAPI:Set(val)
            selectedItems = {}
            if val ~= nil then selectedItems[val] = true end
            BuildItems(currentList)
            UpdateBtnText()
            local result = {}
            for k in pairs(selectedItems) do table.insert(result, k) end
            if callback then pcall(callback, result) end
        end
        function DropAPI:Clear()
            selectedItems = {}
            BuildItems(currentList)
            UpdateBtnText()
        end
        function DropAPI:GetSelected()
            local result = {}
            for k in pairs(selectedItems) do table.insert(result, k) end
            return result
        end

        return DropAPI
    end

    -- ══════════════════════════════
    -- PUBLIC: AddKeybind
    -- ══════════════════════════════
    function XDLuaUI:AddKeybind(parent, text, defaultKey, callback)
        local currentKey = defaultKey and defaultKey.Name or "None"
        local binding = false

        local row = Instance.new("Frame", parent)
        row.LayoutOrder = GetOrder(parent)
        row.Size = UDim2.new(0.95, 0, 0, 36)
        row.BackgroundColor3 = Theme.Secondary
        row.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", row).Color = Theme.Stroke

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -80, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = Theme.TextDark
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.ZIndex = row.ZIndex + 1

        local keyBtn = Instance.new("TextButton", row)
        keyBtn.Size = UDim2.new(0, 64, 0, 24)
        keyBtn.Position = UDim2.new(1, -72, 0.5, -12)
        keyBtn.BackgroundColor3 = Theme.Tertiary
        keyBtn.Text = currentKey
        keyBtn.TextColor3 = Theme.Accent
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 11
        keyBtn.AutoButtonColor = false
        keyBtn.ZIndex = row.ZIndex + 1
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", keyBtn).Color = Theme.StrokeLight

        keyBtn.MouseButton1Click:Connect(function()
            binding = true
            keyBtn.Text = "..."
            Tween(keyBtn, {TextColor3 = Theme.Warning}, "fast")
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if binding then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    keyBtn.Text = currentKey
                    Tween(keyBtn, {TextColor3 = Theme.Accent}, "fast")
                    binding = false
                    if callback then pcall(callback, input.KeyCode) end
                end
            elseif input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode.Name == currentKey then
                if callback then pcall(callback, input.KeyCode) end
            end
        end)

        local KeybindAPI = {}
        function KeybindAPI:Set(key)
            currentKey = key.Name
            keyBtn.Text = currentKey
        end
        function KeybindAPI:Get() return currentKey end

        return KeybindAPI
    end

    -- ══════════════════════════════
    -- PUBLIC: AddTextbox
    -- ══════════════════════════════
    function XDLuaUI:AddTextbox(parent, placeholder, defaultText, callback)
        local row = Instance.new("Frame", parent)
        row.LayoutOrder = GetOrder(parent)
        row.Size = UDim2.new(0.95, 0, 0, 36)
        row.BackgroundColor3 = Theme.Secondary
        row.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Theme.Stroke

        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(1, -24, 1, -12)
        box.Position = UDim2.new(0, 12, 0, 6)
        box.BackgroundTransparency = 1
        box.Text = defaultText or ""
        box.PlaceholderText = placeholder or "ใส่ข้อความ..."
        box.PlaceholderColor3 = Theme.TextMuted
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.ZIndex = row.ZIndex + 1

        box.Focused:Connect(function()
            Tween(rowStroke, {Color = Theme.Accent}, "fast")
        end)
        box.FocusLost:Connect(function(enter)
            Tween(rowStroke, {Color = Theme.Stroke}, "fast")
            if callback then pcall(callback, box.Text, enter) end
        end)

        return box
    end

    -- ══════════════════════════════
    -- PUBLIC: AddColorPicker  (basic)
    -- ══════════════════════════════
    function XDLuaUI:AddColorPicker(parent, text, default, callback)
        default = default or Color3.fromRGB(220, 30, 60)

        local row = Instance.new("Frame", parent)
        row.LayoutOrder = GetOrder(parent)
        row.Size = UDim2.new(0.95, 0, 0, 36)
        row.BackgroundColor3 = Theme.Secondary
        row.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", row).Color = Theme.Stroke

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = Theme.TextDark
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.ZIndex = row.ZIndex + 1

        local swatch = Instance.new("TextButton", row)
        swatch.Size = UDim2.new(0, 36, 0, 22)
        swatch.Position = UDim2.new(1, -46, 0.5, -11)
        swatch.BackgroundColor3 = default
        swatch.Text = ""
        swatch.AutoButtonColor = false
        swatch.ZIndex = row.ZIndex + 1
        Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", swatch).Color = Theme.StrokeLight

        local ColorAPI = {}
        local currentColor = default

        -- Simple H/S/V sliders popup
        local expanded = false
        local picker = nil

        swatch.MouseButton1Click:Connect(function()
            expanded = not expanded
            if picker then picker:Destroy(); picker = nil; return end

            picker = Instance.new("Frame", screenGui)
            picker.Size = UDim2.new(0, 180, 0, 140)
            local sp = swatch.AbsolutePosition
            picker.Position = UDim2.new(0, sp.X - 80, 0, sp.Y + 30)
            picker.BackgroundColor3 = Theme.Secondary
            picker.ZIndex = 50
            Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", picker).Color = Theme.Stroke
            AddShadow(picker, 12)

            local function MakeChannel(labelTxt, yOff, getter, setter)
                local lf = Instance.new("Frame", picker)
                lf.Size = UDim2.new(1, -20, 0, 32)
                lf.Position = UDim2.new(0, 10, 0, yOff)
                lf.BackgroundTransparency = 1
                lf.ZIndex = 51

                local ll = Instance.new("TextLabel", lf)
                ll.Size = UDim2.new(0, 16, 1, 0)
                ll.Text = labelTxt
                ll.TextColor3 = Theme.TextMuted
                ll.Font = Enum.Font.GothamBold
                ll.TextSize = 10
                ll.BackgroundTransparency = 1
                ll.ZIndex = 52

                local track = Instance.new("Frame", lf)
                track.Size = UDim2.new(1, -22, 0, 5)
                track.Position = UDim2.new(0, 20, 0.5, -2)
                track.BackgroundColor3 = Theme.Tertiary
                track.ZIndex = 51
                Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

                local fill2 = Instance.new("Frame", track)
                fill2.Size = UDim2.new(getter(), 0, 1, 0)
                fill2.BackgroundColor3 = Theme.Accent
                fill2.ZIndex = 52
                Instance.new("UICorner", fill2).CornerRadius = UDim.new(1, 0)

                local d2 = false
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        d2 = true
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        fill2.Size = UDim2.new(pct, 0, 1, 0)
                        setter(pct)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then d2 = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if d2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        fill2.Size = UDim2.new(pct, 0, 1, 0)
                        setter(pct)
                    end
                end)
            end

            local h, s, v = Color3.toHSV(currentColor)
            MakeChannel("H", 8, function() return h end, function(val) h = val; local c = Color3.fromHSV(h,s,v); currentColor = c; swatch.BackgroundColor3 = c; if callback then pcall(callback, c) end end)
            MakeChannel("S", 46, function() return s end, function(val) s = val; local c = Color3.fromHSV(h,s,v); currentColor = c; swatch.BackgroundColor3 = c; if callback then pcall(callback, c) end end)
            MakeChannel("V", 84, function() return v end, function(val) v = val; local c = Color3.fromHSV(h,s,v); currentColor = c; swatch.BackgroundColor3 = c; if callback then pcall(callback, c) end end)
        end)

        function ColorAPI:Set(c)
            currentColor = c
            swatch.BackgroundColor3 = c
            if callback then pcall(callback, c) end
        end
        function ColorAPI:Get() return currentColor end

        return ColorAPI
    end

    -- ══════════════════════════════
    -- PUBLIC: AddDivider
    -- ══════════════════════════════
    function XDLuaUI:AddDivider(parent)
        local div = Instance.new("Frame", parent)
        div.LayoutOrder = GetOrder(parent)
        div.Size = UDim2.new(0.9, 0, 0, 1)
        div.BackgroundColor3 = Theme.Stroke
        div.BorderSizePixel = 0
        div.ZIndex = parent.ZIndex + 1
        return div
    end

    -- ══════════════════════════════
    -- PUBLIC: AddDropdownBind (compat)
    -- ══════════════════════════════
    function XDLuaUI:AddDropdownBind(parent, dropdownFunc, text, defaultKey, targetValue)
        self:AddKeybind(parent, text .. " (" .. tostring(targetValue) .. ")", defaultKey, function()
            dropdownFunc:Set(targetValue)
        end)
    end

    return XDLuaUI
end

return XDLuaUI
