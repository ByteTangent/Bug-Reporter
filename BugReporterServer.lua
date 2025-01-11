--[[
 - Add this to ServerScriptStorage
IMPORTANT: Initialize this module by calling the Init() function

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpsService = game:GetService("HttpService")

-- Change the URL game to game
local URL = "" -- Add your webhook URL

local module = {}
module.__index = module

local Queue = {}
local Running = false

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = ""
	self.Data = {}
	
	return self
end

function module:Init()
	ReplicatedStorage:WaitForChild("RemoteEvents").SendBugData.OnServerEvent:Connect(function(player, Data)
		self.Player = player
		self.Data = Data
		
		self.Data.PlayerName = self.Player.Name
		self.Data.UserId = self.Player.UserId
		
		self:PushToQueue()
	end)
end

function module:PushToQueue()
	Queue = {}
	table.insert(Queue, self.Data)
	
	print("[BugReportServer]: Sending data to webhook...")
	self:SendData()
end

-- Unpacks the data.
-- Data includes player username and userid, Bug Category, Bug type, Bug title, Bug description
local function UnpackData(Player:Player, Data)
	local color
	local Type = ""
	
	if Data.SevereBug == true then
		color = tonumber(0xFF0000)
		Type = "[SEVERE]"
	else
		color = tonumber(0xFFFF00)
	end
	
	local Final = {
		["embeds"] = {{
			
			["author"] = {
				["name"] = Player.Name,
				["icon_url"] = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username="..Player.Name,
				
			},
			["description"] = Type.." BUG REPORT: "..Player.Name,
			["color"] = color,
			
			["fields"] = {
				{
					["name"] = "Bug Severity:",
					["value"] = Data.SevereBug,
					["color"] = tonumber(0xFF0000),
					["inline"] = false,
				},
				{
					["name"] = "Bug Category:",
					["value"] = Data.BugCategory,
					["inline"] = false,
				},
				{
					["name"] = "Bug Title:",
					["value"] = Data.BugTitle,
					["inline"] = false,
				},
				{
					["name"] = "Bug Description:",
					["value"] = Data.BugDescription,
					["inline"] = false,
				},
				
			}
				
			
		}}
	}
	
	return Final
end

function module:SendData()
	local DataSend = UnpackData(self.Player,self.Data)
	
	print(DataSend)
	local PackData = HttpsService:JSONEncode(DataSend)
	HttpsService:PostAsync(URL, PackData)
	print("[BugReportServer]: Data was sent to webhook")

end

return module
