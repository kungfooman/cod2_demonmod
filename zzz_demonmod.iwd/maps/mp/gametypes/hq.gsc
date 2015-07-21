/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

main()
{	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "hq", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "hq", 300, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "hq", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "hq", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "hq", 0, 0, 99 );

	level.onPrecacheGametype = ::onPrecacheGametype;
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onRespawnPlayer = ::onRespawnPlayer;
	level.updateTimer = ::updateTimer;
}

onPrecacheGametype()
{
	game["radio_prespawn"][0] = "objectiveA";
	game["radio_prespawn"][1] = "objectiveB";
	game["radio_prespawn"][2] = "objective_hq";
	game["radio_prespawn_objpoint"][0] = "objpoint_A";
	game["radio_prespawn_objpoint"][1] = "objpoint_B";
	game["radio_prespawn_objpoint"][2] = "objpoint_star";
	game["radio_none"] = "objective";
	game["radio_axis"] = "objective_" + game["axis"];
	game["radio_allies"] = "objective_" + game["allies"];

	//custom radio colors for different nationalities
	if(game["allies"] == "american")
		game["radio_model"] = "xmodel/military_german_fieldradio_green_nonsolid";
	else if(game["allies"] == "british")
		game["radio_model"] = "xmodel/military_german_fieldradio_tan_nonsolid";
	else if(game["allies"] == "russian")
		game["radio_model"] = "xmodel/military_german_fieldradio_grey_nonsolid";
	assert(isdefined(game["radio_model"]));

	precacheShader("white");
	precacheShader("objective_hq");
	precacheShader("objectiveA");
	precacheShader("objectiveB");
	precacheShader("objective");
	precacheShader("objpoint_A");
	precacheShader("objpoint_B");
	precacheShader("objpoint_radio");
	precacheShader("field_radio");
	precacheShader(game["radio_allies"]);
	precacheShader(game["radio_axis"]);

	precacheModel(game["radio_model"]);
	precacheString(&"MP_TIME_TILL_SPAWN");
	precacheString(&"MP_ESTABLISHING_HQ");
	precacheString(&"MP_DESTROYING_HQ");
	precacheString(&"MP_LOSING_HQ");
	precacheString(&"MP_MAXHOLDTIME_MINUTESANDSECONDS");
	precacheString(&"MP_MAXHOLDTIME_MINUTES");
	precacheString(&"MP_MAXHOLDTIME_SECONDS");
	precacheString(&"MP_UPTEAM");
	precacheString(&"MP_DOWNTEAM");
	precacheString(&"MP_RESPAWN_WHEN_RADIO_NEUTRALIZED");
	precacheString(&"MP_MATCHSTARTING");
	precacheString(&"MP_MATCHRESUMING");
	precacheString(&"PLATFORM_PRESS_TO_SPAWN");
}

onGametypeStarted()
{
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	level._effect["radioexplosion"] = loadfx("fx/explosions/grenadeExp_blacktop.efx");

	allowed[0] = "tdm";
	maps\mp\gametypes\_gameobjects::main( allowed );

	level.team["allies"] = 0;
	level.team["axis"] = 0;

	level.zradioradius = 72; // Z Distance players must be from a radio to capture/neutralize it
	level.captured_radios["allies"] = 0;
	level.captured_radios["axis"] = 0;

	level.progressBarHeight = 12;
	level.progressBarWidth = 192;

	level.RadioSpawnDelay = demon\_utils::CvarDef( "scr_hq_radio_spawndelay", 45, 0, 999, "int" );
	level.radioradius = 120;
	level.respawngracetime = 5;
	level.RadioMaxHoldSeconds = demon\_utils::CvarDef( "scr_hq_radio_holdtime", 120, 0, 999, "int" );
	level.timesCaptured = 0;
	level.nextradio = 0;
	level.spawnframe = 0;
	level.DefendingRadioTeam = "none";
	level.NeutralizingPoints = 10;
	level.MultipleCaptureBias = 1;
	level.respawndelay = demon\_utils::CvarDef( "scr_hq_respawndelay", 10, 0, 999, "int" );

	hq_setup();
	thread hq_points();
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	level hq_removeall_hudelems( self );

	defendingBeforeDeath = true;
	if( isdefined( self.pers["team"] ) && level.DefendingRadioTeam != self.pers["team"] )
		defendingBeforeDeath = false;

	defendingAfterDeath = false;
	if( isdefined( self.pers["team"] ) && level.DefendingRadioTeam == self.pers["team"] )
		defendingAfterDeath = true;

	allowInstantRespawn = false;
	if( !defendingBeforeDeath && defendingAfterDeath )
		allowInstantRespawn = true;

	//check if it was the last person to die on the defending team
	level updateTeamStatus();
	if( isdefined( self.pers["team"] ) && level.DefendingRadioTeam == self.pers["team"] && level.exist[self.pers["team"]] <= 0 )
	{
		allowInstantRespawn = true;
		for( i = 0; i < level.radio.size; i++ )
		{
			if( level.radio[i].hidden == true )
				continue;
			level hq_radio_capture( level.radio[i], "none" );
			break;
		}
	}

	if( level.roundStarted && !allowInstantRespawn )
	{
		self thread respawn_timer( 2 );
		self thread respawn_staydead( 2 );
	}
}

onPlayerSpawned()
{
	spawnpointname = "mp_tdm_spawn";
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam_AwayfromRadios( spawnpoints );

	if( isdefined( spawnpoint ) )
		self spawn(spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );

	if( level.scorelimit > 0 )
		self setClientCvar( "cg_objectiveText", &"MP_OBJ_TEXT", level.scorelimit );
	else
		self setClientCvar( "cg_objectiveText", &"MP_OBJ_TEXT_NOSCORE" );

	self thread updateTimer();
}

onRespawnPlayer()
{
	self.sessionteam = self.pers["team"];
	self.sessionstate = "spectator";

	if( isdefined(self.dead_origin) && isdefined( self.dead_angles ) )
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
		
	while( isdefined( self.WaitingOnTimer ) || ((self.pers["team"] == level.DefendingRadioTeam) && isdefined( self.WaitingOnNeutralize ) ) )
		wait .05;
}

hq_setup()
{
	wait 0.05;

	maperrors = [];

	if(!isdefined(level.radio))
		level.radio = getentarray("hqradio", "targetname");

	if(level.radio.size < 3)
		maperrors[maperrors.size] = "^1Less than 3 entities found with \"targetname\" \"hqradio\"";

	if(maperrors.size)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		return;
	}

	setTeamScore("allies", 0);
	setTeamScore("axis", 0);

	for(i = 0; i < level.radio.size; i++)
	{
		level.radio[i] setmodel(game["radio_model"]);
		level.radio[i].team = "none";
		level.radio[i].holdtime_allies = 0;
		level.radio[i].holdtime_axis = 0;
		level.radio[i].hidden = true;
		level.radio[i] hide();

		if((!isdefined(level.radio[i].script_radius)) || (level.radio[i].script_radius <= 0))
			level.radio[i].radius = level.radioradius;
		else
			level.radio[i].radius = level.radio[i].script_radius;

		level thread hq_radio_think(level.radio[i]);
	}

	hq_randomize_radioarray();

	level thread hq_obj_think();
}

hq_randomize_radioarray()
{
	for(i = 0; i < level.radio.size; i++)
	{
		rand = randomint(level.radio.size);
    	temp = level.radio[i];
    	level.radio[i] = level.radio[rand];
    	level.radio[rand] = temp;
	}
}

hq_obj_think(radio)
{
	NeutralRadios = 0;
	for(i = 0; i < level.radio.size; i++)
	{
		if(level.radio[i].hidden == true)
			continue;
		NeutralRadios++;
	}
	if(NeutralRadios <= 0)
	{
		if(level.nextradio > level.radio.size - 1)
		{
			hq_randomize_radioarray();
			level.nextradio = 0;

			if(isdefined(radio))
			{
				// same radio twice in a row so go to the next radio
				if(radio == level.radio[level.nextradio])
					level.nextradio++;
			}
		}

		//find a fake radio position that isn't the last position or the next position
		randAorB = undefined;
		if(level.radio.size >= 4)
		{
			fakeposition = level.radio[randomint(level.radio.size)];
			if(isdefined(level.radio[(level.nextradio - 1)]))
			{
				while((fakeposition == level.radio[level.nextradio]) || (fakeposition == level.radio[level.nextradio - 1]))
					fakeposition = level.radio[randomint(level.radio.size)];
			}
			else
			{
				while(fakeposition == level.radio[level.nextradio])
					fakeposition = level.radio[randomint(level.radio.size)];
			}
			randAorB = randomint(2);
			objective_add(1, "current", fakeposition.origin, game["radio_prespawn"][randAorB]);
			thread maps\mp\gametypes\_objpoints::addObjpoint( fakeposition.origin, "1", game["radio_prespawn_objpoint"][randAorB] );
		}
		if(!isdefined(randAorB))
			otherAorB = 2; //use original icon since there is only one objective that will show
		else if(randAorB == 1)
			otherAorB = 0;
		else
			otherAorB = 1;
		objective_add(0, "current", level.radio[level.nextradio].origin, game["radio_prespawn"][otherAorB]);
		thread maps\mp\gametypes\_objpoints::addObjpoint( level.radio[level.nextradio].origin, "0", game["radio_prespawn_objpoint"][otherAorB] );

		if( !level.roundBased )
		{
			level hq_check_teams_exist();
			restartRound = false;
			while( (!level.alliesexist) || (!level.axisexist) )
			{
				restartRound = true;
				wait 2;
				level hq_check_teams_exist();
			}
			
			if( restartRound )
				restartRound();
				
			level.roundStarted = true;
		}

		iprintln( &"MP_RADIOS_SPAWN_IN_SECONDS", level.RadioSpawnDelay );
		wait( level.RadioSpawnDelay );

		level.radio[level.nextradio] show();
		level.radio[level.nextradio].hidden = false;

		level thread [[level.onPlaySoundOnPlayers]]( "explo_plant_no_tick" );
		objective_icon(0, game["radio_none"]);
		objective_delete(1);
		thread maps\mp\gametypes\_objpoints::removeObjpoints();
		thread maps\mp\gametypes\_objpoints::addObjpoint( level.radio[level.nextradio].origin, "0", "objpoint_radio" );

		if((level.captured_radios["allies"] <= 0) && (level.captured_radios["axis"] > 0)) // AXIS HAVE A RADIO AND ALLIES DONT
			objective_team(0, "allies");
		else if((level.captured_radios["allies"] > 0) && (level.captured_radios["axis"] <= 0)) // ALLIES HAVE A RADIO AND AXIS DONT
			objective_team(0, "axis");
		else // NO TEAMS HAVE A RADIO
			objective_team(0, "none");

		level.nextradio++;
	}
}

hq_radio_think( radio )
{
	level endon( "intermission" );

	while( HQinProgress() )
	{
		wait 0.05;
		if( !radio.hidden )
		{
			players = getentarray( "player", "classname" );
			radio.allies = 0;
			radio.axis = 0;
			for(i = 0; i < players.size; i++)
			{
				if(isdefined(players[i].pers["team"]) && players[i].pers["team"] != "spectator" && players[i].sessionstate == "playing")
				{
					if(((distance(players[i].origin,radio.origin)) <= radio.radius) && (distance((0,0,players[i].origin[2]),(0,0,radio.origin[2])) <= level.zradioradius))
					{
						if(players[i].pers["team"] == radio.team)
							continue;

						if((level.captured_radios[players[i].pers["team"]] > 0) && (radio.team == "none"))
							continue;

						if((!isdefined(players[i].radioicon)) || (!isdefined(players[i].radioicon[0])))
						{
							players[i].radioicon[0] = newClientHudElem(players[i]);
							players[i].radioicon[0].x = 30;
							players[i].radioicon[0].y = 95;
							players[i].radioicon[0].alignX = "center";
							players[i].radioicon[0].alignY = "middle";
							players[i].radioicon[0].horzAlign = "left";
							players[i].radioicon[0].vertAlign = "top";
							players[i].radioicon[0] setShader("field_radio", 40, 32);
						}

						if((level.captured_radios[players[i].pers["team"]] <= 0) && (radio.team == "none"))
						{
							if(!isdefined(players[i].progressbar_capture))
							{
								players[i].progressbar_capture = newClientHudElem(players[i]);
								players[i].progressbar_capture.x = 0;

								if(level.splitscreen)
									players[i].progressbar_capture.y = 70;
								else
									players[i].progressbar_capture.y = 104;

								players[i].progressbar_capture.alignX = "center";
								players[i].progressbar_capture.alignY = "middle";
								players[i].progressbar_capture.horzAlign = "center_safearea";
								players[i].progressbar_capture.vertAlign = "center_safearea";
								players[i].progressbar_capture.alpha = 0.5;
							}
							players[i].progressbar_capture setShader("black", level.progressBarWidth, level.progressBarHeight);
							if(!isdefined(players[i].progressbar_capture2))
							{
								players[i].progressbar_capture2 = newClientHudElem(players[i]);
								players[i].progressbar_capture2.x = ((level.progressBarWidth / (-2)) + 2);

								if(level.splitscreen)
									players[i].progressbar_capture2.y = 70;
								else
									players[i].progressbar_capture2.y = 104;

								players[i].progressbar_capture2.alignX = "left";
								players[i].progressbar_capture2.alignY = "middle";
								players[i].progressbar_capture2.horzAlign = "center_safearea";
								players[i].progressbar_capture2.vertAlign = "center_safearea";
							}
							if(players[i].pers["team"] == "allies")
								players[i].progressbar_capture2 setShader("white", radio.holdtime_allies, level.progressBarHeight - 4);
							else
								players[i].progressbar_capture2 setShader("white", radio.holdtime_axis, level.progressBarHeight - 4);

							if(!isdefined(players[i].progressbar_capture3))
							{
								players[i].progressbar_capture3 = newClientHudElem(players[i]);
								players[i].progressbar_capture3.x = 0;

								if(level.splitscreen)
									players[i].progressbar_capture3.y = 16;
								else
									players[i].progressbar_capture3.y = 50;

								players[i].progressbar_capture3.alignX = "center";
								players[i].progressbar_capture3.alignY = "middle";
								players[i].progressbar_capture3.horzAlign = "center_safearea";
								players[i].progressbar_capture3.vertAlign = "center_safearea";
								players[i].progressbar_capture3.archived = false;
								players[i].progressbar_capture3.font = "default";
								players[i].progressbar_capture3.fontscale = 2;
								players[i].progressbar_capture3 settext(&"MP_ESTABLISHING_HQ");
							}
						}
						else if(radio.team != "none")
						{
							if(!isdefined(players[i].progressbar_capture))
							{
								players[i].progressbar_capture = newClientHudElem(players[i]);
								players[i].progressbar_capture.x = 0;

								if(level.splitscreen)
									players[i].progressbar_capture.y = 70;
								else
									players[i].progressbar_capture.y = 104;

								players[i].progressbar_capture.alignX = "center";
								players[i].progressbar_capture.alignY = "middle";
								players[i].progressbar_capture.horzAlign = "center_safearea";
								players[i].progressbar_capture.vertAlign = "center_safearea";
								players[i].progressbar_capture.alpha = 0.5;
							}
							players[i].progressbar_capture setShader("black", level.progressBarWidth, level.progressBarHeight);

							if(!isdefined(players[i].progressbar_capture2))
							{
								players[i].progressbar_capture2 = newClientHudElem(players[i]);
								players[i].progressbar_capture2.x = ((level.progressBarWidth / (-2)) + 2);

								if(level.splitscreen)
									players[i].progressbar_capture2.y = 70;
								else
									players[i].progressbar_capture2.y = 104;

								players[i].progressbar_capture2.alignX = "left";
								players[i].progressbar_capture2.alignY = "middle";
								players[i].progressbar_capture2.horzAlign = "center_safearea";
								players[i].progressbar_capture2.vertAlign = "center_safearea";
							}
							if(players[i].pers["team"] == "allies")
								players[i].progressbar_capture2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
							else
								players[i].progressbar_capture2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

							if(!isdefined(players[i].progressbar_capture3))
							{
								players[i].progressbar_capture3 = newClientHudElem(players[i]);
								players[i].progressbar_capture3.x = 0;

								if(level.splitscreen)
									players[i].progressbar_capture3.y = 16;
								else
									players[i].progressbar_capture3.y = 50;

								players[i].progressbar_capture3.alignX = "center";
								players[i].progressbar_capture3.alignY = "middle";
								players[i].progressbar_capture3.horzAlign = "center_safearea";
								players[i].progressbar_capture3.vertAlign = "center_safearea";
								players[i].progressbar_capture3.archived = false;
								players[i].progressbar_capture3.font = "default";
								players[i].progressbar_capture3.fontscale = 2;
								players[i].progressbar_capture3 settext(&"MP_DESTROYING_HQ");
							}

							if(radio.team == "allies")
							{
								if(!isdefined(level.progressbar_axis_neutralize))
								{
									level.progressbar_axis_neutralize = newTeamHudElem("allies");
									level.progressbar_axis_neutralize.x = 0;

									if(level.splitscreen)
										level.progressbar_axis_neutralize.y = 70;
									else
										level.progressbar_axis_neutralize.y = 104;

									level.progressbar_axis_neutralize.alignX = "center";
									level.progressbar_axis_neutralize.alignY = "middle";
									level.progressbar_axis_neutralize.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize.alpha = 0.5;
								}
								level.progressbar_axis_neutralize setShader("black", level.progressBarWidth, level.progressBarHeight);

								if(!isdefined(level.progressbar_axis_neutralize2))
								{
									level.progressbar_axis_neutralize2 = newTeamHudElem("allies");
									level.progressbar_axis_neutralize2.x = ((level.progressBarWidth / (-2)) + 2);

									if(level.splitscreen)
										level.progressbar_axis_neutralize2.y = 70;
									else
										level.progressbar_axis_neutralize2.y = 104;

									level.progressbar_axis_neutralize2.alignX = "left";
									level.progressbar_axis_neutralize2.alignY = "middle";
									level.progressbar_axis_neutralize2.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize2.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize2.color = (.8,0,0);
								}
								if(players[i].pers["team"] == "allies")
									level.progressbar_axis_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
								else
									level.progressbar_axis_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

								if(!isdefined(level.progressbar_axis_neutralize3))
								{
									level.progressbar_axis_neutralize3 = newTeamHudElem("allies");
									level.progressbar_axis_neutralize3.x = 0;

									if(level.splitscreen)
										level.progressbar_axis_neutralize3.y = 16;
									else
										level.progressbar_axis_neutralize3.y = 50;

									level.progressbar_axis_neutralize3.alignX = "center";
									level.progressbar_axis_neutralize3.alignY = "middle";
									level.progressbar_axis_neutralize3.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize3.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize3.archived = false;
									level.progressbar_axis_neutralize3.font = "default";
									level.progressbar_axis_neutralize3.fontscale = 2;
									level.progressbar_axis_neutralize3 settext(&"MP_LOSING_HQ");
								}
							}
							else
							if(radio.team == "axis")
							{
								if(!isdefined(level.progressbar_allies_neutralize))
								{
									level.progressbar_allies_neutralize = newTeamHudElem("axis");
									level.progressbar_allies_neutralize.x = 0;

									if(level.splitscreen)
										level.progressbar_allies_neutralize.y = 70;
									else
										level.progressbar_allies_neutralize.y = 104;

									level.progressbar_allies_neutralize.alignX = "center";
									level.progressbar_allies_neutralize.alignY = "middle";
									level.progressbar_allies_neutralize.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize.alpha = 0.5;
								}
								level.progressbar_allies_neutralize setShader("black", level.progressBarWidth, level.progressBarHeight);

								if(!isdefined(level.progressbar_allies_neutralize2))
								{
									level.progressbar_allies_neutralize2 = newTeamHudElem("axis");
									level.progressbar_allies_neutralize2.x = ((level.progressBarWidth / (-2)) + 2);

									if(level.splitscreen)
										level.progressbar_allies_neutralize2.y = 70;
									else
										level.progressbar_allies_neutralize2.y = 104;

									level.progressbar_allies_neutralize2.alignX = "left";
									level.progressbar_allies_neutralize2.alignY = "middle";
									level.progressbar_allies_neutralize2.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize2.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize2.color = (.8,0,0);
								}
								if(players[i].pers["team"] == "allies")
									level.progressbar_allies_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
								else
									level.progressbar_allies_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

								if(!isdefined(level.progressbar_allies_neutralize3))
								{
									level.progressbar_allies_neutralize3 = newTeamHudElem("axis");
									level.progressbar_allies_neutralize3.x = 0;

									if(level.splitscreen)
										level.progressbar_allies_neutralize3.y = 16;
									else
										level.progressbar_allies_neutralize3.y = 50;

									level.progressbar_allies_neutralize3.alignX = "center";
									level.progressbar_allies_neutralize3.alignY = "middle";
									level.progressbar_allies_neutralize3.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize3.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize3.archived = false;
									level.progressbar_allies_neutralize3.font = "default";
									level.progressbar_allies_neutralize3.fontscale = 2;
									level.progressbar_allies_neutralize3 settext(&"MP_LOSING_HQ");
								}
							}
						}

						if(players[i].pers["team"] == "allies")
							radio.allies++;
						else
							radio.axis++;

						players[i].inrange = true;
					}
					else if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
					{
						if((isdefined(players[i].radioicon)) || (isdefined(players[i].radioicon[0])))
							players[i].radioicon[0] destroy();
						if(isdefined(players[i].progressbar_capture))
							players[i].progressbar_capture destroy();
						if(isdefined(players[i].progressbar_capture2))
							players[i].progressbar_capture2 destroy();
						if(isdefined(players[i].progressbar_capture3))
							players[i].progressbar_capture3 destroy();

						players[i].inrange = undefined;
					}
				}
			}

			if(radio.team == "none") // Radio is captured if no enemies around
			{
				if((radio.allies > 0) && (radio.axis <= 0) && (radio.team != "allies"))
				{
					radio.holdtime_allies = int(.667 + (radio.holdtime_allies + (radio.allies * level.MultipleCaptureBias)));

					if(radio.holdtime_allies >= (level.progressBarWidth - 4))
					{
						if((level.captured_radios["allies"] > 0) && (radio.team != "none"))
							level hq_radio_capture(radio, "none");
						else if(level.captured_radios["allies"] <= 0)
							level hq_radio_capture(radio, "allies");
					}
				}
				else if((radio.axis > 0) && (radio.allies <= 0) && (radio.team != "axis"))
				{
					radio.holdtime_axis = int(.667 + (radio.holdtime_axis + (radio.axis * level.MultipleCaptureBias)));

					if(radio.holdtime_axis >= (level.progressBarWidth - 4))
					{
						if((level.captured_radios["axis"] > 0) && (radio.team != "none"))
							level hq_radio_capture(radio, "none");
						else if(level.captured_radios["axis"] <= 0)
							level hq_radio_capture(radio, "axis");
					}
				}
				else
				{
					radio.holdtime_allies = 0;
					radio.holdtime_axis = 0;

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						if(isdefined(players[i].pers["team"]) && players[i].pers["team"] != "spectator" && players[i].sessionstate == "playing")
						{
							if(((distance(players[i].origin,radio.origin)) <= radio.radius) && (distance((0,0,players[i].origin[2]),(0,0,radio.origin[2])) <= level.zradioradius))
							{
								if(isdefined(players[i].progressbar_capture))
									players[i].progressbar_capture destroy();
								if(isdefined(players[i].progressbar_capture2))
									players[i].progressbar_capture2 destroy();
								if(isdefined(players[i].progressbar_capture3))
									players[i].progressbar_capture3 destroy();
							}
						}
					}
				}
			}
			else // Radio should go to neutral first
			{
				if((radio.team == "allies") && (radio.axis <= 0))
				{
					if(isdefined(level.progressbar_axis_neutralize))
						level.progressbar_axis_neutralize destroy();
					if(isdefined(level.progressbar_axis_neutralize2))
						level.progressbar_axis_neutralize2 destroy();
					if(isdefined(level.progressbar_axis_neutralize3))
						level.progressbar_axis_neutralize3 destroy();
				}
				else if((radio.team == "axis") && (radio.allies <= 0))
				{
					if(isdefined(level.progressbar_allies_neutralize))
						level.progressbar_allies_neutralize destroy();
					if(isdefined(level.progressbar_allies_neutralize2))
						level.progressbar_allies_neutralize2 destroy();
					if(isdefined(level.progressbar_allies_neutralize3))
						level.progressbar_allies_neutralize3 destroy();
				}

				if((radio.allies > 0) && (radio.team == "axis"))
				{
					radio.holdtime_allies = int(.667 + (radio.holdtime_allies + (radio.allies * level.MultipleCaptureBias)));
					if(radio.holdtime_allies >= (level.progressBarWidth - 4))
						level hq_radio_capture(radio, "none");
				}
				else if((radio.axis > 0) && (radio.team == "allies"))
				{
					radio.holdtime_axis = int(.667 + (radio.holdtime_axis + (radio.axis * level.MultipleCaptureBias)));
					if(radio.holdtime_axis >= (level.progressBarWidth - 4))
						level hq_radio_capture(radio, "none");
				}
				else
				{
					radio.holdtime_allies = 0;
					radio.holdtime_axis = 0;
				}
			}
		}
	}
}

hq_radio_capture( radio, team )
{
	radio.holdtime_allies = 0;
	radio.holdtime_axis = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] != "spectator" && players[i].sessionstate == "playing")
		{
			if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			{
				players[i].radioicon[0] destroy();
				if(isdefined(players[i].progressbar_capture))
					players[i].progressbar_capture destroy();
				if(isdefined(players[i].progressbar_capture2))
					players[i].progressbar_capture2 destroy();
				if(isdefined(players[i].progressbar_capture3))
					players[i].progressbar_capture3 destroy();
			}
		}
	}

	if( radio.team != "none" )
	{
		level.captured_radios[radio.team] = 0;
		playfx(level._effect["radioexplosion"], radio.origin);
		level.timesCaptured = 0;
		// Print some text
		if( radio.team == "allies" )
		{
			if(getTeamCount("axis") && !level.splitscreen)
				iprintln(&"MP_SHUTDOWN_ALLIED_HQ");

			if(isdefined(level.progressbar_axis_neutralize))
				level.progressbar_axis_neutralize destroy();
			if(isdefined(level.progressbar_axis_neutralize2))
				level.progressbar_axis_neutralize2 destroy();
			if(isdefined(level.progressbar_axis_neutralize3))
				level.progressbar_axis_neutralize3 destroy();
		}
		else if(radio.team == "axis")
		{
			if(getTeamCount("allies") && !level.splitscreen)
				iprintln(&"MP_SHUTDOWN_AXIS_HQ");

			if(isdefined(level.progressbar_allies_neutralize))
				level.progressbar_allies_neutralize destroy();
			if(isdefined(level.progressbar_allies_neutralize2))
				level.progressbar_allies_neutralize2 destroy();
			if(isdefined(level.progressbar_allies_neutralize3))
				level.progressbar_allies_neutralize3 destroy();
		}
	}

	if(radio.team == "none")
		radio playsound("explo_plant_no_tick");

	NeutralizingTeam = undefined;
	if(radio.team == "allies")
		NeutralizingTeam = "axis";
	else if(radio.team == "axis")
		NeutralizingTeam = "allies";
	radio.team = team;

	level notify("Radio State Changed");

	if(team == "none")
	{
		// RADIO GOES NEUTRAL
		radio setmodel(game["radio_model"]);
		radio hide();
		radio.hidden = true;

		radio playsound("explo_radio");
		if(isdefined(NeutralizingTeam))
		{
			if(NeutralizingTeam == "allies")
				level thread [[level.onPlaySoundOnPlayers]]("mp_announcer_axishqdest");
			else if(NeutralizingTeam == "axis")
				level thread [[level.onPlaySoundOnPlayers]]("mp_announcer_alliedhqdest");
		}

		objective_delete(0);
		thread maps\mp\gametypes\_objpoints::removeObjpoints();
		level.DefendingRadioTeam = "none";
		level notify("Radio Neutralized");

		//give some points to the neutralizing team
		if( isdefined( NeutralizingTeam ) )
		{
			if((NeutralizingTeam == "allies") || (NeutralizingTeam == "axis"))
			{
				if(getTeamCount(NeutralizingTeam))
				{
					setTeamScore(NeutralizingTeam, getTeamScore(NeutralizingTeam) + level.NeutralizingPoints);
					level notify( "update_allhud_score" );

					if( !level.splitscreen )
					{
						if( NeutralizingTeam == "allies" )
							iprintln(&"MP_SCORED_ALLIES", level.NeutralizingPoints);
						else
							iprintln(&"MP_SCORED_AXIS", level.NeutralizingPoints);
					}
				}
			}
		}

		//give all the alive players that are alive full health
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].sessionstate == "playing")
			{
				players[i].maxhealth = 100;
				players[i].health = players[i].maxhealth;
			}
		}

		level thread hq_removhudelem_allplayers( radio );
	}
	else
	{
		// RADIO CAPTURED BY A TEAM
		level.captured_radios[team] = 1;
		level.DefendingRadioTeam = team;

		if(team == "allies")
		{
			if(!level.splitscreen)
				iprintln(&"MP_SETUP_HQ_ALLIED");

			if(game["allies"] == "british")
				alliedsound = "UK_mp_hqsetup";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_hqsetup";
			else
				alliedsound = "US_mp_hqsetup";

			level thread [[level.onPlaySoundOnPlayers]](alliedsound, "allies");
			if(!level.splitscreen)
				level thread [[level.onPlaySoundOnPlayers]]("GE_mp_enemyhqsetup", "axis");
		}
		else
		{
			if(!level.splitscreen)
				iprintln(&"MP_SETUP_HQ_AXIS");

			if(game["allies"] == "british")
				alliedsound = "UK_mp_enemyhqsetup";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_enemyhqsetup";
			else
				alliedsound = "US_mp_enemyhqsetup";

			level thread [[level.onPlaySoundOnPlayers]]("GE_mp_hqsetup", "axis");
			if(!level.splitscreen)
				level thread [[level.onPlaySoundOnPlayers]](alliedsound, "allies");
		}

		//give all the alive players that are now defending the radio full health
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == level.DefendingRadioTeam && players[i].sessionstate == "playing")
			{
				players[i].maxhealth = 100;
				players[i].health = players[i].maxhealth;
			}
		}

		level thread hq_maxholdtime_think();
	}

	objective_icon(0, (game["radio_" + team ]));
	objective_team(0, "none");

	objteam = "none";
	if((level.captured_radios["allies"] <= 0) && (level.captured_radios["axis"] > 0))
		objteam = "allies";
	else if((level.captured_radios["allies"] > 0) && (level.captured_radios["axis"] <= 0))
		objteam = "axis";

	// Make all neutral radio objectives go to the right team
	for(i = 0; i < level.radio.size; i++)
	{
		if(level.radio[i].hidden == true)
			continue;
		if(level.radio[i].team == "none")
			objective_team(0, objteam);
	}

	level notify("finish_staydead");

	level thread hq_obj_think(radio);
}

hq_maxholdtime_think()
{
	level endon( "Radio State Changed" );
	assert( level.RadioMaxHoldSeconds > 2 );
	if( level.RadioMaxHoldSeconds > 0 )
		wait( level.RadioMaxHoldSeconds - 0.05 );
	level thread hq_radio_resetall();
}

hq_points()
{
	while( HQinProgress() )
	{
		if( level.DefendingRadioTeam != "none" )
		{
			if( getTeamCount( level.DefendingRadioTeam ) )
			{
				setTeamScore( level.DefendingRadioTeam, getTeamScore( level.DefendingRadioTeam ) + 1 );
				level notify( "update_allhud_score" );
				maps\mp\gametypes\_globalgametypes::checkScoreLimit(); 
			}
		}
		
		wait 1;
	}
}

HQinProgress()
{
	if( level.roundBased && level.roundended )
		return false;
	
	if( !level.roundBased && level.mapended )
		return false;
	
	return true;
}

hq_radio_resetall()
{
	// Find the radio that is in play
	radio = undefined;
	for( i = 0; i < level.radio.size; i++ )
	{
		if(level.radio[i].hidden == false)
			radio = level.radio[i];
	}

	if(!isdefined(radio))
		return;

	radio.holdtime_allies = 0;
	radio.holdtime_axis = 0;

	players = getentarray( "player", "classname" );
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] != "spectator" && players[i].sessionstate == "playing")
		{
			if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			{
				players[i].radioicon[0] destroy();
				if(isdefined(players[i].progressbar_capture))
					players[i].progressbar_capture destroy();
				if(isdefined(players[i].progressbar_capture2))
					players[i].progressbar_capture2 destroy();
				if(isdefined(players[i].progressbar_capture3))
					players[i].progressbar_capture3 destroy();
			}
		}
	}

	if(radio.team != "none")
	{
		level.captured_radios[radio.team] = 0;

		playfx(level._effect["radioexplosion"], radio.origin);
		level.timesCaptured = 0;

		localizedTeam = undefined;
		if(radio.team == "allies")
		{
			localizedTeam = (&"MP_UPTEAM");
			if(isdefined(level.progressbar_axis_neutralize))
				level.progressbar_axis_neutralize destroy();
			if(isdefined(level.progressbar_axis_neutralize2))
				level.progressbar_axis_neutralize2 destroy();
			if(isdefined(level.progressbar_axis_neutralize3))
				level.progressbar_axis_neutralize3 destroy();
		}
		else if(radio.team == "axis")
		{
			localizedTeam = (&"MP_DOWNTEAM");
			if(isdefined(level.progressbar_allies_neutralize))
				level.progressbar_allies_neutralize destroy();
			if(isdefined(level.progressbar_allies_neutralize2))
				level.progressbar_allies_neutralize2 destroy();
			if(isdefined(level.progressbar_allies_neutralize3))
				level.progressbar_allies_neutralize3 destroy();
		}

		minutes = 0;
		maxTime = level.RadioMaxHoldSeconds;
		while(maxTime >= 60)
		{
			minutes++;
			maxTime -= 60;
		}
		seconds = maxTime;
		if((minutes > 0) && (seconds > 0))
			iprintlnbold(&"MP_MAXHOLDTIME_MINUTESANDSECONDS", localizedTeam, minutes, seconds);
		else
		if((minutes > 0) && (seconds <= 0))
			iprintlnbold(&"MP_MAXHOLDTIME_MINUTES", localizedTeam);
		else
		if((minutes <= 0) && (seconds > 0))
			iprintlnbold(&"MP_MAXHOLDTIME_SECONDS", localizedTeam, seconds);
	}

	radio.team = "none";
	level.DefendingRadioTeam = "none";
	objective_team(0, "none");

	radio setmodel(game["radio_model"]);
	radio hide();

	if( HQinProgress() )
	{
		radio playsound("explo_radio");
		level thread [[level.onPlaySoundOnPlayers]]("mp_announcer_hqdefended");
	}

	radio.hidden = true;
	objective_delete(0);
	thread maps\mp\gametypes\_objpoints::removeObjpoints();

	level.graceperiod = false;
	level thread hq_obj_think(radio);
	level thread hq_removhudelem_allplayers(radio);

	// All dead people should now respawn
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
	}

	level notify("finish_staydead");
}

hq_removeall_hudelems(player)
{
	if(isdefined(self))
	{
		for(i = 0; i < level.radio.size; i++)
		{
			if((isdefined(player.radioicon)) && (isdefined(player.radioicon[0])))
				player.radioicon[0] destroy();
			if(isdefined(player.progressbar_capture))
				player.progressbar_capture destroy();
			if(isdefined(player.progressbar_capture2))
				player.progressbar_capture2 destroy();
			if(isdefined(player.progressbar_capture3))
				player.progressbar_capture3 destroy();
		}
	}
}

hq_removhudelem_allplayers( radio )
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i]))
			continue;
		if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			players[i].radioicon[0] destroy();
		if(isdefined(players[i].progressbar_capture))
			players[i].progressbar_capture destroy();
		if(isdefined(players[i].progressbar_capture2))
			players[i].progressbar_capture2 destroy();
		if(isdefined(players[i].progressbar_capture3))
			players[i].progressbar_capture3 destroy();
	}
}

hq_check_teams_exist()
{
	players = getentarray("player", "classname");
	level.alliesexist = false;
	level.axisexist = false;
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i].pers["team"]) || players[i].pers["team"] == "spectator")
			continue;
		if(players[i].pers["team"] == "allies")
			level.alliesexist = true;
		else if(players[i].pers["team"] == "axis")
			level.axisexist = true;

		if( level.alliesexist && level.axisexist )
			return;
	}
}

waittill_any( string1, string2 )
{
	self endon( "death" );
	ent = spawnstruct();

	if( isdefined( string1 ) )
		self thread waittill_string( string1, ent );

	if( isdefined( string2 ) )
		self thread waittill_string( string2, ent );

	ent waittill( "returned" );
	ent notify( "die" );
}

waittill_string( msg, ent )
{
	self endon( "death" );
	ent endon( "die" );
	
	self waittill( msg );
	
	ent notify( "returned" );
}

updateTeamStatus()
{
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;

	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] != "spectator" && players[i].sessionstate == "playing" )
			level.exist[players[i].pers["team"]]++;
	}
}

restartRound()
{
	if( level.roundStarted )
	{
		iprintlnBold( &"MP_MATCHRESUMING" );
		return;
	}
	else
	{
		iprintlnBold( &"MP_MATCHSTARTING" );
		wait 5;
	}

	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( isdefined(player.pers["team"]) && ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) )
		{
		    player.score = 0;
		    player.deaths = 0;
			
			player notify( "death" );
			player maps\mp\gametypes\_globalgametypes::spawnPlayer();
		}
	}
}

respawn_timer( delay )
{
	self endon( "disconnect" );

	self.WaitingOnTimer = true;

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
			self.respawntimer.label = ( &"MP_TIME_TILL_SPAWN" );
			self.respawntimer setTimer( level.respawndelay + delay );
		}

		wait delay;
		self thread updateTimer();

		wait level.respawndelay;

		if( isdefined( self.respawntimer ) )
			self.respawntimer destroy();
	}

	self.WaitingOnTimer = undefined;
}

respawn_staydead( delay )
{
	self endon( "disconnect" );

	if( isdefined( self.WaitingOnNeutralize ) )
		return;
	self.WaitingOnNeutralize = true;

	if( !isdefined( self.staydead ) )
	{
		self.staydead = newClientHudElem( self );
		self.staydead.x = 0;
		self.staydead.y = -50;
		self.staydead.alignX = "center";
		self.staydead.alignY = "middle";
		self.staydead.horzAlign = "center_safearea";
		self.staydead.vertAlign = "center_safearea";
		self.staydead.alpha = 0;
		self.staydead.archived = false;
		self.staydead.font = "default";
		self.staydead.fontscale = 2;
		self.staydead setText( &"MP_RESPAWN_WHEN_RADIO_NEUTRALIZED" );
	}

	self thread delayUpdateTimer( delay );
	level waittill( "finish_staydead" );

	if( isdefined( self.staydead ) )
		self.staydead destroy();

	if( isdefined( self.respawntimer ) )
		self.respawntimer destroy();

	self.WaitingOnNeutralize = undefined;
}

delayUpdateTimer( delay )
{
	self endon( "disconnect" );

	wait delay;
	thread updateTimer();
}

updateTimer()
{
	if( isdefined( self.pers["team"] ) && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) && isdefined( self.pers["weapon"] ) )
	{
		if( isdefined( self.pers["team"] ) && self.pers["team"] == level.DefendingRadioTeam )
		{
			if( isdefined( self.respawntimer ) )
				self.respawntimer.alpha = 0;

			if( isdefined( self.staydead ) )
				self.staydead.alpha = 1;
		}
		else
		{
			if( isdefined( self.respawntimer ) )
				self.respawntimer.alpha = 1;

			if( isdefined( self.staydead ) )
				self.staydead.alpha = 0;
		}
	}
	else
	{
		if( isdefined( self.respawntimer ) )
			self.respawntimer.alpha = 0;

		if( isdefined( self.staydead ) )
			self.staydead.alpha = 0;
	}
}

getTeamCount( team )
{
	count = 0;

	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( isdefined( player.pers["team"] ) && player.pers["team"] == team )
			count++;
	}

	return count;
}
