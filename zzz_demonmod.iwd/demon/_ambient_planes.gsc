/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

Init()
{
	level.planes 			= cvardef( "scr_demon_ambient_stukas_number", 0, 0, 5, "int" );
	level.planesdelay 		= cvardef( "scr_demon_ambient_stukas_delay", 120, 0, 9999, "int" );
	
	level.planecount = 0;
	
	game["planemodel"] = "xmodel/vehicle_stuka_flying";
	precacheModel( game["planemodel"] );
	
	if( level.planes )
	{	
		thread planes();
	}
	
}

planes()
{
	level endon( "intermission" );
	
	for( ;; )
	{
		wait( level.planesdelay );
		
		planes = level.planes + randomInt(3);
		offset = -2000 + randomInt(4000);
		angle = 90 * randomInt(4);
		for( i=0; i < planes; i++ )
		{
			if( isdefined( level.airStrikeInProgress ) ) continue;
			
			thread PlaneFlyover( offset - (planes * 500) + (i * 1000), angle );
		}
	}
}

PlaneFlyover( offset, angle )
{
	iZ = level.plane_vMax[2];	

	iZstart = iZ + 1000 - randomInt(400);
	iZend 	= iZ + 1000 - randomInt(400);
	
	iYstart = undefined;
	iXstart = undefined;
	iXend = undefined;
	iYend = undefined;
	
	plane = spawn( "script_origin", (0,0,0) );
	plane.angles = ( 10, angle, 0 );
	
	//start plane sound before they see the plane model
	plane thread doPlaneSound();

	// Set X & Y depending on angle
	switch( angle )
	{
		case 0:
			iY 			= int(level.plane_vMax[1] + level.plane_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.plane_vMax[0] - 6000 - randomInt(1000);	
			iXend 		= level.plane_vMax[0] + 6000;
			break;

		case 90:
			iX 			= int(level.plane_vMax[0] + level.plane_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.plane_vMax[1] - 6000 - randomInt(1000);	
			iYend 		= level.plane_vMax[1] + 6000;
			break;

		case 180:
			iY 			= int(level.plane_vMax[1] + level.plane_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.plane_vMax[0] + 6000 + randomInt(1000);	
			iXend 		= level.plane_vMax[0] - 6000;
			break;

		case 270:
			iX 			= int(level.plane_vMax[0] + level.plane_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.plane_vMax[1] + 6000 + randomInt(1000);	
			iYend 		= level.plane_vMax[1] - 6000;
			break;
	}
	
	startpos 	= (iXstart, iYstart, iZstart);
	endpos 		= (iXend, iYend, iZend);
	
	pathStart = startpos + ( (randomfloat(2) - 1), (randomfloat(2) - 1), 0 );
	pathEnd   = endpos   + ( (randomfloat(2) - 1), (randomfloat(2) - 1), 0 );

	planeFlySpeed = 1800;
	d = length( pathStart - pathEnd );
	flyTime = ( d / planeFlySpeed );

	plane.useObj = spawn_model( game["planemodel"], "plane", pathStart, plane.angles );
	plane.useObj hide();
	
	//wait until the plane sound gets going
	wait( 2.25 );
	
	plane.useObj show();

	// move object
	plane.useObj moveto( pathEnd, flyTime, 0, 0 );
	
	wait( flyTime/3 );
	
	// 20% chance that it's going to roll after one third of the flight
	if( !randomInt( 5 ) )
	{
		if( randomInt( 2 ) )
			plane.useObj rotateroll( 360, 4 + randomFloat(3), 1, 1 );
		else
			plane.useObj rotateroll( -360, 4 + randomFloat(3), 1, 1 );
	}
	
	wait( 2*flyTime/3 );
	
	if( isdefined( plane ) ) plane delete();
	if( isdefined( plane.useObj ) ) plane.useobj delete();
	level.planecount = 0;

}

doPlaneSound()
{
	if( level.planecount > 1 )
		return;
		
	if( level.planecount )
		wait( 1.75 );
	
	self playsound( "plane_flyby_stuka" );
	
	level.planecount++;
}