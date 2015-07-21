/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	// Ambient tracers
	level.tracers			= cvardef( "scr_demon_ambient_tracers", 0, 0, 100, "int" );
	level.tracersdelaymin	= cvardef( "scr_demon_ambient_tracers_delay_min", 60, 1, 1440, "int" );
	level.tracersdelaymax	= cvardef( "scr_demon_ambient_tracers_delay_max", 120, level.tracersdelaymin + 1, 1440, "int" );
	
	level._effect["tracers"] = loadfx( "fx/misc/antiair_tracers.efx" );
	
	level.tracer_soundCount = 0;
	
	if( level.tracers )
		for( i = 0; i < level.tracers; i++ )
			thread tracers();
}

tracers()
{
	level endon( "intermission" );

	iy = undefined;
	ix = undefined;
	iz = undefined;

	delay = level.tracersdelaymin + randomint( level.tracersdelaymax - level.tracersdelaymin );
	
	wait( delay );
	
	iSide = randomInt( 4 );	
	switch( iSide )
	{
		case 0:
			ix = level.demon_playAreaMax[0]-1000;
			iy = level.demon_playAreaMax[1] + randomfloat( level.demon_playAreaMax[1] - level.demon_playAreaMin[1] );
			break;

		case 1:
			ix = level.demon_playAreaMax[0]-1200;
			iy = level.demon_playAreaMax[1] + randomfloat( level.demon_playAreaMax[1] - level.demon_playAreaMin[1] );
			break;
				
		case 2:
			ix = level.demon_playAreaMax[0] -1300 + randomfloat( level.demon_playAreaMax[0] - level.demon_playAreaMin[0] );
			iy = level.demon_playAreaMax[1];
			break;
		
		case 3:
			ix = level.demon_playAreaMax[0] -1500 + randomfloat( level.demon_playAreaMax[0] - level.demon_playAreaMin[0] );
			iy = level.demon_playAreaMax[1];
			break;
	}

	iz = level.demon_playAreaMin[2] - 100;
	
	tracer = SpawnStruct();
	tracer.origin = (ix, iy, iz);
	tracer.fx = playLoopedfx( level._effect["tracers"], delay, tracer.origin );
	
}

