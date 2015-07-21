/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

StartMarty( attacker )
{
	if( !self hasPerk( "specialty_grenadepulldeath" ) )
		return;

	grenade = spawn( "script_origin", self.origin );
	grenade.angles = self.angles;
	grenade.origin = self.origin;
	fake = spawn_weapon( "marty_grenade_mp", "fake_grenade", grenade.origin+(0,0,20), grenade.angles, 2 );
		
	grenade thread createWaypoint( "hud_grenadeicon" );
	grenade thread waitforplayers( attacker );
		
	grenade thread explode( self );
	grenade playsound( "weap_fraggrenade_pin" );
}

explode( eAttacker )
{
	wait 3;
	
	playfx( level._effect["martyrdom_boom"], self.origin );	
	self playSound( "grenade_explode_default");
	
	iMaxdamage = 200;
	iMindamage = 50;

	self scriptedRadiusDamage( eAttacker, (0,0,0), "marty_grenade_mp", 256, iMaxdamage, iMindamage, false );
	
	self deleteWaypoint();
	self thread deleteFake();
	if( isDefined( self ) )
		self delete();
	
}

deleteFake()
{
	fake = getEntArray( "fake_grenade", "targetname" );
	if( isDefined( fake ) )
		for( i=0; i < fake.size; i++ )
			if( distance( self.origin, fake[i].origin ) < 40 )
				fake[i] delete();
}

createWaypoint( shader )
{		
	if( isdefined( self.marty_waypoint ) ) 
		self.marty_waypoint destroy();

	self.marty_waypoint = newHudElem();
	self.marty_waypoint.x = self.origin[0];
	self.marty_waypoint.y = self.origin[1];
	self.marty_waypoint.z = self.origin[2] + 55;
	self.marty_waypoint.alpha = 0;
	self.marty_waypoint.isShown = true;
	self.marty_waypoint.isFlashing = false;
	self.marty_waypoint.baseAlpha = .9;
	self.marty_waypoint setShader( shader, 7, 7 );
	self.marty_waypoint setwaypoint( true, shader );
}

deleteWaypoint()
{
	self HaltFlashing();
	
	if( isdefined( self.marty_waypoint ) ) 
		self.marty_waypoint destroy();
}

waitforplayers( attacker )
{
	self endon( "death" );
	
	while( isDefined( self ) )
	{
		if( distance( self.origin, attacker.origin ) < 150 )
			self thread startFlashing();
		else
			self thread HaltFlashing();
		
		wait( 0.05 );
	}
}

HaltFlashing()
{
	self thread stopFlashing();
	self notify( "stop_flashing_thread" );
	self.marty_waypoint.alpha = 0;
}

startFlashing()
{
	self endon( "stop_flashing_thread" );
	
	if( self.marty_waypoint.isFlashing )
		return;
	
	self.marty_waypoint.isFlashing = true;
	
	while( self.marty_waypoint.isFlashing )
	{
		self.marty_waypoint fadeOverTime( 0.75 );
		self.marty_waypoint.alpha = 0.35 * self.marty_waypoint.baseAlpha;
		wait ( 0.35 );
		
		self.marty_waypoint fadeOverTime( 0.75 );
		self.marty_waypoint.alpha = self.marty_waypoint.baseAlpha;
		wait ( 0.35 );
	}
	
	self.marty_waypoint.alpha = self.marty_waypoint.baseAlpha;
}

stopFlashing()
{
	if ( !self.marty_waypoint.isFlashing )
		return;

	self.marty_waypoint.isFlashing = false;
}


