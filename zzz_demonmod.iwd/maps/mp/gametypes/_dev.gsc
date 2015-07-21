#include maps\mp\_utility;

init()
{
	/#
	if( getCvar( "scr_showspawns") == "" )
		setCvar( "scr_showspawns", "0" );

	if( getCvar( "scr_showstartspawns") == "" )
		setCvar( "scr_showstartspawns", "0" );

	for( ;; )
	{
		updateDevSettings();
		wait( 0.05 );
	}
	#/
}

/#
updateDevSettings()
{
	showspawns = getCvarInt( "scr_showspawns" );
	if( showspawns > 1 )
		showspawns = 1;
	else if( showspawns < 0 )
		showspawns = 0;
	
	if( !isdefined( level.showspawns ) || level.showspawns != showspawns )
	{
		level.showspawns = showspawns;
		setCvar( "scr_showspawns", level.showspawns );

		if( level.showspawns )
			showSpawnpoints();
		else
			hideSpawnpoints();
	}

	showStartSpawns = getCvarInt( "scr_showstartspawns" );
	if( showStartSpawns > 1 )
		showStartSpawns = 1;
	else if( showStartSpawns < 0 )
		showStartSpawns = 0;

	if( !isDefined( level.show_start_spawns) || level.show_start_spawns != showStartSpawns )
	{
		level.show_start_spawns = showStartSpawns;
		setCvar( "scr_showstartspawns", level.show_start_spawns );

		if( level.show_start_spawns )
			showStartSpawnpoints();
		else
			hideStartSpawnpoints();
	}
	
}

showSpawnpoints()
{
	if( IsDefined( level.spawnpoints ) )
	{
		// show standard spawn points
		color = (1, 1, 1);
		for( index= 0; index < level.spawnpoints.size; index++ )
		{
			showOneSpawnPoint( level.spawnpoints[index], color, "hide_spawnpoints" );
		}
	}
	
	return;
}

hideSpawnpoints()
{
	level notify( "hide_spawnpoints" );
	
	return;
}

showStartSpawnpoints()
{
	if( isDefined( level.spawn_axis_start ) )
	{
		color = (1, 0, 1);
		for( index= 0; index < level.spawn_axis_start.size; index++)
		{
			showOneSpawnPoint( level.spawn_axis_start[index], color, "hide_startspawns" );
		}
	}
	
	if( isDefined( level.spawn_allies_start ) )
	{
		color = (0, 1, 1);
		for( index= 0; index < level.spawn_allies_start.size; index++ )
		{
			showOneSpawnPoint( level.spawn_allies_start[index], color, "hide_startspawns" );
		}
	}
	
	return;
}

hideStartSpawnpoints()
{
	level notify( "hide_startspawns" );
	
	return;
}

showOneSpawnPoint( spawn_point, color, notification )
{
	player_height = get_player_height();
	center = spawn_point.origin;
	forward = anglestoforward( spawn_point.angles );
	right = anglestoright( spawn_point.angles );

	forward = vectorScale( forward, 16 );
	right = vectorScale( right, 16 );

	a = center + forward - right;
	b = center + forward + right;
	c = center - forward + right;
	d = center - forward - right;
	
	thread lineUntilNotified( a, b, color, 0, notification );
	thread lineUntilNotified( b, c, color, 0, notification );
	thread lineUntilNotified( c, d, color, 0, notification );
	thread lineUntilNotified( d, a, color, 0, notification );

	thread lineUntilNotified( a, a + (0, 0, player_height), color, 0, notification );
	thread lineUntilNotified( b, b + (0, 0, player_height), color, 0, notification );
	thread lineUntilNotified( c, c + (0, 0, player_height), color, 0, notification );
	thread lineUntilNotified( d, d + (0, 0, player_height), color, 0, notification );

	a = a + ( 0, 0, player_height );
	b = b + ( 0, 0, player_height );
	c = c + ( 0, 0, player_height );
	d = d + ( 0, 0, player_height );
	
	thread lineUntilNotified( a, b, color, 0, notification );
	thread lineUntilNotified( b, c, color, 0, notification );
	thread lineUntilNotified( c, d, color, 0, notification );
	thread lineUntilNotified( d, a, color, 0, notification );

	center = center + (0, 0, player_height/2);
	arrow_forward = anglestoforward( spawn_point.angles );
	arrowhead_forward = anglestoforward( spawn_point.angles );
	arrowhead_right = anglestoright( spawn_point.angles );

	arrow_forward = vectorScale( arrow_forward, 32 );
	arrowhead_forward = vectorScale( arrowhead_forward, 24 );
	arrowhead_right = vectorScale( arrowhead_right, 8 );
	
	a = center + arrow_forward;
	b = center + arrowhead_forward - arrowhead_right;
	c = center + arrowhead_forward + arrowhead_right;
	
	thread lineUntilNotified( center, a, color, 0, notification );
	thread lineUntilNotified( a, b, color, 0, notification );
	thread lineUntilNotified( a, c, color, 0, notification );
	
	if( isSubStr( notification, "startspawns" ) )
		thread print3DUntilNotified( spawn_point.origin + (0, 0, player_height), spawn_point.targetname, color, 1, 1, notification );
	else
		thread print3DUntilNotified( spawn_point.origin + (0, 0, player_height), spawn_point.classname, color, 1, 1, notification );
	
	return;
}

lineUntilNotified( start, end, color, depthTest, notification )
{
	level endon( notification );
	
	for( ;; )
	{
		line( start, end, color, depthTest );
		wait( 0.05 );
	}
}

print3DUntilNotified( origin, text, color, alpha, scale, notification )
{
	level endon( notification );
	
	for( ;; )
	{
		print3d( origin, text, color, alpha, scale );
		wait( .05 );
	}
}

get_player_height()
{
	return 70.0; // inches, see bg_pmove.cpp::playerMins/playerMaxs
}

#/