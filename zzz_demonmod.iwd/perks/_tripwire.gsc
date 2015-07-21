/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;
#include maps\mp\_utility;

init()
{
	level.tripwire						= cvardef( "scr_tripwire", 1, 0, 3, "int" );

	if( !level.tripwire ) return;

	game["tripwire"] = [];
	game["tripwire"]["limit"]				= cvardef( "scr_tripwire_limit", 5, 1, 20, "int" );
	game["tripwire"]["planttime"]			= cvardef( "scr_tripwire_plant_time", 5, 0, 30, "float" );
	game["tripwire"]["picktimesameteam"]	= cvardef( "scr_tripwire_pick_time_sameteam", 5, 0, 30, "float" );
	game["tripwire"]["picktimeotherteam"]	= cvardef( "scr_tripwire_pick_time_otherteam", 8, 0, 30, "float" );
	game["tripwire"]["jump"] 				= cvardef( "scr_tripwire_jump", 0, 0, 1, "int");
	game["tripwire"]["vanish"] 				= cvardef( "scr_tripwire_vanish", 0, 0, 1, "int");
	game["tripwire"]["vanish_time"]			= cvardef( "scr_tripwire_vanish_time", 120, 1, 99999, "float");

	game["tripwire_team"] = [];
	if( level.teamBased )
	{
		game["tripwire_team"]["axis"] = 0;
		game["tripwire_team"]["allies"] = 0;
	}
	else
	{
		game["tripwire_team"] = 0;
	}

	level.tripwires_array = [];

	game["tripwire"]["pickupmessage"] = &"TRIPWIRE_PICKUP";
	game["tripwire"]["placemessage"] = &"TRIPWIRE_PLACE";

	if( game["tripwire"]["picktimesameteam"] || game["tripwire"]["picktimeotherteam"] )
		game["tripwire"]["pickingUpmessage"] = &"TRIPWIRE_PICKING_UP";
	if( game["tripwire"]["planttime"] )
		game["tripwire"]["placingmessage"] = &"TRIPWIRE_PLACING";

	onPrecache();
	
	level thread onPlayerConnect();
}

onPrecache()
{
	if( !isdefined( game["gamestarted"] ) )
	{
		precacheString( game["tripwire"]["pickupmessage"] );
		precacheString( game["tripwire"]["placemessage"] );
		
		if( game["tripwire"]["picktimesameteam"] || game["tripwire"]["picktimeotherteam"] )
			precacheString( game["tripwire"]["pickingUpmessage"] );
			
		if( game["tripwire"]["planttime"] )
			precacheString( game["tripwire"]["placingmessage"] );

		switch( game["allies"] )
		{
			case "american":
				precacheShader( "gfx/icons/hud@us_grenade_C.tga" );
				precacheShader( "hud_us_grenade_defuse" );
				break;

			case "british":
				precacheShader( "gfx/icons/hud@british_grenade_C.tga" );
				precacheShader( "hud_british_grenade_defuse" );
				break;

			case "russian":
				precacheShader( "gfx/icons/hud@russian_grenade_C.tga" );
				precacheShader( "hud_russian_grenade_defuse" );
				break;
		}
		precacheShader( "gfx/icons/hud@steilhandgrenate_C.tga" );
		precacheShader( "hud_german_grenade_defuse" );

		if( game["tripwire"]["planttime"] || game["tripwire"]["picktimesameteam"] || game["tripwire"]["picktimeotherteam"] )
			precacheShader( "white" );
	}
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );
		
		player.pers["tripwire_count"]  = 0;

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
		
		self thread MonitorTripWires();
		
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

MonitorTripWires()
{
	self endon( "killed_player" );
	self endon( "disconnect" );
	
	if( !self hasPerk( "specialty_weapon_tripwire" ) )
		return;
		
	self.pers["checkdefuse"]["tripwire"] = false;
	self.pers["tripwire_count"] = 2;
	self setClientCvar( "ui_tripwire_count", "[" + self.pers["tripwire_count"] + "]" );
		
	team = self getOwnTeam();
	otherteam = self getOtherTeam( team );
	
	for( ;; )
	{
		myammo	= self.pers["tripwire_count"];
		if( level.tripwire && myammo > 0 && self getStance() == "prone" && !isDefined( self.Explosivesmessage["tripwire"] ) )
			self thread checkTripwirePlacement( team, myammo );

		wait( .05 );
	}
}

CleanupKilled()
{
	if( !level.tripwire ) return;

	if( !self hasPerk( "specialty_weapon_tripwire" ) )
		return;

	self CleanUpMessages();
}

checkTripwirePlacement( team, myammo )
{
	if( !level.tripwire ) return;
	
	sWeapon = undefined;

	self notify( "check_tripwire_placement" );
	self endon( "check_tripwire_placement" );
	
	Y = 365;

	while( isAlive( self ) && self.sessionstate == "playing" && self useButtonPressed() )
		wait( 0.1 );

	if( myammo )
		sWeapon = self getTeamGrenadeType();
		
	perks\_bombsquad::showExplosivesMessage( "tripwire", sWeapon, game["tripwire"]["placemessage"], undefined );

	while( isAlive( self ) && self.sessionstate == "playing" )
	{
		myammo	= self.pers["tripwire_count"];

		if( !myammo ) break;

		if( myammo )
		{
			sWeapon = self getTeamGrenadeType();
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
		vPos1 = trace["position"] + ( 0, 0, 3 );

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
				if( game["tripwire_team"][self.sessionteam] >= game["tripwire"]["limit"] )
				{
					self iprintlnbold( &"TRIPWIRE_MAX_TEAM" );
					self CleanUpMessages();
					return false;
				}
			}
			else
			{
				if( game["tripwire_team"] >= game["tripwire"]["limit"] *2 )
				{
					self iprintlnbold( &"TRIPWIRE_MAX" );
					self CleanUpMessages();
					return false;
				}
			}

			origin = self.origin;
			angles = self.angles;

			if( game["tripwire"]["planttime"] )
				planttime = game["tripwire"]["planttime"];
			else
				planttime = undefined;

			if( isdefined( planttime ) )
			{
				self disableWeapon();
				self playsound("MP_bomb_plant");
				
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
		
					self.plantbar = newClientHudElem( self );				
					self.plantbar.alignX = "left";
					self.plantbar.alignY = "top";
					self.plantbar.x = (320 - (barsize / 2.0));
					self.plantbar.y = Y - 4;
					self.plantbar setShader("white", 0, 8);
					self.plantbar scaleOverTime( bartime , barsize, 8 );

					perks\_bombsquad::showExplosivesMessage( "tripwire", sWeapon, game["tripwire"]["placingmessage"], undefined );
				}

				color = 1;
				for( i=0; i < planttime*20; i++ )
				{
					if( !( self useButtonPressed() && origin == self.origin && isAlive( self ) && self.sessionstate == "playing" && self getStance() == "prone" ) )
						break;
						
					self.plantbar.color = ( 1, color, color);
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
				if( game["tripwire_team"][self.sessionteam] >= game["tripwire"]["limit"] )
				{
					self iprintlnbold( &"TRIPWIRE_MAX_TEAM" );
					return false;
				}
			}
			else
			{
				if( game["tripwire_team"] >= game["tripwire"]["limit"]*2 )
				{
					self iprintlnbold( &"TRIPWIRE_MAX" );
					return false;
				}
			}

			if( level.teamBased )
				game["tripwire_team"][self.sessionteam]++;
			else
				game["tripwire_team"]++;

			x = (vPos1[0] + vPos2[0])/2;
			y = (vPos1[1] + vPos2[1])/2;
			z = (vPos1[2] + vPos2[2])/2;
			vPos = (x,y,z);

			if( myammo )
			{
				self.pers["tripwire_count"]--;
				self setClientCvar( "ui_tripwire_count", "[" + self.pers["tripwire_count"] + "]" );
			}

			// Spawn tripwire
			tripwire = spawn( "script_origin", vPos );
			tripwire.angles = angles;
			tripwire.team = team;
			level.tripwires_array[level.tripwires_array.size] = tripwire;
			tripwire thread monitorTripwire( self, sWeapon, vPos1, vPos2 );
			tripwire thread perks\_bombsquad::bombsquadDetectionTrigger( vPos );
			tripwire maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( tripwire.team, (0,0,20) );
			
			self playsound( "weap_fraggrenade_pin" );
			break;
		}
		
		wait( 0.2 );
	}
	
	self CleanUpMessages();
}

monitorTripwire( owner, sWeapon, vPos1, vPos2 )
{
	level endon( "killthreads" );
	self endon( "monitor_tripwire" );

	wait( 0.05 );

	self.nade1 = spawn( "script_model", vPos1 );
	self.nade1.angles = self.angles;
	self.nade1 setModel( getModelName( sWeapon ) );
	self.nade1.triptype = sWeapon;
	self.nade1.targetname = "tripwire";

	self.nade2 = spawn( "script_model", vPos2 );
	self.nade2.angles = self.angles;
	self.nade2 setModel( getModelName( sWeapon ) );	
	self.nade2.triptype = sWeapon;
	self.nade2.targetname = "tripwire";

	vPos3 = self.origin + vectorScale( anglesToForward( self.angles), 50 );
	vPos4 = self.origin + vectorScale( anglesToForward( self.angles + ( 0,180, 0 ) ), 50 );

	range = distance( self.origin, vPos1 ) + 150;
	range2 = distance( vPos3, vPos1 ) + 2;

	if( isDefined (owner ) && isAlive( owner ) && owner.sessionstate == "playing" )
		owner iprintlnbold( &"TRIPWIRE_ACTIVATES" );

	wait( 5 );

	tripwiretime = getTime();
	
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

			if( distance( self.origin, player.origin ) >= range )
				continue;

			if( game["tripwire"]["jump"] && !player isOnGround() )
				continue;
			
			if( !player.pers["checkdefuse"]["tripwire"] )
				player thread perks\_bombsquad::checkDefuse( "tripwire", self, sWeapon );

			if( distance( vPos3, player.origin ) >= range2 )
				continue;

			if( distance( vPos4, player.origin ) >= range2 )
				continue;

			blow = true;
			break;
		}

		// tripwire life time
		if( game["tripwire"]["vanish"] )
		{
			timepassed = (getTime () - tripwiretime) / 1000;
			
			if( timepassed > game["tripwire"]["vanish_time"] )
			{
				if( level.teamBased )
					game["tripwire_team"][ self.team ]--;
				else
					game["tripwire_team"]--;

				if( isdefined( self.nade1 ) )
					self.nade1 delete ();
				if( isdefined( self.nade2 ) )
					self.nade2 delete ();
				if( isdefined( self.entityHeadIcons ) ) 
					self maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( "none" );

				return;
			}
		}
		
		if( blow ) break;
		wait( 0.05 );
	}

	if( level.teamBased )
		game["tripwire_team"][ self.team ]--;
	else
		game["tripwire_team"]--;

	self.nade1 playsound( "weap_fraggrenade_pin" );
	wait(.05);
	self.nade2 playsound( "weap_fraggrenade_pin" );
	wait(.05);

	wait( randomFloat(.5) );

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

	self.nade1 playsound( "grenade_explode_default" );
	playfx( level._effect["martyrdom_boom"], self.nade1.origin );
	
	self.nade1 scriptedRadiusDamage( eAttacker, (0,0,0), sWeapon, 256, iMaxdamage, iMindamage, (level.tripwire>1) );
	
	wait .05;
	self.nade1 delete();

	wait( randomFloat( .25 ) );

	self.nade2 playsound( "grenade_explode_default" );
	playfx( level._effect["martyrdom_boom"], self.nade2.origin );
	
	self.nade2 scriptedRadiusDamage( eAttacker, (0,0,0), sWeapon, 256, iMaxdamage, iMindamage, (level.tripwire>1) );
	
	wait .05;
	self.nade2 delete();
	
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
	if( isdefined( self.Explosivesmessage["tripwire"] ) )	self.Explosivesmessage["tripwire"] destroy();
	if( isdefined( self.ExplosivesShader["tripwire"] ) ) self.ExplosivesShader["tripwire"] destroy();
}
