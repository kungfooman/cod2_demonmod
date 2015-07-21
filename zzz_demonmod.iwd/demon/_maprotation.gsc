/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
/*********************************************
	ORIGINAL CODE BY BELL FOR vCOD/UO
**********************************************/

#include demon\_utils;

init()
{
	level.fixmaprotation 		= cvardef( "scr_demon_fix_maprotation", 0, 0, 1, "int" );	
	level.randommaprotation 	= cvardef( "scr_demon_random_maprotation", 0, 0, 2, "int" );	
	level.rotateifempty 		= cvardef( "scr_demon_rotate_if_empty", 0, 0, 1800, "int" );
	level.fallbackgametypemap 	= cvardef( "scr_demon_fallback_gametype_map", "war mp_backlot", "", "", "string" );
	
	if( !isdefined( game["emptytime"] ) )	game["emptytime"] = 0;

	FixMapRotation();

	thread StartThreads();
}

StartThreads()
{	
	wait( 0.05 );

	thread RandomMapRotation();

	if( level.rotateifempty ) 
		thread RotateIfEmpty();
}

RandomMapRotation()
{
	if(!level.randommaprotation || level.mapvote)
		return;

	if( strip( getcvar( "sv_maprotationcurrent" ) ) == "" || level.randommaprotation == 1 )
	{
		maps = undefined;
		x = GetRandomMapRotation();
		if( isdefined( x ) )
		{
			if( isdefined( x.maps ) )
				maps = x.maps;
			x delete();
		}

		if( !isdefined(maps) || !maps.size )
			return;
			
		lastgt = "";
		newmaprotation = "";
		
		for( i = 0; i < maps.size; i++ )
		{
			if( !isdefined( maps[i]["gametype"] ) || lastgt == maps[i]["gametype"] )
				gametype = "";
			else
			{
				lastgt = maps[i]["gametype"];
				gametype = " gametype " + maps[i]["gametype"];	
			}
			
			temp = gametype + " map " + maps[i]["map"];
			if( (newmaprotation.size + temp.size) > 975 )
			{
				iprintlnbold( "Maprotation: ^1Limiting sv_maprotation to avoid server crash! String1 size:" + newmaprotation.size + " String2 size:" + temp.size );
				break;
			}
			newmaprotation += temp;
		}

		setCvar( "sv_maprotationcurrent", newmaprotation );

		setCvar( "random_maprotation", "2" );
	}
}

FixMapRotation()
{	
	if( !level.fixmaprotation || level.mapvote )
		return;

	maps = undefined;
	
	x = GetPlainMapRotation();
	
	if( isdefined( x ) )
	{
		if( isdefined( x.maps ) )
			maps = x.maps;
		x delete();
	}

	if( !isdefined(maps) || !maps.size )
		return;

	newmaprotation = "";
	newmaprotationcurrent = "";
	
	for( i = 0; i < maps.size; i++ )
	{
		if( !isdefined( maps[i]["gametype"] ) )
			gametype = "";
		else
			gametype = " gametype " + maps[i]["gametype"];

		temp = gametype + " map " + maps[i]["map"];
		if( ( newmaprotation.size + temp.size ) > 975 )
		{
			iprintlnbold( &"DEMON_FIXMAPROT_LIMITING" );
			break;
		}
		newmaprotation += temp;

		if( i>0 )
			newmaprotationcurrent += gametype + " map " + maps[i]["map"];
	}

	setCvar( "sv_maprotation", strip( newmaprotation ) );
	setCvar( "sv_maprotationcurrent", newmaprotationcurrent );
	setCvar( "fix_maprotation", "0" );
}

RotateIfEmpty()
{
	level endon( "game_ended" );

	while( game["emptytime"] < level.rotateifempty )
	{
		wait( 1 );
		
		playercount = 0;
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			if( isDefined( players[i].pers["team"] ) && players[i].sessionstate == "playing" ) 
				playercount++;
		}

		if( playercount >= 1 )
			game["emptytime"] = 0;
		else
			game["emptytime"]++;
		
	}
	
	setCvar( "g_gametype", level.gametype );
	exitLevel( false );
}

/////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// UTILITIES /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

GetPlainMapRotation( number )
{
	return GetMapRotation( false, false, number );
}

GetRandomMapRotation()
{
	return GetMapRotation( true, false, undefined );
}

GetCurrentMapRotation( number )
{
	return GetMapRotation( false, true, number );
}

GetMapRotation( random, current, number )
{
	level endon( "game_ended" );
	
	maprot = "";

	if( !isdefined( number ) )
		number = 0;

	if( current )
		maprot = strip( getCvar( "sv_maprotationcurrent" ) );

	if( maprot == "" ) maprot = strip( getCvar( "sv_maprotation" ) );

	if( maprot == "" )
		return undefined;

	j = 0;
	temparr2[j] = "";	
	for( i=0; i < maprot.size; i++ )
	{
		if( maprot[i] == " " )
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	// Remove empty elements (double spaces)
	temparr = [];
	for( i=0; i < temparr2.size; i++ )
	{
		element = strip( temparr2[i] );
		if(element != "")
		{
			temparr[temparr.size] = element;
		}
	}

	// Spawn entity to hold the array
	x = spawn( "script_origin", (0,0,0) );

	x.maps = [];
	
	lastgt = level.gametype;
	temp = undefined;
	
	for( i=0; i < temparr.size; )
	{
		switch( temparr[i] )
		{
			case "gametype":
				if( isdefined( temparr[i+1] ) )
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if( isdefined( temparr[i+1] ) )
				{
					x.maps[x.maps.size]["temp"]	= temp;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i+1];
				}
				// Only need to save this for random rotations
				if( !random )
				{
					lastgt = undefined;
					temp = undefined;
				}

				i += 2;
				break;

			// If code get's to here, then the maprotation is corrupt so we have to fix it
			default:
				iprintlnbold( "Demon mod: Error in Map Rotation" );
	
				if( isGametype( temparr[i] ) )
					lastgt = temparr[i];
				else
				{
					x.maps[x.maps.size]["temp"]	= temp;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i];
	
					// Only need to save this for random rotations
					if( !random )
					{
						lastgt = undefined;
						temp = undefined;
					}
				}

				i += 1;
				break;
		}
		
		if( number && x.maps.size >= number )
			break;
	}

	if( random )
	{
		// Shuffle the array 20 times
		for( k = 0; k < 20; k++ )
		{
			for(i = 0; i < x.maps.size; i++)
			{
				j = randomInt( x.maps.size );
				element = x.maps[i];
				x.maps[i] = x.maps[j];
				x.maps[j] = element;
			}
		}
	}

	return x;
}

isGametype( gt )
{
	switch( gt )
	{
		case "dm":
		case "tdm":
		case "sd":
		case "hq":
		case "ctf":
		case "kconf":
		case "dom":
		case "re":
			return true;

		default:
			return false;
	}
}

getGametypeName( gt )
{
	switch( gt )
	{	
		case "dm":
			gtname = "Deathmatch";
			break;
		
		case "tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
			gtname = "Search & Destroy";
			break;

		case "hq":
			gtname = "Headquarters";
			break;

		case "ctf":
			gtname = "Capture the Flag";
			break;
			
		case "kconf":
			gtname = "Kill Confirmed";
			break;

		case "tdef":
			gtname = "Team Defender";
			break;		

		case "dom":
			gtname = "Domination";
			break;

		case "re":
			gtname = "Retrieval";
			break;
			
		default:
			gtname = gt;
			break;
	}

	return( gtname );
}

getMapName( map )
{
	switch( map )
	{
		case "mp_farmhouse":
			mapname = "Beltot";
			break;

		case "mp_brecourt":
			mapname = "Brecourt";
			break;

		case "mp_burgundy":
			mapname = "Burgundy";
			break;
		
		case "mp_trainstation":
			mapname = "Caen";
			break;

		case "mp_carentan":
			mapname = "Carentan";
			break;

		case "mp_decoy":
			mapname = "El Alamein";
			break;

		case "mp_leningrad":
			mapname = "Leningrad";
			break;
		
		case "mp_matmata":
			mapname = "Matmata";
			break;
		
		case "mp_downtown":
			mapname = "Moscow";
			break;
		
		case "mp_harbor":
			mapname = "Rostov";
			break;
		
		case "mp_dawnville":
			mapname = "St. Mere Eglise";
			break;

		case "mp_railyard":
			mapname = "Stalingrad";
			break;

		case "mp_toujane":
			mapname = "Toujane";
			break;
		
		case "mp_breakout":
			mapname = "Villers-Bocage";
			break;

		case "mp_rhine":
			mapname = "Wallendar";
			break;

		default:
		    // Strip mp_ prefix
		    if( getsubstr( map, 0, 3 ) == "mp_" )
				mapname = getsubstr( map, 3 );
			else
				mapname = map;
			// Change underscores to space and make words capitalized
			tmp = "";
			from = "abcdefghijklmnopqrstuvwxyz";
		    to   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		    nextisuppercase = true;
			for( i=0; i < mapname.size; i++ )
			{
				if( mapname[i] == "_" )
				{
					tmp += " ";
					nextisuppercase = true;
				}
				else if( nextisuppercase )
				{
					found = false;
					for( j = 0; j < from.size; j++ )
					{
						if( mapname[i] == from[j] )
						{
							tmp += to[j];
							found = true;
							break;
						}
					}
					
					if( !found )
						tmp += mapname[i];
						
					nextisuppercase = false;
				}
				else
					tmp += mapname[i];
			}
			// Change postfixes like B1 to Beta1
			if( ( getsubstr( tmp, tmp.size-2 )[0] == "B" ) && ( issubstr( "0123456789", getsubstr( tmp, tmp.size-1 ) ) ) )
				mapname = getsubstr( tmp, 0, tmp.size-2 ) + "Beta" + getsubstr( tmp, tmp.size-1 );
			else
				mapname = tmp;
				
			break;
	}

	return mapname;
}

explode( s, delimiter )
{
	j=0;
	temparr[j] = "";	

	for( i=0; i < s.size; i++ )
	{
		if( s[i] == delimiter )
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}

strip( s )
{
	if( s=="" )
		return "";

	s2="";
	s3="";

	i=0;
	while( i < s.size && s[i] == " " )
		i++;

	// String is just blanks?
	if( i == s.size )
		return "";
	
	for( ; i < s.size; i++ )
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while( s2[i] == " " && i > 0 )
		i--;

	for( j=0; j <= i; j++ )
	{
		s3 += s2[j];
	}
		
	return s3;
}
