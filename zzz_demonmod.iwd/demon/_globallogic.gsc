/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
#include demon\_utils;

init()
{
	demon\_varcache::init();
	onPrecache();
	setUpUtilities();
	
	thread demon\_bots::init();
	thread demon\_rank::init();
	thread demon\_sprint::init();
	thread demon\_logo::init();
	thread demon\_weapon_pool::init();
	thread demon\_maprotation::init();
	thread demon\_bleeding::init();
	thread demon\_sniperzoom::init();
	thread demon\_turretcontrol::Remove_Map_Entity();
	thread demon\_longrange::init();
	if( !level.messageindividual ) 
		thread demon\_messages::ServerMessages();
	
	//---Ambient FX ---
	thread demon\_ambient_mortars::init();
	thread demon\_ambient_planes::init();
	thread demon\_ambient_tracers::init();
	
	//--- Perks ---
	thread perks\_tripwire::init();
	thread perks\_landmines::init();
	thread perks\_firstaid::init();
	
	//--- Hardpoints ---
	thread hardpoints\_airstrike::init();
	thread hardpoints\_artillery::init();
	thread hardpoints\_hardpoints::init();
}

setupCallbacks()
{
	level.demon_onGametypeStarted	= ::onGametypeStarted;
	level.demon_onPlayerConnect 	= ::onPlayerConnect;
	level.demon_onPlayerDisconnect	= ::onPlayerDisconnect;
	level.demon_onPlayerPreSpawned 	= ::onPlayerPreSpawned;
	level.demon_onPlayerSpawned		= ::onPlayerSpawned;
	level.demon_onPlayerDamage		= ::onPlayerDamage;
	level.demon_onPlayerKilled 		= ::onPlayerKilled;
	level.demon_onSpawnSpectator	= ::onSpawnSpectator;
	level.demon_onSwitchingTeams	= ::demon_onSwitchingTeams;
	level.onPlayerJoinedTeam 		= ::onPlayerJoinedTeam;
}

setUpUtilities()
{
	FindPlayArea();
	FindMapDimensions();

	if( !isdefined( game["roundsplayed"] ) )
		game["roundsplayed"] = 0;

	if( !isdefined( game["matchstarted"] ) )
		game["matchstarted"] = false;
}

onPrecache()
{	

//////////////////// FX ///////////////////////////////	

	level._effect["martyrdom_boom"] = loadfx( "fx/explosions/grenadeExp_dirt.efx" );
	level._effect["tabungas"] = loadfx( "fx/gas/tabungas.efx" );
	level._effect["stickybomb"] = loadfx( "fx/explosions/stickybomb.efx" );
	level._effect["satchel_effect"] = loadfx( "fx/explosions/satchel_charge.efx" ); 
	level._effect["carepackage_signal_smoke"] = loadfx( "fx/smoke/carepackage_grenade.efx" ); 
	level._effect["insertionflare"] = loadFX( "fx/custom/insertion_grenade.efx" );

////////////////////////////////////////////////////////
	
	precacheShellShock( "tabungas" );
	
/////////////////// MODELS ////////////////////////

	game["scavenger_pack"] = "xmodel/scavenger_pack_new";
	demonPrecacheModel( game["scavenger_pack"] );
	
	level.bombModel = "xmodel/prop_stuka_bomb";
	demonPrecacheModel( level.bombModel );

	game["carepackage"] = "xmodel/prop_carepackage";
	game["parachute"] = "xmodel/parachute";
	demonPrecacheModel( game["parachute"] );
	demonPrecacheModel( game["carepackage"] );

	if( level.drophealth )
	{
		game["Item_Healthpack"] = "xmodel/health_large";
		game["health_obj"] = "xmodel/health_large_obj";
		demonPrecacheModel( game["Item_Healthpack"] );
		demonPrecacheModel( game["health_obj"] );
	}

/////////////////////////////////////////////////

	demonPrecacheShader( "keyboardmap" );
	demonPrecacheShader( "hud_grenadeicon" );
	demonPrecacheShader( "waypoint_camper" );

	if( level.bulletscreen )
	{
		demonPrecacheShader( "bullethit_glass" );
		demonPrecacheShader( "bullethit_glass1" );
		demonPrecacheShader( "bullethit_glass2" );
	}
	
	if( level.spawnprotection )
	{
		game["painkiller"] = "hud_painkiller";
		demonPrecacheShader( game["painkiller"] );
		demonPrecacheString( &"DEMON_PRO_ACTIVE" );
		demonPrecacheString( &"DEMON_DISABLED_WEAPON" );
	}
	
	if(	level.bloodyscreen )
	{
		demonPrecacheShader( "overlay_flesh_hit2" );
		demonPrecacheShader( "overlay_fleshhitgib" );
	}
	
	if( level.server_logo )
	{
		game["logo"] = "logo";
		demonPrecacheShader( game["logo"] );
	}
	
	/#
	thread demon\_test::test_Precache();
	#/
}

onGametypeStarted()
{
	level.hardpointtest_count = 0;
	
	//--- Fall Damage Modifier ---
	{
		setCvar( "bg_fallDamageMinHeight", level.minfallheight );
		setCvar( "bg_fallDamageMaxHeight", level.maxfallheight );
	}
	
	/#
	thread demon\_test::test_onGametypeStarted();
	#/
}

onPlayerConnect()
{
	if( !isdefined( self.class ) )
		self.class = undefined;
	if( !isdefined( self.pers["class"] ) )
		self.pers["class"] = undefined;
	if( !isdefined( self.changedClass ) )
		self.changedClass = undefined;
	if( !isdefined( self.changedWeapon ) )
		self.changedWeapon = undefined;
	if( !isDefined( self.gassed ) )
		self.gassed = undefined;
	if( !isdefined( self.buttons_done ) )
		self.buttons_done = undefined;
	if( !isDefined( self.pers["hardPointItem"] ) )
		self.pers["hardPointItem"] = undefined;
	if( !isdefined( self.pers[ "welcomed" ] ) )
		self.pers[ "welcomed" ] = undefined;
	if( !isDefined( self.pers[ "serverMessages" ] ) )
		self.pers[ "serverMessages" ] = undefined;
	if( !isdefined( self.pers["rank"] ) )
		self.pers["rank"] = 0;
	if( !isdefined( self.pers["rank_score"] ) )
		self.pers["rank_score"] = 0;
	if( !isdefined( self.pers["perk1"] ) )
		self.pers["perk1"] = "";
	if( !isdefined( self.pers["perk2"] ) )
		self.pers["perk2"] = "";
	if( !isdefined( self.pers["perk3"] ) )
		self.pers["perk3"] = "";

	self.pers["lives"] = level.numLives;

	self.unlockPerks_done = undefined;
	self.roundBased_dvars = undefined;
	self.firstaidkits = level.firstaidkits;
	self.spawnprotected = false;
	self.zoomLevelSet = false;

	self.bombSquadIcons = [];
	self.bombSquadIds = [];
	self.pers["checkdefuse"] = [];
	self.pers["checkdefuse"]["tripwire"] = false;
	self.pers["checkdefuse"]["landmine"] = false;
	
	self.pers["secondary"] = "";
	self.pers["sidearm"] = "";
	
	self.sidearmArray = [];
	self.sidearmArray[0] = "ui_sidearm_colt";
	self.sidearmArray[1] = "ui_sidearm_webley";
	self.sidearmArray[2] = "ui_sidearm_tokarev";
	self.sidearmArray[3] = "ui_sidearm_walthar";
	self.sidearmArray[4] = "ui_sidearm_magnum";
	self.sidearmArray[5] = "ui_sidearm_knife";

	if( !level.regen && level.bleeding )
	{
		self.bleeding = 0;
		self.bleed_count = 0;
	}

	//--- Perk Cvars ---
	//PERK GROUP 1
	self setClientCvar( "scr_demon_allow_tripwire", level.perk_allow_tripwire );
	self setClientCvar( "scr_demon_allow_betty", level.perk_allow_betty );
	self setClientCvar( "scr_demon_allow_stickybomb", level.perk_allow_stickybomb );
	self setClientCvar( "scr_demon_allow_satchel", level.perk_allow_satchel );
	self setClientCvar( "scr_demon_allow_tabungas", level.perk_allow_tabungas );

	//PERK GROUP 2
	self setClientCvar( "scr_demon_allow_firstaid", level.perk_allow_firstaid );
	self setClientCvar( "scr_demon_allow_bombsquad", level.perk_allow_bombsquad );
	self setClientCvar( "scr_demon_allow_bulletdamage", level.perk_allow_bulletdamage );
	self setClientCvar( "scr_demon_allow_juggernaut", level.perk_allow_juggernaut );
	self setClientCvar( "scr_demon_allow_insertion", level.perk_allow_insertion );
	
	//PERK GROUP 3
	self setClientCvar( "scr_demon_allow_martyrdom", level.perk_allow_martyrdom );
	self setClientCvar( "scr_demon_allow_endurance", level.perk_allow_endurance );
	self setClientCvar( "scr_demon_allow_sonicboom", level.perk_allow_sonicboom );
	self setClientCvar( "scr_demon_allow_hardline", level.perk_allow_hardline );
	self setClientCvar( "scr_demon_allow_scavenger", level.perk_allow_scavenger );
	
	//keyboard map dpad icon
	self setClientCvar( "scr_demon_dynamic_perks", level.dynamic_perks );

	//--- Set the Team Dvars to Show Appropriate Menu Items ---
	switch( game["allies"] )
	{
		case "russian":
			self setClientCvar( "scr_class_russian", "1" );
			self setClientCvar( "ui_teams", "russian" );
			if( !level.perk_allow_stickybomb )
				self setClientCvar( "ui_stickybomb_replace", "russian" );
			if( !level.perk_allow_satchel )
				self setClientCvar( "ui_satchel_replace", "russian" );
			break;
			
		case "british":
			self setClientCvar( "scr_class_british", "1" );
			self setClientCvar( "ui_teams", "british" );
			if( !level.perk_allow_stickybomb )
				self setClientCvar( "ui_stickybomb_replace", "british" );
			if( !level.perk_allow_satchel )
				self setClientCvar( "ui_satchel_replace", "british" );
			break;
			
		default:
			self setClientCvar( "scr_class_american", "1" );
			self setClientCvar( "ui_teams", "american" );
			if( !level.perk_allow_stickybomb )
				self setClientCvar( "ui_stickybomb_replace", "american" );
			if( !level.perk_allow_satchel )
				self setClientCvar( "ui_satchel_replace", "american" );
			break;
	}

	if( !level.sniperzoom_enable ) 
		self setClientCvar( "cg_fovmin", 10 );

	if( level.limit_hardpoint_byPlayer )
		self thread hardpoints\_hardpoints::setPlayerDefaults();

	if( level.messageindividual ) self thread demon\_messages::ServerMessages();
	
	// lock the officer class menu
	self setClientCvar( "ui_allow_officer", 0 );
	
	//--- RANK ---
	// get the player's rank
	self demon\_rank::onPlayerConnect();

}

onPlayerJoinedTeam()
{
	if( !level.regen && level.bleeding )
		self notify( "end_bleed" );
	
	self thread demon\_dynamicperks::unLockPerks();
}

demon_onSwitchingTeams()
{
	// flag for disabling black screen if switching teams
	self.noBlackScreen = true;
	
	// we need to release the player's class if switching teams
	self maps\mp\gametypes\_class_limits::releaseClass( self.pers["team"], self.pers["class"]  );

	//--- custom Obit ---
	self notify( "end_obituary" );
	if( isdefined( self.otherDeathObit ) ) 
		self.otherDeathObit destroy();
}

onPlayerDisconnect()
{
	self thread maps\mp\gametypes\_class_limits::onPlayerDisconnect();
	
	//--- RANK ---
	self thread demon\_playerdata::onPlayerDisconnect();
	
	if( !level.regen && level.bleeding )
	{
		self notify( "end_bleed" );
	}
}

onPlayerPreSpawned()
{
	//--- RANK ---
	self thread demon\_rank::onPlayerPreSpawned();
}

// This is needed on new rounds, otherwise the health bar wont show (timing issue?)
ReEstablishDvars()
{
	if( isdefined( self.roundBased_dvars ) ) return;
	self.roundBased_dvars = true;

	wait( 0.55 );
	
	self setClientCvar( "cg_drawhealth", "1" );
	self setClientCvar( "hud_fade_healthbar", "0" );
}

dpadDvars()
{
	self setClientCvar( "ui_keyboard_hint", "[K]" );
}

onPlayerSpawned()
{	

////////////////////// DO THIS STUFF FIRST //////////////////////////////
	//HARDCORE MODE
	{
		self setClientCvar( "scr_demon_hardcore", level.hardcore );
		setCvar( "scr_demon_hardcore", level.hardcore );
		
		if( level.hardcore )
			self setClientCvar( "cg_drawCrosshair", 0 );
		else
			self setClientCvar( "cg_drawCrosshair", 1 );
	}
	
	self dpadDvars();
	
	//--- Reset Player Flags ---
	self resetPlayerFlags();
	
	//--- Perk Dvars ---
	self thread setPerkCvars();
	
	//--- SPRINT ---
	self thread demon\_sprint::onPlayerSpawned();
	
	//--- RANK ---
	self thread demon\_rank::onPlayerSpawned();
	
	//--- Health Bar ---
	if( level.healthbar )
	{
		self setClientCvar( "cg_drawhealth", "1" );
		self setClientCvar( "hud_fade_healthbar", "0" );

		//--- Round-Based Dvars ---
		if( level.roundBased )
			self thread ReEstablishDvars();
	}
	
	//--- Freeze Bots ---
	if( demon\_bots::IsBot( self ) )
		self thread demon\_bots::spawnFreezer();
	
//	self thread iprintlnboldCLEAR( "self", 5 );
	
	//--- Welcome Messages ---
	self thread demon\_messages::show_WelcomeMessages();
	
	//--- Custom Buttons ---
	self thread setUpButtons();
	//----------------------

//////////////////////////////////////////////////////////////////////

	//--- longrange sniper rifles ---
	self thread demon\_longrange::waitforsniperfire();
	
	//--- PainKiller ----
	self thread demon\_painkiller::Start_Protection();
	
	//--- Pain Killer Freeze Player ---
	if( level.spawnprotection && level.spawnpro_freezeplayer )	
		self thread demon\_painkiller::spawnBlocker();
	//-------------------

	//--- tactical insertion ---
	if( level.perk_allow_insertion )
		self perks\_tactical_insertion::InsertionMove();
	//-------------

	//--- firstaid ---
	if( !level.regen )
		self thread perks\_firstaid::monitorFirstAid();
	//----------------
	
	//--- LaserDot ---
	self thread demon\_laserdot::RunOnSpawn();
	//----------------
	
	//--- Sniper Zoom ---
	if( level.sniperzoom_enable )
		self thread demon\_sniperzoom::RunOnSpawned();
	//------------------

	//--- Jump Monitor ---
	self thread demon\_jump_monitor::jumpMonitor();
	//--------------------
	
	//--- Thumbmarker ---
	self thread attachments();
	//--------------------
	
	/#
	self thread demon\_test::test_onPlayerSpawned();
	#/
	
}

attachments()
{
	// wait until the player model is solid on spawn ( otherwise it will return an invalid player model )
	wait( 1 );
	
	if( !isDefined( self.thumbmarker ) )
	{
		self.thumbmarker = spawn( "script_origin", (0,0,0) );
		self.thumbmarker linkto( self, "J_Thumb_ri_1", (0,0,0) , (0,0,0) );
	}
}

onSpawnSpectator()
{

}

setPerkCvars()
{
	if( level.hardcore ) return;

	if( self.pers["class"] == "officer" )
	{
		self setClientCvar( "cg_player_binoculars", "1" );
		self.binocularsAvailable = true;
	}
	else
	{
		self setClientCvar( "cg_player_binoculars", "0" );
		self.binocularsAvailable = undefined;
	}
	
	if( self hasPerk( "specialty_weapon_tripwire" ) )
	{
		self setClientCvar( "cg_player_tripwire", "1" );
		self setClientCvar( "ui_tripwire_count", "[2]" );
	}
	else
	{
		self setClientCvar( "cg_player_tripwire", "0" );
	}

	if( self hasPerk( "specialty_weapon_betty" ) )
	{
		if( self.pers["team"] == "allies" )
			self setClientCvar( "cg_player_landmine", "allies" );
		else
			self setClientCvar( "cg_player_landmine", "axis" );
		
		self setClientCvar( "ui_landmine_count", "[2]" );
		self setClientCvar( "cg_player_landmine_count", 1 );
	}
	else
	{
		self setClientCvar( "cg_player_landmine", "" );
		self setClientCvar( "cg_player_landmine_count", 0 );
	}

	if( self hasPerk( "specialty_tactical_insertion" ) )
	{
		self setClientCvar( "cg_player_insertion", 1 );
		self setClientCvar( "ui_tactical_hint", "[M]" );
	}
	else
		self setClientCvar( "cg_player_insertion", 0 );

	if( self hasPerk( "specialty_firstaid" ) )
	{
		self setClientCvar( "cg_player_firstaid", 1 );
		self setClientCvar( "ui_firstaid_value", "[" + self.firstaidkits + "]" );
		
	}
	else
	{
		self setClientCvar( "cg_player_firstaid", 0 );
	}

}

resetPlayerFlags()
{
	self.changedWeapon = undefined;
	self.changedClass = undefined;
	self.gassed = undefined;
	self.perk_abuse = undefined;
	self.insertion_done = undefined;
	self.enteredArtyLoop = undefined;
	self.enteredAirStrikeLoop = undefined;
	self.carepackItem = undefined;
	self.noBlackScreen = false;
	self.zoomLevelSet = false;
	self.weaponDisabled = false;

	self.keyboard_count = 0;
	self.binocular_count = 0;
	self.perk_count = 0;
	
	self.firstaidkits = level.firstaidkits;

	if( !level.regen && level.bleeding )
	{
		self notify( "end_bleed" );
		self.proning = undefined;
		self.bleeding = false;
		self.bsoundinit = false;
		self.bpshockinit = false;
		self.bleeding = 0;
		self.bleed_count = 0;
	}
}

setUpButtons()
{
	if( isdefined( self.buttons_done ) ) return;
	self.buttons_done = true;
	
	self ExecClientCommand( "exec custombuttons.cfg" );
	self thread demon\_custombuttons::monitorButtons();
}

onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	//--- drop on hit ---
	self thread DropOnHit( sHitLoc );

	//---demon Bleeding---
	if( !level.regen && level.bleeding > 0 )
		self thread demon\_bleeding::playerBleed( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	//--- bullet screen ---
	if( level.bulletscreen && ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" ) ) 
		self thread demon\_bulletscreen::bulletHitScreen();

	//--- Bloody Screen ---
	if( level.bloodyscreen && ( isPlayer( eAttacker ) && distance( eAttacker.origin, self.origin ) < 150 ) )
		eAttacker thread demon\_bloodyscreen::Splatter_View();

	//--- damage viewshift ---
	if( level.damageviewshift )
		self thread viewShift( level.damageviewshift, eAttacker );
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	//--- Black Screen on Death ---
	self thread demon\_blackscreen::Blackscreen();
		
	//--- delete all client hud elements ---
	self CleanOnDeath();
	
	//--- SPRINT ---
	self thread demon\_sprint::onPlayerKilled();
	
	//--- RANK ---
	self thread demon\_rank::onPlayerKilled();
		
	if( level.drophealth ) 
		self thread demon\_healthpacks::dropHealth();
	
	if( isPlayer( attacker ) && attacker != self  )
	{
		self thread perks\_scavenger::dropScavengerPack();
		self thread perks\_martyrdom::StartMarty( attacker );
	}	

}

CleanOnDeath()
{	
	if( isDefined( self.thumbmarker ) )
	{
		self.thumbmarker unLink();
		self.thumbmarker delete();
	}

	//--- custom Obit ---
	self notify( "end_obituary" );
	if( isdefined( self.otherDeathObit ) ) 
		self.otherDeathObit destroy();
	
	self deleteClientHudElements();
	self deleteClientTextElements();
	
	if( level.healthbar )
		self setClientCvar( "cg_drawhealth", "0" );

	if( !level.regen && level.bleeding )
	{
		self notify( "end_bleed" );
		self.bleeding = 0;
		self.bleed_count = 0;
	}

	for( index=0; index < level.class_string.size; index++ )
		self setClientCvar( "ui_player_class_"+level.class_string[index], "0" );

	self setClientCvar( "ui_player_class_officer", "" );

	if( isdefined( self.class_string ) ) 
		self.class_string destroy();
	
	if( self hasPerk( "specialty_weapon_tripwire" ) )
	{
		self setClientCvar( "cg_player_tripwire", "0" );
		self setClientCvar( "cg_player_tripwire_count", 3 );
	}
	
	if( self hasPerk( "specialty_weapon_betty" ) )
	{
		self setClientCvar( "cg_player_landmine", 0 );
		self setClientCvar( "cg_player_landmine_brackets", 0 );
		self setClientCvar( "cg_player_landmine_count", 3 ); //<--- 3, because 0, 1, and 2 are already used
	}
	
//	if( self.pers["class"] == "officer" )
//		self setClientCvar( "cg_player_binoculars", "0" );

	if( self hasPerk( "specialty_firstaid" ) )
	{
		self setClientCvar( "cg_player_firstaid", 0 );
		self setClientCvar( "cg_player_firstaid_value", 6 );
	}

	if( self hasPerk( "specialty_tactical_insertion" ) )
		self setClientCvar( "cg_player_insertion", 0 );
	
	if( isDefined( self.pers["hardPointItem"] ) )
	{
		self setClientCvar( "cg_player_" + self getHardPointString(), 0 );
		self setClientCvar( "cg_player_" + self getHardPointString() + "_count", 0 );	
	}
	
	self thread demon\_laserdot::CleanUponDeath();
	self thread demon\_painkiller::CleanUponDeath();
	self thread demon\_bulletscreen::CleanUponDeath();
	self thread demon\_bloodyscreen::CleanUponDeath();

	if( level.sniperzoom_enable )
		self thread demon\_sniperzoom::CleanUpKilled();
	
}

viewShift( severity, attacker )
{
	if( isPlayer( attacker ) && self.pers["team"] == attacker.pers["team"] )
		return;
		
  	if( !isDefined( severity ) || severity < 3 ) 
		severity = randomint(10)+5;
  	else 
		severity = int( severity );
		
  	if( severity > 45 ) 
		severity = 45;
		
  	pShift = randomint( severity );
  	yShift = randomint( severity );
	
  	self setPlayerAngles( self.angles + ( pShift, yShift, 0 ) );
}

DropOnHit( sHitLoc )
{
	
	if( isAlive( self ) )
	{	
		weap = self getCurrentWeapon();
		switch( sHitLoc )
		{
			case "right_hand":
			case "left_hand":
			if( level.droponhandhit != 0 && randomInt( 100 ) < level.droponarmhit ) self DropItem( weap );
			break;
			
			case "right_arm_lower":
			case "left_arm_lower":
			if( level.droponarmhit != 0 && randomInt( 100 ) < level.droponarmhit ) self DropItem( weap );
			break;
	
			case "right_foot":
			case "left_foot":
			if( level.triponfoothit && randomInt( 100 ) < level.triponfoothit ) self ExecClientCommand( "gocrouch" );
			break;

			case "right_leg_lower":
			case "left_leg_lower":
			if( level.triponleghit && randomInt( 100 ) < level.triponleghit ) self ExecClientCommand( "gocrouch" );
			break;
		}
	}
}

