		end
	end
end
usermessage.Hook("DispatchChatJoin", DispatchChatJoinMSG)
end

if SERVER then
local function PlyConnectMSG( name )
	umsg.Start("DispatchChatJoin")
		umsg.String(name)
		umsg.String("1")
	umsg.End()
end
hook.Add( "PlayerConnect", "PlyConnectMSG", PlyConnectMSG )

local function PlyLoadedMSG( ply )
	timer.Simple(5, function() --Let the player load you noodle!
		if ply:IsValid() then
			umsg.Start("DispatchChatJoin")
				umsg.String(ply:GetName())
				umsg.String("2")
				umsg.String(ply:SteamID())
			umsg.End()
		end
	end)
end
hook.Add( "PlayerInitialSpawn", "PlyLoadedMSG", PlyLoadedMSG )

local function PlyDisconnectMSG( ply )
	umsg.Start("DispatchChatJoin")
		umsg.String(ply:GetName())
		umsg.String("3")
		umsg.String(ply:SteamID())
	umsg.End()
end
hook.Add( "PlayerDisconnected", "PlyDisconnectMSG", PlyDisconnectMSG )
end
