#include demon\_utils;

init()
{

	level.weaponpools	= cvardef( "scr_demon_weappools", 0, 0, 1, "int" );
	
	if( !level.weaponpools )
		return;
	
	level.weaponpool_num = cvardef( "scr_demon_weappool_maxnum", 6, 0, 6, "int" );
	level.weappool_respawnTime 	= cvardef( "scr_demon_weappool_respawntime", 10, 0, 9999, "int" );
	
	level.weaponpool_weapname = [];
	level.weaponpool_weapname[0] = cvardef( "scr_demon_weappool_weapname1", "greasegun_mp", "", "", "string" );
	level.weaponpool_weapname[1] = cvardef( "scr_demon_weappool_weapname2", "mp40_mp", "", "", "string" );
	level.weaponpool_weapname[2] = cvardef( "scr_demon_weappool_weapname3", "shotgun_mp", "", "", "string" );
	level.weaponpool_weapname[3] = cvardef( "scr_demon_weappool_weapname4", "m1garand_mp", "", "", "string" );
	level.weaponpool_weapname[4] = cvardef( "scr_demon_weappool_weapname5", "mp44_mp", "", "", "string" );
	level.weaponpool_weapname[5] = cvardef( "scr_demon_weappool_weapname6", "kar98k_mp", "", "", "string" );
	
	demonPrecacheModel( "xmodel/prop_crate_smallshipping_open2" );
	
	for( i=0; i < level.weaponpool_num; i++ )
		demonPrecacheItem( level.weaponpool_weapname[i] );
	
	if( level.allow_sprint )
	{
		for( i=0; i < level.weaponpool_num; i++ )
			demonPrecacheItem( "sprint_" + level.weaponpool_weapname[i] );
	}
	
	/#
		demonprecacheShader( "objpoint_flag_neutral" );
		// set the objpoints definitions because this thread is started before callback_startgametype
		thread maps\mp\gametypes\_objpoints::init();
	#/
	
	thread SetUp();
	thread weappool_think();
}

SetUp()
{
	if( level.gametype == "re" )
		level waittill( "re_setup_done" );
		
	// setup the spawnpoint arrays
	spawns = getSpawnPointsArray();
	
	if( !spawns.size ) return;

	min_dist_apart = 700;
		
	weappool_spawnpoints = [];

	for( i=0; i < level.weaponpool_num; )
	{
		spawnpos = spawns[ randomInt( spawns.size ) ];
	
		spawnpos.findanother = false;
			
		for( j = 0; j < weappool_spawnpoints.size; j++ )
			if( distance( spawnpos.origin, weappool_spawnpoints[j].origin ) < min_dist_apart ) 
				spawnpos.findanother = true;

		if( !spawnpos.findanother )
		{
			weappool_spawnpoints[i] = spawnpos;
			
			spawnweappool( spawnpos, level.weaponpool_weapname[i] );
			i++;
		}

		wait( 0.05 );
	}
}

spawnweappool( spawnpoint, weaponName )
{
	groundpoint = getGroundpoint( spawnpoint );
	origin = getForwardPosition( spawnpoint, groundpoint );
	
	weappool = spawnStruct();
	weappool = spawn( "script_model", origin );
	weappool.angles = (0,0,0);
	weappool.origin = origin;
	weappool.weapon = spawn_weapon( weaponName, "weapon_pickup", weappool.origin+(0,0,40), weappool.angles, 3 );
	
	thread spawnCrate( origin );
}

getForwardPosition( spawnpoint, groundpoint )
{
	position = undefined;
	forward = anglesToForward( spawnpoint.angles );
	forward = maps\mp\_utility::vectorScale( forward, 80 );
	position = groundpoint + forward;
		
	return( position );
}

spawnCrate( origin )
{
	decoration = spawn_model( "xmodel/prop_crate_smallshipping_open2", "decoration", origin, (0,0,0) );
	
	/#
		decoration.objpointflag = "objpoint_flag_neutral";
		decoration [[level.createFlagWaypoint]](  "decoration_indicator", origin, decoration.objpointflag, 55 );
	#/
}

weappool_think()
{
	// give time for everything to spawn
	wait( 0.75 );

	pickups = getEntArray( "weapon_pickup", "targetname" );
	for( i = 0; i < pickups.size; i++ )
	{
		thread trackPickup( pickups[i] );
		wait( 0.02 );
	}
}

trackPickup( pickup )
{	
	level endon( "intermission" );
	
	while( true )
	{	
		pickup thread spinPickup();
			
		player = undefined;
		classname = pickup.classname;
		origin = pickup.origin;
		angles = pickup.angles;
		spawnflags = pickup.spawnflags;
		
		isWeapon = false;
		weapname = undefined;
		respawnTime = undefined;

		if( isSubStr( classname, "weapon_" ) )
		{
			isWeapon = true;
			weapname = pickup getItemWeaponName();
			respawnTime = level.weappool_respawnTime;
		}
		
		if( isWeapon )
		{
			while( true )
			{
				pickup waittill( "trigger", player, dropped );
				
				if( !isdefined( pickup ) )
					break;
				
				assert( !isdefined( dropped ) );
			}
			
			if( isdefined( dropped ) )
			{	
				dropped thread monitorDropped();
			}
		}
		
		wait( respawnTime );
		
		pickup = spawn( classname, origin, spawnflags );
		pickup.angles = angles;
		
	}
}

getItemWeaponName()
{
	classname = self.classname;
	assert( getsubstr( classname, 0, 7 ) == "weapon_" );
	weapname = getsubstr( classname, 7 );
	return weapname;
}

spinPickup()
{
	if( self.spawnflags & 2 || self.classname == "script_model" )
	{
		self endon( "death" );
		
		org = spawn( "script_origin", self.origin );
		org endon("death");
		
		self linkto( org );
		self thread deleteOnDeath( org );
		
		while( true )
		{
			org rotateyaw( 360, 3, 0, 0 );
			wait( 2.9 );
		}
	}
}

monitorDropped()
{
	name = self getItemWeaponName();
	clone = spawn( self.classname, self.origin );
	clone setModel( getweaponmodel( name ) );
	clone.angles = self.angles;
	self delete(); 
	
	dropDeleteTime = 5;
	
	if( dropDeleteTime > level.weappool_respawnTime )
		dropDeleteTime = level.weappool_respawnTime;
		
	clone thread delayedDeletion( dropDeleteTime );
	
	clone endon( "death" );

	clone waittill( "trigger", player, dropped );

	if( isdefined( dropped ) )
	{
		if( dropDeleteTime > level.weappool_respawnTime )
			dropDeleteTime = level.weappool_respawnTime;
			
		dropped thread delayedDeletion( dropDeleteTime );
	}
}

delayedDeletion( delay )
{
	self thread delayedDeletionOnSwappedWeapons( delay );
	
	wait( delay );
	
	if( isDefined( self ) )
	{
		self notify( "death" );
		self delete();
	}
}

delayedDeletionOnSwappedWeapons( delay )
{
	self endon( "death" );
	
	while( true )
	{
		self waittill( "trigger", player, dropped );
		
		if( isdefined( dropped ) )
			break;
	}
	
	dropped thread delayedDeletion( delay );
}

deleteOnDeath( ent )
{
	ent endon( "death" );
	self waittill( "death" );
	ent delete();
}


