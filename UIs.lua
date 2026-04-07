-- XDLua UI Library v4.0
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/XDLuaUI/main/XDLua.lua"))()

local XDLua = {}
XDLua.__index = XDLua

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local LocalPlayer = Players.LocalPlayer
local COLORS = {
    Background    = Color3.fromRGB(18, 22, 30),
    Sidebar       = Color3.fromRGB(22, 27, 38),
    Panel         = Color3.fromRGB(26, 32, 44),
    Element       = Color3.fromRGB(30, 37, 52),
    ElementHover  = Color3.fromRGB(36, 44, 62),
    Accent        = Color3.fromRGB(99, 120, 180),
    AccentDark    = Color3.fromRGB(60, 80, 140),
    ToggleOn      = Color3.fromRGB(99, 120, 180),
    ToggleOff     = Color3.fromRGB(50, 58, 78),
    Text          = Color3.fromRGB(220, 225, 235),
    TextDim       = Color3.fromRGB(140, 150, 170),
    TextDark      = Color3.fromRGB(90, 100, 125),
    Border        = Color3.fromRGB(45, 55, 75),
    Slider        = Color3.fromRGB(40, 50, 70),
    SliderFill    = Color3.fromRGB(99, 120, 180),
    Dropdown      = Color3.fromRGB(22, 27, 38),
    DropItem      = Color3.fromRGB(30, 37, 52),
    DropItemHover = Color3.fromRGB(40, 50, 70),
    ButtonBg      = Color3.fromRGB(35, 42, 58),
    ButtonHover   = Color3.fromRGB(50, 60, 85),
    White         = Color3.fromRGB(255, 255, 255),
}
local FONT = Enum.Font.GothamSemiBold
local FONT_REG = Enum.Font.Gotham

-- Utility
local function tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(dur or 0.2, style, dir), props):Play()
end

local function corner(obj, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 6)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function newInstance(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Icon (grid dots)
local function makeGridIcon(parent, size)
    size = size or 14
    local frame = newInstance("Frame", {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
    }, parent)
    local dot = 2
    local gap = (size - dot*3) / 4
    for row = 0, 2 do
        for col = 0, 2 do
            newInstance("Frame", {
                Size = UDim2.new(0, dot, 0, dot),
                Position = UDim2.new(0, gap + col*(dot+gap), 0, gap + row*(dot+gap)),
                BackgroundColor3 = COLORS.TextDim,
                BorderSizePixel = 0,
            }, frame)
        end
    end
    return frame
end

-- ========================
-- Window
-- ========================
function XDLua.new(config)
    config = config or {}
    local self = setmetatable({}, XDLua)
    self.Title = config.Title or "XDLua"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "XDLuaUI_" .. tostring(math.random(100000,999999))
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999

    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.Gui = gui

    -- Main Frame
    local main = newInstance("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 760, 0, 540),
        Position = UDim2.new(0.5, -380, 0.5, -270),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    corner(main, 10)
    stroke(main, COLORS.Border, 1)
    self.Main = main
    makeDraggable(main)

    -- Shadow
    local shadow = newInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0,
    }, main)

    -- Sidebar
    local sidebar = newInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = COLORS.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, main)
    corner(sidebar, 0)
    self.Sidebar = sidebar

    -- Sidebar right border
    newInstance("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)

    -- Avatar Circle
    local avatarFrame = newInstance("Frame", {
        Size = UDim2.new(0, 75, 0, 75),
        Position = UDim2.new(0.5, -37, 0, 22),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)
    corner(avatarFrame, 40)
    stroke(avatarFrame, COLORS.Border, 1.5)

    -- Avatar Icon
    local avatarIcon = newInstance("ImageLabel", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0.5, -21, 0.5, -21),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4003186875",
        ImageColor3 = COLORS.TextDim,
        ZIndex = 4,
    }, avatarFrame)

    -- Try load avatar
    pcall(function()
        local userId = LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        avatarIcon.Image = content
        avatarIcon.ImageColor3 = Color3.new(1,1,1)
        avatarIcon.Size = UDim2.new(1, 0, 1, 0)
        avatarIcon.Position = UDim2.new(0, 0, 0, 0)
        corner(avatarIcon, 40)
    end)

    -- Username
    local username = newInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 104),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    }, sidebar)

    -- Tab list container
    local tabList = newInstance("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -160),
        Position = UDim2.new(0, 0, 0, 138),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3,
        ClipsDescendants = true,
    }, sidebar)

    local tabListLayout = newInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }, tabList)

    newInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
    }, tabList)

    tabListLayout.Changed:Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
    end)
    self.TabList = tabList
    self.TabListLayout = tabListLayout

    -- Settings tab at bottom of sidebar
    local settingsBtn = newInstance("TextButton", {
        Name = "Settings",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 1, -46),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
    }, sidebar)
    corner(settingsBtn, 6)

    local settingsIcon = newInstance("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 12, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(4, 4),
        ImageRectSize = Vector2.new(24, 24),
        ImageColor3 = COLORS.TextDim,
        ZIndex = 4,
    }, settingsBtn)

    local settingsLabel = newInstance("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = COLORS.TextDim,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, settingsBtn)

    settingsBtn.MouseEnter:Connect(function()
        tween(settingsBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = COLORS.Element}, 0.15)
        tween(settingsLabel, {TextColor3 = COLORS.Text}, 0.15)
    end)
    settingsBtn.MouseLeave:Connect(function()
        tween(settingsBtn, {BackgroundTransparency = 1}, 0.15)
        tween(settingsLabel, {TextColor3 = COLORS.TextDim}, 0.15)
    end)

    -- Content Area
    local contentArea = newInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
        ZIndex = 2,
        ClipsDescendants = true,
    }, main)
    self.ContentArea = contentArea

    -- Top bar
    local topBar = newInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, contentArea)

    -- Title
    local titleLabel = newInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = COLORS.Text,
        TextSize = 18,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, topBar)

    -- Top bar divider
    newInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 1, -1),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, topBar)

    -- Minimize button
    local minBtn = newInstance("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundColor3 = COLORS.Element,
        Text = "—",
        TextColor3 = COLORS.TextDim,
        TextSize = 14,
        Font = FONT,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
    }, topBar)
    corner(minBtn, 6)

    -- Close button
    local closeBtn = newInstance("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -34, 0.5, -15),
        BackgroundColor3 = COLORS.Element,
        Text = "✕",
        TextColor3 = COLORS.TextDim,
        TextSize = 13,
        Font = FONT,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
    }, topBar)
    corner(closeBtn, 6)

    for _, btn in pairs({minBtn, closeBtn}) do
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = COLORS.ElementHover, TextColor3 = COLORS.Text}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = COLORS.Element, TextColor3 = COLORS.TextDim}, 0.15)
        end)
    end

    minBtn.MouseButton1Click:Connect(function()
        self.Visible = not self.Visible
        tween(contentArea, {Size = self.Visible and UDim2.new(1, -200, 1, 0) or UDim2.new(1, -200, 0, 50)}, 0.25)
        tween(sidebar, {Size = self.Visible and UDim2.new(0, 200, 1, 0) or UDim2.new(0, 200, 0, 50)}, 0.25)
        tween(main, {Size = self.Visible and UDim2.new(0, 760, 0, 540) or UDim2.new(0, 760, 0, 50)}, 0.25)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 760, 0, 0)}, 0.25)
        task.delay(0.3, function() gui:Destroy() end)
    end)

    -- Tab + Search header row
    local tabHeader = newInstance("Frame", {
        Name = "TabHeader",
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, contentArea)

    self.TabNameLabel = newInstance("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = COLORS.Text,
        TextSize = 15,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, tabHeader)

    -- Search Box
    local searchBox_Frame = newInstance("Frame", {
        Size = UDim2.new(0.52, 0, 0, 28),
        Position = UDim2.new(0.45, 0, 0.5, -14),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, tabHeader)
    corner(searchBox_Frame, 6)
    stroke(searchBox_Frame, COLORS.Border, 1)

    local searchIcon = newInstance("TextLabel", {
        Size = UDim2.new(0, 22, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextSize = 11,
        Font = FONT_REG,
        ZIndex = 5,
    }, searchBox_Frame)

    self.SearchBox = newInstance("TextBox", {
        Size = UDim2.new(1, -26, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Search",
        PlaceholderColor3 = COLORS.TextDark,
        Text = "",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT_REG,
        ClearTextOnFocus = false,
        ZIndex = 5,
    }, searchBox_Frame)

    -- Divider under header
    newInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 1, -1),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, tabHeader)

    -- Elements scroll
    local elemScroll = newInstance("ScrollingFrame", {
        Name = "ElementScroll",
        Size = UDim2.new(1, 0, 1, -96),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3,
        ClipsDescendants = true,
    }, contentArea)
    self.ElementScroll = elemScroll

    local elemLayout = newInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    }, elemScroll)

    newInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    }, elemScroll)

    elemLayout.Changed:Connect(function()
        elemScroll.CanvasSize = UDim2.new(0, 0, 0, elemLayout.AbsoluteContentSize.Y + 20)
    end)
    self.ElemLayout = elemLayout
    self.ElemScroll = elemScroll

    -- Search filter
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = self.SearchBox.Text:lower()
        if self.ActiveTab then
            for _, elem in pairs(self.ActiveTab.Elements) do
                if elem.Frame then
                    if query == "" then
                        elem.Frame.Visible = true
                    else
                        local label = elem.Label or ""
                        elem.Frame.Visible = label:lower():find(query) ~= nil
                    end
                end
            end
        end
    end)

    return self
end

-- ========================
-- Add Tab
-- ========================
function XDLua:AddTab(name)
    local tab = {
        Name = name,
        Elements = {},
        Button = nil,
    }

    local tabBtn = newInstance("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
        LayoutOrder = #self.Tabs + 1,
    }, self.TabList)
    corner(tabBtn, 6)

    -- Grid icon
    local iconHolder = newInstance("Frame", {
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 5,
    }, tabBtn)
    makeGridIcon(iconHolder, 13)

    local icon = iconHolder:FindFirstChildOfClass("Frame")
    if icon then
        icon.Position = UDim2.new(0.5, -6, 0.5, -6)
    end

    local tabLabel = newInstance("TextLabel", {
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = COLORS.TextDim,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, tabBtn)

    tab.Button = tabBtn
    tab.Label = tabLabel

    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            tween(tabBtn, {BackgroundTransparency = 0.85, BackgroundColor3 = COLORS.Element}, 0.15)
            tween(tabLabel, {TextColor3 = COLORS.Text}, 0.15)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
            tween(tabLabel, {TextColor3 = COLORS.TextDim}, 0.15)
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function XDLua:SelectTab(tab)
    if self.ActiveTab then
        tween(self.ActiveTab.Button, {BackgroundTransparency = 1, BackgroundColor3 = COLORS.Sidebar}, 0.15)
        tween(self.ActiveTab.Label, {TextColor3 = COLORS.TextDim}, 0.15)
        for _, elem in pairs(self.ActiveTab.Elements) do
            if elem.Frame then elem.Frame.Parent = nil end
        end
    end

    self.ActiveTab = tab
    self.TabNameLabel.Text = tab.Name
    self.SearchBox.Text = ""

    tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = COLORS.Accent}, 0.15)
    tween(tab.Label, {TextColor3 = COLORS.White}, 0.15)

    for _, elem in pairs(tab.Elements) do
        if elem.Frame then
            elem.Frame.Parent = self.ElemScroll
        end
    end
end

-- ========================
-- Toggle
-- ========================
function XDLua:AddToggle(tab, config)
    config = config or {}
    local label = config.Label or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local state = default
    local elem = {Label = label, Frame = nil}

    local frame = newInstance("Frame", {
        Name = "Toggle_" .. label,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    corner(frame, 6)
    stroke(frame, COLORS.Border, 1)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, frame)

    -- Toggle track
    local track = newInstance("Frame", {
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, frame)
    corner(track, 12)

    -- Toggle knob
    local knob = newInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = COLORS.White,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, track)
    corner(knob, 10)

    local btn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 7,
    }, frame)

    local function updateToggle()
        tween(track, {BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff}, 0.2)
        tween(knob, {Position = state and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2)
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        pcall(callback, state)
    end)

    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.Element}, 0.15)
    end)

    elem.Frame = frame
    elem.GetState = function() return state end
    elem.SetState = function(val)
        state = val
        updateToggle()
    end

    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- DropDown
-- ========================
function XDLua:AddDropdown(tab, config)
    config = config or {}
    local label = config.Label or "Dropdown"
    local items = config.Items or {}
    local default = config.Default
    local callback = config.Callback or function() end

    local elem = {Label = label, Frame = nil}
    local selected = default
    local isOpen = false

    local frame = newInstance("Frame", {
        Name = "DD_" .. label,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
        ClipsDescendants = false,
    })
    corner(frame, 6)
    stroke(frame, COLORS.Border, 1)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, frame)

    -- Value display
    local valBox = newInstance("Frame", {
        Size = UDim2.new(0.45, 0, 0, 28),
        Position = UDim2.new(0.52, 0, 0.5, -14),
        BackgroundColor3 = COLORS.Dropdown,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, frame)
    corner(valBox, 6)
    stroke(valBox, COLORS.Border, 1)

    local valLabel = newInstance("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = selected and tostring(selected) or "",
        TextColor3 = COLORS.TextDim,
        TextSize = 12,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, valBox)

    local arrow = newInstance("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "⌄",
        TextColor3 = COLORS.TextDim,
        TextSize = 16,
        Font = FONT,
        ZIndex = 6,
    }, valBox)

    -- Dropdown popup
    local dropFrame = newInstance("Frame", {
        Name = "DropFrame",
        Size = UDim2.new(0.45, 0, 0, 0),
        Position = UDim2.new(0.52, 0, 1, 4),
        BackgroundColor3 = COLORS.Dropdown,
        BorderSizePixel = 0,
        ZIndex = 20,
        ClipsDescendants = true,
        Visible = false,
    }, frame)
    corner(dropFrame, 6)
    stroke(dropFrame, COLORS.Border, 1)

    -- Drop search
    local dropSearchFrame = newInstance("Frame", {
        Size = UDim2.new(1, -8, 0, 26),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, dropFrame)
    corner(dropSearchFrame, 5)

    newInstance("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextSize = 10,
        Font = FONT_REG,
        ZIndex = 22,
    }, dropSearchFrame)

    local dropSearch = newInstance("TextBox", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Search",
        PlaceholderColor3 = COLORS.TextDark,
        Text = "",
        TextColor3 = COLORS.Text,
        TextSize = 12,
        Font = FONT_REG,
        ClearTextOnFocus = false,
        ZIndex = 22,
    }, dropSearchFrame)

    -- Drop list
    local dropList = newInstance("ScrollingFrame", {
        Size = UDim2.new(1, -4, 1, -38),
        Position = UDim2.new(0, 2, 0, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 21,
    }, dropFrame)

    local dropLayout = newInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    }, dropList)

    local itemFrames = {}

    local function buildItems(filter)
        filter = filter and filter:lower() or ""
        for _, f in pairs(itemFrames) do f:Destroy() end
        itemFrames = {}

        for i, item in pairs(items) do
            local itemStr = tostring(item)
            if filter == "" or itemStr:lower():find(filter) then
                local itemFrame = newInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 22,
                    LayoutOrder = i,
                }, dropList)

                local highlight = newInstance("Frame", {
                    Size = UDim2.new(1, -4, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundColor3 = item == selected and COLORS.AccentDark or COLORS.DropItem,
                    BackgroundTransparency = item == selected and 0 or 1,
                    BorderSizePixel = 0,
                    ZIndex = 22,
                }, itemFrame)
                corner(highlight, 4)

                local itemLbl = newInstance("TextLabel", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = itemStr,
                    TextColor3 = item == selected and COLORS.White or COLORS.Text,
                    TextSize = 12,
                    Font = FONT_REG,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 23,
                }, itemFrame)

                local itemBtn = newInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 24,
                }, itemFrame)

                itemBtn.MouseEnter:Connect(function()
                    if item ~= selected then
                        tween(highlight, {BackgroundTransparency = 0, BackgroundColor3 = COLORS.DropItemHover}, 0.1)
                    end
                end)
                itemBtn.MouseLeave:Connect(function()
                    if item ~= selected then
                        tween(highlight, {BackgroundTransparency = 1}, 0.1)
                    end
                end)

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    valLabel.Text = itemStr
                    buildItems(dropSearch.Text)
                    pcall(callback, selected)
                end)

                table.insert(itemFrames, itemFrame)
            end
        end

        dropLayout.Changed:Wait()
        dropList.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 4)
    end

    dropSearch:GetPropertyChangedSignal("Text"):Connect(function()
        buildItems(dropSearch.Text)
    end)

    buildItems()

    local function openDropdown()
        isOpen = true
        local listH = math.min(#items * 27 + 38, 180)
        dropFrame.Visible = true
        dropFrame.ZIndex = 20
        tween(dropFrame, {Size = UDim2.new(0.45, 0, 0, listH)}, 0.2)
        tween(arrow, {Rotation = 180}, 0.2)
    end

    local function closeDropdown()
        isOpen = false
        tween(dropFrame, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.15)
        tween(arrow, {Rotation = 0}, 0.15)
        task.delay(0.15, function() if not isOpen then dropFrame.Visible = false end end)
    end

    local toggleBtn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 7,
    }, valBox)

    toggleBtn.MouseButton1Click:Connect(function()
        if isOpen then closeDropdown() else openDropdown() end
    end)

    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.Element}, 0.15)
    end)

    elem.Frame = frame
    elem.GetSelected = function() return selected end
    elem.SetItems = function(newItems)
        items = newItems
        buildItems()
    end

    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- TextInput
-- ========================
function XDLua:AddTextInput(tab, config)
    config = config or {}
    local label = config.Label or "TextInput"
    local placeholder = config.Placeholder or "Input..."
    local default = config.Default or ""
    local callback = config.Callback or function() end

    local elem = {Label = label, Frame = nil}

    local frame = newInstance("Frame", {
        Name = "Input_" .. label,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    corner(frame, 6)
    stroke(frame, COLORS.Border, 1)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, frame)

    local inputBox_frame = newInstance("Frame", {
        Size = UDim2.new(0.45, 0, 0, 28),
        Position = UDim2.new(0.52, 0, 0.5, -14),
        BackgroundColor3 = COLORS.Dropdown,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, frame)
    corner(inputBox_frame, 6)
    stroke(inputBox_frame, COLORS.Border, 1)

    local input = newInstance("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = placeholder,
        PlaceholderColor3 = COLORS.TextDark,
        Text = default,
        TextColor3 = COLORS.Text,
        TextSize = 12,
        Font = FONT_REG,
        ClearTextOnFocus = false,
        ZIndex = 6,
    }, inputBox_frame)

    input.FocusLost:Connect(function(enter)
        if enter then
            pcall(callback, input.Text)
        end
    end)

    input.Focused:Connect(function()
        tween(inputBox_frame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
        tween(inputBox_frame.UIStroke, {Color = COLORS.Accent}, 0.15)
    end)
    input.FocusLost:Connect(function()
        tween(inputBox_frame, {BackgroundColor3 = COLORS.Dropdown}, 0.15)
        tween(inputBox_frame.UIStroke, {Color = COLORS.Border}, 0.15)
    end)

    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.Element}, 0.15)
    end)

    elem.Frame = frame
    elem.GetText = function() return input.Text end
    elem.SetText = function(val) input.Text = val end

    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- Slider
-- ========================
function XDLua:AddSlider(tab, config)
    config = config or {}
    local label = config.Label or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end

    local elem = {Label = label, Frame = nil}
    local value = math.clamp(default, min, max)
    local dragging = false

    local frame = newInstance("Frame", {
        Name = "Slider_" .. label,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    corner(frame, 6)
    stroke(frame, COLORS.Border, 1)

    -- Label
    if label ~= "" then
        newInstance("TextLabel", {
            Size = UDim2.new(0.45, 0, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = COLORS.Text,
            TextSize = 13,
            Font = FONT_REG,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        }, frame)
    end

    -- Track
    local trackBg = newInstance("Frame", {
        Size = UDim2.new(1, -100, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = COLORS.Slider,
        BorderSizePixel = 0,
        ZIndex = 5,
        ClipsDescendants = true,
    }, frame)
    corner(trackBg, 4)

    local trackFill = newInstance("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = COLORS.SliderFill,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, trackBg)
    corner(trackFill, 4)

    -- Knob
    local knob = newInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = COLORS.White,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, trackBg)
    corner(knob, 10)
    stroke(knob, COLORS.Accent, 1.5)

    -- Value box
    local valBox = newInstance("Frame", {
        Size = UDim2.new(0, 46, 0, 28),
        Position = UDim2.new(1, -58, 0.5, -14),
        BackgroundColor3 = COLORS.Dropdown,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, frame)
    corner(valBox, 6)
    stroke(valBox, COLORS.Border, 1)

    local valLabel = newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(value)),
        TextColor3 = COLORS.Text,
        TextSize = 12,
        Font = FONT,
        ZIndex = 6,
    }, valBox)

    local function updateSlider(pct)
        pct = math.clamp(pct, 0, 1)
        value = math.floor(min + (max - min) * pct)
        tween(trackFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
        tween(knob, {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.05)
        valLabel.Text = tostring(value)
        pcall(callback, value)
    end

    local inputBtn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 8,
    }, trackBg)

    inputBtn.MouseButton1Down:Connect(function(x, y)
        dragging = true
        local abs = trackBg.AbsolutePosition
        local sz = trackBg.AbsoluteSize
        local pct = math.clamp((x - abs.X) / sz.X, 0, 1)
        updateSlider(pct)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local abs = trackBg.AbsolutePosition
            local sz = trackBg.AbsoluteSize
            local pos = input.UserInputType == Enum.UserInputType.Touch and input.Position or input.Position
            local pct = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
            updateSlider(pct)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = COLORS.Element}, 0.15)
    end)

    elem.Frame = frame
    elem.GetValue = function() return value end
    elem.SetValue = function(val)
        local pct = (math.clamp(val, min, max) - min) / (max - min)
        updateSlider(pct)
    end

    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- Button
-- ========================
function XDLua:AddButton(tab, config)
    config = config or {}
    local label = config.Label or "BUTTON"
    local callback = config.Callback or function() end

    local elem = {Label = label, Frame = nil}

    local frame = newInstance("Frame", {
        Name = "Btn_" .. label,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
    })

    local btn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = COLORS.ButtonBg,
        Text = label,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 5,
    }, frame)
    corner(btn, 6)
    stroke(btn, COLORS.Border, 1)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = COLORS.ButtonHover}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = COLORS.ButtonBg}, 0.15)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = COLORS.AccentDark}, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = COLORS.ButtonHover}, 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    elem.Frame = frame
    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- Label (separator / text)
-- ========================
function XDLua:AddLabel(tab, config)
    config = config or {}
    local text = config.Text or ""
    local elem = {Label = text, Frame = nil}

    local frame = newInstance("Frame", {
        Name = "Lbl_" .. text,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 4,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = COLORS.TextDim,
        TextSize = 12,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, frame)

    elem.Frame = frame
    table.insert(tab.Elements, elem)
    if self.ActiveTab == tab then
        frame.Parent = self.ElemScroll
    end
    return elem
end

-- ========================
-- Notification
-- ========================
function XDLua:Notify(config)
    config = config or {}
    local title = config.Title or "Notice"
    local message = config.Message or ""
    local duration = config.Duration or 3

    local notifGui = self.Gui

    local notifFrame = newInstance("Frame", {
        Size = UDim2.new(0, 260, 0, 0),
        Position = UDim2.new(1, -270, 1, -10),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = COLORS.Element,
        BorderSizePixel = 0,
        ZIndex = 50,
        ClipsDescendants = true,
    }, notifGui)
    corner(notifFrame, 8)
    stroke(notifFrame, COLORS.Accent, 1.5)

    local accentBar = newInstance("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, notifFrame)

    newInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
    }, notifFrame)

    newInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = COLORS.TextDim,
        TextSize = 11,
        Font = FONT_REG,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 52,
    }, notifFrame)

    tween(notifFrame, {Size = UDim2.new(0, 260, 0, 80)}, 0.25)

    task.delay(duration, function()
        tween(notifFrame, {Position = UDim2.new(1, 10, 1, -10), Size = UDim2.new(0, 260, 0, 0)}, 0.25)
        task.delay(0.3, function() notifFrame:Destroy() end)
    end)
end

return XDLua
