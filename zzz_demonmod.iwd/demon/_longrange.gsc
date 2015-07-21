#include demon\_utils;
#include maps\mp\_utility;

init()
{
	level.longrange_sniper 	= cvardef( "scr_demon_longrange_sniper", 0, 0, 1,"int" );
	level.maxbulletrange = cvardef( "scr_demon_longrange_sniper_range", 10000, 0, 40000, "int" ); // sets max range of the scripted bullet in game units
	level.bulletdamage = cvardef( "scr_demon_longrange_sniper_damage", 50, 0, 100, "int" ); // sets damage of the bullet
}

waitforsniperfire()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !level.longrange_sniper ) return;
	
	for( ;; )
	{
		self waittill( "begin_firing" );

		if( self playerADS() < 1.0 )
			continue;

		weap = self getcurrentweapon();
		if( !isSniperRifle( weap ) )
			continue;

		start = self getEye();
		end = start + vectorScale( anglestoforward( self getPlayerAngles() ), level.maxbulletrange );
		trace = bulletTrace( start, end, true, self );

		if( !isDefined( trace["entity"] ) )
			continue;

		if( trace["entity"].classname != "player" )
			continue;

		trace["entity"] thread [[level.callbackPlayerDamage]]( self, self, level.bulletdamage, 0, "MOD_RIFLE_BULLET", weap, trace["position"], VectorNormalize( trace["position"] - self.origin ), "none", 0 );
	}
}
