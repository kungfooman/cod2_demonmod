#include demon\_utils;

init()
{
	//--------------- Hardpoint Limiter ------------------

	game["allies_hardpointcount"] = [];
	game["axis_hardpointcount"] = [];
		
	game["allies_hardpointcount"]["artillery"] = 0;
	game["axis_hardpointcount"]["artillery"] = 0;

	game["allies_hardpointcount"]["airstrike"] = 0;
	game["axis_hardpointcount"]["airstrike"] = 0;
	
	//-----------------------------------------------------
	
	level.hardpointItems = [];
	priority = 0;
	level.hardpointItems["artillery_mp"] = priority;
	priority++;
	level.hardpointItems["airstrike_mp"] = priority;
	priority++;
	level.hardpointItems["carepackage_mp"] = priority;
	priority++;
	
	level.hardpointHints["airstrike_mp"] = &"HARDPOINTS_AIRSTRIKE_READY";
	level.hardpointHints["artillery_mp"] = &"HARDPOINTS_ARTILLERY_READY";
	level.hardpointHints["carepackage_mp"] = &"HARDPOINTS_CAREPACKAGE_READY";

	level.hardpointHints["artillery_mp_use_hint"] = &"HARDPOINTS_ARTILLERY_USE_HINT";
	level.hardpointHints["airstrike_mp_use_hint"] = &"HARDPOINTS_AIRSTRIKE_USE_HINT";
	level.hardpointHints["carepackage_mp_use_hint"] = &"HARDPOINTS_CAREPACKAGE_USE_HINT";

	level.hardpointHints["artillery_mp_not_available"] = &"HARDPOINTS_ARTILLERY_NOT_AVAILABLE";
	level.hardpointHints["airstrike_mp_not_available"] = &"HARDPOINTS_AIRSTRIKE_NOT_AVAILABLE";
	level.hardpointHints["carepackage_mp_not_available"] = &"HARDPOINTS_CAREPACK_NOT_AVAILABLE";

	level.hardpoints_altitude = cvardef( "scr_demon_killstreaks_altitude", 1000, 0, 6000, "int" );
	level.airstrike_radius = 12 * cvardef( "scr_demon_killstreaks_airstrike_radius", 48, 5, 500, "int" );
	level.artillery_offset 		= cvardef( "scr_artillery_offset", 1200, 0, 2000, "int" );
	level.hardpoint_dropflare 	= cvardef( "scr_artillery_dropflare", 1, 0, 1, "int" );
	
	level.effects["hardpoint_indicator"] = loadfx( "fx/misc/flare_artillery_runner.efx" );
	level.effects["hardpoint_explosions"] = loadfx( "fx/props/barrelexp.efx" );
	
	precacheModel( "xmodel/vehicle_condor" );
	precacheModel( "xmodel/mebelle1" );
	
	precacheString( level.hardpointHints["artillery_mp"] );
	precacheString( level.hardpointHints["airstrike_mp"] );
	precacheString( level.hardpointHints["carepackage_mp"] );
	precacheString( level.hardpointHints["artillery_mp_not_available"] );
	precacheString( level.hardpointHints["airstrike_mp_not_available"] );
	precacheString( level.hardpointHints["carepackage_mp_not_available"] );
	precacheString( level.hardpointHints["artillery_mp_use_hint"] );
	precacheString( level.hardpointHints["airstrike_mp_use_hint"] );
	precacheString( level.hardpointHints["carepackage_mp_use_hint"] );
	
	level.artillerystrikeInProgress = undefined;
	level.airstrikeInProgress = undefined;
	level.carepackInProgress = undefined;
}

setPlayerDefaults()
{
	self.hardpointcount = [];
	self.hardpointcount["artillery"] = 0;
	self.hardpointcount["airstrike"] = 0;
	self.hardpointcount["carepack"] = 0;
}

giveHardpointItemForStreak()
{
	streak = undefined;
	if( self hasPerk( "specialty_hardline" ) )
		streak = (self.cur_kill_streak+1);
	else
		streak = self.cur_kill_streak;
	
	team = self getOwnTeam();
	
	if( level.limit_hardpoint_byTeam )
	{
		if( streak == level.artillery_num && game[ team + "_hardpointcount"]["artillery"] < game["hardpoint_artillery_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "artillery_mp", streak );
			game[ team + "_hardpointcount"]["artillery"]++;
		}
		else if( streak == level.airstrike_num && game[ team + "_hardpointcount"]["airstrike"] < game["hardpoint_airstrike_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "airstrike_mp", streak );
			game[ team + "_hardpointcount"]["airstrike"]++;
		}
		else if( streak == level.carepack_num && game[ team + "_hardpointcount"]["carepack"] < game["hardpoint_carepack_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "carepackage_mp", streak );
			game[ team + "_hardpointcount"]["carepack"]++;
		}

	}
	else if( level.limit_hardpoint_byPlayer )
	{
		if( streak == level.artillery_num && self.hardpointcount["artillery"] < game["hardpoint_artillery_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "artillery_mp", streak );
			self.hardpointcount["artillery"]++;
		}
		else if( streak == level.airstrike_num && self.hardpointcount["airstrike"] < game["hardpoint_airstrike_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "airstrike_mp", streak );
			self.hardpointcount["airstrike"]++;
		}
		else if( streak == level.carepack_num && self.hardpointcount["carepack"] < game["hardpoint_carepack_limit"] )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "carepackage_mp", streak );
			self.hardpointcount["carepack"]++;
		}
	}
	else
	{
		if( streak == level.artillery_num )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "artillery_mp", streak );
		}
		else if( streak == level.airstrike_num )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "airstrike_mp", streak );
		}	
		else if( streak == level.carepack_num )
		{
			self CheckForExistingHardPointItem();
			self giveHardpoint( "carepackage_mp", streak );
		}
	}
}

CheckForExistingHardPointItem()
{
	if( isdefined( self.pers["hardPointItem"] ) )
	{
		if( self.pers["hardPointItem"] != "carepackage_mp" )
		{
			self thread RemoveHardpointItem();
		}	
		else
		{			
			self.pers["hardPointItem"] = undefined;	
	
			self setClientCvar( "cg_player_carepackage", 0 );
			self setClientCvar( "cg_player_carepackage_count", 0 );	
		}
	}
}

getHardPointShader( hardpointType )
{
	shader = undefined;
	switch( hardpointType )
	{
		case "airstrike_mp":
			shader = "hud_notify_airstrike";
			break;
		
		case "artillery_mp":
			shader = "hud_notify_artillery";
			break;
			
		case "carepackage_mp":
			shader = "hud_notify_carepackage";
			break;
	}
	
	return shader;
}

hardpointNotify( hardpointType, streak )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self thread iprintlnboldCLEAR( "self", 5 );

	if( isDefined( self.rank_hud_promo ) ) self.rank_hud_promo.alpha = 0;
	if( isdefined( self.rank_promo_text ) ) self.rank_promo_text.alpha = 0;
	
	if( hardpointType == "artillery_mp" )
		self thread hardpoints\_artillery::ArtilleryNotify();
	else if( hardpointType == "airstrike_mp" )
		self thread hardpoints\_airstrike::AirstrikeNotify();
	
	if( level.hardcore ) return;
		
	self createClientHudElement( "hardpoint_notify_shader", 0, -120, "center", "middle", "center_safearea", "center_safearea", false, getHardPointShader( hardpointType ), 80, 80, 1, 0.8, 1, 1, 1 );
	self createClientHudTextElement( "hardpoint_notify_text", 0, -180, "center", "middle", "center_safearea", "center_safearea", false, 1, .8, 1, 1, 1, 1.4, level.hardpointHints[hardpointType] );
	
	wait( 4 );
	
	self deleteClientHudElementbyName( "hardpoint_notify_shader" );
	self deleteClientHudTextElementbyName( "hardpoint_notify_text" );
}

giveHardpoint( hardpointType, streak )
{
	if( self giveHardpointItem( hardpointType ) )
	{
		self thread hardpointNotify( hardpointType, streak );
	}
}

giveHardpointItem( hardpointType )
{
	if( !isDefined( level.hardpointItems[hardpointType] ) )
		return false;
		
	if( isdefined( self.hasHardPointItem ) )
		return false;

	if( isDefined( self.pers["hardPointItem"] ) )
	{
		if( level.hardpointItems[ hardpointType ] < level.hardpointItems[ self.pers["hardPointItem"] ] )
			return false;
	}
	
	if( hardpointType != "carepackage_mp" )
	{		
		if( self getCurrentWeapon() == self getWeaponSlotWeapon( "primaryb" ) )
			shouldSwitch = true;
		else
			shouldSwitch = false;
			
		self.hardpoint_ammo_return = self getWeaponSlotAmmo( "primaryb" );
		self.hardpoint_clip_return = self getWeaponSlotClipAmmo( "primaryb" );

		if( shouldSwitch )
			self SwitchtoWeapon( self getWeaponSlotWeapon( "primary" ) );
		
		self TakeWeapon( self getWeaponSlotWeapon( "primaryb" ) );
		self GiveWeapon( "hardpoint_mp" );
		self setWeaponSlotWeapon( "primaryb", "hardpoint_mp" );
	}
	
	self.pers["hardPointItem"] = hardpointType;	
	
	self setClientCvar( "cg_player_" + self getHardPointString(), 1 );
	self setClientCvar( "cg_player_" + self getHardPointString() + "_count", 1 );
	
	return true;
}

giveOwnedHardpointItem()
{
	if( isDefined( self.pers["hardPointItem"] ) )
		self giveHardpointItem( self.pers["hardPointItem"] );
}

RemoveHardpointItem()
{
	self setClientCvar( "cg_fovscale", "1" );
	
	self TakeWeapon( "hardpoint_mp" );
	self GiveWeapon( self.pers["secondary"] );
	self setWeaponSlotWeapon( "primaryb", self.pers["secondary"]  );
	self setWeaponSlotAmmo( "primaryb", self.hardpoint_ammo_return );
	self setWeaponSlotClipAmmo( "primaryb", self.hardpoint_clip_return );
	self switchtoWeapon( self getWeaponSlotWeapon( "primary" ) );

	self setClientCvar( "cg_player_" + self getHardPointString(), 0 );
	self setClientCvar( "cg_player_" + self getHardPointString() + "_count", 0 );
	
	self.pers["hardPointItem"] = undefined;
	self.hardpoint_ammo_return = undefined;
	self.hardpoint_clip_return = undefined;
	
	self notify( "hardpoint_end" );
}

triggerHardPoint( hardpointType )
{
	team = self getOwnTeam();
	otherTeam = self getOtherTeam( team );
		
	if( hardpointType == "artillery_mp" )
	{
		if( isDefined( level.artillerystrikeInProgress ) || isDefined( level.airstrikeInProgress ) )
		{
			self iPrintLnBold( level.hardpointHints[hardpointType+"_not_available"] );
			return false;
		}
		
		self thread hardpoints\_artillery::artillery_DispenseStrike();
	}
	else if( hardpointType == "airstrike_mp" )
	{
		if( isDefined( level.artillerystrikeInProgress ) || isDefined( level.airstrikeInProgress ) )
		{
			self iPrintLnBold( level.hardpointHints[hardpointType+"_not_available"] );
			return false;
		}
			
		self thread hardpoints\_airstrike::airstrike_DispenseStrike();
	}
	
	return true;
}

// thread from maps\mp\gametypes\_weapons::detectWeaponChange();
MonitorBinocularAction( hardpointType )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self thread InvalidTargetWaiter();
	
   	while( isdefined( self.hasHardPointItem ) && isAlive( self ) && self.sessionstate == "playing" )
	{
		if( self isADS() )
		{
			self notify( "hardpoint_enter" );
			self thread BinocularHintHud( hardpointType );
		}
		else
		{
			self notify( "hardpoint_exit" );
			self thread cleanUpHardpointHints();
		}
			
		wait( 0.05 );
	}
	
	self setClientCvar( "cg_fovscale", "1" );
}

InvalidTargetWaiter()
{
	self notify( "hardpoint_end" );
	self endon( "hardpoint_end" );
	
	self waittill( "hardpoint_reset" );
	
	self switchtoWeapon( self getWeaponSlotWeapon( "primary" ) );
}

BinocularHintHud( hardpointType )
{
	if( !isdefined( self.binocular_hint ) )
	{
		self.binocular_hint = newClientHudElem( self );
		self.binocular_hint.alignX = "center";
		self.binocular_hint.alignY = "middle";
		self.binocular_hint.x = 0;
		self.binocular_hint.y = -60;
		self.binocular_hint.horzAlign = "center_safearea";
		self.binocular_hint.vertAlign = "center_safearea";
		self.binocular_hint.alpha = 1;
		self.binocular_hint.sort = 5;
		self.binocular_hint.fontScale = 1.5;
		self.binocular_hint.font = "default";
		self.binocular_hint setText( getHardpointType( hardpointType ) );
	}
}

getHardpointType( hardpointType )
{
	return level.hardpointHints[ hardpointType + "_use_hint" ];
}

cleanUpHardpointHints()
{
	if( isdefined( self.binocular_hint ) )
		self.binocular_hint destroy();
}


