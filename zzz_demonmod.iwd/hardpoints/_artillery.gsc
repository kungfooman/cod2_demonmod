#include demon\_utils;
#include maps\mp\_utility;

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );
	
		player thread onPlayerKilled();
	}
}

onPlayerKilled()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "killed_player" );
		
		self thread artillery_binocularhint_hud_destroy();
		self notify( "end artillery_WaitForUse" );
	}
}

artillery_binocularhint_hud_destroy()
{	
	if( isdefined( self.binocular_hint ) )
		self.binocular_hint destroy();
}

artillery_DispenseStrike()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self notify( "end artillery_DispenseStrike" );
	wait 0.1;
	self endon( "end artillery_DispenseStrike" );

	self thread artillery_WaitForUse();

	self waittill( "end artillery_WaitForUse" );

	self thread hardpoints\_hardpoints::RemoveHardpointItem();
	self setClientCvar( "cg_player_artillery", 0 );
	self setClientCvar( "cg_player_artillery_count", 0 );

}

ArtilleryNotify()
{
	self playLocalSound( "ctf_touchown" );
	self playLocalsound( teamNoticeSound( self.pers["team"] ) );
}

artillery_WaitForUse()
{	
	self endon( "end artillery_WaitForUse" );
	self endon( "hardpoint_reset" );

	for( ;; )
	{		
		self waittill( "hardpoint_enter" );
		
		self thread artillery_WaitforBinocularFire();
	}
}

artillery_WaitforBinocularFire()
{	
	self endon( "artillery fired" );

	if( self useButtonPressed() )
	{
		targetpos = artillery_GetTargetedPos();
		if( isdefined( targetpos ) ) 
		{
			self.enteredArtyLoop = undefined;
				
			self thread AnnounceApproach( &"HARDPOINTS_ARTILLERY_ONWAY" );
				
			artillery = spawn( "script_origin", targetpos );
			artillery thread artillery_FireBarrage( self );

			if( isdefined( self.artillery_available_icon ) )
				self.artillery_available_icon destroy();

			if( isdefined( self.binocular_hint ) )
				self.binocular_hint destroy();

			self notify( "end artillery_WaitForUse" );
			self notify( "artillery fired" );
			self notify( "hardpoint_exit" );
		}
		else
		{
			self thread AnnounceApproach( &"HARDPOINTS_ARTILLERY_NOT_VALID" );
			self notify( "hardpoint_reset" );
		}
	}
}

AnnounceApproach( string )
{	
	self iprintlnbold( string );
}

artillery_GetTargetedPos()
{
	startOrigin = self getEye();
	forward = anglesToForward( self getplayerangles() );
	forward = vectorScale( forward, 100000 );
	endOrigin = startOrigin + forward;
	
	trace = bulletTrace( startOrigin, endOrigin, false, self );

	if ( trace["fraction"] == 1.0 || trace["surfacetype"] == "default" )
		return ( undefined );
	else
		return ( trace["position"] );
}

artillery_FireBarrage( owner)
{
	self notify( "already looping" );
	wait( 0.1 );
	self endon( "already looping" );
	
	if( isdefined( level.effects["hardpoint_indicator"] ) &&  level.hardpoint_dropflare )
		playfx( level.effects["hardpoint_indicator"], self.origin );

	level thread artillery_ShowWarning( self.origin, owner );

	wait( 1 );
	time = 4;
	
	level.artillerystrikeInProgress = true;
	
	while( time )
	{
		self thread artillery_FiringSound();
		wait (.5);
		time -= .5;
	}
	
	barrageSize = 14;
	shellPositions = [];
	for( index = 0; index < barrageSize; index++ )
		shellPositions[index] = artillery_CalcShellPos( self.origin );

	self.artilleryGlobalDelay = 0;
	
	for( index = 0; index < barrageSize; index++ )
	{
		self thread artillery_FireShell( shellPositions[index] , owner);
	}
	
	shellImpacts = 0;
	while( shellImpacts < barrageSize )
	{
		self waittill( "artillery shell impact" );
		shellImpacts++;
	}

	owner notify( "artillery end" );
	self delete();
	
	level.artillerystrikeInProgress = undefined;
}

artillery_ShowWarning( targetpos, owner )
{
	owner endon( "death" );
	
	players = getentarray( "player", "classname" );
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if( player.pers["team"] == owner.pers["team"] && isalive( player ) ) 
			player playLocalSound( getFireSoundtoPlay( owner.pers["team"] ) );
		
		player playLocalSound( "air_raid" );
		
		if( player != owner && player.pers["team"] == owner.pers["team"] && isalive( player ) ) 
		{				
			if( distance( player.origin, targetpos ) < 1000 )
			{
				player playLocalSound( GetWarningSoundtoPlay( player.pers["team"] ) );
				player iprintln( "^1WARNING - ^7artillery in your area!" );
			}
		}
	}
}

artillery_FireShell( shellTargetPos , owner)
{
	shellStartPos = (shellTargetPos[0]-200, shellTargetPos[1]-200, level.demon_vMax[2]);
	
	self.artilleryGlobalDelay += randomFloatRange( .5, 1.5 );
	wait( self.artilleryGlobalDelay );
	wait( randomFloatRange( 1.5, 2.5) );
	
	shellEnt = spawn( "script_origin", shellTargetPos );
	shellEnt.angles = vectorToAngles( vectorNormalize( shellTargetPos - shellStartPos-(800,0,0) ) );
	shellEnt.bomb = spawn_model( level.bombModel, "bomb", shellStartPos+(800,0,0), shellEnt.angles );

	shellEnt playSound( "artillery_incoming" );
	
	shellSpeed = 40;
	shellInAir = calcTime( shellStartPos, shellTargetPos, shellSpeed );
	
	shellEnt.bomb moveto( shellTargetPos, shellInAir );
	
	wait( shellInAir );
	
	shellEnt artillery_ShellImpact( owner );
	shellEnt delete();
	
	if( isdefined( shellEnt.bomb ) ) shellEnt.bomb delete();

	self notify( "artillery shell impact" );
}

artillery_CalcShellPos( targetPos )
{	
	shellPos = undefined;
	iterations = 0;
	
	while( !isdefined( shellPos ) && iterations < 7 )
	{
		shellPos = targetPos;
		angle = randomfloat( 360 );
		radius = randomfloat( level.artillery_offset );
		randomOffset = ( cos( angle ) * radius, sin( angle ) * radius, 0 );
		shellPos += randomOffset;
		startOrigin = shellPos + (0, 0, 512);
		endOrigin = shellPos + (0, 0, -2048);

		trace = bulletTrace( startOrigin, endOrigin, false, undefined );
		if ( trace["fraction"] < 1.0 )
			shellPos = trace["position"];
		else
			shellPos = undefined;
		
		iterations++;
	}
	return( shellPos );
}

artillery_ShellImpact( eAttacker )
{
	playfx( level.effects["hardpoint_explosions"], self.origin );	
	self playSound( "artillery_explosion" );

	earthquake( 0.25, 0.75, self.origin, 4096 );

	sMeansOfDeath = "MOD_EXPLOSIVE";
	iDFlags = 1;
	irange = 400;
	imaxdamage = 280;
	imindamage = 100;

	players = getentarray( "player", "classname" );
	for( i=0; i < players.size; i++ )
	{
		distance = distance( self.origin, players[i].origin );
		if( distance >= irange || players[i].sessionstate != "playing" || !isAlive( players[i] ) )
			continue;

		percent = (irange - distance)/irange;
		iDamage = imindamage + (imaxdamage - imindamage)*percent;

		traceorigin = players[i].origin + (0,0,32);

		trace = bullettrace( self.origin, traceorigin, true, self );

		if( isdefined( trace["entity"] ) && trace["entity"] != players[i] )
			iDamage = iDamage * .7;
		else if( !isdefined( trace["entity"] ) )
			iDamage = iDamage * .3;

		vDir = vectorNormalize( traceorigin - ( self.origin ) );
		
		iDamage = maps\mp\gametypes\_class::modified_damage( players[i], eAttacker, iDamage, sMeansOfDeath );
		
		if( isPlayer( eAttacker ) && eAttacker.sessionstate == "playing" )
			self thread scriptedRadiusDamage( eAttacker, undefined, "hardpoint_mp", irange, imaxdamage, imindamage, true );
		else
			self thread scriptedRadiusDamage( self, undefined, "hardpoint_mp", irange, imaxdamage, imindamage, true );
	}
}

artillery_FiringSound()
{
	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
		players[i] playLocalSound( "artillery_fire" );

}

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// UTILITIES ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

GetFireSoundtoPlay( team )
{
	fire_sound = undefined;
	if( team == "allies" )	
	{
		switch( game["allies"] )
		{
			case "american":
				fire_sound = "us_arty_shot";
				break;
				
			case "british":
				fire_sound = "uk_arty_shot";
				break;
				
			case "russian":
				fire_sound = "ru_arty_shot";
				break;
		}
	}
	else
	{
		fire_sound = "ge_arty_shot";
	}
	
	return fire_sound;
}

GetWarningSoundtoPlay( team )
{
	incoming_sound = undefined;
	if( team == "allies" )	
	{
		switch( game["allies"] )
		{
			case "american":
				incoming_sound = "US_mp_cmd_fallback";
				break;
				
			case "british":
				incoming_sound = "UK_mp_cmd_fallback";
				break;
				
			case "russian":
				incoming_sound = "RU_mp_cmd_fallback";
				break;
		}
	}
	else
	{
		incoming_sound = "GE_mp_cmd_fallback";
	}
	
	return incoming_sound;
}

teamNoticeSound( team )
{
	ready_sound = undefined;
	if( team == "allies" )	
	{
		switch( game["allies"] )
		{
			case "american":
				ready_sound = "us_arty_ready";
				break;
				
			case "british":
				ready_sound = "uk_arty_ready";
				break;
				
			case "russian":
				ready_sound = "ru_arty_ready";
				break;
		}
	}
	else
	{
		ready_sound = "ge_arty_ready";
	}

	return ready_sound;
}