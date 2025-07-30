-- Minimal Nexus GUI embed (only what we need)
local NexusGui = {}
NexusGui.__index = NexusGui

function NexusGui:CreateWindow()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundColor3 = Color3.fromRGB(20,20,20)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Text = "Greg™ Chat"
    title.Parent = frame

    local self = setmetatable({
        ScreenGui = screenGui,
        Frame = frame,
        Title = title,
        Components = {}
    }, NexusGui)

    return self
end

function NexusGui:AddTextBox(self)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(40,40,40)
    input.BorderSizePixel = 0
    input.TextColor3 = Color3.fromRGB(255,255,255)
    input.ClearTextOnFocus = false
    input.PlaceholderText = "Talk to Greg™"
    input.Parent = self.Frame

    table.insert(self.Components, input)
    self.TextBox = input
    return input
end

function NexusGui:AddButton(self)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 75)
    button.BackgroundColor3 = Color3.fromRGB(0,120,255)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Text = "Send"
    button.Parent = self.Frame

    table.insert(self.Components, button)
    self.Button = button
    return button
end

function NexusGui:SetTitle(self, text)
    self.Title.Text = text
end

function NexusGui:GetText(self)
    if self.TextBox then
        return self.TextBox.Text
    end
    return ""
end

function NexusGui:SetText(self, text)
    if self.TextBox then
        self.TextBox.Text = text
    end
end

-- Now the Greg AI injector logic

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ChatEvent = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")

local GREG_ENDPOINT = "https://8e4ea171f3e4.ngrok-free.app/respond"

local window = NexusGui:CreateWindow()
local input = NexusGui:AddTextBox(window)
local sendButton = NexusGui:AddButton(window)

sendButton.MouseButton1Click:Connect(function()
    local msg = input.Text
    if msg == "" then return end
    input.Text = ""

    local success, response = pcall(function()
        return HttpService:PostAsync(GREG_ENDPOINT, HttpService:JSONEncode({
            prompt = player.Name .. ": " .. msg
        }), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        local reply = data.reply or "Greg is asleep 😴"
        ChatEvent:FireServer("[Greg™]: " .. reply, "All")
    else
        ChatEvent:FireServer("[Greg™]: error contacting Greg's brain 💀", "All")
    end
end)
