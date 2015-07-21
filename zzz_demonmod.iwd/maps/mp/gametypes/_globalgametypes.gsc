/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

SetUpCallBacks()
{
	
	level.onPrecacheGametype = ::blank;
	level.onGametypeStarted = ::blank;
	level.onPlayerSpawned = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;
	level.onRespawnPlayer = ::blank;
	level.onPlayerJoinedTeam = ::blank;
	level.onPlayerJoinedSpectator = ::blank;
	
	level.updateTimer = ::blank;
	level.onEndRound = ::blank;
	level.class = maps\mp\gametypes\_class::menuClass;
	level.autoassign = ::menuAutoAssign;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
	level.spectator = ::menuSpectator;
	level.weapon = ::menuWeapon;
	level.checkRoundLimit = ::checkRoundLimit;
	level.onRoundOutcome = ::onRoundOutcome;
	level.endgameconfirmed = ::endMap;
	level.onPlaySoundOnPlayers = ::onPlaySoundOnPlayers;
	level.startRound = ::startRound;
	level.checkMatchStart = ::checkMatchStart;
	level.updateTeamStatus = ::updateTeamStatus;
	level.endRound	= ::endRound;
	level.createFlagWaypoint = ::createFlagWaypoint;
	level.deleteFlagWaypoint = ::deleteFlagWaypoint;
	
	setUpVariables();
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{

}

Callback_StartGameType()
{
	level.splitscreen = isSplitScreen();
	
	if( !isdefined( game["state"] ) )
		game["state"] = "playing";

	// defaults if not defined in level script
	if( !isDefined( game["allies"] ) )
		game["allies"] = "american";
	if( !isDefined( game["axis"] ) )
		game["axis"] = "german";

	// server cvar overrides
	if( getCvar( "scr_allies" ) != "" )
		game["allies"] = getCvar( "scr_allies" );
	if( getCvar( "scr_axis" ) != "" )
		game["axis"] = getCvar( "scr_axis" );
	
	// Force respawning
	if( getCvar( "scr_forcerespawn") == "" )
		setCvar( "scr_forcerespawn", "0" );

	level.limbotime = Cvardef( "scr_download_checker_time", 20, 0, 120, "int" );
	
	//******************** GLOBAL PRECACHE *****************************
	
	//--- Precache the player class models ---
	maps\mp\gametypes\_player_classmodels::onPrecachePlayerModels();
	
	switch( game["allies"] ) 
	{
		case "american":
			game["allies_flag"] = "gfx/custom/flagge_american.tga";
			game["draw_flag"] = "flag_draw_us";
			game["allies_victory_music"] = "us_victory";
			game["hudicon_allies"] = "hudicon_american";
			break;
			
		case "british":
			game["allies_flag"] = "gfx/custom/flagge_british.tga";
			game["draw_flag"] = "flag_draw_brit";
			game["allies_victory_music"] = "uk_victory";
			game["hudicon_allies"] = "hudicon_british";
			break;
			
		case "russian":
			game["allies_flag"] = "gfx/custom/flagge_russian.tga";
			game["draw_flag"] = "flag_draw_rus";
			game["allies_victory_music"] = "ru_victory";
			game["hudicon_allies"] = "hudicon_russian";
			break;
	}
	
	// GERMAN TEAM SHADERS
	{
		game["axis_flag"] = "gfx/custom/flagge_german.tga";
		game["axis_victory_music"] = "ge_victory";
		game["hudicon_axis"] = "hudicon_german";
	}
	
	// UNIVERSAL SHADERS
	game["deathicon"] = "headicon_dead";
	
	precacheRumble( "damage_heavy" );
	
	///// SHADERS PRECACHE //////

	demonPrecacheStatusIcon( "hud_status_connecting" );
	demonPrecacheStatusIcon( "hud_status_dead" );
	
	demonPrecacheShader( game["draw_flag"] );
	demonPrecacheShader( "gfx/custom/flagge_german.tga" );
	demonPrecacheShader( "gfx/custom/flagge_" + game["allies"] + ".tga" );
	demonPrecacheShader( "waypoint_bombsquad" );
	demonPrecacheShader( "waypoint_airstrike" );
	demonPrecacheShader( "waypoint_artillery" );
	demonPrecacheShader( "waypoint_extraammo" );
	demonPrecacheShader( "waypoint_extradeaths" );
	demonPrecacheShader( "health_cross" );
	demonPrecacheShader( "hud_notify_airstrike" );
	demonPrecacheShader( "hud_notify_artillery" );
	demonPrecacheShader( "hud_notify_carepackage" );
	demonPrecacheShader( game["hudicon_allies"] );
	demonPrecacheShader( game["hudicon_axis"] );
	demonPrecacheShader( game["deathicon"] );
	demonPrecacheShader( "bloodsplatter" );
	demonPrecacheShader( "bloodsplatter2" );
	demonPrecacheShader( "bloodsplatter3" );
	
	///// STRINGS ///////
	game["strings"] = [];
	game["strings"]["outcome_draw"] = &"DEMON_VICTORY_DRAW";
	game["strings"]["outcome_allies"] = &"DEMON_VICTORY_ALLIES";
	game["strings"]["outcome_axis"] = &"DEMON_VICTORY_AXIS";
	game["strings"]["class_assault"] = &"DEMON_CLASS_ASSAULT";
	game["strings"]["class_engineer"] = &"DEMON_CLASS_ENGINEER";
	game["strings"]["class_sniper"] = &"DEMON_CLASS_SNIPER";
	game["strings"]["class_medic"] = &"DEMON_CLASS_MEDIC";
	game["strings"]["class_officer"] = &"DEMON_CLASS_OFFICER";
	game["strings"]["class_gunner"] = &"DEMON_CLASS_GUNNER";
	game["strings"]["capping_carepackage"] = &"HARDPOINTS_CAPPING_CAREPACKAGE";
	
	demonPrecacheString( game["strings"]["outcome_allies"] );
	demonPrecacheString( game["strings"]["outcome_axis"] );
	demonPrecacheString( game["strings"]["outcome_draw"] );
	demonPrecacheString( game["strings"]["class_assault"] );
	demonPrecacheString( game["strings"]["class_engineer"] );
	demonPrecacheString( game["strings"]["class_sniper"] );
	demonPrecacheString( game["strings"]["class_medic"] );
	demonPrecacheString( game["strings"]["class_officer"] );
	demonPrecacheString( game["strings"]["class_gunner"] );
	demonPrecacheString( game["strings"]["capping_carepackage"] );
	demonPrecacheString( &"PLATFORM_PRESS_TO_SPAWN" );
	demonPrecacheString( &"MP_SLASH" );
	
	//******************* FINISH GLOBAL PRECACHE ****************************
	
	//--------- Precache Specific Gametype Stuff ----------
	[[level.onPrecacheGametype]]();
	
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_class_limits::init();
	thread maps\mp\gametypes\_class::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();		
	thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_friendicons::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_grenadeindicators::init();
	thread maps\mp\gametypes\_entityheadicons::init();
	thread maps\mp\gametypes\_teamstatus::Show_TeamStatus();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_hud_util::init_define();
	thread maps\mp\gametypes\_dev::init();

	if( level.teamBased )
		thread maps\mp\gametypes\_hud_teamscore::init();
	else
		thread maps\mp\gametypes\_hud_playerscore::init();
	
	game["gamestarted"] = true;
	
	level.xenon = ( getcvar("xenonGame") == "true" );
	
	setClientNameMode( "auto_change" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );

	level.roundstarted = false;
	level.roundended = false;
	level.mapended = false;
	level.gameEnded = false;
		
	[[level.onGametypeStarted]]();
	[[level.demon_onGametypeStarted]]();
	
	level.graceperiod = cvardef( "scr_graceperiod", 15, 0, 60, "float" );	
	level.inGracePeriod = true;
	
	level.useStartSpawns = true;
	
	if( !isdefined( game["timepassed"] ) )
		game["timepassed"] = 0;
	
	// Created a new flag to deal with round reset
	if( !isdefined( game["reset"] ) )
		game["reset"] = undefined;
		
	if( !level.roundBased )
		level.roundlimit = 0;

	if( !isdefined( game["alliedscore"] ) )
		game["alliedscore"] = 0;
	if( !isdefined( game["axisscore"] ) )
		game["axisscore"] = 0;

	if( level.roundBased )
	{
		setTeamScore( "allies", game["alliedscore"] );
		setTeamScore( "axis", game["axisscore"] );
	}

	level.team["allies"] = 0;
	level.team["axis"] = 0;
	level.bombplanted = false;
	level.bombexploded = false;
	level.bombmode = 0;
	level.planting_team = undefined;

	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	level.exist["teams"] = false;
	level.didexist["allies"] = false;
	level.didexist["axis"] = false;

	thread gracePeriod();
	thread startGame();
	thread updateGametypeCvars();
}

dummy()
{
	waittillframeend;

	if( isdefined( self ) )
		level notify( "connecting", self );
}

Callback_PlayerConnect()
{
	thread dummy();

	if( !level.rank ) self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	self.statusicon = "";

	level notify( "connected", self );
	
	self [[level.onPlayerConnect]]();
	self [[level.demon_onPlayerConnect]]();
	
	if( !level.hardcore )
		iprintln( &"MP_CONNECTED", self );
	
	level.players[level.players.size] = self;

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	if( game["state"] == "intermission" )
	{
		spawnIntermission();
		return;
	}

	level endon( "intermission" );
	
	if( !demon\_bots::IsBot( self ) )
		self maps\mp\gametypes\_downloadchecker::startChecker();

	scriptMainMenu = game["menu_ingame"];

	if( isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" )
	{
		self setClientCvar( "ui_allow_weaponchange", "1" );
		self setClientCvar( "ui_allow_classchange", "1" );

		if( self.pers["team"] == "allies" )
			self.sessionteam = "allies";
		else
			self.sessionteam = "axis";

		if( isDefined( self.pers["weapon"] ) )
			spawnPlayer();
		else
		{
			spawnSpectator();

			self openMenu( game[ "menu_class_"+ self.pers["team"] ] );
			scriptMainMenu = game["menu_class_"+ self.pers["team"] ];
		}
	}
	else
	{
		self setClientCvar( "ui_allow_weaponchange", "0" );
		self setClientCvar( "ui_allow_classchange", "0" );

		self openMenu( game["menu_team"] );

		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";

		spawnSpectator();
	}

	self setClientCvar( "g_scriptMainMenu", scriptMainMenu );

}


Callback_PlayerDisconnect()
{
	iprintln( &"MP_DISCONNECTED", self );
	
	self [[level.onPlayerDisconnect]]();
	self [[level.demon_onPlayerDisconnect]]();
	
	self removePlayerOnDisconnect();

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
}

removePlayerOnDisconnect()
{
	level.players = remove_element_from_array( level.players, self );
}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if( self.sessionteam == "spectator" )
		return;
	
	//--- Spawn Protection ---	
	if( self.spawnprotected )
		return;
	
	// specialty checks - bulletdamage and armorvest
	iDamage = maps\mp\gametypes\_class::modified_damage( self, eAttacker, iDamage, sMeansOfDeath );

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = undefined;
	
	self thread [[level.onPlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	self thread [[level.demon_onPlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	// check for completely getting out of the damage
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		if( level.teamBased && isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]) )
		{
			if( level.friendlyfire == "0" )
			{
				return;
			}
			else if( level.friendlyfire == "1" )
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
				self playrumble("damage_heavy");
			}
			else if( level.friendlyfire == "2" )
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
				eAttacker.friendlydamage = undefined;

				friendly = true;
			}
			else if( level.friendlyfire == "3" )
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker.friendlydamage = undefined;

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
				self playrumble("damage_heavy");

				friendly = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if( iDamage < 1 )
				iDamage = 1;

			self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

			// Shellshock/Rumble
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
			self playrumble("damage_heavy");
		}

		if( isdefined( eAttacker ) && eAttacker != self )
		{
			hasBodyArmor = false;
			if( self hasPerk( "specialty_armorvest" ) )
			{
				hasBodyArmor = true;
			}
			if( iDamage > 0 )
				eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
		}

	}
	
	if ( isdefined( eAttacker ) && eAttacker != self && !isDefined( friendly ) )
		level.useStartSpawns = false;

	// Do debug print if it's enabled
	if( getCvarInt( "g_debugDamage" ) )
	{
		println("client:" + self getEntityNumber() + " health:" + self.health +
			" damage:" + iDamage + " hitLoc:" + sHitLoc);
	}

	if( self.sessionstate != "dead" )
	{
		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfGuid = self getGuid();
		lpattackerteam = "";

		if( isPlayer( eAttacker ) )
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		if( isDefined( friendly ) )
		{
			lpattacknum = lpselfnum;
			lpattackname = lpselfname;
			lpattackGuid = lpselfGuid;
		}

		logPrint("D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
}

Callback_PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon( "spawned" );
	self notify( "killed_player" );
	self notify( "death" );

	if( self.sessionteam == "spectator" )
		return;

	// If the player was killed by a head shot, let players know it was a head shot kill
	if( sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	// send out an obituary message to all clients about the kill
	if( !level.hardcore )
	{
		attacker thread customObit( self );
		obituary( self, attacker, sWeapon, sMeansOfDeath );
	}

	self maps\mp\gametypes\_weapons::dropWeapon();
//	self maps\mp\gametypes\_weapons::dropOffhand();

	self.sessionstate = "dead";
	if( !level.rank )
		self.statusicon = "hud_status_dead";

	if( !isdefined( self.switching_teams ) )
		self.deaths++;

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfguid = self getGuid();
	if( level.teamBased )
		lpselfteam = self.pers["team"];
	else
		lpselfteam = "";
	lpattackerteam = "";
	
	self thread [[level.demon_onPlayerKilled]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	attackerNum = -1;
	if( isPlayer( attacker ) )
	{	
		if( attacker == self ) // killed himself
		{
			doKillcam = false;

			// switching teams
			if( level.teamBased  )
			{
				if( isdefined( self.switching_teams ) )
				{
					if( ( self.leaving_team == "allies" && self.joining_team == "axis" ) || ( self.leaving_team == "axis" && self.joining_team == "allies" ) )
					{
						players = maps\mp\gametypes\_teams::CountPlayers();
						players[self.leaving_team]--;
						players[self.joining_team]++;
					
						if( ( players[self.joining_team] - players[self.leaving_team] ) > 1 )
						{
							attacker.pers["score"]--;
							attacker.score = attacker.pers["score"];
						}
					}
				}
			}
			else
			{
				if( !isdefined( self.switching_teams ) )
				{
					attacker.pers["score"]--;
					attacker.score = attacker.pers["score"];
				}
			}

			if( level.teamBased && isdefined( attacker.friendlydamage ) )
				attacker iprintln( &"MP_FRIENDLY_FIRE_WILL_NOT" );
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if( level.teamBased )
			{
				if( self.pers["team"] == attacker.pers["team"] ) // killed by a friendly
				{
					attacker.pers["score"]--;
					attacker.score = attacker.pers["score"];
				}
				else
				{
					attacker.pers["score"]++;
					attacker.score = attacker.pers["score"];

					if( !level.overrideTeamScore )
					{
						teamscore = getTeamScore( attacker.pers["team"] );
						teamscore++;
						setTeamScore( attacker.pers["team"], teamscore );
						checkScoreLimit();
					}
				}
			}
			else
			{
				attackerNum = attacker getEntityNumber();
				doKillcam = true;

				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];
				
				if( !level.roundBased )
					attacker checkScoreLimit();	
				
			}
			
			attacker.cur_kill_streak++;
			attacker demon\_playerdata::onPlayerScore();
			
			if( isAlive( attacker ) )
				attacker thread hardpoints\_hardpoints::giveHardpointItemForStreak();
		}

		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];
		
		if( !level.teamBased && !level.overrideTeamScore )
			attacker notify( "update_playerscore_hud" );
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		self.pers["score"]--;
		self.score = self.pers["score"];

		lpattacknum = -1;
		lpattackname = "";
		lpattackguid = "";
		lpattackerteam = "world";
		
		if( !level.teamBased )
			self notify( "update_playerscore_hud" );
	}

	if( level.teamBased && !level.overrideTeamScore )
		level notify( "update_allhud_score" );

	logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	
	self thread [[level.onPlayerKilled]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	// Stop thread if map ended on this death
	if( level.mapended )
		return;

	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;
	
	if( level.roundBased )
	{
		[[level.updateTeamStatus]]();

		if( !level.exist[self.pers["team"]] ) // If the last player on a team was just killed, don't do killcam
		{
			doKillcam = false;
			self.skip_setspectatepermissions = true;

			if( level.bombplanted && level.planting_team == self.pers["team"] )
			{
				players = getentarray( "player", "classname" );
				for( i = 0; i < players.size; i++ )
				{
					player = players[i];

					if( player.pers["team"] == self.pers["team"] )
					{
						player allowSpectateTeam( "allies", true );
						player allowSpectateTeam( "axis", true );
						player allowSpectateTeam( "freelook", true );
						player allowSpectateTeam( "none", false );
					}
				}
			}
		}
	}

	body = self cloneplayer( deathAnimDuration );
	thread maps\mp\gametypes\_deathicons::addDeathicon( body, self.clientid, self.pers["team"], 5 );

	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before respawn/killcam can execute

	if( doKillcam && level.killcam )
		self maps\mp\gametypes\_killcam::killcam( attackerNum, delay, psOffsetTime, true );
	
	if( level.numLives )
	{
		if( !self.pers["lives"] )
			self thread spawnSpectator( self.origin + (0, 0, 60), self.angles );
		else
			self thread respawn();
	}
	else 
		self thread respawn();
}

spawnPlayer()
{
	self endon( "disconnect" );
	self notify( "spawned" );
	self notify( "end_respawn" );

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble( "damage_heavy" );
	
	if( level.teamBased )
		self.sessionteam = self.pers["team"];
	else
		self.sessionteam = "none";
		
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.maxhealth = level.player_maxhealth;
	self.health = self.maxhealth;
	self.friendlydamage = undefined;
	self.obitSwatch = 0;

	if( !isdefined( self.pers["score"] ) )
		self.pers["score"] = 0;
	self.score = self.pers["score"];

	// Numlives counter
	if( self.pers["lives"] )
		self.pers["lives"]--;
	
	// hardpoint counter - reset to 0
	self.cur_kill_streak = 0;

	if( level.roundBased )
	{
		[[level.updateTeamStatus]]();

		self.usedweapons = false;
		thread maps\mp\gametypes\_weapons::watchWeaponUsage();
	}
	
	self [[level.onPlayerSpawned]]();
	self [[level.demon_onPlayerPreSpawned]]();

	self maps\mp\gametypes\_class::GiveLoadOut();
	
	if( level.showPerksonSpawn && !level.hardcore )	
	{
		perks = maps\mp\gametypes\_class::getPerks( self );
		
		self maps\mp\gametypes\_class::showPerk( 0, perks[0], -50 );
		self maps\mp\gametypes\_class::showPerk( 1, perks[1], -50 );
		self maps\mp\gametypes\_class::showPerk( 2, perks[2], -50 );

		self thread maps\mp\gametypes\_class::hidePerksAfterTime( 3.0 );
		self thread maps\mp\gametypes\_class::hidePerksOnDeath();
	}
	
	self thread hardpoints\_hardpoints::giveOwnedHardpointItem();

	waittillframeend;
	
	self notify( "spawned_player" );
	
	self [[level.demon_onPlayerSpawned]]();
}

spawnSpectator( origin, angles )
{
	self notify( "spawned" );
	self notify( "end_respawn" );

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble( "damage_heavy" );

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if( self.pers["team"] == "spectator" )
		self.statusicon = "";
		
	if( level.roundBased )
	{
		if( !isdefined( self.skip_setspectatepermissions ) )
			maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
	else
		maps\mp\gametypes\_spectating::setSpectatePermissions();

	if( isDefined( origin ) && isDefined( angles  ) )
		self spawn( origin, angles );
	else
	{
		spawnpointname = "mp_global_intermission";
		spawnpoints = getentarray( spawnpointname, "classname" );
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnpoints );

		if( isDefined( spawnpoint ) )
			self spawn( spawnpoint.origin, spawnpoint.angles );
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}
	
	if( level.roundBased )
	{
		[[level.updateTeamStatus]]();
		self.usedweapons = false;
	}
	
	if( level.gametype == "hq" )
		level maps\mp\gametypes\hq::hq_removeall_hudelems( self );
	
	self [[level.demon_onSpawnSpectator]]();

	self setClientCvar( "cg_objectiveText", "" );
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );
		
	if( level.gametype == "ctf" )
		self thread maps\mp\gametypes\ctf::updateTimer();
}

respawn()
{
	if( !isDefined( self.pers["weapon"] ) )
		return;
	
	if( !isValidWeaponforClass( self.pers["weapon"] ) )
	{
		self openMenu( game[ "menu_" + self maps\mp\gametypes\_class::getClass() + "_"+ self.pers["team"] ] );
		self.pers["weapon"] = undefined;
		return;
	}

	[[level.onRespawnPlayer]]();

	self endon( "end_respawn" );

	if( getCvarInt( "scr_forcerespawn" ) <= 0 )
	{
		self thread waitRespawnButton();
		self waittill( "respawn" );
	}

	self thread spawnPlayer();
}

waitRespawnButton()
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	self endon( "respawn" );

	wait 0; // Required or the "respawn" notify could happen before it's waittill has begun

	if( !isdefined( self.respawntext ) )
	{
		self.respawntext = newClientHudElem( self );
		self.respawntext.horzAlign = "center_safearea";
		self.respawntext.vertAlign = "center_safearea";
		self.respawntext.alignX = "center";
		self.respawntext.alignY = "middle";
		self.respawntext.x = 0;
		self.respawntext.y = -50;
		self.respawntext.archived = false;
		self.respawntext.font = "default";
		self.respawntext.fontscale = 2;
		self.respawntext setText( &"PLATFORM_PRESS_TO_SPAWN" );
	}

	thread removeRespawnText();
	thread waitRemoveRespawnText( "end_respawn" );
	thread waitRemoveRespawnText( "respawn" );

	while( self useButtonPressed() != true )
		wait .05;

	self notify( "remove_respawntext" );

	self notify( "respawn" );
}

removeRespawnText()
{
	self waittill( "remove_respawntext" );

	if( isDefined( self.respawntext ) )
		self.respawntext destroy();
}

waitRemoveRespawnText( message )
{
	self endon( "remove_respawntext" );

	self waittill( message );
	self notify( "remove_respawntext" );
}

gracePeriod()
{
	level endon( "game_ended" );
	
	wait( level.gracePeriod );
	
	level notify( "grace_period_ending" );
	wait ( 0.05 );
	
	level.inGracePeriod = false;
	
	if( game["state"] != "playing" )
		return;
}

startGame()
{
	level.starttime = getTime();
	
	if( level.roundBased )
		thread [[level.startRound]]();
	else
	{
		if( level.timelimit > 0 )
		{
			level.clock = newHudElem();
			level.clock.horzAlign = "left";
			level.clock.vertAlign = "top";
			level.clock.x = 8;
			level.clock.y = 2;
			level.clock.font = "default";
			level.clock.fontscale = 2;
			level.clock setTimer( level.timelimit * 60 );
		}

		for( ;; )
		{
			checkTimeLimit();
			wait 1;
		}
	}
}

registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	varname = ("scr_" + dvarString + "_roundlimit");
	dvarstring = demon\_utils::CvarDef( varname, defaultValue, minValue, maxValue, "int" );	
	
	level.roundLimitDvar = dvarString;
	level.roundlimitMin = dvarString;
	level.roundlimitMax = dvarString;
	level.roundLimit = dvarString;
	
	setCvar( "ui_"+ level.gametype + "_roundlimit", level.roundLimit );
	makeCvarServerInfo( "ui_"+ level.gametype + "_roundlimit", level.timeLimit );
	
}

registerRoundLengthDvar( dvarString, defaultValue, minValue, maxValue )
{
	varname = ("scr_" + dvarString + "_roundlength");
	dvarstring = demon\_utils::CvarDef( varname, defaultValue, minValue, maxValue, "float" );	
	
	level.roundLengthDvar = dvarString;
	level.roundLengthMin = dvarString;
	level.roundLengthMax = dvarString;
	level.roundLength = dvarString;
	
	setCvar( "ui_"+ level.gametype + "_roundlength", level.roundLength );
	makeCvarServerInfo( "ui_"+ level.gametype + "_roundlength", level.roundLength );
	
}

registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	varname = ("scr_" + dvarString + "_scorelimit");
	dvarstring = demon\_utils::CvarDef( varname, defaultValue, minValue, maxValue, "int" );
		
	level.scoreLimitDvar = dvarString;	
	level.scorelimitMin = dvarstring;
	level.scorelimitMax = dvarstring;
	level.scoreLimit = dvarstring;
	
	setCvar( "ui_"+ level.gametype + "_scorelimit", level.scoreLimit );
	makeCvarServerInfo( "ui_"+ level.gametype + "_scorelimit", level.scoreLimit );
}

registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	varname = ("scr_" + dvarString + "_timelimit");
	dvarstring = demon\_utils::CvarDef( varname, defaultValue, minValue, maxValue, "float" );

	level.timeLimitDvar = dvarString;	
	level.timelimitMin = dvarString;
	level.timelimitMax = dvarString;
	level.timelimit = dvarString;
	
	setCvar( "ui_"+ level.gametype + "_timelimit", level.timelimit );
	makeCvarServerInfo( "ui_"+ level.gametype + "_timelimit", level.timeLimit );
}

registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	varname = ("scr_" + dvarString + "_numlives");
	dvarstring = demon\_utils::CvarDef( varname, defaultValue, minValue, maxValue, "int" );
		
	level.numLivesDvar = dvarString;	
	level.numLivesMin = dvarString;
	level.numLivesMax = dvarString;
	level.numLives = dvarString;
}

getValueInRange( value, minValue, maxValue )
{
	if( value > maxValue )
		return maxValue;
	else if( value < minValue )
		return minValue;
	else
		return value;
}

updateGametypeCvars()
{
	for( ;; )
	{
		timeLimit = getValueInRange( level.timeLimitDvar, level.timeLimitMin, level.timeLimitMax );
		if( timelimit != level.timelimit )
		{
			level.timelimit = timelimit;
			setCvar( "ui_"+ level.gametype + "_timelimit", level.timelimit );
			
			if( !level.roundBased )
			{
				level.starttime = getTime();
				
				if( level.timelimit > 0 )
				{
					if( !isDefined( level.clock ) ) 
					{
						level.clock = newHudElem();
						level.clock.horzAlign = "left";
						level.clock.vertAlign = "top";
						level.clock.x = 8;
						level.clock.y = 2;
						level.clock.font = "default";
						level.clock.fontscale = 2;
					}
					level.clock setTimer( level.timelimit * 60 );
				}
				else
				{
					if( isDefined( level.clock ) )
						level.clock destroy();
				}
				
				checkTimeLimit();
			}
		}

		scoreLimit = getValueInRange( level.scoreLimitDvar, level.scoreLimitMin, level.scoreLimitMax );
		if( scoreLimit != level.scorelimit )
		{
			level.scorelimit = scorelimit;

			setCvar( "ui_" + level.gametype + "_scorelimit", level.scorelimit );
			if( !level.roundBasedScoring )
				level notify( "update_allhud_score" );
	
			if( level.roundBased )
			{
				if( game["matchstarted"] )
					checkScoreLimit();
			}
			else
				checkScoreLimit();
		}
		
		if( level.roundBased )
		{
			roundlimit = getValueInRange( level.roundLimitDvar, level.roundLimitMin, level.roundLimitMax );
			if( roundlimit != level.roundlimit )
			{
				level.roundlimit = roundlimit;
				setCvar("ui_" + level.gametype + "_roundlimit", level.roundlimit );

				if( game["matchstarted"] )
					[[level.checkRoundLimit]]();
			}
		}			

		wait 1;
	}
}

checkTimeLimit()
{
	if( level.timelimit <= 0 )
		return;
	
	if( level.roundBased )
	{
		if( game["timepassed"] < level.timelimit )
			return;
	}
	else
	{
		timepassed = (getTime() - level.starttime) / 1000;
		timepassed = timepassed / 60.0;

		if( timepassed < level.timelimit )
			return;
	}

	if( level.mapended )
		return;
	level.mapended = true;

	iprintln( &"MP_TIME_LIMIT_REACHED" );
		
	level thread [[level.endgameconfirmed]]();
}

checkScoreLimit()
{
	waittillframeend;

	if( level.scorelimit <= 0 )
		return;
		
	if( level.teamBased )
	{
		if( level.roundBased )
		{
			if( game["alliedscore"] < level.scorelimit && game["axisscore"] < level.scorelimit )
				return;
		}
		else
		{
			if( getTeamScore("allies") < level.scorelimit && getTeamScore("axis") < level.scorelimit )
				return;
		}
	}
	else
	{
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++)
			if( players[i].score < level.scorelimit )
				return;
	}

	if( level.mapended )
		return;
	level.mapended = true;

	iprintln( &"MP_SCORE_LIMIT_REACHED" );
		
	level thread [[level.endgameconfirmed]]();
}

checkRoundLimit()
{
	if( level.roundlimit <= 0 )
		return;

	if( game["roundsplayed"] < level.roundlimit )
		return;

	if( level.mapended )
		return;
	level.mapended = true;

	iprintln( &"MP_ROUND_LIMIT_REACHED" );

	level thread [[level.endgameconfirmed]]();
}

startRound()
{
	level endon( "bomb_planted" );
	level endon( "round_ended" );

	level.clock = newHudElem();
	level.clock.horzAlign = "left";
	level.clock.vertAlign = "top";
	level.clock.x = 8;
	level.clock.y = 2;
	level.clock.font = "default";
	level.clock.fontscale = 2;
	level.clock setTimer( level.roundlength * 60 );

	if( game["matchstarted"] )
	{
		level.clock.color = (.98, .827, .58);

		if( (level.roundlength * 60) > level.graceperiod )
		{
			wait( level.graceperiod );

			level notify( "round_started" );
			level.roundstarted = true;
			level.clock.color = (1, 1, 1);

			// Players on a team but without a weapon show as dead since they can not get in this round
			players = getentarray( "player", "classname" );
			for(i = 0; i < players.size; i++)
			{
				player = players[i];

				if( player.sessionteam != "spectator" && !isdefined( player.pers["weapon"] ) && !level.rank )
					player.statusicon = "hud_status_dead";
			}

			wait( (level.roundlength * 60) - level.graceperiod );
		}
		else
			wait( level.roundlength * 60 );
	}
	else
	{
		level.clock.color = (1, 1, 1);
		wait( level.roundlength * 60 );
	}

	if( level.roundended )
		return;

	if( !level.exist[ game["attackers"] ] || !level.exist[ game["defenders"] ] )
	{
		iprintln( &"MP_TIMEHASEXPIRED" );
		level thread endRound( "draw" );
		return;
	}

	iprintln( &"MP_TIMEHASEXPIRED" );
	
	if( getTeamScore( game["attackers"] ) < getTeamScore( game["defenders"] ) || !getTeamScore( game["attackers"] ) )
		level thread endRound( game["defenders"] );
	else
		level thread endRound( game["attackers"] );
}

checkMatchStart()
{
	oldvalue["teams"] = level.exist["teams"];
	level.exist["teams"] = false;

	// If teams currently exist
	if( level.exist["allies"] && level.exist["axis"] )
		level.exist["teams"] = true;

	// If teams previously did not exist and now they do
	if( !oldvalue["teams"] && level.exist["teams"] )
	{
		if( !game["matchstarted"] )
		{
			iprintlnBold( &"MP_MATCHSTARTING" );

			level notify( "kill_endround" );
			level.roundended = false;
			level thread endRound( "reset" );
		}
		else
		{
			iprintln( &"MP_MATCHRESUMING" );

			level notify( "kill_endround" );
			level.roundended = false;
			level thread endRound( "draw" );
		}

		return;
	}
}

resetScores()
{
	players = getentarray( "player", "classname" );
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
		player.pers["lives"] = level.numLives;
	}

	game["alliedscore"] = 0;
	setTeamScore( "allies", game["alliedscore"] );
	game["axisscore"] = 0;
	setTeamScore( "axis", game["axisscore"] );
}

CleanUponEndRound()
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		player deleteClientHudElements();
		player deleteClientTextElements();
		
		if( isDefined( player.rank_hud_promo ) ) player.rank_hud_promo destroy();
		if( isdefined( player.rank_promo_text ) ) player.rank_promo_text destroy();
	}
}

endRound( roundwinner )
{
	level endon( "intermission" );
	level endon( "kill_endround" );

	if( level.roundended )
		return;
	level.roundended = true;

	level notify( "round_ended" );
	level notify( "game_ended" );
	
	level thread CleanUponEndRound();
	
	level notify( "update_allhud_score" );

	thread [[level.onEndRound]]();

	level thread announceWinner( roundwinner, 2 );

	winners = "";
	losers = "";

	if( roundwinner == "allies" )
	{
		if( level.roundBasedScoring )
			game["alliedscore"]++;
		else
			game["alliedscore"] = getTeamScore( "allies" );
		
		setTeamScore( "allies", game["alliedscore"] );
		
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) 
		{
			lpGuid = players[i] getGuid();
			if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		
		logPrint( "W;allies" + winners + "\n" );
		logPrint( "L;axis" + losers + "\n" );
	}
	else if( roundwinner == "axis" )
	{
		if( level.roundBasedScoring )
			game["axisscore"]++;
		else
			game["axisscore"] = getTeamScore( "axis" );
			
		setTeamScore( "axis", game["axisscore"] );

		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			lpGuid = players[i] getGuid();
			if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		
		logPrint( "W;axis" + winners + "\n");
		logPrint( "L;allies" + losers + "\n" );
	}
	
	if( roundwinner != "reset" )
	{
		outcome = maps\mp\gametypes\_globalgametypes::isTeamVictory( game["alliedscore"], game["axisscore"] );
		[[level.onRoundOutcome]]( game["alliedscore"], game["axisscore"], outcome );
	}

	wait( 7 );

	if( game["matchstarted"] )
	{
		maps\mp\gametypes\_globalgametypes::checkScoreLimit();
		game["roundsplayed"]++;
		[[level.checkRoundLimit]]();
	}

	if( !game["matchstarted"] && roundwinner == "reset" )
	{
		game["matchstarted"] = true;
		
		// Created a new flag to deal with round reset. 
		// It will stay true for the entire game.
		game["reset"] = true;
		
		thread resetScores();
		game["roundsplayed"] = 0;
	}

	game["timepassed"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;

	maps\mp\gametypes\_globalgametypes::checkTimeLimit();

	if( level.mapended )
		return;
	level.mapended = true;

	// for all living players store their weapons
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" && player.sessionstate == "playing" )
		{
			weapon1 = player getWeaponSlotWeapon( "primary" );
			weapon2 = player getWeaponSlotWeapon( "primaryb" );
			current = player getCurrentWeapon();

			// A new weapon has been selected
			if( isdefined( player.oldweapon ) )
			{
				player.pers["weapon1"] = player.pers["weapon"];
				player.pers["weapon2"] = "none";
				player.pers["spawnweapon"] = player.pers["weapon1"];
			} // No new weapons selected
			else
			{
				if( !maps\mp\gametypes\_weapons::isMainWeapon( weapon1 ) && !maps\mp\gametypes\_weapons::isMainWeapon( weapon2 ) )
				{
					player.pers["weapon1"] = player.pers["weapon"];
					player.pers["weapon2"] = "none";
				}
				else if( maps\mp\gametypes\_weapons::isMainWeapon( weapon1 ) && !maps\mp\gametypes\_weapons::isMainWeapon( weapon2 ) )
				{
					player.pers["weapon1"] = weapon1;
					player.pers["weapon2"] = "none";
				}
				else if( !maps\mp\gametypes\_weapons::isMainWeapon( weapon1 ) && maps\mp\gametypes\_weapons::isMainWeapon( weapon2 ) )
				{
					player.pers["weapon1"] = weapon2;
					player.pers["weapon2"] = "none";
				}
				else
				{
					assert( maps\mp\gametypes\_weapons::isMainWeapon( weapon1 ) && maps\mp\gametypes\_weapons::isMainWeapon( weapon2 ) );

					if( current == weapon2 )
					{
						player.pers["weapon1"] = weapon2;
						player.pers["weapon2"] = weapon1;
					}
					else
					{
						player.pers["weapon1"] = weapon1;
						player.pers["weapon2"] = weapon2;
					}
				}

				player.pers["spawnweapon"] = player.pers["weapon1"];
				
			}
		}
	}

	level notify( "restarting" );

	map_restart( true );
}

endMap()
{
	game["state"] = "intermission";
	level notify( "intermission" );
	level notify( "game_ended" );

	if( level.teamBased )
	{
		if( level.roundBased )
		{
			if( level.gametype == "sd" && isdefined( level.bombmodel ) )
				level.bombmodel stopLoopSound();

			if( game["alliedscore"] == game["axisscore"] )
				text = &"MP_THE_GAME_IS_A_TIE";
			else if( game["alliedscore"] > game["axisscore"] )
				text = &"MP_ALLIES_WIN";
			else
				text = &"MP_AXIS_WIN";

			players = getentarray( "player", "classname" );
			for(i = 0; i < players.size; i++)
			{
				player = players[i];

				player closeMenu();
				player closeInGameMenu();
				player setClientCvar( "cg_objectiveText", text );

				player maps\mp\gametypes\_globalgametypes::spawnIntermission();
			}
		}
		else
		{
			alliedscore = getTeamScore( "allies" );
			axisscore = getTeamScore( "axis" );

			if( alliedscore == axisscore )
			{
				winningteam = "tie";
				losingteam = "tie";
				text = "MP_THE_GAME_IS_A_TIE";
			}
			else if( alliedscore > axisscore )
			{
				winningteam = "allies";
				losingteam = "axis";
				text = &"MP_ALLIES_WIN";
			}
			else
			{
				winningteam = "axis";
				losingteam = "allies";
				text = &"MP_AXIS_WIN";
			}

			winners = "";
			losers = "";

			if( winningteam == "allies" )
				level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_allies_win" );
			else if( winningteam == "axis" )
				level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_axis_win" );
			else
				level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_round_draw" );

			outcome = maps\mp\gametypes\_globalgametypes::isTeamVictory( alliedscore, axisscore );
			[[level.onRoundOutcome]]( alliedscore, axisscore, outcome );

			players = getentarray( "player", "classname" );
			for( i = 0; i < players.size; i++ )
			{
				player = players[i];
				if( ( winningteam == "allies" ) || ( winningteam == "axis" ) )
				{
					lpGuid = player getGuid();
					if( isDefined( player.pers["team"] ) && player.pers["team"] == winningteam )
							winners = ( winners + ";" + lpGuid + ";" + player.name );
					else if( isDefined( player.pers["team"] ) && player.pers["team"] == losingteam )
							losers = ( losers + ";" + lpGuid + ";" + player.name );
				}

				player closeMenu();
				player closeInGameMenu();
				player setClientCvar("cg_objectiveText", text);
				
				player maps\mp\gametypes\_globalgametypes::spawnIntermission();
			}

			if( winningteam == "allies" || winningteam == "axis" )
			{
				logPrint( "W;" + winningteam + winners + "\n" );
				logPrint( "L;" + losingteam + losers + "\n" );
			}
		}
	}
	else
	{
		highscore = undefined;
		tied = undefined;
		playername = undefined;
		name = undefined;
		guid = undefined;
		
		players = getEntArray( "player", "classname" );
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if( isdefined( player.pers["team"] ) && player.pers["team"] == "spectator" )
				continue;

			if( !isdefined( highscore ) )
			{
				highscore = player.score;
				playername = player;
				name = player.name;
				guid = player getGuid();
				continue;
			}

			if( player.score == highscore )
				tied = true;
			else if( player.score > highscore )
			{
				tied = false;
				highscore = player.score;
				playername = player;
				name = player.name;
				guid = player getGuid();
			}
		}

		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];

			player closeMenu();
			player closeInGameMenu();

			if( isdefined(tied) && tied == true )
				player setClientCvar( "cg_objectiveText", &"MP_THE_GAME_IS_A_TIE" );
			else if(isdefined(playername))
				player setClientCvar( "cg_objectiveText", &"MP_WINS", playername );

			player maps\mp\gametypes\_globalgametypes::spawnIntermission();
		}

		if( isdefined( name ) )
			logPrint( "W;;" + guid + ";" + name + "\n" );
	
	}

	wait( 10 );
	exitLevel( false );
}

updateTeamStatus()
{
	wait( 0 );	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	resettimeout();

	oldvalue["allies"] = level.exist["allies"];
	oldvalue["axis"] = level.exist["axis"];
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;

	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" && player.sessionstate == "playing" )
			level.exist[player.pers["team"]]++;
	}

	if( level.exist["allies"] )
		level.didexist["allies"] = true;
	if( level.exist["axis"] )
		level.didexist["axis"] = true;

	if( level.roundended )
		return;

	// if both allies and axis were alive and now they are both dead in the same instance
	if( oldvalue["allies"] && !level.exist["allies"] && oldvalue["axis"] && !level.exist["axis"] )
	{
		if( level.bombplanted )
		{
			// if allies planted the bomb, allies win
			if( level.planting_team == "allies" )
			{
				iprintln( &"MP_ALLIEDMISSIONACCOMPLISHED" );
				level thread endRound( "allies" );
				return;
			}
			else // axis planted the bomb, axis win
			{
				assert(game["attackers"] == "axis");
				iprintln(&"MP_AXISMISSIONACCOMPLISHED");
				level thread endRound( "axis" );
				return;
			}
		}

		// if there is no bomb planted the round is a draw
		iprintln( &"MP_ROUNDDRAW" );
		level thread endRound( "draw" );
		return;
	}

	// if allies were alive and now they are not
	if( oldvalue["allies"] && !level.exist["allies"] )
	{
		// if allies planted the bomb, continue the round
		if( level.bombplanted && level.planting_team == "allies" )
			return;

		iprintln( &"MP_ALLIESHAVEBEENELIMINATED" );
		level thread [[level.onPlaySoundOnPlayers]]( "mp_announcer_allieselim" );
		level thread endRound( "axis" );
		return;
	}

	// if axis were alive and now they are not
	if( oldvalue["axis"] && !level.exist["axis"] )
	{
		// if axis planted the bomb, continue the round
		if( level.bombplanted && level.planting_team == "axis" )
			return;

		iprintln( &"MP_AXISHAVEBEENELIMINATED" );
		level thread [[level.onPlaySoundOnPlayers]]( "mp_announcer_axiselim" );
		level thread endRound( "allies" );
		return;
	}
}

onPlaySoundOnPlayers( sound, team )
{
	players = getentarray( "player", "classname" );
	if( isdefined( team ) )
	{
		for( i = 0; i < players.size; i++ )
		{
			if( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == team )
				players[i] playLocalSound( sound );
		}
	}
	else
	{
		for( i = 0; i < players.size; i++ )
			players[i] playLocalSound( sound );
	}
}

onRoundOutcome( alliedScore, axisScore, isTeamVictory )
{
	X = 0;
	Y = -80;
	
	if( isTeamVictory )
	{
		if( alliedScore > axisScore )
		{	
			players = getentarray( "player", "classname" );
			for( i=0; i < players.size; i++ )
			{
				player = players[i];
				
				player playLocalSound( game["allies_victory_music"] );
				player createClientHudElement( "allies_winner", X, Y, "center", "middle", "center_safearea", "center_safearea", false, game["allies_flag"], 128, 128, 1, 0.9, 1, 1, 1 );
				player createClientHudTextElement( "outcome_allies", 0, Y-50, "center", "middle", "center_safearea", "center_safearea", false, 1, 1, 1, 1, 1, 1.4, game["strings"]["outcome_allies"] );
				player ScaleClientHudElementShaderByName( "allies_winner", 0.5, 1.5, 200, 200, 128, 128 );
				
			}
		}
		else
		{	
			players = getentarray( "player", "classname" );
			for( i=0; i < players.size; i++ )
			{
				player = players[i];
				player playLocalSound( game["axis_victory_music"] );
				player createClientHudTextElement( "outcome_axis", 0, Y-50, "center", "middle", "center_safearea", "center_safearea", false, 1, 1, 1, 1, 1, 1.4, game["strings"]["outcome_axis"] );
				player createClientHudElement( "axis_winner", X, Y, "center", "middle","center_safearea", "center_safearea", false, game["axis_flag"], 128, 128, 1, 0.9, 1, 1, 1 );
				player ScaleClientHudElementShaderByName( "axis_winner", 0.5, 1.5, 200, 200, 128, 128 );
			}
		}	
	}
	else 
	{
		players = getentarray( "player", "classname" );
		for( i=0; i < players.size; i++ )
		{
			player = players[i];
			player playLocalSound( game["axis_victory_music"] );
			player createClientHudTextElement( "outcome_draw", 0, Y-50, "center", "middle", "center_safearea", "center_safearea", false, 1, 1, 1, 1, 1, 1.4, game["strings"]["outcome_draw"] );
			player createClientHudElement( "flag_draw", X, Y, "center", "middle", "center_safearea", "center_safearea", false, game["draw_flag"], 128, 70, 1, 0.9, 1, 1, 1 );
			player ScaleClientHudElementShaderByName( "flag_draw", 0.5, 1.5, 200, 142, 128, 70 );
		}
	}
		
	wait( 8 );
	
	if( isTeamVictory )
	{
		if( alliedScore > axisScore )
		{
			players = getentarray( "player", "classname" );
			for( i=0; i < players.size; i++ )
			{
				player = players[i];
				player deleteClientHudElementbyName( "allies_winner" );
				player deleteClientHudTextElementbyName( "outcome_allies" );
			}
		}
		else
		{
			players = getentarray( "player", "classname" );
			for( i=0; i < players.size; i++ )
			{
				player = players[i];
				player deleteClientHudElementbyName( "axis_winner" );
				player deleteClientHudTextElementbyName( "outcome_axis" );
			}
		}
	}
	else
	{
		players = getentarray( "player", "classname" );
		for( i=0; i < players.size; i++ )
		{
			player = players[i];
			player deleteClientHudElementbyName( "flag_draw" );
			player deleteClientHudTextElementbyName( "outcome_draw" );
		}
	}
}

isTeamVictory( alliedScore, axisScore )
{
	if( alliedscore == axisscore )
		return false;
	
	return true;
}

menuAutoAssign()
{
	if( !level.roundBased && isdefined( self.pers["team"] ) && (self.pers["team"] == "allies" || self.pers["team"] == "axis") )
	{
		self openMenu( game["menu_team"] );
		return;
	}

	numonteam["allies"] = 0;
	numonteam["axis"] = 0;

	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator")
			continue;

		numonteam[player.pers["team"]]++;
	}

	// if teams are equal return the team with the lowest score
	if( numonteam["allies"] == numonteam["axis"] )
	{
		if(getTeamScore("allies") == getTeamScore("axis"))
		{
			teams[0] = "allies";
			teams[1] = "axis";
			assignment = teams[randomInt(2)];	// should not switch teams if already on a team
		}
		else if(getTeamScore("allies") < getTeamScore("axis"))
			assignment = "allies";
		else
			assignment = "axis";
	}
	else if(numonteam["allies"] < numonteam["axis"])
		assignment = "allies";
	else
		assignment = "axis";

	if( assignment == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
	{
	    if( !isdefined( self.pers["class"] ) )
	    {
		    if( self.pers["team"] == "allies" )
			    self openMenu( game["menu_class_allies"] );
		    else
			    self openMenu( game["menu_class_axis"] );
	    }

		return;
	}

	if( assignment != self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
	{
		self.switching_teams = true;
		self.joining_team = assignment;
		self.leaving_team = self.pers["team"];
		self [[level.demon_onSwitchingTeams]]();
		self suicide();
	}

	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self [[level.onPlayerJoinedTeam]]();
	if( level.roundBased )
	{
		self.pers["weapon1"] = undefined;
		self.pers["weapon2"] = undefined;
		self.pers["spawnweapon"] = undefined;
	}
	
	self.pers["savedmodel"] = undefined;

	self setClientCvar( "ui_allow_weaponchange", "1" );
	self setClientCvar( "ui_allow_classchange", "1" );

	if( self.pers["team"] == "allies" )
	{	
		self openMenu( game["menu_class_allies"] );
		self setClientCvar( "g_scriptMainMenu", game["menu_class_allies"] );
	}
	else
	{	
		self openMenu( game["menu_class_axis"] );
		self setClientCvar( "g_scriptMainMenu", game["menu_class_axis"] );
	}

	self notify( "joined_team" );
	self notify( "end_respawn" );
}

menuAllies()
{
	if( self.pers["team"] != "allies" )
	{
		if( self.sessionstate == "playing" )
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self [[level.demon_onSwitchingTeams]]();
			self suicide();
		}

		self.pers["team"] = "allies";
		self.pers["weapon"] = undefined;
		self [[level.onPlayerJoinedTeam]]();
		if( level.roundBased )
		{
			self.pers["weapon1"] = undefined;
			self.pers["weapon2"] = undefined;
			self.pers["spawnweapon"] = undefined;
		}
		
		self.pers["savedmodel"] = undefined;

		self setClientCvar( "ui_allow_weaponchange", "1" );
		self setClientCvar( "ui_allow_classchange", "1" );
		self setClientCvar( "g_scriptMainMenu", game["menu_class_allies"] );

		//--- tactical insertion cleanup ---
		self perks\_tactical_insertion::CleanUpMarker( true );

		self notify( "joined_team" );
		self notify( "end_respawn" );
	}

	if( !isdefined( self.pers["class"] ) )
		self openMenu( game["menu_class_allies"] );
}

menuAxis()
{
	if( self.pers["team"] != "axis" )
	{
		if( self.sessionstate == "playing" )
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self [[level.demon_onSwitchingTeams]]();
			self suicide();
		}

		self.pers["team"] = "axis";
		self.pers["weapon"] = undefined;
		self [[level.onPlayerJoinedTeam]]();
		if( level.roundBased )
		{
			self.pers["weapon1"] = undefined;
			self.pers["weapon2"] = undefined;
			self.pers["spawnweapon"] = undefined;
		}		
		
		self.pers["savedmodel"] = undefined;

		self setClientCvar( "ui_allow_weaponchange", "1" );
		self setClientCvar( "ui_allow_classchange", "1" );
		self setClientCvar( "g_scriptMainMenu", game["menu_class_axis"] );

		//--- tactical insertion cleanup ---
		self perks\_tactical_insertion::CleanUpMarker( true );

		self notify( "joined_team" );
		self notify( "end_respawn" );
	}

	if( !isdefined( self.pers["class"] ) )
		self openMenu( game["menu_class_axis"] );
}

menuSpectator()
{
	if( self.pers["team"] != "spectator" )
	{
		if( isAlive( self ) )
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self [[level.demon_onSwitchingTeams]]();
			self suicide();
		}

		self.pers["team"] = "spectator";
		self.pers["weapon"] = undefined;
		self [[level.onPlayerJoinedSpectator]]();
		if( level.roundBased )
		{
			self.pers["weapon1"] = undefined;
			self.pers["weapon2"] = undefined;
			self.pers["spawnweapon"] = undefined;
		}		
		
		self.pers["savedmodel"] = undefined;
		
		//--- tactical insertion cleanup ---
		self perks\_tactical_insertion::CleanUpMarker( true );

		self.sessionteam = "spectator";
		self setClientCvar("ui_allow_weaponchange", "0");
		self setClientCvar("ui_allow_classchange", "0");
		spawnSpectator();

		self setClientCvar( "g_scriptMainMenu", game["menu_ingame"] );

		self notify( "joined_spectators" );
	}
}

menuWeapon( response )
{
	if( !isDefined( self.pers["team"] ) || (self.pers["team"] != "allies" && self.pers["team"] != "axis") )
		return;

	weapon = self maps\mp\gametypes\_weapons::restrictWeaponByServerCvars( response );

	if( weapon == "restricted" )
	{
		if( self.pers["team"] == "allies" )
			self openMenu( game["menu_" + self maps\mp\gametypes\_class::getClass() + "_allies"] );
		else if( self.pers["team"] == "axis" )
			self openMenu( game["menu_" + self maps\mp\gametypes\_class::getClass() + "_axis"] );

		return;
	}

	self setClientCvar( "g_scriptMainMenu", game["menu_ingame"] );

	if( level.roundBased )
	{
		if( !game["matchstarted"] )
		{
			if( isdefined( self.pers["weapon"] ) )
			{
				self.pers["weapon"] = weapon;
				self setWeaponSlotWeapon( "primary", weapon );
				self setWeaponSlotAmmo( "primary", 999 );
				self setWeaponSlotClipAmmo( "primary", 999 );
				self switchToWeapon( weapon );

				maps\mp\gametypes\_weapons::givePistol();
				maps\mp\gametypes\_weapons::giveClassGrenades();
			}
			else
			{
				self.pers["weapon"] = weapon;
				self.spawned = undefined;
				spawnPlayer();
				self thread printJoinedTeam( self.pers["team"] );
				
				[[level.checkMatchStart]]();
			}
		}
		else if( !level.roundstarted && !self.usedweapons )
		{
			if( isdefined( self.pers["weapon"] ) )
			{
				self.pers["weapon"] = weapon;
				self setWeaponSlotWeapon( "primary", weapon );
				self setWeaponSlotAmmo( "primary", 999 );
				self setWeaponSlotClipAmmo( "primary", 999 );
				self switchToWeapon( weapon );

				maps\mp\gametypes\_weapons::givePistol();
				maps\mp\gametypes\_weapons::giveClassGrenades();
			}
			else
			{
				self.pers["weapon"] = weapon;
				if( !level.exist[ self.pers["team"] ] )
				{
					self.spawned = undefined;
					spawnPlayer();
					self thread printJoinedTeam( self.pers["team"] );
					[[level.checkMatchStart]]();
				}
				else
				{
					spawnPlayer();
					self thread printJoinedTeam( self.pers["team"] );
				}
			}
		}
		else
		{
			self.pers["weapon"] = weapon;
			self.sessionteam = self.pers["team"];

			otherteam = getOtherTeam( self.pers["team"] );

			// if joining a team that has no opponents, just spawn
			if( !level.didexist[ otherteam ] && !level.roundended )
			{
				if( isdefined( self.spawned ) )
				{
					if( isdefined( self.pers["weapon"] ) )
					{
						self.pers["weapon"] = weapon;
						self setWeaponSlotWeapon( "primary", weapon );
						self setWeaponSlotAmmo( "primary", 999 );
						self setWeaponSlotClipAmmo( "primary", 999 );
						self switchToWeapon( weapon );

						maps\mp\gametypes\_weapons::givePistol();
						maps\mp\gametypes\_weapons::giveClassGrenades();
					}
				}
				else
				{
					self.spawned = undefined;
					spawnPlayer();
					self thread printJoinedTeam( self.pers["team"] );
				}
				
			} // else if joining an empty team, spawn and check for match start
			else if( !level.didexist[ self.pers["team"] ] && !level.roundended )
			{
				self.spawned = undefined;
				spawnPlayer();
				self thread printJoinedTeam( self.pers["team"] );
				[[level.checkMatchStart]]();
				
			} // else if numlives you will spawn with selected weapon next round 
			else if( CantSpawnAfterReset() )
			{
				weaponname = maps\mp\gametypes\_weapons::getWeaponName( self.pers["weapon"] );

				if( self.pers["team"] == "allies" )
				{
					if( maps\mp\gametypes\_weapons::useAn( self.pers["weapon"] ) )
						self iprintln( &"MP_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND", weaponname );
					else
						self iprintln( &"MP_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND", weaponname );
				}
				else
				{
					if( maps\mp\gametypes\_weapons::useAn( self.pers["weapon"] ) )
						self iprintln( &"MP_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND", weaponname );
					else
						self iprintln( &"MP_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND", weaponname );
				}
			}
			else
			{
				self.pers["weapon"] = weapon;

				weaponname = maps\mp\gametypes\_weapons::getWeaponName( self.pers["weapon"] );

				if( maps\mp\gametypes\_weapons::useAn( self.pers["weapon"] ) )
					self iprintln( &"MP_YOU_WILL_RESPAWN_WITH_AN", weaponname);
				else
					self iprintln( &"MP_YOU_WILL_RESPAWN_WITH_A", weaponname );
			}
		}	
	}
	else
	{
		if( isDefined( self.pers["weapon"] ) && self.pers["weapon"] == weapon )
			return;

		if( !isDefined( self.pers["weapon"] ) )
		{
			self.pers["weapon"] = weapon;
			
			if( hasRespawnDelay() )
			{
				if( self GetEntityFlagType() )
				{
					self thread respawn();
					self thread [[level.updateTimer]]();
				}
				else
					spawnPlayer();
			}
			else
				spawnPlayer();
			
			self thread printJoinedTeam( self.pers["team"] );
		}
		else
		{
			self.pers["weapon"] = weapon;

			weaponname = maps\mp\gametypes\_weapons::getWeaponName( self.pers["weapon"] );

			if( maps\mp\gametypes\_weapons::useAn( self.pers["weapon"] ) )
				self iprintln( &"MP_YOU_WILL_RESPAWN_WITH_AN", weaponname);
			else
				self iprintln( &"MP_YOU_WILL_RESPAWN_WITH_A", weaponname );
		}
	}

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

CantSpawnAfterReset()
{
	if( getCvar( "scr_" + level.gametype + "_numlives" ) > 0 )
		return true;
		
	return false;
}

GetEntityFlagType()
{
	entityflagtype = undefined;
	switch( level.gametype )
	{
		case "ctf":
			entityflagtype = isdefined( self.WaitingToSpawn );
			break;
			
		case "hq":
			entityflagtype = ( isdefined( self.WaitingOnTimer ) || ( ( self.pers["team"] == level.DefendingRadioTeam ) && isdefined( self.WaitingOnNeutralize ) ) );
			break;
	}
	
	return( entityflagtype );
}

hasRespawnDelay()
{
	switch( level.gametype )
	{
		case "ctf":
		case "hq":
			return true;
	
		default:
			return false;
	}
}

printJoinedTeam( team )
{
	if( level.hardcore ) return;
	
	if( team == "allies" )
		iprintln( &"MP_JOINED_ALLIES", self );
	else
		iprintln( &"MP_JOINED_AXIS", self );
}

announceWinner( winner, delay )
{
	wait delay;

	// Announce winner
	if( winner == "allies" )
		level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_allies_win" );
	else if( winner == "axis" )
		level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_axis_win" );
	else if( winner == "draw" )
		level thread [[level.onPlaySoundOnPlayers]]( "MP_announcer_round_draw" );
}

createFlagWaypoint( name, origin, shader, height )
{
	if( isDefined( height ) )
		height = height;
	else
		height = 100;
		
	thread maps\mp\gametypes\_objpoints::addObjpoint( origin +(0,0,height), name, shader );
}

deleteFlagWaypoint( name )
{
	thread maps\mp\gametypes\_objpoints::deleteWaypointByName( name );
}

customObit( casualty )
{
	if( !level.bloodObit ) return;
	
	if( level.hardcore || !isPlayer( self ) || casualty == self ) return;
	
	self notify( "end_obituary" );	
	
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_obituary" );

	self deleteOtherDeathObit();
	
	X = 5;
	Y = 158;
	alpha = .9;
	
	shader = GetShader( self.obitSwatch );
	
	horizSize = undefined;
	if( shader == "bloodsplatter3" )
		horizSize = 240;
	else
		horizSize = 200;
		
	background = newClientHudElem( self );
	background.x = X;
	background.y = Y;
	background.alignX = "center";
	background.alignY = "middle";
	background.horzAlign = "center_safearea";
	background.vertAlign = "center_safearea";	
	background.alpha = alpha;
	background SetShader( shader, horizSize, 90 );
	
	self.obitSwatch++;
	if( self.obitSwatch > 2 )
		self.obitSwatch = 0;
		
	self.otherDeathObit = background;
		
	wait( 6.95 );
		
	self deleteOtherDeathObit();
}

deleteOtherDeathObit()
{
	if( isdefined( self.otherDeathObit ) ) 
		self.otherDeathObit destroy();
}

GetShader( swatch )
{
	shader = [];
	shader[0] = "bloodsplatter";
	shader[1] = "bloodsplatter2";
	shader[2] = "bloodsplatter3";
	
	return shader[swatch];
}

setUpVariables()
{
	level.onLineGame = ( getCvar( "dedicated" ) == "1" || getCvar( "dedicated" ) == "2" );
	
	level.gametype = getCvar( "g_gametype" );
	level.script = getCvar( "mapname" );
	level.players = [];
	
	// Set up object queue for scavenger
	level.objectQ["scavenger"] = [];
	level.objectQcurrent["scavenger"] = 0;
	level.objectQsize["scavenger"] = 16;

	// Set up object queue for healthpacks
	level.objectQ["healthpack"] = [];
	level.objectQcurrent["healthpack"] = 0;
	level.objectQsize["healthpack"] = 16;
	
	if( isTeamGametype() )
		level.teamBased = true;
	else
		level.teamBased = false;
	
	if( isRoundBasedGametype() )
		level.roundBased = true;
	else
		level.roundBased = false;
		
	if( isRoundBasedScoring() )
		level.roundBasedScoring = true;
	else
		level.roundBasedScoring = false;
	
	if( isObjectiveScoring() )
		level.overrideTeamScore = true;
	else
		level.overrideTeamScore = false;
	
	//---Define if it's a Winter Map or not---
	if( isdefined( game["german_soldiertype"] ) && (game["german_soldiertype"] == "winterlight" || game["german_soldiertype"] == "winterdark") )
		level.wintermap = true;
	else
		level.wintermap = false;
		
	if( isNativeMap() )
		level.native = true;
	else
		level.native = false;
}

isTeamGametype()
{
	switch( level.gametype )
	{
		case "dm":
			return false;
			
		default:
			return true;
	}
}

isRoundBasedGametype()
{
	if( getCvarInt( "scr_" + level.gametype + "_roundLimit" ) )
		return true;
		
	return false;
}

isRoundBasedScoring()
{
	switch( level.gametype )
	{
		case "sd":
			return true;
			
		default:
			return false;
	}
}

isObjectiveScoring()
{
	switch( level.gametype )
	{
		case "ctf":
		case "kconf":
		case "dom":
		case "re":
			return true;
			
		default:
			return false;
	}
}

isNativeMap()
{
	switch( level.script )
	{
		case "mp_brecourt":
		case "mp_carentan":
		case "mp_burgundy":
		case "mp_dawnville":
		case "mp_farmhouse":
		case "mp_trainstation":
		case "mp_rhine":
		case "mp_breakout":
		case "mp_decoy":
		case "mp_matmata":
		case "mp_toujane":
		case "mp_downtown":
		case "mp_railyard":
		case "mp_leningrad":
		case "mp_harbor":
			return true;
		
		default:
			return false;
	}
}


