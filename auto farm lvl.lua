-- Services
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local compass = game:GetService("ReplicatedStorage"):WaitForChild("Compass")
local questNPCs = workspace:WaitForChild("QuestNPCs") -- Assuming the NPCs are stored here

-- UI Setup for Mod Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenu"
ScreenGui.Parent = player:WaitForChild("PlayerGui")  -- Ensure this is parented to PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = ScreenGui

local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Size = UDim2.new(0, 180, 0, 50)
autoFarmButton.Position = UDim2.new(0, 10, 0, 10)
autoFarmButton.Text = "Toggle Auto Farm"
autoFarmButton.Parent = frame

local autoQuestButton = Instance.new("TextButton")
autoQuestButton.Size = UDim2.new(0, 180, 0, 50)
autoQuestButton.Position = UDim2.new(0, 10, 0, 70)
autoQuestButton.Text = "Toggle Auto Quest"
autoQuestButton.Parent = frame

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 180, 0, 50)
teleportButton.Position = UDim2.new(0, 10, 0, 130)
teleportButton.Text = "Teleport to Quest"
teleportButton.Parent = frame

-- Variables for toggles
local autoFarmActive = false
local autoQuestActive = false
local currentQuest = nil
local nextQuestNPC = nil
local questProgress = {}  -- Store the progress for each quest

-- Toggle Functions
autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    print("Auto Farm: " .. tostring(autoFarmActive))
end)

autoQuestButton.MouseButton1Click:Connect(function()
    autoQuestActive = not autoQuestActive
    print("Auto Quest: " .. tostring(autoQuestActive))
end)

teleportButton.MouseButton1Click:Connect(function()
    teleportToQuestLocation()
end)

-- Helper Functions
local function findQuestNPC()
    -- Find the closest NPC that gives the next quest
    for _, npc in pairs(questNPCs:GetChildren()) do
        if npc:FindFirstChild("QuestGiver") then
            return npc
        end
    end
    return nil
end

-- Function to interact with the NPC and start a new quest
local function startNewQuest(npc)
    -- Example: Look for a Quest GUI button, interact and start quest
    local questButton = npc:FindFirstChild("QuestButton")
    if questButton then
        questButton:Click()  -- Interact with the quest NPC
        print("Quest started: " .. npc.Name)
        currentQuest = npc.Name  -- Update current quest name (optional)
        -- Initialize progress for this quest
        questProgress[currentQuest] = { kills = 0, requiredKills = math.random(5, 20) }
    end
end

-- Function to teleport to a quest NPC location (automatically detected)
local function teleportToQuestLocation()
    if nextQuestNPC then
        -- Teleport to the next quest NPC position
        humanoidRootPart.CFrame = nextQuestNPC.HumanoidRootPart.CFrame
        print("Teleported to: " .. nextQuestNPC.Name)
    end
end

-- Function to automatically detect the need for the next quest
local function detectNextQuest()
    -- Detect the nearest NPC that gives the next quest
    nextQuestNPC = findQuestNPC()
    
    if nextQuestNPC then
        -- If a new quest NPC is found, teleport to that NPC
        teleportToQuestLocation()

        -- Start the new quest automatically
        startNewQuest(nextQuestNPC)
    end
end

-- Function to start farming/attacking enemies
local function startAutoFarm()
    -- Example: Automatically farm enemies for the quest
    local targetEnemy = findClosestEnemy()
    if targetEnemy then
        magnetToEnemy(targetEnemy)
        attackEnemy(targetEnemy)
    end
end

-- Quest Completion Check Function (Improved)
function checkQuestCompletion(questName)
    -- Check the current quest progress
    local progress = questProgress[questName]
    if progress then
        -- Example: Quest requires killing enemies
        if progress.kills >= progress.requiredKills then
            return true  -- Quest completed
        end
    end
    return false  -- Quest not completed yet
end

-- Main Loop: Handles auto quest, auto farm, and quest progression
runService.Heartbeat:Connect(function()
    if autoFarmActive then
        -- Start auto farming if needed
        startAutoFarm()
    end

    if autoQuestActive then
        -- Detect new quest if it's time to move on to the next quest
        detectNextQuest()
    end
end)

-- Loop Quest function
local function loopQuest()
    while autoQuestActive do
        -- Continuously check if a quest is completed
        if currentQuest then
            local questCompleted = checkQuestCompletion(currentQuest)
            if questCompleted then
                print("Quest Completed: " .. currentQuest)
                detectNextQuest()  -- Move to the next quest automatically
            end
        end
        wait(1)  -- Check every second for quest completion
    end
end

-- Start the loop for quest checking
runService.Heartbeat:Connect(function()
    if autoQuestActive then
        loopQuest()  -- Start checking quest completion and handle next quest in a loop
    end
end)

-- Detect if the quest is completed (based on your game logic)
function checkQuestCompletion(questName)
    -- Replace with the actual condition that checks if the quest is completed
    -- Example: If quest level is achieved or enemies are defeated
    return true -- Just a placeholder, this condition will vary based on quest system
end

-- Function to find the closest enemy
function findClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    for _, enemy in pairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
            local distance = (humanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestEnemy = enemy
                shortestDistance = distance
            end
        end
    end
    return closestEnemy
end

-- Function to magnet to the enemy
function magnetToEnemy(enemy)
    humanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position)
end

-- Function to attack the enemy
function attackEnemy(enemy)
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(10)  -- Adjust damage value here

        -- Update quest progress for kills
        if currentQuest and questProgress[currentQuest] then
            questProgress[currentQuest].kills = questProgress[currentQuest].kills + 1
        end
    end
end

