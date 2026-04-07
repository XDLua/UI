-- ╔══════════════════════════════════════════════╗
-- ║         NightUI Library for Roblox           ║
-- ║      Designed for Executor / LoadString      ║
-- ╚══════════════════════════════════════════════╝

local NightUI = {}
NightUI.__index = NightUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════
-- THEME
-- ══════════════════════════════════════════
local Theme = {
    Background      = Color3.fromRGB(18, 22, 32),
    Sidebar         = Color3.fromRGB(22, 27, 40),
    SidebarActive   = Color3.fromRGB(38, 46, 68),
    Panel           = Color3.fromRGB(26, 31, 46),
    Element         = Color3.fromRGB(32, 38, 56),
    ElementHover    = Color3.fromRGB(40, 48, 68),
    Accent          = Color3.fromRGB(99, 140, 255),
    AccentDark      = Color3.fromRGB(60, 90, 200),
    ToggleOff       = Color3.fromRGB(55, 62, 80),
    ToggleOn        = Color3.fromRGB(99, 140, 255),
    TextPrimary     = Color3.fromRGB(230, 235, 255),
    TextSecondary   = Color3.fromRGB(130, 145, 185),
    TextDim        = Color3.fromRGB(80, 90, 120),
    Border          = Color3.fromRGB(45, 52, 75),
    Divider         = Color3.fromRGB(38, 45, 65),
    SliderFill      = Color3.fromRGB(99, 140, 255),
    SliderBg        = Color3.fromRGB(38, 46, 68),
    ButtonBg        = Color3.fromRGB(38, 46, 68),
    ButtonHover     = Color3.fromRGB(55, 68, 100),
    Shadow          = Color3.fromRGB(0, 0, 0),
    Scrollbar       = Color3.fromRGB(55, 65, 95),
    DropdownBg      = Color3.fromRGB(22, 27, 40),
    DropdownItem    = Color3.fromRGB(28, 34, 50),
    DropdownHover   = Color3.fromRGB(38, 48, 72),
    DropdownSelected= Color3.fromRGB(45, 60, 100),
}

-- ══════════════════════════════════════════
-- UTILITIES
-- ══════════════════════════════════════════
local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
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

local function MakeRounded(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function MakePadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or 6)
    pad.PaddingBottom = UDim.new(0, bottom or 6)
    pad.PaddingLeft = UDim.new(0, left or 10)
    pad.PaddingRight = UDim.new(0, right or 10)
    pad.Parent = parent
    return pad
end

local function MakeStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- ══════════════════════════════════════════
-- WINDOW CREATION
-- ══════════════════════════════════════════
function NightUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NightUI"
    local width = config.Width or 780
    local height = config.Height or 520

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "NightUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = (RunService:IsStudio() and LocalPlayer:FindFirstChildOfClass("PlayerGui")) or PlayerGui
    })

    -- Shadow frame
    local Shadow = Create("Frame", {
        Name = "Shadow",
        Size = UDim2.new(0, width + 16, 0, height + 16),
        Position = UDim2.new(0.5, -(width/2) - 8, 0.5, -(height/2) - 8),
        BackgroundColor3 = Theme.Shadow,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = ScreenGui,
        ZIndex = 1,
    })
    MakeRounded(Shadow, 14)

    -- Main Window
    local Window = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui,
        ZIndex = 2,
    })
    MakeRounded(Window, 12)
    MakeStroke(Window, Theme.Border, 1)
    MakeDraggable(Window)
    MakeDraggable(Shadow, Window)

    -- ── LEFT SIDEBAR ──────────────────────────────
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 185, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = Window,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Sidebar })
    -- Clip right corners
    Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = Sidebar,
    })

    -- Avatar circle
    local AvatarFrame = Create("Frame", {
        Name = "AvatarFrame",
        Size = UDim2.new(0, 72, 0, 72),
        Position = UDim2.new(0.5, -36, 0, 22),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = Sidebar,
    })
    MakeRounded(AvatarFrame, 36)
    MakeStroke(AvatarFrame, Theme.Accent, 2)

    -- Avatar icon (person SVG-like using frames)
    local AvatarIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0.5, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031075938",
        ImageColor3 = Theme.TextSecondary,
        ZIndex = 5,
        Parent = AvatarFrame,
    })

    -- Username label
    local UsernameLabel = Create("TextLabel", {
        Name = "UsernameLabel",
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 100),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
        Parent = Sidebar,
    })

    -- Divider
    Create("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, 130),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = Sidebar,
    })

    -- Tab list container
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -200),
        Position = UDim2.new(0, 0, 0, 140),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        ZIndex = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar,
    })
    local TabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TabList,
    })
    MakePadding(TabList, 4, 4, 8, 8)

    -- Settings button at bottom of sidebar
    local SettingsBtn = Create("TextButton", {
        Name = "SettingsBtn",
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 1, -48),
        BackgroundColor3 = Theme.SidebarActive,
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 4,
        Parent = Sidebar,
    })
    MakeRounded(SettingsBtn, 7)
    Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031229846",
        ImageColor3 = Theme.TextSecondary,
        ZIndex = 5,
        Parent = SettingsBtn,
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = SettingsBtn,
    })

    -- ── TOP BAR ───────────────────────────────────
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, -185, 0, 50),
        Position = UDim2.new(0, 185, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Window,
    })

    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = TopBar,
    })

    -- Minimize button
    local MinBtn = Create("TextButton", {
        Name = "MinBtn",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -76, 0.5, -16),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 1,
        Text = "─",
        TextColor3 = Theme.TextSecondary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 5,
        Parent = TopBar,
    })
    MakeRounded(MinBtn, 6)

    -- Close button
    local CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(200, 70, 70),
        BackgroundTransparency = 0.5,
        Text = "✕",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 5,
        Parent = TopBar,
    })
    MakeRounded(CloseBtn, 6)

    -- Top Divider
    Create("Frame", {
        Size = UDim2.new(1, -185, 0, 1),
        Position = UDim2.new(0, 185, 0, 50),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = Window,
    })

    -- ── CONTENT AREA ─────────────────────────────
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -185, 1, -50),
        Position = UDim2.new(0, 185, 0, 51),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 3,
        Parent = Window,
    })

    -- ── CLOSE / MINIMIZE LOGIC ────────────────────
    local minimized = false
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(Window.Position.X.Scale, Window.Position.X.Offset + width/2, Window.Position.Y.Scale, Window.Position.Y.Offset + height/2) })
        task.delay(0.35, function() ScreenGui:Destroy() end)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Size = UDim2.new(0, width, 0, 50) })
        else
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Size = UDim2.new(0, width, 0, height) })
        end
    end)

    -- ── BUTTON HOVER EFFECTS ─────────────────────
    for _, btn in ipairs({MinBtn, CloseBtn}) do
        btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = btn.Name == "CloseBtn" and 0.5 or 1 })
        end)
    end

    -- ════════════════════════════════════════
    -- WINDOW OBJECT
    -- ════════════════════════════════════════
    local WindowObj = {}
    WindowObj._gui = ScreenGui
    WindowObj._window = Window
    WindowObj._tabList = TabList
    WindowObj._contentArea = ContentArea
    WindowObj._tabs = {}
    WindowObj._activeTab = nil

    -- ── CREATE TAB ────────────────────────────────
    function WindowObj:CreateTab(tabName, icon)
        local tabIndex = #self._tabs + 1

        -- Sidebar button
        local TabBtn = Create("TextButton", {
            Name = "Tab_" .. tabName,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.SidebarActive,
            BackgroundTransparency = tabIndex == 1 and 0 or 1,
            Text = "",
            ZIndex = 5,
            Parent = TabList,
        })
        MakeRounded(TabBtn, 7)

        -- Icon
        Create("ImageLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 10, 0.5, -7),
            BackgroundTransparency = 1,
            Image = icon or "rbxassetid://10723407389",
            ImageColor3 = tabIndex == 1 and Theme.Accent or Theme.TextSecondary,
            ZIndex = 6,
            Name = "Icon",
            Parent = TabBtn,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -34, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = tabIndex == 1 and Theme.TextPrimary or Theme.TextSecondary,
            TextSize = 13,
            Font = tabIndex == 1 and Enum.Font.GothamMedium or Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Name = "Label",
            Parent = TabBtn,
        })

        -- Tab content page
        local TabPage = Create("ScrollingFrame", {
            Name = "Page_" .. tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = tabIndex == 1,
            ZIndex = 4,
            Parent = ContentArea,
        })
        MakePadding(TabPage, 10, 10, 10, 10)

        local PageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = TabPage,
        })

        -- ── TAB HEADER (name + search) ──────────
        local TabHeader = Create("Frame", {
            Name = "TabHeader",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            ZIndex = 5,
            Parent = TabPage,
        })
        Create("TextLabel", {
            Size = UDim2.new(0, 150, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextPrimary,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = TabHeader,
        })

        local SearchBox = Create("Frame", {
            Size = UDim2.new(0, 200, 0, 28),
            Position = UDim2.new(1, -200, 0.5, -14),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            ZIndex = 6,
            Parent = TabHeader,
        })
        MakeRounded(SearchBox, 7)
        MakeStroke(SearchBox, Theme.Border, 1)

        Create("ImageLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 8, 0.5, -7),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6031154378",
            ImageColor3 = Theme.TextDim,
            ZIndex = 7,
            Parent = SearchBox,
        })

        local SearchInput = Create("TextBox", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            PlaceholderText = "Search",
            PlaceholderColor3 = Theme.TextDim,
            Text = "",
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 7,
            Parent = SearchBox,
        })

        -- Tab click logic
        TabBtn.MouseButton1Click:Connect(function()
            -- Deactivate all
            for _, t in ipairs(self._tabs) do
                Tween(t.btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
                t.btn.Icon.ImageColor3 = Theme.TextSecondary
                t.btn.Label.TextColor3 = Theme.TextSecondary
                t.btn.Label.Font = Enum.Font.Gotham
                t.page.Visible = false
            end
            -- Activate this
            Tween(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
            TabBtn.Icon.ImageColor3 = Theme.Accent
            TabBtn.Label.TextColor3 = Theme.TextPrimary
            TabBtn.Label.Font = Enum.Font.GothamMedium
            TabPage.Visible = true
            self._activeTab = tabIndex
        end)

        if tabIndex == 1 then self._activeTab = 1 end

        local TabObj = {
            _page = TabPage,
            btn = TabBtn,
            page = TabPage,
        }

        -- ════════════════════════════════════════
        -- ELEMENTS
        -- ════════════════════════════════════════

        -- ── TOGGLE ───────────────────────────────
        function TabObj:AddToggle(config)
            config = config or {}
            local name = config.Name or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            local state = default

            local Row = Create("Frame", {
                Name = "Toggle_" .. name,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = TabPage,
            })
            MakeRounded(Row, 8)
            MakeStroke(Row, Theme.Border, 1)

            Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = Row,
            })

            -- Toggle track
            local Track = Create("Frame", {
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -56, 0.5, -12),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = Row,
            })
            MakeRounded(Track, 12)

            -- Toggle knob
            local Knob = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0,
                ZIndex = 7,
                Parent = Track,
            })
            MakeRounded(Knob, 9)

            local ToggleBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 8,
                Parent = Row,
            })

            local function UpdateToggle(newState)
                state = newState
                Tween(Track, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
                Tween(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) })
                callback(state)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                UpdateToggle(not state)
            end)

            -- Hover
            ToggleBtn.MouseEnter:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
            end)
            ToggleBtn.MouseLeave:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
            end)

            local obj = {}
            function obj:Set(v) UpdateToggle(v) end
            function obj:Get() return state end
            return obj
        end

        -- ── DROPDOWN ─────────────────────────────
        function TabObj:AddDropdown(config)
            config = config or {}
            local name = config.Name or "DropDown"
            local options = config.Options or {"1","2","3"}
            local default = config.Default
            local multiSelect = config.Multi or false
            local callback = config.Callback or function() end

            local selected = multiSelect and {} or (default or options[1])
            local isOpen = false

            local Row = Create("Frame", {
                Name = "Dropdown_" .. name,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 5,
                ClipsDescendants = false,
                Parent = TabPage,
            })
            MakeRounded(Row, 8)
            MakeStroke(Row, Theme.Border, 1)

            Create("TextLabel", {
                Size = UDim2.new(0, 180, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = Row,
            })

            -- Value display
            local ValueFrame = Create("Frame", {
                Size = UDim2.new(0, 180, 0, 28),
                Position = UDim2.new(1, -192, 0.5, -14),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = Row,
            })
            MakeRounded(ValueFrame, 6)
            MakeStroke(ValueFrame, Theme.Border, 1)

            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = multiSelect and "Select..." or tostring(selected),
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 7,
                Parent = ValueFrame,
            })

            -- Arrow
            local ArrowLabel = Create("TextLabel", {
                Size = UDim2.new(0, 22, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "⌄",
                TextColor3 = Theme.TextSecondary,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                ZIndex = 7,
                Parent = ValueFrame,
            })

            -- Dropdown panel
            local DropPanel = Create("Frame", {
                Name = "DropPanel",
                Size = UDim2.new(0, 180, 0, 0),
                Position = UDim2.new(1, -192, 1, 4),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 20,
                Visible = false,
                Parent = Row,
            })
            MakeRounded(DropPanel, 8)
            MakeStroke(DropPanel, Theme.Border, 1)

            -- Search inside dropdown
            local DSearchBox = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 28),
                Position = UDim2.new(0, 5, 0, 5),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 21,
                Parent = DropPanel,
            })
            MakeRounded(DSearchBox, 6)
            MakeStroke(DSearchBox, Theme.Border, 1)

            Create("ImageLabel", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 7, 0.5, -6),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031154378",
                ImageColor3 = Theme.TextDim,
                ZIndex = 22,
                Parent = DSearchBox,
            })

            local DSearchInput = Create("TextBox", {
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 24, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText = "Search",
                PlaceholderColor3 = Theme.TextDim,
                Text = "",
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 22,
                Parent = DSearchBox,
            })

            -- Options list
            local OptionsList = Create("ScrollingFrame", {
                Size = UDim2.new(1, -6, 1, -44),
                Position = UDim2.new(0, 3, 0, 38),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Scrollbar,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 21,
                Parent = DropPanel,
            })
            local OptionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = OptionsList,
            })
            MakePadding(OptionsList, 2, 2, 0, 0)

            local optionButtons = {}

            local function UpdateValueLabel()
                if multiSelect then
                    local selected_list = {}
                    for k, _ in pairs(selected) do table.insert(selected_list, k) end
                    ValueLabel.Text = #selected_list > 0 and table.concat(selected_list, ", ") or "Select..."
                else
                    ValueLabel.Text = tostring(selected)
                end
            end

            local function BuildOptions(filter)
                for _, c in ipairs(OptionsList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    if filter == "" or string.lower(opt):find(string.lower(filter), 1, true) then
                        local isSelected = multiSelect and selected[opt] or (selected == opt)
                        local OptBtn = Create("TextButton", {
                            Name = opt,
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = isSelected and Theme.DropdownSelected or Theme.DropdownItem,
                            BackgroundTransparency = isSelected and 0 or 0,
                            Text = opt,
                            TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary,
                            TextSize = 12,
                            Font = isSelected and Enum.Font.GothamMedium or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 22,
                            Parent = OptionsList,
                        })
                        MakeRounded(OptBtn, 5)
                        MakePadding(OptBtn, 0, 0, 10, 0)

                        if isSelected then
                            Create("TextLabel", {
                                Size = UDim2.new(0, 20, 1, 0),
                                Position = UDim2.new(1, -22, 0, 0),
                                BackgroundTransparency = 1,
                                Text = "✓",
                                TextColor3 = Theme.Accent,
                                TextSize = 12,
                                Font = Enum.Font.GothamBold,
                                ZIndex = 23,
                                Parent = OptBtn,
                            })
                        end

                        OptBtn.MouseEnter:Connect(function()
                            if not (multiSelect and selected[opt]) and selected ~= opt then
                                Tween(OptBtn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.DropdownHover })
                            end
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            local sel = multiSelect and selected[opt] or (selected == opt)
                            Tween(OptBtn, TweenInfo.new(0.1), { BackgroundColor3 = sel and Theme.DropdownSelected or Theme.DropdownItem })
                        end)

                        OptBtn.MouseButton1Click:Connect(function()
                            if multiSelect then
                                selected[opt] = not selected[opt] or nil
                            else
                                selected = opt
                                -- Close after pick
                                isOpen = false
                                Tween(DropPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 180, 0, 0) })
                                task.delay(0.2, function() DropPanel.Visible = false end)
                                Tween(ArrowLabel, TweenInfo.new(0.2), { Rotation = 0 })
                            end
                            UpdateValueLabel()
                            BuildOptions(DSearchInput.Text)
                            callback(multiSelect and selected or opt)
                        end)
                    end
                end
            end

            BuildOptions("")

            DSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
                BuildOptions(DSearchInput.Text)
            end)

            -- Toggle open/close
            local DropToggleBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 8,
                Parent = Row,
            })

            DropToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local optCount = math.min(#options, 6)
                    local panelH = 44 + optCount * 30 + 10
                    DropPanel.Visible = true
                    DropPanel.Size = UDim2.new(0, 180, 0, 0)
                    Tween(DropPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 180, 0, panelH) })
                    Tween(ArrowLabel, TweenInfo.new(0.2), { Rotation = 180 })
                else
                    Tween(DropPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 180, 0, 0) })
                    task.delay(0.2, function() DropPanel.Visible = false end)
                    Tween(ArrowLabel, TweenInfo.new(0.2), { Rotation = 0 })
                end
            end)

            -- Hover
            DropToggleBtn.MouseEnter:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
            end)
            DropToggleBtn.MouseLeave:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
            end)

            local obj = {}
            function obj:Set(v)
                if multiSelect then selected = v
                else selected = v end
                UpdateValueLabel()
                BuildOptions("")
            end
            function obj:Get() return selected end
            function obj:Refresh(newOptions)
                options = newOptions
                BuildOptions(DSearchInput.Text)
            end
            return obj
        end

        -- ── TEXT INPUT ────────────────────────────
        function TabObj:AddTextInput(config)
            config = config or {}
            local name = config.Name or "TextInput"
            local placeholder = config.Placeholder or "Input..."
            local default = config.Default or ""
            local callback = config.Callback or function() end

            local Row = Create("Frame", {
                Name = "TextInput_" .. name,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = TabPage,
            })
            MakeRounded(Row, 8)
            MakeStroke(Row, Theme.Border, 1)

            Create("TextLabel", {
                Size = UDim2.new(0, 200, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = Row,
            })

            local InputBox = Create("TextBox", {
                Size = UDim2.new(0, 160, 0, 28),
                Position = UDim2.new(1, -172, 0.5, -14),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel = 0,
                Text = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme.TextDim,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 7,
                Parent = Row,
            })
            MakeRounded(InputBox, 6)
            MakeStroke(InputBox, Theme.Border, 1)
            MakePadding(InputBox, 0, 0, 10, 0)

            InputBox.FocusLost:Connect(function(enterPressed)
                callback(InputBox.Text, enterPressed)
            end)

            InputBox.Focused:Connect(function()
                Tween(InputBox, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
            end)
            InputBox.FocusLost:Connect(function()
                Tween(InputBox, TweenInfo.new(0.15), { BackgroundColor3 = Theme.DropdownBg })
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
            end)

            local obj = {}
            function obj:Set(v) InputBox.Text = v end
            function obj:Get() return InputBox.Text end
            return obj
        end

        -- ── SLIDER ───────────────────────────────
        function TabObj:AddSlider(config)
            config = config or {}
            local name = config.Name or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or 50
            local callback = config.Callback or function() end
            local value = math.clamp(default, min, max)

            local Row = Create("Frame", {
                Name = "Slider_" .. name,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = TabPage,
            })
            MakeRounded(Row, 8)
            MakeStroke(Row, Theme.Border, 1)

            Create("TextLabel", {
                Size = UDim2.new(0, 120, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = Row,
            })

            -- Value box
            local ValueBox = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 26),
                Position = UDim2.new(1, -50, 0.5, -13),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = Row,
            })
            MakeRounded(ValueBox, 5)
            MakeStroke(ValueBox, Theme.Border, 1)

            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamMedium,
                ZIndex = 7,
                Parent = ValueBox,
            })

            -- Track
            local Track = Create("Frame", {
                Size = UDim2.new(1, -130, 0, 6),
                Position = UDim2.new(0, 100, 0.5, -3),
                BackgroundColor3 = Theme.SliderBg,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = Row,
            })
            MakeRounded(Track, 3)

            -- Fill
            local Fill = Create("Frame", {
                Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel = 0,
                ZIndex = 7,
                Parent = Track,
            })
            MakeRounded(Fill, 3)

            -- Knob
            local Knob = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((value - min)/(max - min), -8, 0.5, -8),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0,
                ZIndex = 8,
                Parent = Track,
            })
            MakeRounded(Knob, 8)
            Create("UIStroke", { Color = Theme.Accent, Thickness = 2, Parent = Knob })

            -- Drag logic
            local dragging = false

            local function UpdateSlider(input)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local relX = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
                value = math.floor(min + relX * (max - min) + 0.5)
                local pct = (value - min) / (max - min)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Knob.Position = UDim2.new(pct, -8, 0.5, -8)
                ValueLabel.Text = tostring(value)
                callback(value)
            end

            local SliderBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 9,
                Parent = Track,
            })

            SliderBtn.MouseButton1Down:Connect(function(x, y)
                dragging = true
                UpdateSlider({ Position = Vector2.new(x, y) })
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            Row.MouseEnter:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
            end)
            Row.MouseLeave:Connect(function()
                Tween(Row, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
            end)

            local obj = {}
            function obj:Set(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Knob.Position = UDim2.new(pct, -8, 0.5, -8)
                ValueLabel.Text = tostring(value)
            end
            function obj:Get() return value end
            return obj
        end

        -- ── BUTTON ───────────────────────────────
        function TabObj:AddButton(config)
            config = config or {}
            local name = config.Name or "Button"
            local callback = config.Callback or function() end

            local Btn = Create("TextButton", {
                Name = "Button_" .. name,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ButtonBg,
                BorderSizePixel = 0,
                Text = string.upper(name),
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                ZIndex = 5,
                Parent = TabPage,
            })
            MakeRounded(Btn, 8)
            MakeStroke(Btn, Theme.Accent, 1)

            Btn.MouseEnter:Connect(function()
                Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ButtonHover })
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ButtonBg })
            end)
            Btn.MouseButton1Down:Connect(function()
                Tween(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.AccentDark })
            end)
            Btn.MouseButton1Up:Connect(function()
                Tween(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.ButtonHover })
                callback()
            end)

            local obj = {}
            function obj:SetText(t) Btn.Text = string.upper(t) end
            return obj
        end

        -- ── LABEL ────────────────────────────────
        function TabObj:AddLabel(config)
            config = config or {}
            local text = config.Text or "Label"

            local Lbl = Create("TextLabel", {
                Name = "Label_" .. text,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = TabPage,
            })
            MakePadding(Lbl, 0, 0, 14, 0)

            local obj = {}
            function obj:SetText(t) Lbl.Text = t end
            return obj
        end

        -- ── SEPARATOR ────────────────────────────
        function TabObj:AddSeparator()
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = TabPage,
            })
        end

        table.insert(self._tabs, TabObj)
        return TabObj
    end

    return WindowObj
end

return NightUI
