/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

Stick_Satchel( targetpos, grenade, grenadeType )
{
	wait( 0.20 );
	grenade hide();
			
	if( distance( grenade.origin, targetpos ) > 10 )
		grenade delete();
		
	satchel = SpawnStruct();
	satchel.origin = targetpos+(0,0,25);
	satchel = spawn( "script_origin", satchel.origin );
	satchel.angles = self.angles+(40,90,0);
	satchel spawn_model( getModelName( grenadeType ), "satchel_charge", satchel.origin, satchel.angles );
	
	wait( 2.65 );
	
	playFx( level._effect["satchel_effect"], satchel.origin );
	satchel PlaySound( "grenade_explode_default" );
	
	iMaxdamage = 300;
	iMindamage = 100;
	eAttacker = self;
	sWeapon = grenadeType;

	satchel thread scriptedRadiusDamage( eAttacker, (0,0,0), sWeapon, 256, iMaxdamage, iMindamage, false );
	
	satchel deleteFake();
	if( isdefined( satchel ) )
		satchel delete();
}

deleteFake()
{
	fake = getEntArray( "satchel_charge", "targetname" );
	if( isDefined( fake ) )
		for( i=0; i < fake.size; i++ )
			if( distance( self.origin, fake[i].origin ) < 20 )
				fake[i] delete();
}

GetTargetedWall()
{
	startOrigin = self getEye();
	forward = anglesToForward( self.angles );
	forward = maps\mp\_utility::vectorScale( forward, 230 );
	endOrigin = startOrigin + forward;
	
	trace = bulletTrace( startOrigin, endOrigin, false, self );

	if ( trace["fraction"] == 1.0 || trace["surfacetype"] == "default" )
		return ( undefined );
	else
		return ( trace["position"] );
}