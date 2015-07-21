/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

main()
{
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "dm", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "dm", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "dm", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "dm", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "dm", 0, 0, 99 );

	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
}

onGametypeStarted()
{
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );

	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main( allowed );

	level.QuickMessageToAll = true;
}

onPlayerSpawned()
{
	spawnpointname = "mp_dm_spawn";
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnpoints );

	if( isdefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	if( level.scorelimit > 0 )
		self setClientCvar("cg_objectiveText", &"MP_GAIN_POINTS_BY_ELIMINATING", level.scorelimit);
	else
		self setClientCvar("cg_objectiveText", &"MP_GAIN_POINTS_BY_ELIMINATING_NOSCORE");
}


