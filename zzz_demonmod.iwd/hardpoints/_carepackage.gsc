#include demon\_utils;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_weapons;

setCarePackageGrenade()
{
	if( self IsCarePackTime() )
	{
		ammo = self getAmmoCount( self getSmokeGrenadeType() );
		self takeWeapon( self getSmokeGrenadeType() );

		self GiveWeapon( "carepackage_grenade_mp" );
		self setWeaponClipAmmo( "carepackage_grenade_mp", 1 );
		
		self switchtooffhand( "carepackage_grenade_mp" );

		self ExecClientCommand( "+smoke" );
		wait( 0.05 );
		self ExecClientCommand( "-smoke" );

		wait( 1 );
		
		self TakeWeapon( "carepackage_grenade_mp" );
		self GiveWeapon( self getSmokeGrenadeType() );
		self setWeaponClipammo( self getSmokeGrenadeType(), ammo );
		self switchtooffhand( self getSmokeGrenadeType() );
	}	

}

doCarePackageFX( grenade )
{
	if( !self IsCarePackTime() || !NoHarpointsInProgress() ) return;
	
	wait( 1 );
	
	self.carepackage_fx = spawnStruct();
	self.carepackage_fx.origin = grenade.origin;
	self.carepackage_fx.angles = self.angles;
	self.carepackage_fx = playLoopedFX( level._effect["carepackage_signal_smoke"], 7, self.carepackage_fx.origin );
	self.carepackage_fx playloopsound( "insertiongrenade_explode" );
	
	self spawnCarePackMarker( "carepack_marker", grenade.origin, self.angles, self.carepackage_fx );

	self setClientCvar( "cg_player_carepackage", 0 );
	self setClientCvar( "cg_player_carepackage_count", 0 );

	self.pers["hardPointItem"] = undefined;
	
	self notify( "hardpoint_done" );
	self notify( "hardpoint_used" );
}

spawnCarePackMarker( name, origin, angles, FX )
{
	self notify( "loop_entered" );
	self endon( "loop_entered" );
	
	self.Carepack_marker = spawnStruct();
	self.Carepack_marker = spawn( "script_origin", origin );
	self.Carepack_marker.origin = origin;
	self.Carepack_marker.targetname = name;
	self.Carepack_marker.angles = angles;
	self.Carepack_marker.team = self.pers["team"];
	self.Carepack_marker.owner = self;
	self.Carepack_marker maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( self.Carepack_marker.team, (0,0,20) );
	
	angle = randomInt( 360 );
	self.Carepack_marker thread createPlane( origin, angle, self.Carepack_marker.owner, FX );
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

createPlane( targetpos, planeAngle, owner, FX )
{
	level endon( "carepackage_over" );
	
	level.carepackInProgress = true;

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

	stenpos = hardpoints\_airstrike::getPlaneStartEnd( droppos, planeAngle );
	stenpos2 = hardpoints\_airstrike::getPlaneStartEnd( stenpos[1], planeAngle );
	
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

	planeSpeed = 30; 
	flighttime = calcTime( planeStartPoint, planeEndPoint, planeSpeed );
	plane moveto( planeEndPoint, flighttime );

	plane.isdroping = false;

	for( i = 0; i < flighttime; i += 0.1 )
	{	
		if( !plane.isdroping && ( distance( plane.origin, droppos ) < 100 ) )
		{
			plane thread carepackageSetup( owner, targetpos, self, FX );
			plane.isdroping = true;
		}
		
		wait( 0.1 );
	}

	if( isDefined( plane.planeSound ) )
	{
		plane.planeSound stopLoopSound();
		plane.planeSound delete();
	}

	if( isDefined( plane ) ) plane delete();
	
	level notify( "carepackage_over" );
	
	level.carepackInProgress = undefined;

}

carepackageSetup( owner, targetpos, entity, FX )
{
	PackagePosition = CalcPackagePos( targetPos );
	self thread dropPackage( owner, PackagePosition, entity, FX );
}

CalcPackagePos( targetPos )
{	
	PackagePos = targetPos;
	angle = randomfloat( 360 );
	radius = 150;
	randomOffset = ( cos( angle ) * radius, sin( angle ) * radius, 0 );
	PackagePos += randomOffset;
	startOrigin = PackagePos + (0, 0, 512);
	endOrigin = PackagePos + (0, 0, -2048);

	trace = bulletTrace( startOrigin, endOrigin, false, undefined );
	if( trace["fraction"] < 1.0 )
		PackagePos = trace["position"];
	else
		PackagePos = undefined;
			
	return( PackagePos );
}

dropPackage( owner, PackagePos, entity, FX )
{
	falltime = calcTime( self.origin, PackagePos, 10 );
	
	carepackage = spawn( "script_model", self.origin );
	carepackage setModel( game["carepackage"] );
	carepackage.team = owner.pers["team"];
	
	parachute = spawnStruct();
	parachute.origin = self.origin;
	parachute = spawn_model( game["parachute"], "package", parachute.origin+(0,0,-25), (0,120,90) );
	parachute Linkto( carepackage );
	
	carepackage moveto( PackagePos, falltime );

	wait( falltime );
	
	carepackage thread checkforPlayerBelow( PackagePos );

	if( isdefined( FX ) ) 
	{
		FX stoploopsound( "insertiongrenade_explode" );
		FX delete();
	}
	
	if( isdefined( entity ) ) entity delete();
	
	parachute unLink();
	
	carepackage thread SelectContents();
	carepackage thread carepackage_think();
	
	parachute movez( -50, 3 );
	parachute rotatePitch( 100, 6 );
	parachute waittill( "rotatedone" );
	parachute hide();
	parachute delete();
}

carepackage_think()
{
	carepack_captime = 6;
	radius = 80;
	
	self thread CreateWaypoint();
	
	self.trigger = spawn( "trigger_radius", self.origin, 0, 30, 100 );
	
	self.collision = spawn( "trigger_radius", self.origin, 0, 20, 100 );
	self.collision setContents( 1 );
	
	while( isdefined( self.trigger ) )
	{	
		self.trigger waittill( "trigger", other );
		
		if( isPlayer( other ) )
		{
			while( isAlive( other ) && other isOnGround() && other isTouching( self.trigger ) )
			{							
				other.carepack_progresstime = 0;

				while( isAlive( other ) && other isTouching( self.trigger ) && ( other.carepack_progresstime < carepack_captime ) )
				{
					other.carepack_progresstime += 0.05;
					other updateSecondaryProgressBar( other.carepack_progresstime, carepack_captime, false, game["strings"]["capping_carepackage"] );
					wait( 0.05 );
				}

				other updateSecondaryProgressBar( undefined, undefined, true, undefined );
	
				if( other.carepack_progresstime >= carepack_captime )
				{
					other thread getCarePackContents( self );
					self deleteWaypoint();
					self delete();
					self.trigger delete();
					self.collision delete();
					break;
				}
				else
					continue;
				
				wait( 0.05 );
			}
		}
	}
}

SelectContents()
{
	result = undefined;
	self.carepackItem = undefined;
	
	percentage = randomInt( 100 );
	
	if( percentage < 100 && percentage > 60 ) 		// 40% chance
		result = "resupply";
	else if( percentage < 60 && percentage > 30 ) 	// 30% chance
		result = "scoreupgrade";
	else if( percentage < 30 && percentage > 10 ) 	// 20% chance
		result = "airstrike";
	else if( percentage < 10 ) 						// 10% chance
		result = "artillery";
	else
		result = "resupply";
	
	self.carepackItem = result;
	
	return self.carepackItem;
}

getCarePackContents( carepackage )
{
	switch( carepackage.carepackItem )
	{
		case "resupply":
			self thread ResupplyAmmo();
			break;
				
		case "scoreupgrade":
			self thread DoScoreUpgrade();
			break;
			
		case "airstrike":
			self thread hardpoints\_hardpoints::giveHardpoint( "airstrike_mp" );
			break;
				
		case "artillery":
			self thread hardpoints\_hardpoints::giveHardpoint( "artillery_mp" );
			break;
			
		default:
			break;
	}
}

DoScoreUpgrade()
{
	score = randomIntRange( 1, 5 );
	self.score += score;
	self.pers["score"] = self.score;
	
	self.cur_kill_streak += score;
	self thread hardpoints\_hardpoints::giveHardpointItemForStreak();
	
	self iprintlnbold( "You had a Score Increase" );
}

ResupplyAmmo()
{
	notification = undefined;
	
	//--- Resupply the Primary Slot ---
	if( !self getAmmoCount( self getweaponslotweapon("primary") ) )
	{
		if( level.rank )
		{
			ammo =  self demon\_rank::ranking_GetGunAmmo( self getweaponslotweapon( "primary" ) );
			self setWeaponSlotAmmo( "primary", ammo );		
		}
		else
			self GiveMaxAmmo( self getweaponslotweapon( "primary" ) );
			
		notification = true;
	}
	
	//--- Resupply the Secondary Slot ---
	if( !self getAmmoCount( self getweaponslotweapon("primaryb") ) )
	{
		if( level.rank )
		{
			pistolammo =  self demon\_rank::ranking_GetPistolAmmo( self getweaponslotweapon( "primaryb" ) );
			self setWeaponSlotAmmo( "primaryb", pistolammo );
		}
		else
			self GiveMaxAmmo( self getweaponslotweapon( "primaryb" ) );
		
		notification = true;
	}
	
	//--- Resupply the Frag Class Slot ---
	if( !self getAmmoCount( self getFragGrenadeType() ) )
	{
		self setweaponclipammo( self getFragGrenadeType(), self getFragCount() );
		
		notification = true;
	}
	
	//--- Resupply the Smoke Class Slot ---
	if( !self getAmmoCount( self getSmokeGrenadeType() ) )
	{
		self setweaponclipammo( self getSmokeGrenadeType(), self getSmokeCount() );
		
		notification = true;
	}
	
	//--- Resupply the Tripwire Count ---
	if( self hasPerk( "specialty_weapon_tripwire" ) && !self.pers["tripwire_count"] )
	{
		self.pers["tripwire_count"] = 2;
		
		notification = true;
	}
	
	//--- Resupply the Betty Count ---
	if( self hasPerk( "specialty_weapon_betty" ) && !self.pers["landmine_count"] )
	{
		self.pers["landmine_count"] = 2;
		
		notification = true;
	}
	
	if( isDefined( notification ) )
		self iprintlnbold( "You had Your Ammo Resupplied" );
}

CreateWaypoint()
{
	if( isdefined( self.carepackage_waypoint ) ) self.carepackage_waypoint destroy();
	
	self.carepackage_waypoint = newHudElem();
	self.carepackage_waypoint.x = self.origin[0];
	self.carepackage_waypoint.y = self.origin[1];
	self.carepackage_waypoint.z = self.origin[2]+30;
	self.carepackage_waypoint.alpha = .7;
	self.carepackage_waypoint.archived = true;
	self.carepackage_waypoint setShader( getContentWaypoint( self.carepackItem ), 10, 10 );
	self.carepackage_waypoint setwaypoint( true );

}

deleteWaypoint()
{
	if( isdefined( self.carepackage_waypoint ) ) 
		self.carepackage_waypoint destroy();
}

getContentWaypoint( type )
{
	shader = undefined;
	switch( type )
	{
		case "resupply":
			shader = "waypoint_extraammo";
			break;
				
		case "scoreupgrade":
			shader = "waypoint_extradeaths";
			break;
			
		case "airstrike":
			shader = "waypoint_airstrike";
			break;
				
		case "artillery":
			shader = "waypoint_artillery";
			break;
	}
	
	return shader;
}

checkforPlayerBelow( pos )
{
	players = getEntArray( "player", "classname" );
	for( i=0; i < players.size; i++ )
		if( distance( pos, players[i].origin ) < 40 )
			players[i] suicide();
}



