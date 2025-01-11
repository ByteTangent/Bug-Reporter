--[[
 - Add this to StarterPlayerScripts or StarterGui
IMPORTANT: Initialize this module by calling the Init() function

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Tweeninfo = TweenInfo.new(0.1,Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false, 0)

local SEVERE_BTN_CONNECTION = nil
local SELECTCAT_BTN_CONNECTION = nil

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	
	self.BugReportUI = self.PlayerGui:WaitForChild("BugReportUI")
	
	self.BugCategory = ""
	self.BugTitle = ""
	self.BugDescription = ""
	self.SevereBug = false
	
	self.LocalDebounce = false
	
	self.MainFrameSize = self.BugReportUI.MainFrame.Size
	
	return self
end

function module:Init()
	self.BugReportUI.OpenBugReport.MouseButton1Down:Connect(function()
		self:OpenMenu()
	end)
end

function module:OpenMenu()
	local Tween = TweenService:Create(self.BugReportUI.MainFrame, Tweeninfo, {Size = self.MainFrameSize})
	
	self.BugReportUI.MainFrame.Size = UDim2.new(0,0,0,0)
	self.BugReportUI.MainFrame.Visible = true
	
	Tween:Play()
	Tween.Completed:Wait()
	
	self:SelectCategory()
	self:ToggleSevereBox()
	
	self.BugReportUI.MainFrame.SubmitBtn.MouseButton1Down:Connect(function()
		self:SendDataToServer()
	end)
	
	self.BugReportUI.MainFrame.CancelBtn.MouseButton1Down:Connect(function()
		self:CloseMenu()
	end)
end

function module:SelectCategory()
	print("sel cat")
	if SELECTCAT_BTN_CONNECTION then SELECTCAT_BTN_CONNECTION:Disconnect() end
	for _, btn in pairs(self.BugReportUI.MainFrame.BugCategoryFrame:GetChildren()) do
		if btn:IsA("TextButton") then
		SELECTCAT_BTN_CONNECTION =	btn.MouseButton1Down:Connect(function()
				print("Press")
				self.BugCategory = btn.Name
				self.BugReportUI.MainFrame.CategoryText.Text = [[Bug Category: <font color="#ff1a1e"><b>]]..self.BugCategory..[[</b></font>]]
				print(self.BugReportUI.MainFrame.CategoryText.Text)
			end)
		end
	end
end

function module:ToggleSevereBox()
	if SEVERE_BTN_CONNECTION then SEVERE_BTN_CONNECTION:Disconnect() end
	
 SEVERE_BTN_CONNECTION = self.BugReportUI.MainFrame.SevereBugFrame.Toggle.MouseButton1Down:Connect(function()
		print("PRESSSSSS")
		if self.SevereBug == false and self.BugReportUI.MainFrame.SevereBugFrame.CheckboxBlank.Visible == true then
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxBlank.Visible = false
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxFilled.Visible = true
			self.SevereBug = true
			
		elseif self.SevereBug == true and self.BugReportUI.MainFrame.SevereBugFrame.CheckboxFilled.Visible == true then
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxBlank.Visible = true
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxFilled.Visible = false
			self.SevereBug = false
		else
			print("[BugReportClient]: Something went wrong. Resetting toggle", self.SevereBug)
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxBlank.Visible = true
			self.BugReportUI.MainFrame.SevereBugFrame.CheckboxFilled.Visible = false
			self.SevereBug = false
		end
	end)
end

function module:SendDataToServer()
	if not self.LocalDebounce then
		self.LocalDebounce = true
		
		if self.BugCategory == "" or self.BugCategory == " " then 
			self.BugReportUI.MainFrame.FillCategory.Visible = true
			return
		end
		
		if self.BugReportUI.MainFrame.BugTitle.Text == "" or self.BugReportUI.MainFrame.BugTitle.Text == " " then
			self.BugReportUI.MainFrame.FillTitle.Visible = true
			return
		end
		
		if self.BugReportUI.MainFrame.BugDesc.Text == "" or self.BugReportUI.MainFrame.BugDesc.Text == " " then
			self.BugReportUI.MainFrame.FillDesc.Visible = true
			return
		end

		local Data = {}

		Data.BugCategory = self.BugCategory
		Data.BugTitle = self.BugReportUI.MainFrame.BugTitle.Text
		Data.BugDescription = self.BugReportUI.MainFrame.BugDesc.Text
		Data.SevereBug = self.SevereBug

		ReplicatedStorage.RemoteEvents.SendBugData:FireServer(Data)
		print("[BugReportClient]: Sent data to server, resetting...", Data)
		self:CloseMenu()
		
		task.wait(4)
		self.LocalDebounce = false
	end
end

function module:CloseMenu()
	local Tween = TweenService:Create(self.BugReportUI.MainFrame, Tweeninfo, {Size = UDim2.new(0,0,0,0)})
	Tween:Play()
	Tween.Completed:Wait()
	self.BugReportUI.MainFrame.Visible = false
	self:ResetData()
end

function module:ResetData()
	self.BugCategory = ""
	self.BugTitle = ""
	self.BugDescription = ""
	self.SevereBug = false
	
	self.BugReportUI.MainFrame.BugTitle.Text = ""
	self.BugReportUI.MainFrame.BugDesc.Text = ""
	self.BugReportUI.MainFrame.CategoryText.Text = "Bug Category: "
	
	self.BugReportUI.MainFrame.SevereBugFrame.CheckboxBlank.Visible = true
	self.BugReportUI.MainFrame.SevereBugFrame.CheckboxFilled.Visible = false
	
	print("[BugReportClient]: Reset!")
end

return module
