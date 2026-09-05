--[[
    ========================================================================
    🌟 AJIZ HUB - MUSCLE LEGENDS (SMART AUTO REBIRTH & FARM SUITE) 🌟
    ========================================================================
    • 🔄 Smart Auto Rebirth (Auto Fulfills Requirements, Auto Push Boosts & Pet Swaps)
    • 👑 Auto Rebirth Multiplier Pet Swap (Tribal Overlord + Speedy Sally)
    • 🏋️ Fast Stat Farmer: Strength, Agility, Durability & Auto Rotate
    • ⚡ King's Gym Tool Godmode Grinding
    • 🧪 Smart Consumables & Instant Strength Topping
    • 🎁 Auto Quests, 6h Chests, Group Rewards, Fortune Wheel & Playtime Gifts
    • 🐾 Auto Crystal Hatching, Best Pet Equip, Auto Sell & Auto Evolution
    • 📊 Live Gains/Min & Rebirth Progress Tracker
    • 📱 Exact Ajiz Hub UI with Mobile Draggable "AJ" Toggle & Red Checkboxes [✓]
--]]

local function elevate()
    if setthreadidentity then pcall(setthreadidentity, 8) end
end
elevate()

local rawSpawn = task.spawn
local function spawnTask(fn)
    return rawSpawn(function()
        elevate()
        fn()
    end)
end

local RELOAD_STATE = STATE
local ENV = (getgenv and getgenv()) or _G
ENV.__MuscleLegendsFarm = ENV.__MuscleLegendsFarm or {}
local SESSION = ENV.__MuscleLegendsFarm

local GEN_HOST = game:GetService("CoreGui")
local GEN_ATTR = "__MuscleLegendsFarmGeneration"
local MY_GENERATION = (GEN_HOST:GetAttribute(GEN_ATTR) or 0) + 1
GEN_HOST:SetAttribute(GEN_ATTR, MY_GENERATION)
SESSION.generation = MY_GENERATION

local function generationAlive()
    return GEN_HOST:GetAttribute(GEN_ATTR) == MY_GENERATION
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local rEvents = ReplicatedStorage:WaitForChild("rEvents")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")
local GF = require(sharedFolder.modules.GlobalFunctions)
local Data = require(ReplicatedStorage.packages.ReplicatorClient).get("Data")

local muscleEvent = LocalPlayer:WaitForChild("muscleEvent")
local machineInUse = LocalPlayer:WaitForChild("machineInUse")
local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Strength = leaderstats:WaitForChild("Strength")
local Rebirths = leaderstats:WaitForChild("Rebirths")
local Agility = LocalPlayer:WaitForChild("Agility")
local Durability = LocalPlayer:WaitForChild("Durability")
local Gems = LocalPlayer:WaitForChild("Gems")
local Tokens = LocalPlayer:WaitForChild("Tokens")

local Remotes = {
    Machine   = rEvents:WaitForChild("machineInteractRemote"),
    Rebirth   = rEvents:WaitForChild("rebirthRemote"),
    Crystal   = rEvents:WaitForChild("openCrystalRemote"),
    Chest     = rEvents:WaitForChild("checkChestRemote"),
    Group     = rEvents:WaitForChild("groupRemote"),
    Gift      = rEvents:WaitForChild("freeGiftClaimRemote"),
    Wheel     = rEvents:WaitForChild("openFortuneWheelRemote"),
    Quests    = rEvents:WaitForChild("questsEvent"),
    EquipPet  = rEvents:WaitForChild("equipPetEvent"),
    SellPet   = rEvents:WaitForChild("sellPetEvent"),
    PetEvolve = rEvents:WaitForChild("petEvolveEvent"),
    Area      = rEvents:WaitForChild("areaTravelRemote"),
    Rejoin    = rEvents:WaitForChild("rejoinServerEvent"),
    Ultimates = rEvents:WaitForChild("ultimatesRemote"),
}

local machinesFolder = workspace:WaitForChild("machinesFolder")
local treadmillsFolder = workspace:WaitForChild("Treadmills")
local areaTeleportParts = workspace:WaitForChild("areaTeleportParts")
local kingsGymPart = areaTeleportParts:WaitForChild("beachToMuscleKing")
local crystalPrices = sharedFolder.catalogs.crystalPrices
local gameUltimates = sharedFolder.catalogs.gameUltimatesFolder
local fortuneWheel = sharedFolder.catalogs.fortuneWheelChances["Fortune Wheel"]
local questCatalog = sharedFolder.catalogs:WaitForChild("Quests")
local questsNpcs = workspace:WaitForChild("questsNpcs")

local CHEST_NAMES = {"Golden Chest", "Enchanted Chest", "Magma Chest", "Mythical Chest", "Legends Chest", "Jungle Chest"}

local TOOL_STATS = {
    Weight     = {strengthGain = true},
    Situps     = {strengthGain = true, agilityGain = true},
    Pushups    = {strengthGain = true, agilityGain = true, durabilityGain = true},
    Handstands = {strengthGain = true, durabilityGain = true},
}

local TIMED_BOOSTS = {["Protein Egg"] = "Protein Egg", ["Tropical Shake"] = "Tropical Shake"}
local BOOST_ACTIONS = {
    ["Protein Bar"]    = "proteinBar",
    ["Protein Shake"]  = "proteinShake",
    ["Protein Egg"]    = "proteinEgg",
    ["Energy Bar"]     = "energyBar",
    ["Energy Shake"]   = "energyShake",
    ["TOUGH Bar"]      = "toughBar",
    ["ULTRA Shake"]    = "ultraShake",
    ["Tropical Shake"] = "tropicalShake",
}
local INSTANT_BOOSTS = {
    ["Protein Bar"] = true, ["Protein Shake"] = true, ["TOUGH Bar"] = true,
    ["ULTRA Shake"] = true, ["Energy Bar"] = true, ["Energy Shake"] = true,
}
local SAVED_FOR_PUSH = {["ULTRA Shake"] = true, ["TOUGH Bar"] = true}

local PERK_PETS = {
    ["Swift Samurai"]   = 6000,
    ["Powercore Hound"] = 5000,
    ["Tribal Overlord"] = 4000,
    ["Titanium Hydra"]  = 3000,
    ["Speedy Sally"]    = 2000,
}

local PET_PRIORITY = {
    ["Farm speed"] = {["Swift Samurai"] = 6, ["Powercore Hound"] = 5, ["Tribal Overlord"] = 4, ["Titanium Hydra"] = 3, ["Speedy Sally"] = 2},
    ["Rebirths"]   = {["Tribal Overlord"] = 6, ["Speedy Sally"] = 5, ["Titanium Hydra"] = 4, ["Swift Samurai"] = 3, ["Powercore Hound"] = 2},
    ["Raw stats"]  = {},
}
local RARITY_ORDER = {Basic = 1, Rare = 2, Epic = 3, Unique = 4, Advanced = 5}

local ULTIMATE_PRIORITY = {
    Speed    = {"Galaxy Gains", "+5% Rep Speed", "Golden Rebirth"},
    Balanced = {"Galaxy Gains", "+5% Rep Speed", "Jungle Swift", "Muscle Mind", "Golden Rebirth"},
    Rebirth  = {"Golden Rebirth", "Galaxy Gains", "+5% Rep Speed"},
    Everything = {"Galaxy Gains", "+5% Rep Speed", "Golden Rebirth", "+1 Pet Slot", "x2 Quest Rewards", "x2 Chest Rewards", "+1 Daily Spin", "Jungle Swift", "Muscle Mind", "+10 Item Capacity", "Infernal Health", "Demon Damage"},
}

local State = {
    Running = true,
    FarmMode = "Off",
    RepDelay = 0.06,
    AutoBenchmark = false,
    BenchmarkSeconds = 12,
    BenchmarkEvery = 600,
    SourcePreference = "Auto (fastest)",
    StrengthSource = "Tools (Best for Rebirth)",
    RotateSeconds = 120,
    
    -- 🚀 Enhanced Smart Rebirth Configuration
    AutoRebirth = false,
    SmartRebirthFulfillment = true,
    AutoRebirthPetSwap = true,
    AutoRebirthBoostPush = true,
    
    AutoBoosts = false,
    SaveBigBoosts = false,
    AutoUltimates = true,
    UltimatePlan = "Rebirth",
    KeepRebirths = 0,
    AutoChests = false,
    AutoGroup = false,
    AutoGifts = false,
    AutoWheel = false,
    AutoQuests = false,
    AutoHatch = false,
    HatchCrystal = "Blue Crystal",
    KeepCurrency = 0,
    HatchDelay = 0.4,
    AutoEquipPets = false,
    PetPriority = "Farm speed",
    AutoSellPets = false,
    SellRarities = {},
    AutoDeletePets = false,
    DeletePetNames = {},
    AutoEvolvePets = false,
    AlwaysKingsGym = true,
    AntiAFK = true,
    Notify = true,
}

local Runtime = {
    Status = "Idle",
    Target = "none",
    Bench = "not run",
    FarmToken = 0,
    Reps = 0,
    Hatched = 0,
    Claimed = 0,
    Boosts = 0,
    Upgrades = 0,
    Evolved = 0,
    RebirthCount = 0,
    RebirthBusy = false,
    KingLockedUntil = 0,
    Heartbeat = 0,
    Rates = {},
    RatesStamp = 0,
    RatesRebirth = -1,
    StartClock = os.clock(),
    StartStats = {Strength = Strength.Value, Agility = Agility.Value, Durability = Durability.Value},
    Blacklist = {},
}

local char, hum, hrp
local restartFarm

local function gf(name, ...)
    local packed = table.pack(pcall(GF[name], ...))
    elevate()
    if packed[1] then return table.unpack(packed, 2, packed.n) end
    return nil
end

local function invoke(remote, ...)
    local packed = table.pack(pcall(remote.InvokeServer, remote, ...))
    elevate()
    if packed[1] then return table.unpack(packed, 2, packed.n) end
    return nil
end

local function fire(remote, ...)
    pcall(remote.FireServer, remote, ...)
    elevate()
end

local function dataIndex(...)
    local ok, v = pcall(function(...) return Data:TryIndex({...}) end, ...)
    elevate()
    if ok then return v end
    return nil
end

local function running()
    if not State.Running then return false end
    if not generationAlive() then return false end
    if RELOAD_STATE and RELOAD_STATE.alive and not RELOAD_STATE.alive() then return false end
    return true
end

local function farming(token)
    return running() and State.FarmMode ~= "Off" and token == Runtime.FarmToken
end

local function notify(title, message, dur)
    if not State.Notify then return end
    elevate()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[AJIZ] " .. tostring(title),
            Text = tostring(message),
            Duration = dur or 3
        })
    end)
end

local function bindCharacter(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10)
    hrp = c:WaitForChild("HumanoidRootPart", 10)
end

if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(function(c)
    bindCharacter(c)
    Runtime.Blacklist = {}
    Runtime.Heartbeat = os.clock()
    if State.FarmMode ~= "Off" and not Runtime.RebirthBusy and restartFarm then restartFarm() end
end)

local function alive()
    return char and char.Parent and hum and hrp and hrp.Parent and hum.Health > 0
end

local function short(n)
    local s = gf("shortenNumber", n)
    if s then return s end
    return tostring(n)
end

local function statValue(gainKey)
    if gainKey == "strengthGain" then return Strength.Value end
    if gainKey == "agilityGain" then return Agility.Value end
    return Durability.Value
end

local function repsCounter()
    local quests = LocalPlayer:FindFirstChild("Quests")
    if not quests then return nil end
    for _, group in ipairs(quests:GetChildren()) do
        for _, quest in ipairs(group:GetChildren()) do
            local req = quest:FindFirstChild("requirements")
            local reps = req and req:FindFirstChild("Reps")
            local progress = reps and reps:FindFirstChild("progress")
            if progress then return progress end
        end
    end
    return nil
end

local function beat()
    Runtime.Heartbeat = os.clock()
end

local function beatWait(seconds)
    local t0 = os.clock()
    while os.clock() - t0 < seconds do
        beat()
        task.wait(0.2)
    end
end

local function anchorAt(cf)
    if not alive() then return end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

local function isMounted()
    return char and (char:GetAttribute("MachineStandingMount") == true
        or char:GetAttribute("MachineScaleFrozen") == true
        or (hum and hum.SeatPart ~= nil))
end

local function unseat()
    if not hum then return end
    pcall(function() hum.Sit = false end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    if hum.SeatPart then
        for _, w in ipairs(hum.SeatPart:GetChildren()) do
            if w:IsA("Weld") and w.Name == "SeatWeld" then pcall(function() w:Destroy() end) end
        end
    end
end

local function leaveMachine()
    invoke(Remotes.Machine, "leaveMachine")
    unseat()
    local t = os.clock()
    while isMounted() and os.clock() - t < 4 do
        beat()
        unseat()
        task.wait(0.15)
    end
    task.wait(0.15)
    beat()
    return not isMounted()
end

local function blacklisted(inst)
    local until_ = Runtime.Blacklist[inst]
    return until_ ~= nil and until_ > os.clock()
end

local function meetsRequirements(inst)
    local req = inst:FindFirstChild("requirements")
    if not req then return true end
    return gf("checkIfPlayerCanUseMachine", LocalPlayer, req) == true
end

local function findTool(name)
    return LocalPlayer.Backpack:FindFirstChild(name) or (char and char:FindFirstChild(name))
end

local function toolUsable(name)
    local tool = findTool(name)
    if not tool then return false end
    local amount = tool:FindFirstChild("requiredAmount")
    local kind = tool:FindFirstChild("requiredType")
    if not amount or not kind then return true end
    local have = Strength.Value
    if kind.Value == "Agility" then have = Agility.Value
    elseif kind.Value == "Durability" then have = Durability.Value end
    return have >= amount.Value
end

local function equipTool(name)
    local tool = findTool(name)
    if not tool or not hum then return false end
    pcall(function() hum:EquipTool(tool) end)
    return true
end

local function heldTool()
    local t = char and char:FindFirstChildOfClass("Tool")
    return t and t.Name or nil
end

local function machineSources(gainKey)
    local list = {}
    for _, m in ipairs(machinesFolder:GetChildren()) do
        local gain = m:FindFirstChild(gainKey)
        local seat = m.PrimaryPart
        local repTime = m:FindFirstChild("repTime")
        local kingLocked = m:GetAttribute("IsKingMachine") == true
            and (Runtime.KingLockedUntil or 0) > os.clock()
        if gain and seat and seat:IsA("Seat") and not kingLocked and not blacklisted(m) and meetsRequirements(m) then
            local rt = repTime and repTime.Value or 1
            if rt <= 0 then rt = 1 end
            table.insert(list, {
                kind = "machine", key = "M:" .. m.Name, model = m, seat = seat,
                gain = gain.Value, repTime = rt, estimate = gain.Value / rt,
                label = m.Name .. " (+" .. gain.Value .. "/" .. rt .. "s)",
            })
        end
    end
    table.sort(list, function(a, b) return a.estimate > b.estimate end)
    return list
end

local function toolSources(gainKey)
    local list = {}
    for name, stats in pairs(TOOL_STATS) do
        if stats[gainKey] and toolUsable(name) then
            local tool = findTool(name)
            local gain = tool and tool:FindFirstChild(gainKey)
            local repTime = tool and tool:FindFirstChild("repTime")
            local rt = repTime and repTime.Value or 1
            if rt <= 0 then rt = 1 end
            table.insert(list, {
                kind = "tool", key = "T:" .. name, toolName = name,
                gain = gain and gain.Value or 0, repTime = rt,
                estimate = (gain and gain.Value or 0) / rt,
                label = name .. " tool",
            })
        end
    end
    table.sort(list, function(a, b) return a.estimate > b.estimate end)
    return list
end

local function candidateSources(gainKey)
    local machines = machineSources(gainKey)
    local tools = toolSources(gainKey)
    if #machines == 0 and #tools == 0 and next(Runtime.Blacklist) then
        Runtime.Blacklist = {}
        machines = machineSources(gainKey)
        tools = toolSources(gainKey)
    end
    local out = {}
    local preference = gainKey == "strengthGain" and State.StrengthSource or State.SourcePreference
    local toolsOnly = preference == "Tools only" or preference == "Tools (Hotbar)" or preference == "Tools (Best for Rebirth)"
    local machinesOnly = preference == "Machines only" or preference == "Machines"
    if not toolsOnly then
        for i = 1, math.min(2, #machines) do table.insert(out, machines[i]) end
    end
    if not machinesOnly then
        for i = 1, math.min(2, #tools) do table.insert(out, tools[i]) end
    end
    if #out == 0 then
        for i = 1, math.min(1, #machines) do table.insert(out, machines[i]) end
        for i = 1, math.min(1, #tools) do table.insert(out, tools[i]) end
    end
    return out
end

local function engageMachine(source)
    if not alive() then return false end
    if isMounted() and not leaveMachine() then
        Runtime.Status = "Stuck on a machine, retrying"
        task.wait(0.1)
        return false
    end
    for _ = 1, 3 do
        if not alive() then return false end
        beat()
        anchorAt(source.seat.CFrame * CFrame.new(0, 5, 0))
        task.wait(0.05)
    end
    local res, reason = invoke(Remotes.Machine, "useMachine", source.seat)
    if res ~= true then
        if reason == "isKingMachine" or source.model:GetAttribute("IsKingMachine") == true then
            Runtime.KingLockedUntil = os.clock() + 120
        else
            Runtime.Blacklist[source.model] = os.clock() + 180
        end
        return false
    end
    local deadline = os.clock() + 0.6
    while machineInUse.Value ~= source.seat and os.clock() < deadline do
        beat()
        task.wait(0.03)
    end
    return machineInUse.Value == source.seat
end

local function engageTool(source)
    if isMounted() and not leaveMachine() then
        Runtime.Status = "Stuck on a machine, retrying"
        task.wait(0.5)
        return false
    end
    beat()
    equipTool(source.toolName)
    beatWait(0.5)
    return heldTool() == source.toolName
end

local function engage(source)
    if source.kind == "machine" then return engageMachine(source) end
    return engageTool(source)
end

local function repOnce(source)
    if source.kind == "machine" then
        muscleEvent:FireServer("rep", source.seat)
    else
        muscleEvent:FireServer("rep")
    end
    Runtime.Reps = Runtime.Reps + 1
end

local function sourceHealthy(source)
    if source.kind == "machine" then return machineInUse.Value == source.seat end
    return heldTool() == source.toolName and not isMounted()
end

local function measureSource(source, gainKey, token)
    if not engage(source) then return -1 end
    local counter = repsCounter()
    local prime = os.clock()
    while os.clock() - prime < 2 and farming(token) do
        beat()
        repOnce(source)
        task.wait(State.RepDelay)
    end
    local before = statValue(gainKey)
    local beforeReps = counter and counter.Value or 0
    local seconds = math.max(6, State.BenchmarkSeconds)
    local t0 = os.clock()
    while os.clock() - t0 < seconds and farming(token) do
        if not sourceHealthy(source) then break end
        beat()
        repOnce(source)
        task.wait(State.RepDelay)
    end
    if not farming(token) then return -1 end
    local window = os.clock() - t0
    beatWait(8)
    local delta = statValue(gainKey) - before
    local landed = counter and (counter.Value - beforeReps) or nil
    if delta <= 0 and (landed == nil or landed <= 0) then return -1 end
    return delta / window
end

local function runBenchmark(gainKey, token, list, onlyMissing)
    local todo = {}
    for _, source in ipairs(list) do
        if not onlyMissing or Runtime.Rates[source.key] == nil then table.insert(todo, source) end
    end
    if #todo == 0 then return end
    for _, source in ipairs(todo) do
        if not farming(token) then return end
        Runtime.Status = "Benchmarking " .. source.label
        Runtime.Rates[source.key] = measureSource(source, gainKey, token)
    end
    if not onlyMissing then Runtime.RatesStamp = os.clock() end
    local parts = {}
    for _, source in ipairs(list) do
        local r = Runtime.Rates[source.key]
        parts[#parts + 1] = ("%s %s"):format(source.label, r and (r < 0 and "locked" or string.format("%.0f/s", r)) or "?")
    end
    Runtime.Bench = table.concat(parts, "  |  ")
end

local function pickSource(gainKey, token)
    local list = candidateSources(gainKey)
    if #list == 0 then return nil end
    if State.AutoBenchmark and gainKey ~= "strengthGain" then
        local full = os.clock() - Runtime.RatesStamp > State.BenchmarkEvery
        if full then Runtime.Rates = {} end
        runBenchmark(gainKey, token, list, not full)
        if token ~= Runtime.FarmToken then return nil end
    end
    local best, bestScore
    for _, source in ipairs(list) do
        local score = Runtime.Rates[source.key]
        if score == nil then score = source.estimate end
        if not bestScore or score > bestScore then best, bestScore = source, score end
    end
    if bestScore and bestScore < 0 then
        Runtime.Blacklist = {}
        Runtime.Rates = {}
        Runtime.Bench = "all sources failed, retrying by estimate"
        best, bestScore = nil, nil
        for _, source in ipairs(candidateSources(gainKey)) do
            if not bestScore or source.estimate > bestScore then best, bestScore = source, source.estimate end
        end
    end
    return best
end

local function rebirthTarget()
    local need = gf("calculateRequiredRebirthStrength", Rebirths.Value, LocalPlayer)
    if type(need) == "number" then return need end
    return math.huge
end

local function canRebirth()
    if char and char:GetAttribute("IsRebirthing") == true then return false end
    if LocalPlayer:GetAttribute("LastMapCFrame") ~= nil then return false end
    return Strength.Value >= rebirthTarget()
end

local function boostActive(name)
    local folder = LocalPlayer:FindFirstChild("boostTimersFolder")
    local entry = folder and folder:FindFirstChild(name)
    return entry ~= nil and entry.Value > 0
end

local function boostAction(name)
    local known = BOOST_ACTIONS[name]
    if known then return known end
    local parts = {}
    for word in tostring(name):gmatch("%S+") do
        if #parts == 0 then
            parts[1] = word:lower()
        else
            parts[#parts + 1] = word:sub(1, 1):upper() .. word:sub(2):lower()
        end
    end
    return table.concat(parts)
end

local function useConsumable(tool)
    if not hum or not char or not tool or not tool.Parent then return false end
    beat()
    local consumables = LocalPlayer:FindFirstChild("consumablesFolder")
    local before = consumables and #consumables:GetChildren() or 0
    pcall(function() hum:EquipTool(tool) end)
    local t = os.clock()
    while char:FindFirstChildOfClass("Tool") ~= tool and os.clock() - t < 1.5 do
        beat()
        task.wait(0.1)
    end
    if char:FindFirstChildOfClass("Tool") ~= tool then return false end
    fire(muscleEvent, boostAction(tool.Name), tool)
    local t2 = os.clock()
    local function consumed()
        if tool.Parent == nil then return true end
        return consumables ~= nil and #consumables:GetChildren() < before
    end
    while not consumed() and os.clock() - t2 < 2.5 do
        beat()
        task.wait(0.15)
    end
    if not consumed() then return false end
    Runtime.Boosts = Runtime.Boosts + 1
    return true
end

local function useBoosts(forPush)
    if isMounted() then leaveMachine() end
    local used, failed = 0, 0
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if not running() then break end
        if tool.Parent and TIMED_BOOSTS[tool.Name] and not boostActive(tool.Name) then
            if useConsumable(tool) then
                used = used + 1
                notify("Boost", "Activated " .. tool.Name, 2.5)
            else
                failed = failed + 1
            end
        end
    end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if not running() then break end
        if tool.Parent and INSTANT_BOOSTS[tool.Name] then
            local hold = State.SaveBigBoosts and SAVED_FOR_PUSH[tool.Name] and not forPush
            if not hold then
                if useConsumable(tool) then used = used + 1 else failed = failed + 1 end
            end
        end
    end
    if hum then pcall(function() hum:UnequipTools() end) end
    if used > 0 then
        notify("Boosts", used .. " consumable(s) used", 2.5)
    end
    return used, failed
end

local function upgradeUltimates()
    local plan = ULTIMATE_PRIORITY[State.UltimatePlan] or ULTIMATE_PRIORITY.Rebirth
    local done = 0
    for _, name in ipairs(plan) do
        if not running() then break end
        local entry = gameUltimates:FindFirstChild(name)
        if entry then
            local maxUp = entry:FindFirstChild("maxUpgrades")
            local level = dataIndex("ultimatesFolder", name) or 0
            if type(level) ~= "number" then level = 0 end
            if not maxUp or level < maxUp.Value then
                local cost = gf("calculateUltimateRebirthCost", entry, level)
                if type(cost) == "number" and Rebirths.Value - cost >= State.KeepRebirths then
                    if invoke(Remotes.Ultimates, "upgradeUltimate", name) == true then
                        done = done + 1
                        Runtime.Upgrades = Runtime.Upgrades + 1
                        notify("Ultimate", name .. " -> level " .. (level + 1), 2.5)
                        task.wait(0.4)
                    end
                end
            end
        end
    end
    return done
end

local function petPerkStat(pet, name)
    local perks = pet:FindFirstChild("perksFolder")
    local v = perks and perks:FindFirstChild(name)
    if v then return v.Value end
    local direct = pet:FindFirstChild(name)
    return direct and direct.Value or 0
end

local function allPetsCustom(priorityKey)
    local list = {}
    local folder = LocalPlayer:FindFirstChild("petsFolder")
    if not folder then return list end
    local weights = PET_PRIORITY[priorityKey or State.PetPriority] or PET_PRIORITY["Farm speed"]
    local statKey = "strength"
    if State.FarmMode == "Agility" then statKey = "agility"
    elseif State.FarmMode == "Durability" then statKey = "durability" end
    for _, rarityFolder in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarityFolder:GetChildren()) do
            local levelValue = pet:FindFirstChild("level")
            table.insert(list, {
                pet = pet,
                rarity = rarityFolder.Name,
                perk = weights[pet.Name] or 0,
                keep = PERK_PETS[pet.Name] ~= nil,
                rank = RARITY_ORDER[rarityFolder.Name] or 0,
                power = petPerkStat(pet, statKey),
                level = levelValue and levelValue.Value or 1,
            })
        end
    end
    table.sort(list, function(a, b)
        if a.perk ~= b.perk then return a.perk > b.perk end
        if a.power ~= b.power then return a.power > b.power end
        if a.rank ~= b.rank then return a.rank > b.rank end
        return a.level > b.level
    end)
    return list
end

local function equippedSet()
    local set, slots = {}, 0
    local folder = LocalPlayer:FindFirstChild("equippedPets")
    if not folder then return set, 0 end
    for _, slot in ipairs(folder:GetChildren()) do
        slots = slots + 1
        local ref = slot:FindFirstChild("petReference")
        if ref and ref.Value then set[ref.Value] = true end
    end
    return set, slots
end

local function equipBestPetsCustom(priorityKey)
    local list = allPetsCustom(priorityKey)
    if #list == 0 then return end

    local rankOf, allowed = {}, {}
    for i, entry in ipairs(list) do
        rankOf[entry.pet] = i
        if gf("checkIfPlayerHasEnoughStatsForPet", LocalPlayer, entry.pet) ~= false then
            allowed[#allowed + 1] = entry.pet
        end
    end
    if #allowed == 0 then return end

    local equipped, slots = equippedSet()
    if slots == 0 then return end

    for _, pet in ipairs(allowed) do
        equipped = equippedSet()
        local filled = 0
        for _ in pairs(equipped) do filled = filled + 1 end
        if filled >= slots then break end
        if not equipped[pet] then
            fire(Remotes.EquipPet, "equipPet", pet)
            task.wait(0.2)
            if not equippedSet()[pet] then break end
        end
    end

    for _ = 1, 8 do
        equipped = equippedSet()
        local best
        for _, pet in ipairs(allowed) do
            if not equipped[pet] then best = pet break end
        end
        if not best then break end
        local worst, worstRank
        for pet in pairs(equipped) do
            local r = rankOf[pet] or math.huge
            if not worstRank or r > worstRank then worst, worstRank = pet, r end
        end
        if not worst or (rankOf[best] or math.huge) >= worstRank then break end
        fire(Remotes.EquipPet, "unequipPet", worst)
        task.wait(0.25)
        fire(Remotes.EquipPet, "equipPet", best)
        task.wait(0.25)
        if not equippedSet()[best] then break end
    end
end

local function doRebirth()
    -- Smart Pre-Rebirth Optimization: Auto Equip Rebirth Pets for extra rebirths & discounts
    if State.AutoRebirthPetSwap then
        pcall(function() equipBestPetsCustom("Rebirths") end)
    end
    
    if isMounted() then leaveMachine() end
    local beforeStrength = Strength.Value
    local res = invoke(Remotes.Rebirth, "rebirthRequest")
    if res == true then
        Runtime.RebirthCount = Runtime.RebirthCount + 1
        notify("Rebirth", "Rebirth " .. tostring(Rebirths.Value) .. " Complete!", 3)
    end
    local t = os.clock()
    while res == true and os.clock() - t < 8 do
        beat()
        if Strength.Value < beforeStrength and alive() and char:GetAttribute("IsRebirthing") ~= true then break end
        task.wait(0.03)
    end
    Runtime.Blacklist = {}
    
    -- Auto Upgrade Golden Rebirth & Ultimates
    if State.AutoUltimates then pcall(upgradeUltimates) end
    
    -- Smart Post-Rebirth Optimization: Auto Swap back to Farm Speed/Strength Pets
    if State.AutoRebirthPetSwap then
        pcall(function() equipBestPetsCustom("Farm speed") end)
    end
    
    return res == true
end

local function rebirthChain(maxCount, spendBoosts)
    maxCount = maxCount or 50
    local gained = 0
    for _ = 1, maxCount do
        if not running() then break end
        if not canRebirth() and spendBoosts then
            local before = Strength.Value
            Runtime.Status = "Auto pushing boost for rebirth"
            useBoosts(true)
            if Strength.Value <= before then break end
        end
        if not canRebirth() then break end
        Runtime.Status = "Rebirthing (" .. (gained + 1) .. ")"
        if not doRebirth() then break end
        gained = gained + 1
        task.wait()
    end
    if gained > 1 then
        notify("Rebirth Chain", gained .. " rebirths chained!", 4)
    end
    return gained
end

local function requestAutoRebirth()
    if not running() or not State.AutoRebirth or Runtime.RebirthBusy then return false end
    
    local target = rebirthTarget()
    
    -- Auto Requirement Fulfillment: If close to target, auto pop instant boosts
    if State.AutoRebirthBoostPush and Strength.Value < target and Strength.Value >= target * 0.85 then
        useBoosts(true)
    end
    
    if not canRebirth() then return false end
    
    Runtime.RebirthBusy = true
    Runtime.FarmToken = Runtime.FarmToken + 1
    spawnTask(function()
        local gained = rebirthChain(50, false)
        Runtime.RebirthBusy = false
        if State.FarmMode ~= "Off" and restartFarm then restartFarm() end
    end)
    return true
end

Strength.Changed:Connect(function()
    if running() and State.AutoRebirth then requestAutoRebirth() end
end)

spawnTask(function()
    while running() do
        if State.AutoRebirth then requestAutoRebirth() end
        task.wait(0.25)
    end
end)

local function resolveMode()
    -- If AutoRebirth is on and we need strength, ensure strength is prioritized
    if State.AutoRebirth and State.SmartRebirthFulfillment and Strength.Value < rebirthTarget() then
        return "Strength"
    end
    if State.FarmMode ~= "Rotate" then return State.FarmMode end
    local order = {"Strength", "Agility", "Durability"}
    local span = math.max(State.RotateSeconds, 15)
    return order[(math.floor(os.clock() / span) % #order) + 1]
end

local GAIN_KEY = {Strength = "strengthGain", Agility = "agilityGain", Durability = "durabilityGain"}

local function bestTreadmill()
    local best
    for _, t in ipairs(treadmillsFolder:GetChildren()) do
        local gain = t:FindFirstChild("agilityAmount")
        local part = t:FindFirstChild("treadmillPart")
        if gain and part and not blacklisted(t) and meetsRequirements(t) then
            if not best or gain.Value > best.gain then
                best = {model = t, part = part, gain = gain.Value}
            end
        end
    end
    return best
end

local function bestRock()
    local best
    for _, m in ipairs(machinesFolder:GetChildren()) do
        local rock = m:FindFirstChild("Rock")
        local gain = m:FindFirstChild("durabilityGain")
        local need = m:FindFirstChild("neededDurability")
        if rock and gain and not blacklisted(m) and Durability.Value >= (need and need.Value or 0) then
            if not best or gain.Value > best.gain then
                best = {model = m, rock = rock, gain = gain.Value, estimate = gain.Value / 1.4}
            end
        end
    end
    return best
end

local function farmTreadmill(token, mode)
    local entry = bestTreadmill()
    if not entry then return false end
    leaveMachine()
    local part = entry.part
    Runtime.Target = entry.model.Name .. " treadmill (+" .. entry.gain .. ")"
    Runtime.Status = "Running on treadmill"
    local nextScan = os.clock() + 15
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        Runtime.Heartbeat = os.clock()
        anchorAt(part.CFrame * CFrame.new(0, part.Size.Y / 2 + hum.HipHeight + hrp.Size.Y / 2 + 0.4, 0))
        if os.clock() > nextScan then
            nextScan = os.clock() + 15
            local better = bestTreadmill()
            if better and better.model ~= entry.model and better.gain > entry.gain then return true end
        end
        task.wait(0.1)
    end
    return true
end

local function farmRock(token, mode)
    local entry = bestRock()
    if not entry then return false end
    leaveMachine()
    local rock = entry.rock
    local reach = math.max(rock.Size.X, rock.Size.Z) / 2 - 4
    local stand = CFrame.new(rock.Position - Vector3.new(0, 0, reach), rock.Position)
    equipTool("Punch")
    Runtime.Target = entry.model.Name .. " (+" .. entry.gain .. " per punch)"
    Runtime.Status = "Punching"
    local flip = false
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        Runtime.Heartbeat = os.clock()
        anchorAt(stand)
        flip = not flip
        muscleEvent:FireServer("punch", flip and "rightHand" or "leftHand")
        Runtime.Reps = Runtime.Reps + 1
        task.wait(0.12)
    end
    return true
end

local function farmStat(token, mode)
    if not farming(token) then return true end
    local gainKey = GAIN_KEY[mode]
    local source = pickSource(gainKey, token)
    if not farming(token) then return true end

    if mode == "Agility" then
        local treadmill = bestTreadmill()
        local treadRate = treadmill and (treadmill.gain / 3.3) or 0
        local sourceRate = source and (Runtime.Rates[source.key] or source.estimate) or 0
        if treadmill and treadRate > sourceRate and State.SourcePreference ~= "Tools only" then
            return farmTreadmill(token, mode)
        end
    end

    if mode == "Durability" and State.SourcePreference == "Rocks only" then
        return farmRock(token, mode)
    end

    if not source then
        if mode == "Durability" and farmRock(token, mode) then return true end
        Runtime.Status = "No usable source for " .. mode
        Runtime.Target = "none"
        task.wait(2)
        return true
    end

    if not farming(token) then return true end
    if not engage(source) then
        Runtime.Status = "Locked, trying next: " .. source.label
        Runtime.Target = "switching"
        task.wait(0.2)
        return true
    end

    local rate = Runtime.Rates[source.key]
    Runtime.Target = source.label .. (rate and (" ~ " .. string.format("%.0f", rate) .. "/s") or "")
    Runtime.Status = (source.kind == "machine") and "Lifting" or "Exercising"

    local chore = os.clock() + 90
    while farming(token) and resolveMode() == mode do
        if not alive() then return true end
        if not sourceHealthy(source) then return true end
        Runtime.Heartbeat = os.clock()
        repOnce(source)
        if requestAutoRebirth() then
            return true
        end
        if os.clock() > chore then return true end
        task.wait(State.RepDelay)
    end
    return true
end

local function teleportToKingsGym()
    if not alive() or not kingsGymPart then return false end
    if (hrp.Position - kingsGymPart.Position).Magnitude < 500 then return true end
    if isMounted() then leaveMachine() end
    for _ = 1, 3 do
        if not alive() then return false end
        anchorAt(kingsGymPart.CFrame * CFrame.new(0, 6, 0))
        task.wait(0.05)
    end
    return (hrp.Position - kingsGymPart.Position).Magnitude < 500
end

local function startFarm()
    Runtime.FarmToken = Runtime.FarmToken + 1
    local token = Runtime.FarmToken
    Runtime.Heartbeat = os.clock()
    spawnTask(function()
        local nextBoost, nextUlt = 0, 0
        while farming(token) do
            elevate()
            Runtime.Heartbeat = os.clock()
            if State.AutoBoosts and os.clock() > nextBoost then
                nextBoost = os.clock() + 45
                pcall(useBoosts, false)
            end
            if State.AutoUltimates and os.clock() > nextUlt then
                nextUlt = os.clock() + 60
                pcall(upgradeUltimates)
            end
            local mode = resolveMode()
            if not alive() then
                Runtime.Status = "Waiting for character"
                task.wait(1)
            elseif GAIN_KEY[mode] then
                farmStat(token, mode)
            else
                task.wait(0.5)
            end
            task.wait(0.05)
        end
        Runtime.Exited = token
        if token == Runtime.FarmToken then
            Runtime.Status = "Idle"
            Runtime.Target = "none"
            pcall(leaveMachine)
        end
    end)
end

restartFarm = startFarm

local function stopFarm(reason)
    local old = Runtime.FarmToken
    State.FarmMode = "Off"
    Runtime.FarmToken = old + 1
    Runtime.Target = "none"
    Runtime.Status = "Stopping"
    spawnTask(function()
        local t = os.clock()
        while Runtime.Exited ~= old and os.clock() - t < 6 do task.wait(0.1) end
        leaveMachine()
        local t2 = os.clock()
        while isMounted() and os.clock() - t2 < 3 do
            leaveMachine()
            task.wait(0.2)
        end
        if State.FarmMode == "Off" then
            Runtime.Status = reason or "Idle"
            Runtime.Target = "none"
        end
    end)
end

spawnTask(function()
    while running() do
        elevate()
        if State.FarmMode ~= "Off" and os.clock() - (Runtime.Heartbeat or 0) > 25 then
            Runtime.Status = "Watchdog restart"
            startFarm()
        end
        task.wait(5)
    end
end)

local function claimChests()
    for _, name in ipairs(CHEST_NAMES) do
        if invoke(Remotes.Chest, name) == true then
            Runtime.Claimed = Runtime.Claimed + 1
            notify("Chest", name .. " claimed", 2)
        end
        task.wait(0.25)
    end
end

local function claimGroup()
    if invoke(Remotes.Group, "groupRewards") == true then
        Runtime.Claimed = Runtime.Claimed + 1
        notify("Group Reward", "Group reward claimed", 2.5)
    end
end

local function claimGifts()
    for n = 1, 8 do
        if invoke(Remotes.Gift, "claimGift", n) == true then
            Runtime.Claimed = Runtime.Claimed + 1
            notify("Free Gift", "Gift " .. n .. " claimed", 2)
        end
        task.wait(0.25)
    end
end

local function spinWheel()
    local spins = dataIndex("freeWheelSpins")
    if type(spins) ~= "number" then return end
    while spins > 0 do
        local res = invoke(Remotes.Wheel, "openFortuneWheel", fortuneWheel)
        if type(res) ~= "table" then break end
        Runtime.Claimed = Runtime.Claimed + 1
        notify("Fortune Wheel", tostring(res.name) .. " (" .. tostring(res.rarity) .. ")", 2.5)
        spins = spins - 1
        task.wait(1)
    end
end

local function collectQuests()
    local root = LocalPlayer:FindFirstChild("Quests")
    if not root then return end

    for _, quest in ipairs(root:GetDescendants()) do
        if quest:IsA("Folder") and quest:FindFirstChild("requirements") then
            if gf("checkForCompleteQuest", quest) == true then
                fire(Remotes.Quests, "collectQuest", quest)
                Runtime.Claimed = Runtime.Claimed + 1
                notify("Quest", quest.Name .. " collected", 2)
                task.wait(0.4)
            end
        end
    end
end

local questAcceptCooldown = {}

local function nextNpcQuest(questLine)
    local root = LocalPlayer:FindFirstChild("Quests")
    local story = root and root:FindFirstChild("Story Quests")
    local completed = root and root:FindFirstChild("completedQuests")
    local catalogQuests = questLine and questLine:FindFirstChild("Quests")
    if not root or not story or not completed or not catalogQuests then return nil end

    if story:FindFirstChild(questLine.Name) then return nil end

    local finished = completed:FindFirstChild(questLine.Name)
    local numbers = {}
    for _, quest in ipairs(catalogQuests:GetChildren()) do
        local number = tonumber(quest.Name)
        if number then table.insert(numbers, number) end
    end
    table.sort(numbers)

    if not finished then return catalogQuests:FindFirstChild("1") end
    for _, number in ipairs(numbers) do
        local name = tostring(number)
        if not finished:FindFirstChild(name) then
            return catalogQuests:FindFirstChild(name)
        end
    end

    if questLine.Name == "Industrial Gains" then
        local industrial = root:FindFirstChild("Industrial Daily")
        if industrial and #industrial:GetChildren() > 0 then return nil end
        local lastDaily = dataIndex("quests", "industrialDailyQuestTime")
        if type(lastDaily) == "number" and os.time() - lastDaily < 86400 then return nil end
        local daily = questCatalog:FindFirstChild("Industrial Daily")
        local today = daily and daily:FindFirstChild(os.date("!%A"))
        return today and today:GetChildren()[1] or nil
    end
    return nil
end

local function acceptNpcQuests()
    for _, npc in ipairs(questsNpcs:GetChildren()) do
        local link = npc:FindFirstChild("questLink")
        local questLine = link and link:IsA("ObjectValue") and link.Value or nil
        local required = questLine and questLine:FindFirstChild("Rebirths")
        if questLine and (not required or required.Value <= Rebirths.Value) then
            local quest = nextNpcQuest(questLine)
            local lastRequest = quest and questAcceptCooldown[quest] or 0
            if quest and os.clock() - lastRequest >= 8 then
                questAcceptCooldown[quest] = os.clock()
                local action = quest.Parent and quest.Parent.Parent and quest.Parent.Parent.Name == "Industrial Daily"
                    and "createNewIndustrialDaily" or "createNewStoryQuest"
                fire(Remotes.Quests, action, quest)
                notify("Quest", npc.Name .. " quest accepted", 2)
                task.wait(0.4)
            end
        end
    end
end

local function updateNpcQuests()
    collectQuests()
    task.wait(0.6)
    acceptNpcQuests()
end

local function crystalCost(name)
    local entry = crystalPrices:FindFirstChild(name)
    if not entry then return nil end
    local price = entry:FindFirstChild("price")
    local kind = entry:FindFirstChild("priceType")
    return price and price.Value or 0, kind and kind.Value or "Gems"
end

local function currencyValue(kind)
    if kind == "Tokens" then return Tokens.Value end
    return Gems.Value
end

local function hatchOnce(name)
    local price, kind = crystalCost(name)
    if not price then return false, "unknown crystal" end
    if currencyValue(kind) - price < State.KeepCurrency then return false, "saving " .. kind end
    local pet, rarity = invoke(Remotes.Crystal, "openCrystal", name)
    if type(pet) == "string" then
        Runtime.Hatched = Runtime.Hatched + 1
        return true, pet .. " (" .. tostring(rarity) .. ")"
    end
    return false, "denied"
end

local function inventoryPetNames()
    local names, seen = {}, {}
    local folder = LocalPlayer:FindFirstChild("petsFolder")
    if not folder then return names end
    for _, rarityFolder in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarityFolder:GetChildren()) do
            if not seen[pet.Name] then
                seen[pet.Name] = true
                names[#names + 1] = pet.Name
            end
        end
    end
    table.sort(names)
    return names
end

local function selectedName(selection, name)
    if type(selection) ~= "table" then return false end
    if selection[name] == true then return true end
    for _, value in pairs(selection) do
        if value == name then return true end
    end
    return false
end

local function sellJunkPets()
    local selected = State.SellRarities
    if type(selected) ~= "table" then return end
    local any = false
    for _, v in pairs(selected) do if v then any = true break end end
    if not any then return end
    local equipped = equippedSet()
    for _, entry in ipairs(allPetsCustom()) do
        if selected[entry.rarity] and not entry.keep and not equipped[entry.pet] then
            fire(Remotes.SellPet, "sellPet", entry.pet)
            task.wait(0.2)
        end
    end
end

local function deleteSelectedPets()
    local selected = State.DeletePetNames
    if type(selected) ~= "table" then return 0 end
    local equipped = equippedSet()
    local deleted = 0
    for _, entry in ipairs(allPetsCustom()) do
        if selectedName(selected, entry.pet.Name)
            and not entry.keep
            and not equipped[entry.pet] then
            fire(Remotes.SellPet, "sellPet", entry.pet)
            deleted = deleted + 1
            task.wait(0.2)
        end
    end
    return deleted
end

local function unevolvedPetCounts()
    local counts = {}
    local folder = LocalPlayer:FindFirstChild("petsFolder")
    if not folder then return counts end
    for _, rarityFolder in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarityFolder:GetChildren()) do
            if pet:IsA("StringValue") and pet:FindFirstChild("evolved") == nil then
                counts[pet.Name] = (counts[pet.Name] or 0) + 1
            end
        end
    end
    return counts
end

local function evolveReadyPets()
    local evolved = 0
    local counts = unevolvedPetCounts()
    local names = {}
    for name, count in pairs(counts) do
        if count >= 5 then names[#names + 1] = name end
    end
    table.sort(names)

    for _, name in ipairs(names) do
        local count = counts[name] or 0
        while count >= 5 and running() do
            fire(Remotes.PetEvolve, "evolvePet", name)
            task.wait(0.8)
            local after = unevolvedPetCounts()[name] or 0
            if after >= count then break end
            evolved = evolved + 1
            Runtime.Evolved = Runtime.Evolved + 1
            count = after
        end
    end
    return evolved
end

spawnTask(function()
    local nextChest, nextGroup, nextGift, nextWheel, nextQuest = 0, 0, 0, 0, 0
    while running() do
        elevate()
        local now = os.clock()
        if State.AutoChests and now > nextChest then nextChest = now + 90 pcall(claimChests) end
        if State.AutoGroup and now > nextGroup then nextGroup = now + 120 pcall(claimGroup) end
        if State.AutoGifts and now > nextGift then nextGift = now + 60 pcall(claimGifts) end
        if State.AutoWheel and now > nextWheel then nextWheel = now + 60 pcall(spinWheel) end
        if State.AutoQuests and now > nextQuest then nextQuest = now + 10 pcall(updateNpcQuests) end
        task.wait(2)
    end
end)

spawnTask(function()
    local nextPets = 0
    while running() do
        elevate()
        if State.AutoHatch then
            local ok = hatchOnce(State.HatchCrystal)
            task.wait(ok and State.HatchDelay or 3)
        else
            task.wait(1)
        end
        if (State.AutoEquipPets or State.AutoSellPets or State.AutoDeletePets or State.AutoEvolvePets) and os.clock() > nextPets then
            nextPets = os.clock() + 15
            if State.AutoSellPets then pcall(sellJunkPets) end
            if State.AutoDeletePets then pcall(deleteSelectedPets) end
            if State.AutoEvolvePets then pcall(evolveReadyPets) end
            if State.AutoEquipPets then pcall(function() equipBestPetsCustom() end) end
        end
    end
end)

spawnTask(function()
    while running() do
        elevate()
        if State.AlwaysKingsGym
            and State.FarmMode == "Strength"
            and (State.StrengthSource == "Tools (Hotbar)" or State.StrengthSource == "Tools (Best for Rebirth)")
        then
            pcall(teleportToKingsGym)
        end
        task.wait(1)
    end
end)

LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ========================================================================
-- 🎨 AUTHENTIC AJIZ HUB UI SYSTEM (EXACT DESIGN, RED [✓] BOXES, FLYOUTS)
-- ========================================================================

local function getGuiContainer()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local core = nil
    pcall(function() core = game:GetService("CoreGui") end)
    if core then
        local success = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = core
            test:Destroy()
        end)
        if success then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getGuiContainer()

for _, old in ipairs(parentGui:GetChildren()) do
    if old.Name == "AjizMuscleHub" or old:GetAttribute("AjizMuscleHub") then
        pcall(function() old:Destroy() end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AjizMuscleHub"
ScreenGui:SetAttribute("AjizMuscleHub", true)
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentGui

if RELOAD_STATE and RELOAD_STATE.onCleanup then
    RELOAD_STATE.onCleanup(function()
        State.Running = false
        State.FarmMode = "Off"
        Runtime.FarmToken = Runtime.FarmToken + 1
        pcall(function() ScreenGui:Destroy() end)
    end)
end

local Theme = {
    Background = Color3.fromRGB(15, 17, 24),
    Header = Color3.fromRGB(20, 23, 32),
    Border = Color3.fromRGB(32, 38, 52),
    Accent = Color3.fromRGB(0, 170, 255),       -- Glowing Sky Blue
    CheckActive = Color3.fromRGB(235, 60, 60),  -- Red Checkbox [✓]
    CheckInactive = Color3.fromRGB(28, 32, 44),
    ItemBg = Color3.fromRGB(22, 25, 36),
    ItemHover = Color3.fromRGB(30, 35, 50),
    TextPrimary = Color3.fromRGB(245, 248, 255),
    TextMuted = Color3.fromRGB(140, 148, 165),
    Font = Enum.Font.GothamBold,
    FontRegular = Enum.Font.GothamMedium
}

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Mobile Floating "AJ" Icon
local MobileToggle = Instance.new("ImageButton")
MobileToggle.Name = "AjizFloatIcon"
MobileToggle.Size = UDim2.new(0, 42, 0, 42)
MobileToggle.Position = UDim2.new(0, 15, 0.45, 0)
MobileToggle.BackgroundColor3 = Theme.Header
MobileToggle.BorderSizePixel = 0
MobileToggle.Active = true
MobileToggle.Parent = ScreenGui
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(0, 8)
local iconStroke = Instance.new("UIStroke", MobileToggle)
iconStroke.Color = Theme.Accent
iconStroke.Thickness = 1.4

local iconLabel = Instance.new("TextLabel", MobileToggle)
iconLabel.Size = UDim2.new(1, 0, 1, 0)
iconLabel.BackgroundTransparency = 1
iconLabel.Font = Theme.Font
iconLabel.Text = "AJ"
iconLabel.TextColor3 = Theme.Accent
iconLabel.TextSize = 14.5

makeDraggable(MobileToggle)

-- Compact Main Frame (Exact Ajiz Hub 240px width structure)
local isMin = false
local expandedHeight = 440

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 250, 0, expandedHeight)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -220)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Border
mainStroke.Thickness = 1

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Theme.Header
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -65, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Theme.Font
TitleLabel.Text = "MUSCLE LEGENDS"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -54, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
MinBtn.Text = "▲"
MinBtn.Font = Theme.Font
MinBtn.TextColor3 = Theme.TextMuted
MinBtn.TextSize = 11
MinBtn.AutoButtonColor = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -27, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 25)
CloseBtn.Text = "×"
CloseBtn.Font = Theme.Font
CloseBtn.TextColor3 = Color3.fromRGB(235, 60, 60)
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

makeDraggable(MainFrame, Header)

MobileToggle.Activated:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.Activated:Connect(function() MainFrame.Visible = false end)

MinBtn.Activated:Connect(function()
    isMin = not isMin
    if isMin then
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 34)
        }):Play()
        MinBtn.Text = "▼"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, expandedHeight)
        }):Play()
        MinBtn.Text = "▲"
    end
end)

-- Scrollable List
local ScrollBody = Instance.new("ScrollingFrame", MainFrame)
ScrollBody.Size = UDim2.new(1, -12, 1, -62)
ScrollBody.Position = UDim2.new(0, 6, 0, 38)
ScrollBody.BackgroundTransparency = 1
ScrollBody.BorderSizePixel = 0
ScrollBody.ScrollBarThickness = 2.5
ScrollBody.ScrollBarImageColor3 = Theme.Accent
ScrollBody.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollBody.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", ScrollBody)
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Footer
local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(1, 0, 0, 22)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundColor3 = Theme.Header
Footer.BorderSizePixel = 0

local FooterLabel = Instance.new("TextLabel", Footer)
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Theme.Font
FooterLabel.Text = "AJIZ HUB"
FooterLabel.TextColor3 = Theme.Accent
FooterLabel.TextSize = 11.5

-- ========================================================================
-- 🧩 AJIZ UI CONTROLS (EXACT SIGNATURE SPEC)
-- ========================================================================

local function AddToggle(title, default, callback)
    local state = default or false
    local ItemFrame = Instance.new("Frame", ScrollBody)
    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
    ItemFrame.BackgroundColor3 = Theme.ItemBg
    ItemFrame.BorderSizePixel = 0
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", ItemFrame)
    stroke.Color = Theme.Border
    stroke.Thickness = 0.8

    local Title = Instance.new("TextLabel", ItemFrame)
    Title.Size = UDim2.new(1, -44, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Theme.Font
    Title.Text = title
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 11.5
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("Frame", ItemFrame)
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(1, -30, 0.5, -10)
    Box.BackgroundColor3 = state and Theme.CheckActive or Theme.CheckInactive
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", Box)
    boxStroke.Color = state and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(45, 52, 70)

    local Check = Instance.new("TextLabel", Box)
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Font = Theme.Font
    Check.Text = state and "✓" or ""
    Check.TextColor3 = Color3.fromRGB(255, 255, 255)
    Check.TextSize = 13

    local Btn = Instance.new("TextButton", ItemFrame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local function update(val)
        state = val
        Box.BackgroundColor3 = state and Theme.CheckActive or Theme.CheckInactive
        boxStroke.Color = state and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(45, 52, 70)
        Check.Text = state and "✓" or ""
        if callback then task.spawn(callback, state) end
    end

    Btn.Activated:Connect(function() update(not state) end)
    return { SetValue = update }
end

local function AddButton(title, callback)
    local ItemFrame = Instance.new("Frame", ScrollBody)
    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
    ItemFrame.BackgroundColor3 = Theme.ItemBg
    ItemFrame.BorderSizePixel = 0
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", ItemFrame)
    stroke.Color = Theme.Border
    stroke.Thickness = 0.8

    local Title = Instance.new("TextLabel", ItemFrame)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Theme.Font
    Title.Text = title
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 11.5
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Arrow = Instance.new("TextLabel", ItemFrame)
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Position = UDim2.new(1, -28, 0.5, -10)
    Arrow.BackgroundTransparency = 1
    Arrow.Font = Theme.Font
    Arrow.Text = "▶"
    Arrow.TextColor3 = Theme.Accent
    Arrow.TextSize = 11

    local Btn = Instance.new("TextButton", ItemFrame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    Btn.Activated:Connect(function()
        TweenService:Create(ItemFrame, TweenInfo.new(0.08), { BackgroundColor3 = Theme.Accent }):Play()
        task.wait(0.08)
        TweenService:Create(ItemFrame, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ItemBg }):Play()
        if callback then task.spawn(callback) end
    end)
end

local function AddSelector(title, options, callback)
    local items = options or {}
    local currentIndex = 1
    if #items == 0 then items = {"None"} end

    local ItemFrame = Instance.new("Frame", ScrollBody)
    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
    ItemFrame.BackgroundColor3 = Theme.ItemBg
    ItemFrame.BorderSizePixel = 0
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", ItemFrame)
    stroke.Color = Theme.Border
    stroke.Thickness = 0.8

    local Label = Instance.new("TextLabel", ItemFrame)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.Font
    Label.Text = title .. ": " .. tostring(items[currentIndex])
    Label.TextColor3 = Theme.TextPrimary
    Label.TextSize = 11.5
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd

    local Icon = Instance.new("TextLabel", ItemFrame)
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(1, -28, 0.5, -10)
    Icon.BackgroundTransparency = 1
    Icon.Font = Theme.Font
    Icon.Text = "🔄"
    Icon.TextSize = 12

    local Btn = Instance.new("TextButton", ItemFrame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local function selectIndex(idx)
        currentIndex = idx
        local selected = items[currentIndex]
        Label.Text = title .. ": " .. tostring(selected)
        if callback then task.spawn(callback, selected) end
    end

    Btn.Activated:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #items then currentIndex = 1 end
        selectIndex(currentIndex)
    end)

    return {
        SetValue = function(val)
            for i, opt in ipairs(items) do
                if opt == val then
                    selectIndex(i)
                    break
                end
            end
        end,
        SetOptions = function(newOpts)
            items = newOpts
            if #items == 0 then items = {"None"} end
            currentIndex = 1
            selectIndex(1)
        end
    }
end

local function AddLabel(text)
    local ItemFrame = Instance.new("Frame", ScrollBody)
    ItemFrame.Size = UDim2.new(1, 0, 0, 28)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    ItemFrame.BorderSizePixel = 0
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 5)

    local Label = Instance.new("TextLabel", ItemFrame)
    Label.Size = UDim2.new(1, -16, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.FontRegular
    Label.Text = text
    Label.TextColor3 = Theme.TextPrimary
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd

    return {
        SetText = function(str) Label.Text = tostring(str) end
    }
end

local function AddSection(title)
    local Frame = Instance.new("Frame", ScrollBody)
    Frame.Size = UDim2.new(1, 0, 0, 22)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -8, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.Font
    Label.Text = "• " .. string.upper(title) .. " •"
    Label.TextColor3 = Theme.Accent
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
end

-- ========================================================================
-- 📋 POPULATE ENHANCED AJIZ HUB FEATURES
-- ========================================================================

-- 1. 🔄 SMART AUTO REBIRTH (FULLY AUTOMATED REQUIREMENT FULFILLMENT)
AddSection("Smart Auto Rebirth System")

local rebirthStatusLabel = AddLabel("Next Rebirth: Calculating...")

AddToggle("🏆 Smart Auto Rebirth", false, function(state)
    State.AutoRebirth = state
    if state then
        notify("Auto Rebirth", "Smart Requirement Fulfillment & Multi-Rebirth Active!", 3)
        requestAutoRebirth()
    else
        notify("Auto Rebirth", "Auto Rebirth Paused.", 2)
    end
end)

AddToggle("⚡ Auto Boost Push for Rebirth", true, function(state)
    State.AutoRebirthBoostPush = state
end)

AddToggle("🐾 Auto Swap Rebirth Perk Pets", true, function(state)
    State.AutoRebirthPetSwap = state
end)

AddToggle("👑 Auto Upgrade Rebirth Ultimates", true, function(state)
    State.AutoUltimates = state
end)

AddButton("🔄 Rebirth Now (Instant Chain)", function()
    spawnTask(function()
        local wasFarming = State.FarmMode
        Runtime.FarmToken = Runtime.FarmToken + 1
        local gained = rebirthChain(50, true)
        notify("Rebirth Chain", gained > 0 and (gained .. " rebirth(s) completed!") or "Not enough strength yet", 3)
        if wasFarming ~= "Off" then startFarm() end
    end)
end)

-- 2. 🏋️ FAST AUTO FARM CONTROLS
AddSection("Fast Auto Farm")

local farmStatusLabel = AddLabel("Status: Idle")
local farmTargetLabel = AddLabel("Target: none")

local farmModeSelector = AddSelector("Stat Farm", {"Off", "Strength", "Agility", "Durability", "Rotate"}, function(mode)
    if mode == "Off" then
        stopFarm("Stopped by user")
        notify("Auto Farm", "Farm Stopped.", 2)
    else
        State.FarmMode = mode
        startFarm()
        notify("Auto Farm", "Farming " .. mode .. " Started!", 2.5)
    end
end)

AddSelector("Strength Method", {"Tools (Best for Rebirth)", "Auto (Fastest)", "Machines"}, function(source)
    State.StrengthSource = source
    Runtime.Rates = {}
    Runtime.Blacklist = {}
    if State.FarmMode == "Strength" then startFarm() end
end)

AddToggle("🏰 King's Gym Tool Farm", true, function(state)
    State.AlwaysKingsGym = state
    if state then spawnTask(teleportToKingsGym) end
end)

AddButton("🛑 Stop Farming / Free Character", function()
    farmModeSelector.SetValue("Off")
    stopFarm("Freed character")
end)

-- 3. 🧪 CONSUMABLES & BOOSTS
AddSection("Consumables & Boosts")
local boostHeldLabel = AddLabel("Held Boosts: -")
AddToggle("🧪 Auto Use Timed Boosts", false, function(state)
    State.AutoBoosts = state
end)
AddButton("⚡ Consume All Shakes & Bars Now", function()
    spawnTask(function() useBoosts(true) end)
end)

-- 4. 🎁 AUTO CLAIMS & REWARDS
AddSection("Automatic Reward Claims")
AddToggle("📦 Auto Chests (6h Timers)", false, function(state) State.AutoChests = state end)
AddToggle("👥 Auto Group Rewards", false, function(state) State.AutoGroup = state end)
AddToggle("🎁 Auto Free Playtime Gifts", false, function(state) State.AutoGifts = state end)
AddToggle("🎡 Auto Fortune Wheel", false, function(state) State.AutoWheel = state end)
AddToggle("📜 Auto Story & Daily Quests", false, function(state)
    State.AutoQuests = state
    if state then spawnTask(updateNpcQuests) end
end)

AddButton("🎁 Claim All Rewards Now", function()
    spawnTask(function()
        pcall(claimChests)
        pcall(claimGroup)
        pcall(claimGifts)
        pcall(spinWheel)
        pcall(updateNpcQuests)
        notify("Rewards", "All reward claims executed!", 2.5)
    end)
end)

-- 5. 🐾 CRYSTAL HATCHING & PETS
AddSection("Pet Hatching & Management")
local crystalNames = {}
for _, c in ipairs(crystalPrices:GetChildren()) do table.insert(crystalNames, c.Name) end
table.sort(crystalNames)

local crystalHatchLabel = AddLabel("Selected: Blue Crystal")

AddSelector("Crystal", crystalNames, function(cName)
    State.HatchCrystal = cName
    local price, kind = crystalCost(cName)
    crystalHatchLabel.SetText(("Selected: %s (%s %s)"):format(cName, short(price or 0), kind or "Gems"))
end)

AddToggle("🥚 Auto Hatch Crystal", false, function(state) State.AutoHatch = state end)
AddButton("✨ Hatch x1", function()
    spawnTask(function()
        local ok, info = hatchOnce(State.HatchCrystal)
        notify("Hatch", ok and info or ("Failed: " .. tostring(info)), 2)
    end)
end)
AddButton("🌟 Hatch x10", function()
    spawnTask(function()
        local got = 0
        for _ = 1, 10 do
            if hatchOnce(State.HatchCrystal) then got = got + 1 else break end
            task.wait(0.3)
        end
        notify("Hatch", got .. " pets hatched!", 2.5)
    end)
end)

AddToggle("⚔️ Auto Equip Best Pets", false, function(state) State.AutoEquipPets = state end)
AddButton("🛡️ Equip Best Pets Now", function() spawnTask(function() equipBestPetsCustom() end) end)
AddToggle("🧬 Auto Evolve Ready Pets (x5)", false, function(state) State.AutoEvolvePets = state end)
AddButton("🧬 Evolve All Ready Pets Now", function()
    spawnTask(function()
        local n = evolveReadyPets()
        notify("Evolution", n .. " pet(s) evolved!", 2.5)
    end)
end)

-- 6. 📊 LIVE REALTIME STATS
AddSection("Live Character Stats")
local liveStatsLabel = AddLabel("Str: - | Agi: - | Dur: -")
local liveCurrencyLabel = AddLabel("Gems: - | Rebirths: -")
local liveRateLabel = AddLabel("Gains/min: -")

AddButton("🔄 Reset Session Tracker", function()
    Runtime.Reps, Runtime.Hatched, Runtime.Claimed = 0, 0, 0
    Runtime.RebirthCount, Runtime.Boosts, Runtime.Upgrades, Runtime.Evolved = 0, 0, 0, 0
    Runtime.StartClock = os.clock()
    Runtime.StartStats = {Strength = Strength.Value, Agility = Agility.Value, Durability = Durability.Value}
    notify("Session", "Counters reset successfully!", 2)
end)

-- 7. 📍 AREA TELEPORTS & MISC
AddSection("Teleports & Server Utilities")
local areaParts = areaTeleportParts
local areaNames = {}
if areaParts then
    for _, p in ipairs(areaParts:GetChildren()) do table.insert(areaNames, p.Name) end
    table.sort(areaNames)
end
if #areaNames == 0 then areaNames = {"none"} end
local selectedArea = areaNames[1]

AddSelector("Area Pad", areaNames, function(pad) selectedArea = pad end)
AddButton("📍 Teleport To Area Pad", function()
    spawnTask(function()
        if not areaParts then return end
        local part = areaParts:FindFirstChild(selectedArea)
        if not part or not alive() then return end
        Runtime.FarmToken = Runtime.FarmToken + 1
        leaveMachine()
        for _ = 1, 10 do anchorAt(part.CFrame * CFrame.new(0, 6, 0)) task.wait(0.1) end
        if State.FarmMode ~= "Off" then startFarm() end
    end)
end)

AddButton("🔁 Rejoin Server", function()
    pcall(function() Remotes.Rejoin:FireServer() end)
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
end)

AddButton("⚠️ Stop All Automations", function()
    State.AutoHatch, State.AutoBoosts, State.AutoUltimates = false, false, false
    State.AutoChests, State.AutoGroup, State.AutoGifts, State.AutoWheel, State.AutoQuests = false, false, false, false, false
    State.AutoEquipPets, State.AutoSellPets, State.AutoDeletePets = false, false, false
    State.AutoEvolvePets, State.AutoRebirth, State.AlwaysKingsGym = false, false, false
    farmModeSelector.SetValue("Off")
    stopFarm("All automations stopped")
    notify("Ajiz Hub", "All background routines stopped.", 2.5)
end)

-- ========================================================================
-- 🔄 BACKGROUND LIVE STATS & DASHBOARD REFRESH LOOP
-- ========================================================================

spawnTask(function()
    local repsProgress = repsCounter()
    local lastReps = repsProgress and repsProgress.Value or 0
    local repsStart = lastReps
    while running() do
        elevate()
        local elapsed = math.max(os.clock() - Runtime.StartClock, 1)
        local perMin = 60 / elapsed
        
        local targetReq = rebirthTarget()
        local pct = math.clamp(Strength.Value / (targetReq > 0 and targetReq or 1) * 100, 0, 100)
        
        if rebirthStatusLabel then
            rebirthStatusLabel.SetText(("Next Rebirth: %s / %s (%.0f%%)"):format(short(Strength.Value), short(targetReq), pct))
        end
        if farmStatusLabel then
            farmStatusLabel.SetText("Status: " .. Runtime.Status)
        end
        if farmTargetLabel then
            farmTargetLabel.SetText("Target: " .. Runtime.Target)
        end
        if boostHeldLabel then
            local counts = {}
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if TIMED_BOOSTS[tool.Name] or INSTANT_BOOSTS[tool.Name] then
                    counts[tool.Name] = (counts[tool.Name] or 0) + 1
                end
            end
            local parts = {}
            for name, n in pairs(counts) do parts[#parts + 1] = name .. " x" .. n end
            boostHeldLabel.SetText("Held: " .. (#parts > 0 and table.concat(parts, ", ") or "None"))
        end
        if liveStatsLabel then
            liveStatsLabel.SetText(("Str: %s | Agi: %s | Dur: %s"):format(short(Strength.Value), short(Agility.Value), short(Durability.Value)))
        end
        if liveCurrencyLabel then
            liveCurrencyLabel.SetText(("Gems: %s | Rebirths: %s"):format(short(Gems.Value), short(Rebirths.Value)))
        end
        if liveRateLabel then
            liveRateLabel.SetText(("Gains/min: Str +%s | Rebirths: +%d"):format(
                short(math.floor((Strength.Value - Runtime.StartStats.Strength) * perMin)),
                Runtime.RebirthCount
            ))
        end
        task.wait(0.5)
    end
end)

SESSION.State = State
SESSION.Runtime = Runtime
SESSION.api = {
    startFarm = function() startFarm() end,
    stopFarm = stopFarm,
    generation = MY_GENERATION,
    generationAlive = generationAlive,
    candidateSources = candidateSources,
    teleportToKingsGym = teleportToKingsGym,
    rebirthTarget = rebirthTarget,
    useBoosts = useBoosts,
    upgradeUltimates = upgradeUltimates,
    equipBestPets = function() equipBestPetsCustom() end,
    rebirthChain = rebirthChain,
}

notify("Muscle Legends", "Ajiz Hub v4 (Smart Auto Rebirth) Loaded!", 4)
