/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

main()
{
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	
	maps\mp\gametypes\_startspawns::init();

	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "ctf", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "ctf", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "ctf", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "ctf", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "ctf", 0, 0, 99 );

	level.respawndelay = CvarDef( "scr_ctf_respawndelay", 10, 0, 999, "int" );
	level.flag_returnTime = CvarDef( "scr_ctf_flag_return_time", 120, 0, 999, "int" );

	level.onPrecacheGametype = ::onPrecacheGametype;
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPlayerDisconnect = ::onPlayerDisconnect;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onRespawnPlayer = ::onRespawnPlayer;
	level.updateTimer = ::updateTimer;
}

onPrecacheGametype()
{
	//--- Models ---
	game["prop_flag"] = [];
	game["prop_flag_carry"] = [];
	
	game["prop_flag"]["allies"] 		= "xmodel/prop_flag_" + game["allies"];
	game["prop_flag_carry"]["allies"] 	= "xmodel/prop_flag_" + game["allies"] + "_carry";
	game["prop_flag"]["axis"] 			= "xmodel/prop_flag_" + game["axis"];
	game["prop_flag_carry"]["axis"] 	= "xmodel/prop_flag_" + game["axis"] + "_carry";
	
	//--- shaders ---
	game["compassflag"] = [];
	game["objpointflag"] = [];
	game["hudflag"] = [];
	game["hudflag"] = [];
	game["hudflagflash"] = [];
	game["hudflagflash"] = [];
	game["objpointflagmissing"] = [];
	game["objpointflagmissing"] = [];
		
	game["compassflag"]["allies"] = "compass_flag_" + game["allies"];
	game["compassflag"]["axis"] = "compass_flag_" + game["axis"];
	game["objpointflag"]["allies"] = "objpoint_flag_" + game["allies"];
	game["objpointflag"]["axis"] = "objpoint_flag_" + game["axis"];
	game["hudflag"]["allies"] = "compass_flag_" + game["allies"];
	game["hudflag"]["axis"] = "compass_flag_" + game["axis"];
	game["hudflagflash"]["allies"] = "hud_flagflash_" + game["allies"];
	game["hudflagflash"]["axis"] = "hud_flagflash_" + game["axis"];
	game["objpointflagmissing"]["allies"] = "objpoint_flagmissing_" + game["allies"];
	game["objpointflagmissing"]["axis"] = "objpoint_flagmissing_" + game["axis"];
	
	///////////////// FLAG SOUNDS ///////////////////////
	
	game["flagTaken"] = [];
	game["flagCapped"] = [];
	game["flagReturned"] = [];
	game["flagDropped"] = [];
	
	switch( game["allies"] )
	{
		case "british":
			game["flagTaken"]["allies"] = "UK_mp_flagtaken";
			break;
		
		case "russian":
			game["flagTaken"]["allies"] = "RU_mp_flagtaken";
			break;
		
		default:
			game["flagTaken"]["allies"] = "US_mp_flagtaken";
			break;
		
	}
	
	game["flagCapped"]["allies"] = "mp_announcer_alliedflagcap";
	game["flagReturned"]["allies"] = "mp_announcer_alliedflagret";
	game["flagDropped"]["allies"] = "mp_announcer_alliedflagdrop";
	
	game["flagTaken"]["axis"] = "GE_mp_flagtaken";
	game["flagCapped"]["axis"] = "mp_announcer_axisflagcap";
	game["flagReturned"]["axis"] = "mp_announcer_axisflagret";
	game["flagDropped"]["axis"] = "mp_announcer_axisflagdrop";
	
	////////////////////////////////////////////////////////////
	
	demonPrecacheStatusIcon( game["hudflag"]["allies"] );
	demonPrecacheStatusIcon( game["hudflag"]["axis"] );
	
	demonPrecacheShader( game["compassflag"]["allies"] );
	demonPrecacheShader( game["compassflag"]["axis"] );
	demonPrecacheShader( game["objpointflag"]["allies"] );
	demonPrecacheShader( game["objpointflag"]["axis"] );
	demonPrecacheShader( game["hudflag"]["allies"] );
	demonPrecacheShader( game["hudflag"]["axis"] );
	demonPrecacheShader( game["hudflagflash"]["allies"] );
	demonPrecacheShader( game["hudflagflash"]["axis"] );
	demonPrecacheShader( game["objpointflagmissing"]["allies"] );
	demonPrecacheShader( game["objpointflagmissing"]["axis"] );
	
	demonPrecacheModel( game["prop_flag"]["allies"] );
	demonPrecacheModel( game["prop_flag"]["axis"] );
	demonPrecacheModel( game["prop_flag_carry"]["allies"] );
	demonPrecacheModel( game["prop_flag_carry"]["axis"] );
	demonPrecacheModel( "xmodel/prop_flag_base" );
	
	demonPrecacheString( &"MP_TIME_TILL_SPAWN" );
	demonPrecacheString( &"MP_CTF_OBJ_TEXT" );
	demonPrecacheString( &"MP_ENEMY_FLAG_TAKEN" );
	demonPrecacheString( &"MP_ENEMY_FLAG_CAPTURED" );
	demonPrecacheString( &"MP_YOUR_FLAG_WAS_TAKEN" );
	demonPrecacheString( &"MP_YOUR_FLAG_WAS_CAPTURED" );
	demonPrecacheString( &"MP_YOUR_FLAG_WAS_RETURNED" );

	flagBaseFX = [];
	flagBaseFX["american"] = "fx/tickrings/objective_ring_blue";
	flagBaseFX["british"    ] = "fx/tickrings/objective_ring_green";
	flagBaseFX["russian"] = "fx/tickrings/objective_ring_red";
	flagBaseFX["german"  ] = "fx/tickrings/objective_ring_black";
	
	level.flagBaseFXid[ "allies" ] = loadfx( flagBaseFX[ game[ "allies" ] ] );
	level.flagBaseFXid[ "axis"   ] = loadfx( flagBaseFX[ game[ "axis"   ] ] );

}

onGametypeStarted()
{
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_ctf_spawn_allied" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_ctf_spawn_axis" );
	level.spawn_axis = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_ctf_spawn_axis" );
	level.spawn_allies = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_ctf_spawn_allied" );
	level.spawn_allies_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_allies_start" );
	level.spawn_axis_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_axis_start" );

	allowed[0] = "ctf";
	maps\mp\gametypes\_gameobjects::main( allowed );

	minefields = [];
	minefields = getentarray("minefield", "targetname");
	trigger_hurts = [];
	trigger_hurts = getentarray("trigger_hurt", "classname");

	level.flag_returners = minefields;
	for( i = 0; i < trigger_hurts.size; i++ )
		level.flag_returners[level.flag_returners.size] = trigger_hurts[i];
	
	thread initFlags();
}

onPlayerDisconnect()
{
	self dropFlag();
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self dropFlag();
	
	// Delay the player becoming a spectator till after he's done dying
	self thread respawn_timer( 2 );
}

onPlayerSpawned()
{
	spawnTeam = self.pers["team"];
	if( level.startSpawns && level.useStartSpawns )
	{
		if( spawnteam == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_axis_start );
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_allies_start );
	}
	else
	{
		if( spawnTeam == "axis" )
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_axis );
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_allies );
	}

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );

	if( level.scorelimit > 0 )
		self setClientCvar( "cg_objectiveText", &"MP_CTF_OBJ_TEXT", level.scorelimit );
	else
		self setClientCvar( "cg_objectiveText", &"MP_CTF_OBJ_TEXT_NOSCORE" );

	self thread updateTimer();
}

onRespawnPlayer()
{
	self.sessionteam = self.pers["team"];
	self.sessionstate = "spectator";

	if( isdefined( self.dead_origin ) && isdefined( self.dead_angles ) )
	{
		origin = self.dead_origin + (0, 0, 16);
		angles = self.dead_angles;
	}
	else
	{
		origin = self.origin + (0, 0, 16);
		angles = self.angles;
	}

	self spawn( origin, angles );
	
	while( isdefined( self.WaitingToSpawn ) )
		wait( 0.05 );
}

initFlags()
{
	maperrors = [];

	allied_flags = getentarray( "allied_flag", "targetname" );
	if( allied_flags.size < 1 )
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"allied_flag\"";
	else if( allied_flags.size > 1 )
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"allied_flag\"";
	

	axis_flags = getentarray("axis_flag", "targetname");
	if( axis_flags.size < 1 )
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"axis_flag\"";
	else if( axis_flags.size > 1 )
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"axis_flag\"";

	if( maperrors.size )
	{
		println( "^1------------ Map Errors ------------" );
		for( i = 0; i < maperrors.size; i++ )
			println( maperrors[i] );
		println( "^1------------------------------------" );

		return;
	}

	// Allied Assets
	allied_flag = getent( "allied_flag", "targetname" );
	allied_flag.home_origin = allied_flag.origin;
	allied_flag.home_angles = allied_flag.angles;
	allied_flag.flagmodel = spawn( "script_model", allied_flag.home_origin );
	allied_flag.flagmodel.angles = allied_flag.home_angles;
	allied_flag.flagmodel setmodel( game["prop_flag"]["allies"] );
	
	allied_origin = getGroundpoint( allied_flag );
	flagEffect = playLoopedFx( level.flagBaseFXid[ "allies" ], 0.90, allied_origin );
	
	allied_flag.team = "allies";
	allied_flag.atbase = true;
	allied_flag.objective = 0;
	allied_flag.compassflag = game["compassflag"]["allies"];
	allied_flag.objpointflag = game["objpointflag"]["allies"];
	allied_flag.objpointflagmissing = game["objpointflagmissing"]["allies"];
	allied_flag thread flag();
	
	// Axis Assets
	axis_flag = getent( "axis_flag", "targetname" );
	axis_flag.home_origin = axis_flag.origin;
	axis_flag.home_angles = axis_flag.angles;
	axis_flag.flagmodel = spawn( "script_model", axis_flag.home_origin );
	axis_flag.flagmodel.angles = axis_flag.home_angles;
	axis_flag.flagmodel setmodel( game["prop_flag"]["axis"] );

	axis_origin = getGroundpoint( axis_flag );
	flagEffect = playLoopedFx( level.flagBaseFXid[ "axis" ], 0.90, axis_origin );
	
	axis_flag.team = "axis";
	axis_flag.atbase = true;
	axis_flag.objective = 1;
	axis_flag.compassflag = game["compassflag"]["axis"];
	axis_flag.objpointflag = game["objpointflag"]["axis"];
	axis_flag.objpointflagmissing = game["objpointflagmissing"]["axis"];
	axis_flag thread flag();
}

flag()
{
	objective_add( self.objective, "current", self.origin, self.compassflag );
	self [[level.createFlagWaypoint]]( self.team+"_home_flag", self.origin, self.objpointflag );

	for( ;; )
	{
		self waittill( "trigger", other );

		if( isPlayer( other ) && isAlive( other ) && ( other.pers["team"] != "spectator" ) )
		{
			// PICKUP THE FLAG !!
			if( other.pers["team"] != self.team )
			{
				println( "PICKED UP THE FLAG!");

				friendlyAlias = "ctf_touchenemy";
				enemyAlias = "ctf_enemy_touchenemy";
				
				thread [[level.onPlaySoundOnPlayers]]( game["flagTaken"][other.pers["team"]], other.pers["team"] );

				thread [[level.onPlaySoundOnPlayers]]( friendlyAlias, self.team );
				thread [[level.onPlaySoundOnPlayers]]( enemyAlias, getOtherTeam( self.team ) );

				thread printOnTeam( &"MP_YOUR_FLAG_WAS_TAKEN", self.team );
				thread printOnTeam( &"MP_ENEMY_FLAG_TAKEN", getOtherTeam( self.team ) );

				other pickupFlag( self );
			}
			else 
			{
				// CAPTURED THE FLAG !!
				if( self.atbase )
				{
					if( isdefined( other.flag ) )
					{
						println( "CAPTURED THE FLAG!" );

						friendlyAlias = "ctf_touchcapture";
						enemyAlias = "ctf_enemy_touchcapture";

						thread [[level.onPlaySoundOnPlayers]]( game["flagCapped"][ getOtherTeam( self.team ) ] );

						thread [[level.onPlaySoundOnPlayers]]( friendlyAlias, self.team );
						thread [[level.onPlaySoundOnPlayers]]( enemyAlias, getOtherTeam( self.team ) );

						thread printOnTeam( &"MP_ENEMY_FLAG_CAPTURED", self.team );
						thread printOnTeam( &"MP_YOUR_FLAG_WAS_CAPTURED", getOtherTeam( self.team ) );

						other.flag returnFlag( undefined );
						other detachFlag( other.flag);
						other.flag = undefined;
						other.statusicon = "";

						other.score += 10;
						teamscore = getTeamScore( other.pers["team"]);
						teamscore += 1;
						setTeamScore( other.pers["team"], teamscore );
						level notify( "update_allhud_score");

						maps\mp\gametypes\_globalgametypes::checkScoreLimit();
					}
				}
				else // RETURNED FLAG TO BASE !!
				{					
					println( "RETURNED THE FLAG!");
					thread [[level.onPlaySoundOnPlayers]]( "ctf_touchown", self.team );
					thread printOnTeam( &"MP_YOUR_FLAG_WAS_RETURNED", self.team );

					self returnFlag( true );

					other.score += 2;
					level notify( "update_allhud_score" );
				}
			}
		}
		
		wait( 0.05 );
	}
}

pickupFlag( flag )
{
	flag notify( "end_autoreturn" );

	flag.origin = flag.origin + (0, 0, -10000);
	flag.flagmodel hide();
	self.flag = flag;
	
	level.useStartSpawns = false;
	
	if( !level.rank )
		self.statusicon = game["hudflag"][ getOtherTeam( self.pers["team"] ) ];

	self.dont_auto_balance = true;
	
	flag [[level.deleteFlagWaypoint]]( flag.team+"_home_flag" );
	flag [[level.deleteFlagWaypoint]]( flag.team+"_dropped_flag" );
	flag [[level.createFlagWaypoint]]( flag.team+"_missing_flag", flag.home_origin, flag.objpointflagmissing );

	objective_onEntity( self.flag.objective, self );
	objective_team( self.flag.objective, self.pers["team"] );

	self attachFlag( flag );
}

dropFlag()
{
	if( isdefined( self.flag ) )
	{
		start = self.origin + (0, 0, 10);
		end = start + (0, 0, -2000);
		trace = bulletTrace( start, end, false, undefined );

		self.flag.origin = trace["position"];
		self.flag.flagmodel.origin = self.flag.origin;
		self.flag.flagmodel show();
		self.flag.atbase = false;
		self.statusicon = "";

		objective_position( self.flag.objective, self.flag.origin );
		objective_team( self.flag.objective, "none" );

		self.flag [[level.createFlagWaypoint]]( self.flag.team+"_dropped_flag", self.flag.origin, self.flag.objpointflag );

		self.flag thread autoReturn();
		self detachFlag( self.flag );

		level thread [[level.onPlaySoundOnPlayers]]( game["flagDropped"][self.flag.team] );

		//check if it's in a flag_returner
		for( i = 0; i < level.flag_returners.size; i++ )
		{
			if( self.flag.flagmodel istouching( level.flag_returners[i] ) )
			{
				self.flag returnFlag( true );
				break;
			}
		}

		self.flag = undefined;
		self.dont_auto_balance = undefined;
	}
}

returnFlag( playsound )
{
	self notify( "end_autoreturn" );

 	self.origin = self.home_origin;
 	self.flagmodel.origin = self.home_origin;
 	self.flagmodel.angles = self.home_angles;
	self.flagmodel show();
	self.atbase = true;

	objective_position( self.objective, self.origin );
	objective_team( self.objective, "none" );
	
	self [[level.deleteFlagWaypoint]]( self.team+"_dropped_flag" );
	self [[level.deleteFlagWaypoint]]( self.team+"_missing_flag" );	
	self [[level.createFlagWaypoint]]( self.team+"_home_flag", self.origin, self.objpointflag );

	announce_return = false;
	if( isDefined( playsound ) && !level.mapended ) 
		announce_return = true;

	if( announce_return )
		self thread [[level.onPlaySoundOnPlayers]]( game["flagReturned"][ self.team ] );
}

autoReturn()
{
	self endon( "end_autoreturn" );

	wait( level.flag_returnTime );
	
	self thread returnFlag( true );
}

attachFlag( flag )
{
	if( isdefined( self.flagAttached ) )
		return;
	
	self attach( game["prop_flag_carry"][ flag.team ], "J_Spine4", true );
	self.flagAttached = true;
	
	self thread createHudIcon();
}

detachFlag( flag )
{
	if( !isdefined( self.flagAttached ) )
		return;
		
	self detach( game["prop_flag_carry"][ flag.team ], "J_Spine4" );
	self.flagAttached = undefined;

	self thread deleteHudIcon();
}

createHudIcon()
{
	iconSize = 40;

	self.hud_flag = newClientHudElem( self );
	self.hud_flag.x = 30;
	self.hud_flag.y = 95;
	self.hud_flag.alignX = "center";
	self.hud_flag.alignY = "middle";
	self.hud_flag.horzAlign = "left";
	self.hud_flag.vertAlign = "top";
	self.hud_flag.alpha = 0;
	self.hud_flag setShader( game["hudflag"][ getOtherTeam( self.pers["team"] ) ], iconSize, iconSize );

	self.hud_flagflash = newClientHudElem( self );
	self.hud_flagflash.x = 30;
	self.hud_flagflash.y = 95;
	self.hud_flagflash.alignX = "center";
	self.hud_flagflash.alignY = "middle";
	self.hud_flagflash.horzAlign = "left";
	self.hud_flagflash.vertAlign = "top";
	self.hud_flagflash.alpha = 0;
	self.hud_flagflash.sort = 1;
	self.hud_flagflash setShader( game["hudflagflash"][ getOtherTeam( self.pers["team"] )  ], iconSize, iconSize );
	
	self.hud_flagflash fadeOverTime( 0.2 );
	self.hud_flagflash.alpha = 1;

	self.hud_flag fadeOverTime( 0.2 );
	self.hud_flag.alpha = 1;

	wait( 0.2 );
	
	if( isdefined( self.hud_flagflash ) )
	{
		self.hud_flagflash fadeOverTime( 1 );
		self.hud_flagflash.alpha = 0;
	}
}

deleteHudIcon()
{
	if( isdefined( self.hud_flagflash ) )
		self.hud_flagflash destroy();
		
	if( isdefined( self.hud_flag ) )
		self.hud_flag destroy();
}

printOnTeam( text, team )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == team )
			players[i] iprintln( text );
	}
}

respawn_timer( delay )
{
	self endon( "disconnect" );

	self.WaitingToSpawn = true;

	if( level.respawndelay > 0 )
	{
		if( !isdefined( self.respawntimer ) )
		{
			self.respawntimer = newClientHudElem( self );
			self.respawntimer.x = 0;
			self.respawntimer.y = -50;
			self.respawntimer.alignX = "center";
			self.respawntimer.alignY = "middle";
			self.respawntimer.horzAlign = "center_safearea";
			self.respawntimer.vertAlign = "center_safearea";
			self.respawntimer.alpha = 0;
			self.respawntimer.archived = false;
			self.respawntimer.font = "default";
			self.respawntimer.fontscale = 2;
			self.respawntimer.label = (&"MP_TIME_TILL_SPAWN");
			self.respawntimer setTimer( level.respawndelay + delay );
		}

		wait( delay );
		
		self thread updateTimer();

		wait( level.respawndelay );

		if( isdefined( self.respawntimer ) )
			self.respawntimer destroy();
	}

	self.WaitingToSpawn = undefined;
}

updateTimer()
{
	if( isdefined( self.respawntimer ) )
	{
		if( isdefined( self.pers["team"] ) && (self.pers["team"] == "allies" || self.pers["team"] == "axis") && isdefined( self.pers["weapon"] ) )
			self.respawntimer.alpha = 1;
		else
			self.respawntimer.alpha = 0;
	}
}
