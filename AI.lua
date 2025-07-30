-- 💣 KRNL Greg GUI Injector - Force Visible
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ChatEvent = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")

local GREG_ENDPOINT = "https://8e4ea171f3e4.ngrok-free.app/respond"

-- Make sure CoreGui is writable
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("GregGUI") then
    CoreGui:FindFirstChild("GregGUI"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GregGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Container
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 50)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Input box
local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 300, 0, 30)
input.Position = UDim2.new(0, 10, 0, 10)
input.PlaceholderText = "Talk to Greg™"
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.Parent = frame

-- Send button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 30)
button.Position = UDim2.new(0, 315, 0, 10)
button.Text = "Send"
button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Parent = frame

-- Interaction
button.MouseButton1Click:Connect(function()
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
