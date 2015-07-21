/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	
	level.firstaid	= level.perk_allow_firstaid;
	
	level.fullhealth = level.player_maxhealth;
	
	level.firstaid_shock 	= cvardef( "scr_demon_firstaid_healing_shock", 1, 0, 1, "int" );
	level.firstaidkits 		= cvardef( "scr_demon_firstaidkits", 5, 0, 5, "int" );
	level.minheal 			= cvardef( "scr_demon_minheal", 40, 1, level.fullhealth - 1, "int" );	
	level.maxheal 			= cvardef( "scr_demon_maxheal", level.minheal + 1, level.minheal + 1, level.fullhealth, "int" );	
	level.medicself 		= cvardef( "scr_demon_medicself", 1, 0, 1, "int" );
	level.firstaidkitmsg 	= cvardef( "scr_demon_firstaidkitmsg", 1, 0, 1, "int" );
	level.showinjp 			= cvardef( "scr_demon_showinjp", 0, 0, 1, "int" );
	level.showinjptime 		= cvardef( "scr_demon_showinjptime", 5, 3, 60, "float" );
	level.firstaidmsg 		= cvardef( "scr_demon_firstaidmsg", 1, 0, 3, "int" );
	level.firstaidpickup 	= cvardef( "scr_demon_firstaidpickup", 3, 0, 5, "int" );

}

monitorFirstAid()
{
	level endon( "intermission" );
	self endon( "disconnect" );
	self endon( "death" );	

	if( level.regen || !level.firstaid )
		return;
		
	if( !self hasPerk( "specialty_firstaid" ) )
		return;

	self.canheal = true;
	self.targetplayer = undefined;

	while( isPlayer( self ) && self.sessionstate != "spectator" && self hasPerk( "specialty_firstaid" ) )
	{
		wait 0.5;

		if( isPlayer( self ) && self useButtonPressed() && self isOnGround() && self.canheal && !isdefined( self.isSprinting ) )
		{	
			players = getEntArray( "player", "classname" );
			for(i = 0; i < players.size; i++)
			{
				if( level.medicself == 0 )
				{
					if( players[i] == self )
						continue;	// can't heal yourself
				}

				if( players[i].pers["team"] == self.pers["team"] && isalive( players[i] ) && players[i].health <= level.fullhealth - 1 && !isDefined( players[i].gettingfirstaid ) 
				&& distance( players[i].origin, self.origin ) < 48 )
				{
					if( !level.teambased )
					{
						if( players[i] == self && level.medicself != 0 ) 
						{
							self.targetplayer = players[i];
							break;
						}
					}
					else
					{
						self.targetplayer = players[i];
						break;
					}					
				}
			}
			
			if( !isDefined( self.targetplayer) ) continue;

			holdtime = 0;

			while( isPlayer( self ) && self useButtonPressed() && holdtime < 1 && self isOnGround() && self.targetplayer isOnGround() && distance( self.targetplayer.origin, self.origin ) < 50 && !isdefined( self.isSprinting ) )
			{
				holdtime += 0.05;
				wait 0.05;
			}

			if( holdtime < 1 ) continue;

			if( isPlayer( self ) && self.firstaidkits > 0 )
			{
				if( level.gametype == "sd" && self.isPlanting )
					continue;
	
				if( self.targetplayer.health == level.fullhealth ) continue;
	
				self.targetplayer.needshealing = false;
		
 				healamount = ( level.minheal + randomInt( level.maxheal - level.minheal ) );
				healtime = (int(healamount / 2) * .1 );
				
				if( level.firstaid_shock ) self.targetplayer shellshock( "default", 4 );
					self disableWeapon();
		
				healnow = 0;
				holdtime = 0;
	
				while( self useButtonPressed()							// still holding the USE key
				&& !(self meleeButtonPressed())							// player hasn't melee'd
				&& !(self.targetplayer meleeButtonPressed() )			// target hasn't melee'd
				&& !(self attackButtonPressed())						// player hasn't fired
				&& !( self.targetplayer attackButtonPressed() )			// target hasn't fired
				&& isalive( self ) && isalive( self.targetplayer ) 		// both still alive
				&& self.targetplayer.health < level.fullhealth			// hasn't filled target's health
				&& healamount > 0										// hasn't run out of healamount
				)
				{	
					if( healnow == 1 )
					{
						self.targetplayer.health++;	 					// 10 health per second, 1 point every other 1/20th of a second (server frame) had to do that 'cause of integer rounding issues
						healamount--;
						healnow = -1;
	
						self.ishealing = true;
					}
	
					healnow++;
					holdtime += 0.05;
					wait 0.05;
				}
	
				if( isDefined( self.ishealing ) ) self.ishealing = undefined;
	
				if( isalive( self ) && isalive( self.targetplayer ) && ( healamount == 0 || self.targetplayer.health == level.fullhealth ) )
				{
					if( level.firstaidmsg > 0 )
					{
						if( self.name == self.targetplayer.name )
							iprintln( &"FIRSTAID_ISUSING", self.name );
						else
							iprintln( &"FIRSTAID_FIXEDUP", self.targetplayer, self.name );
					}
				
				}
			}
			
			if( self.firstaidkits > 0 )
			{
				self.firstaidkits--;
				self setClientCvar( "cg_player_firstaid_value", self.firstaidkits );
			}
				
			self enableWeapon();
	
			wait 0.5;

			if( isPlayer( self ) )
			{				
				if( self.firstaidkits == 0 ) self.canheal = false;
		
				if( level.firstaidkitmsg )
				{
					if( self.firstaidkits >= 2 ) self iprintlnbold( &"FIRSTAID_NUMBER_LEFT", self.firstaidkits );
					else if( self.firstaidkits == 1 ) self iprintlnbold( &"FIRSTAID_NUMBER_ONE" );
					else if( self.firstaidkits == 0 ) self iprintlnbold( &"FIRSTAID_NUMBER_ZERO" );
				}
				
				if( isDefined( self.spamdelay ) ) self.spamdelay = undefined;
			}
		}
	}
}

CleanUp()
{
	if( isDefined( self.firstaidval ) ) self.firstaidval destroy();
	if( isDefined( self.firstaidicon) ) self.firstaidicon destroy();
	self deleteHudTextElementbyName( "firstaid_hint" );
}

