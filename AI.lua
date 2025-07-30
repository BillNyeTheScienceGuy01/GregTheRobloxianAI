-- Greg AI Chat + Chat Bubble Injector KRNL Edition
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Ensure GregChatEvent RemoteEvent exists (server chat hook)
local GregChatEvent = ReplicatedStorage:FindFirstChild("GregChatEvent")
if not GregChatEvent then
    GregChatEvent = Instance.new("RemoteEvent")
    GregChatEvent.Name = "GregChatEvent"
    GregChatEvent.Parent = ReplicatedStorage
end

-- Ensure GregChatBubble RemoteEvent exists (client bubble chat)
local GregChatBubble = ReplicatedStorage:FindFirstChild("GregChatBubble")
if not GregChatBubble then
    GregChatBubble = Instance.new("RemoteEvent")
    GregChatBubble.Name = "GregChatBubble"
    GregChatBubble.Parent = ReplicatedStorage
end

-- Client-side bubble display handler
GregChatBubble.OnClientEvent:Connect(function(fromPlayer, msg)
    local char = fromPlayer.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Remove old bubble if present
    local oldBubble = head:FindFirstChild("GregBubble")
    if oldBubble then oldBubble:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GregBubble"
    billboard.Size = UDim2.new(5, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.TextWrapped = true
    textLabel.Text = msg
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.Font = Enum.Font.Arcade
    textLabel.Parent = billboard

    task.delay(5, function()
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end)
end)

-- Get HTTP exploit function
local function getHttpRequest()
    return http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
end

local httpRequest = getHttpRequest()
local GREG_ENDPOINT = "https://fd8277848be7.ngrok-free.app/respond"

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GregGUI_KRNL"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 140)
frame.Position = UDim2.new(0.5, -160, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(15,15,15)
title.BorderSizePixel = 0
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.Arcade
title.TextSize = 24
title.Text = "Greg™ KRNL Chat"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 50)
inputBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
inputBox.BorderSizePixel = 0
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.ClearTextOnFocus = false
inputBox.PlaceholderText = "Ask Greg™ anything..."
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 18
inputBox.Parent = frame

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 30)
sendButton.Position = UDim2.new(0, 10, 0, 90)
sendButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
sendButton.BorderSizePixel = 0
sendButton.TextColor3 = Color3.new(1,1,1)
sendButton.Font = Enum.Font.SciFi
sendButton.Text = "Unleash Greg™"
sendButton.TextSize = 18
sendButton.Parent = frame

sendButton.MouseButton1Click:Connect(function()
    local msg = inputBox.Text
    if msg == "" then return end
    inputBox.Text = ""

    if not httpRequest then
        warn("[Greg™]: No supported HTTP request function found.")
        return
    end

    local success, response = pcall(function()
        return httpRequest({
            Url = GREG_ENDPOINT,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                prompt = player.Name .. ": " .. msg
            })
        })
    end)

    if success and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        local reply = data.reply or "Greg blacked out mid-thought."

        -- Fire server chat event for official chat system
        GregChatEvent:FireServer("[Greg™]: " .. reply)
        -- Fire bubble event for everyone to see
        GregChatBubble:FireAllClients(player, "[Greg™]: " .. reply)
    else
        warn("[Greg™]: HTTP request failed.", response)
    end
end)
