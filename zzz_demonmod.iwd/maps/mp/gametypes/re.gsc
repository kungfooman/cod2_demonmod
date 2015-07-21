/*************************************************
	Demon Mod for COD2 by Tally
	
	RETRIEVAL GAMETYPE
	
**************************************************/

#include demon\_utils;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

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
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onPlayerDisconnect = ::onPlayerDisconnect;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onObjectiveComplete = ::onObjectiveComplete;
	
	thread GetFieldDim();
	
	thread FixBadSpawns();
}

// We need to fix these spawns on various maps because they are out of reach and might be used for an objective 
// and players wont be able to reach them.
FixBadSpawns()
{
	switch( level.script )
	{
		case "mp_railyard":
		{
			locator = spawn( "script_origin", (-1537, -101, 61) );
			spawns = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
			for( i=0; i < spawns.size; i++ )
				if( distance( spawns[i].origin, locator.origin ) < 100 )
					spawns[i].origin = locator.origin;
		}
		break;
	
		case "mp_dawnville":
		{
			locator = spawn( "script_origin", (-40, -16899, 43) );
			spawns = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
			for( i=0; i < spawns.size; i++ )
				if( distance( spawns[i].origin, locator.origin ) < 200 )
					spawns[i].origin = locator.origin;
		}	
		break;

		case "mp_downtown":
		{
			locator = spawn( "script_origin", (2161, -1860, 272) );
			spawns = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
			for( i=0; i < spawns.size; i++ )
				if( distance( spawns[i].origin, locator.origin ) < 200 )
					spawns[i].origin = locator.origin;
		}	
		break;
	
		default:
			break;
	
	}
}

onPrecacheGameType()
{
	demonPrecacheModel( "xmodel/static_berlin_ger_radio" );
	demonPrecacheModel( "xmodel/static_berlin_diary" );
	demonPrecacheShader( "objpoint_A" );
	demonPrecacheShader( "objpoint_B" );
	demonPrecacheShader( "objpoint_C" );
	demonPrecacheShader( "objectiveA" );
	demonPrecacheShader( "objectiveB" );
	demonPrecacheShader( "hud_radio" );
	demonPrecacheShader( "hud_diary" );
	demonPrecacheShader( "objectiveC" );

	game["strings"]["objectives_reached"] = &"RE_OBJ_CAPTURED_ALL";
	game["strings"]["capping_objective"] = &"RE_CAPPING_OBJECTIVE";
	
	precacheString( game["strings"]["objectives_reached"] );
	precacheString( game["strings"]["capping_objective"] );
	
	game["objective_tickring"] = [];
	game["objective_tickring"]["home"] 		= loadfx( "fx/tickrings/objective_pickup_blue" );
	game["objective_tickring"]["target"]	= loadfx( "fx/tickrings/objective_pickup_gold" );
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
	
	level.objective_captime = 7;
	level.objective_returndelay = 20;
	game["objectives_taken"] = 0;
	
	thread SetUp();
}

onPlayerSpawned()
{
	self.objectiveAttached = undefined;
	
	if( level.startSpawns && level.useStartSpawns )
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

onPlayerDisconnect()
{
	self dropObjective();
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self dropObjective();
}

SetUp()
{
	wait( 0.10 );
	
	// spawn a map center indicator
	mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( game["playArea_Min"], game["playArea_Max"] );
	groundpoint = FindGround( mapCenter );
	level.indicator = spawn( "script_model", groundpoint );
	level.indicator.origin = groundpoint;

	// Determine the size of the map based on number of spawns
	// Set distances for the objectives to spawn based on that size
	level.maxSpawnNum = maxSpawnNum( game["playArea_Min"], game["playArea_Max"] );
	min_dist_apart = undefined;
	indicator_distance = undefined;
	if( level.maxSpawnNum <= 2500 ) // SMALL 
	{
		min_dist_apart = 400;
		indicator_distance = 800;
	}
	else if( level.maxSpawnNum <= 6000 ) // MEDIUM
	{
		min_dist_apart = 600;
		indicator_distance = 1000;
	}
	else // LARGE
	{
		min_dist_apart = 600;
		indicator_distance = 1300;
	}

	// setup the map center indicator array so we can find all spawnpoints in its radius
	level.indicator_array = [];
	spawns = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
	for( i=0; i < spawns.size; i++ )
	{
		if( distance( spawns[i].origin, level.indicator.origin ) < indicator_distance )
			level.indicator_array[level.indicator_array.size] = spawns[i];
	}
	
	// Abort if there aren't any spawns in the map center indicator array
	if( !level.indicator_array.size )
	{
		printLn( "^1No Spawns Near Map Center Indicator found in Level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	
	// setup the objective spawns
	re_spawnpoints = [];
	
	delete_spawn = [];
	for( i=0; i < 2; )
	{
		spawnpos = level.indicator_array[ randomInt( level.indicator_array.size ) ];
	
		spawnpos.findanother = false;
			
		for( j = 0; j < re_spawnpoints.size; j++ )
			if( distance( spawnpos.origin, re_spawnpoints[j].origin ) < min_dist_apart ) 
				spawnpos.findanother = true;

		if( !spawnpos.findanother )
		{
			re_spawnpoints[i] = spawnpos;
			SpawnTriggers( spawnpos, GetObjectiveLetter( i ) );
			UpdateSpawnpointArray( spawnpos );
			delete_spawn[delete_spawn.size] = spawnpos;
			i++;
		}

		wait( 0.05 );
	}
	
	// delete the spawnpoints that the objectives are sitting on
	for( i=0; i < delete_spawn.size; i++ )
		delete_spawn[i] delete();
	
	level notify( "re_setup_done" );
	
	thread ObjectiveSetUp();
	thread BaseSetup();

	/#
		thread Test_Debug();
	#/
}

maxSpawnNum( mins, maxs )
{
	spawns = ( 0, 0, 0 );
	spawns = maxs - mins;
	spawns = ( spawns[0], spawns[1], spawns[2] ) + mins;
	return( spawns[0] );
}

// We need to update these spawnpoint arrays by removing the objective spawnpoints from their arrays,
// otherwise we can't delete the spawnpoints without incurring lots of runtime errors
UpdateSpawnpointArray( spawnpoint )
{
	level.spawnpoints = remove_element_from_array( level.spawnpoints, spawnpoint );
	level.teamSpawnPoints["allies"] = remove_element_from_array( level.teamSpawnPoints["allies"], spawnpoint );
	level.teamSpawnPoints["axis"] = remove_element_from_array( level.teamSpawnPoints["axis"], spawnpoint );
	
	/#
	level.indicator_array = remove_element_from_array( level.indicator_array, spawnpoint );
	#/
}

/#
Test_Debug()
{
	while( true )
	{
		if( getCvar( "scr_redebug") != "1" ) 
		{
			wait( 2 );
			continue;
		}
		
		for( ;; )
		{
			for( j=0; j < level.indicator_array.size; j++ )
				line( level.indicator.origin+(0,0,20), level.indicator_array[j].origin+(0,0,40), (1.000,0.502,0.000) );
			
			print3d( level.indicator.origin+(0,0,30), "Map Center Indicator" );
			
			wait( 0.05 );
		}
	}
}
#/

SpawnTriggers( spawnpoint, objectiveLetter )
{
	groundpoint = FindGround( spawnpoint.origin );
	origin = getForwardPosition( spawnpoint.angles, groundpoint );
	
	ent = spawn( "trigger_radius", origin, 0, 70, 80 );
	ent.targetname = "objective_" + objectiveLetter;
	ent.objectiveLetter = objectiveLetter;
}

ObjectiveSetUp()
{
	wait( 0.75 );
	
	///////////// RADIO ////////////////////
	
	level.objectives = [];
	
	objective_a = getEnt( "objective_a", "targetname" );
	objective_a.home_origin = objective_a.origin;
	objective_a.objectivenum = 0;
	objective_a.objective_name = "radio";
	objective_a.ownerTeam = game["defenders"];
	objective_a.atBase = true;
	objective_a.indicator = "objpoint_A";
	
	objective_a.Objmodel = spawn( "script_model", objective_a.home_origin+(0,0,35) );
	objective_a.Objmodel setModel( "xmodel/static_berlin_ger_radio" );
	objective_a.Objmodel thread spinObjective();
	
	objective_a [[level.createFlagWaypoint]]( objective_a.objective_name, objective_a.home_origin, objective_a.indicator, 55 );
	
	origin = FindGround( objective_a.home_origin );
	objective_a.effectObj = playLoopedFx( game["objective_tickring"]["target"], 0.90, origin );
	
	objective_a thread objective_think();
	
	level.objectives[level.objectives.size] = objective_a;
	
	///////////// DIARY ////////////////////

	objective_b = getEnt( "objective_b", "targetname" );
	objective_b.home_origin = objective_b.origin;
	objective_b.objectivenum = 1;
	objective_b.objective_name = "diary";
	objective_b.ownerTeam = game["defenders"];
	objective_b.atBase = true;
	objective_b.indicator = "objpoint_B";
	
	objective_b.Objmodel = spawn( "script_model", objective_b.home_origin+(0,0,35) );
	objective_b.Objmodel setModel( "xmodel/static_berlin_diary" );
	objective_b.Objmodel thread spinObjective();

	objective_b [[level.createFlagWaypoint]]( objective_b.objective_name, objective_b.home_origin, objective_b.indicator, 55 );
	
	origin = FindGround( objective_b.home_origin );
	objective_b.effectObj = playLoopedFx( game["objective_tickring"]["target"], 0.90, origin );
	
	objective_b thread objective_think();
	
	level.objectives[level.objectives.size] = objective_b;
}

BaseSetup()
{
	// setup the base array
	base_spawn = undefined;
	if( level.startSpawns )
	{
		if( game["attackers"] == "allies" )
			base_spawn = level.spawn_allies_start;
		else
			base_spawn = level.spawn_axis_start;
	}
	else
	{
		// TO DO: need to find a way of spawning a base if there aren't any startspawns		
		return;
	}

	spawnpoint = base_spawn[ randomInt( base_spawn.size ) ];
	groundpoint = FindGround( spawnpoint.origin );
	
	base = spawn( "trigger_radius", groundpoint, 0, 60, 60 );
	base.origin = groundpoint;
	base.angles = (0,0,0);
	base.targetname = "base";
	base.objectivenum = 2;
	base.indicator = "objpoint_C";
	
	base.radioModel = spawn( "script_model", base.origin+( 0,0,25 ) );
	base.radioModel.angles = base.angles;
	base.radioModel setmodel( "xmodel/static_berlin_ger_radio" );
	base.radioModel thread spinobjective();
	base.radioModel hide();

	base.diaryModel = spawn( "script_model", base.origin+( 0,0,45 ) );
	base.diaryModel.angles = base.angles;
	base.diaryModel setmodel( "xmodel/static_berlin_diary" );
	base.diaryModel thread spinobjective();
	base.diaryModel hide();
	
	wait( 20 );
	
	base [[level.createFlagWaypoint]]( base.targetname, base.origin, base.indicator, 70 );
	base.effectObj = playLoopedFx( game["objective_tickring"]["home"], 0.90, base.origin );
	objective_add( base.objectivenum, "current", base.origin, "objectiveC" );
	
	base thread Objective_Base_think();
}

objective_think()
{
	objective_add( self.objectivenum, "current", self.origin, "objective"+self.objectiveLetter );
	
	self.beingCapped = undefined;
	for( ;; )
	{
		self waittill( "trigger", player );
		
		if( isPlayer( player ) && isAlive( player ) && player.pers["team"] != "spectator" )
		{
			if( player.pers["team"] == game["attackers"] )
			{
				if( isDefined( self.beingCapped ) )
					continue;
				
				while( isAlive( player ) && player isTouching( self ) && player isOnGround() && !isdefined( player.objectiveAttached ) )
				{
					self.beingCapped = true;
					
					player.progresstime = 0; 
										
					while( isAlive( player ) && player isTouching( self ) && ( player.progresstime < level.objective_captime ) )
					{
						player.progresstime += 0.05;
						
						player updateSecondaryProgressBar( player.progresstime, level.objective_captime, false, game["strings"]["capping_objective"] );

						wait( 0.05 );
					}
						
					player updateSecondaryProgressBar( undefined, undefined, true, undefined );
					self.beingCapped = undefined;
					
					if( player.progresstime >= level.objective_captime )	
					{
						self setOwnerTeam( game["attackers"] );
						
						player pickupObjective( self );
						
						lpselfnum = player getEntityNumber();
						lpselfguid = player getGuid();
						logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + player.name + ";" + "re_pickedup_objective" + "\n");
					}
					else
						continue;
				}
			}
		}
		
		wait( 0.05 );
	}
}

Objective_Base_think()
{
	for( ;; )
	{
		self waittill( "trigger", player );
		
		if( isPlayer( player ) && isAlive( player ) && player.pers["team"] != "spectator" )
		{
			if( player.pers["team"] == game["attackers"] && player isTouching( self ) && player isOnGround() && isdefined( player.objectiveAttached ) )
			{
				player thread [[level.onObjectiveComplete]]( self );
			}
		}
		
		wait( 0.05 );
	}
}

onObjectiveComplete( objective )
{
	objective_delete( self.objective.objectivenum );
	
	if( self.objective.objective_name == "radio" )
	{
		objective.radioModel show();
		level.primary_objective = true;
	}
	else
	{
		objective.diaryModel show();
		level.secondary_objective = true;
	}

	self detachObjective();
	self.objective = undefined;
	// self thread Check_ObjectivesDone();
	
	game["objectives_taken"]++;
}

pickupObjective( objective )
{
	level.useStartSpawns = false;
	
	if( isdefined( objective.effectObj ) ) objective.effectObj delete();
	
	objective.origin = objective.origin + (0, 0, -10000);
	objective.Objmodel hide();
	objective.Objmodel notify( "stop_spinning" );
	self.objective = objective;
	
	objective_onEntity( self.objective.objectivenum, self );
	objective_team( self.objective.objectivenum, "none" );
	objective [[level.deleteFlagWaypoint]]( objective.objective_name );
	
	self thread attachObjective();
}

dropObjective()
{
	if( isdefined( self.objective ) )
	{
		start = self.origin + (0, 0, 10);
		end = start + (0, 0, -2000);
		trace = bulletTrace( start, end, false, undefined );
		
		self.objective.origin = trace["position"]+(0,30,0);
		self.objective.Objmodel.origin = self.objective.origin;
		self.objective.Objmodel show();
		
		self.objective [[level.createFlagWaypoint]]( self.objective.objective_name, self.objective.origin, self.objective.indicator, 20 );
		objective_position( self.objective.objectivenum, self.objective.origin );
		objective_team( self.objective.objectivenum, "none" );
		
		self.objective.atbase = false;
		self.objective.isFlashing = false;
	//	self.statusicon = "";
		
		self.objective thread autoReturn();
		self thread detachObjective();

		self.objective = undefined;
		self.dont_auto_balance = undefined;
	}
}

attachObjective()
{
	if( isdefined( self.ObjectiveAttached ) )
		return;
	
	self.ObjectiveAttached = true;
	
	self thread createHudIcon( self.objective );
}

detachObjective()
{
	if( !isdefined( self.ObjectiveAttached ) )
		return;

	self.ObjectiveAttached = undefined;
	
	self.statusicon = "";
	
	self thread deleteHudIcon();
}

autoReturn()
{
	self endon( "end_autoreturn" );

	wait( level.objective_returndelay );
/*
	if( isdefined( self.objective_name ) )
		iprintln( &"RE_RETURNED_BASE", self.ownerTeam, self.objective_name, level.objective_returndelay );
*/
	self thread returnObjective();
}

returnObjective()
{
	self notify( "end_autoreturn" );
	
	// OBJECTIVE
	self.origin = self.home_origin;
	self.atbase = true;
	self.effectObj = playLoopedFx( game["objective_tickring"]["target"], 0.90, self.origin );
	
	// MODEL
	self.Objmodel.origin = self.origin+(0,0,35);
	self.Objmodel thread spinObjective();
	
	// INDICATORS
	self [[level.deleteFlagWaypoint]]( self.objective_name );
	self [[level.createFlagWaypoint]]( self.objective_name, self.origin, self.indicator, 55 );
	objective_position( self.objectivenum, self.origin );
	objective_team( self.objectivenum, "none" );
}

getObjectivesTeam()
{
	return( self getOwnerTeam() );
}

setOwnerTeam( team )
{
	self.ownerTeam = team;
}

getOwnerTeam()
{
	return( self.ownerTeam );
}

createHudIcon( objective )
{
	self.hud_objective_icon = newClientHudElem( self );
	self.hud_objective_icon.x = 0;
	self.hud_objective_icon.y = 160;
	self.hud_objective_icon.alignX = "center";
	self.hud_objective_icon.alignY = "middle";
	self.hud_objective_icon.horzAlign = "center_safearea";
	self.hud_objective_icon.vertAlign = "center_safearea";
	self.hud_objective_icon.alpha = .9;
	self.hud_objective_icon.archived = false;
	self.hud_objective_icon setShader( "hud_" + objective.objective_name, 60, 60 );
}

deleteHudIcon()
{
	if( isdefined( self.hud_objective_icon ) ) self.hud_objective_icon destroy();
}

//////////////////////////////////////////////////////////////////////////////////////////////////

GetObjectiveLetter( num )
{
	switch( num )
	{
		case 0: return "a";
		case 1: return "b";
	}
}

getForwardPosition( angles, groundpoint )
{
	position = undefined;
	forward = anglesToForward( angles );
	forward = vectorScale( forward, 80 );
	position = groundpoint + forward;
		
	return( position );
}

FindGround( position )
{
	trace = bulletTrace( position+(0,0,10), position+(0,0,-10000), false, undefined );
	ground = trace["position"];
	return( ground );
}

GetFieldDim()
{
	spawnpoints = [];

	spawnpoints_tdm = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
	for( i = 0; i < spawnpoints_tdm.size; i++ ) 
		spawnpoints = add_to_array( spawnpoints, spawnpoints_tdm[i] );

	xMax = spawnpoints[0].origin[0];
	xMin = spawnpoints[0].origin[0];

	yMax = spawnpoints[0].origin[1];
	yMin = spawnpoints[0].origin[1];

	zMax = spawnpoints[0].origin[2];
	zMin = spawnpoints[0].origin[2];

	for( i = 1; i < spawnpoints.size; i++ )
	{
		if( spawnpoints[i].origin[0] > xMax ) xMax = spawnpoints[i].origin[0];
		if( spawnpoints[i].origin[1] > yMax ) yMax = spawnpoints[i].origin[1];
		if( spawnpoints[i].origin[2] > zMax ) zMax = spawnpoints[i].origin[2];
		if( spawnpoints[i].origin[0] < xMin ) xMin = spawnpoints[i].origin[0];
		if( spawnpoints[i].origin[1] < yMin ) yMin = spawnpoints[i].origin[1];
		if( spawnpoints[i].origin[2] < zMin ) zMin = spawnpoints[i].origin[2];
	}

	game["playArea_Min"] = (xMin, yMin, zMin);
	game["playArea_Max"] = (xMax, yMax, zMax);
}

spinObjective()
{
	if( self.spawnflags & 2 || self.classname == "script_model" )
	{
		self endon( "stop_spinning" );
		
		org = spawn( "script_origin", self.origin );
		org endon( "stop_spinning" );
		
		self linkto( org );
		self thread deleteOnDeath( org );
		
		while( true )
		{
			org rotateyaw( 360, 3, 0, 0 );
			wait( 2.9 );
		}
	}
}

deleteOnDeath( ent )
{
	ent endon( "stop_spinning" );
	self waittill( "stop_spinning" );
	ent delete();
}

