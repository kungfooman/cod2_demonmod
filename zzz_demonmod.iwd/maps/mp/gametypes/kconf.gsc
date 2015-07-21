/*************************************************
	Demon Mod for COD2 by Tally
	
	KILL CONFIRMED GAMETYPE
	
**************************************************/

#include demon\_utils;

main()
{	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_startspawns::init();
	
	maps\mp\gametypes\_globalgametypes::registerTimeLimitDvar( "kconf", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerScoreLimitDvar( "kconf", 30, 0, 9999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLimitDvar( "kconf", 0, 0, 999 );
	maps\mp\gametypes\_globalgametypes::registerRoundLengthDvar( "kconf", 4, 1, 999 );
	maps\mp\gametypes\_globalgametypes::registerNumLivesDvar( "kconf", 0, 0, 99 );
	
	level.life_cycle = cvardef( "scr_kconf_dogtag_life", 40, 0, 999, "int" );

	level.onPrecacheGametype = ::onPrecacheGametype;
	level.onGametypeStarted = ::onGametypeStarted;
	level.onPlayerSpawned = ::onPlayerSpawned;
	level.onPlayerKilled = ::onPlayerKilled;
}

onPrecacheGametype()
{
	game["dogtags_confirm"] = "xmodel/dogtags_gold";
	game["dogtags_deny"] = "xmodel/dogtags_red";

	precacheModel( game["dogtags_confirm"] );
	precacheModel( game["dogtags_deny"] );

	precacheShader( "dogtags_gold" );
	precacheShader( "dogtags_red" );
	
	level.kconf["explode_red"] = loadfx( "fx/smoke/dogtag_sparks_red.efx" );
	level.kconf["explode_gold"] = loadfx( "fx/smoke/dogtag_sparks_gold.efx" );
	
	precacheString( &"KCONF_KILL_CONFIRMED" );
	precacheString( &"KCONF_KILL_DENIED" );
	precacheString( &"KCONF_OWN_DOGTAGS_DENIED" );
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
	
	level.dogtagObjectives = 0;
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

	self setClientCvar( "cg_objectiveText", &"KCONF_OBJECTIVE_HINT" );
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( isPlayer( attacker ) && attacker != self )
		self dropDogtags( attacker );
}

dropDogtags( attacker )
{
	Dogtag = [];

	if( IsEvenObjectiveNum( level.dogtagObjectives ) )
	{
		// attacker's dogtags
		Dogtag[0] = spawn( "script_origin", self.origin );
		Dogtag[0].angles = (0,0,0);
		Dogtag[0].team = attacker.pers["team"];
		Dogtag[0].life_cycle = 0;
		// VISUALS
		Dogtag[0].visuals = spawn( "script_model", self.origin + (0,0,25) );
		Dogtag[0].visuals.angles = (0,0,0);
		Dogtag[0].visuals setModel( game["dogtags_confirm"] );
		Dogtag[0].visuals.team = attacker.pers["team"];
		Dogtag[0].visuals.life_cycle = 0;
		Dogtag[0].visuals thread Bounce();

		Dogtag[0].objective = level.dogtagObjectives;
		
		// increase the objective count for the next dogtag
		level.dogtagObjectives++; 

		objective_add( Dogtag[0].objective, "current", Dogtag[0].origin );
		objective_icon( Dogtag[0].objective, "dogtags_gold" );
		objective_team( Dogtag[0].objective, Dogtag[0].team );

		// victim's dogtags
		Dogtag[1] = spawn( "script_origin", self.origin );
		Dogtag[1].angles = (0,0,0);
		Dogtag[1].team = self.pers["team"];
		Dogtag[1].owner = self;
		Dogtag[1].life_cycle = 0;
		// VISUALS
		Dogtag[1].visuals = spawn( "script_model", self.origin + (0,0,25) );
		Dogtag[1].visuals.angles = (0,0,0);
		Dogtag[1].visuals setModel( game["dogtags_deny"] );
		Dogtag[1].visuals.team = self.pers["team"];
		Dogtag[1].visuals.owner = self;
		Dogtag[1].visuals.life_cycle = 0;
		Dogtag[1].visuals thread Bounce();

		Dogtag[1].objective = level.dogtagObjectives;
		
		// increase the objective count for the next dogtag
		level.dogtagObjectives++; 
		
		objective_add( Dogtag[1].objective, "current", Dogtag[1].origin );
		objective_icon( Dogtag[1].objective, "dogtags_red" );
		objective_team( Dogtag[1].objective, Dogtag[1].team );
		
		for( i=0; i < Dogtag.size; i++ )
		{
			Dogtag[i] thread dogtagThink( attacker.pers["team"] );
		}
	
	}
}

Bounce()
{
	level endon( "intermission" );
	self endon( "death" );	
	
	bottomPos = self.Origin;
	topPos = self.Origin +( 0,0,15 );
	
	while( true )
	{
		self moveTo( topPos, 0.5, 0.15, 0.15 );
		self rotateYaw( 180, 0.5 );
		
		wait( 0.5 );
		
		self moveTo( bottomPos, 0.5, 0.15, 0.15 );
		self rotateYaw( 180, 0.5 );	
		
		wait( 0.5 );		
	}
}

DogtagThink( attackerTeam )
{	
	level endon( "intermission" );
	self endon( "death" );
	
	self thread DogTagLife( attackerTeam );

	while( isDefined( self ) &&  isDefined( self.visuals ) )
	{	
		self.visuals hide();
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) 
		{             
			player = players[i];
			
			// Show the right dogtag to the right team at the right time
			if( player.pers["team"] == self.visuals.team )
				self.visuals showtoplayer( player );
			
			if( isPlayer( player ) && isAlive( player ) && player.sessionstate == "playing" && distance( self.origin, player.origin ) < 40 )
			{
				// if player is on the attackers team
				if( player.pers["team"] == attackerTeam )
					self thread Attacker( attackerTeam, player );
				else
					self thread Defender( attackerTeam, player );

				if( isdefined( self.objective ) )
				{
					objective_delete( self.objective );
					
					// decrese the objective count so that another fresh dogtag can take its place
					if( !( level.dogtagObjectives < 0 ) )
						level.dogtagObjectives--;
				}
				
				if( isdefined( self ) ) 
				{
					self.visuals delete();
					self delete();
				}
			}
		}

		wait( 0.05 );		
	}
}

DogTagLife( attackerTeam )
{
	level endon( "intermission" );
	self endon( "death" );
	
	self.explode_fx = undefined;
	
	while( isDefined( self ) )
	{
		self.life_cycle++;
		
		if( self.life_cycle >= level.life_cycle )
		{
			if( isdefined( self.objective ) )
			{
				objective_delete( self.objective );
					
				// decrese the objective count so that another fresh dogtag can take its place
				if( !( level.dogtagObjectives < 0 ) )
					level.dogtagObjectives--;
			}

			// run the dogtag explode FX
			if( self.team == attackerTeam )
			{
				goldTeam = playLoopedFX( level.kconf["explode_gold"], 0.75, self.visuals getOrigin() );
				goldTeam thread showToTeam( attackerTeam );
			}
			else
			{
				redTeam = playLoopedFX( level.kconf["explode_red"], 0.75, self.visuals getOrigin() );
				redTeam thread showToTeam( self.team );		
			}
			
			self.visuals delete();
			self delete();
		}
			
		wait( 1 );
	}
}

// Show the right dogtag explode FX to the right team
showToTeam( team )
{
	self hide();
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ )
	{
		player = players[i];
		if( isDefined( player.pers["team"] ) && player.pers["team"] == team )
			self ShowToPlayer( player );
	}
		
	wait( 0.5 );	
	
	self delete();
}

Attacker( attackerTeam, player )
{
	if( self.team != attackerTeam ) return;
	
	teamscore = getTeamScore( attackerTeam );
	teamscore++;
	setTeamScore( attackerTeam, teamscore );
	
	level notify( "update_allhud_score" );

	maps\mp\gametypes\_globalgametypes::checkScoreLimit();
	
	self AnnouncetoAll( &"KCONF_KILL_CONFIRMED" );
	
	player playLocalSound( "ctf_touchown" );	
}

Defender( attackerTeam, player )
{
	if( self.team == attackerTeam ) return;
	
	if( self.owner == player )
		player iprintlnBold( &"KCONF_OWN_DOGTAGS_DENIED" );
	else
		self AnnouncetoAll( &"KCONF_KILL_DENIED" );
	
	player playLocalSound( "ctf_enemy_touchcapture" );	
}

AnnouncetoAll( Msg )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		players[i] iprintlnbold( Msg );
	}
}

IsEvenObjectiveNum( num )
{
	switch( num )
	{
		case 0:
		case 2:
		case 4:
		case 6:
		case 8:
		case 10:
		case 12:
			return true;
		
		default:
			return false;
	}
}




