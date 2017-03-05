------------------------- IHL Hudaddons --------------------------
-- IHalo Hud v1.1 - by Darken217								--
------------------------------------------------------------------
-- Please do NOT use any of my code without further permission! --
------------------------------------------------------------------
-- Draws the hud by hooking into render order every frame.		--
-- Determins precached files and (c)vars during the autorun.	--
------------------------------------------------------------------
-- Initialized via autorun.										--
------------------------------------------------------------------

AddCSLuaFile()

-- cvars --
CreateConVar( "ihl_hud_enable", "1", 128, "Updates status of placed sentinel turrets to the hud." )
CreateConVar( "ihl_hud_disabledefault", "1", 128, "Prevents drawing of classic hud health/ammo panels." )
CreateConVar( "ihl_hud_font_text", "CatahudText", 128, "The font, the hud's text panels should use. This is either the set font or one of gmod's default fonts." )
CreateConVar( "ihl_hud_font_stats", "CatahudStats", 128, "The font, the hud's stats and large numbers should use. This is either the set font or one of gmod's default fonts." )
CreateConVar( "ihl_hud_ammo_pos", "0", 128, "Switches the ammo panel's x-axis offset between left and right." )
CreateConVar( "ihl_hud_hbar_pos", "0", 128, "Show a target's health bar above the target." )
CreateConVar( "ihl_hud_sentinel", "0", 128, "Updates status of placed sentinel turrets to the hud." )
CreateConVar( "ihl_hud_showplayers", "0", 128, "Shows name, rank and ping of nearby players on the hud." )
CreateConVar( "ihl_hud_showkicon", "0", 128, "Shows the current weapon's killicon next to its name." )
CreateConVar( "ihl_hud_showclock", "0", 128, "Shows the current time and date on the hud." )
CreateConVar( "ihl_hud_showpower", "0", 128, "Show your battery's power level on the hud (useless for desktop PCs)." )
CreateConVar( "ihl_hud_showhbar", "1", 128, "Show target's health and status bar on the hud." )
CreateConVar( "ihl_hud_anim_angles", "1", 128, "Uses the player's eye angles for hud angle modulation." )
CreateConVar( "ihl_hud_anim_velo", "1", 128, "Moves hud panels on the screen, relatively to the player's current speed." )
CreateConVar( "ihl_hud_anim_flicker", "1", 128, "Hud panels, numbers and text start to flicker when health is below the set threshold." )
CreateConVar( "ihl_hud_anim_flicker_thold", "10", 128, "" )
CreateConVar( "ihl_hud_anim_onspawn", "1", 128, "The hud plays a boot-up animation, when the player spawns for the first time." )
CreateConVar( "ihl_hud_anim_onspawn_thold", "6", 128, "" )
CreateConVar( "ihl_hud_qs_enable", "0", 128, "Show quick settings when holding down the specified button" )
CreateConVar( "ihl_hud_qs_button", "", 128, "dem buttons, bro..." )
CreateConVar( "ihl_hud_ammonote", "0", 128, "Show ammo notifier, if the ammo count in the current clip is low or the clip is empty." )

-- precache --
resource.AddFile( "resource/fonts/subfont.ttf" )
resource.AddFile( "materials/vgui/ihl/icon_proc_corro.vmt" )
resource.AddFile( "materials/vgui/ihl/icon_proc_fire.vmt" )
resource.AddFile( "materials/vgui/ihl/icon_proc_ice.vmt" )
resource.AddFile( "materials/vgui/ihl/icon_proc_subm.vmt" )
resource.AddFile( "materials/vgui/ihl/icon_proc_resu.vmt" )
resource.AddFile( "materials/effects/screen_refract.vmt" )

local icon_corro = Material( "vgui/ihl/icon_proc_corro.vmt" )
local icon_fire = Material( "vgui/ihl/icon_proc_fire.vmt" )
local icon_ice = Material( "vgui/ihl/icon_proc_ice.vmt" )
local icon_resu = Material( "vgui/ihl/icon_proc_resu.vmt" )
local icon_subm = Material( "vgui/ihl/icon_proc_subm.vmt" )
local screen_refract = "effects/screen_refract.vmt"

-- time-shift variable for delay/lifetime computation --
local NextTick = 0

-- settings menu --
function IhlHudOptions( CPanel )

	CPanel:AddControl( "CheckBox", { Label = "Enable IHL Hud", Command = "ihl_hud_enable" } )

	CPanel:AddControl( "Header", { Description = "" } )
	CPanel:AddControl( "Header", { Description = "Visibility settings" } )
	CPanel:AddControl( "CheckBox", { Label = "Disable default Hud", Command = "ihl_hud_disabledefault" } )
	CPanel:AddControl( "Header", { Description = "" } )
	CPanel:AddControl( "Header", { Description = "Animations" } )
	CPanel:AddControl( "CheckBox", { Label = "Use the player's eye angles for hud angle modulation", Command = "ihl_hud_anim_angles" } )
	CPanel:AddControl( "CheckBox", { Label = "Use the player's speed for hud position modulation", Command = "ihl_hud_anim_velo" } )
	CPanel:AddControl( "CheckBox", { Label = "Numbers and text start to flicker when health is below 10", Command = "ihl_hud_anim_flicker" } )
	CPanel:NumSlider( "Hud-flicker health threshold.", "ihl_hud_anim_flicker_thold", 1, 100, 0 )
	CPanel:AddControl( "CheckBox", { Label = "Plays a 'boot-up animation', when spawning for the first time.", Command = "ihl_hud_anim_onspawn" } )
	CPanel:NumSlider( "Initialization duration (seconds)", "ihl_hud_anim_onspawn_thold", 1, 10, 0 )
	CPanel:AddControl( "Header", { Description = "" } )
	CPanel:AddControl( "Header", { Description = "Panels" } )
	CPanel:AddControl( "CheckBox", { Label = "Show the target's health and status bar.", Command = "ihl_hud_showhbar" } )
	CPanel:AddControl( "CheckBox", { Label = "Show a notifier next to your crosshair, if your current clip is either low on ammo or depleted.", Command = "ihl_hud_ammonote" } )
	CPanel:AddControl( "CheckBox", { Label = "Show the current weapon's killicon on the ammo display", Command = "ihl_hud_showkicon" } )
	CPanel:AddControl( "CheckBox", { Label = "Show the current time and date on the hud.", Command = "ihl_hud_showclock" } )
	CPanel:AddControl( "CheckBox", { Label = "Show your battery's power level on the hud (useless for desktop PCs).", Command = "ihl_hud_showpower" } )
	CPanel:AddControl( "CheckBox", { Label = "Show your own and nearby player's ping and server rank.", Command = "ihl_hud_showplayers" } )
	CPanel:AddControl( "Header", { Description = "" } )
	CPanel:AddControl( "Header", { Description = "Layout" } )
	CPanel:AddControl( "CheckBox", { Label = "Show a target's health bar above the target.", Command = "ihl_hud_hbar_pos" } )
	CPanel:AddControl( "CheckBox", { Label = "Show ammo panel on the right side", Command = "ihl_hud_ammo_pos" } )

	CPanel:AddControl( "Header", { Description = "" } )
	CPanel:AddControl( "Header", { Description = "Warning! Due to the static nature of fonts\n the panels may not scale well with the font you may pick." } )

	local font_text = {Label = "The font, the hud's text should use.", MenuButton = 0, Options={}, CVars = { "ihl_hud_font_text" }}
	font_text["Options"]["Bandal (default; broken)"] = { ihl_hud_font_text = "CatahudText" }
	font_text["Options"]["Engine debug"] = { ihl_hud_font_text = "DebugFixed" }
	font_text["Options"]["Engine debug (small)"] = { ihl_hud_font_text = "DebugFixedSmall" }
	font_text["Options"]["Engine default font"] = { ihl_hud_font_text = "Default" }
--	font_text["Options"]["Buttons and stuff..."] = { ihl_hud_font_text = "Marlett" }
	font_text["Options"]["Trebuchet MS (18px)"] = { ihl_hud_font_text = "Trebuchet18" }
	font_text["Options"]["Trebuchet MS (24px)"] = { ihl_hud_font_text = "Trebuchet24" }
	font_text["Options"]["Hud hint font (large)"] = { ihl_hud_font_text = "HudHintTextLarge" }
	font_text["Options"]["Hud hint font (small)"] = { ihl_hud_font_text = "HudHintTextSmall" }
	font_text["Options"]["Credits or centred messages"] = { ihl_hud_font_text = "CenterPrintText" }
	font_text["Options"]["Close caption (normal)"] = { ihl_hud_font_text = "CloseCaption_Normal" }
	font_text["Options"]["Close caption (bold)"] = { ihl_hud_font_text = "CloseCaption_Bold" }
	font_text["Options"]["Close caption (bold; italic)"] = { ihl_hud_font_text = "CloseCaption_BoldItalic" }
	font_text["Options"]["Standard chat font"] = { ihl_hud_font_text = "ChatFont" }
	font_text["Options"]["Target ID"] = { ihl_hud_font_text = "TargetID" }
	font_text["Options"]["Target ID (small)"] = { ihl_hud_font_text = "TargetIDSmall" }
--	font_text["Options"]["Dem iconz"] = { ihl_hud_font_text = "HL2MPTypeDeath" }
	font_text["Options"]["Debug budget label"] = { ihl_hud_font_text = "BudgetLabel" }
	font_text["Options"]["Hud selection font"] = { ihl_hud_font_text = "HudSelectionText" }
	font_text["Options"]["Gmod Derma (default)"] = { ihl_hud_font_text = "DermaDefault" }
	font_text["Options"]["Gmod Derma (bold)"] = { ihl_hud_font_text = "DermaDefaultBold" }
	font_text["Options"]["Gmod derma (large)"] = { ihl_hud_font_text = "DermaLarge" }

	CPanel:AddControl( "ComboBox", font_text )

	local font_stats = {Label = "The font, the hud's text should use.", MenuButton = 0, Options={}, CVars = { "ihl_hud_font_stats" }}
	font_stats["Options"]["Bandal (default; broken)"] = { ihl_hud_font_stats = "CatahudStats" }
	font_stats["Options"]["Engine debug"] = { ihl_hud_font_stats = "CatahudStatsCN" }
	font_stats["Options"]["Engine debug (small)"] = { ihl_hud_font_stats = "DebugFixed" }
	font_stats["Options"]["Engine default font"] = { ihl_hud_font_stats = "CatahudStatsVD" }
	font_stats["Options"]["Half-Life 2"] = { ihl_hud_font_stats = "CatahudStatsHL2" }
	font_stats["Options"]["Derma (thin)"] = { ihl_hud_font_stats = "CatahudStatsRbTh" }
	font_stats["Options"]["Derma (condensed)"] = { ihl_hud_font_stats = "CatahudStatsRbCo" }
	font_stats["Options"]["Derma"] = { ihl_hud_font_stats = "CatahudStatsRbMe" }
	font_stats["Options"]["Derma (bold)"] = { ihl_hud_font_stats = "CatahudStatsRbBo" }
	font_stats["Options"]["Garry's Mod"] = { ihl_hud_font_stats = "CatahudStatsCV" }
	font_stats["Options"]["Fixedsys"] = { ihl_hud_font_stats = "CatahudStatsFS" }

	CPanel:AddControl( "ComboBox", font_stats )

--	CPanel:AddControl( "CheckBox", { Label = "Show quick settings when pressing a certain button (I'd recommend to use the same button, you use for the context menu)", Command = "ihl_hud_qs_enable" } )
--	CPanel:AddControl( "Numpad", { Label = "Quick Settings", Command = "ihl_hud_qs_button", ButtonSize = 22 } )


end

-- add settings to spawn menu --
hook.Add( "PopulateToolMenu", "PopulateIhlHud", function()

	spawnmenu.AddToolMenuOption(
	"Utilities",
	"Darken217's Hud addons",
	"CustomMenu2",
	"IHalo Hud settings",
	"",
	"",
	IhlHudOptions
	)

end )

hook.Add( "PlayerSwitchWeapon", "NoticeWepSwitch", function( ply, oldWeapon, newWeapon )

end )

-- from down here, everything is clientsided --
if ( CLIENT ) then

-- custom fonts --
	surface.CreateFont( "CatahudStats",
	{
		font = "Bandal",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsHL2",
	{
		font = "HalfLife2",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsVD",
	{
		font = "Verdana",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsRbTh",
	{
		font = "Roboto Th",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsRbCo",
	{
		font = "Roboto Cn",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsRbMe",
	{
		font = "Roboto Lt",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsRbBo",
	{
		font = "Roboto",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsCV",
	{
		font = "Coolvetica",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsCN",
	{
		font = "Courier New",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudStatsFS",
	{
		font = "Fixedsys",
		size = 56,
		weight = 500
	})

	surface.CreateFont( "CatahudText",
	{
		font = "Bandal",
		size = 24,
		weight = 360
	})

-- dynamic health color and dynamically pulsing health colors --
function GetHealthColor( target )

	local alpha = 0
	local sine = math.sin( CurTime() * 8 )
	local sine2 = math.sin( CurTime() * 4 ) + 1.64

	if ( isnumber( target ) ) then
		if ( target < 30 ) then
			return Color( target * 2.55, target * 0.3, 50, math.sin( CurTime() * 16 ) * 200 )
		end
		return Color( target * 2.55, target * 0.3, 50, 200 )
	end

	if ( target == LocalPlayer() || target:GetOwner() == LocalPlayer() ) then
		alpha = 80
	else
		alpha = 200
	end

	if ( target:GetMaxHealth() <= 0 ) then
		return Color( 120, 125, 135, alpha )
	end

	if ( !target:IsPlayer() && !target:IsNPC() ) then
		return Color( 180, 185, 190, alpha )
	end

--	if ( target:IsNPC() && target:Disposition( LocalPlayer() ) == D_LI ) then
--		return Color( 120, 255, 80, alpha )
--	end

	if ( target:Health() >= target:GetMaxHealth() * 0.75 ) then
		return Color( 255, 30, 0, alpha )
	elseif( target:Health() < target:GetMaxHealth() * 0.75 && target:Health() >= target:GetMaxHealth() * 0.5 ) then
		return Color( 245, 15, 15, alpha )
	elseif( target:Health() < target:GetMaxHealth() * 0.5 && target:Health() >= target:GetMaxHealth() * 0.25 ) then
		return Color( sine2 * 100 + 100, sine2 * 10 + 10, sine2 * 20 + 20, alpha )
	elseif( target:Health() < target:GetMaxHealth() * 0.25 && target:Health() > 0 ) then
		return Color( sine * 180 + 8, sine * 20 + 8, sine * 90 + 8, alpha )
	elseif( target:Health() <= 0 ) then
		return Color( 0, 0, 0, 0 )
	end

end

-- custom draw function for filled circles --
function draw.Circle( x, y, radius, seg )

	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )

end

-- custom textured rect function --
function draw.StatIcon( x, y, mat, scale, color )

	if ( color ) then
		surface.SetDrawColor( color )
	else
		surface.SetDrawColor( 255, 255, 255, 200 )
	end
	surface.SetMaterial( mat )
	surface.DrawTexturedRect( x, y, scale, scale )

end

-- cvars, listed in qs radial menu --
local favs = {
	"ihl_hud_enable",
	"ihl_enable",
	"ihl_hud_ammo_pos",
	"ihl_hud_showplayers",
	"ihl_hud_sentinel",
	"sfw_debug_force_itemhalo",
	"ihl_hud_disabledefault"
}

-- to-be-hidden hud elements --
local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true
}

-- hide default hud --
hook.Add( "HUDShouldDraw", "CataHideLegacyHUD", function( name )

	local ihl_hud_enable = GetConVarNumber( "ihl_hud_enable" )
	local allowhide = GetConVarNumber( "ihl_hud_disabledefault" )

	if ( ihl_hud_enable == 1 && allowhide == 1 && hide[ name ] ) then return false end

end )

local ammo_pos_global = Vector( 0, 0, velo )
local velo = Vector( 0, 0, 0 )
local curang = Angle( 0, 0, 0 )
local shiftang = Angle( 0, 0, 0 )
local shiftang_stats = Angle( 0, 0, 0 )
local ammoscale = ScrW() / 3.5

-- the actual hud --
function DrawCataHud()

	local screen_w = ScrW()
	local screen_h = ScrH()

--	local scene_old = render.GetRenderTarget()
--	local scene_hud = GetRenderTarget( "_rt_FullFrameFB", screen_w, screen_h, false )

--	render.SetRenderTarget( scene_hud )
--	render.DrawScreenQuad()

	----------------------
	-- Global variables --
	----------------------

	-- cvars --
	local cl_drawhud = GetConVarNumber( "cl_drawhud" )
	local ihl_hud_enable = GetConVarNumber( "ihl_hud_enable" )
	local ihl_hud_font_text = GetConVarString( "ihl_hud_font_text" )
	local ihl_hud_font_stats = GetConVarString( "ihl_hud_font_stats" )
	local ihl_hud_pos_stats = GetConVarNumber( "ihl_hud_pos_stats" )
	local ihl_hud_pos_ammo = GetConVarNumber( "ihl_hud_ammo_pos" )
	local ihl_hud_pos_hbar = GetConVarNumber( "ihl_hud_hbar_pos" )
	local ihl_hud_ammonote = GetConVarNumber( "ihl_hud_ammonote" )
	local ihl_hud_sentinel = GetConVarNumber( "ihl_hud_sentinel" )
	local ihl_hud_showhbar = GetConVarNumber( "ihl_hud_showhbar" )
	local ihl_hud_players = GetConVarNumber( "ihl_hud_showplayers" )
	local ihl_hud_kicons = GetConVarNumber( "ihl_hud_showkicon" )
	local ihl_hud_clock = GetConVarNumber( "ihl_hud_showclock" )
	local ihl_hud_power = GetConVarNumber( "ihl_hud_showpower" )
	local ihl_hud_anim_angles = GetConVarNumber( "ihl_hud_anim_angles" )
	local ihl_hud_anim_velo = GetConVarNumber( "ihl_hud_anim_velo" )
	local ihl_hud_anim_flicker = GetConVarNumber( "ihl_hud_anim_flicker" )
	local ihl_hud_anim_flicker_thold = GetConVarNumber( "ihl_hud_anim_flicker_thold" )
	local ihl_hud_anim_onspawn = GetConVarNumber( "ihl_hud_anim_onspawn" )
	local ihl_hud_anim_onspawn_thold = GetConVarNumber( "ihl_hud_anim_onspawn_thold" )

	if ( cl_drawhud == 0 ) then return end
	if ( ihl_hud_enable == 0 ) then return end

	-- objects / entities --
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	local target = ply:GetEyeTrace().Entity

	-- resolutions --
	local alpha = 255
	local alpha2 = 180
	local width_1 = screen_w * 0.16 	-- 256 @ 1600x900
	local width_2 = screen_w * 0.2 	-- 320 @ 1600x900
	local width_3 = width_2 - 14 	-- 306 @ 1600x900
	local width_4 = width_1 - 14 	-- 242 @ 1600x900
	local statpanel_h = 32
	local statelement_h = statpanel_h - 14
	local sine_w = math.sin( CurTime() * math.random( -screen_w / 256, screen_w / 256 ) )
	local sine_h = math.sin( CurTime() * math.random( -screen_h / 256, screen_h / 256 ) )
	local painflicker = Vector( 0, 0 )

	if ( ihl_hud_anim_flicker == 1 ) && ( ply:Health() < ihl_hud_anim_flicker_thold ) then
		painflicker = Vector( sine_w, sine_h )
		alpha = math.random( 80, 220 )
		alpha2 = math.random( 160, 180 )
		width_1 = screen_w * 0.16 + sine_w
		width_2 = screen_w * 0.2 - sine_h
		width_3 = width_2 - 14
		width_4 = width_1 - 14
	end

	-- colors --
	local color_hud_bg = Color( 20, 20, 20, 120 )
	local color_hud_text = Color( 220, 220, 220, alpha )
	local color_hud_stats = Color( 220, 230, 255, alpha )
	local color_hud_stats_2 = Color( color_hud_stats.r / 2, color_hud_stats.b / 2, color_hud_stats.g / 2, alpha2 )

	-- fonts --
	local hud_font = "DermaDefault"
	local hud_font_bold = "DermaDefaultBold"
	local hud_font_stats = ihl_hud_font_stats --"CatahudStats"
	local hud_font_text = ihl_hud_font_text --"CatahudText"

	-- dynamic values --
	local playervelo = ply:GetVelocity()

	if ( ihl_hud_anim_velo == 1 ) then
	velo = math.Clamp( ( math.Round( ( math.abs( playervelo.y ) + math.abs( playervelo.x ) + math.abs( playervelo.z ) ) ) / 16 ), 0, 32 )
	end

	local distance = math.Round( ply:GetPos():Distance( ply:GetEyeTrace().HitPos ), 0 )
--	local vbob = math.sin( CurTime() * ( 1 + math.Round( velo / 5.5, 0 ) ) ) * ( velo / 4 )

	-- positions --
	if ( ihl_hud_pos_ammo == 0 ) then
		ammo_pos_global.x = 0
	else
		ammo_pos_global.x = screen_w * 0.53
	end
	local text_pos = Vector( 0, 0, velo )
	local cursor_x, cursor_y = input.GetCursorPos()

	-- angels --
	if ( ihl_hud_anim_angles == 1 ) then
		curang = Angle( cursor_x - screen_w / 2, 0, ( cursor_y - screen_h / 2 ) * 1.79 ) * 0.012 --Angle( cursor_x - screen_w * 0.5, 0, cursor_y + screen_h * -0.5 ) * 0.012
		shiftang = Angle( velo * 0.2, 0, velo * 0.2 + ply:EyeAngles().pitch / 4 + ply:EyeAngles().yaw * -0.075)
		shiftang_stats = ( Angle( -20, 0, 0 ) + Angle( 0, 0, -10 * ( ply:EyeAngles().pitch / 45 ) + ( velo / 10 ) ) ) + curang + Angle( 20 * -velo / 100, 0, 0 )
	end

	if ( distance >= 32000 ) then
		distance = "very far away..."
	end

	if ( wep ~= NULL && wep:GetClass() == "gmod_camera" ) then return end

--	if ( CurTime() <= 3.2 && math.sin( CurTime() * 64 ) < 0 ) then return end

	offset_sys = 0

	-----------
	-- Clock --
	-----------
	if ( ihl_hud_clock == 1 ) then
		cam.Start3D2D( Vector( screen_w / 3.5, screen_h - screen_h * 1.1, 0 ) + painflicker, Angle( 0, 0, 180 ) - shiftang_stats, 1 )
			clock_pos = Vector( text_pos.x - ( screen_w * 0.245 ) - math.abs( ply:EyeAngles().pitch * 0.8 ) - velo * 1.3, screen_h * 0.2 - ply:EyeAngles().pitch / 5 + offset_sys )

			draw.RoundedBox( 6, clock_pos.x, clock_pos.y - statpanel_h, 212, statpanel_h, color_hud_bg )
			draw.SimpleTextOutlined( os.date( "%X | %d/%m/%Y" , Timestamp ), hud_font_text, clock_pos.x + 8, clock_pos.y - 4, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

			offset_sys = 32

		cam.End3D2D()
	end

	---------------------
	-- Battery / Power --
	---------------------
	if ( ihl_hud_power == 1 ) then
		cam.Start3D2D( Vector( screen_w / 3.5, screen_h - screen_h * 1.1, 0 ) + painflicker, Angle( 0, 0, 180 ) - shiftang_stats, 1 )
			pwr_pos = Vector( text_pos.x - ( screen_w * 0.245 ) - math.abs( ply:EyeAngles().pitch * 0.8 ) - velo * 1.3, screen_h * 0.2 - ply:EyeAngles().pitch / 5 + offset_sys )

			local syspwr = system.BatteryPower()

			draw.RoundedBox( 6, pwr_pos.x, pwr_pos.y - statpanel_h * 0.85, 212, statpanel_h / 2, color_hud_bg )

			if ( syspwr <= 100 ) then
				draw.RoundedBox( 4, pwr_pos.x + 4, pwr_pos.y - 24, math.Clamp( 204 * ( syspwr / 100 ), 0, 204 ), 8, GetHealthColor( syspwr ) )
				draw.SimpleTextOutlined( syspwr.."%", hud_font_text, pwr_pos.x + 8, pwr_pos.y - 2, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			else
				draw.RoundedBox( 4, pwr_pos.x + 4, pwr_pos.y - 24, 204, 8, Color( 120, 200, 80, alpha2 ) )
				draw.SimpleTextOutlined( "charging...", hud_font_text, pwr_pos.x + 8, pwr_pos.y - 2, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end

		cam.End3D2D()
	end

	-----------------------
	-- Health/Suit panel --
	-----------------------
	cam.Start3D2D( Vector( screen_w / 3.5, screen_h / 1.5, 0 ) + painflicker, Angle( 0, 0, 180 ) - shiftang_stats, 1 )
		stats_pos = Vector( text_pos.x - ( screen_w * 0.245 ) - math.abs( ply:EyeAngles().pitch * 0.8 ) - velo, screen_h * 0.2 - ply:EyeAngles().pitch / 5 ) + painflicker
--		stats_pos = Vector( stats_pos.x + vbob / 4, stats_pos.y - vbob )
		offset = 16

		draw.RoundedBox( 6, stats_pos.x, stats_pos.y - statpanel_h - 10, width_2, statpanel_h, color_hud_bg )
		draw.RoundedBox( 6, stats_pos.x, stats_pos.y, width_2, statpanel_h, color_hud_bg )

		if ( ihl_hud_anim_onspawn == 1 && CurTime() < ihl_hud_anim_onspawn_thold ) then
			draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y + 7, width_3 * ( CurTime() / ihl_hud_anim_onspawn_thold ), statelement_h, Color( 180, 185, 190, 200 ) )
			if ( math.sin( CurTime() * 12 ) > 0 ) then
				draw.SimpleTextOutlined( "initializing...", hud_font_text, stats_pos.x + 32, stats_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end
		else
			if ( ply:Alive() ) then
				draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y + 7, math.Clamp( width_3 * ( ply:Health() / ply:GetMaxHealth() ), 0, width_3 ), statelement_h, GetHealthColor( ply ) )
			end

			if ( ply:Armor() <= 100 && ply:Armor() > 0 ) then
				draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y - statpanel_h - 4, width_3 * ( ply:Armor() / 100 ), statelement_h, Color( 20, 200, 255, 80 ) )
			elseif( ply:Armor() <= 200 && ply:Armor() > 0  ) then
				draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y - statpanel_h - 4, width_3, statelement_h, Color( 20, 200, 255, 40 ) )
				draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y - statpanel_h - 4, width_3 * ( ( ply:Armor() - 100 ) / 100 ), statelement_h, Color( 220, 80, 255, 60 ) )
			elseif( ply:Armor() > 200 ) then
				draw.RoundedBox( 4, stats_pos.x + 7, stats_pos.y - statpanel_h - 4, width_3, statelement_h, Color( 200, 20, 255, 80 ) )
			end

		--	draw.SimpleText( string.rep( "O", string.len( tostring( ply:Health() ) ) ), hud_font_stats, stats_pos.x + 32, stats_pos.y + 54, Color( 200, 220, 250, 32 ), 0, 4 )
			draw.SimpleTextOutlined( "Leben", hud_font_text, stats_pos.x - 32, stats_pos.y + 26, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			if ( ply:Alive() ) then
				draw.SimpleTextOutlined( math.Clamp( ply:Health(), 0, 4294967296 ), hud_font_stats, stats_pos.x + 32, stats_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			else
				draw.SimpleTextOutlined( "--", hud_font_stats, stats_pos.x + 32, stats_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
				if ( math.sin( CurTime() * 8 ) > 0 ) then
					draw.SimpleTextOutlined( "terminal injuries detected, death imminent", hud_font_text, stats_pos.x - 32, stats_pos.y + 52, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
				end
			end

		--	draw.SimpleText( string.rep( "O", string.len( tostring( ply:Armor() ) ) ), hud_font_stats, stats_pos.x + 32, stats_pos.y - 12, Color( 200, 220, 255, 32 ), 0, 4 )
			draw.SimpleTextOutlined( "Ruestung", hud_font_text, stats_pos.x - 32, stats_pos.y - 17, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			if ( ply:Alive() ) then
				draw.SimpleTextOutlined( ply:Armor(), hud_font_stats, stats_pos.x + 32, stats_pos.y - 12, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			else
				draw.SimpleTextOutlined( "--", hud_font_stats, stats_pos.x + 32, stats_pos.y - 12, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end


			if ( ply:GetNWBool( "edmg_corrosive" ) == true  ) then
				draw.StatIcon( stats_pos.x - 64, stats_pos.y - 114 - offset, icon_corro, 64 )
				draw.WordBox( 4, stats_pos.x, stats_pos.y - 96 - offset, "Corrosion", hud_font_bold, color_hud_bg, Color( 50, 220, 10, alpha ) )
				offset = offset + 42
			end

			if ( ply:GetNWBool( "bliz_frozen" ) == true ) then
				draw.StatIcon( stats_pos.x - 64, stats_pos.y - 114 - offset, icon_ice, 64 )
				draw.WordBox( 4, stats_pos.x, stats_pos.y - 96 - offset, "Ice", hud_font_bold, color_hud_bg, Color( 245, 240, 255, alpha ) )
				offset = offset + 42
			end

			if ( ply:IsOnFire() ) then
				draw.StatIcon( stats_pos.x - 64, stats_pos.y - 114 - offset, icon_fire, 64 )
				draw.WordBox( 4, stats_pos.x, stats_pos.y - 96 - offset, "Fire", hud_font_bold, color_hud_bg, Color( 250, 170, 80, alpha ) )
				offset = offset + 42
			end

			if ( IsValid( wep ) && wep:GetClass() == "sfw_saphyre" ) then
				draw.StatIcon( stats_pos.x - 64, stats_pos.y - 114 - offset, icon_resu, 64 )
				draw.WordBox( 4, stats_pos.x, stats_pos.y - 96 - offset, "Resurgence", hud_font_bold, color_hud_bg, Color( 80, 180, 255, alpha ) )
				offset = offset + 42
			end

			if ( ply:WaterLevel() == 3 ) then
				draw.StatIcon( stats_pos.x - 64, stats_pos.y - 114 - offset, icon_subm, 64 )
				draw.WordBox( 4, stats_pos.x, stats_pos.y - 96 - offset, "Submerged", hud_font_bold, color_hud_bg, Color( 120, 120, 255, alpha ) )
				offset = offset + 42
			end
		end
	cam.End3D2D()

	if ( ihl_hud_anim_onspawn == 1 && CurTime() < ihl_hud_anim_onspawn_thold ) then return end

	----------------
	-- Ammo panel --
	----------------
	if ( !ply:InVehicle() ) then
		ammoscale = Lerp( FrameTime() * 12, ammoscale, screen_w / 3.5 )
	else
		if ( ihl_hud_pos_ammo == 0 ) then
			ammoscale = Lerp( FrameTime() * 6, ammoscale, ( screen_w / 3.5 ) * -1 )
		else
			ammoscale = Lerp( FrameTime() * 6, ammoscale, ( screen_w / 3.5 ) * 2.4 )
		end
	end

	if ( IsValid( wep ) ) then
		cam.Start3D2D( ( Vector( ammoscale, screen_h / 1.5, 0 ) ) + painflicker, Angle( 0, 0, 180 ) + shiftang_stats, 1 )
			ammo_pos = Vector( ammo_pos_global.x, screen_h * 0.2 - ply:EyeAngles().pitch / 2 ) + painflicker
			if ( ammo_pos.x < screen_w * 0.16 ) then
				ammo_pos.x = ammo_pos.x - math.abs( ply:EyeAngles().pitch / 1.8 ) - velo * 2.25
			else
				ammo_pos.x = ammo_pos.x + math.abs( ply:EyeAngles().pitch * -1.2 ) + velo * 2.4 --1.4
				ammo_pos.y = screen_h * 0.2 - ply:EyeAngles().pitch / 5
			end

			local curclip =  tostring( wep:Clip1() )
			local curclip1 =  tostring( " / "..wep:GetMaxClip1() )
			local curammo1 = tostring( ply:GetAmmoCount( wep:GetPrimaryAmmoType() ) )
			local curammo2 = tostring( ply:GetAmmoCount( wep:GetSecondaryAmmoType() ) )

			draw.RoundedBox( 6, ammo_pos.x, ammo_pos.y, width_1, statpanel_h, color_hud_bg )

			if ( wep:GetClass() ~= "weapon_slam" ) && ( wep:Clip1() > 0 && ( wep:GetMaxClip1() ~= -1 && wep:GetMaxClip1() ~= 0 ) ) then
				draw.RoundedBox( 4, ammo_pos.x + 7, ammo_pos.y + 7, math.Clamp( width_4 * ( wep:Clip1() / wep:GetMaxClip1() ), 0, width_4 ), statelement_h, Color( 220, 225, 255, 80 ) )
			end

			draw.SimpleTextOutlined( "Munition", hud_font_text, ammo_pos.x - 32, ammo_pos.y + 25, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			draw.SimpleTextOutlined( wep:GetPrintName(), hud_font_text, ammo_pos.x - 32, ammo_pos.y - 17, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

			if( ihl_hud_kicons == 1 ) then
			killicon.Draw( ammo_pos.x + string.len( wep:GetPrintName() ) * 9, ammo_pos.y - 32, wep:GetClass(), 200 )
			end

			--print( wep:IsScripted(), istable( wep:CustomAmmoDisplay() ), wep:CustomAmmoDisplay().PrimaryAmmo )
			if ( !wep:IsScripted() || ( wep:IsScripted() && ( !istable( wep:CustomAmmoDisplay() ) || ( istable( wep:CustomAmmoDisplay() ) && wep:CustomAmmoDisplay().PrimaryAmmo ~= nil && wep:CustomAmmoDisplay().PrimaryAmmo >= 0 ) ) ) ) then
				if ( wep:GetClass() ~= "weapon_slam" ) then
					if ( wep:GetMaxClip1() > 0 ) then
						draw.SimpleTextOutlined( curclip, hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
						draw.SimpleTextOutlined( curclip1, hud_font_stats, ammo_pos.x + 27 * string.len( curclip ) + 24, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
						if ( ( wep:IsScripted() ) and ( wep.Primary.Ammo ~= "none" && wep.Primary.Ammo ~= "" ) ) then
							draw.SimpleTextOutlined( curammo1, hud_font_text, ammo_pos.x + 35, ammo_pos.y + 72, color_hud_stats, 0, 4 , 0.64, color_hud_stats_2)
						elseif ( !wep:IsScripted() ) then
							draw.SimpleTextOutlined( curammo1, hud_font_text, ammo_pos.x + 35, ammo_pos.y + 72, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
						end
					elseif ( !wep:IsScripted() && ( wep:GetMaxClip1() == -1 || wep:GetMaxClip1() == 0 ) && ( wep:GetPrimaryAmmoType() ~= "" && wep:GetPrimaryAmmoType() ~= -1 && wep:GetPrimaryAmmoType() ~= "none" ) ) then
						draw.SimpleTextOutlined( curammo1, hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					else
						draw.SimpleTextOutlined( "--", hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					end
				elseif ( wep:GetClass() == "weapon_slam" ) then
					draw.SimpleTextOutlined( curammo2, hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
				end
			elseif( wep:IsScripted() && istable( wep:CustomAmmoDisplay() ) && wep:GetMaxClip1() > 0 ) then
				draw.SimpleTextOutlined( wep:CustomAmmoDisplay().PrimaryClip, hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			elseif( wep:IsScripted() && ( !istable( wep:CustomAmmoDisplay() ) || ( istable( wep:CustomAmmoDisplay() ) && ( wep:GetMaxClip1() <= 0 || wep:CustomAmmoDisplay().PrimaryClip == nil || wep:CustomAmmoDisplay().PrimaryAmmo ~= nil ) ) ) ) then
				draw.SimpleTextOutlined( "--", hud_font_stats, ammo_pos.x + 32, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end

			if ( wep:GetClass() ~= "weapon_slam" ) && ( wep:GetSecondaryAmmoType() ~= "" && wep:GetSecondaryAmmoType() ~= -1 ) then
				draw.SimpleTextOutlined( "|", hud_font_stats, ammo_pos.x  + 56 + string.len( curclip1 ) * 30.5, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
				draw.SimpleTextOutlined( curammo2, hud_font_stats, ammo_pos.x  + 62 + string.len( curclip1 ) * 36, ammo_pos.y + 54, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end
		cam.End3D2D()
	end

	------------------
	-- Entity radar --
	------------------
--[[
	cam.Start3D2D( ( Vector( 0, 0, 0 ) ), Angle( 0, 0, 180 ) + shiftang_stats * -1, 1 )
		radar_pos = Vector( screen_w * 0.82 + math.abs( ply:EyeAngles().pitch / 1.8 ) + velo * 1.8, screen_h * 0.64 + ply:EyeAngles().pitch / 3 )

		surface.SetDrawColor( color_hud_bg )
		draw.NoTexture()
		draw.Circle( radar_pos.x, radar_pos.y, 128, 32 )
		draw.SimpleTextOutlined( "256x256 units", hud_font_text, radar_pos.x + 64, radar_pos.y + 132, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

		surface.DrawCircle( radar_pos.x, radar_pos.y, math.sin( CurTime() ) * 64 + 56, Color( 205, 225, 255, 180 ) )
		surface.DrawCircle( radar_pos.x, radar_pos.y, 128, Color( 205, 225, 255, 90 ) )
		surface.DrawCircle( radar_pos.x, radar_pos.y, 4, Color( 255, 225, 120, 90 ) )

		for k,v in pairs( ents.FindInSphere( ply:GetPos(), 256 ) ) do
			if ( ( v:IsNPC() || v:IsPlayer() ) && v ~= LocalPlayer() && v:GetPos():Distance( ply:GetPos() ) <= 256 ) then
				local tarpos = ( ( v:GetPos() - ply:GetPos() ) + Vector( radar_pos.x, radar_pos.y ) )
				surface.DrawCircle( tarpos.x, tarpos.y, 4, Color( 255, 40, 40, 90 ) )
			end
		end
	cam.End3D2D()
]]--

	-------------------------------
	-- Playerinfo and ping-meter --
	-------------------------------
	if ( !game.SinglePlayer() && gmod.GetGamemode().FolderName == "sandbox" && ihl_hud_players == 1 ) then
		cam.Start3D2D( ( Vector( screen_w * 0.2, screen_h * 0.3, 0 ) ) + painflicker, Angle( 0, 0, 180 ) + shiftang_stats * -1, 1 )
			plrinfo_pos = Vector( text_pos.x - ( screen_w / 6.5 ) - math.abs( ply:EyeAngles().pitch / 1.8 ) - velo * 1.8, screen_h * -0.1 - ply:EyeAngles().pitch / 3 )
			offset_plr = 32

			draw.RoundedBox( 4, plrinfo_pos.x, plrinfo_pos.y - 40, width_1, 64, color_hud_bg )
			draw.SimpleTextOutlined( ply:Nick(), hud_font_text, plrinfo_pos.x + 16, plrinfo_pos.y - 14, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			draw.SimpleTextOutlined( "Ping : "..ply:Ping(), hud_font_text, plrinfo_pos.x + 16, plrinfo_pos.y + 12, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

			if ( ply:IsAdmin() ) then
				draw.SimpleTextOutlined( "(Admin)", hud_font_text, plrinfo_pos.x + string.len( ply:Nick() ) + 112, plrinfo_pos.y - 14, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
			end

			for k,v in pairs( ents.FindInSphere( ply:GetPos(), 1024 ) ) do
				if ( v:IsPlayer() && v ~= ply ) then
					draw.RoundedBox( 4, plrinfo_pos.x, plrinfo_pos.y + offset_plr, width_1, 64, color_hud_bg )
					draw.SimpleTextOutlined( v:Nick(), hud_font_text, plrinfo_pos.x + 16, plrinfo_pos.y + 26 + offset_plr, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					draw.SimpleTextOutlined( "Ping : "..v:Ping(), hud_font_text, plrinfo_pos.x + 16, plrinfo_pos.y + 52 + offset_plr, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

					if ( v:IsAdmin() ) then
						draw.SimpleTextOutlined( "(Admin)", hud_font_text, plrinfo_pos.x + string.len( v:Nick() ) + 112, plrinfo_pos.y + 26 + offset_plr, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					end

					if ( v:IsBot() ) then
						draw.SimpleTextOutlined( "(Bot)", hud_font_text, plrinfo_pos.x + string.len( v:Nick() ) + 112, plrinfo_pos.y + 26 + offset_plr, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					end
					offset_plr = offset_plr + 72
				end
			end
		cam.End3D2D()
	end

	--------------------------------
	-- Sentinel turret info panel --
	--------------------------------
	if ( ihl_hud_sentinel == 1 ) then
		cam.Start3D2D( ( Vector( screen_w / 2, screen_h / 2, 0 ) ) + painflicker, Angle( 0, 0, 180 ) + shiftang_stats * -1, 1 )
			sentui_pos = Vector( text_pos.x + ( screen_w * 0.42 ) + math.abs( ply:EyeAngles().pitch / 1.8 ) + velo * 1.8, screen_h / 5 + ply:EyeAngles().pitch / 3 )
			offset_sent = 72

			for k,v in pairs( ents.FindByClass( "sfi_sentinel" ) ) do
				if ( v:GetOwner() == LocalPlayer() ) then
					if ( v:GetPos():Distance( v:GetOwner():GetPos() ) < 256 ) then
						sentui_pos = Vector( v:GetPos():ToScreen().x / 5 + math.abs( ply:EyeAngles().pitch / 1.8 ) + velo * 1.8, v:GetPos():ToScreen().y / 5 + ply:EyeAngles().pitch / 3 )
					end
					draw.RoundedBox( 4, sentui_pos.x, sentui_pos.y - 30 - offset_sent, ( screen_w * 0.081 ), 24, color_hud_bg )
					draw.RoundedBox( 4, sentui_pos.x + 4, sentui_pos.y - 26 - offset_sent, math.Clamp( ( screen_w * 0.081 - 8 ) * ( v:Health() / v:GetMaxHealth() ), 0, 128 ), 16, GetHealthColor( v ) )
					draw.SimpleTextOutlined( v:Health(), hud_font_text, sentui_pos.x - 16, sentui_pos.y - 7 - offset_sent, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

					draw.RoundedBox( 4, sentui_pos.x, sentui_pos.y - offset_sent, ( screen_w * 0.081 ), 24, color_hud_bg )
					draw.RoundedBox( 4, sentui_pos.x + 4, sentui_pos.y + 4 - offset_sent, ( screen_w * 0.081 - 8 ) * ( v:GetNWInt( "sent_ammo" ) / 960 ), 16, Color( 220, 225, 255, 80 ) )
					draw.SimpleTextOutlined( v:GetNWInt( "sent_ammo" ), hud_font_text, sentui_pos.x - 16, sentui_pos.y + 22 - offset_sent, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

					draw.SimpleTextOutlined( tostring( v ), hud_font_text, sentui_pos.x - 280, sentui_pos.y - 7 - offset_sent, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
					draw.SimpleTextOutlined( "Target: "..tostring( v:GetNWEntity( "TargetEnt" ) ), hud_font_text, sentui_pos.x - 280, sentui_pos.y + 22 - offset_sent, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )

					offset_sent = offset_sent + 72
				end
			end
		cam.End3D2D()
	end

	--------------------------
	-- Radial settings menu --
	--------------------------
	cam.Start3D2D( ( Vector( 0, 0, 0 ) ) + painflicker, Angle( 0, 0, 180 ) + curang, 1 )
		radsel_pos = Vector( screen_w / 2 + velo * 0.1, screen_h / 2 + velo * 0.1 )
		local radius = 256
		local segments = #favs - 1

		if ( GetConVarNumber( "ihl_hud_qs_enable" ) == 1 ) && ( input.IsKeyDown( GetConVarNumber( "ihl_hud_qs_button" ) ) || input.IsMouseDown( GetConVarNumber( "ihl_hud_qs_button" ) ) ) then
			surface.SetDrawColor( Color( 20, 20, 20, 0 ) )
			draw.NoTexture()

			local cir = {}

			table.insert( cir, { x = radsel_pos.x, y = radsel_pos.y, u = 0.5, v = 0.5 } )
			for i = 0, segments do
				local a = math.rad( ( i / segments ) * -360 )
				table.insert( cir, { x = radsel_pos.x + math.sin( a ) * radius, y = radsel_pos.y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
			end

			local a = math.rad( 0 )
			table.insert( cir, { x = radsel_pos.x + math.sin( a ) * radius, y = radsel_pos.y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

			surface.DrawPoly( cir )

				for k, v in SortedPairs ( cir ) do
					surface.DrawCircle( v.x, v.y, 8, Color( 220, 220, 220, 220 ) )
					surface.DrawLine( radsel_pos.x, radsel_pos.y, v.x, v.y )
					if ( Vector( v.x, v.y ):Distance( Vector( cursor_x, cursor_y ) ) <= 128 ) && ( isnumber( k ) && favs[k] ~= nil ) then
						surface.DrawCircle( v.x, v.y, 16, Color( 255, 240, 255, 220 ) )
						draw.WordBox( 4, v.x, v.y, favs[k].." ("..GetConVarNumber( favs[k] )..")", hud_font_bold, color_hud_bg, Color( 220, 220, 230, alpha ) )
						if ( input.IsMouseDown( MOUSE_LEFT ) && NextTick < CurTime() ) then
							RunConsoleCommand( favs[k], 1 )
							NextTick = CurTime() + 0.1
						end
						if ( input.IsMouseDown( MOUSE_RIGHT ) && NextTick < CurTime() ) then
							RunConsoleCommand( favs[k], 0 )
							NextTick = CurTime() + 0.1
						end
					end
				end

				draw.WordBox( 4, radsel_pos.x - 104, radsel_pos.y - screen_h / 3, "Mouse1 to enable, Mouse2 to disable", hud_font_bold, color_hud_bg, Color( 220, 220, 230, alpha ) )

			end
	cam.End3D2D()

	---------------------------
	-- SciFiACC to crosshair --
	---------------------------
	if ( IsValid( wep ) && string.StartWith( wep:GetClass(), "sfw_" ) ) then
		cam.Start3D2D( ( Vector( 0, 0, 0 ) ), Angle( 0, 0, 180 ) + curang, 1 )
			chair_pos = Vector( screen_w / 2 + velo * 0.1, screen_h / 2 + velo * 0.1 )

			surface.DrawCircle( chair_pos.x, chair_pos.y, 2 * (wep.SciFiACC * 2), Color( color_hud_text.r, color_hud_text.g, color_hud_text.b, 120 ) )

		cam.End3D2D()
	end

	----------------------------------
	-- SciFiWeapon's selection menu --
	----------------------------------
	if ( IsValid( wep ) && string.StartWith( wep:GetClass(), "sfw_" ) ) && ( GetConVarNumber( "sfw_debug_enable_hlr" ) == 1 ) && ( input.IsMouseDown( MOUSE_4 ) ) then
		cam.Start3D2D( ( Vector( 0, 0, 0 ) ) + painflicker, Angle( 0, 0, 180 ) + curang, 1 )
			radsel_pos = Vector( screen_w / 2 + velo * 0.1, screen_h / 2 + velo * 0.1 )
			local radius = 256
			local favs = wep.SciFiFamily
			local segments = #favs - 1

				surface.SetDrawColor( Color( 20, 20, 20, 0 ) )
				draw.NoTexture()

				local cir = {}

				table.insert( cir, { x = radsel_pos.x, y = radsel_pos.y, u = 0.5, v = 0.5 } )
				for i = 0, segments do
					local a = math.rad( ( i / segments ) * -360 )
					table.insert( cir, { x = radsel_pos.x + math.sin( a ) * radius, y = radsel_pos.y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
				end

				local a = math.rad( 0 )
				table.insert( cir, { x = radsel_pos.x + math.sin( a ) * radius, y = radsel_pos.y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

				surface.DrawPoly( cir )

					for k, v in SortedPairs ( cir ) do
						surface.DrawCircle( v.x, v.y, 8, Color( 220, 220, 220, 220 ) )
						surface.DrawLine( radsel_pos.x, radsel_pos.y, v.x, v.y )
						if ( v.y == screen_h / 2 ) then
							surface.DrawCircle( v.x, v.y, 32, Color( 220, 220, 220, 110 ) )
						else
							if ( Vector( v.x, v.y ):Distance( Vector( cursor_x, cursor_y ) ) <= 128 ) && ( favs[k] ~= nil ) then
								surface.DrawCircle( v.x, v.y, 16, Color( 255, 240, 255, 220 ) )
								draw.WordBox( 4, v.x, v.y, favs[k], hud_font_bold, color_hud_bg, Color( 220, 220, 230, alpha ) )
							end
						end
					end

					draw.WordBox( 4, radsel_pos.x - 104, radsel_pos.y - screen_h / 3, "Mouse1 to enable, Mouse2 to disable", hud_font_bold, color_hud_bg, Color( 220, 220, 230, alpha ) )
		cam.End3D2D()
	end

	-------------------------------------------------
	-- Target status bar, SciFiWeapons info panels --
	-------------------------------------------------
	cam.Start3D2D( ( Vector( screen_w / 2, screen_h / 2, text_pos.z ) ) + painflicker, Angle( 0, 0, 180 ) +  shiftang, 1 )
		text_left = ammo_pos_global.x - ( screen_w / 6 ) - math.abs( ply:EyeAngles().pitch / 2 )
		text_right = ammo_pos_global.x + ( screen_w / 8 ) + math.abs( ply:EyeAngles().pitch / 2 )
		text_top = ammo_pos_global.y - ( screen_h / 2.4 ) - math.abs( ply:EyeAngles().pitch / 2 )
		hbar_offset_x = -128 - width_2 / 8
		hight = 16
		offset = 16
		offset_top = 24

		if ( ihl_hud_showhbar == 1 ) then
			if ( ihl_hud_pos_hbar == 1 && IsValid( target ) && target:GetPos():Distance( ply:EyePos() ) <= 16000 ) then
				local tarpos = ( target:EyePos() + Vector( 0, 0, 4 - distance / 500 ) ):ToScreen()
				if ( tarpos.visible == true ) then
					--text_left = tarpos.x - math.abs( ply:EyeAngles().pitch / 2 )
					--text_right = tarpos.x + math.abs( ply:EyeAngles().pitch / 2 )
					text_top = tarpos.y - ( screen_h * 0.6 ) + math.abs( ply:EyeAngles().pitch / 2 )
					width_2 = screen_w * 0.08
					hbar_offset_x = -64
					hight = 8
				end
			end

			if ( IsValid( target ) && ( ( target:IsPlayer() || target:IsNPC() || ( target:GetClass() == "prop_physics" ) || ( target:GetClass() == "prop_physics_respawnable" ) || ( target:GetClass() == "prop_physics_multiplayer" ) ) && target:Health() > 0 ) ) then
				targetname = tostring( target )
				draw.RoundedBox( 4, hbar_offset_x - 5, text_top - 4, width_2 + 10, hight + 8, color_hud_bg )
				--draw.RoundedBox( 4, -128, text_top, 256, hight, Color( 80, 80, 80, alpha2 ) )

				if ( target:GetMaxHealth() > 0 ) then
				draw.RoundedBox( 4, hbar_offset_x, text_top, math.Clamp( width_2 * ( target:Health() / target:GetMaxHealth() ), 0, width_2 ) , hight, GetHealthColor( target ) )
				else
				draw.RoundedBox( 4, hbar_offset_x, text_top, width_2, hight, GetHealthColor( target ) )
				end

				if ( target:IsPlayer() && target:Armor() >= 1 ) then
					if ( target:Armor() <= 100 ) then
						draw.RoundedBox( 4, hbar_offset_x, text_top, width_2 * ( target:Armor() / 100 ), hight, Color( 20, 200, 255, 80 ) )
					elseif( target:Armor() <= 200 ) then
						draw.RoundedBox( 4, hbar_offset_x, text_top, width_2 * ( ( target:Armor() - 100 ) / 100 ), hight, Color( 20, 80, 255, 80 ) )
					elseif( target:Armor() > 200 ) then
						draw.RoundedBox( 4, hbar_offset_x, text_top, width_2, hight, Color( 200, 20, 255, 80 ) )
					end
				end

				if ( ihl_hud_pos_hbar == 0 ) then
					draw.SimpleTextOutlined( targetname, hud_font_bold, 0 - string.len( targetname ) * 3, text_top + 13, color_hud_stats, 0, 4, 0.64, color_hud_stats_2 )
				end

				if ( ihl_hud_pos_hbar == 0 ) then
					if ( target:GetNWBool( "edmg_corrosive" ) == true  ) then
						draw.StatIcon( hbar_offset_x - 40, text_top - 4 + offset_top, icon_corro, 32 )
						draw.WordBox( 4, hbar_offset_x - 5, text_top + 2 + offset_top, "Corrosion", hud_font_bold, color_hud_bg, Color( 50, 220, 10, alpha ) )
						offset_top = offset_top + 24
					end

					if ( target:GetNWBool( "bliz_frozen" ) == true ) then
						draw.StatIcon( hbar_offset_x - 40, text_top - 4 + offset_top, icon_ice, 32 )
						draw.WordBox( 4, hbar_offset_x - 5, text_top + 2 + offset_top, "Ice", hud_font_bold, color_hud_bg, Color( 245, 240, 255, alpha ) )
						offset_top = offset_top + 24
					end

					if ( target:IsOnFire() ) then
						draw.StatIcon( hbar_offset_x - 40, text_top - 4 + offset_top, icon_fire, 32 )
						draw.WordBox( 4, hbar_offset_x - 5, text_top + 2 + offset_top, "Fire", hud_font_bold, color_hud_bg, Color( 250, 170, 80, alpha ) )
						offset_top = offset_top + 24
					end

					if ( target:IsNPC() || target:IsPlayer() ) && ( IsValid( target:GetActiveWeapon() ) && target:GetActiveWeapon():GetClass() == "sfw_saphyre" ) then
						draw.StatIcon( hbar_offset_x - 40, text_top - 4 + offset_top, icon_resu, 32 )
						draw.WordBox( 4, hbar_offset_x - 5, text_top + 2 + offset_top, "Resurgence", hud_font_bold, color_hud_bg, Color( 80, 180, 255, alpha ) )
						offset_top = offset_top + 24
					end

					if ( target:WaterLevel() == 3 ) then
						draw.StatIcon( hbar_offset_x - 40, text_top - 4 + offset_top, icon_subm, 32 )
						draw.WordBox( 4, hbar_offset_x - 5, text_top + 2 + offset_top, "Submerged", hud_font_bold, color_hud_bg, Color( 120, 120, 255, alpha ) )
						offset_top = offset_top + 24
					end
				else
					if ( target:GetNWBool( "edmg_corrosive" ) == true  ) then
						draw.StatIcon( hbar_offset_x - 24 + offset_top, text_top + 12, icon_corro, 32, color_white )
						offset_top = offset_top + 24
					end

					if ( target:GetNWBool( "bliz_frozen" ) == true ) then
						draw.StatIcon( hbar_offset_x - 24 + offset_top, text_top + 12, icon_ice, 32, color_white )
						offset_top = offset_top + 24
					end

					if ( target:IsOnFire() ) then
						draw.StatIcon( hbar_offset_x - 24 + offset_top, text_top + 12, icon_fire, 32, color_white )
						offset_top = offset_top + 24
					end

					if ( target:IsNPC() || target:IsPlayer() ) && ( IsValid( target:GetActiveWeapon() ) && target:GetActiveWeapon():GetClass() == "sfw_saphyre" ) then
						draw.StatIcon( hbar_offset_x - 24 + offset_top, text_top + 12, icon_resu, 32, color_white )
						offset_top = offset_top + 24
					end

					if ( target:WaterLevel() == 3 ) then
						draw.StatIcon( hbar_offset_x - 24 + offset_top, text_top + 12, icon_subm, 32, color_white )
						offset_top = offset_top + 24
					end
				end
			end
		end

		if ( IsValid( wep ) ) then
			if ( ihl_hud_ammonote == 1 ) then
				if ( wep:GetNWBool( "IsReloading" ) == false && wep:Clip1() <= wep:GetMaxClip1() / 4 && wep:Clip1() > 0 && wep:GetMaxClip1() > 0 ) then
					draw.WordBox( 4, text_right, text_pos.y + offset, "ammo low ("..wep:Clip1().." / "..wep:GetMaxClip1()..")", hud_font, color_hud_bg, color_hud_text )
					offset = offset + 16
				end

				if ( wep:GetNWBool( "IsReloading" ) == false && wep:Clip1() == 0 && wep:GetMaxClip1() > 0 ) then
					draw.WordBox( 4, text_right, text_pos.y + offset, "ammo dry", hud_font, color_hud_bg, color_hud_text )
					offset = offset + 16
				end
			end

			if ( string.StartWith( wep:GetClass(), "sfw_" ) ) then
				if ( wep:GetNWBool( "Ads" ) == true ) then
					draw.WordBox( 4, text_left, text_pos.y, "Distance: "..distance, hud_font, color_hud_bg, color_hud_text )
				end

				if ( table.HasValue( wep.SciFiFamily, "modes_bfire" ) ) then
					if ( wep:GetNWBool( "BurstMode" ) ~= nil ) then
					curmode = wep:GetNWBool( "BurstMode" )
					end

					if ( wep:GetNWInt( "Fmode1" ) ~= nil ) and ( !table.HasValue( wep.SciFiFamily, "hwave" ) )  then
					curmode = wep:GetNWInt( "Fmode1" )
					end

					if ( delay2 ~= nil ) and ( delay2 >= CurTime() ) then
						if ( curmode == true || curmode == 1 ) then
							fmode_msg = "burst"
						elseif ( curmode == 2 ) then
							fmode_msg = "semi-auto"
						elseif ( curmode == false || curmode == 0 ) then
							fmode_msg = "full auto"
						end

						draw.WordBox( 4, text_right, text_pos.y, "Firemode: "..fmode_msg, hud_font, color_hud_bg, color_hud_text )
						offset = offset + 16
					end

					if ( curmode ~= lastmode ) then
						delay2 = CurTime() + 0.8
					end

					if ( wep:GetNWBool( "BurstMode" ) ~= nil ) then
					lastmode = wep:GetNWBool( "BurstMode" )
					end

					if ( wep:GetNWInt( "Fmode1" ) ~= nil ) and ( !table.HasValue( wep.SciFiFamily, "hwave" ) ) then
					lastmode = wep:GetNWInt( "Fmode1" )
					end
				end

				if ( wep:GetNWBool( "IsReloading" ) == true ) then
					draw.WordBox( 4, text_right, text_pos.y + offset, "reloading...", hud_font, color_hud_bg, color_hud_text )
					offset = offset + 16

					if ( wep:GetNWBool( "IsReloading" ) == true && wep:GetNextPrimaryFire() >= CurTime() ) then
						delay = CurTime() + 1.2
					end
				end

				--if ( delay ~= nil ) and ( wep:GetNWBool( "IsReloading" ) == false && delay >= CurTime() ) then
				--	draw.WordBox( 4, text_right, text_pos.y + offset, "reloading... done.", hud_font, color_hud_bg, color_hud_text )
				--	offset = offset + 16
				--end
			end
		end
	cam.End3D2D()
	--[[
	--------------------------------------
	-- Weapon stats display (sfw only!) --
	--------------------------------------
	cam.Start3D2D( Vector( screen_w / 2, screen_h / 2 ), Angle( 0, 0, 180 ) + shiftang_stats, 1 )
		local wstats_pos = Vector( 0 + ( screen_w / 3.2 ) + math.abs( ply:EyeAngles().pitch / 8 ) + velo * 1.8, 0 + ( screen_h * 0.05 ) - math.abs( ply:EyeAngles().pitch / 2 ) )

		offset_vstats = 32

		if ( string.StartWith( wep:GetClass(), "sfw_" ) ) then
			draw.WordBox( 6, wstats_pos.x, wstats_pos.y, wep.PrintName, hud_font_bold, color_hud_bg, color_hud_text )

			if ( wep.SciFiWorldStats ~= nil ) then
				for k,v in SortedPairs( wep.SciFiWorldStats ) do
					if ( v.text == nil or v.color == nil ) then
						DevMsg( "@"..wep:GetClass().." : !Error; Check your stats table!" )
					else
						draw.WordBox( 4, wstats_pos.x, wstats_pos.y + offset_vstats, v.text, hud_font, color_hud_bg, color_hud_text )
						offset_vstats = offset_vstats + 24
					end
				end
			else
				draw.WordBox( 4, wstats_pos.x, wstats_pos.y + offset_vstats, wep.Purpose, hud_font, color_hud_bg, color_hud_text )
				offset_vstats = offset_vstats + 24
				draw.WordBox( 4, wstats_pos.x, wstats_pos.y + offset_vstats, wep.Instructions, hud_font, color_hud_bg, color_hud_text )
			end
		end
	cam.End3D2D()
	]]--

--	DrawMaterialOverlay( screen_refract, 0.4 )
--	render.SetRenderTarget( scene_old )
end

-- dem hooks, bruh --
hook.Add( "PostDrawHUD", "CataDrawHudTInfo", function()

	DrawCataHud()

end )

end
