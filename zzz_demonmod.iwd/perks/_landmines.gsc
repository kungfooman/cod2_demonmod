/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;
#include maps\mp\_utility;

init()
{
	level.landmine						= cvardef( "scr_landmines", 1, 0, 3, "int" );

	if( !level.landmine ) return;

	game["landmine"] = [];
	game["landmine"]["limit"]				= cvardef( "scr_landmine_limit", 5, 1, 20, "int" );
	game["landmine"]["planttime"]			= cvardef( "scr_landmine_plant_time", 5, 0, 30, "float" );
	game["landmine"]["picktimesameteam"]	= cvardef( "scr_landmine_pick_time_sameteam", 5, 0, 30, "float" );
	game["landmine"]["picktimeotherteam"]	= cvardef( "scr_landmine_pick_time_otherteam", 8, 0, 30, "float" );
	game["landmine"]["jump"] 				= cvardef( "scr_landmine_jump", 0, 0, 1, "int");
	game["landmine"]["vanish"] 				= cvardef( "scr_landmine_vanish", 0, 0, 1, "int");
	game["landmine"]["vanish_time"]			= cvardef( "scr_landmine_vanish_time", 120, 1, 99999, "float");

	game["landmine_team"] = [];
	if( level.teamBased )
	{
		game["landmine_team"]["axis"] = 0;
		game["landmine_team"]["allies"] = 0;
	}
	else
	{
		game["landmine_team"] = 0;
	}

	level.landmines_array = [];

	game["landmine"]["pickupmessage"] = &"LANDMINE_PICKUP";
	game["landmine"]["placemessage"] = &"LANDMINE_PLACE";

	if( game["landmine"]["picktimesameteam"] || game["landmine"]["picktimeotherteam"] )
		game["landmine"]["pickingUpmessage"] = &"LANDMINE_PICKING_UP";
	if( game["landmine"]["planttime"] )
		game["landmine"]["placingmessage"] = &"LANDMINE_PLACING" ;

	onPrecache();
	
	level thread onPlayerConnect();
}

onPrecache()
{
	if( !isdefined( game["gamestarted"] ) )
	{
		precacheModel( "xmodel/landmine" );
		precacheModel( "xmodel/tellermine" );
	
		precacheString( game["landmine"]["pickupmessage"] );
		precacheString( game["landmine"]["placemessage"] );
		
		if( game["landmine"]["picktimesameteam"] || game["landmine"]["picktimeotherteam"] )
			precacheString( game["landmine"]["pickingUpmessage"] );
			
		if( game["landmine"]["planttime"] )
			precacheString( game["landmine"]["placingmessage"] );

		precacheShader( "hud_tellermine" );
		precacheShader( "hud_landmine" );
		precacheShader( "hud_tellermine_defuse" );
		precacheShader( "hud_landmine_defuse" );

		if( game["landmine"]["planttime"] || game["landmine"]["picktimesameteam"] || game["landmine"]["picktimeotherteam"] )
			precacheShader( "white" );
		
		level.mine_explosion = loadfx ("fx/explosions/grenadeExp_dirt.efx");
	}
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );

		player.pers["checkdefuse"]["landmine"] = false;
		player.Explosivesmessage = [];
		player.ExplosivesShader = [];
		player.pers["landmine_count"] = 0;
		
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "spawned_player" );
		
		self thread Monitorlandmines();
		
	}
}

onPlayerKilled()
{
	self endon("disconnect");
	
	for( ;; )
	{
		self waittill( "killed_player" );
		
		self thread CleanupKilled();
	}
}

Monitorlandmines()
{
	self endon( "killed_player" );
	self endon( "disconnect" );
	
	if( !self hasPerk( "specialty_weapon_betty" ) )
		return;

	self.pers["checkdefuse"]["landmine"] = false;
	self.pers["landmine_count"] = 2;
	self setClientCvar( "ui_landmine_count", "[" + self.pers["landmine_count"] + "]" );
		
	team = self getOwnTeam();
	otherteam = self getOtherTeam( team );
	
	for( ;; )
	{
		myammo	= self.pers["landmine_count"];
		if( level.landmine && myammo > 0 && self getStance() == "prone" && !isDefined( self.Explosivesmessage["landmine"] ) )
			self thread checklandminePlacement( team, myammo );

		wait .05;
	}
}

CleanupKilled()
{
	if( !level.landmine ) return;

	if( !self hasPerk( "specialty_weapon_betty" ) )
		return;

	self CleanUpMessages();
}

checklandminePlacement( team, myammo )
{
	if( !level.landmine ) 		return;
	
	sWeapon = undefined;
	
	Y = 365;

	self notify( "check_landmine_placement" );
	self endon( "check_landmine_placement" );

	while( isAlive( self ) && self.sessionstate == "playing" && self useButtonPressed() )
		wait( 0.1 );

	if( myammo )
		sWeapon = self GetLandmineType();

	perks\_bombsquad::showExplosivesMessage( "landmine", sWeapon, game["tripwire"]["placemessage"], undefined );

	while( isAlive( self ) && self.sessionstate == "playing" )
	{
		myammo	= self.pers["landmine_count"];

		if( !myammo ) break;

		if( myammo )
		{
			sWeapon = self GetLandmineType();
		}

		if( self getStance() != "prone" ) break;
	
		if( !self CanPlant() )
			self CleanUpMessages();

		position = self.origin + vectorScale( anglesToForward( self.angles ), 15 );

		trace = bulletTrace( self.origin+(0,0,10), position+(0,0,10), false, undefined );
		if( trace["fraction"] != 1 ) break;
	
		trace = bulletTrace( position+(0,0,10), position+(0,0,-10), false, undefined );
		if( trace["fraction"] == 1 ) break;
		position = trace["position"];
		tracestart = position + (0,0,10);

		traceend = tracestart + vectorScale( anglesToForward( self.angles + ( 0, 90, 0 ) ), 50 );
		trace = bulletTrace( tracestart, traceend, false, undefined );
		if( trace["fraction"] != 1 )
		{
			distance = distance( tracestart, trace["position"] );
			if( distance > 5 ) distance = distance - 2;
			position1 = tracestart + vectorScale( vectorNormalize( trace["position"] -tracestart ), distance );
		}
		else
			position1 = trace["position"];

		trace = bulletTrace( position1, position1+( 0, 0, -20 ), false, undefined );
		if( trace["fraction"] == 1 ) break;
		vPos1 = trace["position"] + (0,0,3);

		traceend = tracestart + vectorScale( anglesToForward( self.angles + (0,-90,0) ), 50 );
		trace = bulletTrace( tracestart, traceend, false, undefined );
		if( trace["fraction"] != 1 )
		{
			distance = distance( tracestart, trace["position"] );
			if( distance > 5 ) distance = distance - 2;
			position2 = tracestart + vectorScale( vectorNormalize( trace["position"]-tracestart ), distance );
		}
		else
			position2 = trace["position"];

		trace = bulletTrace( position2, position2+(0,0,-20), false, undefined );
		if( trace["fraction"] == 1 ) break;
		vPos2 = trace["position"] + (0,0,3);

		if( isAlive( self ) && self.sessionstate == "playing" && self CanPlant() && self useButtonPressed() )
		{
			if( level.teamBased )
			{
				if( game["landmine_team"][self.sessionteam] >= game["landmine"]["limit"] )
				{
					self iprintlnbold( &"LANDMINE_MAX_TEAM" );
					self CleanUpMessages();
					return false;
				}
			}
			else
			{
				if( game["landmine_team"] >= game["landmine"]["limit"] *2 )
				{
					self iprintlnbold( &"LANDMINE_MAX" );
					self CleanUpMessages();
					return false;
				}
			}

			origin = self.origin;
			angles = self.angles;

			if( game["landmine"]["planttime"] )
				planttime = game["landmine"]["planttime"];
			else
				planttime = undefined;

			if( isdefined( planttime ) )
			{
				self disableWeapon();
				self playsound( "MP_bomb_plant" );
				
				if( !isdefined( self.plantbar ) )
				{
					barsize = 288;
					bartime = planttime;
					self CleanUpMessages();

					self.plantbarbackground = newClientHudElem( self );				
					self.plantbarbackground.alignX = "center";
					self.plantbarbackground.alignY = "top";
					self.plantbarbackground.x = 320;
					self.plantbarbackground.y = Y - 6;
					self.plantbarbackground.alpha = 0.5;
					self.plantbarbackground.color = (0,0,0);
					self.plantbarbackground setShader( "white", (barsize + 4), 12 );	
		
					// Progress bar
					self.plantbar = newClientHudElem( self );				
					self.plantbar.alignX = "left";
					self.plantbar.alignY = "top";
					self.plantbar.x = (320 - (barsize / 2.0));
					self.plantbar.y = Y - 4;
					self.plantbar setShader("white", 0, 8);
					self.plantbar scaleOverTime( bartime , barsize, 8 );

					perks\_bombsquad::showExplosivesMessage( "landmine", sWeapon, game["tripwire"]["placingmessage"], undefined );
				}

				color = 1;
				for( i=0; i < planttime*20; i++ )
				{
					if( !( self useButtonPressed() && origin == self.origin && isAlive( self ) && self.sessionstate == "playing" && self getStance() == "prone" ) )
						break;
						
					self.plantbar.color = (1,color,color);
					color -= 0.05 / planttime;
					wait( 0.05 );
				}
				
				self CleanUpMessages();
				self enableWeapon();
				
				if( i < planttime*20 )
					return false;
			}

			if( level.teamBased )
			{
				if( game["landmine_team"][self.sessionteam] >= game["landmine"]["limit"] )
				{
					self iprintlnbold( &"LANDMINE_MAX_TEAM" );
					return false;
				}
			}
			else
			{
				if( game["landmine_team"] >= game["landmine"]["limit"]*2 )
				{
					self iprintlnbold( &"LANDMINE_MAX" );
					return false;
				}
			}

			if( level.teamBased )
				game["landmine_team"][self.sessionteam]++;
			else
				game["landmine_team"]++;

			x = (vPos1[0] + vPos2[0])/2;
			y = (vPos1[1] + vPos2[1])/2;
			z = (vPos1[2] + vPos2[2])/2;
			vPos = (x,y,z);

			// Decrease landmine count
			if( myammo )
			{
				self.pers["landmine_count"]--;
				self setClientCvar( "ui_landmine_count", "[" + self.pers["landmine_count"] + "]" );
			}

			// Spawn landmine Origin
			landmine = spawn( "script_origin", vPos );
			landmine.angles = angles;
			landmine.team = team;
			level.landmines_array[level.landmines_array.size] = landmine;
			landmine thread monitorlandmine( self, sWeapon, vPos );
			landmine thread perks\_bombsquad::bombsquadDetectionTrigger( vPos );
			landmine maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( landmine.team, (0,0,20) );
			
			self playsound( "weap_fraggrenade_pin" );
			break;
		}
		
		wait( 0.2 );
	}
	
	self CleanUpMessages();
}

monitorlandmine( owner, sWeapon, origin )
{
	level endon( "intermission" );
	self endon( "monitor_landmine" );

	wait( 0.05 );
	
	offset = -4;

	// Spawn mine model
	self.landmine = spawn( "script_model", origin+(0,0,offset) );
	self.landmine.angles = self.angles;
	self.landmine setModel( sWeapon );
	self.landmine.minetype = sWeapon;
	self.landmine.targetname = "landmines";

	range = distance( self.origin, origin ) + 120;

	if( isDefined (owner ) && isAlive( owner ) && owner.sessionstate == "playing" )
		owner iprintlnbold( &"LANDMINE_ACTIVATES" );

	wait 5;

	landminetime = getTime();
	
	for( ;; )
	{
		blow = false;

		players = getEntArray( "player", "classname" );
		for( i=0; i < players.size && !blow; i++ )
		{
			player = players[i];
		
			if( player.sessionstate == "spectator" || player.sessionstate == "dead" || player == self )
				continue;

			if( !isPlayer( player ) || !isAlive( player ) || player.sessionstate != "playing" )
				continue;
			
			distance = distance( self.origin, player.origin );
			if( distance >= range )
				continue;
			
			if( !player.pers["checkdefuse"]["landmine"] )
				player thread perks\_bombsquad::checkDefuse( "landmine", self, sWeapon );
				
			if( player hasPerk( "specialty_detectexplosives" ) && player getStance() == "prone" )
				continue;

			if( game["landmine"]["jump"] && ( !player isOnGround() ) )
				continue;

			distance = distance( origin, player.origin );
			if( distance >= range )
				continue;
				
			blow = true;
			break;
		}

		// landmine life time
		if( game["landmine"]["vanish"] )
		{
			timepassed = (getTime () - landminetime) / 1000;
			
			if( timepassed > game["landmine"]["vanish_time"] )
			{
				if( level.teamBased )
					game["landmine_team"][ self.team ]--;
				else
					game["landmine_team"]--;

				if( isdefined( self.landmine ) )
					self.landmine delete ();
				if( isdefined( self.entityHeadIcons ) ) 
					self maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( "none" );
				return;
			}
		}
		
		if( blow ) break;
		wait .05;
	}

	if( level.teamBased )
		game["landmine_team"][ self.team ]--;
	else
		game["landmine_team"]--;
		
	if( self.team == "allies" )
	{
		self.landmine playsound( "betty_jump" );
		self.landmine movez( 50, .25 );
		wait( .25 );
	}
	else
	{
		self.landmine playsound( "weap_fraggrenade_pin" );
		wait( .50 );
	}
	
	if( isDefined( owner ) && isPlayer( owner ) )
	{
		if( isdefined( self.team ) && self.team == owner.sessionteam )
			eAttacker = owner;
		else if( !isdefined( self.team ) )
			eAttacker = owner;
		else
			eAttacker = self;
	}
	else
		eAttacker = self;

	iMaxdamage = 200;
	iMindamage = 50;

	self.landmine playsound( "grenade_explode_default" );
	playfx( level.mine_explosion, self.landmine.origin );
	
	self scriptedRadiusDamage( eAttacker, (0,0,0), sWeapon, 256, iMaxdamage, iMindamage, (level.landmine>1) );
	
	wait .05;
	self.landmine delete();

	wait( randomFloat( .25 ) );
	
	if( isdefined( self.entityHeadIcons ) ) 
		self maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( "none" );
	
	if( isdefined( self ) )
		self delete();		
}

CleanUpMessages()
{
	if( isdefined( self.pickbar ) )				self.pickbar destroy();
	if( isdefined( self.plantbarbackground ) )	self.plantbarbackground destroy();
	if( isdefined( self.plantbar ) )			self.plantbar destroy();
	
	if( isdefined( self.Explosivesmessage["landmine"] ) )	self.Explosivesmessage["landmine"] destroy();
	if( isdefined( self.ExplosivesShader["landmine"] ) ) self.ExplosivesShader["landmine"] destroy();
}

GetLandmineType()
{
	model = undefined;
	if( self.pers["team"] == "allies" )
		model = "xmodel/landmine";
	else
		model = "xmodel/tellermine";
		
	return model;
}
