/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

main()
{	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_startspawns::init();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "tdm", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "tdm", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "tdm", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "tdm", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "tdm", 0, 0, 99 );
	
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
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
}

onPlayerSpawned()
{
	if( level.startSpawns && level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_" + self.pers["team"] + "_start" );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}		
	else 
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnpoints );
	}

	self spawn( spawnpoint.origin, spawnpoint.angles );

	if( level.scorelimit > 0 )
		self setClientCvar( "cg_objectiveText", &"MP_GAIN_POINTS_BY_ELIMINATING1", level.scorelimit );
	else
		self setClientCvar( "cg_objectiveText", &"MP_GAIN_POINTS_BY_ELIMINATING1_NOSCORE" );
}


