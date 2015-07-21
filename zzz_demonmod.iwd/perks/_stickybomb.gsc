/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

Sticky( targetpos, grenade, grenadeType )
{
	wait( 0.20 );
	grenade hide();
			
	if( distance( grenade.origin, targetpos ) > 10 )
		grenade delete();
		
	sticky = SpawnStruct();
	sticky.origin = targetpos;
	sticky = spawn( "script_origin", sticky.origin );
	sticky.angles = self.angles+(0,0,40);
	sticky spawn_model( getModelName( grenadeType ), "sticky_bomb", sticky.origin, sticky.angles );
	
	wait( 2.65 );
	
	playFx( level._effect["stickybomb"], sticky.origin );
	sticky PlaySound( "grenade_explode_default" );
	
	iMaxdamage = 230;
	iMindamage = 70;
	eAttacker = self;
	sWeapon = grenadeType;

	sticky thread scriptedRadiusDamage( eAttacker, (0,0,0), sWeapon, 256, iMaxdamage, iMindamage, false );
	
	sticky deleteFake();
	if( isdefined( sticky ) )
		sticky delete();
}

deleteFake()
{
	fake = getEntArray( "sticky_bomb", "targetname" );
	if( isDefined( fake ) )
		for( i=0; i < fake.size; i++ )
			if( distance( self.origin, fake[i].origin ) < 20 )
				fake[i] delete();
}

GetTargetedWall()
{
	startOrigin = self getEye() + (0,0,25);
	forward = anglesToForward( self.angles );
	forward = maps\mp\_utility::vectorScale( forward, 230 );
	endOrigin = startOrigin + forward;
	
	trace = bulletTrace( startOrigin, endOrigin, false, self );

	if ( trace["fraction"] == 1.0 || trace["surfacetype"] == "default" )
		return ( undefined );
	else
		return ( trace["position"] );
}


