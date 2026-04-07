local NovaUI = {}
NovaUI.__index = NovaUI

-- ═══════════════════════════════
--         SERVICES
-- ═══════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════
--         THEME / COLORS
-- ═══════════════════════════════
local Theme = {
    Background      = Color3.fromRGB(18, 22, 32),       -- Main window bg
    Sidebar         = Color3.fromRGB(14, 18, 26),       -- Left sidebar
    SidebarActive   = Color3.fromRGB(28, 35, 52),       -- Active tab in sidebar
    Content         = Color3.fromRGB(22, 28, 40),       -- Content area bg
    Header          = Color3.fromRGB(18, 22, 32),       -- Top header bg
    
    Element         = Color3.fromRGB(28, 35, 52),       -- Element row bg
    ElementHover    = Color3.fromRGB(34, 43, 62),       -- Element hover
    ElementBorder   = Color3.fromRGB(45, 58, 82),       -- Element border
    
    ToggleOn        = Color3.fromRGB(60, 120, 220),     -- Toggle enabled
    ToggleOff       = Color3.fromRGB(40, 50, 72),       -- Toggle disabled
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    
    SliderFill      = Color3.fromRGB(60, 120, 220),
    SliderTrack     = Color3.fromRGB(40, 50, 72),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    
    Button          = Color3.fromRGB(28, 35, 52),
    ButtonHover     = Color3.fromRGB(45, 60, 90),
    ButtonBorder    = Color3.fromRGB(65, 85, 125),
    
    Dropdown        = Color3.fromRGB(28, 35, 52),
    DropdownList    = Color3.fromRGB(20, 26, 38),
    DropdownHover   = Color3.fromRGB(34, 43, 62),
    DropdownSelected= Color3.fromRGB(35, 55, 95),
    
    SearchBg        = Color3.fromRGB(28, 35, 52),
    InputBg         = Color3.fromRGB(28, 35, 52),
    
    TextPrimary     = Color3.fromRGB(220, 225, 240),
    TextSecondary   = Color3.fromRGB(130, 145, 175),
    TextDim        = Color3.fromRGB(80, 95, 125),
    
    Accent          = Color3.fromRGB(60, 120, 220),
    Border          = Color3.fromRGB(38, 48, 68),
    Shadow          = Color3.fromRGB(8, 10, 16),
}

-- ═══════════════════════════════
--         UTILITY
-- ═══════════════════════════════
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function MakeCorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function MakeStroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function MakePadding(top, bottom, left, right, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

local function MakeList(spacing, parent, fillDir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 4)
    l.FillDirection = fillDir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

-- Draggable window
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════
--   CREATE WINDOW
-- ═══════════════════════════════════════════════════════
function NovaUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Nova UI"
    local username = config.Username or LocalPlayer.Name

    -- ScreenGui
    local ScreenGui = New("ScreenGui", {
        Name = "NovaUI_" .. windowTitle,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, (RunService:IsStudio() and LocalPlayer:FindFirstChild("PlayerGui")) or game:GetService("CoreGui"))

    -- Main Frame
    local MainFrame = New("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 780, 0, 530),
        Position = UDim2.new(0.5, -390, 0.5, -265),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, ScreenGui)
    MakeCorner(10, MainFrame)
    MakeStroke(Theme.Border, 1.5, MainFrame)

    -- Shadow
    local Shadow = New("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.4,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
    }, MainFrame)

    -- ═══════════════ SIDEBAR ═══════════════
    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
    }, MainFrame)
    MakeStroke(Theme.Border, 1, Sidebar)

    -- Logo area
    local LogoFrame = New("Frame", {
        Name = "LogoFrame",
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
    }, Sidebar)

    -- Logo icon (diamond shape)
    local LogoBg = New("Frame", {
        Name = "LogoBg",
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0.5, -22, 0.5, -22),
        BackgroundColor3 = Theme.SidebarActive,
        BorderSizePixel = 0,
    }, LogoFrame)
    MakeCorner(8, LogoBg)
    MakeStroke(Theme.Border, 1, LogoBg)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "◈",
        TextColor3 = Theme.TextPrimary,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
    }, LogoBg)

    -- Divider under logo
    New("Frame", {
        Size = UDim2.new(0.8, 0, 0, 1),
        Position = UDim2.new(0.1, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    }, LogoFrame)

    -- Tab list container
    local TabList = New("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -140),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)
    MakeList(2, TabList)
    MakePadding(6, 6, 8, 8, TabList)

    -- Settings at bottom
    local SettingsBtn = New("TextButton", {
        Name = "Settings",
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 1, -48),
        BackgroundColor3 = Theme.SidebarActive,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, Sidebar)
    MakeCorner(6, SettingsBtn)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⚙  Settings",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, SettingsBtn)
    MakePadding(0, 0, 10, 0, SettingsBtn:FindFirstChildWhichIsA("TextLabel"))

    -- ═══════════════ CONTENT AREA ═══════════════
    local ContentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
    }, MainFrame)

    -- Header
    local Header = New("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
    }, ContentArea)
    MakeStroke(Theme.Border, 1, Header)

    -- Search bar
    local SearchFrame = New("Frame", {
        Name = "SearchFrame",
        Size = UDim2.new(0, 180, 0, 30),
        Position = UDim2.new(0, 14, 0.5, -15),
        BackgroundColor3 = Theme.SearchBg,
        BorderSizePixel = 0,
    }, Header)
    MakeCorner(6, SearchFrame)
    MakeStroke(Theme.ElementBorder, 1, SearchFrame)

    New("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
    }, SearchFrame)

    local SearchBox = New("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.TextDim,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, SearchFrame)

    -- Username display
    local UserFrame = New("Frame", {
        Name = "UserFrame",
        Size = UDim2.new(0, 160, 0, 34),
        Position = UDim2.new(1, -170, 0.5, -17),
        BackgroundTransparency = 1,
    }, Header)

    New("TextLabel", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 0, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "👤",
        TextColor3 = Theme.TextSecondary,
        TextSize = 18,
    }, UserFrame)

    New("TextLabel", {
        Size = UDim2.new(1, -34, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text = username,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, UserFrame)

    -- Header divider
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    }, Header)

    -- Pages container
    local PagesHolder = New("Frame", {
        Name = "PagesHolder",
        Size = UDim2.new(1, 0, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, ContentArea)

    -- Make window draggable
    MakeDraggable(MainFrame, Header)

    -- ═══════════════════════════════════════════════════
    --   WINDOW OBJECT
    -- ═══════════════════════════════════════════════════
    local Window = {}
    Window._tabs = {}
    Window._tabButtons = {}
    Window._activeTab = nil
    Window._searchQuery = ""

    -- Search filter across all elements
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Window._searchQuery = SearchBox.Text:lower()
        Window:_FilterElements()
    end)

    function Window:_FilterElements()
        for _, tab in pairs(self._tabs) do
            for _, elem in pairs(tab._elements or {}) do
                if elem.Frame then
                    local label = elem.Label or ""
                    if self._searchQuery == "" or label:lower():find(self._searchQuery, 1, true) then
                        elem.Frame.Visible = true
                    else
                        elem.Frame.Visible = false
                    end
                end
            end
        end
    end

    function Window:_SwitchTab(tabObj)
        -- Hide all pages
        for _, t in pairs(self._tabs) do
            t.Page.Visible = false
        end
        -- Deactivate all tab buttons
        for _, btn in pairs(self._tabButtons) do
            Tween(btn, {BackgroundColor3 = Theme.Sidebar}, 0.15)
            btn:FindFirstChild("ActiveBar") and (btn.ActiveBar.Visible = false)
            local lbl = btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Theme.TextSecondary}, 0.15) end
        end
        -- Show selected tab
        tabObj.Page.Visible = true
        self._activeTab = tabObj
        local btn = tabObj._button
        if btn then
            Tween(btn, {BackgroundColor3 = Theme.SidebarActive}, 0.15)
            btn:FindFirstChild("ActiveBar") and (btn.ActiveBar.Visible = true)
            local lbl = btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Theme.TextPrimary}, 0.15) end
        end
    end

    -- ═══════════════════════════════════════════════════
    --   ADD TAB
    -- ═══════════════════════════════════════════════════
    function Window:AddTab(name, icon)
        icon = icon or "⊞"

        -- Sidebar button
        local TabBtn = New("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, TabList)
        MakeCorner(6, TabBtn)

        -- Active indicator bar
        local ActiveBar = New("Frame", {
            Name = "ActiveBar",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
        }, TabBtn)
        MakeCorner(3, ActiveBar)

        New("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = icon .. "  " .. name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, TabBtn)

        -- Hover effect
        TabBtn.MouseEnter:Connect(function()
            if self._activeTab and self._activeTab._button ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab and self._activeTab._button ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Theme.Sidebar}, 0.12)
            end
        end)

        -- Page for content
        local Page = New("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, PagesHolder)
        MakeList(6, Page)
        MakePadding(14, 14, 14, 14, Page)

        -- Tab Object
        local Tab = {}
        Tab._button = TabBtn
        Tab.Page = Page
        Tab._elements = {}

        table.insert(self._tabs, Tab)
        table.insert(self._tabButtons, TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            self:_SwitchTab(Tab)
        end)

        -- Auto-select first tab
        if #self._tabs == 1 then
            self:_SwitchTab(Tab)
        end

        -- ═══════════════════════════════════
        --   SECTION HEADER
        -- ═══════════════════════════════════
        function Tab:AddSection(title)
            local SectionLabel = New("TextLabel", {
                Name = "Section_" .. title,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.TextPrimary,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #self._elements,
            }, Page)
            table.insert(self._elements, {Frame = SectionLabel, Label = title})
            return SectionLabel
        end

        -- ═══════════════════════════════════
        --   TOGGLE
        -- ═══════════════════════════════════
        function Tab:AddToggle(label, default, callback)
            default = default or false
            callback = callback or function() end

            local ToggleFrame = New("Frame", {
                Name = "Toggle_" .. label,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                LayoutOrder = #self._elements,
            }, Page)
            MakeCorner(6, ToggleFrame)
            MakeStroke(Theme.ElementBorder, 1, ToggleFrame)

            New("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, ToggleFrame)

            -- Toggle pill
            local TogglePill = New("Frame", {
                Name = "Pill",
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -58, 0.5, -12),
                BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
            }, ToggleFrame)
            MakeCorner(12, TogglePill)
            MakeStroke(Theme.ElementBorder, 1, TogglePill)

            local Knob = New("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 18, 0, 18),
                Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Theme.ToggleKnob,
                BorderSizePixel = 0,
            }, TogglePill)
            MakeCorner(9, Knob)

            local state = default
            local toggling = false

            local ToggleBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 2,
            }, ToggleFrame)

            ToggleBtn.MouseEnter:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end)
            ToggleBtn.MouseLeave:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.Element}, 0.12)
            end)

            ToggleBtn.MouseButton1Click:Connect(function()
                if toggling then return end
                toggling = true
                state = not state
                if state then
                    Tween(TogglePill, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
                    Tween(Knob, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.2)
                else
                    Tween(TogglePill, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
                    Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
                end
                task.wait(0.21)
                toggling = false
                callback(state)
            end)

            local elem = {Frame = ToggleFrame, Label = label}
            table.insert(self._elements, elem)

            local ToggleObj = {}
            function ToggleObj:Set(val)
                state = val
                if state then
                    Tween(TogglePill, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
                    Tween(Knob, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.2)
                else
                    Tween(TogglePill, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
                    Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
                end
                callback(state)
            end
            function ToggleObj:Get() return state end
            return ToggleObj
        end

        -- ═══════════════════════════════════
        --   DROPDOWN
        -- ═══════════════════════════════════
        function Tab:AddDropdown(label, options, default, callback)
            options = options or {}
            default = default or options[1] or ""
            callback = callback or function() end

            local selected = default
            local isOpen = false
            local selectedIndices = {}

            local DropFrame = New("Frame", {
                Name = "Drop_" .. label,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                LayoutOrder = #self._elements,
                ClipsDescendants = false,
                ZIndex = 10,
            }, Page)
            MakeCorner(6, DropFrame)
            MakeStroke(Theme.ElementBorder, 1, DropFrame)

            New("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10,
            }, DropFrame)

            -- Value display area
            local ValueBox = New("Frame", {
                Name = "ValueBox",
                Size = UDim2.new(0, 160, 0, 30),
                Position = UDim2.new(1, -170, 0.5, -15),
                BackgroundColor3 = Theme.Dropdown,
                BorderSizePixel = 0,
                ZIndex = 10,
            }, DropFrame)
            MakeCorner(6, ValueBox)
            MakeStroke(Theme.ElementBorder, 1, ValueBox)

            local ValueLabel = New("TextLabel", {
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(selected),
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10,
            }, ValueBox)

            New("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1,
                Text = "⌄",
                TextColor3 = Theme.TextSecondary,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                ZIndex = 10,
            }, ValueBox)

            -- Dropdown panel (opens below)
            local DropPanel = New("Frame", {
                Name = "DropPanel",
                Size = UDim2.new(0, 170, 0, 0),
                Position = UDim2.new(1, -170, 1, 4),
                BackgroundColor3 = Theme.DropdownList,
                BorderSizePixel = 0,
                ZIndex = 50,
                ClipsDescendants = true,
                Visible = false,
            }, DropFrame)
            MakeCorner(6, DropPanel)
            MakeStroke(Theme.ElementBorder, 1, DropPanel)

            -- Search inside dropdown
            local DropSearch = New("Frame", {
                Size = UDim2.new(1, -8, 0, 28),
                Position = UDim2.new(0, 4, 0, 4),
                BackgroundColor3 = Theme.SearchBg,
                BorderSizePixel = 0,
                ZIndex = 51,
            }, DropPanel)
            MakeCorner(5, DropSearch)
            MakeStroke(Theme.ElementBorder, 1, DropSearch)

            New("TextLabel", {
                Size = UDim2.new(0, 18, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = "🔍",
                TextColor3 = Theme.TextDim,
                TextSize = 10,
                ZIndex = 52,
            }, DropSearch)

            local DropSearchBox = New("TextBox", {
                Size = UDim2.new(1, -26, 1, 0),
                Position = UDim2.new(0, 22, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText = "Search",
                PlaceholderColor3 = Theme.TextDim,
                Text = "",
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 52,
            }, DropSearch)

            -- Options scroll
            local OptionScroll = New("ScrollingFrame", {
                Size = UDim2.new(1, -4, 1, -40),
                Position = UDim2.new(0, 2, 0, 36),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 51,
            }, DropPanel)
            MakeList(1, OptionScroll)
            MakePadding(2, 2, 2, 2, OptionScroll)

            local optionButtons = {}

            local function BuildOptions(filter)
                filter = filter and filter:lower() or ""
                for _, btn in pairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                for _, opt in ipairs(options) do
                    local optStr = tostring(opt)
                    if filter == "" or optStr:lower():find(filter, 1, true) then
                        local isSelected = (optStr == tostring(selected))
                        local Opt = New("TextButton", {
                            Name = "Opt_" .. optStr,
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = isSelected and Theme.DropdownSelected or Theme.DropdownList,
                            BorderSizePixel = 0,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 52,
                        }, OptionScroll)
                        MakeCorner(4, Opt)

                        if isSelected then
                            New("Frame", {
                                Size = UDim2.new(0, 3, 0.6, 0),
                                Position = UDim2.new(0, 0, 0.2, 0),
                                BackgroundColor3 = Theme.Accent,
                                BorderSizePixel = 0,
                                ZIndex = 53,
                            }, Opt)
                        end

                        New("TextLabel", {
                            Size = UDim2.new(1, -10, 1, 0),
                            Position = UDim2.new(0, 10, 0, 0),
                            BackgroundTransparency = 1,
                            Text = optStr,
                            TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary,
                            TextSize = 12,
                            Font = isSelected and Enum.Font.GothamMedium or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 53,
                        }, Opt)

                        Opt.MouseEnter:Connect(function()
                            if optStr ~= tostring(selected) then
                                Tween(Opt, {BackgroundColor3 = Theme.DropdownHover}, 0.1)
                            end
                        end)
                        Opt.MouseLeave:Connect(function()
                            if optStr ~= tostring(selected) then
                                Tween(Opt, {BackgroundColor3 = Theme.DropdownList}, 0.1)
                            end
                        end)

                        Opt.MouseButton1Click:Connect(function()
                            selected = opt
                            ValueLabel.Text = optStr
                            -- Close
                            isOpen = false
                            Tween(DropPanel, {Size = UDim2.new(0, 170, 0, 0)}, 0.2)
                            task.wait(0.21)
                            DropPanel.Visible = false
                            BuildOptions("")
                            callback(selected)
                        end)

                        table.insert(optionButtons, Opt)
                    end
                end
            end

            BuildOptions("")

            DropSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                BuildOptions(DropSearchBox.Text)
            end)

            -- Open/close
            local panelHeight = math.min(#options * 29 + 44, 200)

            local OpenBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11,
            }, DropFrame)

            OpenBtn.MouseEnter:Connect(function()
                Tween(DropFrame, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end)
            OpenBtn.MouseLeave:Connect(function()
                Tween(DropFrame, {BackgroundColor3 = Theme.Element}, 0.12)
            end)

            OpenBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    DropPanel.Visible = true
                    DropSearchBox.Text = ""
                    BuildOptions("")
                    Tween(DropPanel, {Size = UDim2.new(0, 170, 0, panelHeight)}, 0.2, Enum.EasingStyle.Quart)
                else
                    Tween(DropPanel, {Size = UDim2.new(0, 170, 0, 0)}, 0.15)
                    task.wait(0.16)
                    DropPanel.Visible = false
                end
            end)

            local elem = {Frame = DropFrame, Label = label}
            table.insert(self._elements, elem)

            local DropObj = {}
            function DropObj:Set(val)
                selected = val
                ValueLabel.Text = tostring(val)
                BuildOptions("")
                callback(selected)
            end
            function DropObj:Get() return selected end
            function DropObj:SetOptions(newOptions)
                options = newOptions
                BuildOptions("")
            end
            return DropObj
        end

        -- ═══════════════════════════════════
        --   TEXT INPUT
        -- ═══════════════════════════════════
        function Tab:AddTextInput(label, placeholder, callback)
            placeholder = placeholder or "Input..."
            callback = callback or function() end

            local InputFrame = New("Frame", {
                Name = "Input_" .. label,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                LayoutOrder = #self._elements,
            }, Page)
            MakeCorner(6, InputFrame)
            MakeStroke(Theme.ElementBorder, 1, InputFrame)

            New("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, InputFrame)

            local InputBox = New("TextBox", {
                Name = "Box",
                Size = UDim2.new(0, 155, 0, 28),
                Position = UDim2.new(1, -165, 0.5, -14),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel = 0,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme.TextDim,
                Text = "",
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            }, InputFrame)
            MakeCorner(5, InputBox)
            MakeStroke(Theme.ElementBorder, 1, InputBox)
            MakePadding(0, 0, 8, 0, InputBox)

            InputBox.FocusLost:Connect(function(enter)
                if enter then
                    callback(InputBox.Text)
                end
            end)

            InputBox.Focused:Connect(function()
                Tween(InputBox:FindFirstChildWhichIsA("UIStroke"), {Color = Theme.Accent}, 0.15)
            end)
            InputBox.FocusLost:Connect(function()
                Tween(InputBox:FindFirstChildWhichIsA("UIStroke"), {Color = Theme.ElementBorder}, 0.15)
            end)

            local elem = {Frame = InputFrame, Label = label}
            table.insert(self._elements, elem)

            local InputObj = {}
            function InputObj:Set(val)
                InputBox.Text = tostring(val)
                callback(val)
            end
            function InputObj:Get() return InputBox.Text end
            return InputObj
        end

        -- ═══════════════════════════════════
        --   SLIDER
        -- ═══════════════════════════════════
        function Tab:AddSlider(label, min, max, default, callback)
            min = min or 0
            max = max or 100
            default = math.clamp(default or 50, min, max)
            callback = callback or function() end

            local SliderFrame = New("Frame", {
                Name = "Slider_" .. label,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                LayoutOrder = #self._elements,
            }, Page)
            MakeCorner(6, SliderFrame)
            MakeStroke(Theme.ElementBorder, 1, SliderFrame)

            -- Track
            local Track = New("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -80, 0, 6),
                Position = UDim2.new(0, 14, 0.5, -3),
                BackgroundColor3 = Theme.SliderTrack,
                BorderSizePixel = 0,
            }, SliderFrame)
            MakeCorner(3, Track)

            -- Fill
            local initialRatio = (default - min) / (max - min)
            local Fill = New("Frame", {
                Name = "Fill",
                Size = UDim2.new(initialRatio, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel = 0,
            }, Track)
            MakeCorner(3, Fill)

            -- Knob
            local Knob = New("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(initialRatio, -7, 0.5, -7),
                BackgroundColor3 = Theme.SliderKnob,
                BorderSizePixel = 0,
                ZIndex = 2,
            }, Track)
            MakeCorner(7, Knob)
            MakeStroke(Theme.Accent, 1.5, Knob)

            -- Value display
            local ValueBox = New("Frame", {
                Size = UDim2.new(0, 46, 0, 28),
                Position = UDim2.new(1, -58, 0.5, -14),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel = 0,
            }, SliderFrame)
            MakeCorner(5, ValueBox)
            MakeStroke(Theme.ElementBorder, 1, ValueBox)

            local ValueLabel = New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamMedium,
            }, ValueBox)

            local currentValue = default
            local sliding = false

            local function UpdateSlider(ratio)
                ratio = math.clamp(ratio, 0, 1)
                currentValue = math.round(min + (max - min) * ratio)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                Knob.Position = UDim2.new(ratio, -7, 0.5, -7)
                ValueLabel.Text = tostring(currentValue)
                callback(currentValue)
            end

            local SliderBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 3,
            }, Track)

            SliderBtn.MouseButton1Down:Connect(function()
                sliding = true
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                if sliding then
                    local trackPos = Track.AbsolutePosition.X
                    local trackSize = Track.AbsoluteSize.X
                    local mouseX = UserInputService:GetMouseLocation().X
                    local ratio = (mouseX - trackPos) / trackSize
                    UpdateSlider(ratio)
                end
            end)

            SliderBtn.MouseButton1Click:Connect(function()
                local trackPos = Track.AbsolutePosition.X
                local trackSize = Track.AbsoluteSize.X
                local mouseX = UserInputService:GetMouseLocation().X
                UpdateSlider((mouseX - trackPos) / trackSize)
            end)

            SliderFrame.MouseEnter:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end)
            SliderFrame.MouseLeave:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.Element}, 0.12)
            end)

            local elem = {Frame = SliderFrame, Label = label}
            table.insert(self._elements, elem)

            local SliderObj = {}
            function SliderObj:Set(val)
                val = math.clamp(val, min, max)
                local ratio = (val - min) / (max - min)
                UpdateSlider(ratio)
            end
            function SliderObj:Get() return currentValue end
            return SliderObj
        end

        -- ═══════════════════════════════════
        --   BUTTON
        -- ═══════════════════════════════════
        function Tab:AddButton(label, callback)
            callback = callback or function() end

            local BtnFrame = New("TextButton", {
                Name = "Btn_" .. label,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Button,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = #self._elements,
            }, Page)
            MakeCorner(6, BtnFrame)
            MakeStroke(Theme.ButtonBorder, 1.5, BtnFrame)

            New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                --LetterSpacing = 2,
            }, BtnFrame)

            BtnFrame.MouseEnter:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end)
            BtnFrame.MouseLeave:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.Button}, 0.15)
            end)
            BtnFrame.MouseButton1Down:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
            end)
            BtnFrame.MouseButton1Up:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.ButtonHover}, 0.1)
            end)
            BtnFrame.MouseButton1Click:Connect(function()
                callback()
            end)

            local elem = {Frame = BtnFrame, Label = label}
            table.insert(self._elements, elem)
        end

        -- ═══════════════════════════════════
        --   LABEL (info text)
        -- ═══════════════════════════════════
        function Tab:AddLabel(text)
            local LabelFrame = New("Frame", {
                Name = "Label_" .. text,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                LayoutOrder = #self._elements,
            }, Page)

            New("TextLabel", {
                Size = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, LabelFrame)

            local elem = {Frame = LabelFrame, Label = text}
            table.insert(self._elements, elem)
        end

        return Tab
    end

    -- Keybind to toggle UI visibility
    local uiVisible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
        end
    end)

    return Window
end

-- ═══════════════════════════════════════════════════════
--   THEME CUSTOMIZATION
-- ═══════════════════════════════════════════════════════
function NovaUI:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        Theme[k] = v
    end
end

function NovaUI:GetTheme()
    return Theme
end

return NovaUI
