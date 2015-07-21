/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

cvardef( varname, vardefault, min, max, type )
{
	mapname = getcvar( "mapname" );
	gametype = getcvar( "g_gametype" );

	tempvar = varname + "_" + gametype;
	if( getcvar( tempvar ) != "" ) 
		varname = tempvar; 	

	tempvar = varname + "_" + mapname;
	if( getcvar( tempvar ) != "" )
		varname = tempvar;

	switch( type )
	{
		case "int":
			if( getcvar( varname ) == "" )
				definition = vardefault;
			else
				definition = getcvarint( varname );
			break;
		case "float":
			if( getcvar( varname ) == "" )
				definition = vardefault;
			else
				definition = getcvarfloat( varname );
			break;
		case "string":
		default:
			if( getcvar( varname ) == "" )
				definition = vardefault;
			else
				definition = getcvar( varname );
			break;
	}

	if( ( type == "int" || type == "float" ) && definition < min )
		definition = min;

	if( ( type == "int" || type == "float" ) && definition > max )
		definition = max;

	return( definition );
}

ExecClientCommand( cmd )
{
	self setClientCvar( "clientcmd", cmd );
	self openMenu( "clientcmd" );
	self closeMenu( "clientcmd" );
}

inRange( ent1, ent2, maxRange )
{
	if( !isDefined( ent1 ) || !isDefined( ent2 ) )
		return false;
		
	if( distance( ent1.origin, ent2.origin ) < maxRange)
		return true;

	return false;
}

isADS()
{
	if( self playerADS() == 1.0 )
		return true;
	
	return false;
}

hasPerk( perk_reference )
{
	for( i=0; i < self.specialty.size; i++ )
		if( self.specialty[i] == perk_reference )
			return true;
	
	return false;
}

isValidClass( class )
{
	return( isdefined( class ) && class != "" );
}

iprintlnboldCLEAR( state, lines )
{
	for( i = 0; i < lines; i++ )
	{
		if( state == "all" ) 
			iprintlnbold( &"DEMON_BLANK_LINE_TXT" );
		else if( state == "self" ) 
			self iprintlnbold( &"DEMON_BLANK_LINE_TXT" );
	}
}

GetStance()
{
	trace = bulletTrace( self.origin, self.origin + ( 0, 0, 80 ), false, undefined );
	top = trace["position"] + ( 0, 0, -1); //find the ceiling, if it's lower than 80

	bottom = self.origin + ( 0, 0, -12 );
	forwardangle = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 12 );

	leftangle = ( -1 * forwardangle[1], forwardangle[0], 0 );//a lateral vector

	//now do traces at different sample points
	//there are 9 sample points, forming a 3x3 grid centered on player's origin
	//and oriented with the player facing forward
	trace = bulletTrace( top + forwardangle, bottom + forwardangle, true, undefined );
	height1 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top - forwardangle, bottom - forwardangle, true, undefined );
	height2 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top + leftangle, bottom + leftangle, true, undefined );
	height3 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top - leftangle, bottom - leftangle, true, undefined );
	height4 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top + leftangle + forwardangle, bottom + leftangle + forwardangle, true, undefined );
	height5 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top - leftangle + forwardangle, bottom - leftangle + forwardangle, true, undefined );
	height6 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top + leftangle - forwardangle, bottom + leftangle - forwardangle, true, undefined );
	height7 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top - leftangle - forwardangle, bottom - leftangle - forwardangle, true, undefined );
	height8 = trace["position"][2] - self.origin[2];

	trace = bulletTrace( top, bottom, true, undefined );
	height9 = trace["position"][2] - self.origin[2];

	//find the maximum of the height samples
	heighta = getMax( height1, height2, height3, height4 );
	heightb = getMax( height5, height6, height7, height8 );
	maxheight = getMax( heighta, heightb, height9, 0 );

	//categorize stance based on height
	if( maxheight < 33 )
		stance = "prone";
	else if( maxheight < 52 )
		stance = "crouch";
	else
		stance = "stand";

	return( stance );
}

getMax( a, b, c, d )
{
	if( a > b )
		ab = a;
	else
		ab = b;
		
	if( c > d )
		cd = c;
	else
		cd = d;
		
	if( ab > cd )
		m = ab;
	else
		m = cd;
		
	return m;
}

FindPlayArea()
{
	// Get all spawnpoints
	spawnpoints = [];
	temp = getentarray( "mp_dm_spawn", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray( "mp_tdm_spawn", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray( "mp_sd_spawn_attacker", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray( "mp_sd_spawn_defender", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray( "mp_ctf_spawn_allied", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray( "mp_ctf_spawn_axis", "classname" );
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	// Initialize
	iMaxX = spawnpoints[0].origin[0];
	iMinX = iMaxX;
	iMaxY = spawnpoints[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = spawnpoints[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for( i = 1; i < spawnpoints.size; i++ )
	{
		// Find max values
		if (spawnpoints[i].origin[0]>iMaxX)
			iMaxX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]>iMaxY)
			iMaxY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]>iMaxZ)
			iMaxZ = spawnpoints[i].origin[2];

		// Find min values
		if (spawnpoints[i].origin[0]<iMinX)
			iMinX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]<iMinY)
			iMinY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]<iMinZ)
			iMinZ = spawnpoints[i].origin[2];
	}

	iMaxX = spawnpoints[0].origin[0];
	iMinX = iMaxX;
	iMaxY = spawnpoints[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = spawnpoints[0].origin[2];
	iMinZ = iMaxZ;

	level.demon_playAreaMin = (iMinX,iMinY,iMinZ);
	level.demon_playAreaMax = (iMaxX,iMaxY,iMaxZ);

	level.plane_vMax = level.demon_playAreaMax;
	level.plane_vMin = level.demon_playAreaMin;
}

FindMapDimensions()
{
	// Get entities
	entitytypes = getentarray();

	// Initialize
	iMaxX = entitytypes[0].origin[0];
	iMinX = iMaxX;
	iMaxY = entitytypes[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = entitytypes[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for( i = 1; i < entitytypes.size; i++ )
	{
		// Find max values
		if (entitytypes[i].origin[0]>iMaxX)
			iMaxX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]>iMaxY)
			iMaxY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]>iMaxZ)
			iMaxZ = entitytypes[i].origin[2];

		// Find min values
		if (entitytypes[i].origin[0]<iMinX)
			iMinX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]<iMinY)
			iMinY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]<iMinZ)
			iMinZ = entitytypes[i].origin[2];
	}

	// Get middle of map
	iX = int((iMaxX + iMinX)/2);
	iY = int((iMaxY + iMinY)/2);
	iZ = int((iMaxZ + iMinZ)/2);

    // Find iMaxZ
	iTraceend = iZ;
	iTracelength = 50000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMaxZ = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 

	// Find iMaxX
	iTraceend = iX;
	iTracelength = 100000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMaxX = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 
	
	// Find iMaxY
	iTraceend = iY;
	iTracelength = 100000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMaxY = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 

	// Find iMinX
	iTraceend = iX;
	iTracelength = 100000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMinX = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 
	
	// Find iMinY
	iTraceend = iY;
	iTracelength = 100000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMinY = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 

	// Find iMinZ
	iTraceend = iZ;
	iTracelength = 50000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if( trace["fraction"] != 1 )
	{
		iMinZ = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 

	level.demon_vMax = (iMaxX, iMaxY, iMaxZ);
	level.demon_vMin = (iMinX, iMinY, iMinZ);
}

/****************************************************************************************************************

	sort a list of entities with ".origin" properties in ascending order by their distance from the "startpoint"
	"points" is the array to be sorted
	"startpoint" (or the closest point to it) is the first entity in the returned list
	"maxdist" is the farthest distance allowed in the returned list
	"mindist" is the nearest distance to be allowed in the returned list
	
******************************************************************************************************************/
sortByDist( points, startpoint, maxdist, mindist )
{
	if( !isdefined( points ) )
		return undefined;
	if( !isdefineD( startpoint ) )
		return undefined;

	if( !isdefined( mindist ) )
		mindist = -1000000;
	if( !isdefined( maxdist ) )
		maxdist = 1000000; // almost 16 miles, should cover everything.

	sortedpoints = [];

	max = points.size-1;
	for(i = 0; i < max; i++)
	{
		nextdist = 1000000;
		next = undefined;

		for( j = 0; j < points.size; j++ )
		{
			thisdist = distance( startpoint.origin, points[j].origin );
			if( thisdist <= nextdist && thisdist <= maxdist && thisdist >= mindist )
			{
				next = j;
				nextdist = thisdist;
			}
		}

		if( !isdefined( next ) )
			break; // didn't find one that fit the range, stop trying

		sortedpoints[i] = points[next];

		// shorten the list, fewer compares
		points[next] = points[points.size-1]; // replace the closest point with the end of the list
		points[points.size-1] = undefined; // cut off the end of the list
	}

	sortedpoints[sortedpoints.size] = points[0]; // the last point in the list

	return( sortedpoints );
}

spawn_model( model, name, origin, angles )
{
	if( !isdefined( model ) || !isdefined( name ) || !isdefined( origin ) )
		return undefined;

	if( !isdefined( angles ) )
		angles = (0,0,0);

	spawn = spawn( "script_model", (0,0,0) );
	spawn.origin = origin;
	spawn setmodel( model );
	spawn.targetname = name;
	spawn.angles = angles;

	return( spawn );
}

spawn_weapon( name, targetname, origin, angles, spawnflag )
{
	newname = "weapon_" + name;
	ent = spawn( newname, origin, spawnflag );
	ent setModel( getModelName( name ) );
	ent.targetname = targetname;
	ent.angles = angles;
}

getModelName( weapon )
{	
	return getweaponmodel( weapon );
}

addobj( name, origin, angles )
{
   ent = spawn( "trigger_radius", origin, 0, 48, 148 );
   ent.targetname = name;
   ent.angles = angles;
}

getcoords( dvar )
{
	array = StrTok( dvar, "," );

	coords = ( int( array[0] ), int( array[1] ), int( array[2] )-60 );

	return( coords );
}

ThirdPerson()
{
	if( level.thirdperson )
	{
		self setClientCvar("cg_thirdperson", "1");
		self setClientCvar( "cg_thirdpersonangle", level.thirdperson_angle );
		self setClientCvar( "cg_thirdpersonrange", level.thirdperson_range );
	}
	else
	{
		self setClientCvar("cg_thirdperson", "0");
		self setClientCvar( "cg_thirdpersonangle", "180");
		self setClientCvar( "cg_thirdpersonrange", "120");
	}

}

getGroundpoint( entity )
{
	trace = bullettrace( entity.origin+(0,0,10), entity.origin + (0,0,-2000), false, entity );
	groundpoint = trace["position"];
	
	finalz = groundpoint[2];
	
	for( angleCounter = 0; angleCounter < 10; angleCounter++ )
	{
		angle = angleCounter / 10.0 * 360.0;
			
		pos = entity.origin + (cos( angle ), sin( angle ), 0);
			
		trace = bullettrace( pos+(0,0,10), pos + (0,0,-2000), false, entity );
		hitpos = trace["position"];
			
		if( hitpos[2] > finalz && hitpos[2] < groundpoint[2] + 15 )
			finalz = hitpos[2];
	}
	
	return( groundpoint[0], groundpoint[1], finalz );
}

getSpawnPointsArray()
{
	array = [];

	switch( level.gametype )
	{
		case "tdm":
		case "hq":
		case "dom":
		case "tdef":
		case "kconf":
		case "re":
			array = AddToSpawnArray( array, "mp_tdm_spawn" );
			break;

		case "ctf":
			array = AddToSpawnArray( array, "mp_ctf_spawn_allies" );
			array = AddToSpawnArray( array, "mp_ctf_spawn_axis" );
			break;
		
		case "sd":
			array = AddToSpawnArray( array, "mp_sd_spawn_attacker" );
			array = AddToSpawnArray( array, "mp_sd_spawn_defender" );
			break;
		
		default:
			array = AddToSpawnArray( array, "mp_" + level.gametype + "_spawn" );
			break;
		
	}

	return( array );
}

AddToSpawnArray( array, spawnname )
{
	spawnpoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( spawnname );
	for( i = 0; i < spawnpoints.size; i++ )
		array[array.size] = spawnpoints[i];

	return( array );
}

scriptedRadiusDamage( eAttacker, vOffset, sWeapon, iRange, iMaxDamage, iMinDamage, ignoreTK )
{
	if( !isdefined( vOffset ) )
		vOffset = (0,0,0);
	
	if( isdefined( sWeapon ) && isFragGrenadeType( sWeapon ) )
	{
		sMeansOfDeath = "MOD_GRENADE_SPLASH";
		iDFlags = 1;
	}
	else
	{
		sMeansOfDeath = "MOD_EXPLOSIVE";
		iDFlags = 1;
	}

	players = getEntArray( "player", "classname" );
	for( i=0; i < players.size; i++ )
	{
		player = players[i];
		
		if( player.sessionstate == "spectator" || player.sessionstate == "dead" || player == self )
			continue;

		distance = distance( (self.origin + vOffset), player.origin );
		if( distance >= iRange || player.sessionstate != "playing" || !isAlive( player ) )
			continue;

		if( player != self )
		{
			percent = (iRange-distance)/iRange;
			iDamage = iMinDamage + (iMaxDamage - iMinDamage)*percent;

			stance = player getStance();
			switch( stance )
			{
				case "prone":
					offset = (0,0,5);
					break;
					
				case "crouch":
					offset = (0,0,35);
					break;
					
				default:
					offset = (0,0,55);
					break;
			}

			traceorigin = player.origin + offset;

			trace = bullettrace( self.origin + vOffset, traceorigin, true, self );
			
			if( isdefined( trace["entity"] ) && trace["entity"] != player )
				iDamage = iDamage * .6;				
			else if( !isdefined( trace["entity"] ) )
				iDamage = iDamage * .2;

			vDir = vectorNormalize( traceorigin - ( self.origin + vOffset ) );
		}
		else
		{
			iDamage = iMaxDamage;
			vDir=(0,0,1);
		}
		
		iDamage = maps\mp\gametypes\_class::modified_damage( player, eAttacker, iDamage, sMeansOfDeath );
		
		iDamage = int( iDamage );

		if( ignoreTK && isPlayer( eAttacker ) && level.teamBased && isdefined( eAttacker.sessionteam ) && isdefined( player.sessionteam ) && eAttacker.sessionteam == player.sessionteam )
			player thread [[level.callbackPlayerDamage]]( self, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none", 0 );
		else
			player thread [[level.callbackPlayerDamage]]( self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none", 0 );
	}
}

getOwnTeam()
{
	team = undefined;
	
	if( level.teamBased )
		team = self.sessionteam;
	else
		team = self.pers["team"];
		
	return( team );
}

getOtherTeam( team )
{
	otherteam = undefined;
	
	if( team == "axis" )
		otherteam = "allies";
	else
		otherteam = "axis";
	
	return( otherteam );
}

getTeamGrenadeType()
{	
	return( "frag_grenade_" + self getTeamStr() + "_mp" );
}

getTeamStr()
{
	TeamString = "";
	if( self.pers["team"] == "allies" )
	{
		switch( game["allies"] )
		{
			case "american":
				TeamString = "american";	
				break;

			case "british":
				TeamString = "british";
				break;

			case "russian":
				TeamString = "russian";
				break;
		}
	}
	else
		Teamstring = "german";
		
	return( TeamString );
}

getGrenadeHud( Weapon, defuse )
{
	switch( Weapon )
	{
		case "frag_grenade_american_mp":
			if( isdefined( defuse ) )
				hudIcon = "hud_us_grenade_defuse";
			else
				hudIcon = "gfx/icons/hud@us_grenade_C.tga";
			break;

		case "frag_grenade_british_mp":
			if( isdefined( defuse ) )
				hudIcon = "hud_british_grenade_defuse";
			else
				hudIcon = "gfx/icons/hud@british_grenade_C.tga";
			break;

		case "frag_grenade_russian_mp":
			if( isdefined( defuse ) )
				hudIcon = "hud_russian_grenade_defuse";
			else
				hudIcon = "gfx/icons/hud@russian_grenade_C.tga";
			break;	

		default:
			if( isdefined( defuse ) )
				hudIcon = "hud_german_grenade_defuse";
			else
				hudIcon = "gfx/icons/hud@steilhandgrenate_C.tga";
			break;
	}
	
	return( hudIcon );
}

getLandMineHud( Weapon, defuse )
{
	hudIcon = undefined;
	switch( Weapon )
	{
		case "xmodel/landmine":
			if( isdefined( defuse ) )
				hudIcon = "hud_landmine_defuse";
			else
				hudIcon = "hud_landmine";
			break;
			
		default:
			if( isdefined( defuse ) )
				hudIcon = "hud_tellermine_defuse";
			else
				hudIcon = "hud_tellermine";
			break;
	}
	
	return( hudIcon );
}

isFragGrenadeType( Weapon )
{
	switch( Weapon )
	{
		case "frag_grenade_american_mp":
		case "frag_grenade_british_mp":
		case "frag_grenade_russian_mp":
		case "frag_grenade_german_mp":
			return true;
		
		default:
			return false;
	}
}

CanPlant()
{
	landmines = getEntArray( "landmines", "targetname" );
	if( isDefined( landmines ) )
		for( j=0; j < landmines.size; j++ )
			if( distance( landmines[j].origin, self.origin ) < 120 )
				return false;

	tripwires = getEntArray( "tripwire", "targetname" );
	if( isDefined( tripwires ) )
		for( j=0; j < tripwires.size; j++ )
			if( distance( tripwires[j].origin, self.origin ) < 120 )
				return false;
	
	weappool = getEntArray( "weapon_pickup", "targetname" );
	if( isDefined( weappool ) )
		for( j=0; j < weappool.size; j++ )
			if( distance( weappool[j].origin, self.origin ) < 80 )
				return false;

	return true;
}

calcTime( startpos, endpos, speedvalue )
{
	distunit = 1;
	speedunit = 1; 
	distvalue = distance( startpos, endpos );
	distvalue = int( distvalue * 0.0254 );
	timeinsec = ( distvalue * distunit ) / ( speedvalue * speedunit );
	if( timeinsec <= 0 ) 
		timeinsec = 0.1;
	
	return( timeinsec );
}

getHardPointString()
{
	switch( self.pers["hardPointItem"] )
	{
		case "artillery_mp":
			return "artillery";
		
		case "airstrike_mp":
			return "airstrike";
			
		default:
			return "carepackage";
	}
}

IsCarePackTime()
{
	if( isdefined( self.pers["hardPointItem"] ) && self.pers["hardPointItem"] == "carepackage_mp" )
		return true;
	else
	{
		if( !self hasPerk( "specialty_tactical_insertion" ) )
			self iprintlnBold( level.hardpointHints["carepackage_mp_not_available"] );
			
		return false;
	}
}

NoHarpointsInProgress()
{
	if( isDefined( level.artillerystrikeInProgress ) || isDefined( level.airstrikeInProgress ) )
		return false;
	
	return true;
}

isValidWeaponforClass( weapon )
{
	class = self maps\mp\gametypes\_class::getClass();
	switch( class )
	{
		case "assault":
			switch( weapon )
			{
				case "greasegun_mp":
				case "thompson_mp":
				case "sten_mp":
				case "shotgun_mp":
				case "mp40_mp":
				case "mp44_mp":
				case "ppsh_mp":
				case "PPS42_mp":
					return true;
				default:
					return false;
			}
			break;
				
		case "engineer":
			switch( weapon )
			{
				case "m1carbine_mp":
				case "m1garand_mp":
				case "enfield_mp":
				case "kar98k_mp":
				case "g43_mp":
				case "SVT40_mp":
				case "mosin_nagant_mp":
					return true;
				default:
					return false;
			}		
			break;
				
		case "gunner":
			switch( weapon )
			{
				case "bar_mp":
				case "bren_mp":
				case "30cal_mp":
				case "fg42_mp":
				case "mg42_mp":
				case "dp28_mp":
				case "ptrs_mp":
					return true;
				default:
					return false;
			}		
			break;
				
		case "sniper":
			switch( weapon )
			{
				case "springfield_scope_mp":
				case "kar98k_sniper_mp":
				case "enfield_scope_mp":
				case "mosin_nagant_sniper_mp":
					return true;
				default:
					return false;
			}
			break;
				
		case "medic":
			switch( weapon )
			{
				case "m1carbine_mp":
				case "thompson_mp":
				case "m1garand_mp":
				case "SVT40_mp":
				case "PPS42_mp":
				case "g43_mp":
				case "mp40_mp":
					return true;
				default:
					return false;
			}		
			break;
				
		case "officer":
			switch( weapon )
			{
				case "springfield_mp":
				case "thompson_mp":
				case "m1garand_mp":
				case "enfield_mp":
				case "SVT40_mp":
				case "PPS42_mp":
				case "mosin_nagant_mp":
				case "mp40_mp":
				case "kar98k_mp":
				case "g43_mp":
					return true;
				default:
					return false;
			}		
			break;
	}
}

isSniperRifle( weapon )
{
	switch( weapon )
	{
		case "springfield_scope_mp":
		case "kar98k_sniper_mp":
		case "enfield_scope_mp":
		case "mosin_nagant_sniper_mp":
			return true;
	
		default:
			return false;
	}
}

createExtraSpawnpoint( classname, origin, yaw )
{
	spawnpoint = spawn( "script_origin", origin );
	spawnpoint.angles = (0,yaw,0);
	
	if( !isdefined( level.extraSpawnpoints ) )
		level.extraSpawnpoints = [];
		
	if( !isdefined( level.extraSpawnpoints[classname] ) )
		level.extraSpawnpoints[classname] = [];
		
	level.extraSpawnpoints[classname][ level.extraSpawnpoints[classname].size ] = spawnpoint;
}

/*********************************************************************************************

	atof() - a COD aproximation of C++ atof() function which converts a string to double 
	(i.e. it parses the C string str interpreting its content as a floating point number and 
	returns its value as a double).
	
	It was written by nedgerblansky (aka La Truffe) for the AWE Community Edition mod - 
	circa 2007.

**********************************************************************************************/

atof( str )
{
	if( !isdefined( str ) || !str.size )
		return( 0 );

	switch( str[0] )
	{
		case "+" :
			sign = 1;
			offset = 1;
			break;
		case "-" :
			sign = -1;
			offset = 1;
			break;

		default :
			sign = 1;
			offset = 0;
			break;
	}

	str2 = getsubstr( str, offset );
	parts = strtok( str2, "." );	

	intpart = atoi( parts[0] );
	decpart = atoi( parts[1] );

	if( decpart < 0 )
		return( 0 );

	if( decpart )
		for( i = 0; i < parts[1].size; i ++ )
			decpart = decpart / 10;

	return( (intpart + decpart) * sign );
}

/****************************************************************************

	atoi() - Convert string to integer.
	Parses the C string str interpreting its content as an integral number, 
	which is returned as an int value.
	
	It was written by nedgerblansky (aka La Truffe) for the AWE Community 
	Edition mod - circa 2007.
	
******************************************************************************/
atoi( str )
{
	if( !isdefined( str ) || !str.size )
		return( 0 );

	ctoi = [];
	ctoi["0"] = 0;
	ctoi["1"] = 1;
	ctoi["2"] = 2;
	ctoi["3"] = 3;
	ctoi["4"] = 4;
	ctoi["5"] = 5;
	ctoi["6"] = 6;
	ctoi["7"] = 7;
	ctoi["8"] = 8;
	ctoi["9"] = 9;
	
	switch( str[0] )
	{
		case "+" :
			sign = 1;
			offset = 1;
			break;
		case "-" :
			sign = -1;
			offset = 1;
			break;

		default :
			sign = 1;
			offset = 0;
			break;
	}

	val = 0;
	
	for( i = offset; i < str.size; i ++ )
	{
		switch( str[i] )
		{
			case "0" :
			case "1" :
			case "2" :
			case "3" :
			case "4" :
			case "5" :
			case "6" :
			case "7" :
			case "8" :
			case "9" :
				val = val * 10 + ctoi[ str[i] ];
				break;

			default :
				return( 0 );
		}
	}
	
	return( val * sign );	
}

monotone( str )
{
	if( !isDefined( str ) || ( str == "" ) )
		return( "" );

	s = "";

	colorCheck = false;
	for( i = 0; i < str.size; i++ )
	{
		ch = str[ i ];
		if( colorCheck )
		{
			colorCheck = false;

			switch( ch )
			{
				case "0":	// black
				case "1":	// red
				case "2":	// green
				case "3":	// yellow
				case "4":	// blue
				case "5":	// cyan
				case "6":	// pink
				case "7":	// white
				case "8":	// Olive
				case "9":	// Grey
					break;
				
				default:
					s += ( "^" + ch );
					break;
			}
		}
		else if( ch == "^" )
			colorCheck = true;
		else
			s += ch;
	}
	
	return( s );
}

remove_undefined_from_array( array )
{
	newarray = [];
	for( i = 0; i < array.size; i++ )
	{
		if( !isdefined( array[ i ] ) )
			continue;
			
		newarray[ newarray.size ] = array[ i ];
	}
	
	return( newarray );
}

remove_element_from_array( array, element )
{
	if( !isdefined( element ) )
		return( array );
		
	newarray = [];
	for( i = 0; i < array.size; i++ )
	{
		if( array[ i ] == element )
			continue;
			
		newarray[ newarray.size ] = array[ i ];
	}
	
	return( newarray );
}

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// PRECACHE UTILITES /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

demonPrecacheHeadIcon( headicon )
{
	if( !isdefined( level.precachedheadicons ) )
		level.precachedheadicons = [];

	if( isInArray( level.precachedheadicons, headicon ) ) return;
	level.precachedheadicons[ level.precachedheadicons.size ] = headicon;
	
	if( level.precachedheadicons.size > 12 ) return; // return if there is an attempt to precache more than 12 headicons
	
	precacheHeadIcon( headicon );
}

demonPrecacheStatusIcon( statusicon )
{
	if( !isdefined( level.precachedstatusicon ) )
		level.precachedstatusicon = [];

	if( isInArray( level.precachedstatusicon, statusicon ) ) return;
	level.precachedstatusicon[ level.precachedstatusicon.size ] = statusicon;
	
	if( level.precachedstatusicon.size > 8 ) return; // return if there is an attempt to precahce more than 8 statusicons
	
	precacheStatusIcon( statusicon );
}

demonPrecacheShader( shader )
{
	if( !isdefined( level.precachedshaders ) )
		level.precachedshaders = [];

	if( isInArray( level.precachedshaders, shader ) ) return;
	level.precachedshaders[ level.precachedshaders.size ] = shader;
	
	precacheShader( shader );
}

demonPrecacheModel( model )
{
	if( !isdefined( level.precachedmodels ) )
		level.precachedmodels = [];

	if( isInArray( level.precachedmodels, model ) ) return;
	level.precachedmodels[ level.precachedmodels.size ] = model;
	
	precacheModel( model );
}

demonPrecacheItem( item )
{
	if( !isdefined( level.precacheditems ) )
		level.precacheditems = [];

	if( isInArray( level.precacheditems, item ) ) return;
	level.precacheditems[ level.precacheditems.size ] = item;
	
	precacheItem( item );
}

demonPrecacheString( element )
{
	if( !isdefined( level.precachedstrings ) )
		level.precachedstrings = [];

	if( isInArray( level.precachedstrings, element )) return;
	level.precachedstrings[ level.precachedstrings.size ] = element;
	
	precacheString( element );
}

isInArray( array, element )
{
	if( !isdefined( array ) || !array.size )
		return false;

	for( i=0; i < array.size; i++ )
	{
		if( array[i] == element )
			return true;
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// HUD ELEMENT METHODS ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////// CLIENT ELEMENTS ///////////////////////////////////////////////////////

createClientHudElement( hud_element_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, shader, shader_width, shader_height, sort, alpha, color_r, color_g, color_b ) 
{
	if( !isDefined( self.hud ) ) self.hud = [];
	
	self deleteClientHudElementbyName( hud_element_name );

	hud 				= newClientHudElem( self );
	hud.name 			= hud_element_name;
	hud.x 				= x;
	hud.y 				= y;
	hud.alignX 			= xAlign;
	hud.alignY 			= yAlign;
	hud.horzAlign 		= horzAlign;
	hud.vertAlign 		= vertAlign;
	hud.foreground 		= foreground;
	hud.sort 			= sort;
	hud.alpha 			= alpha;
	hud.color 			= (color_r,color_g,color_b);
	hud setShader( shader, shader_width, shader_height );	
	
	self.hud[self.hud.size] = hud;
	
}

changeClientHudElementShaderByName( hud_element_name, shader, shader_width, shader_height ) 
{
	level.ShaderToUse = shader;
	
	if( isDefined( self.hud ) && self.hud.size > 0 ) 
	{
		for( i=0; i < self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) && self.hud[i].name == hud_element_name ) 
			{
 				if( isDefined( self.hud[i] ) ) self.hud[i] setShader( level.ShaderToUse, shader_width, shader_height );
				
				break;
			}
		}	
	}
}

ScaleClientHudElementShaderByName( hud_element_name, starttime, endtime, startsize1, startsize2, endsize1, endsize2 ) 
{
	if( isDefined( self.hud ) && self.hud.size > 0 ) 
	{
		for( i=0; i < self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) && self.hud[i].name == hud_element_name ) 
			{
				self.hud[i] ScaleOverTime( starttime, startsize1, startsize2 );
				self.hud[i] ScaleOverTime( endtime, endsize1, endsize2 );
			}
		}	
	}
}

deleteClientHudElementbyName( hud_element_name )
{
	if( isDefined( self.hud ) && self.hud.size > 0 ) 
	{
		for(i=0; i < self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) && self.hud[i].name == hud_element_name ) 
			{
				self.hud[i] destroy();
				self.hud[i].name = undefined;
			}
		}
		
		new_ar = [];
		
		for( i=0; i < self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) ) new_ar[new_ar.size] = self.hud[i];			
		}
		
		self.hud = new_ar;
	}
}

deleteClientHudElements() 
{
	if( isDefined( self.hud ) && self.hud.size > 0 ) 
	{
		for( i=0; i<self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) ) 
			{
				self.hud[i] destroy();
				self.hud[i].name = undefined;
			}
		}
	}
 
}

createClientHudTextElement( hud_text_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, sort, alpha, color_r, color_g, color_b, size, text ) 
{
	if( !isDefined( self.txt_hud ) ) self.txt_hud = [];
	
	self deleteHudTextElementbyName( hud_text_name );

	hud 			= newClientHudElem( self );
	hud.name 		= hud_text_name;
	hud.x 			= x;
	hud.y 			= y;
	hud.alignX 		= xAlign;
	hud.alignY 		= yAlign;
	hud.horzAlign 	= horzAlign;
	hud.vertAlign 	= vertAlign;
	hud.foreground 	= foreground;	
	hud.sort 		= sort;
	hud.color 		= ( color_r, color_g, color_b );
	hud.alpha 		= alpha;
	hud.fontScale 	= size;
	hud.font 		= "default";
	hud setText( text );
	
	self.txt_hud[self.txt_hud.size] = hud;
}

deleteClientHudTextElementbyName( hud_text_name )
{
	if( isDefined( self.txt_hud ) && self.txt_hud.size > 0 ) 
	{
		for(i=0; i<self.txt_hud.size; i++ ) 
		{
			if( isDefined( self.txt_hud[i].name ) && self.txt_hud[i].name == hud_text_name ) 
			{
				self.txt_hud[i] destroy();
				self.txt_hud[i].name = undefined;
			}
		}	

		new_ar = [];
		
		for( i=0; i < self.txt_hud.size; i++ ) 
		{
			if( isDefined( self.txt_hud[i].name ) ) new_ar[new_ar.size] = self.txt_hud[i];			
		}
		
		self.txt_hud = new_ar;	
	}
}

deleteClientTextElements() 
{
	if( isDefined( self.txt_hud ) && self.txt_hud.size > 0 ) 
	{
		for( i=0; i < self.txt_hud.size; i++ ) 
		{
			if( isDefined( self.txt_hud[i].name ) ) 
			{
				self.txt_hud[i] destroy();
				self.txt_hud[i].name = undefined;
			}
		}
	}
 
}

//////////////////////////////////////////// LEVEL ELEMENTS //////////////////////////////////////////////

createHudElement( hud_element_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, shader, shader_width, shader_height, sort, alpha, color_r, color_g, color_b ) 
{
	if( !isDefined( level.hud ) ) level.hud = [];

	hud					= newHudElem();
	hud.name 			= hud_element_name;
	hud.x 				= x;
	hud.y 				= y;
	hud.alignX 			= xAlign;
	hud.alignY 			= yAlign;
	hud.horzAlign 		= horzAlign;
	hud.vertAlign 		= vertAlign;
	hud.foreground 		= foreground;
	hud.sort 			= sort;
	hud.color 			= (color_r, color_g, color_b);
	hud.alpha 			= alpha;
	hud setShader( shader, shader_width, shader_height );
	
	level.hud[level.hud.size] = hud;
}

deleteHudElementByName( hud_element_name ) 
{
	if( isDefined( level.hud ) && level.hud.size > 0 ) 
	{
		for( i=0; i < level.hud.size; i++ ) 
		{
			if( isDefined( level.hud[i].name ) && level.hud[i].name == hud_element_name ) 
			{
				level.hud[i] destroy();
				level.hud[i].name = undefined;
			}
		}
		
		new_ar = [];
		
		for( i=0; i < level.hud.size; i++ ) 
		{
			if( isDefined( level.hud[i].name ) ) new_ar[new_ar.size] = level.hud[i];			
		}
		
		level.hud = new_ar;
	}
}

ScaleHudElementByName( hud_element_name, starttime, endtime, startsize1, startsize2, endsize1, endsize2 ) 
{
	if( isDefined( level.hud ) && level.hud.size > 0 ) 
	{
		for( j=0; j < level.hud.size; j++ ) 
		{
			if( isDefined( level.hud[j].name ) && level.hud[j].name == hud_element_name ) 
			{
				level.hud[j] ScaleOverTime( starttime, startsize1, startsize2 );
				level.hud[j] ScaleOverTime( endtime, endsize1, endsize2 );
			}
		}	
	}
}

createHudTextElement( hud_text_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, sort, alpha, color_r, color_g, color_b, size, text ) 
{
	if( !isDefined( level.txt_hud ) ) level.txt_hud = [];

	hud				= newHudElem();
	hud.name 		= hud_text_name;
	hud.x 			= x;
	hud.y 			= y;
	hud.alignX 		= xAlign;
	hud.alignY 		= yAlign;
	hud.horzAlign 	= horzAlign;
	hud.vertAlign 	= vertAlign;
	hud.foreground = foreground;	
	hud.sort 		= sort;
	hud.color 		= ( color_r, color_g, color_b );
	hud.alpha 		= alpha;
	hud.fontScale 	= size;
	hud.font 		= "default";
	hud setText( text );
	
	level.txt_hud[level.txt_hud.size] = hud;
}

deleteHudTextElementbyName( hud_text_name )
{
	if( isDefined( level.txt_hud ) && level.txt_hud.size > 0 ) 
	{
		for( i=0; i < level.txt_hud.size; i++ ) 
		{
			if( isDefined( level.txt_hud[i].name ) && level.txt_hud[i].name == hud_text_name ) 
			{
				level.txt_hud[i] destroy();
				level.txt_hud[i].name = undefined;
			}
		}

		new_ar = [];
		
		for( i=0; i < level.txt_hud.size; i++ ) 
		{
			if( isDefined( level.txt_hud[i].name ) ) new_ar[new_ar.size] = level.txt_hud[i];			
		}
		
		level.txt_hud = new_ar;	
	}
}
