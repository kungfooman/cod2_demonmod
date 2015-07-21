/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;
#include maps\mp\_utility;

init()
{
	level.amb_mortars = cvardef( "scr_demon_ambient_mortars", 0, 0, 15, "int" );

	if( !level.amb_mortars ) 
		return;

	level.mortar_quake 		= cvardef( "scr_demon_ambient_mortars_quake", 1, 0, 1, "int" );
	level.mortar_random 	= cvardef( "scr_demon_ambient_mortars_random", 0, 0, 1, "int" );
	level.mortar_safety 	= cvardef( "scr_demon_ambient_mortars_safety", 1, 0, 1, "int" );
	level.mortar_delay_min 	= cvardef( "scr_demon_ambient_mortars_delay_min", 15, 5, 179, "int" );
	level.mortar_delay_max 	= cvardef( "scr_demon_ambient_mortars_delay_max", 70, level.mortar_delay_min+1, 180, "int" );


	// Set up mortar sounds
	level.mortars = [];
	level.mortars[level.mortars.size]["incoming"] = "mortar_incoming2";
	level.mortars[level.mortars.size-1]["delay"] = 0.65;
	level.mortars[level.mortars.size]["incoming"] = "mortar_incoming1";
	level.mortars[level.mortars.size-1]["delay"] = 1.05;
	level.mortars[level.mortars.size]["incoming"] = "mortar_incoming3";
	level.mortars[level.mortars.size-1]["delay"] = 1.5;
	level.mortars[level.mortars.size]["incoming"] = "mortar_incoming4";
	level.mortars[level.mortars.size-1]["delay"] = 2.1;
	level.mortars[level.mortars.size]["incoming"] = "mortar_incoming5";
	level.mortars[level.mortars.size-1]["delay"] = 3.0;

	// load effects
	level.mortarfx["sand"] 		= loadfx("fx/explosions/mortarExp_beach.efx");
	level.mortarfx["snow"]		= loadfx("fx/explosions/large_snow_explode1.efx");
	level.mortarfx["concrete"]	= loadfx("fx/explosions/mortarExp_concrete.efx");
	level.mortarfx["dirt"] 		= loadfx("fx/explosions/mortarExp_dirt.efx");
	level.mortarfx["generic"] 	= loadfx("fx/explosions/mortarExp_mud.efx");
	level.mortarfx["grass"] 	= loadfx("fx/explosions/artilleryExp_grass.efx");
	
	thread StartThreads();
}

StartThreads()
{
	wait .05;

	level endon("killthreads");

	for(i = 0; i < level.amb_mortars; i++)
		thread incoming();

}

incoming()
{
	level endon( "intermission" );

	maxz = level.demon_vMax[2];	

	surfaces = [];
	surfaces[surfaces.size] = "concrete";
	surfaces[surfaces.size] = "dirt";
	surfaces[surfaces.size] = "generic";
	surfaces[surfaces.size] = "grass";
	surfaces[surfaces.size] = "sand";

	// Init some local variables
	endorigin = (0,0,0);
	m = 0;
	pc = 0;
	x = 0;
	y = 0;
	trace = [];
	surface = "generic";

	for( ;; )
	{
		range = int( level.mortar_delay_max - level.mortar_delay_min );
		delay = randomInt( range );
		delay = level.mortar_delay_min + delay;

		wait( delay );
		
		if( isdefined( level.artillerystrikeInProgress ) || isdefined( level.airstrikeInProgress ) ) 
			continue;

		mortar = spawn( "script_model", (0,0,0) );

		m = randomInt( level.mortars.size );

		pc = randomInt( 100 );

		range = int( 200 + pc*360*0.01 );
		distance = -1;

		while( distance < ( level.mortar_safety * range * 2) )
		{
			All_players = getEntArray( "player", "classname" );
			players = [];
			for( i=0; i < All_players.size; i++ )
				if( isdefined( All_players[i] ) )
					if( All_players[i].sessionstate == "playing" )
						players[ players.size ] = All_players[i];
	
			if( !level.mortar_random && players.size )
			{
				p = randomInt( players.size );		
				angle = (0,randomInt(360),0);
				vector = anglesToForward(angle);
				variance = maps\mp\_utility::vectorScale( vector, range*level.mortar_safety*2 + randomInt( range*3 ) );
				endorigin = players[p].origin + variance;
			}
			else
			{
				x = level.demon_vMin[0] + randomInt( int( level.demon_vMax[0] - level.demon_vMin[0] ) );
				y = level.demon_vMin[1] + randomInt( int( level.demon_vMax[1] - level.demon_vMin[1] ) );
				z = level.demon_vMin[2];
				endorigin = (x,y,z);
			}

			trace = bulletTrace( ( endorigin[0], endorigin[1], maxz ), ( endorigin[0], endorigin[1], level.demon_vMin[2] ), false, undefined );
			endorigin = trace["position"];

			if( level.mortar_safety && players.size )
			{
				bplayers = sortByDist( players, mortar );
				distance = distance( endorigin, bplayers[0].origin );
			}
			else
				break;

			wait( 0.2 ); 
		}

		surface = trace["surfacetype"];

		startpoint = ( ( endorigin[0] - 200 + randomInt(400)) , (endorigin[1] - 200 + randomInt(400) ), maxz);

		mortar.origin = startpoint;
		mortar.angles = vectortoangles( vectornormalize( endorigin-(800,0,0) - startpoint ) );
		mortar.shell = spawn_model( level.bombModel, "mortar", mortar.origin+(800,0,0), mortar.angles );
		mortar.shell hide();
		
		wait 0.05;
		mortar playsound( level.mortars[m]["incoming"] );
		wait level.mortars[m]["delay"] - 0.05;
		
		shellSpeed = 40;
		shellInAir = calcTime( startpoint, endorigin, shellSpeed );

		mortar.shell show();
		mortar moveto( endorigin, shellInAir );
		mortar.shell moveto( endorigin, shellInAir );

		wait( shellInAir );

		if( !isdefined( level.mortarfx[ surface ] ) )
		{
			if( level.wintermap )
				surface = "snow";
			else
				surface = surfaces[ randomInt( surfaces.size ) ];
		}

		playfx( level.mortarfx[surface], endorigin );

		mortar playsound( "mortar_explosion" + ( randomInt(5) + 1 ) );

		if( !level.mortar_safety )
		{
			max = 200 + 200*pc*0.01;
			min = 10;
			radiusDamage( endorigin + (0,0,12), range, max, min );
		}

		if( level.mortar_quake )
		{
			strength = 0.5 + 0.5 * pc * 0.01;
			length = 1 + 3*pc*0.01;
			range = int(600 + 600*pc*0.01);
			earthquake( strength, length, endorigin, range ); 
		}

		mortar delete();
		if( isdefined( mortar.shell ) ) mortar.shell delete();
	}
}
