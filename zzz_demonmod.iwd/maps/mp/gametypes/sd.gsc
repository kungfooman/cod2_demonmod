/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

// place solid triggers around the Silo model in map mp_farmhouse
setupSolidSilo()
{
	bombzones = getentarray( "bombzone", "targetname" );
	for( i = 0; i < bombzones.size; i++ )
	{
		bombzone = bombzones[i];

		if( isdefined( bombzone.script_label ) )
		{
			if( bombzone.script_label == "B" || bombzone.script_label == "b" )
		 	{
				solid = spawn( "trigger_radius", bombzone.origin+(-60,-50,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(60,-50,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(-60,70,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(60,70,-10), 0, 200, 70 );
				solid setContents( 1 );
				
				solid = spawn( "trigger_radius", bombzone.origin+(80,25,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(-80,30,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(0,-80,-10), 0, 200, 70 );
				solid setContents( 1 );

				solid = spawn( "trigger_radius", bombzone.origin+(0,80,-10), 0, 200, 70 );
				solid setContents( 1 );
				
		 	}
		}
	}
}

// delete the bombzone model and replace with a destroyed one
destroyModel()
{
	if( level.used_bombzone != "" )
	{
		if( isDefined( level.replace[ level.used_bombzone ] ) )
		{
			replaceDestroyed = spawn( "script_model", level.replace[ level.used_bombzone ].origin );
			replaceDestroyed setModel( "xmodel/static_mp_supplies_x" );
						
			level.replace[ level.used_bombzone ] playsound( "flak88_explode" );
			level.replace[ level.used_bombzone ] delete();
		}
	}
}

replaceModels()
{
	level.saved_origin = [];
	level.saved_modelType = [];
	
	// delete existing bombzone models
	entitytypes = getentarray();
	for( i = 0; i < entitytypes.size; i++ )
	{
		if( isdefined( entitytypes[i].script_gameobjectname ) )
		{
			gameobjectnames = strtok( entitytypes[i].script_gameobjectname, " " );
			
			for( k = 0; k < gameobjectnames.size; k++ )
			{
				if( gameobjectnames[k] == "bombzone" )
				{	
					if( entitytypes[i].classname == "script_model" )
					{
						level.saved_origin[level.saved_origin.size] = entitytypes[i].origin;
						entitytypes[i] delete();
					}
				}
			}

		}
	}
	
	// delete bombzone clips
	entitytypes = getentarray();
	for( i = 0; i < entitytypes.size; i++ )
	{
		if( isdefined( entitytypes[i].script_gameobjectname ) )
		{
			gameobjectnames = strtok( entitytypes[i].script_gameobjectname, " " );
			
			for( k = 0; k < gameobjectnames.size; k++ )
			{
				if( gameobjectnames[k] == "bombzone" )
				{	
					if( entitytypes[i].classname == "script_brushmodel" )
					{
						if( level.script == "mp_farmhouse" )
						{
							entitytypes[i] notSolid();
							thread setupSolidSilo();
						}
						else 
							entitytypes[i] delete();
					}
				}
			}

		}
	}
	
	level.replace = [];
	
	// spawn World at War bombzone model at target point A and make solid
	spawnpoint = FindGround( level.saved_origin[0] );
	level.replace["A"] = spawn( "script_model", spawnpoint );
	level.replace["A"] setModel( "xmodel/static_supplies_mp" );
	level.replace["A"].angles = (0,0,0);
	solid = spawn( "trigger_radius", spawnpoint, 0, 50, 80 );
	solid setContents( 1 );
	
	bombzones = getentarray( "bombzone", "targetname" );
	for( i = 0; i < bombzones.size; i++ )
	{
		bombzone = bombzones[i];
		if( isdefined( bombzone.script_label ) )
			if( bombzone.script_label == "A" || bombzone.script_label == "a" )
				bombzone.origin = level.replace["A"].origin+(0,0,55);
	}
	
	// Remove target point A from saved origin array
	level.saved_origin = remove_element_from_array( level.saved_origin, level.saved_origin[0] );

	// spawn World at War bombzone model at target point B and make solid
	if( level.script == "mp_farmhouse" )
	{
		// Move the bombzone away from the Silo in map mp_farmhouse to a new location
		level.replace["B"] = spawn( "script_model", (-2556, 950, -45) );
		level.replace["B"] setModel( "xmodel/static_supplies_mp" );
		level.replace["B"].angles = (0,0,0);
		solid = spawn( "trigger_radius", level.replace["B"].origin, 0, 50, 80 );
		solid setContents( 1 );
		
		bombzones = getentarray( "bombzone", "targetname" );
		for( i = 0; i < bombzones.size; i++ )
		{
			bombzone = bombzones[i];
			if( isdefined( bombzone.script_label ) )
				if( bombzone.script_label == "B" || bombzone.script_label == "b" )
					bombzone.origin = level.replace["B"].origin+(0,0,55);
		}
	}
	else
	{
		spawnpoint = level.saved_origin[ randomint( level.saved_origin.size ) ];
		spawn = FindGround( spawnpoint );
		level.replace["B"] = spawn( "script_model", spawn );
		level.replace["B"] setModel( "xmodel/static_supplies_mp" );
		level.replace["B"].angles = (0,0,0);
		solid = spawn( "trigger_radius", spawn, 0, 50, 70 );
		solid setContents( 1 );
		
		bombzones = getentarray( "bombzone", "targetname" );
		for( i = 0; i < bombzones.size; i++ )
		{
			bombzone = bombzones[i];
			if( isdefined( bombzone.script_label ) )
				if( bombzone.script_label == "B" || bombzone.script_label == "b" )
					bombzone.origin = level.replace["B"].origin+(0,0,55);
		}
	}
}

FindGround( position )
{
	trace = bulletTrace( position+(0,0,10), position+(0,0,-10000), false, undefined );
	ground = trace["position"];
	return ground;
}

main()
{	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "sd", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "sd", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "sd", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "sd", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "sd", 1, 0, 99 );

	// Sets the time it takes for a planted bomb to explode
	if(getCvar("scr_sd_bombtimer") == "")
		setCvar("scr_sd_bombtimer", "60");
	else if(getCvarInt("scr_sd_bombtimer") > 120)
		setCvar("scr_sd_bombtimer", "120");
	else if(getCvarInt("scr_sd_bombtimer") < 30)
		setCvar("scr_sd_bombtimer", "30");
	level.bombtimer = getCvarInt("scr_sd_bombtimer");

	level.onPrecacheGametype = ::onPrecacheGametype;
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPlayerDisconnect = ::onPlayerDisconnect;
	level.onEndRound = ::onEndRound;
	
}

onPrecacheGametype()
{
	if( !isdefined( game["gamestarted"] ) )
	{
		precacheRumble("damage_heavy");
		precacheShader("white");
		precacheShader("plantbomb");
		precacheShader("defusebomb");
		precacheShader("objective");
		precacheShader("objectiveA");
		precacheShader("objectiveB");
		precacheShader("bombplanted");
		precacheShader("objpoint_bomb");
		precacheShader("objpoint_A");
		precacheShader("objpoint_B");
		precacheShader("objpoint_star");
		precacheShader("hudStopwatch");
		precacheShader("hudstopwatchneedle");
		precacheString(&"MP_MATCHSTARTING");
		precacheString(&"MP_MATCHRESUMING");
		precacheString(&"MP_EXPLOSIVESPLANTED");
		precacheString(&"MP_EXPLOSIVESDEFUSED");
		precacheString(&"MP_ROUNDDRAW");
		precacheString(&"MP_TIMEHASEXPIRED");
		precacheString(&"MP_ALLIEDMISSIONACCOMPLISHED");
		precacheString(&"MP_AXISMISSIONACCOMPLISHED");
		precacheString(&"MP_ALLIESHAVEBEENELIMINATED");
		precacheString(&"MP_AXISHAVEBEENELIMINATED");
		precacheString(&"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");
		precacheString(&"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");
		precacheModel("xmodel/mp_tntbomb");
		precacheModel("xmodel/mp_tntbomb_obj");
		
		precacheModel( "xmodel/static_supplies_mp" );
		precacheModel( "xmodel/static_mp_supplies_x" );
	}
}

onPlayerDisconnect()
{
	if( game["matchstarted"] )
		level thread [[level.updateTeamStatus]]();
}

onGametypeStarted()
{	
	spawnpointname = "mp_sd_spawn_attacker";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpointname = "mp_sd_spawn_defender";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] PlaceSpawnpoint();

	level._effect["bombexplosion"] = loadfx("fx/props/barrelexp.efx");

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);

	// Auto Team Balancing
	level.lockteams = false;
	level.used_bombzone = "";

	replaceModels();
	thread bombzones();
}

onPlayerSpawned()
{
	if( self.pers["team"] == "allies" )
		spawnpointname = "mp_sd_spawn_attacker";
	else
		spawnpointname = "mp_sd_spawn_defender";

	spawnpoints = getentarray( spawnpointname, "classname" );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnpoints );

	if( isdefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );

	if( level.bombplanted )
		thread showPlayerBombTimer();

	if( level.scorelimit > 0 )
	{
		if( self.pers["team"] == game["attackers"] )
			self setClientCvar("cg_objectiveText", &"MP_OBJ_ATTACKERS", level.scorelimit );
		else if( self.pers["team"] == game["defenders"])
			self setClientCvar( "cg_objectiveText", &"MP_OBJ_DEFENDERS", level.scorelimit );
	}
	else
	{
		if( self.pers["team"] == game["attackers"] )
			self setClientCvar( "cg_objectiveText", &"MP_OBJ_ATTACKERS_NOSCORE" );
		else if(self.pers["team"] == game["defenders"])
			self setClientCvar( "cg_objectiveText", &"MP_OBJ_DEFENDERS_NOSCORE" );
	}
}

onEndRound()
{
	players = getEntArray( "player", "classname" );
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if( isdefined( player.progressbackground ) )
			player.progressbackground destroy();

		if( isdefined( player.progressbar ) )
			player.progressbar destroy();

		player unlink();
		player enableWeapon();
	}

	objective_delete( 0 );
	objective_delete( 1 );
}

bombzones()
{
	maperrors = [];

	level.barsize = 192;
	level.planttime = 5;		// seconds to plant a bomb
	level.defusetime = 10;		// seconds to defuse a bomb

	wait .2;

	bombzones = getentarray("bombzone", "targetname");
	array = [];

	if(level.bombmode == 0)
	{
		for(i = 0; i < bombzones.size; i++)
		{
			bombzone = bombzones[i];

			if(isdefined(bombzone.script_bombmode_original) && isdefined(bombzone.script_label))
				array[array.size] = bombzone;
		}

		if(array.size == 2)
		{
			bombzone0 = array[0];
			bombzone1 = array[1];
			bombzoneA = undefined;
			bombzoneB = undefined;

			if(bombzone0.script_label == "A" || bombzone0.script_label == "a")
		 	{
		 		bombzoneA = bombzone0;
		 		bombzoneB = bombzone1;
		 	}
		 	else if(bombzone0.script_label == "B" || bombzone0.script_label == "b")
		 	{
		 		bombzoneA = bombzone1;
		 		bombzoneB = bombzone0;
		 	}
		 	else
		 		maperrors[maperrors.size] = "^1Bombmode original: Bombzone found with an invalid \"script_label\", must be \"A\" or \"B\"";

	 		objective_add(0, "current", bombzoneA.origin, "objectiveA");
	 		objective_add(1, "current", bombzoneB.origin, "objectiveB");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneA.origin, "0", "allies", "objpoint_A");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneB.origin, "1", "allies", "objpoint_B");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneA.origin, "0", "axis", "objpoint_A");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneB.origin, "1", "axis", "objpoint_B");

	 		bombzoneA thread bombzone_think( bombzoneB );
			bombzoneB thread bombzone_think( bombzoneA );
		}
		else if( array.size < 2 )
			maperrors[maperrors.size] = "^1Bombmode original: Less than 2 bombzones found with \"script_bombmode_original\" \"1\"";
		else if( array.size > 2 )
			maperrors[maperrors.size] = "^1Bombmode original: More than 2 bombzones found with \"script_bombmode_original\" \"1\"";
	}
	else if( level.bombmode == 1 )
	{
		for( i = 0; i < bombzones.size; i++ )
		{
			bombzone = bombzones[i];

			if( isdefined( bombzone.script_bombmode_single ) )
				array[array.size] = bombzone;
		}

		if(array.size == 1)
		{
	 		objective_add(0, "current", array[0].origin, "objective");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(array[0].origin, "single", "allies", "objpoint_star");
			thread maps\mp\gametypes\_objpoints::addTeamObjpoint(array[0].origin, "single", "axis", "objpoint_star");

	 		array[0] thread bombzone_think();
		}
		else if(array.size < 1)
			maperrors[maperrors.size] = "^1Bombmode single: Less than 1 bombzone found with \"script_bombmode_single\" \"1\"";
		else if(array.size > 1)
			maperrors[maperrors.size] = "^1Bombmode single: More than 1 bombzone found with \"script_bombmode_single\" \"1\"";
	}
	else if( level.bombmode == 2 )
	{
		for(i = 0; i < bombzones.size; i++)
		{
			bombzone = bombzones[i];

			if(isdefined(bombzone.script_bombmode_dual))
		 		array[array.size] = bombzone;
		}

		if(array.size == 2)
		{
	 		bombzone0 = array[0];
	 		bombzone1 = array[1];

	 		objective_add(0, "current", bombzone0.origin, "objective");
	 		objective_add(1, "current", bombzone1.origin, "objective");

	 		if(isdefined(bombzone0.script_team) && isdefined(bombzone1.script_team))
	 		{
	 			if((bombzone0.script_team == "allies" && bombzone1.script_team == "axis") || (bombzone0.script_team == "axis" || bombzone1.script_team == "allies"))
	 			{
	 				objective_team(0, bombzone0.script_team);
	 				objective_team(1, bombzone1.script_team);

					if(bombzone0.script_team == "allies")
					{
						thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzone0.origin, "0", "allies", "objpoint_star");
						thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzone1.origin, "1", "axis", "objpoint_star");
					}
					else
					{
						thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzone0.origin, "0", "axis", "objpoint_star");
						thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzone1.origin, "1", "allies", "objpoint_star");
					}
	 			}
	 			else
	 				maperrors[maperrors.size] = "^1Bombmode dual: One or more bombzones missing \"script_team\" \"allies\" or \"axis\"";
	 		}

	 		bombzone0 thread bombzone_think(bombzone1);
	 		bombzone1 thread bombzone_think(bombzone0);
		}
		else if(array.size < 2)
			maperrors[maperrors.size] = "^1Bombmode dual: Less than 2 bombzones found with \"script_bombmode_dual\" \"1\"";
		else if(array.size > 2)
			maperrors[maperrors.size] = "^1Bombmode dual: More than 2 bombzones found with \"script_bombmode_dual\" \"1\"";
	}
	else
		println("^6Unknown bomb mode");

	bombtriggers = getentarray("bombtrigger", "targetname");
	if(bombtriggers.size < 1)
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"bombtrigger\"";
	else if(bombtriggers.size > 1)
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"bombtrigger\"";

	if(maperrors.size)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		return;
	}

	bombtrigger = getent("bombtrigger", "targetname");
	bombtrigger maps\mp\_utility::triggerOff();

	// Kill unused bombzones and associated script_exploders

	accepted = [];
	for(i = 0; i < array.size; i++)
	{
		if(isdefined(array[i].script_noteworthy))
			accepted[accepted.size] = array[i].script_noteworthy;
	}

	remove = [];
	bombzones = getentarray("bombzone", "targetname");
	for(i = 0; i < bombzones.size; i++)
	{
		bombzone = bombzones[i];

		if(isdefined(bombzone.script_noteworthy))
		{
			addtolist = true;
			for(j = 0; j < accepted.size; j++)
			{
				if(bombzone.script_noteworthy == accepted[j])
				{
					addtolist = false;
					break;
				}
			}

			if(addtolist)
				remove[remove.size] = bombzone.script_noteworthy;
		}
	}

	ents = getentarray();
	for(i = 0; i < ents.size; i++)
	{
		ent = ents[i];

		if(isdefined(ent.script_exploder))
		{
			kill = false;
			for(j = 0; j < remove.size; j++)
			{
				if(ent.script_exploder == int(remove[j]))
				{
					kill = true;
					break;
				}
			}

			if(kill)
				ent delete();
		}
	}
}

bombzone_think(bombzone_other)
{
	level endon("round_ended");

	level.barincrement = (level.barsize / (20.0 * level.planttime));

	self setteamfortrigger(game["attackers"]);
	self setHintString(&"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");

	for( ;; )
	{
		self waittill( "trigger", other );

		if(isdefined(bombzone_other) && isdefined(bombzone_other.planting))
			continue;

		if(level.bombmode == 2 && isdefined(self.script_team))
			team = self.script_team;
		else
			team = game["attackers"];

		if(isPlayer(other) && (other.pers["team"] == team) && other isOnGround())
		{
			while(other istouching(self) && isAlive(other) && other useButtonPressed())
			{
				other notify("kill_check_bombzone");

				self.planting = true;
				other clientclaimtrigger(self);
				other clientclaimtrigger(bombzone_other);

				if(!isdefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);
					other.progressbackground.x = 0;

					if(level.splitscreen)
						other.progressbackground.y = 70;
					else
						other.progressbackground.y = 104;

					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.horzAlign = "center_safearea";
					other.progressbackground.vertAlign = "center_safearea";
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);

				if(!isdefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);
					other.progressbar.x = int(level.barsize / (-2.0));

					if(level.splitscreen)
						other.progressbar.y = 70;
					else
						other.progressbar.y = 104;

					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.horzAlign = "center_safearea";
					other.progressbar.vertAlign = "center_safearea";
				}
				other.progressbar setShader("white", 0, 8);
				other.progressbar scaleOverTime(level.planttime, level.barsize, 8);

				other playsound("MP_bomb_plant");
				other linkTo(self);
				other disableWeapon();

				self.progresstime = 0;
				while(isAlive(other) && other useButtonPressed() && (self.progresstime < level.planttime))
				{
					self.progresstime += 0.05;
					wait 0.05;
				}

				// TODO: script error if player is disconnected/kicked here
				other clientreleasetrigger(self);
				other clientreleasetrigger(bombzone_other);

				if(self.progresstime >= level.planttime)
				{
					other.progressbackground destroy();
					other.progressbar destroy();
					other enableWeapon();

					if( isdefined( self.target ) )
					{
						exploder = getent( self.target, "targetname" );

						if(isdefined(exploder) && isdefined(exploder.script_exploder))
							level.bombexploder = exploder.script_exploder;
					}
					
					if( isDefined( self.script_label ) )
						level.used_bombzone = self.script_label;

					bombzones = getentarray("bombzone", "targetname");
					for(i = 0; i < bombzones.size; i++)
						bombzones[i] delete();

					if( level.bombmode == 1 )
					{
						objective_delete(0);
						thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
						thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					}
					else
					{
						objective_delete(0);
						objective_delete(1);
						thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
						thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					}

					plant = other maps\mp\_utility::getPlant();

					level.bombmodel = spawn("script_model", plant.origin);
					level.bombmodel.angles = plant.angles;
					level.bombmodel setmodel("xmodel/mp_tntbomb");
					level.bombmodel playSound("Explo_plant_no_tick");
					level.bombglow = spawn("script_model", plant.origin);
					level.bombglow.angles = plant.angles;
					level.bombglow setmodel("xmodel/mp_tntbomb_obj");

					bombtrigger = getent("bombtrigger", "targetname");
					bombtrigger.origin = level.bombmodel.origin;

					objective_add(0, "current", bombtrigger.origin, "objective");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombtrigger.origin, "bomb", "allies", "objpoint_star");
					thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombtrigger.origin, "bomb", "axis", "objpoint_star");

					level.bombplanted = true;
					level.bombtimerstart = gettime();
					level.planting_team = other.pers["team"];

					lpselfnum = other getEntityNumber();
					lpselfguid = other getGuid();
					logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + other.pers["team"] + ";" + other.name + ";" + "bomb_plant" + "\n");

					iprintln(&"MP_EXPLOSIVESPLANTED");
					level thread soundPlanted(other);

					bombtrigger thread bomb_think();
					bombtrigger thread bomb_countdown();

					level notify("bomb_planted");
					level.clock destroy();

					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					if(isdefined(other.progressbackground))
						other.progressbackground destroy();

					if(isdefined(other.progressbar))
						other.progressbar destroy();

					other unlink();
					other enableWeapon();
				}

				wait .05;
			}

			self.planting = undefined;
			other thread check_bombzone(self);
		}
	}
}

check_bombzone(trigger)
{
	self notify("kill_check_bombzone");
	self endon("kill_check_bombzone");
	level endon("round_ended");

	while(isdefined(trigger) && !isdefined(trigger.planting) && self istouching(trigger) && isAlive(self))
		wait 0.05;
}

bomb_countdown()
{
	self endon("bomb_defused");
	level endon("intermission");

	thread showBombTimers();
	level.bombmodel playLoopSound("bomb_tick");

	wait level.bombtimer;

	// bomb timer is up
	objective_delete(0);
	thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
	thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
	thread deleteBombTimers();

	level.bombexploded = true;
	self notify("bomb_exploded");

	thread destroyModel();

	// trigger exploder if it exists
	if(isdefined(level.bombexploder))
		maps\mp\_utility::exploder(level.bombexploder);

	// explode bomb
	origin = self getorigin();
	range = 500;
	maxdamage = 2000;
	mindamage = 1000;

	self delete(); // delete the defuse trigger
	level.bombmodel stopLoopSound();
	level.bombmodel delete();
	level.bombglow delete();

	playfx(level._effect["bombexplosion"], origin);
	radiusDamage(origin, range, maxdamage, mindamage);

	level thread [[level.onPlaySoundOnPlayers]]("mp_announcer_objdest");
	level thread [[level.endRound]]( level.planting_team );
}

bomb_think()
{
	self endon("bomb_exploded");
	level.barincrement = (level.barsize / (20.0 * level.defusetime));

	self setteamfortrigger(game["defenders"]);
	self setHintString(&"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");

	for(;;)
	{
		self waittill("trigger", other);

		// check for having been triggered by a valid player
		if(isPlayer(other) && (other.pers["team"] != level.planting_team) && other isOnGround())
		{
			while(isAlive(other) && other useButtonPressed())
			{
				other notify("kill_check_bomb");

				other clientclaimtrigger(self);

				if(!isdefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);
					other.progressbackground.x = 0;

					if(level.splitscreen)
						other.progressbackground.y = 70;
					else
						other.progressbackground.y = 104;

					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.horzAlign= "center_safearea";
					other.progressbackground.vertAlign = "center_safearea";
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);

				if(!isdefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);
					other.progressbar.x = int(level.barsize / (-2.0));

					if(level.splitscreen)
						other.progressbar.y = 70;
					else
						other.progressbar.y = 104;

					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.horzAlign = "center_safearea";
					other.progressbar.vertAlign = "center_safearea";
				}
				other.progressbar setShader("white", 0, 8);
				other.progressbar scaleOverTime(level.defusetime, level.barsize, 8);

				other playsound("MP_bomb_defuse");
				other linkTo(self);
				other disableWeapon();

				self.progresstime = 0;
				while(isAlive(other) && other useButtonPressed() && (self.progresstime < level.defusetime))
				{
					self.progresstime += 0.05;
					wait 0.05;
				}

				other clientreleasetrigger(self);

				if(self.progresstime >= level.defusetime)
				{
					other.progressbackground destroy();
					other.progressbar destroy();

					objective_delete(0);
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					thread deleteBombTimers();

					self notify("bomb_defused");
					level.bombmodel stopLoopSound();
					level.bombglow delete();
					self delete();
					
					level.used_bombzone = "";

					iprintln(&"MP_EXPLOSIVESDEFUSED");
					level thread [[level.onPlaySoundOnPlayers]]("MP_announcer_bomb_defused");

					lpselfnum = other getEntityNumber();
					lpselfguid = other getGuid();
					logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + other.pers["team"] + ";" + other.name + ";" + "bomb_defuse" + "\n");

					level thread [[level.endRound]]( other.pers["team"] );
					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					if(isdefined(other.progressbackground))
						other.progressbackground destroy();

					if(isdefined(other.progressbar))
						other.progressbar destroy();

					other unlink();
					other enableWeapon();
				}

				wait .05;
			}

			self.defusing = undefined;
			other thread check_bomb(self);
		}
	}
}

check_bomb(trigger)
{
	self notify("kill_check_bomb");
	self endon("kill_check_bomb");

	while(isdefined(trigger) && !isdefined(trigger.defusing) && self istouching(trigger) && isAlive(self))
		wait 0.05;
}

showBombTimers()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isdefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
			player showPlayerBombTimer();
	}
}

showPlayerBombTimer()
{
	timeleft = (level.bombtimer - (getTime() - level.bombtimerstart) / 1000);

	if(timeleft > 0)
	{
		self.bombtimer = newClientHudElem(self);
		self.bombtimer.x = 6;
		self.bombtimer.y = 76;
		self.bombtimer.horzAlign = "left";
		self.bombtimer.vertAlign = "top";
		self.bombtimer setClock(timeleft, level.bombtimer, "hudStopwatch", 48, 48);
	}
}

deleteBombTimers()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] deletePlayerBombTimer();
}

deletePlayerBombTimer()
{
	if(isdefined(self.bombtimer))
		self.bombtimer destroy();
}

soundPlanted(player)
{
	if(game["allies"] == "british")
		alliedsound = "UK_mp_explosivesplanted";
	else if(game["allies"] == "russian")
		alliedsound = "RU_mp_explosivesplanted";
	else
		alliedsound = "US_mp_explosivesplanted";

	axissound = "GE_mp_explosivesplanted";

	if(level.splitscreen)
	{
		if(player.pers["team"] == "allies")
			player playLocalSound(alliedsound);
		else if(player.pers["team"] == "axis")
			player playLocalSound(axissound);

		return;
	}
	else
	{
		level [[level.onPlaySoundOnPlayers]](alliedsound, "allies");
		level [[level.onPlaySoundOnPlayers]](axissound, "axis");

		wait 1.5;

		if(level.planting_team == "allies")
		{
			if(game["allies"] == "british")
				alliedsound = "UK_mp_defendbomb";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_defendbomb";
			else
				alliedsound = "US_mp_defendbomb";

			level [[level.onPlaySoundOnPlayers]](alliedsound, "allies");
			level [[level.onPlaySoundOnPlayers]]("GE_mp_defusebomb", "axis");
		}
		else if(level.planting_team == "axis")
		{
			if(game["allies"] == "british")
				alliedsound = "UK_mp_defusebomb";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_defusebomb";
			else
				alliedsound = "US_mp_defusebomb";

			level [[level.onPlaySoundOnPlayers]](alliedsound, "allies");
			level [[level.onPlaySoundOnPlayers]]("GE_mp_defendbomb", "axis");
		}
	}
}