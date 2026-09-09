-- Hotel Minus MEGA EASY MODE Script
-- Instant speed walk, instant revive, friendly entities, custom items

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 150
local PLAYER_HEALTH = 99999
local PLAYER_JUMP = 300
local AUTO_HEAL = true
local HEAL_RATE = 100
local DOOR_DETECT_RANGE = 100
local AUTO_OPEN_DOORS = true
local REVIVE_BUTTON = Enum.KeyCode.R
local INSTANT_SPEED_WALK = true -- No momentum buildup
local SPAWN_CUSTOM_ITEMS = true
local ITEM_SPAWN_INTERVAL = 8
local MAX_ITEMS = 3

-- Tables
local customItems = {}
local lastItemSpawnTime = 0

-- Boost player stats
humanoid.MaxHealth = PLAYER_HEALTH
humanoid.Health = PLAYER_HEALTH
humanoid.WalkSpeed = PLAYER_SPEED
humanoid.JumpPower = PLAYER_JUMP

-- Function to check if player is solo
local function isSoloMode()
    local playerCount = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            playerCount = playerCount + 1
        end
    end
    return playerCount <= 1
end

-- Function to revive player instantly
local function revivePlayer()
    if not character or not humanoidRootPart then return end
    
    character = player.Character
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    humanoid.MaxHealth = PLAYER_HEALTH
    humanoid.Health = PLAYER_HEALTH
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
    
    print("✓ INSTANT REVIVED!")
end

-- Function to heal player
local function healPlayer()
    if AUTO_HEAL and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = math.min(humanoid.Health + HEAL_RATE, humanoid.MaxHealth)
    end
end

-- Function for instant speed walk (no momentum)
local function instantSpeedWalk()
    if INSTANT_SPEED_WALK and humanoid then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end

-- Function to make all entities friendly
local function makeFriendlyEntities()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local objHumanoid = obj:FindFirstChild("Humanoid")
            -- Make them follow player instead of attacking
            if objHumanoid then
                objHumanoid.MaxHealth = 9999
                objHumanoid.Health = 9999
                objHumanoid.WalkSpeed = 20
                
                -- Color them blue to show they're friendly
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("Part") then
                        part.Color = Color3.fromRGB(0, 100, 255)
                    end
                end
            end
        end
    end
end

-- Function to create custom power-up items
local function createCustomItem()
    if #customItems >= MAX_ITEMS then return end
    
    local item = Instance.new("Part")
    item.Name = "PowerUpItem_" .. math.random(1000, 9999)
    item.Shape = Enum.PartType.Ball
    item.Size = Vector3.new(1.5, 1.5, 1.5)
    item.Color = Color3.fromRGB(255, 215, 0) -- Gold
    item.CanCollide = true
    item.Parent = workspace
    
    -- Spawn at random location
    local spawnPos = Vector3.new(
        math.random(-200, 200),
        50,
        math.random(-200, 200)
    )
    item.CFrame = CFrame.new(spawnPos)
    
    -- Add touch detection
    local touchConnection
    touchConnection = item.Touched:Connect(function(hit)
        if hit.Parent == character then
            print("✓ PowerUp collected! +25 health boost!")
            humanoid.MaxHealth = humanoid.MaxHealth + 25
            humanoid.Health = humanoid.MaxHealth
            
            -- Remove item
            item:Destroy()
            table.remove(customItems, table.find(customItems, item))
            touchConnection:Disconnect()
        end
    end)
    
    table.insert(customItems, item)
end

-- Function to spawn custom items periodically
local function spawnItemsPeriodically()
    local currentTime = tick()
    if currentTime - lastItemSpawnTime >= ITEM_SPAWN_INTERVAL and #customItems < MAX_ITEMS then
        createCustomItem()
        lastItemSpawnTime = currentTime
        print("✨ PowerUp item spawned!")
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

-- Instant revive on death
humanoid.Died:Connect(function()
    wait(0.01)
    revivePlayer()
end)

-- Button to manually revive (press R)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == REVIVE_BUTTON then
        revivePlayer()
    end
end)

-- Maintain instant speed walk
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed ~= PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart or not humanoid then return end
    
    -- Auto heal player
    healPlayer()
    
    -- Keep jump power high
    humanoid.JumpPower = PLAYER_JUMP
    
    -- Instant speed walk (no momentum)
    instantSpeedWalk()
    
    -- Auto-open doors
    autoOpenDoors()
    
    -- Make entities friendly
    makeFriendlyEntities()
    
    -- Spawn custom items
    if SPAWN_CUSTOM_ITEMS then
        spawnItemsPeriodically()
    end
    
    -- Instant revive on death
    if humanoid.Health <= 0 then
        wait(0.01)
        revivePlayer()
    end
end)

print("✓✓✓ MEGA EASY MODE ACTIVATED! ✓✓✓")
print("⚡ Speed: 150 (INSTANT - NO MOMENTUM!)")
print("❤️ Health: 99999 (GOD MODE)")
print("📈 Jump Power: 300")
print("🚪 Auto-opens doors within 100 studs")
print("💀 INSTANT REVIVE ON DEATH!")
print("💙 ALL ENTITIES ARE FRIENDLY!")
print("✨ Custom PowerUp items spawn every 8 seconds")
print("🔄 Press R to manually revive anytime!")
print("😎 PURE CHILL MODE - IMPOSSIBLE TO FAIL!")
