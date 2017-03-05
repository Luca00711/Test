if CLIENT then
CreateClientConVar( "cl_connectsound", "1", true, false )
local function DispatchChatJoinMSG(um)
	local ply = um:ReadString()
	local mode = um:ReadString()
	local id = um:ReadString()

	if mode == "1" then
		chat.AddText(Color(72,72,72),"[SERVER] ",Color(145,145,145),ply,Color(235, 235, 235),", ",Color(0, 127, 127)," Joint ",Color(235, 235, 235),"den Server!")
		if GetConVarNumber( "cl_connectsound" ) == 1 then
			surface.PlaySound("buttons/combine_button3.wav")
		end
	elseif mode == "2" then
		chat.AddText(Color(72,72,72),"[SERVER] ",Color(145,145,145),ply,Color(235, 235, 235),", hat",Color(0, 127, 31)," Hat fertig geladen")
		print("("..id..")")
	elseif mode == "3" then
		chat.AddText(Color(72,72,72),"[SERVER] ",Color(145,145,145),ply,Color(235, 235, 235),",",Color(255, 30, 30)," Verlässt ",Color(235, 235, 235),"den Server!")
		print("("..id..")")
		if GetConVarNumber( "cl_connectsound" ) == 1 then
		surface.PlaySound("buttons/combine_button2.wav")
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
