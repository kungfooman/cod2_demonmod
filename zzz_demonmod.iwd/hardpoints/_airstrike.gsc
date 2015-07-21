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
		self notify( "end airstrike_WaitForUse" );
	}
}

artillery_binocularhint_hud_destroy()
{	
	if( isdefined( self.binocular_hint ) )
		self.binocular_hint destroy();
}

AirstrikeNotify()
{
	self teamSound( "airstk_ready", 1 );
}

airstrike_DispenseStrike()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self notify( "end airstrike_DispenseStrike" );
	wait 0.1;
	self endon( "end airstrike_DispenseStrike" );

	self thread airstrike_WaitForUse();

	self waittill( "end airstrike_WaitForUse" );

	self thread hardpoints\_hardpoints::RemoveHardpointItem();

}

airstrike_WaitForUse()
{
	self endon( "end airstrike_WaitForUse" );
	self endon( "hardpoint_reset" );

	for( ;; )
	{
		self waittill( "hardpoint_enter" );
		
		self thread airstrike_WaitforBinocularFire();
	}
}

airstrike_WaitforBinocularFire()
{	
	self endon( "airstrike onway" );

	if( self useButtonPressed() )
	{
		targetpos = airstrike_GetTargetedPos();
			
		if( isdefined( targetpos ) ) 
		{
			self thread AnnounceApproach( &"HARDPOINTS_AIRSTRIKE_ONWAY", "airstk_ontheway", 4 );
				
			airstrike = spawn( "script_origin", targetpos );
			airstrike thread CallAirstrike( self );

			if( isdefined( self.binocular_hint ) )
				self.binocular_hint destroy();

			self notify( "end airstrike_WaitForUse" );
			self notify( "airstrike onway" );
			self notify( "hardpoint_exit" );
		}
		else
		{
			self thread AnnounceApproach( &"HARDPOINTS_AIRSTRIKE_NOT_VALID", "airstk_novalid", 3 );
			self notify( "hardpoint_reset" );
		}
	}
}

AnnounceApproach( string, alias, time )
{
	self notify( "announce done" );
	self endon( "announce done" );
	
	self iprintlnbold( string );
	self teamSound( alias, time );
}

airstrike_GetTargetedPos()
{
	startOrigin = self getEye();
	forward = anglesToForward( self getplayerangles() );
	forward = vectorScale( forward, 100000 );
	endOrigin = startOrigin + forward;
	
	trace = bulletTrace( startOrigin, endOrigin, false, self );

	if ( trace["fraction"] == 1.0 || trace["surfacetype"] == "default" )
		return( undefined );
	else
		return( trace["position"] );
}

CallAirstrike( owner )
{
	owner endon( "airstrike_over" );
	
	if( isdefined( level.effects["hardpoint_indicator"] ) &&  level.hardpoint_dropflare )
		playfx( level.effects["hardpoint_indicator"], self.origin );

	wait( 5 );
	
	if( owner.sessionstate != "playing" )
		return;
	
	level.airStrikeInProgress = true;
	
	owner teamSound( "pilot_cmg_target", 4 );

	angle = randomInt( 360 );
	
	for( i=0; i < 2; i++ )
	{
		self thread createPlanes( self.origin , angle, owner );
		wait( randomintrange( 2, 5 ) );
	}

	self waittill( "planes_finished" );

	owner notify( "airstrike_over" );
	level notify( "airstrike_over" );
	self delete();
	
	level.airStrikeInProgress = undefined;
}

getAltitude()
{
	altitude = undefined;
	if( level.script == "mp_trainstation" )
		altitude = 1000;
	else
		altitude = level.demon_vMax[2];
		
	return altitude;
}

createPlanes( targetpos, planeAngle, owner )
{
	level endon( "airstrike_over" );

	if( isPlayer( owner ) && owner.sessionstate == "playing" )
	{
		if( owner.pers["team"] == "axis" ) 
			planeTeam = "axis";
		else 
			planeTeam = "allies";
	}
	else return;

	x = targetpos[0];
	y = targetpos[1];
	z = getAltitude();
	
	if( level.hardpoints_altitude && ( level.hardpoints_altitude < z ) ) 
		z = level.hardpoints_altitude;
		
	droppos = (x,y,z);

	stenpos = getPlaneStartEnd( droppos, planeAngle );
	stenpos2 = getPlaneStartEnd( stenpos[1], planeAngle );
	
	if( stenpos2[2] == 1 ) 
		stenpos[1] = stenpos2[1];

	planeStartPoint = stenpos[0];
	planeEndPoint = stenpos[1];

	if( planeTeam == "axis" )
		planeModel = "xmodel/vehicle_condor";
	else
		planeModel = "xmodel/mebelle1";

	planeSoundChoice = [];
	planeSoundChoice[0] = "stuka_flyby_1";
	planeSoundChoice[1] = "stuka_flyby_2";

	planeSound = planeSoundChoice[ randomInt( planeSoundChoice.size ) ];

	plane = spawn( "script_model", planeStartPoint );
	plane setModel( planeModel );
	plane.angles = plane.angles + (0, planeAngle, 0);
	
	if( planeTeam == "allies" ) 
		plane rotateyaw( 90, .1 );

	plane.planeSound = spawn( "script_model", planeStartPoint - (0,50,0) );
	plane.planeSound linkto( plane );
	plane.planeSound playloopsound( planeSound );

	planeSpeed = 50; 
	flighttime = calcTime( planeStartPoint, planeEndPoint, planeSpeed );
	plane moveto( planeEndPoint, flighttime );

	plane.isbombing = false;

	for( i = 0; i < flighttime; i += 0.1 )
	{	
		if( !plane.isbombing && ( distance( droppos, plane.origin ) < 1500 ) )
		{
			owner teamSound( "fire_away", 1 );
			
			plane thread bombSetup( owner, targetpos );
			
			plane.isbombing = true;
		}
		
		wait( 0.1 );
	}

	if( isDefined( plane.planeSound ) )
	{
		plane.planeSound stopLoopSound();
		plane.planeSound delete();
	}

	if( isDefined( plane ) ) plane delete();
	
	self notify( "planes_finished" );
}

bombSetup( owner, targetpos )
{
	bombcount = 0;
	barrageSize = 4;
	BombPositions = [];
	for( index = 0; index < barrageSize; index++ )
		BombPositions[index] = CalcBombPos( targetPos );

	while( bombcount < barrageSize )
	{
		self thread dropBomb( owner, BombPositions[bombcount] );
		bombcount++;
		wait( 0.2 );
	}
}

CalcBombPos( targetPos )
{	
	BombPos = undefined;
	iterations = 0;
	
	while( !isdefined( BombPos ) && iterations < 4 )
	{
		BombPos = targetPos;
		angle = randomfloat( 360 );
		radius = level.airstrike_radius/2;
		randomOffset = ( cos( angle ) * radius, sin( angle ) * radius, 0 );
		BombPos += randomOffset;
		startOrigin = BombPos + (0, 0, 512);
		endOrigin = BombPos + (0, 0, -10000);

		trace = bulletTrace( startOrigin, endOrigin, false, undefined );
		if ( trace["fraction"] < 1.0 )
			BombPos = trace["position"];
		else
			BombPos = undefined;
		
		iterations++;
	}
	
	return( BombPos );
}

dropBomb( owner, shellTargetPos )
{
	if( !isDefined( self ) ) return;

	falltime = calcTime( self.origin, shellTargetPos, 40 );

	bombsfx[0] = "mortar_incoming1";
	bombsfx[1] = "mortar_incoming2";
	bombsfx[2] = "mortar_incoming3";
	bombsfx[3] = "mortar_incoming4";
	bombsfx[4] = "mortar_incoming5";
	bs = randomInt( bombsfx.size );

	angle = vectorToAngles( vectorNormalize( self.origin - shellTargetPos ) );
	bomb = spawn_model( level.bombModel, "bomb", self.origin, angle );
	bomb playsound( bombsfx[bs] );
	bomb moveto( shellTargetPos, falltime );

	wait( falltime );

	bombsfx[0] = "mortar_explosion1";
	bombsfx[1] = "mortar_explosion2";
	bombsfx[2] = "mortar_explosion3";
	bombsfx[3] = "mortar_explosion4";
	bombsfx[4] = "mortar_explosion5";
	bs = randomInt( bombsfx.size );
	bomb playsound( bombsfx[bs] );

	playfx( level.effects["hardpoint_explosions"], shellTargetPos );

	if( isPlayer( owner ) && owner.sessionstate == "playing" )
		bomb thread scriptedRadiusDamage( owner, undefined, "hardpoint_mp", level.airstrike_radius/2, 500, 400, true );
	else
		bomb thread scriptedRadiusDamage( self, undefined, "hardpoint_mp", level.airstrike_radius/2, 500, 400, true );

	bomb hide();
	wait( 1 );
	bomb delete();
}

getPlaneStartEnd( targetpos, angle )
{
	forwardvector = anglestoforward( (0, angle, 0) );
	backpos = targetpos + vectormulti( forwardvector, -30000 );
	frontpos = targetpos + vectormulti( forwardvector, 30000 );
	fronthit = 0;

	trace = bulletTrace( targetpos, backpos, false, undefined );
	if( trace["fraction"] != 1 ) 
		start = trace["position"];
	else 
		start = backpos;

	trace = bulletTrace( targetpos, frontpos, false, undefined );
	if( trace["fraction"] != 1 )
	{
		endpoint = trace["position"];
		fronthit = 1;
	}
	else 
		endpoint = frontpos;

	startpos = start + vectormulti( forwardvector, -3000 );
	endpoint = endpoint + vectormulti( forwardvector, 3000 );
	stenpos[0] = startpos;
	stenpos[1] = endpoint;
	stenpos[2] = fronthit;
	return stenpos;
}

teamSound( aliasPart, waitTime )
{
	if( self.pers["team"] == "allies" )
	{
		switch( game["allies"] )
		{
			case "american":
				self playLocalSound( "us_" + aliasPart );
				wait( waitTime );
				break;
				
			case "british":
				self playLocalSound( "uk_" + aliasPart );
				wait( waitTime );
				break;
				
			default:
				self playLocalSound( "ru_" + aliasPart );
				wait( waitTime );
				break;
		}
	}
	else
	{
		self playLocalSound("ge_" + aliasPart);
		wait( waitTime );
	}
}

vectorMulti( vec, size )
{
	x = vec[0] * size;
	y = vec[1] * size;
	z = vec[2] * size;
	vec = (x,y,z);
	return vec;
}

