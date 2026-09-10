--[[
    ========================================================================
    AJIZ HUB - SCREAM AND RUN (V12 ADVANCED EDITION)
    ========================================================================
    OPTIMIZED FOR: Delta, Xeno, Codex, Fluxus, Hydrogen (Android / iOS / PC)
    
    PALETTE (3-Color Clean System - ZERO EMOJIS):
    - Background: Dark Navy/Charcoal (16, 18, 24)
    - Primary Text: White (255, 255, 255)
    - Accent / Active / Brand: Sky Blue (0, 180, 255)
    ========================================================================
--]]

-- ========================================================================
-- EXECUTOR SAFE WRAPPERS
-- ========================================================================
local function safeFireTouch(part1, part2)
    if not part1 or not part2 or not part1.Parent or not part2.Parent then return end
    if firetouchinterest then
        pcall(firetouchinterest, part1, part2, 0)
        task.wait(0.02)
        pcall(firetouchinterest, part1, part2, 1)
    end
end

local function safeFirePrompt(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
    end)
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end)
    end
end

local function safeFireClick(detector)
    if not detector or not detector.Parent then return end
    pcall(function()
        detector.MaxActivationDistance = 50
    end)
    if fireclickdetector then
        pcall(fireclickdetector, detector)
    end
end

local function safeClick(cx, cy)
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(cx, cy))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(cx, cy))
    end)
end

-- ========================================================================
-- SERVICES
-- ========================================================================
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- ========================================================================
-- SAFE GUI PARENT (100% FAIL-PROOF FOR ALL EXECUTORS & STUDIO)
-- ========================================================================
local function getSafeParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    
    local okCore, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if okCore and coreGui then
        local testOk = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = coreGui
            test:Destroy()
        end)
        if testOk then return coreGui end
    end
    
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    return pg
end

local parentGui = getSafeParent()

pcall(function()
    for _, child in ipairs(parentGui:GetChildren()) do
        if child.Name:find("AjizScream") then
            pcall(function() child:Destroy() end)
        end
    end
end)

-- ========================================================================
-- CONFIGURATION STATE (ALL DEFAULT OFF)
-- ========================================================================
local State = {
    Running             = true,

    -- Objectives
    AutoCollectKeys     = false,
    AutoOpenDoors       = false,
    AutoSearchSpots     = false,
    CollectRange        = 75,

    -- Monster Controls & Freeze
    FreezeMonster       = false,
    NukeMonsterHitbox   = false,
    AutoFlingMonster    = false,
    StopMonsterAnim     = false,
    AutoDodge           = false,
    DodgeDistance       = 25,

    -- Survival
    GodSpot             = false,
    SafeHover           = false,
    TrueGodmode         = false,
    AntiDamage          = false,
    AutoRevive          = false,

    -- Visuals
    KeyESP              = false,
    ExitESP             = false,
    MonsterESP          = false,
    PlayerESP           = false,
    FullBright          = false,

    -- Movement
    SpeedHack           = false,
    WalkSpeed           = 32,
    InfiniteJump        = false,
    Noclip              = false,
    Fly                 = false,
    FlySpeed            = 50,
    FlyUp               = false,
    FlyDown             = false,

    -- Misc & UI
    AntiAFK             = false,
    UiScale             = 1.0,
}

-- ========================================================================
-- CHARACTER HELPERS
-- ========================================================================
local function getChar()
    return LocalPlayer.Character
end

local function getRoot(char)
    char = char or getChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char.PrimaryPart
end

local function getHumanoid(char)
    char = char or getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ========================================================================
-- ADVANCED MONSTER RECOGNITION & MULTI-LAYER FREEZE ENGINE
-- ========================================================================
local cachedMonsters = {}

local function isMonsterModel(m)
    if not m or not m:IsA("Model") or m == getChar() then return false end
    if Players:GetPlayerFromCharacter(m) then return false end

    local n = m.Name:lower()
    for _, kw in ipairs({"monster", "killer", "creature", "cat", "hat", "scream", "beast", "hunter", "enemy", "slasher", "chaser", "entity", "npc", "charles"}) do
        if n:find(kw) then return true end
    end

    local hum  = m:FindFirstChildOfClass("Humanoid")
    local root = m:FindFirstChild("HumanoidRootPart")
    if hum and root and not m:FindFirstChild("HumanoidDescription") then
        return true
    end
    return false
end

task.spawn(function()
    while State.Running do
        pcall(function()
            local list = {}
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("Model") and isMonsterModel(desc) then
                    if not table.find(list, desc) then
                        table.insert(list, desc)
                    end
                end
            end
            cachedMonsters = list
        end)
        task.wait(1.2)
    end
end)

-- Multi-Layer Monster Freeze & Neutralization Loop
RunService.Heartbeat:Connect(function()
    if not State.Running then return end

    local myRoot = getRoot()
    local myHum  = getHumanoid()

    for _, m in ipairs(cachedMonsters) do
        if m.Parent then
            local mRoot = getRoot(m)
            local mHum  = getHumanoid(m)

            -- Layer 1: Freeze Physics & Stop Movement
            if State.FreezeMonster and mRoot then
                pcall(function()
                    mRoot.Anchored = true
                    mRoot.AssemblyLinearVelocity = Vector3.zero
                    mRoot.AssemblyAngularVelocity = Vector3.zero
                    if mHum then
                        mHum.WalkSpeed = 0
                        mHum.PlatformStand = true
                    end
                end)
            end

            -- Layer 2: Stop Monster Animations
            if (State.FreezeMonster or State.StopMonsterAnim) and mHum then
                pcall(function()
                    local animator = mHum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            track:AdjustSpeed(0)
                        end
                    end
                end)
            end

            -- Layer 3: Auto Fling Monster if too close
            if State.AutoFlingMonster and myRoot and mRoot then
                local dist = (mRoot.Position - myRoot.Position).Magnitude
                if dist <= 30 then
                    pcall(function()
                        mRoot.CFrame = CFrame.new(mRoot.Position + Vector3.new(0, -600, 0))
                        mRoot.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                    end)
                end
            end

            -- Layer 4: Smart Auto Dodge with Cooldown Debounce (Prevents 60FPS Jitter/Hang)
            if (State.TrueGodmode or State.AutoDodge) and myRoot and mRoot then
                local now = os.clock()
                if (now - (State._lastDodge or 0)) >= 1.5 then
                    local dist = (mRoot.Position - myRoot.Position).Magnitude
                    if dist <= State.DodgeDistance then
                        State._lastDodge = now
                        local away = (myRoot.Position - mRoot.Position)
                        if away.Magnitude < 0.01 then away = Vector3.new(0, 1, 0) end
                        away = away.Unit
                        pcall(function()
                            myRoot.CFrame = CFrame.new(myRoot.Position + away * 25 + Vector3.new(0, 3, 0))
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            myRoot.AssemblyAngularVelocity = Vector3.zero
                        end)
                    end
                end
            end
        end
    end

    -- Layer 5: Anti-Damage State Protection
    if State.AntiDamage and myHum then
        pcall(function()
            if myHum.Health < 100 then myHum.Health = 100 end
            myHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            myHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end

    -- Layer 6: Continuous Speed Boost Enforcement
    if State.SpeedHack and myHum and myHum.WalkSpeed ~= State.WalkSpeed then
        pcall(function()
            myHum.WalkSpeed = State.WalkSpeed
        end)
    end
end)

-- Zero-Damage Touch & Hitbox Stripper (Monster Hitbox Nullification)
RunService.Stepped:Connect(function()
    if not State.Running then return end
    local char = getChar()

    -- Strip touch transmitters and collisions from monster parts only (Never strip player's touch!)
    if State.NukeMonsterHitbox or State.FreezeMonster then
        for _, m in ipairs(cachedMonsters) do
            if m and m.Parent then
                for _, p in ipairs(m:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function()
                            p.CanTouch   = false
                            p.CanCollide = false
                        end)
                    elseif p:IsA("TouchTransmitter") then
                        pcall(function() p:Destroy() end)
                    end
                end
            end
        end
    end

    -- Noclip
    if State.Noclip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end
end)

-- Manual Monster Fling / Void Ejector function
local function flingAllMonsters()
    local count = 0
    for _, m in ipairs(cachedMonsters) do
        if m and m.Parent then
            local r = getRoot(m)
            if r then
                pcall(function()
                    r.Anchored = false
                    r.CFrame = CFrame.new(0, -600, 0)
                    r.AssemblyLinearVelocity = Vector3.new(0, -5000, 0)
                    r.RotVelocity = Vector3.new(5000, 5000, 5000)
                    count = count + 1
                end)
            end
        end
    end
    return count
end

-- ========================================================================
-- PRECISE OBJECT IDENTIFIERS & VALIDATORS (ZERO JITTER / TRUE PICKUP)
-- ========================================================================
local function isValidMapPosition(pos)
    if not pos then return false end
    if pos.Y < -60 or pos.Y > 400 then return false end
    if math.abs(pos.X) > 3000 or math.abs(pos.Z) > 3000 then return false end
    return true
end

-- Smooth, non-jittery safe teleportation
local function safeTeleport(targetPos, offset)
    local root = getRoot()
    local hum  = getHumanoid()
    if not root or not hum then return false end

    offset = offset or Vector3.new(0, 2.8, 0)
    local finalPos = targetPos + offset

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(finalPos)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
    return true
end

local function isKeyItem(obj)
    if not obj or not obj.Parent then return false end

    local myChar = getChar()
    if myChar and obj:IsDescendantOf(myChar) then return false end

    -- Tools in workspace
    if obj:IsA("Tool") then
        local h = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
        if h and isValidMapPosition(h.Position) then return true end
    end

    -- ProximityPrompt Pickups
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if prompt and prompt.Enabled then
        local action = (prompt.ActionText or ""):lower()
        local objTxt = (prompt.ObjectText or ""):lower()
        local nameTxt = obj.Name:lower()

        -- Skip container / hiding prompts
        for _, ban in ipairs({"hide", "sit", "locker", "closet", "cabinet", "chest", "drawer", "wardrobe", "desk", "shelf"}) do
            if objTxt:find(ban) or nameTxt:find(ban) or action:find(ban) then
                return false
            end
        end

        for _, kw in ipairs({"take", "pick", "grab", "collect", "fuse", "key", "battery", "card", "crowbar", "wrench", "tool", "gas", "fuel", "plank", "tape", "item", "equip"}) do
            if action:find(kw) or objTxt:find(kw) or nameTxt:find(kw) then
                return true
            end
        end
    end

    -- ClickDetector on items
    local detector = obj:FindFirstChildOfClass("ClickDetector")
                  or (obj.Parent and obj.Parent:FindFirstChildOfClass("ClickDetector"))
    if detector and detector.MaxActivationDistance > 0 then
        local n = obj.Name:lower()
        for _, kw in ipairs({"key", "fuse", "battery", "card", "crowbar", "wrench", "tool", "fuel", "plank"}) do
            if n:find(kw) and not n:find("keyboard") and not n:find("keypad") and not n:find("keyhole") and not n:find("cardboard") then
                return true
            end
        end
    end

    -- Physical items on ground with strict filtering
    local n = obj.Name:lower()
    local banned = {"keyboard", "keypad", "keyhole", "cardboard", "desk", "shelf", "wall", "floor", "door", "gate", "chair", "table", "lock", "panel", "screen", "button", "light", "mesh", "room", "building", "spawn", "barrier"}
    for _, b in ipairs(banned) do
        if n:find(b) then return false end
    end

    for _, kw in ipairs({"key", "keycard", "fuse", "battery", "crowbar", "wrench", "plank", "card"}) do
        if n:find(kw) then
            if obj:IsA("BasePart") and obj.Size.Magnitude < 7 then
                return true
            elseif obj:IsA("Model") then
                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p and p.Size.Magnitude < 8 then
                    return true
                end
            end
        end
    end

    return false
end

local function isDoorObject(obj)
    if not obj then return false end
    local n = obj.Name:lower()
    if n:find("exit") or n:find("escape") then return false end
    for _, kw in ipairs({"door", "gate", "hatch", "barrier", "shutter", "entrance", "lock"}) do
        if n:find(kw) then return true end
    end
    return false
end

local function isExitDoor(obj)
    if not obj then return false end
    local n = obj.Name:lower()
    for _, kw in ipairs({"exit", "escape", "safezone", "safe_zone", "extract", "win_door", "main_door", "schoolexit", "school_exit", "windoor", "exitdoor", "escapedoor"}) do
        if n:find(kw) then return true end
    end
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if prompt then
        local a = (prompt.ActionText or ""):lower()
        local o = (prompt.ObjectText or ""):lower()
        if a:find("escape") or a:find("exit") or a:find("extract") or a:find("win") or o:find("escape") or o:find("exit") then
            return true
        end
    end
    return false
end

-- ========================================================================
-- WORLD OBJECT CACHE ENGINE (ELIMINATES LAG & PREVENTS CRASHES)
-- ========================================================================
local cachedKeys = {}
local cachedDoors = {}
local cachedSearchPrompts = {}

local function refreshWorldCache()
    local myChar = getChar()
    local newKeys = {}
    local newDoors = {}
    local newSearches = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not (myChar and obj:IsDescendantOf(myChar)) then
            -- 1. Keys & Items
            if isKeyItem(obj) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and part.Parent and isValidMapPosition(part.Position) and not table.find(newKeys, part) then
                    table.insert(newKeys, part)
                end
            end

            -- 2. Exit Door & Doors
            if isExitDoor(obj) or isDoorObject(obj) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and part.Parent and isValidMapPosition(part.Position) and not table.find(newDoors, part) then
                    table.insert(newDoors, part)
                end
            end

            -- 3. Search Prompts (Lockers / Desks)
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parent = obj.Parent
                if parent then
                    local act = (obj.ActionText or ""):lower()
                    local objT = (obj.ObjectText or ""):lower()
                    local parN = parent.Name:lower()
                    for _, kw in ipairs({"search", "locker", "desk", "drawer", "cabinet", "closet", "shelf", "box", "chest", "check", "open"}) do
                        if act:find(kw) or objT:find(kw) or parN:find(kw) then
                            table.insert(newSearches, obj)
                            break
                        end
                    end
                end
            end
        end
    end

    cachedKeys = newKeys
    cachedDoors = newDoors
    cachedSearchPrompts = newSearches
end

-- Periodic world cache update thread (Runs every 2.5 seconds, zero frame drops)
task.spawn(function()
    while State.Running do
        pcall(refreshWorldCache)
        task.wait(2.5)
    end
end)

local function findAllKeys()
    local valid = {}
    local myRoot = getRoot()
    for _, k in ipairs(cachedKeys) do
        if k and k.Parent and isValidMapPosition(k.Position) then
            table.insert(valid, k)
        end
    end
    if #valid == 0 then
        pcall(refreshWorldCache)
        for _, k in ipairs(cachedKeys) do
            if k and k.Parent and isValidMapPosition(k.Position) then
                table.insert(valid, k)
            end
        end
    end
    if myRoot and #valid > 1 then
        local myPos = myRoot.Position
        table.sort(valid, function(a, b)
            return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
        end)
    end
    return valid
end

local function findExitDoor()
    for _, d in ipairs(cachedDoors) do
        if d and d.Parent and isExitDoor(d) and isValidMapPosition(d.Position) then
            return d
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isExitDoor(obj) then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and part.Parent and isValidMapPosition(part.Position) then
                return part
            end
        end
    end
    return nil
end

local function interactWithObject(part)
    if not part or not part.Parent then return end
    local myRoot = getRoot()
    if not myRoot then return end

    -- 1. Fire ProximityPrompt safely
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                or (part.Parent and part.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if prompt and prompt.Enabled then
        safeFirePrompt(prompt)
    end

    -- 2. Fire ClickDetector
    local detector = part:FindFirstChildOfClass("ClickDetector")
                  or (part.Parent and part.Parent:FindFirstChildOfClass("ClickDetector"))
    if detector then
        safeFireClick(detector)
    end

    -- 3. Touch interaction
    if part:IsA("BasePart") then
        safeFireTouch(myRoot, part)
    elseif part:IsA("Model") then
        local p = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")
        if p then safeFireTouch(myRoot, p) end
    end

    -- 4. Tool Handle Pickup
    if part:IsA("Tool") or (part.Parent and part.Parent:IsA("Tool")) then
        local tool = part:IsA("Tool") and part or part.Parent
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if handle then
            safeFireTouch(myRoot, handle)
        end
    end
end

-- Auto Objectives Background Loop (Fast 0.3s tick, cached objects, zero lag)
task.spawn(function()
    while State.Running do
        local myRoot = getRoot()
        if myRoot then
            -- 1. Auto Collect Keys in range
            if State.AutoCollectKeys then
                for _, keyPart in ipairs(cachedKeys) do
                    if keyPart and keyPart.Parent then
                        local dist = (keyPart.Position - myRoot.Position).Magnitude
                        if dist <= State.CollectRange then
                            interactWithObject(keyPart)
                        end
                    end
                end
            end

            -- 2. Auto Open Doors in range
            if State.AutoOpenDoors then
                for _, doorPart in ipairs(cachedDoors) do
                    if doorPart and doorPart.Parent then
                        local dist = (doorPart.Position - myRoot.Position).Magnitude
                        if dist <= 30 then
                            interactWithObject(doorPart)
                        end
                    end
                end
            end

            -- 3. Auto Search Spots in range
            if State.AutoSearchSpots then
                for _, prompt in ipairs(cachedSearchPrompts) do
                    if prompt and prompt.Parent and prompt.Enabled then
                        local p = prompt.Parent
                        local pos = p:IsA("BasePart") and p.Position or (p:IsA("Model") and p.PrimaryPart and p.PrimaryPart.Position)
                        if pos and (pos - myRoot.Position).Magnitude <= 30 then
                            safeFirePrompt(prompt)
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Safe & Smooth Auto Win Sequence (Zero Lag / Zero Physics Hang)
local autoWinning = false
local function runSafeAutoWinSequence()
    if autoWinning then return false, "Already in progress" end
    autoWinning = true

    local myRoot = getRoot()
    local myHum  = getHumanoid()
    if not myRoot or not myHum then
        autoWinning = false
        return false, "Player not ready"
    end

    pcall(refreshWorldCache)
    local keys = findAllKeys()
    local collected = 0

    if #keys > 0 then
        for _, k in ipairs(keys) do
            if k and k.Parent and isValidMapPosition(k.Position) then
                safeTeleport(k.Position, Vector3.new(0, 2.8, 0))
                task.wait(0.25)
                interactWithObject(k)
                task.wait(0.2)
                collected = collected + 1
            end
        end
    end

    -- Teleport to exit
    task.wait(0.3)
    local exit = findExitDoor()
    if exit and isValidMapPosition(exit.Position) then
        safeTeleport(exit.Position, Vector3.new(0, 2.8, 0))
        task.wait(0.25)
        interactWithObject(exit)
        autoWinning = false
        return true, "Escaped successfully"
    end

    autoWinning = false
    if collected > 0 then
        return true, "Collected " .. tostring(collected) .. " items"
    else
        return false, "No active keys detected"
    end
end

-- Auto Revive Loop
local function tryRevive()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return end

    for _, obj in ipairs(pg:GetDescendants()) do
        if not (obj:IsA("TextButton") or obj:IsA("ImageButton")) then continue end
        if not obj.Visible then continue end

        local textL = (obj:IsA("TextButton") and obj.Text or ""):lower()
        local nameL = obj.Name:lower()

        if textL:find("revive") or textL:find("respawn") or textL:find("play again")
        or nameL:find("revive") or nameL:find("respawn") then
            pcall(function() obj.MouseButton1Click:Fire() end)
            pcall(function() obj.Activated:Fire() end)
            pcall(function()
                local ap = obj.AbsolutePosition
                local as = obj.AbsoluteSize
                safeClick(ap.X + as.X * 0.5, ap.Y + as.Y * 0.5)
            end)
        end
    end
end

task.spawn(function()
    while State.Running do
        if State.AutoRevive then
            local hum = getHumanoid()
            if not hum or hum.Health <= 0 then
                pcall(tryRevive)
            end
        end
        task.wait(0.4)
    end
end)

local function hookDeath(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 8)
    if not hum then return end
    hum.Died:Connect(function()
        if not State.AutoRevive then return end
        for i = 1, 12 do
            task.wait(0.3)
            pcall(tryRevive)
        end
    end)
end

task.spawn(function()
    if LocalPlayer.Character then pcall(hookDeath, LocalPlayer.Character) end
end)
LocalPlayer.CharacterAdded:Connect(function(c)
    task.spawn(pcall, hookDeath, c)
    task.spawn(function()
        task.wait(0.3)
        local hum = c:WaitForChild("Humanoid", 6)
        if hum and State.SpeedHack then
            hum.WalkSpeed = State.WalkSpeed
        end
        if State.FullBright then
            applyFullBright(true)
        end
        if State.Fly then
            toggleFly(false)
            task.wait(0.1)
            toggleFly(true)
        end
        if State.KeyESP or State.ExitESP or State.MonsterESP or State.PlayerESP then
            task.wait(0.5)
            refreshESP()
        end
    end)
end)

-- Safe Hover & Sky Base
local hoverFloor = nil
RunService.RenderStepped:Connect(function()
    if State.SafeHover then
        if not hoverFloor or not hoverFloor.Parent then
            hoverFloor = Instance.new("Part")
            hoverFloor.Name         = "AjizHoverFloor"
            hoverFloor.Size         = Vector3.new(8, 1, 8)
            hoverFloor.Transparency = 0.75
            hoverFloor.Color        = Color3.fromRGB(0, 180, 255)
            hoverFloor.Material     = Enum.Material.Neon
            hoverFloor.Anchored     = true
            hoverFloor.CanCollide   = true
            hoverFloor.Parent       = Workspace
        end
        local r = getRoot()
        if r then
            hoverFloor.CFrame = CFrame.new(r.Position.X, r.Position.Y - 3.2, r.Position.Z)
        end
    elseif hoverFloor then
        hoverFloor:Destroy()
        hoverFloor = nil
    end
end)

local safePlatform, originalCF = nil, nil
local function makeGodSpot()
    if safePlatform and safePlatform.Parent then safePlatform:Destroy() end
    local model = Instance.new("Model")
    model.Name  = "AjizGodSpot"

    local function mkPart(sz, pos, transp, col)
        local p           = Instance.new("Part")
        p.Size            = sz
        p.Position        = pos
        p.Anchored        = true
        p.CanCollide      = true
        p.Transparency    = transp
        p.Color           = col
        p.Material        = Enum.Material.Neon
        p.Parent          = model
    end

    mkPart(Vector3.new(40, 2, 40), Vector3.new(0, 380, 0),  0.25, Color3.fromRGB(0, 180, 255))
    mkPart(Vector3.new(40, 12, 2), Vector3.new(0, 387, 20), 0.6,  Color3.fromRGB(15, 20, 35))
    mkPart(Vector3.new(40, 12, 2), Vector3.new(0, 387,-20), 0.6,  Color3.fromRGB(15, 20, 35))
    mkPart(Vector3.new(2, 12, 40), Vector3.new(20, 387, 0), 0.6,  Color3.fromRGB(15, 20, 35))
    mkPart(Vector3.new(2, 12, 40), Vector3.new(-20,387, 0), 0.6,  Color3.fromRGB(15, 20, 35))

    model.Parent = Workspace
    safePlatform = model
end

local function toggleGodSpot(on)
    local r = getRoot()
    if on then
        makeGodSpot()
        if r then
            originalCF = r.CFrame
            r.CFrame   = CFrame.new(0, 385, 0)
        end
    else
        if r and originalCF then
            r.CFrame   = originalCF
            originalCF = nil
        end
        if safePlatform then safePlatform:Destroy(); safePlatform = nil end
    end
end

-- Visuals / ESP Engine
local espObjects = {}
local function clearESP()
    for _, t in pairs(espObjects) do
        for _, inst in ipairs(t) do
            if inst and inst.Parent then pcall(function() inst:Destroy() end) end
        end
    end
    espObjects = {}
end

local function attachHighlight(target, color, fillTransp, outlineColor)
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "AjizHL"
        hl.Adornee = target
        hl.FillColor = color
        hl.FillTransparency = fillTransp or 0.5
        hl.OutlineColor = outlineColor or Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Parent = target
        table.insert(espObjects[target] or {}, hl)
    end)
end

local function attachTag(target, text, color)
    pcall(function()
        local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart")
        if not part then return end
        local bg = Instance.new("BillboardGui")
        bg.Name = "AjizTag"
        bg.Adornee = part
        bg.Size = UDim2.new(0, 120, 0, 30)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = part

        local l = Instance.new("TextLabel", bg)
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.Text = text
        l.TextColor3 = color
        l.TextSize = 12
        l.TextStrokeTransparency = 0.2
        l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        table.insert(espObjects[target] or {}, bg)
    end)
end

local function refreshESP()
    clearESP()
    local myChar = getChar()

    if State.MonsterESP then
        for _, m in ipairs(cachedMonsters) do
            if m.Parent then
                espObjects[m] = {}
                attachHighlight(m, Color3.fromRGB(255, 45, 45), 0.4, Color3.fromRGB(255, 100, 100))
                attachTag(m, "MONSTER: " .. m.Name:upper(), Color3.fromRGB(255, 50, 50))
            end
        end
    end

    if State.KeyESP then
        for _, k in ipairs(findAllKeys()) do
            if k and k.Parent then
                espObjects[k] = {}
                attachHighlight(k, Color3.fromRGB(0, 220, 255), 0.3, Color3.fromRGB(255, 255, 255))
                attachTag(k, "ITEM: " .. k.Name:upper(), Color3.fromRGB(0, 220, 255))
            end
        end
    end

    if State.ExitESP then
        local exit = findExitDoor()
        if exit and exit.Parent then
            espObjects[exit] = {}
            attachHighlight(exit, Color3.fromRGB(40, 240, 100), 0.3, Color3.fromRGB(255, 255, 255))
            attachTag(exit, "EXIT DOOR", Color3.fromRGB(40, 240, 100))
        end
    end

    if State.PlayerESP then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character.Parent then
                espObjects[pl.Character] = {}
                attachHighlight(pl.Character, Color3.fromRGB(255, 210, 0), 0.6, Color3.fromRGB(255, 255, 255))
                attachTag(pl.Character, pl.DisplayName, Color3.fromRGB(255, 210, 0))
            end
        end
    end
end

task.spawn(function()
    while State.Running do
        if State.KeyESP or State.ExitESP or State.MonsterESP or State.PlayerESP then
            pcall(refreshESP)
        else
            clearESP()
        end
        task.wait(2.5)
    end
end)

-- Movement & Flight
local flyBV, flyBG = nil, nil
local function toggleFly(on)
    local root = getRoot()
    local hum  = getHumanoid()
    if on and root and hum then
        flyBV = Instance.new("BodyVelocity")
        flyBV.Name     = "AjizFlyBV"
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent   = root

        flyBG = Instance.new("BodyGyro")
        flyBG.Name     = "AjizFlyBG"
        flyBG.MaxTorque= Vector3.new(9e9, 9e9, 9e9)
        flyBG.CFrame   = root.CFrame
        flyBG.Parent   = root
        hum.PlatformStand = true
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if hum then hum.PlatformStand = false end
    end
end

RunService.RenderStepped:Connect(function()
    if State.Fly and flyBV and flyBG then
        local cam  = Workspace.CurrentCamera
        local root = getRoot()
        if not cam or not root then return end

        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if State.FlyUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if State.FlyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * State.FlySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = cam.CFrame
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local function applyFullBright(on)
    if not on then return end
    pcall(function()
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness     = 2.5
        Lighting.FogEnd         = 100000
        Lighting.ClockTime      = 14
    end)
end

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ========================================================================
-- 3-COLOR CLEAN UI (NO EMOJIS - FULLY RESIZABLE WITH VISIBLE CONTROLS)
-- Palette:
-- 1. Dark BG: (16, 18, 24)
-- 2. Text: White (255, 255, 255)
-- 3. Accent / Brand / Toggle ON: Sky Blue (0, 180, 255)
-- ========================================================================
local Theme = {
    BG       = Color3.fromRGB(16, 18, 24),
    Header   = Color3.fromRGB(22, 25, 34),
    Border   = Color3.fromRGB(30, 36, 48),
    SkyBlue  = Color3.fromRGB(0, 180, 255),
    White    = Color3.fromRGB(255, 255, 255),
    ToggleOFF= Color3.fromRGB(28, 32, 42),
    ItemBg   = Color3.fromRGB(22, 26, 36),
    Muted    = Color3.fromRGB(150, 158, 175),
    Red      = Color3.fromRGB(235, 65, 65),
    FontB    = Enum.Font.GothamBold,
    FontR    = Enum.Font.GothamMedium,
}

local ScreenGui        = Instance.new("ScreenGui")
ScreenGui.Name         = "AjizScreamHubV12"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

local parented = false
pcall(function()
    ScreenGui.Parent = parentGui
    parented = true
end)
if not parented or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local drag, dInp, dSt, dP0
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dSt = i.Position; dP0 = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then dInp = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dInp and drag then
            local d = i.Position - dSt
            frame.Position = UDim2.new(dP0.X.Scale, dP0.X.Offset + d.X,
                                       dP0.Y.Scale, dP0.Y.Offset + d.Y)
        end
    end)
end

-- Mobile AJ Bubble
local AJBtn = Instance.new("ImageButton", ScreenGui)
AJBtn.Name            = "AJFloat"
AJBtn.Size            = UDim2.new(0, 42, 0, 42)
AJBtn.Position        = UDim2.new(0, 15, 0.45, 0)
AJBtn.BackgroundColor3= Theme.Header
AJBtn.BorderSizePixel = 0
AJBtn.Active          = true
Instance.new("UICorner", AJBtn).CornerRadius = UDim.new(0, 8)
local ajS = Instance.new("UIStroke", AJBtn)
ajS.Color = Theme.SkyBlue; ajS.Thickness = 1.3
local ajL = Instance.new("TextLabel", AJBtn)
ajL.Size = UDim2.new(1, 0, 1, 0); ajL.BackgroundTransparency = 1
ajL.Font = Theme.FontB; ajL.Text = "AJ"; ajL.TextColor3 = Theme.SkyBlue; ajL.TextSize = 14
makeDraggable(AJBtn)

-- Main Frame with UIScale Support
-- Main Frame with UIScale Support
local isMin   = false
local curW    = 260
local curH    = 340

local Main = Instance.new("Frame", ScreenGui)
Main.Name            = "MainPanel"
Main.Size            = UDim2.new(0, curW, 0, curH)
Main.Position        = UDim2.new(0.5, -130, 0.5, -170)
Main.BackgroundColor3= Theme.BG
Main.BorderSizePixel = 0
Main.Active          = true
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local mS = Instance.new("UIStroke", Main)
mS.Color = Theme.Border; mS.Thickness = 1.2

-- Global Scale Controller
local GlobalScale = Instance.new("UIScale", Main)
GlobalScale.Scale = State.UiScale

local function setScale(val)
    val = math.clamp(val, 0.5, 1.6)
    State.UiScale = val
    GlobalScale.Scale = val
end

-- Header
local Hdr = Instance.new("Frame", Main)
Hdr.Name = "Header"
Hdr.Size = UDim2.new(1, 0, 0, 32); Hdr.BackgroundColor3 = Theme.Header; Hdr.BorderSizePixel = 0
Hdr.ZIndex = 10
Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 8)

local Ttl = Instance.new("TextLabel", Hdr)
Ttl.Size = UDim2.new(1, -115, 1, 0); Ttl.Position = UDim2.new(0, 10, 0, 0)
Ttl.BackgroundTransparency = 1; Ttl.Font = Theme.FontB
Ttl.Text = "SCREAM AND RUN"; Ttl.TextColor3 = Theme.SkyBlue
Ttl.TextSize = 11; Ttl.TextXAlignment = Enum.TextXAlignment.Left
Ttl.ZIndex = 11

-- Scale Down Button (-)
local ScaleMinus = Instance.new("TextButton", Hdr)
ScaleMinus.Size = UDim2.new(0, 20, 0, 20); ScaleMinus.Position = UDim2.new(1, -108, 0.5, -10)
ScaleMinus.BackgroundColor3 = Color3.fromRGB(28, 32, 44); ScaleMinus.Text = "-"
ScaleMinus.Font = Theme.FontB; ScaleMinus.TextColor3 = Theme.SkyBlue; ScaleMinus.TextSize = 13; ScaleMinus.AutoButtonColor = false
ScaleMinus.ZIndex = 12
Instance.new("UICorner", ScaleMinus).CornerRadius = UDim.new(0, 4)

-- Scale Up Button (+)
local ScalePlus = Instance.new("TextButton", Hdr)
ScalePlus.Size = UDim2.new(0, 20, 0, 20); ScalePlus.Position = UDim2.new(1, -84, 0.5, -10)
ScalePlus.BackgroundColor3 = Color3.fromRGB(28, 32, 44); ScalePlus.Text = "+"
ScalePlus.Font = Theme.FontB; ScalePlus.TextColor3 = Theme.SkyBlue; ScalePlus.TextSize = 13; ScalePlus.AutoButtonColor = false
ScalePlus.ZIndex = 12
Instance.new("UICorner", ScalePlus).CornerRadius = UDim.new(0, 4)

-- Minimize Button
local MinB = Instance.new("TextButton", Hdr)
MinB.Size = UDim2.new(0, 22, 0, 20); MinB.Position = UDim2.new(1, -58, 0.5, -10)
MinB.BackgroundColor3 = Color3.fromRGB(28, 32, 44); MinB.Text = "[-]"
MinB.Font = Theme.FontB; MinB.TextColor3 = Theme.Muted; MinB.TextSize = 10; MinB.AutoButtonColor = false
MinB.ZIndex = 12
Instance.new("UICorner", MinB).CornerRadius = UDim.new(0, 4)

-- Close Button
local XBtn = Instance.new("TextButton", Hdr)
XBtn.Size = UDim2.new(0, 22, 0, 20); XBtn.Position = UDim2.new(1, -30, 0.5, -10)
XBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 25); XBtn.Text = "[X]"
XBtn.Font = Theme.FontB; XBtn.TextColor3 = Theme.Red; XBtn.TextSize = 10; XBtn.AutoButtonColor = false
XBtn.ZIndex = 12
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(0, 4)

-- Scroll Body
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -56); Scroll.Position = UDim2.new(0, 5, 0, 34)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2.5; Scroll.ScrollBarImageColor3 = Theme.SkyBlue
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ZIndex = 2
local SL = Instance.new("UIListLayout", Scroll)
SL.Padding = UDim.new(0, 4); SL.SortOrder = Enum.SortOrder.LayoutOrder

-- Footer (Status & Brand)
local Ftr = Instance.new("Frame", Main)
Ftr.Size = UDim2.new(1, 0, 0, 22); Ftr.Position = UDim2.new(0, 0, 1, -22)
Ftr.BackgroundColor3 = Theme.Header; Ftr.BorderSizePixel = 0
Ftr.ZIndex = 3
local FtrL = Instance.new("TextLabel", Ftr)
FtrL.Name = "Status"; FtrL.Size = UDim2.new(1, -75, 1, 0); FtrL.Position = UDim2.new(0, 8, 0, 0)
FtrL.BackgroundTransparency = 1; FtrL.Font = Theme.FontB; FtrL.Text = "AJIZ HUB"
FtrL.TextColor3 = Theme.SkyBlue; FtrL.TextSize = 10.5; FtrL.TextXAlignment = Enum.TextXAlignment.Left
FtrL.ZIndex = 4

-- Dynamic Corner Resize Handle
local ResizeHandle = Instance.new("TextButton", Main)
ResizeHandle.Name = "ResizeGrip"
ResizeHandle.Size = UDim2.new(0, 68, 0, 20)
ResizeHandle.Position = UDim2.new(1, -70, 1, -21)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
ResizeHandle.Text = "RESIZE ///"
ResizeHandle.Font = Theme.FontB
ResizeHandle.TextColor3 = Theme.SkyBlue
ResizeHandle.TextSize = 9.5
ResizeHandle.AutoButtonColor = false
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 5
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

-- Smooth Minimize / Restore Function
local function toggleMinimize(targetState)
    if targetState ~= nil then
        isMin = targetState
    else
        isMin = not isMin
    end

    if isMin then
        Scroll.Visible = false
        Ftr.Visible = false
        ResizeHandle.Visible = false
        MinB.Text = "[+]"
        MinB.TextColor3 = Theme.SkyBlue
        Ttl.Text = "SCREAM AND RUN [CLICK +]"
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, curW, 0, 32)
        }):Play()
    else
        MinB.Text = "[-]"
        MinB.TextColor3 = Theme.Muted
        Ttl.Text = "SCREAM AND RUN"
        Scroll.Visible = true
        Ftr.Visible = true
        ResizeHandle.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, curW, 0, curH)
        }):Play()
    end
end

makeDraggable(Main, Hdr)
AJBtn.Activated:Connect(function()
    if not Main.Visible then
        Main.Visible = true
        if isMin then toggleMinimize(false) end
    else
        if isMin then
            toggleMinimize(false)
        else
            Main.Visible = false
        end
    end
end)

XBtn.Activated:Connect(function() Main.Visible = false end)
MinB.Activated:Connect(function() toggleMinimize() end)

ScaleMinus.Activated:Connect(function() setScale(State.UiScale - 0.1) end)
ScalePlus.Activated:Connect(function() setScale(State.UiScale + 0.1) end)

local resizing = false
local rStartPos, rStartSize
ResizeHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        rStartPos = i.Position
        rStartSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = (i.Position - rStartPos) / (GlobalScale.Scale or 1)
        local newW = math.clamp(rStartSize.X + delta.X, 220, 500)
        local newH = math.clamp(rStartSize.Y + delta.Y, 260, 700)
        curW = newW
        curH = newH
        if not isMin then
            Main.Size = UDim2.new(0, newW, 0, newH)
        end
    end
end)

-- ========================================================================
-- UI BUILDER HELPERS (STRICT ZERO EMOJIS)
-- ========================================================================
local function AddSection(title)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(1, 0, 0, 20); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Font = Theme.FontB; l.Text = "  " .. title:upper()
    l.TextColor3 = Theme.SkyBlue; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    local ln = Instance.new("Frame", f)
    ln.Size = UDim2.new(1, -6, 0, 1); ln.Position = UDim2.new(0, 3, 1, -1)
    ln.BackgroundColor3 = Theme.Border; ln.BorderSizePixel = 0
end

local function AddToggle(title, def, cb)
    local state = def or false
    local row = Instance.new("Frame", Scroll)
    row.Size = UDim2.new(1, 0, 0, 32); row.BackgroundColor3 = Theme.ItemBg; row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    local sk = Instance.new("UIStroke", row); sk.Color = Theme.Border; sk.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -48, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Font = Theme.FontR
    lbl.Text = title; lbl.TextColor3 = Theme.White; lbl.TextSize = 10.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local box = Instance.new("TextButton", row)
    box.Size = UDim2.new(0, 34, 0, 18); box.Position = UDim2.new(1, -40, 0.5, -9)
    box.BackgroundColor3 = state and Theme.SkyBlue or Theme.ToggleOFF
    box.Text = state and "ON" or "OFF"; box.Font = Theme.FontB
    box.TextColor3 = state and Theme.BG or Theme.Muted; box.TextSize = 9.5; box.AutoButtonColor = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    local function flip(v)
        state = v
        box.BackgroundColor3 = state and Theme.SkyBlue or Theme.ToggleOFF
        box.Text = state and "ON" or "OFF"
        box.TextColor3 = state and Theme.BG or Theme.Muted
        pcall(cb, state)
    end
    box.Activated:Connect(function() flip(not state) end)
    local cv = Instance.new("TextButton", row)
    cv.Size = UDim2.new(1, -45, 1, 0); cv.BackgroundTransparency = 1; cv.Text = ""
    cv.Activated:Connect(function() flip(not state) end)
end

local function AddButton(text, cb)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Theme.SkyBlue
    btn.Text = text:upper(); btn.TextColor3 = Theme.BG
    btn.Font = Theme.FontB; btn.TextSize = 10.5; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.Activated:Connect(cb)
end

local function AddSlider(title, min, max, def, cb)
    local val = def or min
    local row = Instance.new("Frame", Scroll)
    row.Size = UDim2.new(1, 0, 0, 44); row.BackgroundColor3 = Theme.ItemBg; row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", row).Color = Theme.Border

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -50, 0, 20); lbl.Position = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1; lbl.Font = Theme.FontR
    lbl.Text = title; lbl.TextColor3 = Theme.White; lbl.TextSize = 10.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local vL = Instance.new("TextLabel", row)
    vL.Size = UDim2.new(0, 40, 0, 20); vL.Position = UDim2.new(1, -45, 0, 3)
    vL.BackgroundTransparency = 1; vL.Font = Theme.FontB
    vL.Text = tostring(val); vL.TextColor3 = Theme.SkyBlue; vL.TextSize = 10
    vL.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("TextButton", row)
    bar.Size = UDim2.new(1, -16, 0, 7); bar.Position = UDim2.new(0, 8, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(30, 35, 48); bar.Text = ""; bar.AutoButtonColor = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp((val - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Theme.SkyBlue; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function upd(i)
        local rx = math.clamp(i.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local r  = rx / bar.AbsoluteSize.X
        val = math.floor(min + (max - min) * r)
        fill.Size = UDim2.new(r, 0, 1, 0); vL.Text = tostring(val); pcall(cb, val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
end

local function AddFlyButtons()
    local row = Instance.new("Frame", Scroll)
    row.Size = UDim2.new(1, 0, 0, 34); row.BackgroundTransparency = 1
    local function mkBtn(txt, xPos, onD, onU)
        local b = Instance.new("TextButton", row)
        b.Size = UDim2.new(0.48, 0, 1, 0); b.Position = UDim2.new(xPos, 0, 0, 0)
        b.BackgroundColor3 = Theme.ItemBg; b.Text = txt
        b.TextColor3 = Theme.SkyBlue; b.Font = Theme.FontB; b.TextSize = 10.5; b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local st = Instance.new("UIStroke", b); st.Color = Theme.Border
        b.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then onD() end
        end)
        b.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then onU() end
        end)
    end
    mkBtn("FLY UP",   0,    function() State.FlyUp   = true  end, function() State.FlyUp   = false end)
    mkBtn("FLY DOWN", 0.52, function() State.FlyDown = true  end, function() State.FlyDown = false end)
end

-- ========================================================================
-- CONTROLS INITIALIZATION
-- ========================================================================

-- 1. OBJECTIVES & ESCAPE
AddSection("Objectives and Escape")
AddButton("Auto Collect All Keys", function()
    task.spawn(function()
        FtrL.Text = "STATUS: COLLECTING KEYS..."
        local ok, msg = runSafeAutoWinSequence()
        FtrL.Text = "STATUS: " .. msg:upper()
        task.delay(3, function() FtrL.Text = "AJIZ HUB" end)
    end)
end)

AddButton("Teleport to Nearest Key", function()
    task.spawn(function()
        local myRoot = getRoot()
        if not myRoot then return end
        local keys = findAllKeys()
        if #keys == 0 then
            FtrL.Text = "STATUS: NO KEYS DETECTED"
        else
            local closest, cDist = nil, math.huge
            for _, k in ipairs(keys) do
                local d = (k.Position - myRoot.Position).Magnitude
                if d < cDist then cDist = d; closest = k end
            end
            if closest and isValidMapPosition(closest.Position) then
                safeTeleport(closest.Position, Vector3.new(0, 2.8, 0))
                FtrL.Text = "STATUS: TELEPORTED TO " .. closest.Name:upper()
                task.wait(0.2)
                interactWithObject(closest)
            end
        end
        task.delay(3, function() FtrL.Text = "AJIZ HUB" end)
    end)
end)

AddButton("Teleport to Exit Door", function()
    task.spawn(function()
        local myRoot = getRoot()
        local exit = findExitDoor()
        if myRoot and exit and isValidMapPosition(exit.Position) then
            safeTeleport(exit.Position, Vector3.new(0, 2.8, 0))
            FtrL.Text = "STATUS: TELEPORTED TO EXIT"
            task.wait(0.2)
            interactWithObject(exit)
        else
            FtrL.Text = "STATUS: EXIT NOT FOUND"
        end
        task.delay(3, function() FtrL.Text = "AJIZ HUB" end)
    end)
end)

AddToggle("Auto Collect Keys / Items", false, function(v) State.AutoCollectKeys = v end)
AddToggle("Auto Open and Unlock Doors", false, function(v) State.AutoOpenDoors   = v end)
AddToggle("Auto Search Lockers and Desks", false, function(v) State.AutoSearchSpots = v end)
AddSlider("Collect Range", 20, 120, 75, function(v) State.CollectRange = v end)

-- 2. ADVANCED MONSTER FREEZE & NEUTRALIZER
AddSection("Monster Freeze and Defense")
AddButton("Fling Monster to Void", function()
    task.spawn(function()
        local c = flingAllMonsters()
        FtrL.Text = "STATUS: FLUNG " .. tostring(c) .. " MONSTERS"
        task.delay(3, function() FtrL.Text = "AJIZ HUB" end)
    end)
end)

AddToggle("Freeze Monster Physics", false, function(v)
    State.FreezeMonster = v
    if not v then
        for _, m in ipairs(cachedMonsters) do
            local r = getRoot(m)
            local hum = getHumanoid(m)
            if r then pcall(function() r.Anchored = false end) end
            if hum then pcall(function() hum.WalkSpeed = 16; hum.PlatformStand = false end) end
        end
    end
end)

AddToggle("Nuke Monster Touch Hitbox", false, function(v) State.NukeMonsterHitbox = v end)
AddToggle("Auto Fling Nearby Monster", false, function(v) State.AutoFlingMonster = v end)
AddToggle("Stop Monster Animations", false, function(v) State.StopMonsterAnim = v end)
AddToggle("Smart Auto Dodge", false, function(v) State.AutoDodge = v end)
AddSlider("Dodge Distance", 15, 50, 25, function(v) State.DodgeDistance = v end)

-- 3. SURVIVAL & GODMODE
AddSection("Survival and Godmode")
AddToggle("Auto Revive (Instant Respawn)", false, function(v) State.AutoRevive = v end)
AddToggle("God Spot (Sky Base)", false, function(v) State.GodSpot = v; toggleGodSpot(v) end)
AddToggle("Safe Hover (Walk in Air)", false, function(v) State.SafeHover = v end)
AddToggle("True Godmode (Auto Evade)", false, function(v) State.TrueGodmode = v end)
AddToggle("Anti Damage (HP Lock)", false, function(v) State.AntiDamage = v end)

-- 4. ESP & VISUALS
AddSection("Visuals and ESP")
AddToggle("Key Item ESP", false, function(v) State.KeyESP = v; if v then task.spawn(refreshESP) else clearESP() end end)
AddToggle("Exit Door ESP", false, function(v) State.ExitESP = v; if v then task.spawn(refreshESP) else clearESP() end end)
AddToggle("Monster ESP", false, function(v) State.MonsterESP = v; if v then task.spawn(refreshESP) else clearESP() end end)
AddToggle("Player ESP", false, function(v) State.PlayerESP = v; if v then task.spawn(refreshESP) else clearESP() end end)
AddToggle("FullBright (No Darkness)", false, function(v) State.FullBright = v; applyFullBright(v) end)

-- 5. MOVEMENT
AddSection("Movement and Teleports")
AddToggle("Speed Boost", false, function(v)
    State.SpeedHack = v
    if not v then pcall(function() local h = getHumanoid(); if h then h.WalkSpeed = 16 end end) end
end)
AddSlider("WalkSpeed", 16, 120, 32, function(v)
    State.WalkSpeed = v
    if State.SpeedHack then pcall(function() local h = getHumanoid(); if h then h.WalkSpeed = v end end) end
end)
AddToggle("Infinite Jump", false, function(v) State.InfiniteJump = v end)
AddToggle("Noclip (Through Walls)", false, function(v) State.Noclip = v end)
AddToggle("Fly Mode", false, function(v) State.Fly = v; toggleFly(v) end)
AddSlider("Fly Speed", 20, 120, 50, function(v) State.FlySpeed = v end)
AddFlyButtons()
AddToggle("Anti-AFK", false, function(v) State.AntiAFK = v end)

-- 6. UI RESIZE & SCALE SETTINGS
AddSection("UI Size and Resize Settings")
AddSlider("UI Scale Percent", 60, 150, 100, function(v)
    setScale(v / 100)
end)

print("[AJIZ HUB] Scream and Run Advanced V12 Loaded Successfully.")
