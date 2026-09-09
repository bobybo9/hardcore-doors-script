-- Hotel Minus ULTIMATE SUPER EZ MODE Script
-- Crucifix entities, items in inventory, mega easy mode

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 200 -- MEGA FAST
local PLAYER_HEALTH = 999999 -- MEGA god mode
local PLAYER_JUMP = 500 -- FLYING
local AUTO_HEAL = true
local HEAL_RATE = 200 -- SUPER FAST heal
local DOOR_DETECT_RANGE = 200 -- HUGE door range
local AUTO_OPEN_DOORS = true
local CRUCIFIX_BUTTON = Enum.KeyCode.X -- Press X to crucifix
local INSTANT_REVIVE = true
local SPAWN_ITEMS_TO_INVENTORY = true
local ITEM_SPAWN_INTERVAL = 5
local AUTO_COLLECT_ITEMS = true
local ITEM_COLLECT_RANGE = 100
local INVINCIBILITY = true
local ONE_HIT_KILL = true

-- Tables
local crucifiedEntities = {}
local inventoryItems = {}

-- Boost player stats
humanoid.MaxHealth = PLAYER_HEALTH
humanoid.Health = PLAYER_HEALTH
humanoid.WalkSpeed = PLAYER_SPEED
humanoid.JumpPower = PLAYER_JUMP

-- Function to crucifix entity
local function crucifyEntity(entity)
    if not entity or entity.Parent ~= character or crucifiedEntities[entity] then return end
    
    local entityHumanoid = entity:FindFirstChild("Humanoid")
    if not entityHumanoid then return end
    
    -- Make entity helpless
    entityHumanoid.WalkSpeed = 0
    entityHumanoid.JumpPower = 0
    entityHumanoid.Health = 0
    
    -- Visual effect - make them red (crucified)
    for _, part in pairs(entity:GetDescendants()) do
        if part:IsA("Part") then
            part.Color = Color3.fromRGB(139, 0, 0) -- Dark red
        end
    end
    
    crucifiedEntities[entity] = true
    print("✝️ Entity crucified!")
end

-- Function to crucifix all nearby entities
local function crucifyAllNearby()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local objPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj
            if objPos then
                local distance = (objPos.Position - humanoidRootPart.Position).Magnitude
                if distance < 300 then
                    crucifyEntity(obj)
                end
            end
        end
    end
end

-- Function to add item to inventory
local function addItemToInventory(itemName)
    table.insert(inventoryItems, itemName)
    print("✨ " .. itemName .. " added to inventory!")
    print("📦 Inventory: " .. table.concat(inventoryItems, ", "))
end

-- Function to spawn items directly to inventory
local function spawnItemToInventory()
    local items = {
        "Health Boost +50",
        "Speed Boost x2",
        "Shield +100",
        "Revive Token",
        "Door Key",
        "Crucifix Power",
        "Invincibility Potion"
    }
    
    local randomItem = items[math.random(1, #items)]
    addItemToInventory(randomItem)
    
    -- Apply item effects
    if randomItem == "Health Boost +50" then
        humanoid.MaxHealth = humanoid.MaxHealth + 50
        humanoid.Health = humanoid.MaxHealth
    elseif randomItem == "Speed Boost x2" then
        PLAYER_SPEED = PLAYER_SPEED + 50
        humanoid.WalkSpeed = PLAYER_SPEED
    elseif randomItem == "Shield +100" then
        humanoid.MaxHealth = humanoid.MaxHealth + 100
    elseif randomItem == "Crucifix Power" then
        crucifyAllNearby()
    end
end

-- Function to auto-collect nearby items
local function autoCollectItems()
    if not AUTO_COLLECT_ITEMS then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Item") or obj.Name:match("PowerUp") then
            local distance = (obj.Position - humanoidRootPart.Position).Magnitude
            if distance < ITEM_COLLECT_RANGE then
                addItemToInventory(obj.Name)
                obj:Destroy()
            end
        end
    end
end

-- Function to heal player
local function healPlayer()
    if AUTO_HEAL and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = math.min(humanoid.Health + HEAL_RATE, humanoid.MaxHealth)
    end
end

-- Function to revive instantly
local function revivePlayer()
    if not character or not humanoidRootPart then return end
    
    character = player.Character
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    humanoid.MaxHealth = PLAYER_HEALTH
    humanoid.Health = PLAYER_HEALTH
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
    
    print("✝️ INSTANT REVIVED!")
end

-- Function to one-hit kill
local function oneHitKillEntities()
    if not ONE_HIT_KILL then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local objHumanoid = obj:FindFirstChild("Humanoid")
            if objHumanoid and objHumanoid.Health > 0 then
                objHumanoid.Health = 0
            end
        end
    end
end

-- Function to auto-open nearby doors
local function autoOpenDoors()
    if not AUTO_OPEN_DOORS or not humanoidRootPart then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Door") or obj.Name:match("door") or obj.Parent.Name:match("Door") then
            local objPos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if objPos then
                local distance = (objPos - humanoidRootPart.Position).Magnitude
                
                if distance < DOOR_DETECT_RANGE then
                    local openValue = obj.Parent:FindFirstChild("Open")
                    if openValue and openValue:IsA("BoolValue") then
                        openValue.Value = true
                    end
                    
                    for _, remote in pairs(obj.Parent:FindFirstChildOfClass("RemoteEvent") or {}) do
                        pcall(function()
                            remote:FireServer("Open")
                        end)
                    end
                    
                    if obj:IsA("Part") then
                        obj.CanCollide = false
                        obj.Transparency = 0.9
                    end
                end
            end
        end
    end
end

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.MaxHealth = PLAYER_HEALTH
    humanoid.Health = PLAYER_HEALTH
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
end)

-- Crucifix button (press X)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CRUCIFIX_BUTTON then
        print("✝️ CRUCIFYING ALL NEARBY ENTITIES!")
        crucifyAllNearby()
    end
end)

-- Instant revive on death
humanoid.Died:Connect(function()
    if INSTANT_REVIVE then
        wait(0.01)
        revivePlayer()
    end
end)

-- Maintain speed
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed ~= PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

-- Spawn items to inventory periodically
local lastItemSpawnTime = 0
local function spawnItemsPeriodically()
    local currentTime = tick()
    if currentTime - lastItemSpawnTime >= ITEM_SPAWN_INTERVAL then
        spawnItemToInventory()
        lastItemSpawnTime = currentTime
    end
end

-- Main loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart or not humanoid then return end
    
    -- Auto heal player
    healPlayer()
    
    -- Keep jump power high
    humanoid.JumpPower = PLAYER_JUMP
    
    -- Keep speed at max
    humanoid.WalkSpeed = PLAYER_SPEED
    
    -- Auto-open doors
    autoOpenDoors()
    
    -- Auto-collect items
    autoCollectItems()
    
    -- Spawn items to inventory
    if SPAWN_ITEMS_TO_INVENTORY then
        spawnItemsPeriodically()
    end
    
    -- One-hit kill all entities
    if ONE_HIT_KILL then
        oneHitKillEntities()
    end
    
    -- Instant revive on death
    if humanoid.Health <= 0 and INSTANT_REVIVE then
        wait(0.01)
        revivePlayer()
    end
    
    -- Invincibility
    if INVINCIBILITY and humanoid.Health <= 0 then
        humanoid.Health = PLAYER_HEALTH
    end
end)

print("✝️✝️✝️ ULTIMATE SUPER EZ MODE ACTIVATED! ✝️✝️✝️")
print("✝️ CRUCIFIX POWER - Press X to crucify all nearby entities!")
print("⚡ Speed: 200 (MEGA FAST!)")
print("❤️ Health: 999999 (MEGA GOD MODE!)")
print("📈 Jump Power: 500 (FLYING!)")
print("💰 Items spawn directly in your INVENTORY every 5 seconds!")
print("⚔️ ONE-HIT KILL - All entities die instantly!")
print("🛡️ INVINCIBILITY - Cannot die!")
print("🚪 Auto-opens ALL doors within 200 studs!")
print("💀 INSTANT REVIVE ALWAYS!")
print("✨ Auto-collect nearby items!")
print("📦 Inventory system enabled!")
print("😎 ULTIMATE CHEAT MODE - YOU LITERALLY CANNOT LOSE!")
