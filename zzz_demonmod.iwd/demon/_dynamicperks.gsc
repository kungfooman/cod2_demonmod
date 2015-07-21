/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;
#include maps\mp\gametypes\_weapons;

UnlockPerks()
{
	if( isDefined( self.unlockPerks_done ) ) return;
	self.unlockPerks_done = true;
	
	//--- Close all ranking perk unlocks ---
	if( level.rank )
	{
		for( ranks = 1; ranks < 6; ranks++ )
		{
			for( perkNum = 1; perkNum < 4; perkNum++ )
				self setClientCvar( "perk" + perkNum + "_unlock_rank_" + ranks, 0 );
		}
		
		self.perk_unlock = [];
		for( i=1; i < 6; i++ )
			self.perk_unlock[i] = false;
	}
	else
	{
		if( level.dynamic_perks )
		{
			for( ranks = 1; ranks < 6; ranks++ )
			{
				for( perkNum = 1; perkNum < 4; perkNum++ )
					self setClientCvar( "perk"+perkNum+"_unlock_rank_"+ranks, demon\_rank::getPerkAllowDvar( perkNum, ranks ) );
			}
			
			self.perk_unlock = [];
			for( i=1; i < 6; i++ )
				self.perk_unlock[i] = true;	
		}
	}
}

monitorPerkGroup1( response )
{
	if( !level.dynamic_perks )
		return;

	if( !isdefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
		return;
		
	if( !self.perk_unlock[ int( response ) ] )
		return;
	
	self.perk_count = 0;
	old_perk = self.specialty[0];
	fragammo = self getAmmoCount( self getFragGrenadeType() );
	fragType = self getFragGrenadeType();
	smokeammo = self getAmmoCount( self getSmokeGrenadeType() );
	smokeType = self getSmokeGrenadeType();
		
	switch( response )
	{
		//Tripwires x2
		case "1":
			if( !level.perk_allow_tripwire ) return;
			
			if( isSubStr( self.specialty[0], "tipwire" ) )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			if( isDefined( self.perk_abuse ) )
			{
				self iprintlnBold( "Specialty Weapons are limited to one time per spawn" );
				return;
			}
			self.perk_abuse = true;
			
			self.pers["perk1"] = "specialty_weapon_tripwire";
			self.specialty[0] = self.pers["perk1"];
			
			if( fragammo )
			{
				self TakeWeapon( fragType );
				self GiveWeapon( self getFragType() );
				self setweaponclipammo( self getFragType(), 1 );
			}
			
			if( smokeammo )
			{
				self TakeWeapon( smokeType );
				self GiveWeapon( self getsmokeType() );
				self setweaponclipammo( self getsmokeType(), 1 );			
			}
			
			self thread TakeSpecialtyWeapons();
			self thread perks\_tripwire::MonitorTripWires();
			break;

		//Betty x2
		case "2":
			if( !level.perk_allow_betty ) return;
			
			if( isSubStr( self.specialty[0], "betty" ) )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			if( isDefined( self.perk_abuse ) )
			{
				self iprintlnBold( "Specialty Weapons are limited to one time per spawn" );
				return;
			}
			self.perk_abuse = true;

			self.pers["perk1"] = "specialty_weapon_betty";
			self.specialty[0] = self.pers["perk1"];

			if( fragammo )
			{
				self TakeWeapon( fragType );
				self GiveWeapon( self getFragType() );
				self setweaponclipammo( self getFragType(), 1 );
			}
			
			if( smokeammo )
			{
				self TakeWeapon( smokeType );
				self GiveWeapon( self getsmokeType() );
				self setweaponclipammo( self getsmokeType(), 1 );			
			}
			
			self thread TakeSpecialtyWeapons();
			self thread perks\_landmines::Monitorlandmines();
			break;

		//Sticky Bombs x2
		case "3":		
			if( !level.perk_allow_stickybomb ) return;
			
			if( isSubStr( self.specialty[0], "stickybomb" ) )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			if( isDefined( self.perk_abuse ) )
			{
				self iprintlnBold( "Specialty Weapons are limited to one time per spawn" );
				return;
			}
			self.perk_abuse = true;

			if( fragammo )
			{
				self.pers["perk1"] = "specialty_weapon_stickybomb";
				self.specialty[0] = self.pers["perk1"];
			
				if( isSubStr( old_perk, "tabungas" ) && smokeammo )
				{
					self TakeWeapon( smokeType );
					self GiveWeapon( self getSmokeType() );
					self setweaponclipammo( self getSmokeType(), 1 );
				}
			
				self thread TakeSpecialtyWeapons();
				self TakeWeapon( fragType );
				self GiveWeapon( "stickybomb_mp" );
				self setweaponclipammo( "stickybomb_mp", 2 );
			}
			else
			{
				self iprintlnBold( "You Must have at Least 1 Frag Grenade" );
				self.perk_abuse = undefined;
			}
			break;

		//Satchel Charges x2
		case "4":
			if( !level.perk_allow_satchel ) return;
			
			if( self.specialty[0] == "specialty_weapon_satchel_charge" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			if( isDefined( self.perk_abuse ) )
			{
				self iprintlnBold( "Specialty Weapons are limited to one time per spawn" );
				return;
			}
			self.perk_abuse = true;

			if( fragammo )
			{
				self.pers["perk1"] = "specialty_weapon_satchel_charge";
				self.specialty[0] = self.pers["perk1"];
			
				self thread TakeSpecialtyWeapons();

				if( isSubStr( old_perk, "tabungas" ) && smokeammo )
				{
					self TakeWeapon( smokeType );
					self GiveWeapon( self getSmokeType() );
					self setweaponclipammo( self getSmokeType(), 1 );
				}

				self TakeWeapon( fragType );
				self giveWeapon( "satchel_charge_mp" );
				self setweaponclipammo( "satchel_charge_mp", 2 );
			}
			else
			{
				self iprintlnBold( "you must have at least 1 frag grenade" );
				self.perk_abuse = undefined;
			}
			break;
			
		//Tabun Gas x2
		case "5":
			if( !level.perk_allow_tabungas ) return;
			
			if( isSubStr( self.specialty[0], "tabungas" ) )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			if( isDefined( self.perk_abuse ) )
			{
				self iprintlnBold( "Specialty Weapons are limited to one time per spawn" );
				return;
			}
			self.perk_abuse = true;
			
			if( smokeammo )
			{
				self.pers["perk1"] = "specialty_weapon_tabungas";
				self.specialty[0] = self.pers["perk1"];

				if( ( isSubStr( old_perk, "stickybomb" ) || isSubStr( old_perk, "satchel_charge" ) ) && fragammo )
				{
					self TakeWeapon( fragType );
					self GiveWeapon( self getFragType() );
					self setweaponclipammo( self getFragType(), 1 );
				}
			
				self thread TakeSpecialtyWeapons();

				self TakeWeapon( smokeType );
				self GiveWeapon( "tabungas_mp" );
				self setweaponclipammo( "tabungas_mp", 2 );
			}
			else
			{
				self iprintlnBold( "you must have at least 1 smoke grenade" );
				self.perk_abuse = undefined;
			}
			break;
		
	}
	
	perks = maps\mp\gametypes\_class::getPerks( self );
	self maps\mp\gametypes\_class::showPerk( 0, perks[0], -50 );
	self thread maps\mp\gametypes\_class::hidePerksAfterTime( 3.0 );
	self thread maps\mp\gametypes\_class::hidePerksOnDeath();
}

monitorPerkGroup2( response )
{
	if( !level.dynamic_perks )
		return;

	if( !isdefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
		return;

	if( !self.perk_unlock[ int( response ) ] )
		return;
	
	self.perk_count = 0;
	
	switch( response )
	{
		//First Aid
		case "1":
			if( !level.perk_allow_firstaid ) return;
			
			if( self.specialty[1] == "specialty_firstaid" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			self ClearTacticalInsertion();
			
			self.pers["perk2"] = "specialty_firstaid";
			self.specialty[1] = self.pers["perk2"];
			self setFirstAid();
			break;
		
		// Bomb Squad
		case "2":
			if( !level.perk_allow_bombsquad ) return;
			
			if( self.specialty[1] == "specialty_detectexplosives" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self ClearTacticalInsertion();
			self ClearFirstAid();
			
			self.pers["perk2"] = "specialty_detectexplosives";
			self.specialty[1] = self.pers["perk2"];
			break;
			
		//Juggernaut
		case "3":
			if( !level.perk_allow_juggernaut ) return;
			
			if( self.specialty[1] == "specialty_armorvest" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			self ClearTacticalInsertion();
			self ClearFirstAid();

			self.pers["perk2"] = "specialty_armorvest";
			self.specialty[1] = self.pers["perk2"];	
			break;
			
		//Stopping Power
		case "4":
			if( !level.perk_allow_bulletdamage ) return;
			
			if( self.specialty[1] == "specialty_bulletdamage" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			self ClearTacticalInsertion();
			self ClearFirstAid();
			
			self.pers["perk2"] = "specialty_bulletdamage";
			self.specialty[1] = self.pers["perk2"];
			break;

		//Tactical Insertion
		case "5":
			if( !level.perk_allow_insertion ) return;
			
			if( self.specialty[1] == "specialty_tactical_insertion" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self ClearFirstAid();
			
			self.pers["perk2"] = "specialty_tactical_insertion";
			self.specialty[1] = self.pers["perk2"];
			self setClientCvar( "cg_player_insertion", 1 );
			break;
	}

	perks = maps\mp\gametypes\_class::getPerks( self );	
	self maps\mp\gametypes\_class::showPerk( 1, perks[1], -50 );
	self thread maps\mp\gametypes\_class::hidePerksAfterTime( 3.0 );
	self thread maps\mp\gametypes\_class::hidePerksOnDeath();
	
	self BombSquad();

}

monitorPerkGroup3( response )
{
	if( !level.dynamic_perks )
		return;

	if( !isdefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
		return;

	if( !self.perk_unlock[ int( response ) ] )
		return;
		
	switch( response )
	{
		//Martyrdom
		case "1":	
			if( !level.perk_allow_martyrdom ) return;
			
			if( self.specialty[2] == "specialty_grenadepulldeath" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self.pers["perk3"] = "specialty_grenadepulldeath";
			self.specialty[2] = self.pers["perk3"];
			break;
			
		//Endurance
		case "2":
			
			if( self.specialty[2] == "specialty_longersprint" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}

			self.pers["perk3"] = "specialty_longersprint";
			self.specialty[2] = self.pers["perk3"];
			self.sprintTime = self demon\_sprint::getSprintTime();
			break;

		//Sonic Boom
		case "3":
			if( !level.perk_allow_sonicboom ) return;
			
			if( self.specialty[2] == "speicalty_explosivedamage" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self.pers["perk3"] = "specialty_explosivedamage";
			self.specialty[2] = self.pers["perk3"];
			break;
			
		//Hardline
		case "4":	
			if( !level.perk_allow_hardline ) return;
			
			if( self.specialty[2] == "specialty_hardline" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self.pers["perk3"] = "specialty_hardline";
			self.specialty[2] = self.pers["perk3"];			
			break;

		//Scavenger
		case "5":	
			if( !level.perk_allow_scavenger ) return;
			
			if( self.specialty[2] == "specialty_scavenger" )
			{
				self iprintlnBold( "You already have this Perk" );
				return;
			}
			
			self.pers["perk3"] = "specialty_scavenger";
			self.specialty[2] = self.pers["perk3"];		
			break;
	}	

	perks = maps\mp\gametypes\_class::getPerks( self );	
	self maps\mp\gametypes\_class::showPerk( 2, perks[2], -50 );
	self thread maps\mp\gametypes\_class::hidePerksAfterTime( 3.0 );
	self thread maps\mp\gametypes\_class::hidePerksOnDeath();
	
	if( !self hasPerk( "specialty_longersprint" ) && level.allow_sprint )
		self.sprintTime = level.sprint_time;
		
}

getFragType()
{
	return getTeamGrenadeType();
}

getSmokeType()
{
	smoketype = undefined;
	if( self.pers["team"] == "allies" )
		smoketype = "smoke_grenade_allied_mp";
	else
		smoketype = "smoke_grenade_german_mp";
		
	return( smoketype );
}

TakeSpecialtyWeapons()
{
	self.pers["landmine_count"] = 0;
	self.pers["tripwire_count"] = 0;
	self thread setPerkGroup1Cvars();
}

BombSquad()
{	
	if( self hasPerk( "specialty_detectexplosives" ) )
		self.detectExplosives = true;
	else
		self.detectExplosives = undefined;
	self thread perks\_bombsquad::setupBombSquad();
}

ClearTacticalInsertion()
{
	// clear tactical insertion stuff
	self setClientCvar( "cg_player_insertion", 0 );
}

setFirstAid()
{	
	self setClientCvar( "cg_player_firstaid", 1 );
	self setClientCvar( "cg_player_firstaid_value", self.firstaidkits );
	self thread perks\_firstaid::monitorFirstAid();
}

ClearFirstAid()
{
	// clear firstaid stuff
	self setClientCvar( "cg_player_firstaid", 0 );
	self setClientCvar( "cg_player_firstaid_value", 6 );
}

setPerkGroup1Cvars()
{
	if( level.hardcore ) return;
	
	if( self hasPerk( "specialty_weapon_tripwire" ) )
	{
		self setClientCvar( "cg_player_tripwire", 1 );
	}
	else
	{
		self setClientCvar( "cg_player_tripwire", 0 );
	}

	if( self hasPerk( "specialty_weapon_betty" ) )
	{
		if( self.pers["team"] == "allies" )
			self setClientCvar( "cg_player_landmine", "allies" );
		else
			self setClientCvar( "cg_player_landmine", "axis" );
			
		self setClientCvar( "cg_player_landmine_count", 1 );
	}
	else
	{
		self setClientCvar( "cg_player_landmine", "" );
		self setClientCvar( "cg_player_landmine_count", 0 );
	}
}

