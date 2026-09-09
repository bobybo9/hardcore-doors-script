-- Hotel Minus Hardcore Mode Script
-- All-in-one hardcore gameplay modifier

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 25 -- Player walk speed
local PLAYER_JUMP = 50 -- Player jump power
local ENTITY_SPEED = 35 -- Entity walk speed
local ENTITY_DETECTION_RANGE = 200 -- Detection range for entities
local DOOR_OPEN_SPEED = 2 -- How fast doors open

-- Boost player stats
humanoid.WalkSpeed = PLAYER_SPEED
humanoid.JumpPower = PLAYER_JUMP

-- Table to track boosted entities
local boostedEntities = {}

-- Function to boost entity
local function boostEntity(entity)
    if entity and entity:FindFirstChild("Humanoid") and entity.Parent ~= character then
        if not boostedEntities[entity] then
            entity.Humanoid.WalkSpeed = ENTITY_SPEED
            boostedEntities[entity] = true
        end
    end
end

-- Function to speed up doors
local function speedUpDoors()
    for _, door in pairs(workspace:FindPartsByClass("Model")) do
        if door:FindFirstChild("Open") or door.Name:match("Door") or door.Name:match("door") then
            local openScript = door:FindFirstChildOfClass("Script")
            if openScript then
                -- Modify door opening speed by adjusting tweens/animations
                for _, descendant in pairs(door:GetDescendants()) do
                    if descendant:IsA("TweenValue") then
                        descendant.Speed = DOOR_OPEN_SPEED
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
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
    boostedEntities = {}
end)

-- Main loop: detect and boost entities + doors
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Detect nearby entities
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local distance = (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj).Position:Distance(humanoidRootPart.Position)
            if distance < ENTITY_DETECTION_RANGE then
                boostEntity(obj)
            end
        end
    end
    
    -- Speed up doors
    speedUpDoors()
end)

-- Speed up player on stat changes
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed < PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

print("✓ Hotel Minus Hardcore Mode ACTIVATED!")
print("Player Speed: " .. PLAYER_SPEED)
print("Entity Speed: " .. ENTITY_SPEED)
print("Door Speed: " .. DOOR_OPEN_SPEED .. "x")
