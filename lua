local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")

-- Remove previous instances of the GUI
local previousGUI = coreGui:FindFirstChild("RemoteEventGUI")
if previousGUI then
    previousGUI:Destroy()
end

-- Function to get the full path of a RemoteEvent
local function getFullPath(instance)
    local path = {}
    while instance and instance ~= game do
        table.insert(path, 1, instance.Name)
        instance = instance.Parent
    end
    return table.concat(path, ".")
end

-- Function to find all RemoteEvents in the game
local function findAllRemoteEvents()
    local remoteEvents = {}
    local function addRemoteEvents(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(remoteEvents, obj)
            end
        end
    end

    -- Search in ReplicatedStorage and Workspace, including all descendants
    addRemoteEvents(replicatedStorage)
    addRemoteEvents(workspace)

    return remoteEvents
end

-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteEventGUI"
screenGui.Parent = coreGui  -- Parent to CoreGui to persist through deaths

-- Create the main container frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)  -- Adjusted size to accommodate additional buttons
mainFrame.Position = UDim2.new(0, 10, 0, 10)  -- Position in top-left corner
mainFrame.BackgroundTransparency = 0.5
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Create a title bar with a collapse button
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Remote Events"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSans
titleLabel.Parent = titleBar

local collapseButton = Instance.new("TextButton")
collapseButton.Size = UDim2.new(0, 30, 1, 0)
collapseButton.Position = UDim2.new(1, -30, 0, 0)
collapseButton.BackgroundTransparency = 1
collapseButton.Text = "-"
collapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collapseButton.TextScaled = true
collapseButton.Font = Enum.Font.SourceSansBold
collapseButton.Parent = titleBar

-- Create a frame to hold the scrolling area
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)  -- Full size minus title bar
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Will be adjusted later
scrollingFrame.ScrollBarThickness = 10
scrollingFrame.Parent = mainFrame

-- Create a UIListLayout to manage the layout of buttons inside the ScrollingFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollingFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Get all RemoteEvents in the game
local remoteEvents = findAllRemoteEvents()

-- Function to copy text to clipboard (works on PC)
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif writeclipboard then
        writeclipboard(text)
    else
        print("Clipboard functions are not available.")
    end
end

-- Iterate over the RemoteEvents and create GUI elements for each
for i, remoteEvent in ipairs(remoteEvents) do
    local path = getFullPath(remoteEvent)
    local index = i  -- Number the RemoteEvents
    local autoRunEnabled = false
    local autoRunConnection

    -- Function to toggle Auto Run for each specific RemoteEvent
    local function toggleAutoRun()
        autoRunEnabled = not autoRunEnabled
        if autoRunEnabled then
            autoRunConnection = game:GetService("RunService").Stepped:Connect(function()
                remoteEvent:FireServer()
            end)
        elseif autoRunConnection then
            autoRunConnection:Disconnect()
            autoRunConnection = nil
        end
    end

    -- Create a frame for each event entry
    local eventFrame = Instance.new("Frame")
    eventFrame.Size = UDim2.new(1, -10, 0, 50)  -- Full width minus a margin, fixed height
    eventFrame.BackgroundTransparency = 1
    eventFrame.Parent = scrollingFrame

    -- Label to show the index and path
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(0.4, -5, 1, 0)  -- 40% width
    pathLabel.Position = UDim2.new(0, 0, 0, 0)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = string.format("[%d] %s", index, path)
    pathLabel.TextScaled = true
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pathLabel.Font = Enum.Font.SourceSans
    pathLabel.Parent = eventFrame

    -- Copy button
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.2, -5, 1, 0)  -- 20% width
    copyButton.Position = UDim2.new(0.4, 0, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    copyButton.Text = "Copy"
    copyButton.TextScaled = true
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.Parent = eventFrame

    copyButton.MouseButton1Click:Connect(function()
        copyToClipboard(path)
        print("Path copied to clipboard: " .. path)
    end)

    -- Run button
    local runButton = Instance.new("TextButton")
    runButton.Size = UDim2.new(0.2, 0, 1, 0)  -- 20% width
    runButton.Position = UDim2.new(0.6, 0, 0, 0)
    runButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    runButton.Text = "Run"
    runButton.TextScaled = true
    runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    runButton.Font = Enum.Font.SourceSansBold
    runButton.Parent = eventFrame

    runButton.MouseButton1Click:Connect(function()
        remoteEvent:FireServer()
        print("RemoteEvent triggered: " .. path)
    end)

    -- Auto Run button
    local autoRunButton = Instance.new("TextButton")
    autoRunButton.Size = UDim2.new(0.2, 0, 1, 0)  -- 20% width
    autoRunButton.Position = UDim2.new(0.8, 0, 0, 0)
    autoRunButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    autoRunButton.Text = "Auto Run: OFF"
    autoRunButton.TextScaled = true
    autoRunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoRunButton.Font = Enum.Font.SourceSansBold
    autoRunButton.Parent = eventFrame

    autoRunButton.MouseButton1Click:Connect(function()
        toggleAutoRun()
        if autoRunEnabled then
            autoRunButton.Text = "Auto Run: ON"
            autoRunButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            autoRunButton.Text = "Auto Run: OFF"
            autoRunButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

-- Adjust the CanvasSize of the ScrollingFrame based on the content size
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)

-- Handle collapse button logic
collapseButton.MouseButton1Click:Connect(function()
    if scrollingFrame.Visible then
        scrollingFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 350, 0, 30)  -- Collapse to just the title bar height
        collapseButton.Text = "+"
    else
        scrollingFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 350, 0, 400)  -- Expand back to original size
        collapseButton.Text = "-"
    end
end)
