local AbilityScript = require(game.ServerScriptService.Abilities)
local RemoteFunction = game:GetService("ReplicatedStorage").Remotes.RemoteFunctions.AbilityRemoteFunction

RemoteFunction.OnServerInvoke = function(player,AbilityKey)
	AbilityScript.UseAbility(AbilityKey,player)
end