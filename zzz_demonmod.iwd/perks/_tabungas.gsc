/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
/***************************************************************************************
 Some of the scipting below is from Merciless mod COD2; Some is from eXtreme+ mod COD2
****************************************************************************************/

#include demon\_utils;

StartTabunGas( grenade, grenadeType )
{
	origin = (0,0,0);
	while( isDefined( grenade ) && origin != grenade.origin )
	{
		origin = grenade.origin;
		wait( 0.1 );
	}

	clone = spawnStruct();
	clone.origin = grenade.origin;
	clone.tabun_effect = playLoopedfx( level._effect["tabungas"], 1, clone.origin );
	
	self thread MonitorTabunGas( grenadeType, clone.origin );
	
	wait 10;
		
	if( isdefined( clone.tabun_effect ) ) 
		clone.tabun_effect delete();
}

MonitorTabunGas( sWeapon, vPoint )
{ 
	self endon( "killed_player" );
	self endon( "disconnect" );

	iDamage = undefined;
	gastime = 15;    
 
	for( j = 0; j <= gastime; j++ ) 
	{ 
		players = getentarray( "player", "classname" ); 
		for( i=0; i < players.size; i++) 
		{ 
			dst = distance( vPoint, players[i].origin ); 
			comboDistance = (dst > 200 + (j * 20));

			if( comboDistance || players[i].sessionstate != "playing" || !isAlive( players[i] ) ) 
				continue;

			pcnt = 200 + (j * 20);
			if( dst > pcnt * .75 ) 
				iDamage = randomint(5);
			else if( dst > pcnt * .5 && dst < pcnt * .75 ) 
				iDamage = 15 + randomint(5);
			else if( dst > pcnt *.25 && dst < pcnt * .5 ) 
				iDamage = 30 + randomint(5);
			else if( dst < pcnt * .25 )
				iDamage = 45 + randomint(5);
					
			iDamage = int( iDamage );
			iDFlags = 1; 
			sMeansOfDeath = "MOD_UNKNOWN";
			sHitLoc = "none";
			psOffsetTime = 0;
			
			players[i] thread tabunShock( comboDistance, iDamage, self );
			
			players[i] thread GasPlayer( self, self, iDamage, iDFlags , sMeansOfDeath , sWeapon, vPoint , undefined, sHitLoc, psOffsetTime ); 
		} 
		
		wait(1); 
	}    
}

GasPlayer( eAttacker, eAttacker, iDamage, iDFlags , sMeansOfDeath , sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ) 
{ 
	self endon( "killed_player" );
	self endon( "disconnect" );
	self endon( "intermission" );

	if( self.health - iDamage <= 0 )
		self finishPlayerDamage( eAttacker, eAttacker, 5, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	else
		self.health = self.health -iDamage;
}

tabunShock( comboDistance, iDamage, eAttacker )
{
	if( !comboDistance )
	{
		self shellshock( "tabungas", 1.3 );
		self PlayGasSound( "choke" );

		if( iDamage > 0 && eAttacker != self )
		{
			hasBodyArmor = false;
			if( self hasPerk( "specialty_armorvest" ) )
			{
				hasBodyArmor = true;
			}

			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
		}
	}
}

PlayGasSound( sound )
{
	self endon( "killed_player" );
	self endon( "disconnect" );

	if( !isDefined( self.gassed ) )
	{
		self.gassed = true;
		self playsound( sound );
	}

	wait( 2 );
	
	if( isAlive( self ) ) 
		self.gassed = undefined;
}