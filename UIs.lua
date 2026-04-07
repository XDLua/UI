--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  NOVA UI LIBRARY v1.1                        ║
    ║              Roblox UI Library - Dark Navy Theme             ║
    ╚══════════════════════════════════════════════════════════════╝

    USAGE EXAMPLE:

    local NovaUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

    local Window = NovaUI:CreateWindow({
        Title = "My Script",
        Username = game.Players.LocalPlayer.Name,
    })

    local Tab = Window:AddTab("Main")
    Tab:AddSection("HEAD TEXT")

    Tab:AddToggle("Speed Hack", false, function(value)
        print("Toggle:", value)
    end)

    Tab:AddDropdown("Gamemode", {"Easy","Normal","Hard"}, "Normal", function(value)
        print("Selected:", value)
    end)

    Tab:AddTextInput("Set Speed", "Enter value...", function(value)
        print("Input:", value)
    end)

    Tab:AddSlider("WalkSpeed", 0, 100, 50, function(value)
        print("Slider:", value)
    end)

    Tab:AddButton("EXECUTE", function()
        print("Button clicked!")
    end)
]]

-- ═══════════════════════════════
--         SERVICES
-- ═══════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════
--         THEME
-- ═══════════════════════════════
local Theme = {
    Background       = Color3.fromRGB(18, 22, 32),
    Sidebar          = Color3.fromRGB(14, 18, 26),
    SidebarActive    = Color3.fromRGB(28, 35, 52),
    Content          = Color3.fromRGB(22, 28, 40),
    Header           = Color3.fromRGB(18, 22, 32),
    Element          = Color3.fromRGB(28, 35, 52),
    ElementHover     = Color3.fromRGB(34, 43, 62),
    ElementBorder    = Color3.fromRGB(45, 58, 82),
    ToggleOn         = Color3.fromRGB(60, 120, 220),
    ToggleOff        = Color3.fromRGB(40, 50, 72),
    ToggleKnob       = Color3.fromRGB(255, 255, 255),
    SliderFill       = Color3.fromRGB(60, 120, 220),
    SliderTrack      = Color3.fromRGB(40, 50, 72),
    SliderKnob       = Color3.fromRGB(255, 255, 255),
    Button           = Color3.fromRGB(28, 35, 52),
    ButtonHover      = Color3.fromRGB(45, 60, 90),
    ButtonBorder     = Color3.fromRGB(65, 85, 125),
    Dropdown         = Color3.fromRGB(28, 35, 52),
    DropdownList     = Color3.fromRGB(20, 26, 38),
    DropdownHover    = Color3.fromRGB(34, 43, 62),
    DropdownSelected = Color3.fromRGB(35, 55, 95),
    SearchBg         = Color3.fromRGB(28, 35, 52),
    InputBg          = Color3.fromRGB(28, 35, 52),
    TextPrimary      = Color3.fromRGB(220, 225, 240),
    TextSecondary    = Color3.fromRGB(130, 145, 175),
    TextDim          = Color3.fromRGB(80, 95, 125),
    Accent           = Color3.fromRGB(60, 120, 220),
    Border           = Color3.fromRGB(38, 48, 68),
}

-- ═══════════════════════════════
--         UTILITY
-- ═══════════════════════════════
local function Tween(obj, props, duration, style, dir)
    if not obj or not obj.Parent then return end
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function MakeCorner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function MakeStroke(color, thick, p)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function MakePadding(t, b, l, r, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
    pad.Parent = p
    return pad
end

local function MakeList(spacing, p, fillDir)
    local l = Instance.new("UIListLayout")
    l.Padding       = UDim.new(0, spacing or 4)
    l.FillDirection = fillDir or Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Parent = p
    return l
end

local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════
--   LIBRARY
-- ═══════════════════════════════════════════════════════
local NovaUI = {}
NovaUI.__index = NovaUI

function NovaUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title    or "Nova UI"
    local username    = config.Username or LocalPlayer.Name

    -- CoreGui fallback
    local guiParent
    local ok = pcall(function() guiParent = game:GetService("CoreGui") end)
    if not ok then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "NovaUI_" .. windowTitle
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent         = guiParent

    -- MainFrame  (ClipsDescendants = false  → dropdown เปิดออกนอกได้)
    local MainFrame = New("Frame", {
        Size             = UDim2.new(0, 780, 0, 530),
        Position         = UDim2.new(0.5, -390, 0.5, -265),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
    }, ScreenGui)
    MakeCorner(10, MainFrame)
    MakeStroke(Theme.Border, 1.5, MainFrame)

    -- shadow
    local ShadowFrame = New("Frame", {
        Size             = UDim2.new(1, 14, 1, 14),
        Position         = UDim2.new(0, -7, 0, -7),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.72,
        BorderSizePixel  = 0,
        ZIndex           = 0,
    }, MainFrame)
    MakeCorner(14, ShadowFrame)

    -- ════ SIDEBAR ════
    local Sidebar = New("Frame", {
        Size             = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, MainFrame)
    MakeCorner(10, Sidebar)
    MakeStroke(Theme.Border, 1, Sidebar)

    -- logo
    local LogoBg = New("Frame", {
        Size             = UDim2.new(0, 44, 0, 44),
        Position         = UDim2.new(0.5, -22, 0, 18),
        BackgroundColor3 = Theme.SidebarActive,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Sidebar)
    MakeCorner(8, LogoBg)
    MakeStroke(Theme.Border, 1, LogoBg)
    New("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "◈",
        TextColor3       = Theme.TextPrimary,
        TextSize         = 22,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 3,
    }, LogoBg)

    -- divider under logo
    New("Frame", {
        Size             = UDim2.new(0.8, 0, 0, 1),
        Position         = UDim2.new(0.1, 0, 0, 76),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Sidebar)

    -- tab list
    local TabList = New("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, -130),
        Position         = UDim2.new(0, 0, 0, 82),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex           = 3,
    }, Sidebar)
    MakeList(2, TabList)
    MakePadding(6, 6, 8, 8, TabList)

    -- settings btn
    New("TextButton", {
        Size             = UDim2.new(1, -16, 0, 36),
        Position         = UDim2.new(0, 8, 1, -46),
        BackgroundColor3 = Theme.SidebarActive,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        Text             = "⚙  Settings",
        TextColor3       = Theme.TextSecondary,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        AutoButtonColor  = false,
        ZIndex           = 3,
    }, Sidebar)

    -- ════ CONTENT ════
    local ContentArea = New("Frame", {
        Size             = UDim2.new(1, -180, 1, 0),
        Position         = UDim2.new(0, 180, 0, 0),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        ZIndex           = 2,
    }, MainFrame)

    -- header
    local Header = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, ContentArea)
    MakeStroke(Theme.Border, 1, Header)
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Header)

    -- search bar
    local SrchFrame = New("Frame", {
        Size             = UDim2.new(0, 185, 0, 30),
        Position         = UDim2.new(0, 14, 0.5, -15),
        BackgroundColor3 = Theme.SearchBg,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, Header)
    MakeCorner(6, SrchFrame)
    MakeStroke(Theme.ElementBorder, 1, SrchFrame)
    New("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, Text = "🔍",
        TextColor3 = Theme.TextDim, TextSize = 12, ZIndex = 4,
    }, SrchFrame)
    local SearchBox = New("TextBox", {
        Size             = UDim2.new(1, -28, 1, 0),
        Position         = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText  = "Search",
        PlaceholderColor3= Theme.TextDim,
        Text             = "",
        TextColor3       = Theme.TextPrimary,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex           = 4,
    }, SrchFrame)

    -- username
    New("TextLabel", {
        Size             = UDim2.new(0, 24, 0, 24),
        Position         = UDim2.new(1, -168, 0.5, -12),
        BackgroundTransparency = 1,
        Text             = "👤",
        TextColor3       = Theme.TextSecondary,
        TextSize         = 15,
        ZIndex           = 4,
    }, Header)
    New("TextLabel", {
        Size             = UDim2.new(0, 130, 1, 0),
        Position         = UDim2.new(1, -140, 0, 0),
        BackgroundTransparency = 1,
        Text             = username,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 13,
        Font             = Enum.Font.GothamMedium,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 4,
    }, Header)

    -- pages holder
    local PagesHolder = New("Frame", {
        Size             = UDim2.new(1, 0, 1, -54),
        Position         = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = 2,
    }, ContentArea)

    MakeDraggable(MainFrame, Header)

    -- ════ WINDOW OBJECT ════
    local Window      = {}
    Window._tabs      = {}
    Window._tabBtns   = {}
    Window._activeTab = nil

    -- global search filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchBox.Text:lower()
        for _, tab in ipairs(Window._tabs) do
            for _, elem in ipairs(tab._elements) do
                if elem.Frame and elem.Frame.Parent then
                    elem.Frame.Visible = (q == "") or ((elem.Label or ""):lower():find(q, 1, true) ~= nil)
                end
            end
        end
    end)

    function Window:_SwitchTab(tabObj)
        for _, t in ipairs(self._tabs) do t.Page.Visible = false end
        for _, btn in ipairs(self._tabBtns) do
            Tween(btn, {BackgroundColor3 = Theme.Sidebar}, 0.15)
            local bar = btn:FindFirstChild("ActiveBar")
            if bar then bar.Visible = false end
            local lbl = btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Theme.TextSecondary}, 0.15) end
        end
        tabObj.Page.Visible = true
        self._activeTab = tabObj
        local btn = tabObj._button
        if btn then
            Tween(btn, {BackgroundColor3 = Theme.SidebarActive}, 0.15)
            local bar = btn:FindFirstChild("ActiveBar")
            if bar then bar.Visible = true end
            local lbl = btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Theme.TextPrimary}, 0.15) end
        end
    end

    -- ════════════════════════════════════════════════
    --   AddTab
    -- ════════════════════════════════════════════════
    function Window:AddTab(name, icon)
        icon = icon or "⊞"

        local TabBtn = New("TextButton", {
            Name             = "Tab_"..name,
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 3,
        }, TabList)
        MakeCorner(6, TabBtn)

        local ActiveBar = New("Frame", {
            Name             = "ActiveBar",
            Size             = UDim2.new(0, 3, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
            ZIndex           = 4,
        }, TabBtn)
        MakeCorner(3, ActiveBar)

        New("TextLabel", {
            Size             = UDim2.new(1, -10, 1, 0),
            Position         = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text             = icon.."  "..name,
            TextColor3       = Theme.TextSecondary,
            TextSize         = 13,
            Font             = Enum.Font.GothamMedium,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 3,
        }, TabBtn)

        TabBtn.MouseEnter:Connect(function()
            if not (self._activeTab and self._activeTab._button == TabBtn) then
                Tween(TabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not (self._activeTab and self._activeTab._button == TabBtn) then
                Tween(TabBtn, {BackgroundColor3 = Theme.Sidebar}, 0.12)
            end
        end)

        local Page = New("ScrollingFrame", {
            Name             = "Page_"..name,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible          = false,
            ClipsDescendants = false,
            ZIndex           = 2,
        }, PagesHolder)
        MakeList(6, Page)
        MakePadding(14, 14, 14, 14, Page)

        local Tab        = {}
        Tab._button      = TabBtn
        Tab.Page         = Page
        Tab._elements    = {}
        Tab._order       = 0

        table.insert(self._tabs,    Tab)
        table.insert(self._tabBtns, TabBtn)

        TabBtn.MouseButton1Click:Connect(function() self:_SwitchTab(Tab) end)
        if #self._tabs == 1 then self:_SwitchTab(Tab) end

        -- ── Section ──────────────────────────────
        function Tab:AddSection(title)
            Tab._order += 1
            local f = New("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text             = title,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 15,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = Tab._order,
                ZIndex           = 2,
            }, Page)
            table.insert(Tab._elements, {Frame = f, Label = title})
        end

        -- ── Toggle ───────────────────────────────
        function Tab:AddToggle(label, default, callback)
            default  = default  or false
            callback = callback or function() end
            Tab._order += 1

            local F = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order,
                ZIndex           = 2,
            }, Page)
            MakeCorner(6, F); MakeStroke(Theme.ElementBorder, 1, F)

            New("TextLabel", {
                Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0),
                BackgroundTransparency=1, Text=label, TextColor3=Theme.TextPrimary,
                TextSize=13, Font=Enum.Font.GothamMedium,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2,
            }, F)

            local Pill = New("Frame", {
                Size             = UDim2.new(0, 44, 0, 24),
                Position         = UDim2.new(1, -58, 0.5, -12),
                BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel  = 0, ZIndex = 3,
            }, F)
            MakeCorner(12, Pill); MakeStroke(Theme.ElementBorder, 1, Pill)

            local Knob = New("Frame", {
                Size             = UDim2.new(0, 18, 0, 18),
                Position         = default and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3 = Theme.ToggleKnob,
                BorderSizePixel  = 0, ZIndex = 4,
            }, Pill)
            MakeCorner(9, Knob)

            local state, busy = default, false
            local Hit = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5,
            }, F)

            Hit.MouseEnter:Connect(function() Tween(F,{BackgroundColor3=Theme.ElementHover},0.12) end)
            Hit.MouseLeave:Connect(function() Tween(F,{BackgroundColor3=Theme.Element},0.12) end)
            Hit.MouseButton1Click:Connect(function()
                if busy then return end
                busy  = true
                state = not state
                if state then
                    Tween(Pill,{BackgroundColor3=Theme.ToggleOn},0.2)
                    Tween(Knob,{Position=UDim2.new(1,-21,0.5,-9)},0.2)
                else
                    Tween(Pill,{BackgroundColor3=Theme.ToggleOff},0.2)
                    Tween(Knob,{Position=UDim2.new(0,3,0.5,-9)},0.2)
                end
                task.wait(0.21); busy = false
                callback(state)
            end)
            table.insert(Tab._elements, {Frame=F, Label=label})

            local obj = {}
            function obj:Set(v)
                state = v
                if state then
                    Tween(Pill,{BackgroundColor3=Theme.ToggleOn},0.2)
                    Tween(Knob,{Position=UDim2.new(1,-21,0.5,-9)},0.2)
                else
                    Tween(Pill,{BackgroundColor3=Theme.ToggleOff},0.2)
                    Tween(Knob,{Position=UDim2.new(0,3,0.5,-9)},0.2)
                end
                callback(state)
            end
            function obj:Get() return state end
            return obj
        end

        -- ── Dropdown ─────────────────────────────
        function Tab:AddDropdown(label, options, default, callback)
            options  = options  or {}
            default  = default  or options[1] or ""
            callback = callback or function() end
            Tab._order += 1

            local selected = default
            local isOpen   = false

            local DF = New("Frame", {
                Name             = "Drop_"..label,
                Size             = UDim2.new(1,0,0,42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order,
                ClipsDescendants = false,
                ZIndex           = 10,
            }, Page)
            MakeCorner(6, DF); MakeStroke(Theme.ElementBorder, 1, DF)

            New("TextLabel", {
                Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,14,0,0),
                BackgroundTransparency=1, Text=label, TextColor3=Theme.TextPrimary,
                TextSize=13, Font=Enum.Font.GothamMedium,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
            }, DF)

            local VBox = New("Frame", {
                Size=UDim2.new(0,162,0,30), Position=UDim2.new(1,-170,0.5,-15),
                BackgroundColor3=Theme.Dropdown, BorderSizePixel=0, ZIndex=10,
            }, DF)
            MakeCorner(6, VBox); MakeStroke(Theme.ElementBorder, 1, VBox)

            local VLabel = New("TextLabel", {
                Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1, Text=tostring(selected),
                TextColor3=Theme.TextPrimary, TextSize=12, Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=10,
            }, VBox)
            New("TextLabel", {
                Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0),
                BackgroundTransparency=1, Text="⌄", TextColor3=Theme.TextSecondary,
                TextSize=14, Font=Enum.Font.GothamBold, ZIndex=10,
            }, VBox)

            local panelH = math.min(#options*30+44, 220)
            local Panel  = New("Frame", {
                Size=UDim2.new(0,170,0,0), Position=UDim2.new(1,-170,1,6),
                BackgroundColor3=Theme.DropdownList, BorderSizePixel=0,
                ZIndex=50, ClipsDescendants=true, Visible=false,
            }, DF)
            MakeCorner(6, Panel); MakeStroke(Theme.ElementBorder, 1, Panel)

            local DSF = New("Frame", {
                Size=UDim2.new(1,-8,0,28), Position=UDim2.new(0,4,0,4),
                BackgroundColor3=Theme.SearchBg, BorderSizePixel=0, ZIndex=51,
            }, Panel)
            MakeCorner(5, DSF); MakeStroke(Theme.ElementBorder, 1, DSF)
            New("TextLabel", {
                Size=UDim2.new(0,18,1,0), Position=UDim2.new(0,4,0,0),
                BackgroundTransparency=1, Text="🔍", TextColor3=Theme.TextDim,
                TextSize=10, ZIndex=52,
            }, DSF)
            local DSBox = New("TextBox", {
                Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,22,0,0),
                BackgroundTransparency=1, PlaceholderText="Search",
                PlaceholderColor3=Theme.TextDim, Text="",
                TextColor3=Theme.TextPrimary, TextSize=12, Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, ZIndex=52,
            }, DSF)

            local OScroll = New("ScrollingFrame", {
                Size=UDim2.new(1,-4,1,-38), Position=UDim2.new(0,2,0,36),
                BackgroundTransparency=1, BorderSizePixel=0,
                ScrollBarThickness=2, ScrollBarImageColor3=Theme.Accent,
                CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
                ZIndex=51,
            }, Panel)
            MakeList(1, OScroll); MakePadding(2,2,2,2, OScroll)

            local optBtns = {}
            local function BuildOpts(filter)
                filter = (filter or ""):lower()
                for _, b in ipairs(optBtns) do if b and b.Parent then b:Destroy() end end
                optBtns = {}
                for _, opt in ipairs(options) do
                    local s = tostring(opt)
                    if filter=="" or s:lower():find(filter,1,true) then
                        local isSel = s==tostring(selected)
                        local Btn = New("TextButton", {
                            Size=UDim2.new(1,0,0,28),
                            BackgroundColor3=isSel and Theme.DropdownSelected or Theme.DropdownList,
                            BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=52,
                        }, OScroll)
                        MakeCorner(4, Btn)
                        if isSel then
                            New("Frame", {
                                Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
                                BackgroundColor3=Theme.Accent, BorderSizePixel=0, ZIndex=53,
                            }, Btn)
                        end
                        New("TextLabel", {
                            Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0),
                            BackgroundTransparency=1, Text=s,
                            TextColor3=isSel and Theme.TextPrimary or Theme.TextSecondary,
                            TextSize=12, Font=isSel and Enum.Font.GothamMedium or Enum.Font.Gotham,
                            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=53,
                        }, Btn)
                        Btn.MouseEnter:Connect(function()
                            if s~=tostring(selected) then Tween(Btn,{BackgroundColor3=Theme.DropdownHover},0.1) end
                        end)
                        Btn.MouseLeave:Connect(function()
                            if s~=tostring(selected) then Tween(Btn,{BackgroundColor3=Theme.DropdownList},0.1) end
                        end)
                        Btn.MouseButton1Click:Connect(function()
                            selected = opt; VLabel.Text = s
                            isOpen = false
                            Tween(Panel,{Size=UDim2.new(0,170,0,0)},0.15)
                            task.delay(0.16, function()
                                if Panel and Panel.Parent then Panel.Visible=false end
                            end)
                            BuildOpts(""); callback(selected)
                        end)
                        table.insert(optBtns, Btn)
                    end
                end
            end
            BuildOpts("")
            DSBox:GetPropertyChangedSignal("Text"):Connect(function() BuildOpts(DSBox.Text) end)

            local OpenHit = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=11,
            }, DF)
            OpenHit.MouseEnter:Connect(function() Tween(DF,{BackgroundColor3=Theme.ElementHover},0.12) end)
            OpenHit.MouseLeave:Connect(function() Tween(DF,{BackgroundColor3=Theme.Element},0.12) end)
            OpenHit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Panel.Visible = true
                    DSBox.Text = ""
                    BuildOpts("")
                    Tween(Panel,{Size=UDim2.new(0,170,0,panelH)},0.2,Enum.EasingStyle.Quart)
                else
                    Tween(Panel,{Size=UDim2.new(0,170,0,0)},0.15)
                    task.delay(0.16, function()
                        if Panel and Panel.Parent then Panel.Visible=false end
                    end)
                end
            end)
            table.insert(Tab._elements, {Frame=DF, Label=label})

            local obj={}
            function obj:Set(v) selected=v; VLabel.Text=tostring(v); BuildOpts(""); callback(selected) end
            function obj:Get() return selected end
            function obj:SetOptions(o) options=o; panelH=math.min(#o*30+44,220); BuildOpts("") end
            return obj
        end

        -- ── TextInput ────────────────────────────
        function Tab:AddTextInput(label, placeholder, callback)
            placeholder = placeholder or "Input..."
            callback    = callback    or function() end
            Tab._order += 1

            local F = New("Frame", {
                Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.Element,
                BorderSizePixel=0, LayoutOrder=Tab._order, ZIndex=2,
            }, Page)
            MakeCorner(6,F); MakeStroke(Theme.ElementBorder,1,F)
            New("TextLabel", {
                Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,14,0,0),
                BackgroundTransparency=1, Text=label, TextColor3=Theme.TextPrimary,
                TextSize=13, Font=Enum.Font.GothamMedium,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2,
            }, F)

            local IBox = New("TextBox", {
                Size=UDim2.new(0,155,0,28), Position=UDim2.new(1,-163,0.5,-14),
                BackgroundColor3=Theme.InputBg, BorderSizePixel=0,
                PlaceholderText=placeholder, PlaceholderColor3=Theme.TextDim,
                Text="", TextColor3=Theme.TextPrimary, TextSize=12,
                Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false, ZIndex=3,
            }, F)
            MakeCorner(5,IBox)
            local iStroke = MakeStroke(Theme.ElementBorder,1,IBox)
            MakePadding(0,0,8,0,IBox)

            IBox.Focused:Connect(function()    Tween(iStroke,{Color=Theme.Accent},0.15) end)
            IBox.FocusLost:Connect(function(enter)
                Tween(iStroke,{Color=Theme.ElementBorder},0.15)
                if enter then callback(IBox.Text) end
            end)
            F.MouseEnter:Connect(function() Tween(F,{BackgroundColor3=Theme.ElementHover},0.12) end)
            F.MouseLeave:Connect(function() Tween(F,{BackgroundColor3=Theme.Element},0.12) end)
            table.insert(Tab._elements, {Frame=F, Label=label})

            local obj={}
            function obj:Set(v) IBox.Text=tostring(v); callback(v) end
            function obj:Get() return IBox.Text end
            return obj
        end

        -- ── Slider ───────────────────────────────
        function Tab:AddSlider(label, min, max, default, callback)
            min      = min      or 0
            max      = max      or 100
            default  = math.clamp(default or 50, min, max)
            callback = callback or function() end
            Tab._order += 1

            local F = New("Frame", {
                Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.Element,
                BorderSizePixel=0, LayoutOrder=Tab._order, ZIndex=2,
            }, Page)
            MakeCorner(6,F); MakeStroke(Theme.ElementBorder,1,F)

            local Track = New("Frame", {
                Size=UDim2.new(1,-76,0,6), Position=UDim2.new(0,12,0.5,-3),
                BackgroundColor3=Theme.SliderTrack, BorderSizePixel=0, ZIndex=3,
            }, F)
            MakeCorner(3,Track)

            local r0 = (default-min)/(max-min)
            local Fill = New("Frame", {
                Size=UDim2.new(r0,0,1,0),
                BackgroundColor3=Theme.SliderFill, BorderSizePixel=0, ZIndex=3,
            }, Track)
            MakeCorner(3,Fill)

            local Knob = New("Frame", {
                Size=UDim2.new(0,14,0,14), Position=UDim2.new(r0,-7,0.5,-7),
                BackgroundColor3=Theme.SliderKnob, BorderSizePixel=0, ZIndex=4,
            }, Track)
            MakeCorner(7,Knob); MakeStroke(Theme.Accent,1.5,Knob)

            local VBox = New("Frame", {
                Size=UDim2.new(0,46,0,28), Position=UDim2.new(1,-56,0.5,-14),
                BackgroundColor3=Theme.InputBg, BorderSizePixel=0, ZIndex=3,
            }, F)
            MakeCorner(5,VBox); MakeStroke(Theme.ElementBorder,1,VBox)
            local VLbl = New("TextLabel", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text=tostring(default), TextColor3=Theme.TextPrimary,
                TextSize=12, Font=Enum.Font.GothamMedium, ZIndex=3,
            }, VBox)

            local cur     = default
            local sliding = false

            local function Update(ratio)
                ratio = math.clamp(ratio,0,1)
                cur   = math.round(min+(max-min)*ratio)
                Fill.Size     = UDim2.new(ratio,0,1,0)
                Knob.Position = UDim2.new(ratio,-7,0.5,-7)
                VLbl.Text     = tostring(cur)
                callback(cur)
            end

            local Hit = New("TextButton", {
                Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0.5,-10),
                BackgroundTransparency=1, Text="", ZIndex=5,
            }, Track)

            Hit.MouseButton1Down:Connect(function()
                sliding = true
                local tp = Track.AbsolutePosition.X
                local ts = Track.AbsoluteSize.X
                Update((UserInputService:GetMouseLocation().X - tp) / ts)
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)
            RunService.Heartbeat:Connect(function()
                if not sliding then return end
                if not (Track and Track.Parent) then sliding=false return end
                local tp = Track.AbsolutePosition.X
                local ts = Track.AbsoluteSize.X
                Update((UserInputService:GetMouseLocation().X - tp) / ts)
            end)

            F.MouseEnter:Connect(function() Tween(F,{BackgroundColor3=Theme.ElementHover},0.12) end)
            F.MouseLeave:Connect(function() Tween(F,{BackgroundColor3=Theme.Element},0.12) end)
            table.insert(Tab._elements, {Frame=F, Label=label})

            local obj={}
            function obj:Set(v) Update((math.clamp(v,min,max)-min)/(max-min)) end
            function obj:Get() return cur end
            return obj
        end

        -- ── Button ───────────────────────────────
        function Tab:AddButton(label, callback)
            callback = callback or function() end
            Tab._order += 1

            local Btn = New("TextButton", {
                Name=label, Size=UDim2.new(1,0,0,42),
                BackgroundColor3=Theme.Button, BorderSizePixel=0,
                Text="", AutoButtonColor=false,
                LayoutOrder=Tab._order, ZIndex=2,
            }, Page)
            MakeCorner(6,Btn); MakeStroke(Theme.ButtonBorder,1.5,Btn)
            New("TextLabel", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text=label, TextColor3=Theme.TextPrimary,
                TextSize=13, Font=Enum.Font.GothamBold, ZIndex=2,
            }, Btn)

            Btn.MouseEnter:Connect(function()    Tween(Btn,{BackgroundColor3=Theme.ButtonHover},0.15) end)
            Btn.MouseLeave:Connect(function()    Tween(Btn,{BackgroundColor3=Theme.Button},0.15) end)
            Btn.MouseButton1Down:Connect(function() Tween(Btn,{BackgroundColor3=Theme.Accent},0.1) end)
            Btn.MouseButton1Up:Connect(function()   Tween(Btn,{BackgroundColor3=Theme.ButtonHover},0.1) end)
            Btn.MouseButton1Click:Connect(function() callback() end)
            table.insert(Tab._elements, {Frame=Btn, Label=label})
        end

        -- ── Label ────────────────────────────────
        function Tab:AddLabel(text)
            Tab._order += 1
            local F = New("Frame", {
                Size=UDim2.new(1,0,0,30), BackgroundTransparency=1,
                LayoutOrder=Tab._order, ZIndex=2,
            }, Page)
            New("TextLabel", {
                Size=UDim2.new(1,-14,1,0), Position=UDim2.new(0,14,0,0),
                BackgroundTransparency=1, Text=text, TextColor3=Theme.TextSecondary,
                TextSize=12, Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=2,
            }, F)
            table.insert(Tab._elements, {Frame=F, Label=text})
        end

        return Tab
    end -- AddTab

    -- hide/show with RightControl
    local visible = true
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.RightControl then
            visible = not visible
            MainFrame.Visible = visible
        end
    end)

    return Window
end -- CreateWindow

function NovaUI:SetTheme(t) for k,v in pairs(t) do Theme[k]=v end end
function NovaUI:GetTheme()   return Theme end

return NovaUI
