/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;
#include maps\mp\gametypes\_weapons;

setInsertionGrenade()
{
	if( !self hasPerk( "specialty_tactical_insertion" ) )
		return;
	
	if( isdefined( self.insertion_done ) ) 
	{
		self iprintlnBold( "You can only have one insertion point" );
		return;
	}

	self takeWeapon( self getSmokeGrenadeType() );

	self GiveWeapon( "insertion_grenade_mp" );
	self setWeaponClipAmmo( "insertion_grenade_mp", 1 );
	
	self switchtooffhand( "insertion_grenade_mp" );

	self ExecClientCommand( "+smoke" );
	wait 0.05;
	self ExecClientCommand( "-smoke" );

	wait( 1 );
	
	self TakeWeapon( "insertion_grenade_mp" );
	self GiveWeapon( self getSmokeGrenadeType() );
	self setWeaponClipammo( self getSmokeGrenadeType(), self getSmokeCount() );
	self switchtooffhand( self getSmokeGrenadeType() );
	
	self.insertion_done = true;
}

doInsertionFX( grenade )
{
	wait( 1 );
	
	self spawnMarker( "marker_"+self getEntityNumber(), grenade.origin, self.angles );
	
	self.flare_fx = spawnStruct();
	self.flare_fx.origin = grenade.origin;
	self.flare_fx.angles = self.angles;
	self.flare_fx = playLoopedFX( level._effect["insertionflare"], 7, self.flare_fx.origin );
	self.flare_fx playloopsound( "insertiongrenade_explode" );
	
	self.insertion_done = true;
}

spawnMarker( name, origin, angles )
{
	self.marker = spawn( "script_origin", origin );
	self.marker.origin = origin;
	self.marker.targetname = name;
	self.marker.angles = angles;
	self.marker.team = self.pers["team"];
	self.marker.owner = self;
	self.marker maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( self.marker.team, (0,0,20) );
}


InsertionMove()
{
	if( isdefined( self.marker ) && self.marker.team == self.pers["team"] )
	{
		self setOrigin( self.marker.origin );
		self SetPlayerAngles( self.marker.angles );
		self iprintlnBold( "Insertion Complete!" );
		self CleanUpMarker( undefined );
	}	
}

CleanUpMarker( switching_team )
{
	if( isdefined( self.flare_fx ) ) 
	{
		self.flare_fx stoploopsound( "insertiongrenade_explode" );
		self.flare_fx delete();
	}
	
	if( isdefined( self.marker ) ) self.marker delete();
	
	if( !isdefined( switching_team ) )
		if( isdefined( self.entityHeadIcons ) ) self maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( "none" );
	
}

