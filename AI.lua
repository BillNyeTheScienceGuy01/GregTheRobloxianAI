-- Greg AI Chat Injector KRNL Edition
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Make sure this RemoteEvent exists or create it (KRNL can do this)
local GregChatEvent = ReplicatedStorage:FindFirstChild("GregChatEvent")
if not GregChatEvent then
    GregChatEvent = Instance.new("RemoteEvent")
    GregChatEvent.Name = "GregChatEvent"
    GregChatEvent.Parent = ReplicatedStorage
end

local function getHttpRequest()
    return http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
end

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

local GREG_ENDPOINT = "https://8e4ea171f3e4.ngrok-free.app/respond"
local httpRequest = getHttpRequest()

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

        GregChatEvent:FireServer("[Greg™]: " .. reply)
    else
        warn("[Greg™]: HTTP request failed.", response)
    end
end)
