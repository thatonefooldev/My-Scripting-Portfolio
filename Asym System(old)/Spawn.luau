local Methods = {}

local DataStore = game:GetService("DataStoreService")

local CharecterFolder = game.ReplicatedStorage.Charecters
local Characters = {
["Zombie"] = {},
["Construct"] = {}, 
["Spirit"] = {},
["Alien"] = {Role = "Killer",Male = CharecterFolder.Killer.Male.Alien,Female = CharecterFolder.Killer.Female.Alien,WalkSpeed = 10,SprintSpeed = 20, MaxStam = 110,StaminaGain = 20,StaminaDrain = 10,MaxHp = 1500},
["SerialKiller"] = {},
["TestRig"] = {Role = "Survivor",Male = CharecterFolder.TestRig,Female = CharecterFolder.TestRig,WalkSpeed = 5,SprintSpeed = 28, MaxStam = 110,StaminaGain = 20,StaminaDrain = 10,MaxHp = 9999}
}

local MetaTableMethodList = {

}
	
	
	
	
	


function Methods:Spawn(Player, GameCharecter)
	local PlrCharecter = Player.Character
	local GameCharecterTable = Characters[GameCharecter]
	local MetaCharecterTable = setmetatable(GameCharecterTable,MetaTableMethodList)
	
	local OnJoinData = DataStore:GetDataStore("OnJoinData"):GetAsync(tostring(Player.UserId))
	local CosmeticData = DataStore:GetDataStore("CosmeticData"):GetAsync(tostring(Player.UserId))
	
	local CosGender = CosmeticData.Gender
	
	local Model = MetaCharecterTable[CosGender]:Clone()
	
	if not Model:FindFirstChild("Animate") then
		
		game.ReplicatedStorage.Animate:Clone().Parent = Model
		
	end
	
	Model.Name = Player.Name
	Player.Character = Model
	Model.Parent = game.Workspace 
	Model:PivotTo(PlrCharecter.HumanoidRootPart.CFrame)
	PlrCharecter = Model
	
	local CharecterValue = Player:FindFirstChild("GameCharecter") or Instance.new("StringValue")
	CharecterValue.Name = "GameCharecter"
	CharecterValue.Value = GameCharecter
	CharecterValue.Parent = Player
	
	PlrCharecter.Humanoid.MaxHealth = GameCharecterTable.MaxHp
	PlrCharecter.Humanoid.Health = GameCharecterTable.MaxHp
	
	PlrCharecter.Humanoid.WalkSpeed = GameCharecterTable.WalkSpeed
	
	local MovementScript = script.Movement:Clone()
	MovementScript.Parent = PlrCharecter
	
	MovementScript:SetAttribute("WalkSpeed",MetaCharecterTable.WalkSpeed)
	MovementScript:SetAttribute("SprintSpeed",MetaCharecterTable.SprintSpeed)
	MovementScript:SetAttribute("MaxStamina",MetaCharecterTable.MaxStam)
	MovementScript:SetAttribute("StaminaGain",MetaCharecterTable.StaminaGain)
	MovementScript:SetAttribute("StaminaDrain",MetaCharecterTable.StaminaDrain)
	
	MovementScript.Enabled = true
	
	
	local AbilitiesModule = require(script.Parent.Abilities)
	AbilitiesModule.ActivatePlayerAbilities(Player,GameCharecter)
	
end

return Methods
