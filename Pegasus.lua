-- [[ PEGASUS HUB - MUGIGEN2 EDITION ]]
-- [[ GAME: MALAM SAMA OPAH / NENEK ]]

local MugiHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/ftgless/Mugi/refs/heads/main/UI"))()

local CONFIG = {
    FloatingIcon = "rbxassetid://1314520", -- ganti dengan ID Decal kamu
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================
-- HELPERS
-- ========================
local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function fireRemote(remote)
    if not remote then return false end
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer()
        end
    end)
    return true
end

local function findRemote(name)
    local found
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name:lower():find(name:lower()) then
            found = v
            break
        end
    end
    return found
end

local function tpTo(cf)
    local root = getRoot()
    if root and cf then
        root.CFrame = cf + Vector3.new(0, 3, 0)
    end
end

local function clearESP(folderName)
    local f = Workspace:FindFirstChild(folderName)
    if f then f:Destroy() end
end

local function makeHighlight(target, color, folder)
    if not target then return end
    local h = Instance.new("Highlight")
    h.Adornee = target
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.45
    h.OutlineTransparency = 0
    h.Parent = folder
end

local function makeBillboard(adornee, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 140, 0, 28)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.Adornee = adornee
    bb.Parent = adornee
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Parent = bb
    return bb
end

-- ========================
-- WINDOW
-- ========================
local Window = MugiHub.Library:CreateWindow({
    Title = "PEGASUS HUB",
    Description = "Malam Sama Opah / Nenek",
    SizeUi = UDim2.fromOffset(620, 420),
    Keybind = Enum.KeyCode.RightControl,
    Icon = "hub",
    Theme = "Crimson",
    Style = "Sidebar",
})

-- ========================
-- TAB MAIN
-- ========================
local TabMain = Window:AddTab({
    Name = "Main",
    Icon = "home",
    Color = "Ocean",
    Description = "Fitur utama untuk menyelesaikan game",
})
local SectionMain = TabMain:AddSection("Main Features")

local autoWinConn
SectionMain:AddToggle({
    Name = "Auto Win",
    Default = false,
    Flag = "AutoWin",
    Callback = function(state)
        if autoWinConn then autoWinConn:Disconnect() autoWinConn = nil end
        if state then
            autoWinConn = RunService.Heartbeat:Connect(function()
                -- fire common escape / win remotes
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    or (ReplicatedStorage:FindFirstChild("PuzzleShared") and ReplicatedStorage.PuzzleShared:FindFirstChild("Remotes"))
                    or (ReplicatedStorage:FindFirstChild("GameShared") and ReplicatedStorage.GameShared)
                if remotes then
                    for _, name in ipairs({"Escape", "Win", "SubmitPasscode", "PuzzleRemote", "GameRemote"}) do
                        local r = remotes:FindFirstChild(name)
                        if r then fireRemote(r) end
                    end
                end
                -- also try direct find
                fireRemote(findRemote("Escape"))
                fireRemote(findRemote("Win"))
                fireRemote(findRemote("SubmitPasscode"))

                -- teleport to front door / keypad if present
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("frontdoor") or n:find("exitdoor") or n:find("keypad") or n == "door") and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                        tpTo(pivot)
                        break
                    end
                end
            end)
            print("[PEGASUS] Auto Win: ON")
        else
            print("[PEGASUS] Auto Win: OFF")
        end
    end,
})

local autoSecretConn
SectionMain:AddToggle({
    Name = "Auto Secret Ending",
    Default = false,
    Flag = "AutoSecret",
    Callback = function(state)
        if autoSecretConn then autoSecretConn:Disconnect() autoSecretConn = nil end
        if state then
            autoSecretConn = RunService.Heartbeat:Connect(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("secret") or n:find("hidden") or n:find("ending")) and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("ProximityPrompt")) then
                        if obj:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(obj) end)
                        else
                            local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                            tpTo(pivot)
                        end
                    end
                end
                fireRemote(findRemote("Secret"))
                fireRemote(findRemote("Ending"))
            end)
            print("[PEGASUS] Auto Secret Ending: ON")
        else
            print("[PEGASUS] Auto Secret Ending: OFF")
        end
    end,
})

local autoStartConn
SectionMain:AddToggle({
    Name = "Auto Start (Lobby)",
    Default = false,
    Flag = "AutoStart",
    Callback = function(state)
        if autoStartConn then autoStartConn:Disconnect() autoStartConn = nil end
        if state then
            autoStartConn = RunService.Heartbeat:Connect(function()
                -- join nearest bus / start remote
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("bus") or n:find("start") or n:find("join")) and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("ProximityPrompt")) then
                        if obj:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(obj) end)
                        else
                            local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                            tpTo(pivot)
                        end
                    end
                end
                fireRemote(findRemote("Start"))
                fireRemote(findRemote("Join"))
                fireRemote(findRemote("Bus"))
            end)
            print("[PEGASUS] Auto Start: ON")
        else
            print("[PEGASUS] Auto Start: OFF")
        end
    end,
})

local infStaminaConn
SectionMain:AddToggle({
    Name = "Inf Stamina",
    Default = false,
    Flag = "InfStamina",
    Callback = function(state)
        if infStaminaConn then infStaminaConn:Disconnect() infStaminaConn = nil end
        if state then
            infStaminaConn = RunService.Heartbeat:Connect(function()
                local hum = getHum()
                if hum then
                    hum.WalkSpeed = math.max(hum.WalkSpeed, 22)
                    hum.JumpPower = math.max(hum.JumpPower, 50)
                end
                -- common stamina attributes / values
                local char = getChar()
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            local n = v.Name:lower()
                            if n:find("stamina") or n:find("energy") or n:find("run") then
                                v.Value = 100
                            end
                        end
                    end
                end
                if LocalPlayer:GetAttribute("Stamina") then
                    LocalPlayer:SetAttribute("Stamina", 100)
                end
            end)
            print("[PEGASUS] Inf Stamina: ON")
        else
            print("[PEGASUS] Inf Stamina: OFF")
        end
    end,
})

SectionMain:AddButton({
    Name = "Collect Key",
    Hint = "Kumpulkan semua key",
    Callback = function()
        local collected = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("key") or n:find("kunci")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                tpTo(pivot)
                -- fire nearby prompt
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        pcall(function() fireproximityprompt(p) end)
                    end
                end
                collected = collected + 1
                task.wait(0.15)
            end
        end
        print("[PEGASUS] Collect Key executed | found \~" .. collected)
    end,
})

SectionMain:AddButton({
    Name = "Collect Passcode",
    Hint = "Kumpulkan passcode",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("passcode") or n:find("code") or n:find("note") or n:find("kode")) and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("ProximityPrompt")) then
                if obj:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(obj) end)
                else
                    local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                    tpTo(pivot)
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(p) end)
                        end
                    end
                end
                task.wait(0.15)
            end
        end
        print("[PEGASUS] Collect Passcode executed")
    end,
})

-- ========================
-- TAB ESP
-- ========================
local TabESP = Window:AddTab({
    Name = "ESP",
    Icon = "eye",
    Color = "Violet",
    Description = "Visualisasi objek penting",
})
local SectionESP = TabESP:AddSection("Visuals")

local espPlayerConn
SectionESP:AddToggle({
    Name = "ESP Player (Hitbox Merah)",
    Default = false,
    Flag = "ESPPlayer",
    Callback = function(state)
        clearESP("PegasusESP_Player")
        if espPlayerConn then espPlayerConn:Disconnect() espPlayerConn = nil end
        if state then
            local folder = Instance.new("Folder")
            folder.Name = "PegasusESP_Player"
            folder.Parent = Workspace
            local function apply()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr \~= LocalPlayer and plr.Character then
                        makeHighlight(plr.Character, Color3.fromRGB(255, 40, 40), folder)
                    end
                end
            end
            apply()
            espPlayerConn = RunService.Heartbeat:Connect(function()
                if tick() % 1.5 < 0.03 then apply() end
            end)
            print("[PEGASUS] ESP Player: ON")
        else
            print("[PEGASUS] ESP Player: OFF")
        end
    end,
})

local espKeyConn
SectionESP:AddToggle({
    Name = "ESP Key",
    Default = false,
    Flag = "ESPKey",
    Callback = function(state)
        clearESP("PegasusESP_Key")
        if espKeyConn then espKeyConn:Disconnect() espKeyConn = nil end
        if state then
            local folder = Instance.new("Folder")
            folder.Name = "PegasusESP_Key"
            folder.Parent = Workspace
            local function apply()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("key") or n:find("kunci")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part then
                            makeHighlight(obj, Color3.fromRGB(255, 220, 40), folder)
                            makeBillboard(part, obj.Name, Color3.fromRGB(255, 220, 40))
                        end
                    end
                end
            end
            apply()
            espKeyConn = RunService.Heartbeat:Connect(function()
                if tick() % 2 < 0.03 then apply() end
            end)
            print("[PEGASUS] ESP Key: ON")
        else
            print("[PEGASUS] ESP Key: OFF")
        end
    end,
})

local espPassConn
SectionESP:AddToggle({
    Name = "ESP Passcode",
    Default = false,
    Flag = "ESPPasscode",
    Callback = function(state)
        clearESP("PegasusESP_Passcode")
        if espPassConn then espPassConn:Disconnect() espPassConn = nil end
        if state then
            local folder = Instance.new("Folder")
            folder.Name = "PegasusESP_Passcode"
            folder.Parent = Workspace
            local function apply()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("passcode") or n:find("code") or n:find("note") or n:find("kode") or n:find("keypad")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part then
                            makeHighlight(obj, Color3.fromRGB(80, 200, 255), folder)
                            makeBillboard(part, obj.Name, Color3.fromRGB(80, 200, 255))
                        end
                    end
                end
            end
            apply()
            espPassConn = RunService.Heartbeat:Connect(function()
                if tick() % 2 < 0.03 then apply() end
            end)
            print("[PEGASUS] ESP Passcode: ON")
        else
            print("[PEGASUS] ESP Passcode: OFF")
        end
    end,
})

local espGuardConn
SectionESP:AddToggle({
    Name = "ESP Guard/Opah (Skeleton)",
    Default = false,
    Flag = "ESPGuard",
    Callback = function(state)
        clearESP("PegasusESP_Opah")
        if espGuardConn then espGuardConn:Disconnect() espGuardConn = nil end
        if state then
            local folder = Instance.new("Folder")
            folder.Name = "PegasusESP_Opah"
            folder.Parent = Workspace
            local function apply()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if (n:find("opah") or n:find("nenek") or n:find("granny") or n:find("guard") or n:find("npc")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part then
                            makeHighlight(obj, Color3.fromRGB(255, 50, 50), folder)
                            makeBillboard(part, "OPAH", Color3.fromRGB(255, 50, 50))
                        end
                    end
                end
            end
            apply()
            espGuardConn = RunService.Heartbeat:Connect(function()
                if tick() % 1 < 0.03 then apply() end
            end)
            print("[PEGASUS] ESP Guard/Opah: ON")
        else
            print("[PEGASUS] ESP Guard/Opah: OFF")
        end
    end,
})

-- ========================
-- TAB TELEPORT
-- ========================
local TabTP = Window:AddTab({
    Name = "Teleport",
    Icon = "map-pin",
    Color = "Amber",
    Description = "Teleport ke objek atau pemain",
})
local SectionTP = TabTP:AddSection("Teleport Options")

local function scanKeys()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("key") or n:find("kunci")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            table.insert(list, obj.Name)
        end
    end
    if #list == 0 then
        list = {"Red Key", "Blue Key", "Green Key", "Yellow Key", "Purple Key"}
    end
    return list
end

local keyList = scanKeys()
local selectedKey = keyList[1]

SectionTP:AddDropdown({
    Name = "Pilih Key",
    Options = keyList,
    Default = selectedKey,
    Callback = function(selected)
        selectedKey = type(selected) == "table" and selected[1] or selected
    end,
})

SectionTP:AddButton({
    Name = "Teleport ke Key Terpilih",
    Hint = "TP ke key",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == selectedKey and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                tpTo(pivot)
                print("[PEGASUS] Teleport to Key: " .. selectedKey)
                return
            end
        end
        print("[PEGASUS] Key not found: " .. tostring(selectedKey))
    end,
})

local function scanPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p \~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local playerNames = scanPlayers()
local selectedPlayer = playerNames[1] or ""

SectionTP:AddDropdown({
    Name = "Pilih Player",
    Options = #playerNames > 0 and playerNames or {"(no players)"},
    Default = selectedPlayer,
    Callback = function(selected)
        selectedPlayer = type(selected) == "table" and selected[1] or selected
    end,
})

SectionTP:AddButton({
    Name = "Teleport ke Player Terpilih",
    Hint = "TP ke player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame
                print("[PEGASUS] Teleport to Player: " .. selectedPlayer)
            end
        else
            print("[PEGASUS] Player not found / no character")
        end
    end,
})

SectionTP:AddButton({
    Name = "Teleport to Passcode",
    Hint = "TP ke passcode",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("passcode") or n:find("code") or n:find("note") or n:find("keypad")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local pivot = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                tpTo(pivot)
                print("[PEGASUS] Teleport to Passcode")
                return
            end
        end
        print("[PEGASUS] Passcode object not found")
    end,
})

-- ========================
-- FLOATING ICON
-- ========================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "PegasusFloatingIcon"
FloatingGui.ResetOnSpawn = false
FloatingGui.DisplayOrder = 999999
FloatingGui.IgnoreGuiInset = true
FloatingGui.Parent = PlayerGui

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0, 20, 0.5, -30)
FloatingButton.BackgroundTransparency = 1
FloatingButton.Image = CONFIG.FloatingIcon
FloatingButton.Visible = false
FloatingButton.Parent = FloatingGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingButton

FloatingButton.MouseButton1Click:Connect(function()
    if Window.Toggle then
        Window:Toggle()
    end
    FloatingButton.Visible = false
end)

-- simple visibility watcher (best-effort for MugiGen2)
task.spawn(function()
    task.wait(2)
    local gui = PlayerGui:FindFirstChild("MugiGen2") or PlayerGui:FindFirstChild("MugiHub") or PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    if gui then
        local mainFrame = gui:FindFirstChild("MainFrame") or gui:FindFirstChild("Window") or gui:FindFirstChildWhichIsA("Frame")
        if mainFrame then
            mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                FloatingButton.Visible = not mainFrame.Visible
            end)
        end
    end
end)

-- ========================
-- READY
-- ========================
MugiHub.Library:SetNotification({
    Type = "success",
    Content = "PEGASUS HUB berhasil dimuat!",
    Delay = 3,
})

print("[PEGASUS HUB] loaded for Malam Sama Opah / Nenek")
