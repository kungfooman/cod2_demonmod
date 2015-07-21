#include maps\mp\gametypes\_hud_util;
#include demon\_utils;

main()
{
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_startspawns::init();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "dom", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "dom", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "dom", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "dom", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "dom", 0, 0, 99 );
	
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onPlayerScore = ::onPlayerScore;
	
	if( !init_domFlags() )
	{
		printLn( "^1No DOM Flags found in Level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
}

onPrecacheGameType()
{
	game["flagmodels"] = [];
	
	game["flagmodels"]["neutral"] = "xmodel/prop_flag_neutral";
	game["flagmodels"]["allies"] = "xmodel/prop_flag_" + game["allies"];
	game["flagmodels"]["axis"] = "xmodel/prop_flag_" + game["axis"];
	
	precacheModel( game["flagmodels"]["neutral"] );
	precacheModel( game["flagmodels"]["allies"] );
	precacheModel( game["flagmodels"]["axis"] );
	
	precacheString( &"DOM_CAPTURING_FLAG" );
	precacheString( &"DOM_LOSING_FLAG" );
	precacheString( &"DOM_YOUR_FLAG_WAS_CAPTURED" );
	precacheString( &"DOM_ENEMY_FLAG_CAPTURED" );
	precacheString( &"DOM_NEUTRAL_FLAG_CAPTURED" );
	precacheString( &"DOM_ENEMY_FLAG_CAPTURED_BY" );
	precacheString( &"DOM_NEUTRAL_FLAG_CAPTURED_BY" );
	precacheString( &"DOM_FRIENDLY_FLAG_CAPTURED_BY" );

	precacheShader( "compass_waypoint_capture" );
	precacheShader( "compass_waypoint_capture_a" );
	precacheShader( "compass_waypoint_capture_b" );
	precacheShader( "compass_waypoint_capture_c" );
	precacheShader( "compass_waypoint_captureneutral" );
	precacheShader( "compass_waypoint_captureneutral_a" );
	precacheShader( "compass_waypoint_captureneutral_b" );
	precacheShader( "compass_waypoint_captureneutral_c" );
	precacheShader( "compass_waypoint_defend" );
	precacheShader( "compass_waypoint_defend_a" );
	precacheShader( "compass_waypoint_defend_b" );
	precacheShader( "compass_waypoint_defend_c" );

	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_defend_c" );

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
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level.spawn_all = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
	level.spawn_allies_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_allies_start" );
	level.spawn_axis_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_spawn_axis_start" );
	
	level.startPos["allies"] = level.spawn_allies_start[0].origin;
	level.startPos["axis"] = level.spawn_axis_start[0].origin;
	
	allowed[0] = "ctf";
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	level.lastSlowProcessFrame = 0;
	level.scoreInfo = [];

	registerScoreInfo( "capture", cvardef( "scr_dom_player_capture", 15, 0, 99, "int" ) );
	registerScoreInfo( "defend", cvardef( "scr_dom_player_defend", 5, 0, 99, "int" ) );
	registerScoreInfo( "assault", cvardef( "scr_dom_player_assult", 5, 0, 99, "int" ) );
		
	thread domFlags();
	thread updateDomScores();	
}

onPlayerSpawned()
{
	spawnpoint = undefined;
	
	if( !level.useStartSpawns )
	{
		flagsOwned = 0;
		enemyFlagsOwned = 0;
		myTeam = self.pers["team"];
		enemyTeam = getOtherTeam( myTeam );
		for( i = 0; i < level.flags.size; i++ )
		{
			team = level.flags[i] getFlagTeam();
			if( team == myTeam )
				flagsOwned++;
			else if( team == enemyTeam )
				enemyFlagsOwned++;
		}
		
		if( flagsOwned == level.flags.size )
		{
			// own all flags! pretend we don't own the last one we got, so enemies can spawn there
			enemyBestSpawnFlag = level.bestSpawnFlag[ getOtherTeam( self.pers["team"] ) ];
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( getSpawnsBoundingFlag( enemyBestSpawnFlag ) );
		}
		else if( flagsOwned > 0 )
		{
			// spawn near any flag we own that's nearish something we can capture
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( getBoundaryFlagSpawns( myTeam ) );
		}
		else
		{
			// own no flags!
			bestFlag = undefined;
			if( enemyFlagsOwned > 0 && enemyFlagsOwned < level.flags.size )
			{
				// there should be an unowned one to use
				bestFlag = getUnownedFlagNearestStart( myTeam );
			}
			if( !isdefined( bestFlag ) )
			{
				// pretend we still own the last one we lost
				bestFlag = level.bestSpawnFlag[ self.pers["team"] ];
			}
			level.bestSpawnFlag[ self.pers["team"] ] = bestFlag;
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( bestFlag.nearbyspawns );
		}
	}
	
	if( level.startSpawns && !isdefined( spawnpoint ) )
	{
		if( self.pers["team"] == "axis" )
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_axis_start );
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_allies_start );
	}
	
	assert( isDefined(spawnpoint) );
	
	self spawn( spawnpoint.origin, spawnpoint.angles );
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( self.touchTriggers.size && isPlayer( attacker ) && attacker.pers["team"] != self.pers["team"] )
	{
		triggerIds = self.touchTriggersID;
		ownerTeam = self.touchTriggers[triggerIds].useObj.ownerTeam;
		team = self.pers["team"];
		
		if( team == ownerTeam )
			givePlayerScore( "assault", attacker );
		else
			givePlayerScore( "defend", attacker );
	}
}

domFlags()
{
	level.lastStatus["allies"] = 0;
	level.lastStatus["axis"] = 0;
	
	primaryFlags = getEntArray( "flag_primary", "targetname" );
	
	if( primaryFlags.size < 2 )
	{
		printLn( "^1Not enough domination flags found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	
	level.flags = [];
	for( index = 0; index < primaryFlags.size; index++ )
		level.flags[level.flags.size] = primaryFlags[index];
	
	level.domFlags = [];
	for( index = 0; index < level.flags.size; index++ )
	{
		trigger = level.flags[index];
		if( isDefined( trigger.target ) )
		{
			visuals[0] = getEnt( trigger.target, "targetname" );
		}
		else
		{
			visuals[0] = spawn( "script_model", trigger.origin );
			visuals[0].angles = trigger.angles;
		}

		visuals[0] setModel( game["flagmodels"]["neutral"] );

		domFlag = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,100) );
		domFlag maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		domFlag maps\mp\gametypes\_gameobjects::setUseTime( 10.0 );
		domFlag maps\mp\gametypes\_gameobjects::setUseText( &"DOM_CAPTURING_FLAG" );
		label = domFlag maps\mp\gametypes\_gameobjects::getLabel();
		domFlag.label = label;
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		domFlag.didStatusNotify = false;
		
		domFlag.onUse = ::onUse;
		domFlag.onBeginUse = ::onBeginUse;
		domFlag.onUseUpdate = ::onUseUpdate;
		domFlag.onEndUse = ::onEndUse;
		
		traceStart = visuals[0].origin + (0,0,32);
		traceEnd = visuals[0].origin + (0,0,-32);
		trace = bulletTrace( traceStart, traceEnd, false, undefined );
		domFlag.baseeffectpos = trace["position"];

		// legacy spawn code support
		level.flags[index].useObj = domFlag;
		level.flags[index].adjflags = [];
		level.flags[index].nearbyspawns = [];
		
		domFlag.levelFlag = level.flags[index];
		
		level.domFlags[level.domFlags.size] = domFlag;
	}
	
	// level.bestSpawnFlag is used as a last resort when the enemy holds all flags.
	level.bestSpawnFlag = [];
	level.bestSpawnFlag[ "allies" ] = getUnownedFlagNearestStart( "allies", undefined );
	level.bestSpawnFlag[ "axis" ] = getUnownedFlagNearestStart( "axis", level.bestSpawnFlag[ "allies" ] );
	
	flagSetup();

	/#
	thread domDebug();
	#/
}

getUnownedFlagNearestStart( team, excludeFlag )
{
	best = undefined;
	bestdistsq = undefined;
	for( i = 0; i < level.flags.size; i++ )
	{
		flag = level.flags[i];
		
		if( flag getFlagTeam() != "neutral" )
			continue;
		
		distsq = distanceSquared( flag.origin, level.startPos[team] );
		if( (!isDefined( excludeFlag ) || flag != excludeFlag) && (!isdefined( best ) || distsq < bestdistsq) )
		{
			bestdistsq = distsq;
			best = flag;
		}
	}
	return best;
}

/#
domDebug()
{
	while( 1 )
	{
		if( getCvar( "scr_domdebug") != "1" ) 
		{
			wait( 2 );
			continue;
		}
		
		while( 1 )
		{
			if( getCvar( "scr_domdebug") != "1" )
				break;
				
			// show flag connections and each flag's spawnpoints
			for( i = 0; i < level.flags.size; i++ ) 
			{
				for( j = 0; j < level.flags[i].adjflags.size; j++) 
				{
					line( level.flags[i].origin, level.flags[i].adjflags[j].origin, (1,1,1) );
				}
				
				for( j = 0; j < level.flags[i].nearbyspawns.size; j++) 
				{
					line( level.flags[i].origin, level.flags[i].nearbyspawns[j].origin, (.2,.2,.6) );
				}
				
				if( level.flags[i] == level.bestSpawnFlag["allies"] )
					print3d( level.flags[i].origin, "allies best spawn flag" );
				if( level.flags[i] == level.bestSpawnFlag["axis"] )
					print3d( level.flags[i].origin, "axis best spawn flag" );
			}
			
			wait( .05 );
		}
	}
}
#/

onBeginUse( player )
{
	if( !( isDefined( self.objPoints["allies"] ) && isDefined( self.objPoints["axis"] ) ) ) return;	
	self.didStatusNotify = false;

	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
}


onUseUpdate( team, progress, change )
{
	if ( progress > 0.05 && change && !self.didStatusNotify )
	{
		ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();

		self.didStatusNotify = true;
	}
}

updateDomScores()
{
	level endon( "game_ended" );

	while( game["state"] != "intermission" )
	{
		numFlags = getTeamFlagCount( "allies" );
		if( numFlags )
		{
			teamscore = getTeamScore( "allies" );
			teamscore += 1 * numflags;
			setTeamScore( "allies", teamscore );

			level notify( "update_allhud_score" );
			maps\mp\gametypes\_globalgametypes::checkScoreLimit();
		}

		numFlags = getTeamFlagCount( "axis" );
		if( numFlags )
		{
			teamscore = getTeamScore( "axis" );
			teamscore += 1 * numflags;
			setTeamScore( "axis", teamscore );
			
			level notify( "update_allhud_score" );
			maps\mp\gametypes\_globalgametypes::checkScoreLimit();
		}
		
		wait( 5.0 );
	}
}


onEndUse( team, player, success )
{
	if( !( isDefined( self.objPoints["allies"] ) && isDefined( self.objPoints["axis"] ) ) ) return;

	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
}

resetFlagBaseEffect()
{
	if( isdefined( self.baseeffect ) )
		self.baseeffect delete();
	
	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	
	if( team != "axis" && team != "allies" )
		return;
	
	fxid = level.flagBaseFXid[ team ];

	self.baseeffect = playLoopedFx( fxid, 0.90, self.baseeffectpos );
}


onUse( player )
{
	team = player.pers["team"];
	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();
	
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_capture" + label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" + label );
	self.visuals[0] setModel( game["flagmodels"][team] );
	
	self resetFlagBaseEffect();
	
	level.useStartSpawns = false;
	
	assert( team != "neutral" );
	
	if( oldTeam == "neutral" )
	{
		otherTeam = getOtherTeam( team );
		thread printAndSoundOnEveryone( team, otherTeam, &"DOM_NEUTRAL_FLAG_CAPTURED_BY", &"DOM_NEUTRAL_FLAG_CAPTURED_BY", "ctf_touchenemy", undefined, player );
	}
	else
	{
		thread printAndSoundOnEveryone( team, oldTeam, &"DOM_ENEMY_FLAG_CAPTURED_BY", &"DOM_FRIENDLY_FLAG_CAPTURED_BY", "ctf_touchenemy", "ctf_enemy_touchenemy", player );
		
		level.bestSpawnFlag[ oldTeam ] = self.levelFlag;
	}
	
	givePlayerScore( "capture", player );
}


getTeamFlagCount( team )
{
	score = 0;
	for( i = 0; i < level.flags.size; i++) 
	{
		if( level.domFlags[i] maps\mp\gametypes\_gameobjects::getOwnerTeam() == team )
			score++;
	}	
	return score;
}

getFlagTeam()
{
	return self.useObj maps\mp\gametypes\_gameobjects::getOwnerTeam();
}

getBoundaryFlags()
{
	// get all flags which are adjacent to flags that aren't owned by the same team
	bflags = [];
	for( i = 0; i < level.flags.size; i++ )
	{
		for( j = 0; j < level.flags[i].adjflags.size; j++ )
		{
			if( level.flags[i].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() != level.flags[i].adjflags[j].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() )
			{
				bflags[bflags.size] = level.flags[i];
				break;
			}
		}
	}
	
	return bflags;
}

getBoundaryFlagSpawns( team )
{
	spawns = [];
	
	bflags = getBoundaryFlags();
	for( i = 0; i < bflags.size; i++ )
	{
		if( isdefined( team ) && bflags[i] getFlagTeam() != team )
			continue;
		
		for( j = 0; j < bflags[i].nearbyspawns.size; j++ )
			spawns[spawns.size] = bflags[i].nearbyspawns[j];
	}
	
	return spawns;
}

getSpawnsBoundingFlag( avoidflag )
{
	spawns = [];

	for( i = 0; i < level.flags.size; i++ )
	{
		flag = level.flags[i];
		if( flag == avoidflag )
			continue;
		
		isbounding = false;
		for( j = 0; j < flag.adjflags.size; j++ )
		{
			if( flag.adjflags[j] == avoidflag )
			{
				isbounding = true;
				break;
			}
		}
		
		if( !isbounding )
			continue;
		
		for( j = 0; j < flag.nearbyspawns.size; j++ )
			spawns[spawns.size] = flag.nearbyspawns[j];
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team, or that are adjacent to flags owned by the given team.
getOwnedAndBoundingFlagSpawns( team )
{
	spawns = [];

	for( i = 0; i < level.flags.size; i++ )
	{
		if( level.flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for( s = 0; s < level.flags[i].nearbyspawns.size; s++ )
				spawns[spawns.size] = level.flags[i].nearbyspawns[s];
		}
		else
		{
			for( j = 0; j < level.flags[i].adjflags.size; j++ )
			{
				if( level.flags[i].adjflags[j] getFlagTeam() == team )
				{
					// add spawns near this flag
					for( s = 0; s < level.flags[i].nearbyspawns.size; s++ )
						spawns[spawns.size] = level.flags[i].nearbyspawns[s];
					break;
				}
			}
		}
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team
getOwnedFlagSpawns( team )
{
	spawns = [];

	for( i = 0; i < level.flags.size; i++ )
	{
		if( level.flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for( s = 0; s < level.flags[i].nearbyspawns.size; s++ )
				spawns[spawns.size] = level.flags[i].nearbyspawns[s];
		}
	}
	
	return spawns;
}

flagSetup()
{
	maperrors = [];
	descriptorsByLinkname = [];

	// (find each flag_descriptor object)
	descriptors = getentarray( "flag_descriptor", "targetname" );
	
	flags = level.flags;
	
	for( i = 0; i < level.domFlags.size; i++ )
	{
		closestdist = undefined;
		closestdesc = undefined;
		for( j = 0; j < descriptors.size; j++)
		{
			dist = distance(flags[i].origin, descriptors[j].origin);
			if(!isdefined(closestdist) || dist < closestdist) 
			{
				closestdist = dist;
				closestdesc = descriptors[j];
			}
		}
		
		if( !isdefined( closestdesc ) ) 
		{
			maperrors[maperrors.size] = "there is no flag_descriptor in the map! see explanation in dom.gsc";
			break;
		}
		if( isdefined( closestdesc.flag ) ) 
		{
			maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + closestdesc.script_linkname + "\" is nearby more than one flag; is there a unique descriptor near each flag?";
			continue;
		}
		flags[i].descriptor = closestdesc;
		closestdesc.flag = flags[i];
		descriptorsByLinkname[closestdesc.script_linkname] = closestdesc;
	}
	
	if( maperrors.size == 0 )
	{
		// find adjacent flags
		for( i = 0; i < flags.size; i++ )
		{
			if( isdefined(flags[i].descriptor.script_linkto ) )
				adjdescs = strtok(flags[i].descriptor.script_linkto, " ");
			else
				adjdescs = [];
			for( j = 0; j < adjdescs.size; j++ )
			{
				otherdesc = descriptorsByLinkname[adjdescs[j]];
				if(!isdefined(otherdesc) || otherdesc.targetname != "flag_descriptor") 
				{
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to \"" + adjdescs[j] + "\" which does not exist as a script_linkname of any other entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
					continue;
				}
				adjflag = otherdesc.flag;
				if(adjflag == flags[i]) 
				{
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to itself";
					continue;
				}
				
				flags[i].adjflags[flags[i].adjflags.size] = adjflag;
			}
		}
	}
	
	// assign each spawnpoint to nearest flag
	spawnpoints = getentarray( "mp_tdm_spawn", "classname" );
	for( i = 0; i < spawnpoints.size; i++ )
	{
		if( isdefined( spawnpoints[i].script_linkto ) ) 
		{
			desc = descriptorsByLinkname[spawnpoints[i].script_linkto];
			if( !isdefined(desc) || desc.targetname != "flag_descriptor" ) 
			{
				maperrors[maperrors.size] = "Spawnpoint at " + spawnpoints[i].origin + "\" linked to \"" + spawnpoints[i].script_linkto + "\" which does not exist as a script_linkname of any entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
				continue;
			}
			nearestflag = desc.flag;
		}
		else 
		{
			nearestflag = undefined;
			nearestdist = undefined;
			for( j = 0; j < flags.size; j++ )
			{
				dist = distancesquared( flags[j].origin, spawnpoints[i].origin );
				if( !isdefined( nearestflag ) || dist < nearestdist )
				{
					nearestflag = flags[j];
					nearestdist = dist;
				}
			}
		}
		nearestflag.nearbyspawns[nearestflag.nearbyspawns.size] = spawnpoints[i];
	}
	
	if( maperrors.size > 0 )
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");
		
		maps\mp\_utility::error("Map errors. See above");
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// UTILITES ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

printAndSoundOnEveryone( team, otherteam, printFriendly, printEnemy, soundFriendly, soundEnemy, printarg )
{
	shouldDoSounds = isDefined( soundFriendly );
	
	shouldDoEnemySounds = false;
	if( isDefined( soundEnemy ) )
	{
		assert( shouldDoSounds ); // can't have an enemy sound without a friendly sound
		shouldDoEnemySounds = true;
	}
	
	players = getEntArray( "player", "classname" );
	if( shouldDoEnemySounds )
	{
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			playerteam = player.pers["team"];
			if( isdefined( playerteam ) )
			{
				if( playerteam == team )
				{
					player iprintln( printFriendly, printarg );
					player playLocalSound( soundFriendly );
				}
				else if( playerteam == otherteam )
				{
					player iprintln( printEnemy, printarg );
					player playLocalSound( soundEnemy );
				}
			}
		}
	}
	else
	{
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];
			playerteam = player.pers["team"];
			if( isdefined( playerteam ) )
			{
				if( playerteam == team )
				{
					player iprintln( printFriendly, printarg );
					player playLocalSound( soundFriendly );
				}
				else if( playerteam == otherteam )
				{
					player iprintln( printEnemy, printarg );
				}
			}
		}
	}
}

givePlayerScore( event, player, victim )
{	
	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );
	
	if( score == player.pers["score"] )
		return;
	
	player.score = player.pers["score"];
	
	player notify( "update_playerscore_hud" );
	player thread maps\mp\gametypes\_globalgametypes::checkScoreLimit();
}

onPlayerScore( event, player, victim )
{
	score = getScoreInfoValue( event );
	
	assert( isDefined( score ) );
	
	player.pers["score"] += score;
}

getScoreInfoValue( type )
{
	return( level.scoreInfo[type] );
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type] = value;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// FLAG SETUP //////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

init_domFlags()
{	
	domFlags = [];
	flagnumber = 1;
	
	filename = undefined;
	if( level.native )
		filename = "stock_domflags.ini";
	else
		filename = "custom_domflags.ini";
	
	file = OpenFile( filename, "read" );
	
	if( file == -1 )
		return( false );
	
	currentmap = false;
	for( ;; )
	{
		elems = freadln( file );
		
		if( elems == -1 )
			break;
			
		if( elems == 0 )
		{
			currentmap = false;
			continue;
		}
	
		line = "";
		for( pos = 0; pos < elems; pos++ )
		{
			line = line + fgetarg( file, pos );
			if( pos < elems - 1 )
				line = line + ",";
		}
		
		if( getSubStr( line, 0, 2 ) == "//" || getSubStr(line, 0, 1) == "#" )
			continue;
			
		array = strtok( line, " " );

		if( array[0] == getcvar( "mapname" ) )
		{
			currentmap = true;
			continue;
		}
		
		if( currentmap )
		{
			switch( array[0] )
			{
				case "flag_primary":
					origin_str = getsubstr( array[2], 1 );
					origin_array = strtok( origin_str, "," );
					origin = ( int( origin_array[0] ), int( origin_array[1] ), int( origin_array[2] ) );
					domFlags[flagnumber] =  spawn( "trigger_radius", origin, 0, 160, 126 );
					domFlags[flagnumber].origin = origin;
					domFlags[flagnumber].targetname = array[0];
					domFlags[flagnumber].script_label = array[1];
					add_descriptor( origin, "flag_descriptor", "flag" + flagnumber, getLinkto( flagnumber ) );
					flagnumber++;
					break;

				default:
					break;
			}
		}
	}
	
	CloseFile( file );
	
	if( !domFlags.size )
		return( false );
	
	return( true );
}

add_descriptor( origin, targetname, flagname, linkto )
{
	descriptor = spawn( "script_origin", origin );
	descriptor.targetname = targetname;
	descriptor.script_linkname = flagname;
	descriptor.script_linkto = linkto;
}

getLinkto( number )
{
	switch( number )
	{
		case 1:
			return "flag2 flag3";
		case 2:
			return "flag1 flag3";
		case 3:
			return "flag1 flag2";
		
		default:
			return;
	}
}


