/*************************************************
	Demon Mod for COD2 by Tally
	
	TEAM DEFENDER GAMETYPE
		
	
**************************************************/

main()
{	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_startspawns::init();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "tdef", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "tdef", 10, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "tdef", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "tdef", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "tdef", 0, 0, 99 );
	
	// this determines how many extra points each killer gets while their team holds the flag - this 
	// will always be on top of their standard kill score set in globalgametypes
	level.points_for_flagteam = demon\_utils::cvardef( "scr_tdef_flagteam_points", 1, 0, 99, "int" );
	
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPrecacheGametype = ::onPrecacheGametype;
	level.onPlayerDisconnect = ::onPlayerDisconnect;
	level.onPlayerKilled = ::onPlayerKilled;
}

onPrecacheGametype()
{
	game["prop_flag"] = [];
	game["prop_flag_carry"] = [];
	game["hudflag"] = [];
	game["compassflag"] = [];
	game["objpointflag"] = [];
	game["statusicon_carrier"] = [];
	
	game["prop_flag"]["allies"] 		= "xmodel/prop_flag_" + game["allies"];
	game["prop_flag"]["axis"] 			= "xmodel/prop_flag_" + game["axis"];
	game["prop_flag"]["neutral"] 		= "xmodel/prop_flag_neutral";
	
	game["prop_flag_carry"]["allies"] 	= "xmodel/prop_flag_" + game["allies"] + "_carry";
	game["prop_flag_carry"]["axis"] 	= "xmodel/prop_flag_" + game["axis"] + "_carry";
	
	game["compassflag"]["allies"] = "compass_flag_" + game["allies"];
	game["compassflag"]["axis"] = "compass_flag_" + game["axis"];
	game["compassflag"]["neutral"] = "compass_flag_neutral";
	
	game["hudflag"]["allies"] = "compass_flag_" + game["allies"];
	game["hudflag"]["axis"] = "compass_flag_" + game["axis"];
	
	game["objpointflag"]["neutral"] = "objpoint_flag_neutral";
	
	if( !level.rank )
	{
		game["statusicon_carrier"]["allies"] = "compass_flag_" + game["allies"];
		game["statusicon_carrier"]["axis"] = "compass_flag_" + game["axis"];
	}
	
	precacheModel( game["prop_flag"]["allies"] );
	precacheModel( game["prop_flag"]["axis"] );
	precacheModel( game["prop_flag"]["neutral"] );
	precacheModel( game["prop_flag_carry"]["allies"] );
	precacheModel( game["prop_flag_carry"]["axis"] );
	
	precacheShader( game["hudflag"]["allies"] );
	precacheShader( game["hudflag"]["axis"] );
	precacheShader( game["compassflag"]["allies"] );
	precacheShader( game["compassflag"]["axis"] );
	precacheShader( game["compassflag"]["neutral"] );
	precacheShader( game["objpointflag"]["neutral"] );
	
	if( !level.rank )
	{
		precacheStatusIcon( game["statusicon_carrier"]["allies"] );
		precacheStatusIcon( game["statusicon_carrier"]["axis"] );
	}
	
	precacheString( &"TDEF_FLAG_RESET" );
	precacheString( &"TDEF_STOLE_FLAG" );
	precacheString( &"TDEF_FLAG_DROPPED" );
	precacheString( &"TDEF_OBJECTIVE_HINT" );
	precacheString( &"TDEF_OBJECTIVE_HINT_SCORE" );
}

onGametypeStarted()
{	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	level.spawn_allies_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_allies_start" );
	level.spawn_axis_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_axis_start" );

	allowed[0] = "tdm";
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	level.firstBlood = false;
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
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnpoints );
	}

	self spawn( spawnpoint.origin, spawnpoint.angles );

	if( level.scorelimit > 0 )
		self setClientCvar( "cg_objectiveText", &"TDEF_OBJECTIVE_HINT_SCORE", level.scorelimit );
	else
		self setClientCvar( "cg_objectiveText", &"TDEF_OBJECTIVE_HINT" );
}

onPlayerDisconnect()
{
	self dropFlag();
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( !level.firstBlood && isPlayer( attacker ) && attacker != self )
	{
		thread SpawnFirstFlag( self getDropPoint(), self.pers["team"] );
	}
	
	self dropFlag();

	// Give extra points to an attacker whose team holds the flag
	if( isDefined( level.flag ) && attacker.pers["team"] == level.flag.team )
	{
		attacker.pers["score"] += level.points_for_flagteam;
		attacker.score = attacker.pers["score"];

		teamscore = getTeamScore( attacker.pers["team"] );
		teamscore++;
		setTeamScore( attacker.pers["team"], teamscore );
		level notify( "update_allhud_score" );
		
		maps\mp\gametypes\_globalgametypes::checkScoreLimit();
	}
}

SpawnFirstFlag( origin, team )
{	
	level.firstBlood = true;
	
	level.flag = spawn( "script_model", origin + (0, 0, 5) );
	level.flag.origin = origin + (0, 0, 5);
	level.flag.angles = (0, 0, 0);
	level.flag setModel( game["prop_flag"]["neutral"] );
	level.flag.team = "neutral";
	level.flag.objectiveNum = 1;
	level.flag.compassflag = game["compassflag"]["neutral"];
	level.flag.objpointflag = game["objpointflag"]["neutral"];
	level.flag thread [[level.createFlagWaypoint]]( "neutral_flag", level.flag.origin, level.flag.objpointflag );
	
	level.flag AnnouncetoAll( &"TDEF_FLAG_DROPPED" );
	thread [[level.onPlaySoundOnPlayers]]( "ctf_enemy_touchcapture", team );
	thread [[level.onPlaySoundOnPlayers]]( "ctf_enemy_touchcapture", getOtherTeam( team ) );
	
	level.flag thread trigger_radius();
	level.flag thread flag_think();
}

trigger_radius()
{
	level endon( "intermission" );
	self endon( "death" );
	
	while( isDefined( self ) )
	{
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) 
		{             
			player = players[i];
			
			if( isPlayer( player ) && player.sessionstate == "playing" && distance( self.origin, player.origin ) < 50 )
				self notify( "trigger", player );
		}	
		
		wait( 0.05 );
	}
}

flag_think()
{
	level endon( "intermission" );
	self endon( "death" );
	
	objective_add( self.objectiveNum, "current", self.origin, self.compassflag );
	
	for( ;; )
	{
		self waittill( "trigger", other );

		if( isPlayer( other ) && isAlive( other ) && ( other.pers["team"] != "spectator" ) )
		{
			thread [[level.onPlaySoundOnPlayers]]( "ctf_touchown", other.pers["team"] );
			other pickupFlag( self );
			other AnnouncetoAll( &"TDEF_STOLE_FLAG", other.name );
			
			// Logfile
			lpselfnum = other getEntityNumber();
			lpselfguid = other getGuid();
			logPrint( "A;" + lpselfguid + ";" + lpselfnum + ";" + other.name + ";" + "tdef_stole_flag" + "\n" );
		}
	}
}

pickupFlag( flag )
{	
	flag.origin = flag.origin + (0, 0, -10000);
	flag setModel( game["prop_flag"]["neutral"] );
	flag.team = self.pers["team"];
	flag thread [[level.deleteFlagWaypoint]]( "neutral_flag" );
	flag hide();
	
	if( !level.rank )
		self.statusicon = game["statusicon_carrier"][ self.pers["team"] ];

	self.dont_auto_balance = true;
	
	objective_add( flag.objectiveNum, "current", flag.origin, game[ "compassflag"][ self.pers["team"] ] );
	objective_onEntity( flag.objectiveNum, self );
	objective_team( flag.objectiveNum, "none" );

	self attachFlag();
}

dropFlag()
{
	if( !isdefined( self.flagAttached ) )
		return; 
		
	if( isdefined( level.flag ) )
	{
		self detachFlag();

		if( !level.rank )
			self.statusicon = "";

		self.dont_auto_balance = undefined;
		
		thread [[level.onPlaySoundOnPlayers]]( "ctf_enemy_touchcapture", self.pers["team"] );
		thread [[level.onPlaySoundOnPlayers]]( "ctf_enemy_touchcapture", getOtherTeam( self.pers["team"] ) );
		
		// make the flag team neutral at this point since it might be dropped in a minefield
		level.flag.team = "neutral";

		// check if the dropped flag is in a mine field
		if( self isNearMinefield() )
		{
			level.flag thread MinefieldResetFlag();
			return;
		}
		
		level.flag.origin = self getDropPoint();
		level.flag thread [[level.createFlagWaypoint]]( "neutral_flag", level.flag.origin, level.flag.objpointflag );
		level.flag show();
		
		self AnnouncetoAll( &"TDEF_FLAG_DROPPED" );
		
		objective_add( level.flag.objectiveNum, "current", level.flag.origin, level.flag.compassflag );
		objective_team( level.flag.objectiveNum, "none" );
	}
}

attachFlag()
{
	if( isdefined( self.flagAttached ) )
		return;
	
	self attach( game["prop_flag_carry"][ self.pers["team"] ], "j_spine4", true );
	self.flagAttached = true;
	
	self thread createHudIcon();
}

detachFlag()
{
	if( !isdefined( self.flagAttached ) )
		return; 
		
	self detach( game["prop_flag_carry"][ self.pers["team"] ], "j_spine4" );
	self.flagAttached = undefined;
	
	self thread deleteHudIcon();
}

createHudIcon()
{
	self deleteHudIcon();
	
	self.flagindicator = newClientHudElem( self );	
	self.flagindicator.x = 30;
	self.flagindicator.y = 95;
	self.flagindicator.alignX = "center";
	self.flagindicator.alignY = "middle";
	self.flagindicator.horzAlign = "left";
	self.flagindicator.vertAlign = "top";
	self.flagindicator.alpha = 0.8;
	self.flagindicator setShader( game["hudflag"][ self.pers["team"] ], 50, 50 );
}

deleteHudIcon()
{
	if( isDefined( self.flagindicator ) ) self.flagindicator destroy();
}

getDropPoint()
{
	start = self.origin + (0, 0, 5);
	end = start + (0, 0, -2000);
	trace = bulletTrace( start, end, false, undefined );
	
	return( trace["position"] );
}

getOtherTeam( team )
{
	if( team == "allies" )
		return "axis";
	else
		return "allies";
}

AnnouncetoTeam( team, teamMsg )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		if( players[i].pers["team"] == team )
			players[i] iprintlnbold( teamMsg );
	}
}

AnnouncetoAll( str, name )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		if( isdefined( name ) )
			players[i] iprintlnbold( str, name );
		else
			players[i] iprintlnbold( str );
	}
}

isNearMinefield()
{
	minefields = getEntArray( "minefield", "targetname" );
	if( minefields.size > 0 )
		for( i=0; i < minefields.size; i++ )
			if( minefields[i] istouching( self ) )
				return true;
	
	return false;
}

MinefieldResetFlag()
{	
	self endon( "death" );
	
	level.firstBlood = false;
	
	objective_delete( self.objectiveNum );

	self AnnouncetoAll( &"TDEF_FLAG_RESET" );
	wait( 0.75 );
	self AnnouncetoAll( &"TDEF_FLAG_RESET_PRT2" );

	if( isDefined( self ) )
		self delete();
}
