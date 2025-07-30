-- Minimal Nexus GUI embed (clean and fixed)
local NexusGui = {}
NexusGui.__index = NexusGui

function NexusGui.new()
    local guiParent = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not guiParent then
        guiParent = game:GetService("CoreGui") -- fallback if PlayerGui doesn’t exist yet
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(0.5, -150, 0.5, -60)
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

function NexusGui:AddTextBox()
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(40,40,40)
    input.BorderSizePixel = 0
    input.TextColor3 = Color3.fromRGB(255,255,255)
    input.ClearTextOnFocus = false
    input.PlaceholderText = "Talk to Greg™"
    input.Text = ""
    input.Font = Enum.Font.SourceSans
    input.TextSize = 18
    input.Parent = self.Frame

    table.insert(self.Components, input)
    self.TextBox = input
    return input
end

function NexusGui:AddButton()
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(0,120,255)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Text = "Send"
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = self.Frame

    table.insert(self.Components, button)
    self.Button = button
    return button
end

function NexusGui:SetTitle(text)
    self.Title.Text = text
end

function NexusGui:GetText()
    if self.TextBox then
        return self.TextBox.Text
    end
    return ""
end

function NexusGui:SetText(text)
    if self.TextBox then
        self.TextBox.Text = text
    end
end

-- ========== Greg AI Inject Logic ==========
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Check if DefaultChatSystemChatEvents exists
local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
local ChatEvent = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")

local GREG_ENDPOINT = "https://8e4ea171f3e4.ngrok-free.app/respond"

local gui = NexusGui.new()
local inputBox = gui:AddTextBox()
local sendButton = gui:AddButton()

sendButton.MouseButton1Click:Connect(function()
    local msg = inputBox.Text
    if msg == "" then return end
    inputBox.Text = ""

    local success, response = pcall(function()
        return HttpService:PostAsync(GREG_ENDPOINT, HttpService:JSONEncode({
            prompt = player.Name .. ": " .. msg
        }), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        local reply = data.reply or "Greg is asleep 😴"

        if ChatEvent then
            ChatEvent:FireServer("[Greg™]: " .. reply, "All")
        else
            warn("SayMessageRequest not found. Greg can't speak.")
        end
    else
        if ChatEvent then
            ChatEvent:FireServer("[Greg™]: error contacting Greg's brain 💀", "All")
        end
        warn("Failed to reach Greg endpoint:", response)
    end
end)
