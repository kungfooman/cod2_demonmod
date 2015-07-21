/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	demonPrecacheShader( "objpoint_default" );

	level.objpoints_allies = spawnstruct();
	level.objpoints_allies.array = [];
	
	level.objpoints_axis = spawnstruct();
	level.objpoints_axis.array = [];
	
	level.objWaypoint = [];	

	level.objpoint_scale = 7;

	//=========== COD4 ============
	
	level.objPointNames = [];
	level.objPoints = [];
	
	level.objPointSize = 8;
	level.objpoint_alpha_default = .5;
	
	//==============================
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	if( level.hardcore ) return;
	
	for( ;; )
	{
		level waittill( "connecting", player );
		
		player.objpoints = [];

		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerKilled();
	}
}

onJoinedTeam()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "joined_team" );
		
		self thread clearPlayerObjpoints();
	}
}

onJoinedSpectators()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "joined_spectators" );
		
		self thread clearPlayerObjpoints();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "spawned_player" );

		self thread updatePlayerObjpoints();		
		
	}
}

onPlayerKilled()
{
	self endon( "disconnect" );

	for( ;; )
	{
		self waittill( "killed_player" );
		
		self thread clearPlayerObjpoints();
	}
}

addObjpoint( origin, name, material )
{
	if( level.hardcore ) return;
	
	thread addTeamObjpoint( origin, name, "all", material );
}

addTeamObjpoint( origin, name, team, material )
{
	if( level.hardcore ) return;
	
	assert( team == "allies" || team == "axis" || team == "all" );
	if( team == "allies" )
	{
		assert( isdefined( level.objpoints_allies ) );
		objpoints = level.objpoints_allies;
	}
	else if( team == "axis" )
	{
		assert( isdefined( level.objpoints_axis ) );
		objpoints = level.objpoints_axis;
	}
	else 
	{
		thread createWayPoint( name, origin, material );
		return;
	}

	// Rebuild objpoints array minus named
	cleanpoints = [];
	for( i = 0; i < objpoints.array.size; i++ )
	{
		objpoint = objpoints.array[i];
	
		if( isdefined( objpoint.name ) && objpoint.name != name )
			cleanpoints[ cleanpoints.size ] = objpoint;
	}
	
	objpoints.array = cleanpoints;
	
	newpoint = spawnstruct();
	newpoint.name = name;
	newpoint.x = origin[0];
	newpoint.y = origin[1];
	newpoint.z = origin[2];
	newpoint.archived = false;

	if( isdefined( material ) )
		newpoint.material = material;
	else
		newpoint.material = "objpoint_default";

	objpoints.array[objpoints.array.size] = newpoint;

	//update objpoints for players
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
			
		if( isDefined( player.pers["team"]) && player.pers["team"] == team && player.sessionstate == "playing" )
		{
			player clearPlayerObjpoints();
	
			for( j = 0; j < objpoints.array.size; j++ )
			{
				objpoint = objpoints.array[j];
					
				newobjpoint = newClientHudElem( player );
				newobjpoint.name = objpoint.name;
				newobjpoint.x = objpoint.x;
				newobjpoint.y = objpoint.y;
				newobjpoint.z = objpoint.z;
				newobjpoint.alpha = .61;
				newobjpoint.archived = objpoint.archived;
				newobjpoint setShader( objpoint.material, level.objpoint_scale, level.objpoint_scale );
				newobjpoint setwaypoint( true );
					
				player.objpoints[ player.objpoints.size ] = newobjpoint;
			}
		}
	}
}

removeObjpoints()
{
	if( level.hardcore ) return;
	
	thread removeTeamObjpoints( "all" );
}

removeTeamObjpoints( team )
{
	assert( team == "allies" || team == "axis" || team == "all" );
	if( team == "allies" )
	{
		assert( isdefined( level.objpoints_allies ) );
		level.objpoints_allies.array = [];
	}
	else if( team == "axis" )
	{
		assert( isdefined( level.objpoints_axis ) );
		level.objpoints_axis.array = [];
	}
	else
	{
		thread deleteWaypoints();
		return;
	}

	//clear objpoints for team specified
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if( isDefined( player.pers["team"]) && player.pers["team"] == team && player.sessionstate == "playing" )
			player clearPlayerObjpoints();
	}
}

updatePlayerObjpoints()
{
	if( isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" && self.sessionstate == "playing" )
	{
		assert( self.pers["team"] == "allies" || self.pers["team"] == "axis" );
		if( self.pers["team"] == "allies" )
		{
			assert( isdefined( level.objpoints_allies ) );
			objpoints = level.objpoints_allies;
		}
		else
		{
			assert( isdefined( level.objpoints_axis ) );
			objpoints = level.objpoints_axis;
		}
		
		self clearPlayerObjpoints();
		
		for( i = 0; i < objpoints.array.size; i++ )
		{
			objpoint = objpoints.array[i];
			
			newobjpoint = newClientHudElem( self );
			newobjpoint.name = objpoint.name;
			newobjpoint.x = objpoint.x;
			newobjpoint.y = objpoint.y;
			newobjpoint.z = objpoint.z;
			newobjpoint.alpha = .61;
			newobjpoint.archived = objpoint.archived;
			newobjpoint setShader( objpoint.material, level.objpoint_scale, level.objpoint_scale );
			newobjpoint setwaypoint( true );
			
			self.objpoints[self.objpoints.size] = newobjpoint;
		}
	}
}

clearPlayerObjpoints()
{
	for( i = 0; i < self.objpoints.size; i++ )
		self.objpoints[i] destroy();
	
	self.objpoints = [];
}

createWayPoint( name, origin, shader ) 
{	
	objWaypoint = newHudElem();
	objWaypoint.name = name;
	objWaypoint.x	= origin[0];
	objWaypoint.y	= origin[1];
	objWaypoint.z	= origin[2];
	objWaypoint.archived = false;
	objWaypoint.alpha = .61;
	objWaypoint setShader( shader, level.objpoint_scale, level.objpoint_scale );
	objWaypoint setwaypoint( true );
	
	level.objWaypoint[level.objWaypoint.size] = objWaypoint;
}

deleteWaypointByName( name ) 
{
	if( level.hardcore ) return;
	
	if( isDefined( level.objWaypoint ) && level.objWaypoint.size > 0 ) 
	{
		for( i=0; i < level.objWaypoint.size; i++ ) 
		{
			if( isDefined( level.objWaypoint[i].name ) && level.objWaypoint[i].name == name ) 
			{
				level.objWaypoint[i] destroy();
				level.objWaypoint[i].name = undefined;
			}
		}
		
		new_ar = [];
		
		for( i=0; i < level.objWaypoint.size; i++ ) 
		{
			if( isDefined( level.objWaypoint[i].name ) ) new_ar[new_ar.size] = level.objWaypoint[i];			
		}
		
		level.objWaypoint = new_ar;
	}
}

deleteWaypoints() 
{
	if( isDefined( level.objWaypoint ) && level.objWaypoint.size > 0 )  
	{
		for( i=0; i < level.objWaypoint.size; i++ ) 
		{
			if( isDefined( level.objWaypoint[i].name ) )
			{
				level.objWaypoint[i] destroy();
				level.objWaypoint[i].name = undefined;
			}
		}
	}
 
}

//########################## COD4 STUFF ##############################################

createTeamObjpoint( name, origin, team, shader, alpha, scale )
{
	if( level.hardcore ) return( undefined );
	
	assert( team == "axis" || team == "allies" || team == "all" );
	
	objPoint = getObjPointByName( name );
	
	if( isDefined( objPoint ) )
		deleteObjPoint( objPoint );
	
	if( !isDefined( shader ) )
		shader = "objpoint_default";

	if( !isDefined( scale ) )
		scale = 1.0;
		
	if( team != "all" )
		objPoint = newTeamHudElem( team );
	else
		objPoint = newHudElem();
	
	objPoint.name = name;
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	objPoint.team = team;
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, level.objPointSize, level.objPointSize );
	objPoint setWaypoint( true );
	
	if ( isDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = level.objpoint_alpha_default;
	objPoint.baseAlpha = objPoint.alpha;
		
	objPoint.index = level.objPointNames.size;
	level.objPoints[name] = objPoint;
	level.objPointNames[level.objPointNames.size] = name;
	
	return objPoint;
}

deleteObjPoint( oldObjPoint )
{
	assert( level.objPoints.size == level.objPointNames.size );
	
	if ( level.objPoints.size == 1 )
	{
		assert( level.objPointNames[0] == oldObjPoint.name );
		assert( isDefined( level.objPoints[oldObjPoint.name] ) );
		
		level.objPoints = [];
		level.objPointNames = [];
		oldObjPoint destroy();
		return;
	}
	
	newIndex = oldObjPoint.index;
	oldIndex = (level.objPointNames.size - 1);
	
	objPoint = getObjPointByIndex( oldIndex );
	level.objPointNames[newIndex] = objPoint.name;
	objPoint.index = newIndex;
	
	level.objPointNames[oldIndex] = undefined;
	level.objPoints[oldObjPoint.name] = undefined;
	
	oldObjPoint destroy();
}


updateOrigin( origin )
{
	if( !isDefined( origin ) ) return;
	
	if( self.x != origin[0] )
		self.x = origin[0];

	if( self.y != origin[1] )
		self.y = origin[1];

	if( self.z != origin[2] )
		self.z = origin[2];
}


setOriginByName( name, origin )
{
	objPoint = getObjPointByName( name );
	objPoint updateOrigin( origin );
}


getObjPointByName( name )
{
	if( isDefined( level.objPoints[name] ) )
		return level.objPoints[name];
	else
		return undefined;
}

getObjPointByIndex( index )
{
	if( isDefined( level.objPointNames[index] ) )
		return level.objPoints[level.objPointNames[index]];
	else
		return undefined;
}

startFlashing()
{
	self endon( "stop_flashing_thread" );
	
	if( self.isFlashing || level.hardcore )
		return;
	
	self.isFlashing = true;
	
	while( self.isFlashing )
	{
		self fadeOverTime( 0.75 );
		self.alpha = 0.35 * self.baseAlpha;
		wait ( 0.75 );
		
		self fadeOverTime( 0.75 );
		self.alpha = self.baseAlpha;
		wait ( 0.75 );
	}
	
	self.alpha = self.baseAlpha;
}

stopFlashing()
{
	if( !self.isFlashing || level.hardcore )
		return;

	self.isFlashing = false;
}

