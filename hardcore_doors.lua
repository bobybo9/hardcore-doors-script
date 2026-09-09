-- Hotel Minus Hardcore Mode Script
-- Creates new dangerous entities to make the game harder

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 20
local PLAYER_HEALTH = 50
local SPAWN_NEW_ENTITIES = true
local ENTITY_SPAWN_INTERVAL = 10 -- Spawn new entity every 10 seconds
local MAX_ENTITIES = 5
local lastSpawnTime = 0

-- Boost player stats
humanoid.MaxHealth = PLAYER_HEALTH
humanoid.Health = PLAYER_HEALTH
humanoid.WalkSpeed = PLAYER_SPEED

-- Table to track custom entities
local customEntities = {}

-- Function to create a new hostile entity
local function createHostileEntity()
    local newEntity = Instance.new("Model")
    newEntity.Name = "HardcoreEntity_" .. math.random(1000, 9999)
    
    -- Create body
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(2, 2, 2)
    head.Color = Color3.fromRGB(255, 0, 0) -- Red
    head.CanCollide = true
    head.Parent = newEntity
    
    -- Create humanoid
    local entityHumanoid = Instance.new("Humanoid")
    entityHumanoid.MaxHealth = 30
    entityHumanoid.Health = 30
    entityHumanoid.Parent = newEntity
    
    -- Spawn at random location away from player
    local spawnOffset = Vector3.new(
        math.random(-200, 200),
        math.random(-50, 50),
        math.random(-200, 200)
    )
    head.CFrame = humanoidRootPart.CFrame + spawnOffset
    head.CanCollide = true
    
    newEntity.PrimaryPart = head
    newEntity:SetPrimaryPartCFrame(head.CFrame)
    newEntity.Parent = workspace
    
    table.insert(customEntities, newEntity)
    return newEntity
end

-- Function to make entity chase player
local function chasePlayer(entity)
    if not entity or not entity.Parent then return end
    
    local entityHead = entity:FindFirstChild("Head")
    local entityHumanoid = entity:FindFirstChild("Humanoid")
    
    if not entityHead or not entityHumanoid or entityHumanoid.Health <= 0 then return end
    
    local distance = (entityHead.Position - humanoidRootPart.Position).Magnitude
    
    -- If close enough, move towards player
    if distance < 300 then
        local direction = (humanoidRootPart.Position - entityHead.Position).Unit
        entityHumanoid:MoveTo(entityHead.Position + direction * 35) -- Chase speed 35
        
        -- Deal damage if touching player
        if distance < 10 then
            humanoid:TakeDamage(5)
        end
    end
end

-- Function to spawn new entities periodically
local function spawnEntitiesPeriodicly()
    local currentTime = tick()
    if currentTime - lastSpawnTime >= ENTITY_SPAWN_INTERVAL and #customEntities < MAX_ENTITIES then
        createHostileEntity()
        lastSpawnTime = currentTime
        print("✓ New Hardcore Entity Spawned! Total: " .. #customEntities)
    end
end

-- Function to clean up dead entities
local function cleanupDeadEntities()
    for i = #customEntities, 1, -1 do
        local entity = customEntities[i]
        if not entity or not entity.Parent or entity:FindFirstChild("Humanoid").Health <= 0 then
            if entity and entity.Parent then
                entity:Destroy()
            end
            table.remove(customEntities, i)
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
end)

-- Maintain player speed
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed < PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Make entities chase player
    for _, entity in pairs(customEntities) do
        if entity and entity.Parent then
            chasePlayer(entity)
        end
    end
    
    -- Spawn new entities
    if SPAWN_NEW_ENTITIES then
        spawnEntitiesPeriodicly()
    end
    
    -- Clean dead entities
    cleanupDeadEntities()
end)

-- Cleanup on death
humanoid.Died:Connect(function()
    for _, entity in pairs(customEntities) do
        if entity and entity.Parent then
            entity:Destroy()
        end
    end
    customEntities = {}
end)

print("✓ HARDCORE MODE ACTIVATED!")
print("🔴 New hostile entities spawning every " .. ENTITY_SPAWN_INTERVAL .. " seconds!")
print("⚠️ Stay alert! Entities will chase and damage you!")
