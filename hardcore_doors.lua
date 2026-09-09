-- Hardcore Doors Script
-- Simple and fast gameplay modifier

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Settings
local SPEED_BOOST = 1.5 -- Movement speed multiplier
local DAMAGE_MULTIPLIER = 2 -- Take 2x damage
local ENTITY_SPEED_BOOST = 1.3 -- Entities move faster

-- Function to boost player speed
local function boostSpeed()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed * SPEED_BOOST
    end
end

-- Function to increase entity speed
local function boostEntitySpeed(entity)
    if entity:FindFirstChild("Humanoid") then
        entity.Humanoid.WalkSpeed = entity.Humanoid.WalkSpeed * ENTITY_SPEED_BOOST
    end
end

-- Boost initial speed
boostSpeed()

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    boostSpeed()
end)

-- Detect and boost entities
RunService.Heartbeat:Connect(function()
    for _, entity in pairs(workspace:FindPartByCFrame(character:FindFirstChild("HumanoidRootPart").CFrame, 100)) do
        if entity.Parent and entity.Parent:FindFirstChild("Humanoid") and entity.Parent ~= character then
            boostEntitySpeed(entity.Parent)
        end
    end
end)

print("✓ Hardcore Doors Script Loaded!")
