-- Built by Olivia — https://discord.gg/ojailbreaks
-- Snow Hub: cliente único para ambiente preparado. Sem dependências remotas.
local modules = {}

-- BEGIN Config
modules.Config = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return {
    Name = "SNOW HUB", Edition = "PREMIUM WHITE EDITION", Version = "1.0.0",
    Protocol = 1, ItemTag = "SnowHubItem", NPCTag = "SnowHubNPC",
    WorldName = "SnowHubTestWorld", Categories = {"Todos", "Cristais", "Relíquias", "Moedas"},
    MarkerLimit = 48, VisualInterval = 0.15, RequestTimeout = 8,
    ToggleKey = Enum.KeyCode.RightShift,
}

end)()
-- END Config

-- BEGIN Maid
modules.Maid = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
local Maid = {}
Maid.__index = Maid
function Maid.new()
    return setmetatable({tasks = {}, dead = false}, Maid)
end
local function dispose(value)
    local kind = typeof(value)
    if kind == "RBXScriptConnection" then value:Disconnect()
    elseif kind == "Instance" then value:Destroy()
    elseif kind == "function" then value()
    elseif kind == "thread" then
        if coroutine.status(value) ~= "dead" and value ~= coroutine.running() then task.cancel(value) end
    elseif kind == "table" and value.Destroy then value:Destroy() end
end
function Maid:Give(value)
    if self.dead then pcall(dispose, value) else table.insert(self.tasks, value) end
    return value
end
function Maid:Connect(signal, callback)
    return self:Give(signal:Connect(callback))
end
function Maid:Destroy()
    if self.dead then return end
    self.dead = true
    local tasks = self.tasks
    self.tasks = {}
    for i = #tasks, 1, -1 do
        local ok, err = pcall(dispose, tasks[i])
        if not ok then warn("[Snow Hub] limpeza: " .. tostring(err)) end
    end
end
return Maid

end)()
-- END Maid

-- BEGIN UI
modules.UI = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local TweenService = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local player = game:GetService("Players").LocalPlayer
    local ui = {maid = ctx.Maid.new(), pages = {}, tabs = {}, tweens = {}, notices = {},
        reducedMotion = false, alive = true, busyConfirm = false}
    local ink = Color3.fromRGB(37, 49, 66)
    local muted = Color3.fromRGB(105, 120, 141)
    local accent = Color3.fromRGB(108, 157, 196)
    local pale = Color3.fromRGB(229, 237, 246)
    function ui:Create(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        o.Parent = parent
        return o
    end
    local function create(...) return ui:Create(...) end
    local function corner(o, radius) create("UICorner", {CornerRadius = UDim.new(0, radius or 12)}, o) end
    local function stroke(o, color)
        create("UIStroke", {Color = color or Color3.fromRGB(212, 222, 233), Thickness = 1, Transparency = 0.12}, o)
    end
    local function text(parent, value, size, props)
        local p = {BackgroundTransparency = 1, Text = value, Font = Enum.Font.Gotham,
            TextSize = size or 14, TextColor3 = ink, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, Size = UDim2.new(1, 0, 0, 28)}
        for k, v in pairs(props or {}) do p[k] = v end
        return create("TextLabel", p, parent)
    end
    function ui:Tween(object, props, duration)
        if not self.alive or not object.Parent then return end
        if self.reducedMotion then for k, v in pairs(props) do object[k] = v end; return end
        local tween = TweenService:Create(object, TweenInfo.new(duration or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
        self.tweens[tween] = true
        tween.Completed:Once(function() self.tweens[tween] = nil; tween:Destroy() end)
        tween:Play()
    end
    ui.gui = create("ScreenGui", {Name = "SnowHubUI", ResetOnSpawn = false, DisplayOrder = 180,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, player:WaitForChild("PlayerGui"))
    ui.maid:Give(ui.gui)
    ui.blur = create("BlurEffect", {Name = "SnowHubOwnedBlur", Size = 0, Enabled = true}, Lighting)
    ui.maid:Give(ui.blur)
    ui.main = create("CanvasGroup", {Size = UDim2.fromOffset(880, 574), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(246, 249, 253),
        BackgroundTransparency = 0.08, GroupTransparency = 1, Visible = false, BorderSizePixel = 0}, ui.gui)
    corner(ui.main, 18); stroke(ui.main)
    create("UIGradient", {Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(226, 235, 246)), Rotation = 115}, ui.main)
    local scale = create("UIScale", {Scale = 1}, ui.main)
    local function resize()
        local camera = workspace.CurrentCamera
        if camera then scale.Scale = math.clamp(math.min((camera.ViewportSize.X - 32) / 880,
            (camera.ViewportSize.Y - 32) / 574), 0.35, 1) end
    end
    local cameraConnection
    local function watchCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
        resize()
    end
    ui.maid:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), watchCamera)
    ui.maid:Give(function() if cameraConnection then cameraConnection:Disconnect() end end)
    watchCamera()
    local side = create("Frame", {Size = UDim2.new(0, 188, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.32, BorderSizePixel = 0}, ui.main)
    text(side, "❄", 34, {Position = UDim2.fromOffset(19, 16), Size = UDim2.fromOffset(40, 40), TextColor3 = accent})
    text(side, "SNOW HUB", 19, {Position = UDim2.fromOffset(18, 65), Font = Enum.Font.GothamBold})
    text(side, "PREMIUM WHITE EDITION", 9, {Position = UDim2.fromOffset(19, 94), TextColor3 = muted})
    local nav = create("Frame", {Position = UDim2.fromOffset(14, 141), Size = UDim2.new(1, -28, 0, 300), BackgroundTransparency = 1}, side)
    create("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, nav)
    text(side, "Built by Olivia\ndiscord.gg/ojailbreaks", 10, {Position = UDim2.new(0, 18, 1, -64), Size = UDim2.new(1, -30, 0, 40), TextColor3 = muted})
    local titleBar = create("Frame", {Position = UDim2.fromOffset(202, 12), Size = UDim2.new(1, -218, 0, 50), BackgroundTransparency = 1, Active = true}, ui.main)
    ui.heading = text(titleBar, "Dashboard", 23, {Size = UDim2.new(1, -105, 1, 0), Font = Enum.Font.GothamBold})
    local minimize = create("TextButton", {Position = UDim2.new(1, -76, 0, 6), Size = UDim2.fromOffset(32, 32), Text = "−",
        BackgroundColor3 = pale, TextColor3 = ink, BorderSizePixel = 0, TextSize = 22}, titleBar)
    corner(minimize, 8)
    local close = create("TextButton", {Position = UDim2.new(1, -36, 0, 6), Size = UDim2.fromOffset(32, 32), Text = "×",
        BackgroundColor3 = pale, TextColor3 = ink, BorderSizePixel = 0, TextSize = 22}, titleBar)
    corner(close, 8)
    ui.maid:Connect(minimize.Activated, function() ui:SetVisible(false) end)
    ui.maid:Connect(close.Activated, function()
        ui:Confirm("Fechar Snow Hub?", "Todas as funções e conexões do cliente serão encerradas.", function() ctx:Destroy() end)
    end)
    ui.body = create("Frame", {Position = UDim2.fromOffset(205, 70), Size = UDim2.new(1, -223, 1, -108), BackgroundTransparency = 1}, ui.main)
    ui.footer = text(ui.main, "Conectando ao ambiente de testes...", 11, {Position = UDim2.new(0, 205, 1, -30),
        Size = UDim2.new(1, -226, 0, 20), TextColor3 = muted})
    local dragging, initialMouse, initialPosition
    ui.maid:Connect(titleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, initialMouse, initialPosition = true, input.Position, ui.main.Position
        end
    end)
    ui.maid:Connect(UIS.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - initialMouse
            local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
            if viewport then
                local x = initialPosition.X.Scale * viewport.X + initialPosition.X.Offset + delta.X
                local y = initialPosition.Y.Scale * viewport.Y + initialPosition.Y.Offset + delta.Y
                local halfW, halfH = 440 * scale.Scale, 287 * scale.Scale
                ui.main.Position = UDim2.fromOffset(math.clamp(x, halfW, math.max(halfW, viewport.X - halfW)),
                    math.clamp(y, halfH, math.max(halfH, viewport.Y - halfH)))
            end
        end
    end)
    ui.maid:Connect(UIS.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    ui.maid:Connect(UIS.InputBegan, function(input, processed)
        if not processed and input.KeyCode == ctx.config.ToggleKey then ui:SetVisible(not ui.main.Visible) end
    end)
    ui.restore = create("TextButton", {Text = "❄ SNOW HUB", Size = UDim2.fromOffset(140, 38), Position = UDim2.new(0, 18, 0.5, -19),
        BackgroundColor3 = Color3.fromRGB(242, 248, 255), TextColor3 = ink, Font = Enum.Font.GothamBold, TextSize = 13, Visible = false}, ui.gui)
    corner(ui.restore, 12); stroke(ui.restore)
    ui.maid:Connect(ui.restore.Activated, function() ui:SetVisible(true) end)
    function ui:SetVisible(value)
        self.main.Visible, self.restore.Visible = value, not value
        self.blur.Size = value and self.useBlur and 10 or 0
    end
    function ui:SetBlur(value)
        self.useBlur = value
        self:Tween(self.blur, {Size = self.main.Visible and value and 10 or 0})
    end
    function ui:Page(name, icon)
        local index = #nav:GetChildren()
        local tab = create("TextButton", {Size = UDim2.new(1, 0, 0, 41), Text = icon .. "   " .. name,
            LayoutOrder = index, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = muted,
            BackgroundColor3 = Color3.fromRGB(220, 233, 246), BackgroundTransparency = 1, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left}, nav)
        corner(tab, 9)
        create("UIPadding", {PaddingLeft = UDim.new(0, 12)}, tab)
        local page = create("ScrollingFrame", {Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false}, self.body)
        create("UIPadding", {PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
        create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
        self.pages[name], self.tabs[name] = page, tab
        self.maid:Connect(tab.Activated, function() self:Select(name) end)
        return page
    end
    function ui:Select(name)
        self.heading.Text = name
        for key, page in pairs(self.pages) do
            page.Visible = key == name
            self:Tween(self.tabs[key], {BackgroundTransparency = key == name and 0.12 or 1,
                TextColor3 = key == name and ink or muted})
        end
    end
    function ui:Section(page, title, subtitle)
        local card = create("Frame", {Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.24, BorderSizePixel = 0,
            LayoutOrder = #page:GetChildren()}, page)
        corner(card, 12); stroke(card)
        create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)}, card)
        create("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, card)
        text(card, title, 16, {Font = Enum.Font.GothamBold, LayoutOrder = 0})
        if subtitle then text(card, subtitle, 12, {AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 20), TextColor3 = muted, LayoutOrder = 1}) end
        return card
    end
    function ui:Label(parent, value)
        return text(parent, value, 13, {LayoutOrder = #parent:GetChildren(), AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 24), TextColor3 = muted})
    end
    function ui:Button(parent, label, callback)
        local b = create("TextButton", {Size = UDim2.new(1, 0, 0, 37), BackgroundColor3 = pale, BorderSizePixel = 0,
            Text = label, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = ink, LayoutOrder = #parent:GetChildren()}, parent)
        corner(b, 8)
        local working = false
        self.maid:Connect(b.MouseEnter, function() self:Tween(b, {BackgroundColor3 = Color3.fromRGB(210, 226, 242)}) end)
        self.maid:Connect(b.MouseLeave, function() self:Tween(b, {BackgroundColor3 = pale}) end)
        self.maid:Connect(b.Activated, function()
            if working or not self.alive then return end
            working = true
            local success, err = pcall(callback, b)
            working = false
            if not success and self.alive then self:Notify("Ação interrompida", tostring(err):sub(1, 160), true) end
        end)
        return b
    end
    function ui:Toggle(parent, label, initial, callback)
        local value = initial
        local b
        local function paint()
            if b and b.Parent then b.Text = label .. (value and "  •  ATIVO" or "  •  DESLIGADO") end
        end
        b = self:Button(parent, label, function()
            local requested = not value
            local accepted = callback(requested)
            if accepted ~= false then value = requested end
            paint()
        end)
        paint()
        return {Set = function(_, v) value = v; paint() end, Get = function() return value end}
    end
    function ui:Cycle(parent, label, values, index, callback)
        local b = self:Button(parent, label .. ": " .. tostring(values[index]), function(button)
            index = index % #values + 1
            button.Text = label .. ": " .. tostring(values[index])
            callback(values[index], index)
        end)
        return b
    end
    function ui:Slider(parent, label, low, high, initial, callback)
        local row = create("Frame", {Size = UDim2.new(1, 0, 0, 53), BackgroundTransparency = 1,
            LayoutOrder = #parent:GetChildren()}, parent)
        local caption = text(row, label, 13, {Size = UDim2.new(1, 0, 0, 23)})
        local bar = create("TextButton", {Position = UDim2.fromOffset(0, 35), Size = UDim2.new(1, 0, 0, 7),
            Text = "", BackgroundColor3 = pale, BorderSizePixel = 0, AutoButtonColor = false}, row)
        corner(bar, 4)
        local fill = create("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = accent, BorderSizePixel = 0}, bar)
        corner(fill, 4)
        local dot = create("Frame", {Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(1, 0.5), BackgroundColor3 = Color3.new(1, 1, 1)}, fill)
        corner(dot, 7); stroke(dot, accent)
        local held = false
        local function set(value, invoke)
            value = math.floor(math.clamp(value, low, high) * 100 + 0.5) / 100
            fill.Size = UDim2.fromScale((value - low) / (high - low), 1)
            caption.Text = label .. "  " .. tostring(value)
            if invoke then callback(value) end
        end
        local function pointer()
            local x = UIS:GetMouseLocation().X
            set(low + math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1) * (high - low), true)
        end
        self.maid:Connect(bar.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then held = true; pointer() end
        end)
        self.maid:Connect(UIS.InputChanged, function(input)
            if held and input.UserInputType == Enum.UserInputType.MouseMovement then pointer() end
        end)
        self.maid:Connect(UIS.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then held = false end end)
        set(initial, false)
    end
    ui.toastRoot = create("Frame", {Position = UDim2.new(1, -354, 1, -22), Size = UDim2.fromOffset(336, 340),
        AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1}, ui.gui)
    create("UIListLayout", {Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder}, ui.toastRoot)
    function ui:Notify(title, message, bad)
        if not self.alive then return end
        while #self.notices >= 4 do
            local old = table.remove(self.notices, 1)
            old:Destroy()
        end
        local card = create("CanvasGroup", {Size = UDim2.new(1, 0, 0, 80), BackgroundColor3 = Color3.fromRGB(245, 249, 255),
            BorderSizePixel = 0, GroupTransparency = 1}, self.toastRoot)
        corner(card, 11); stroke(card, bad and Color3.fromRGB(209, 158, 161) or nil)
        text(card, (bad and "!  " or "❄  ") .. title, 13, {Position = UDim2.fromOffset(14, 8),
            Size = UDim2.new(1, -28, 0, 22), Font = Enum.Font.GothamBold})
        text(card, message, 12, {Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 0, 41), TextColor3 = muted})
        self.notices[#self.notices + 1] = card
        self:Tween(card, {GroupTransparency = 0})
        task.delay(5, function()
            if not self.alive or not card.Parent then return end
            self:Tween(card, {GroupTransparency = 1})
            task.delay(0.3, function()
                local index = table.find(self.notices, card)
                if index then table.remove(self.notices, index) end
                card:Destroy()
            end)
        end)
    end
    function ui:Confirm(title, message, callback)
        if self.busyConfirm then return end
        self.busyConfirm = true
        local modalMaid = ctx.Maid.new()
        local overlay = create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(48, 61, 81),
            BackgroundTransparency = 0.4, Active = true, ZIndex = 30}, self.gui)
        local box = create("Frame", {Size = UDim2.fromOffset(380, 215), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(247, 250, 255), ZIndex = 31}, overlay)
        corner(box, 14); stroke(box)
        text(box, title, 18, {Position = UDim2.fromOffset(20, 17), Size = UDim2.new(1, -40, 0, 35), ZIndex = 32, Font = Enum.Font.GothamBold})
        text(box, message, 13, {Position = UDim2.fromOffset(20, 58), Size = UDim2.new(1, -40, 0, 74), ZIndex = 32, TextColor3 = muted})
        local function finish()
            self.busyConfirm = false
            modalMaid:Destroy()
            overlay:Destroy()
        end
        for i, label in ipairs({"Cancelar", "Confirmar"}) do
            local b = create("TextButton", {Size = UDim2.fromOffset(162, 36), Position = UDim2.fromOffset(20 + (i - 1) * 178, 155),
                Text = label, BackgroundColor3 = i == 2 and Color3.fromRGB(193, 215, 238) or pale,
                TextColor3 = ink, TextSize = 13, Font = Enum.Font.GothamMedium, BorderSizePixel = 0, ZIndex = 32}, box)
            corner(b, 8)
            local confirm = i == 2
            modalMaid:Connect(b.Activated, function()
                finish()
                if confirm and self.alive then
                    task.spawn(function()
                        local success, err = pcall(callback)
                        if not success then self:Notify("Falha", tostring(err):sub(1, 160), true) end
                    end)
                end
            end)
        end
        self.maid:Give(modalMaid)
    end
    function ui:StartLoading()
        self.loadingMaid = ctx.Maid.new()
        self.splash = create("CanvasGroup", {Size = UDim2.fromOffset(440, 290), Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(244, 249, 255), ClipsDescendants = true}, self.gui)
        corner(self.splash, 18); stroke(self.splash)
        text(self.splash, "SNOW HUB", 30, {Position = UDim2.fromOffset(40, 65), Size = UDim2.new(1, -80, 0, 43),
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
        text(self.splash, "Loading your experience...", 14, {Position = UDim2.fromOffset(40, 120), Size = UDim2.new(1, -80, 0, 30),
            TextColor3 = muted, TextXAlignment = Enum.TextXAlignment.Center})
        local track = create("Frame", {Position = UDim2.fromOffset(45, 190), Size = UDim2.new(1, -90, 0, 7),
            BackgroundColor3 = pale, BorderSizePixel = 0}, self.splash)
        corner(track, 4)
        self.progress = create("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = accent, BorderSizePixel = 0}, track)
        corner(self.progress, 4)
        self.loadingLabel = text(self.splash, "Preparando interface", 11, {Position = UDim2.fromOffset(45, 215),
            Size = UDim2.new(1, -90, 0, 25), TextColor3 = muted, TextXAlignment = Enum.TextXAlignment.Center})
        local flakes = {}
        local random = Random.new()
        for i = 1, 15 do
            local f = text(self.splash, "❄", random:NextInteger(12, 22), {Size = UDim2.fromOffset(28, 28),
                TextColor3 = Color3.fromRGB(185, 207, 229), TextTransparency = 0.35})
            flakes[i] = {label = f, x = random:NextNumber(), y = random:NextNumber(), speed = random:NextNumber(0.06, 0.14)}
        end
        self.loadingMaid:Connect(RunService.RenderStepped, function(dt)
            if self.reducedMotion then return end
            for _, f in ipairs(flakes) do
                f.y = (f.y + dt * f.speed) % 1
                f.label.Position = UDim2.fromScale(f.x, f.y)
                f.label.Rotation = f.label.Rotation + dt * 12
            end
        end)
    end
    function ui:Progress(value, label)
        if self.progress then self:Tween(self.progress, {Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)}, 0.35) end
        if self.loadingLabel then self.loadingLabel.Text = label end
    end
    function ui:FinishLoading()
        self:Progress(1, "Pronto")
        task.wait(0.4)
        if not self.alive then return end
        self.loadingMaid:Destroy()
        self:Tween(self.splash, {GroupTransparency = 1}, 0.3)
        self.main.Visible = true
        self:Tween(self.main, {GroupTransparency = 0}, 0.4)
        task.delay(0.4, function() if self.splash then self.splash:Destroy() end end)
    end
    function ui:Destroy()
        if not self.alive then return end
        self.alive = false
        if self.loadingMaid then self.loadingMaid:Destroy() end
        for tween in pairs(self.tweens) do tween:Cancel(); tween:Destroy() end
        self.tweens = {}
        self.maid:Destroy()
    end
    return ui
end

end)()
-- END UI

-- BEGIN Network
modules.Network = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local Replicated = game:GetService("ReplicatedStorage")
    local Http = game:GetService("HttpService")
    local net = {maid = ctx.Maid.new(), pending = {}, alive = true, count = 0, latency = 0}
    local runtime = Replicated:WaitForChild("SnowHubRuntime", 6)
    if runtime and runtime:GetAttribute("Ready") and runtime:GetAttribute("Protocol") == ctx.config.Protocol then
        net.request = runtime:FindFirstChild("Request")
        net.response = runtime:FindFirstChild("Response")
        net.feedback = runtime:FindFirstChild("Feedback")
    end
    net.available = net.request and net.request:IsA("RemoteEvent") and net.response
        and net.response:IsA("RemoteEvent") and net.feedback and net.feedback:IsA("RemoteEvent") or false
    function net:Finish(id, result)
        local entry = self.pending[id]
        if not entry then return end
        self.pending[id], self.count = nil, self.count - 1
        if entry.timer then pcall(task.cancel, entry.timer) end
        self.latency = math.floor((os.clock() - entry.started) * 1000)
        entry.signal:Fire(result)
        task.defer(function() entry.signal:Destroy() end)
    end
    if net.available then
        net.maid:Connect(net.response.OnClientEvent, function(id, result)
            if type(result) ~= "table" or type(result.ok) ~= "boolean" then return end
            net:Finish(id, result)
        end)
    end
    function net:Request(action, payload)
        if not self.alive or not self.available then
            return {ok = false, message = "Servidor Snow Hub não instalado. Abra o projeto de testes preparado."}
        end
        if self.count >= 4 then return {ok = false, message = "Há ações pendentes. Aguarde."} end
        local id = Http:GenerateGUID(false)
        local entry = {signal = Instance.new("BindableEvent"), started = os.clock()}
        self.pending[id], self.count = entry, self.count + 1
        entry.timer = task.delay(ctx.config.RequestTimeout, function()
            entry.timer = nil
            self:Finish(id, {ok = false, message = "O servidor não respondeu dentro do prazo."})
        end)
        local sent = pcall(function() self.request:FireServer(id, action, payload) end)
        if not sent then
            task.defer(function() self:Finish(id, {ok = false, message = "Conexão com o servidor indisponível."}) end)
        end
        return entry.signal.Event:Wait()
    end
    function net:Destroy()
        if not self.alive then return end
        self.alive = false
        self.maid:Destroy()
        local ids = {}
        for id in pairs(self.pending) do ids[#ids + 1] = id end
        for _, id in ipairs(ids) do self:Finish(id, {ok = false, message = "Snow Hub encerrado."}) end
    end
    return net
end

end)()
-- END Network

-- BEGIN Farming
modules.Farming = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local Players = game:GetService("Players")
    local Collection = game:GetService("CollectionService")
    local Pathfinding = game:GetService("PathfindingService")
    local player = Players.LocalPlayer
    local module = {enabled = false, category = "Todos", maid = nil, generation = 0}
    local ui, page = ctx.ui, ctx.pages.Farming
    local card = ui:Section(page, "📦 Item Farm", "O personagem caminha até os itens da arena. A coleta é confirmada pelo servidor.")
    local counter = ui:Label(card, "Coletados nesta sessão: 0")
    local status = ui:Label(card, "Pronto para iniciar.")
    local toggle
    local function actor()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then return hum, root end
    end
    local function itemPart(item)
        if item:IsA("BasePart") then return item end
        return item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)) or nil
    end
    local function nearest(root)
        local world = workspace:FindFirstChild(ctx.config.WorldName)
        local best, distance = nil, ctx.server.farmRange
        for _, item in ipairs(Collection:GetTagged(ctx.config.ItemTag)) do
            local part = itemPart(item)
            if world and item:IsDescendantOf(world) and part and item:GetAttribute("Available") == true
                and (module.category == "Todos" or item:GetAttribute("Category") == module.category) then
                local d = (part.Position - root.Position).Magnitude
                if d < distance then best, distance = item, d end
            end
        end
        return best
    end
    function module:Stop()
        self.enabled, self.generation = false, self.generation + 1
        if self.activePath then self.activePath:Destroy(); self.activePath = nil end
        if self.maid then self.maid:Destroy(); self.maid = nil end
        local hum, root = actor()
        if hum and root then hum:MoveTo(root.Position) end
        if toggle then toggle:Set(false) end
        status.Text = "Coleta interrompida."
    end
    function module:Start()
        if self.enabled then return true end
        if not ctx:RequirePermission() then return false end
        if not ctx.server.worldReady then ui:Notify("Arena indisponível", "Instale o mundo de testes no servidor.", true); return false end
        if ctx.modules.Combat then ctx.modules.Combat:Stop() end
        self.enabled, self.generation = true, self.generation + 1
        local generation = self.generation
        local function active() return ctx.alive and module.enabled and generation == module.generation end
        self.maid = ctx.Maid.new()
        self.maid:Give(task.spawn(function()
            local success, err = pcall(function()
                while active() do
                    local hum, root = actor()
                    local item = root and nearest(root)
                    local part = item and itemPart(item)
                    if not hum then
                        status.Text = "Aguardando personagem vivo..."
                    elseif not part then
                        status.Text = "Aguardando itens da categoria " .. module.category .. "."
                    elseif (root.Position - part.Position).Magnitude <= ctx.server.collectRange - 1 then
                        status.Text = "Coletando " .. item.Name
                        local result = ctx.net:Request("Collect", {target = item})
                        if not active() then break end
                        if result.ok then ctx:SetStats(result.data)
                        else status.Text = result.message end
                    else
                        status.Text = "Caminhando até " .. item.Name
                        local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 6})
                        module.activePath = path
                        local computed = pcall(function() path:ComputeAsync(root.Position, part.Position) end)
                        local points = computed and path.Status == Enum.PathStatus.Success and path:GetWaypoints() or nil
                        if not active() then path:Destroy(); break end
                        if not points then
                            status.Text = "Sem caminho disponível para " .. item.Name .. ". Recalculando..."
                        else
                            for _, point in ipairs(points) do
                                if not active() or not item.Parent or item:GetAttribute("Available") ~= true then break end
                                local currentHum, currentRoot = actor()
                                if not currentHum or currentHum ~= hum then break end
                                if (currentRoot.Position - part.Position).Magnitude <= ctx.server.collectRange - 1 then break end
                                if point.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                                hum:MoveTo(point.Position)
                                local deadline = os.clock() + 3
                                repeat task.wait(0.1)
                                    currentHum, currentRoot = actor()
                                until not active() or currentHum ~= hum or not currentRoot
                                    or (currentRoot.Position - point.Position).Magnitude < 3 or os.clock() > deadline
                                if os.clock() > deadline then break end
                            end
                        end
                        path:Destroy()
                        module.activePath = nil
                    end
                    task.wait(0.65)
                end
            end)
            if not success and active() then
                module.enabled = false
                toggle:Set(false)
                ui:Notify("Item Farm interrompido", tostring(err):sub(1, 160), true)
            end
        end))
        return true
    end
    ui:Cycle(card, "Categoria", ctx.config.Categories, 1, function(value) module.category = value end)
    toggle = ui:Toggle(card, "Coleta automática", false, function(value)
        if value then return module:Start() end
        module:Stop(); return true
    end)
    local notes = ui:Section(page, "Itens do próprio projeto", "Somente objetos com a tag SnowHubItem dentro de SnowHubTestWorld são aceitos.")
    ui:Label(notes, "O contador registra coletas confirmadas, não movimentos ou tentativas. Os itens da demonstração reaparecem após 12 segundos.")
    function module:UpdateStats(stats) counter.Text = "Coletados nesta sessão: " .. tostring(stats.items or 0) end
    module.Destroy = module.Stop
    return module
end

end)()
-- END Farming

-- BEGIN Visual
modules.Visual = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local Collection = game:GetService("CollectionService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local module = {npc = false, items = false, boxes = false, alpha = 0.6,
        color = Color3.fromRGB(116, 178, 231), markers = {}, maid = nil}
    local ui = ctx.ui
    local card = ui:Section(ctx.pages.Visual, "👁 ESP de Testes", "Nomes e distâncias dos objetos de teste replicados para este cliente.")
    local boxCard = ui:Section(ctx.pages.Visual, "🎯 Hitbox Visualizer", "Caixas visuais usam as dimensões reais das peças. Nenhuma hitbox física é alterada.")
    local toggles = {}
    local function remove(object)
        local entry = module.markers[object]
        if entry then entry.maid:Destroy(); module.markers[object] = nil end
    end
    local function partOf(object)
        return object:IsA("BasePart") and object or object:IsA("Model")
            and (object.PrimaryPart or object:FindFirstChild("HumanoidRootPart") or object:FindFirstChildWhichIsA("BasePart", true))
    end
    local function update()
        local ch = Players.LocalPlayer.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local world = workspace:FindFirstChild(ctx.config.WorldName)
        local wanted = {}
        local function add(tag, isNPC)
            for _, object in ipairs(Collection:GetTagged(tag)) do
                local part = partOf(object)
                local hum = isNPC and object:FindFirstChildOfClass("Humanoid")
                if world and object:IsDescendantOf(world) and part
                    and ((isNPC and hum and hum.Health > 0) or (not isNPC and object:GetAttribute("Available") == true)) then
                    table.insert(wanted, {object = object, part = part, npc = isNPC,
                        distance = root and (root.Position - part.Position).Magnitude or 0})
                end
            end
        end
        if module.npc or module.boxes then add(ctx.config.NPCTag, true) end
        if module.items then add(ctx.config.ItemTag, false) end
        table.sort(wanted, function(a, b) return a.distance < b.distance end)
        local keep = {}
        for i = 1, math.min(#wanted, ctx.config.MarkerLimit) do keep[wanted[i].object] = true end
        local stale = {}
        for object in pairs(module.markers) do if not keep[object] then table.insert(stale, object) end end
        for _, object in ipairs(stale) do remove(object) end
        for i = 1, math.min(#wanted, ctx.config.MarkerLimit) do
            local record = wanted[i]
            local object, part = record.object, record.part
            local entry = module.markers[object]
            if entry and entry.part ~= part then remove(object); entry = nil end
            if not entry then
                local maid = ctx.Maid.new()
                entry = {maid = maid, part = part, boxes = {}}
                entry.highlight = maid:Give(ui:Create("Highlight", {Adornee = object,
                    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = 0.85}, ctx.visualRoot))
                entry.billboard = maid:Give(ui:Create("BillboardGui", {Adornee = part, AlwaysOnTop = true,
                    Size = UDim2.fromOffset(240, 42), StudsOffsetWorldSpace = Vector3.new(0, 4, 0)}, ui.gui))
                entry.label = ui:Create("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 0.2, TextWrapped = true}, entry.billboard)
                module.markers[object] = entry
            end
            local espOn = record.npc and module.npc or not record.npc and module.items
            entry.highlight.Enabled, entry.billboard.Enabled = espOn, espOn
            entry.highlight.FillColor, entry.highlight.OutlineColor = module.color, module.color
            entry.label.Text = object.Name .. "  |  " .. math.floor(record.distance) .. " studs"
            if record.npc then
                local seen = {}
                for _, bodyPart in ipairs(object:GetDescendants()) do
                    if bodyPart:IsA("BasePart") and bodyPart.Name ~= "HumanoidRootPart" then
                        seen[bodyPart] = true
                        local adornment = entry.boxes[bodyPart]
                        if module.boxes and not adornment then
                            adornment = ui:Create("BoxHandleAdornment", {Adornee = bodyPart, AlwaysOnTop = true,
                                ZIndex = 1, Size = bodyPart.Size}, ctx.visualRoot)
                            entry.boxes[bodyPart] = adornment
                            entry.maid:Give(adornment)
                        end
                        if adornment then
                            adornment.Visible, adornment.Transparency = module.boxes, module.alpha
                            adornment.Color3, adornment.Size = module.color, bodyPart.Size
                        end
                    end
                end
                for bodyPart, adornment in pairs(entry.boxes) do
                    if not seen[bodyPart] then adornment:Destroy(); entry.boxes[bodyPart] = nil end
                end
            end
        end
    end
    function module:Reconcile()
        if self.npc or self.items or self.boxes then
            if not self.maid then
                self.maid = ctx.Maid.new()
                local elapsed = 0
                self.maid:Connect(RunService.Heartbeat, function(dt)
                    elapsed = elapsed + dt
                    if elapsed < ctx.config.VisualInterval then return end
                    elapsed = 0
                    local success, err = pcall(update)
                    if not success then
                        self:Stop()
                        ui:Notify("Visual interrompido", tostring(err):sub(1, 150), true)
                    end
                end)
            end
        else
            if self.maid then self.maid:Destroy(); self.maid = nil end
            local old = {}
            for object in pairs(self.markers) do old[#old + 1] = object end
            for _, object in ipairs(old) do remove(object) end
        end
    end
    for _, info in ipairs({{"NPCs", "npc", card}, {"Itens", "items", card}, {"Hitboxes", "boxes", boxCard}}) do
        local key = info[2]
        toggles[key] = ui:Toggle(info[3], info[1], false, function(value)
            if value and not ctx:RequirePermission() then return false end
            module[key] = value
            module:Reconcile()
            return true
        end)
    end
    local palette = {Color3.fromRGB(116, 178, 231), Color3.fromRGB(233, 241, 255), Color3.fromRGB(191, 166, 232), Color3.fromRGB(109, 200, 177)}
    ui:Cycle(boxCard, "Cor dos indicadores", {"Gelo", "Branco-neve", "Lavanda", "Menta"}, 1, function(_, index) module.color = palette[index] end)
    ui:Slider(boxCard, "Transparência", 0, 0.95, module.alpha, function(value) module.alpha = value end)
    function module:Stop()
        self.npc, self.items, self.boxes = false, false, false
        for _, toggle in pairs(toggles) do toggle:Set(false) end
        self:Reconcile()
    end
    module.Destroy = module.Stop
    return module
end

end)()
-- END Visual

-- BEGIN Combat
modules.Combat = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local Players = game:GetService("Players")
    local Collection = game:GetService("CollectionService")
    local RunService = game:GetService("RunService")
    local module = {enabled = false, showRange = false, showDamage = true, range = 12,
        trainingMaid = nil, rangeMaid = nil, floats = {}}
    local ui = ctx.ui
    local card = ui:Section(ctx.pages.Combat, "⚔ Combat Tester", "Ataques de teste atingem somente NPCs autorizados. Alcance, obstáculos e dano são validados pelo servidor.")
    local targetLabel = ui:Label(card, "Alvo: nenhum NPC próximo")
    local status = ui:Label(card, "Posicione-se perto de um NPC da arena.")
    local statsLabel = ui:Label(card, "Acertos: 0   •   Dano: 0   •   NPCs derrotados: 0")
    local rangeToggle, trainToggle, damageToggle
    local function root()
        local ch = Players.LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0 and ch:FindFirstChild("HumanoidRootPart") or nil
    end
    local function nearest(limit)
        local origin = root()
        local world = workspace:FindFirstChild(ctx.config.WorldName)
        if not origin or not world then return end
        local best, distance = nil, limit
        for _, npc in ipairs(Collection:GetTagged(ctx.config.NPCTag)) do
            if npc:IsA("Model") and npc:IsDescendantOf(world) then
                local hum, part = npc:FindFirstChildOfClass("Humanoid"), npc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and part then
                    local d = (part.Position - origin.Position).Magnitude
                    if d <= distance then best, distance = npc, d end
                end
            end
        end
        return best, distance
    end
    function module:Attack(manual)
        if not ctx:RequirePermission() then return false end
        local target, distance = nearest(manual and 250 or self.range)
        if not target then status.Text = "Nenhum NPC válido no alcance selecionado."; return false end
        targetLabel.Text = target.Name .. "  |  " .. string.format("%.1f", distance) .. " studs"
        local result = ctx.net:Request("Attack", {target = target})
        if not ctx.alive then return false end
        if result.ok then
            ctx:SetStats(result.data)
            status.Text = "Golpe confirmado pelo servidor."
        else
            status.Text = result.message
            if manual then ui:Notify("Teste de golpe", result.message, true) end
        end
        return result.ok
    end
    function module:StopTraining()
        self.enabled = false
        if self.trainingMaid then self.trainingMaid:Destroy(); self.trainingMaid = nil end
        if trainToggle then trainToggle:Set(false) end
    end
    function module:StartTraining()
        if self.enabled then return true end
        if not ctx:RequirePermission() then return false end
        if ctx.modules.Farming then ctx.modules.Farming:Stop() end
        self.enabled = true
        self.trainingMaid = ctx.Maid.new()
        self.trainingMaid:Give(task.spawn(function()
            local success, err = pcall(function()
                while ctx.alive and module.enabled do
                    module:Attack(false)
                    task.wait(math.max(ctx.server.attackCooldown, 0.4) + 0.1)
                end
            end)
            if not success and ctx.alive then
                module.enabled = false
                trainToggle:Set(false)
                ui:Notify("Treino interrompido", tostring(err):sub(1, 150), true)
            end
        end))
        return true
    end
    function module:SetRangeVisible(value)
        self.showRange = value
        if self.rangeMaid then self.rangeMaid:Destroy(); self.rangeMaid = nil end
        if not value then return end
        self.rangeMaid = ctx.Maid.new()
        local sphere = self.rangeMaid:Give(ui:Create("SphereHandleAdornment", {Radius = self.range,
            AlwaysOnTop = false, Color3 = Color3.fromRGB(143, 190, 235), Transparency = 0.88, ZIndex = 0}, ctx.visualRoot))
        self.rangeMaid:Connect(RunService.Heartbeat, function()
            sphere.Adornee, sphere.Radius = root(), module.range
        end)
    end
    ui:Slider(card, "Alcance de treino (studs)", 1, 12, module.range, function(value)
        module.range = math.min(value, ctx.server and ctx.server.attackRange or 12)
    end)
    rangeToggle = ui:Toggle(card, "Exibir esfera de alcance", false, function(value)
        if value and not ctx:RequirePermission() then return false end
        module:SetRangeVisible(value); return true
    end)
    damageToggle = ui:Toggle(card, "Indicadores de dano confirmado", true, function(value)
        module.showDamage = value
        if not value then module:ClearFloats() end
        return true
    end)
    ui:Button(card, "Aplicar um golpe de teste", function() module:Attack(true) end)
    trainToggle = ui:Toggle(card, "Treino automático com NPCs", false, function(value)
        if value then return module:StartTraining() end
        module:StopTraining(); return true
    end)
    local statsCard = ui:Section(ctx.pages.Combat, "Estatísticas da sessão", "Os números vêm do servidor e são zerados ao sair da instância.")
    local dpsLabel = ui:Label(statsCard, "DPS da sessão: 0   •   Fora de alcance/obstáculo: 0")
    ui:Button(statsCard, "Zerar estatísticas da sessão", function()
        if not ctx:RequirePermission() then return end
        ui:Confirm("Zerar estatísticas?", "Coletas, dano, acertos e derrotas desta sessão voltarão a zero.", function()
            local result = ctx.net:Request("ResetStats")
            if result.ok then ctx:SetStats(result.data) else ui:Notify("Estatísticas", result.message, true) end
        end)
    end)
    function module:ClearFloats()
        for object in pairs(self.floats) do object:Destroy() end
        self.floats = {}
    end
    function module:OnDamage(data)
        if not self.showDamage or typeof(data.position) ~= "Vector3" then return end
        local count = 0
        for _ in pairs(self.floats) do count = count + 1 end
        if count >= 12 then return end
        local anchor = ui:Create("Part", {Size = Vector3.new(0.1, 0.1, 0.1), Anchored = true,
            CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1,
            Position = data.position + Vector3.new(0, 3, 0)}, ctx.visualRoot)
        self.floats[anchor] = true
        local billboard = ui:Create("BillboardGui", {Adornee = anchor, AlwaysOnTop = true, Size = UDim2.fromOffset(100, 40)}, anchor)
        local label = ui:Create("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = "−" .. tostring(data.damage), TextColor3 = Color3.fromRGB(237, 246, 255),
            TextStrokeTransparency = 0.15, Font = Enum.Font.GothamBold, TextSize = 24}, billboard)
        ui:Tween(anchor, {Position = anchor.Position + Vector3.new(0, 3, 0)}, 0.8)
        ui:Tween(label, {TextTransparency = 1, TextStrokeTransparency = 1}, 0.9)
        task.delay(1, function() self.floats[anchor] = nil; anchor:Destroy() end)
    end
    function module:UpdateStats(stats)
        statsLabel.Text = string.format("Acertos: %d   •   Dano: %d   •   NPCs derrotados: %d", stats.hits or 0, stats.damage or 0, stats.kills or 0)
        dpsLabel.Text = string.format("DPS da sessão: %.1f   •   Fora de alcance/obstáculo: %d", (stats.damage or 0) / math.max(0.01, stats.elapsed or 1), stats.misses or 0)
    end
    function module:Stop()
        self:StopTraining(); self:SetRangeVisible(false)
        self.showDamage = false
        damageToggle:Set(false); rangeToggle:Set(false)
        self:ClearFloats()
        status.Text = "Treino e indicadores interrompidos."
    end
    module.Destroy = module.Stop
    return module
end

end)()
-- END Combat

-- BEGIN Servers
modules.Servers = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
return function(ctx)
    local ui = ctx.ui
    local module = {rows = nil, stopped = false}
    local card = ui:Section(ctx.pages.Servers, "🌐 Instâncias autorizadas", "Somente servidores públicos deste mesmo place que executam o backend Snow Hub aparecem aqui.")
    local current = ui:Label(card, "Servidor atual: verificando...")
    local status = ui:Label(card, "Atualize para buscar instâncias ativas.")
    local results = ui:Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 100}, card)
    ui:Create("UIListLayout", {Padding = UDim.new(0, 8)}, results)
    function module:Clear()
        if self.rows then self.rows:Destroy(); self.rows = nil end
        for _, child in ipairs(results:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
    end
    function module:Refresh()
        if not ctx:RequirePermission() then return end
        if not ctx.server.serverHop then
            status.Text = ctx.server.serverReason or "Navegação indisponível nesta instância."
            ui:Notify("Server Hop", status.Text, true)
            return
        end
        self.stopped = false
        status.Text = "Consultando registro autorizado..."
        local result = ctx.net:Request("Servers")
        if not ctx.alive or self.stopped then return end
        self:Clear()
        if not result.ok then status.Text = result.message; return end
        self.rows = ctx.Maid.new()
        status.Text = #result.data == 0 and "Nenhuma outra instância disponível. Abra um segundo servidor público do projeto."
            or (#result.data .. " instância(s) disponível(is).")
        for _, entry in ipairs(result.data) do
            local id = entry.id
            local row = ui:Create("TextButton", {Size = UDim2.new(1, 0, 0, 39), BackgroundColor3 = Color3.fromRGB(229, 237, 246),
                Text = string.sub(id, 1, 12) .. "…  |  " .. entry.players .. "/" .. entry.capacity .. "  |  Entrar",
                Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.fromRGB(37, 49, 66), BorderSizePixel = 0}, results)
            ui:Create("UICorner", {CornerRadius = UDim.new(0, 8)}, row)
            self.rows:Connect(row.Activated, function()
                ui:Confirm("Trocar de instância?", "Destino: " .. id .. "\nAs funções serão interrompidas antes do teleporte.", function()
                    ctx:StopAll(false)
                    local answer = ctx.net:Request("Hop", {id = id})
                    if ctx.alive then ui:Notify("Server Hop", answer.ok and "Teleporte solicitado. Aguarde o Roblox." or answer.message, not answer.ok) end
                end)
            end)
        end
    end
    ui:Button(card, "Atualizar servidores", function() module:Refresh() end)
    function module:Connected()
        current.Text = "Servidor atual: " .. ((ctx.server.jobId or "") ~= "" and ctx.server.jobId or "Studio — sessão local")
        status.Text = ctx.server.serverHop and "Pronto para consultar instâncias." or (ctx.server.serverReason or "Navegação indisponível.")
    end
    function module:Stop()
        self.stopped = true
        self:Clear()
    end
    module.Destroy = module.Stop
    return module
end

end)()
-- END Servers

-- BEGIN App
modules.App = (function()
-- Built by Olivia — https://discord.gg/ojailbreaks
-- O mesmo ponto de entrada é usado no Studio e no bundle para Xeno.
return function(modules)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    if not game:IsLoaded() then game.Loaded:Wait() end
    local player = Players.LocalPlayer
    if not player then error("Snow Hub deve ser iniciado no cliente.") end
    local playerGui = player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("SnowHubSession")
    if old then
        local shutdown = old:FindFirstChild("Shutdown")
        if shutdown and shutdown:IsA("BindableEvent") then shutdown:Fire(); task.wait() end
        old:Destroy()
    end
    local ctx = {alive = true, authorized = false, config = modules.Config,
        Maid = modules.Maid, modules = {}, pages = {}, stats = {}, server = {}, status = "Inicializando"}
    ctx.maid = ctx.Maid.new()
    local session = Instance.new("Folder")
    session.Name, session.Parent = "SnowHubSession", playerGui
    local shutdown = Instance.new("BindableEvent")
    shutdown.Name, shutdown.Parent = "Shutdown", session
    ctx.maid:Give(session)
    ctx.visualRoot = Instance.new("Folder")
    ctx.visualRoot.Name, ctx.visualRoot.Parent = "SnowHubClientVisuals", workspace
    ctx.maid:Give(ctx.visualRoot)
    function ctx:RequirePermission()
        if self.alive and self.authorized then return true end
        if self.ui then self.ui:Notify("Função indisponível", self.status, true) end
        return false
    end
    function ctx:SetStats(stats)
        if not self.alive or type(stats) ~= "table" then return end
        self.stats = stats
        for _, module in pairs(self.modules) do
            if module.UpdateStats then module:UpdateStats(stats) end
        end
        if self.dashboardStats then
            self.dashboardStats.Text = string.format("%d itens coletados   •   %d golpes   •   %d de dano",
                stats.items or 0, stats.hits or 0, stats.damage or 0)
        end
    end
    function ctx:StopAll(notify)
        for _, module in pairs(self.modules) do
            if module.Stop then pcall(function() module:Stop() end) end
        end
        if self.ui then
            self.ui:SetBlur(false)
            if self.blurToggle then self.blurToggle:Set(false) end
            if notify ~= false then self.ui:Notify("Funções desligadas", "Farming, visuais, treino e efeitos foram interrompidos.") end
        end
    end
    function ctx:Destroy()
        if not self.alive then return end
        self.alive = false
        self:StopAll(false)
        if self.net then self.net:Destroy() end
        self.maid:Destroy()
        if self.ui then self.ui:Destroy() end
    end
    ctx.maid:Connect(shutdown.Event, function() ctx:Destroy() end)
    local success, err = pcall(function()
        ctx.ui = modules.UI(ctx)
        local ui = ctx.ui
        ctx.maid:Connect(ui.gui.Destroying, function() ctx:Destroy() end)
        ui:StartLoading()
        ui:Progress(0.16, "Montando interface branca-neve")
        for _, page in ipairs({{"Dashboard", "❄"}, {"Farming", "📦"}, {"Visual", "👁"},
            {"Combat", "⚔"}, {"Servers", "🌐"}, {"Settings", "⚙"}}) do
            ctx.pages[page[1]] = ui:Page(page[1], page[2])
        end
        local home = ui:Section(ctx.pages.Dashboard, "Bem-vindo ao Snow Hub", "PREMIUM WHITE EDITION • PC • versão " .. ctx.config.Version)
        local connection = ui:Label(home, "Conectando ao servidor de testes...")
        ctx.dashboardStats = ui:Label(home, "0 itens coletados   •   0 golpes   •   0 de dano")
        local diagnostics = ui:Label(home, "FPS: —   •   Resposta do servidor: —")
        ui:Button(home, "Ir para a arena de testes", function()
            if not ctx:RequirePermission() then return end
            local result = ctx.net:Request("Arena")
            if ctx.alive then ui:Notify("Arena", result.ok and result.data.message or result.message, not result.ok) end
        end)
        ui:Button(home, "Desligar todas as funções", function() ctx:StopAll() end)
        local about = ui:Section(ctx.pages.Dashboard, "Ambiente preparado", "Módulos operam nos itens e NPCs criados por este projeto.")
        ui:Label(about, "RightShift mostra ou esconde o painel. Arraste a barra superior com o mouse. O botão ❄ reabre o painel minimizado.")
        for _, name in ipairs({"Farming", "Visual", "Combat", "Servers"}) do ctx.modules[name] = modules[name](ctx) end
        local settings = ui:Section(ctx.pages.Settings, "⚙ Preferências", "Configurações locais desta sessão. O painel permanece disponível para reativar funções.")
        ctx.blurToggle = ui:Toggle(settings, "Desfoque de fundo", false, function(value) ui:SetBlur(value); return true end)
        ui:Toggle(settings, "Reduzir animações", false, function(value) ui.reducedMotion = value; return true end)
        ui:Button(settings, "Desligar todas as funções", function() ctx:StopAll() end)
        ui:Button(settings, "Encerrar Snow Hub", function()
            ui:Confirm("Encerrar Snow Hub?", "A interface e todos os recursos locais serão removidos.", function() ctx:Destroy() end)
        end)
        local permission = ui:Section(ctx.pages.Settings, "Permissões e conexão", "A lista de testadores é controlada pelo ServerConfig dentro de ServerScriptService.")
        local permissionLabel = ui:Label(permission, "Verificando acesso...")
        ui:Progress(0.45, "Localizando backend Snow Hub")
        ctx.net = modules.Network(ctx)
        if not ctx.alive then ctx.net:Destroy(); return end
        local function authenticate()
            if not ctx.alive then return end
            local result = ctx.net:Request("Handshake", {protocol = ctx.config.Protocol})
            if not ctx.alive then return end
            ctx.authorized = result.ok and type(result.data) == "table" and result.data.protocol == ctx.config.Protocol
            if ctx.authorized then
                ctx.server, ctx.status = result.data, "Acesso autorizado ao ambiente de testes."
                ctx:SetStats(result.data.stats)
                ctx.modules.Combat.range = math.min(12, ctx.server.attackRange)
                ctx.modules.Servers:Connected()
            else
                ctx.status = result.message or "Versão incompatível com o servidor."
                ctx:StopAll(false)
            end
            connection.Text, permissionLabel.Text, ui.footer.Text = ctx.status, ctx.status, ctx.status
            ui:Notify(ctx.authorized and "Snow Hub conectado" or "Ambiente indisponível", ctx.status, not ctx.authorized)
        end
        ui:Button(permission, "Verificar permissões novamente", function()
            if not ctx.net.available then
                ctx.net:Destroy()
                ctx.net = modules.Network(ctx)
                ctx:AttachFeedback()
            end
            authenticate()
        end)
        function ctx:AttachFeedback()
            if self.feedbackConnection then self.feedbackConnection:Disconnect(); self.feedbackConnection = nil end
            if self.net.available then
                self.feedbackConnection = self.maid:Connect(self.net.feedback.OnClientEvent, function(event, data)
                    if not self.alive or type(data) ~= "table" then return end
                    if data.stats then self:SetStats(data.stats) end
                    if event == "Damage" then self.modules.Combat:OnDamage(data)
                    elseif event == "Error" then ui:Notify("Servidor", data.message or "Ação não concluída.", true) end
                end)
            end
        end
        ctx:AttachFeedback()
        ui:Progress(0.78, "Validando permissões no servidor")
        authenticate()
        if not ctx.alive then return end
        local frames, elapsed = 0, 0
        ctx.maid:Connect(RunService.RenderStepped, function(dt)
            frames, elapsed = frames + 1, elapsed + dt
            if elapsed >= 1 then
                diagnostics.Text = string.format("FPS: %d   •   Resposta do servidor: %d ms",
                    math.floor(frames / elapsed), ctx.net.latency)
                frames, elapsed = 0, 0
            end
        end)
        ctx.maid:Give(task.spawn(function()
            while ctx.alive do
                task.wait(2)
                if ctx.alive and ctx.authorized then
                    local result = ctx.net:Request("Stats")
                    if not ctx.alive then break end
                    if result.ok then ctx:SetStats(result.data)
                    elseif result.message and string.find(result.message, "Sem permissão", 1, true) then
                        ctx.authorized, ctx.status = false, result.message
                        ctx:StopAll(false)
                        ui:Notify("Acesso removido", result.message, true)
                    end
                end
            end
        end))
        ui:Select("Dashboard")
        ui:FinishLoading()
    end)
    if not success then
        warn("[Snow Hub] inicialização: " .. tostring(err))
        ctx:Destroy()
        error("Snow Hub interrompido: " .. tostring(err), 0)
    end
    return ctx
end

end)()
-- END App

return modules.App(modules)
