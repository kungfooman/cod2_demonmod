/*************************************
	Original code by DemonSeed
	EDITED for COD2 by Tally
**************************************/

#include demon\_utils;
#include maps\mp\gametypes\_weapons;

dropScavengerPack()
{	
	origin = getGroundpoint( self ); // get the groundpoint for the victim
	
	item_scavenger = spawn( "script_model", (0, 0, 0) );
	item_scavenger setModel( game["scavenger_pack"] );
	item_scavenger.targetname = "scavenger";
	item_scavenger.origin = origin + (35, 0, 0);
	item_scavenger.angles = (0, randomint(360), 90);
	item_scavenger.team = self.pers["team"]; 
	item_scavenger.count = 0;
	
	item_scavenger thread ScavengerPack_Think();
	item_scavenger thread Scavenger_Pack_Life();
}

ScavengerPack_Think()
{
	level endon( "intermission" );
	self endon( "death" );
	
	while( isDefined( self ) )
	{
		if( !isDefined( self ) )
			return;
		
		self hide();
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) 
		{             
			player = players[i];
			
			if( player hasPerk( "specialty_scavenger" ) )
			{
				self showtoplayer( player ); // only show the scavenger packs to those who have the perk
			
				if( isPlayer( player ) && ( player.sessionstate == "playing" && self.team != player.pers["team"] ) && distance( self.origin, player.origin ) < 50 )
					player thread ResupplyAmmo( self );
			}
		}	
		
		wait( 0.05 );
	}
}

Scavenger_Pack_Life()
{
	for( ;; )
	{
		if( !isDefined( self ) ) break;
		self.count++;
		if( self.count >= 15 ) self delete();
		wait( 1 );
	}
}

ResupplyAmmo( item_scavenger )
{
	giveammo = undefined;
	
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
		
		giveammo = true;
	}
	
	//--- Resupply the Secondary Slot ---
	if( !self getAmmoCount( self getweaponslotweapon( "primaryb" ) ) )
	{
		if( level.rank )
		{
			pistolammo =  self demon\_rank::ranking_GetPistolAmmo( self getweaponslotweapon( "primaryb" ) );
			self setWeaponSlotAmmo( "primaryb", pistolammo );
		}
		else
			self GiveMaxAmmo( self getweaponslotweapon( "primaryb" ) );
			
		giveammo = true;
	}
	
	//--- Resupply the Frag Class Slot ---
	if( !self getAmmoCount( self getFragGrenadeType() ) )
	{
		self setweaponclipammo( self getFragGrenadeType(), self getFragCount() );
		giveammo = true;
	}
	
	//--- Resupply the Smoke Class Slot ---
	if( !self getAmmoCount( self getSmokeGrenadeType() ) )
	{
		self setweaponclipammo( self getSmokeGrenadeType(), self getSmokeCount() );
		giveammo = true;
	}
	
	//--- Resupply the Tripwire Count ---
	if( self hasPerk( "specialty_weapon_tripwire" ) && !self.pers["tripwire_count"] )
	{
		self.pers["tripwire_count"] = 2;
		giveammo = true;
	}
	
	//--- Resupply the Betty Count ---
	if( self hasPerk( "specialty_weapon_betty" ) && !self.pers["landmine_count"] )
	{
		self.pers["landmine_count"] = 2;
		giveammo = true;
	}

	if( isdefined( giveAmmo ) )
	{
			
		self playLocalSound( "re_pickup_paper" );		
		self createClientHudElement( "specialty_scavenger", 0, 40, "center", "middle", "center_safearea", "center_safearea", false, "specialty_scavenger", 35, 35, 1, 0.8, 1, 1, 1 );
		self createClientHudElement( "health_cross", -30, 40, "center", "middle", "center_safearea", "center_safearea", false, "health_cross", 15, 15, 1, 0.8, 1, 1, 1 );
			
		wait( 2 );
		
		self deleteClientHudElementbyName( "specialty_scavenger" );
		self deleteClientHudElementbyName( "health_cross" );
		
		if( isDefined( item_scavenger ) )
		item_scavenger delete();
	}
}