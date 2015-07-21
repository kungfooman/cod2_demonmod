#include demon\_utils;

init()
{
	if( !init_mapConfig() )
	{
		printLn( "^1No Start Spawns found in Level!" );
		level.startSpawns = false;
		return;
	}
}

init_mapConfig()
{
	startspawns = [];
	number = 0;
	
	filename = undefined;
	if( level.native )
		filename = "stock_startspawns.ini";
	else
		filename = "custom_startspawns.ini";
	
	file = OpenFile( filename, "read" );
	
	if( file == -1 )
		return( false );
	
	currentmap = false;
	for( ;; )
	{
		elems = freadln( file );
		
		if( elems == -1 )
			break;
			
		if( elems == 0 )
		{
			currentmap = false;
			continue;
		}
	
		line = "";
		for( pos = 0; pos < elems; pos++ )
		{
			line = line + fgetarg( file, pos );
			if( pos < elems - 1 )
				line = line + ",";
		}
		
		if( getSubStr( line, 0, 2 ) == "//" || getSubStr( line, 0, 1 ) == "#" )
			continue;
			
		array = strtok( line, " " );

		if( array[0] == getcvar( "mapname" ) )
		{
			currentmap = true;
			continue;
		}
		
		if( currentmap )
		{
			switch( array[0] )
			{
				case "startspawns":
					team = array[1];
					origin_str = getsubstr( array[2], 1 );
					origin_array = strtok( origin_str, "," );
					origin = ( int( origin_array[0] ), int( origin_array[1] ), int( origin_array[2] ) );
					startspawns[number] = spawn( "script_origin", origin );
					startspawns[number].origin = origin;
					startspawns[number].angles = ( 0, int( array[3] ), 0 );
					startspawns[number].team = team;
					startspawns[number].targetname = "mp_spawn_" + team + "_start";
					defineStartSpawnsArray( startspawns[number] );
					number++;
					break;

				default:
					break;
			}
		}
	}
	
	CloseFile( file );
	
	if( !startspawns.size )
		return( false );
	
	return( true );
}

defineStartSpawnsArray( spawnpoint )
{	
	if( !isdefined( level.startSpawnpoints ) )
		level.startSpawnpoints = [];
		
	if( !isdefined( level.startSpawnpoints[spawnpoint.targetname] ) )
		level.startSpawnpoints[spawnpoint.targetname] = [];
		
	level.startSpawnpoints[spawnpoint.targetname][ level.startSpawnpoints[spawnpoint.targetname].size ] = spawnpoint;
}



