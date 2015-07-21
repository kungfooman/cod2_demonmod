/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include maps\mp\_utility;
#include demon\_utils;

init()
{
	//--- ALLIED WEAPONS ---
	switch( game["allies"] )
	{
		case "american":
			demonPrecacheItem( "frag_grenade_american_mp" );
			demonPrecacheItem( "colt_mp" );
			demonPrecacheItem( "m1carbine_mp" );
			demonPrecacheItem( "m1garand_mp" );
			demonPrecacheItem( "thompson_mp" );
			demonPrecacheItem( "bar_mp" );
			demonPrecacheItem( "springfield_mp" );
			demonPrecacheItem( "greasegun_mp" );
			demonPrecacheItem( "springfield_scope_mp" );
			demonPrecacheItem( "30cal_mp" );
			break;

		case "british":
			demonPrecacheItem( "frag_grenade_british_mp" );
			demonPrecacheItem( "webley_mp" );
			demonPrecacheItem( "enfield_mp" );
			demonPrecacheItem( "sten_mp" );
			demonPrecacheItem( "bren_mp" );
			demonPrecacheItem( "enfield_scope_mp" );
			demonPrecacheItem( "m1garand_mp" );
			demonPrecacheItem( "thompson_mp" );
			demonPrecacheItem( "30cal_mp" );
			break;

		case "russian":
			demonPrecacheItem( "frag_grenade_russian_mp" );
			demonPrecacheItem( "TT30_mp" );
			demonPrecacheItem( "mosin_nagant_mp" );
			demonPrecacheItem( "SVT40_mp" );
			demonPrecacheItem( "pps42_mp" );
			demonPrecacheItem( "ppsh_mp" );
			demonPrecacheItem( "mosin_nagant_sniper_mp" );
			demonPrecacheItem( "dp28_mp" );
			demonPrecacheItem( "ptrs_mp" );
			break;
	}
	
	//--- ALLIED SMOKE GRENADE ---
	demonPrecacheItem( "smoke_grenade_allied_mp" );

	//--- GERMAN WEAPONS ---
	{
		demonPrecacheItem( "frag_grenade_german_mp" );
		demonPrecacheItem( "smoke_grenade_german_mp" );
		demonPrecacheItem( "luger_mp" );
		demonPrecacheItem( "kar98k_mp" );
		demonPrecacheItem( "g43_mp" );
		demonPrecacheItem( "mp40_mp" );
		demonPrecacheItem( "mp44_mp" );
		demonPrecacheItem( "kar98k_sniper_mp" );
		demonPrecacheItem(  "mg42_mp" );
		demonPrecacheItem(  "fg42_mp" );
	}
	
	//--- SHOTGUN FOR BOTH TEAMS ---
	demonPrecacheItem( "shotgun_mp" );
	
	//--- NEW WEAPONS FOR BOTH TEAMS ---
	demonPrecacheItem( "binoculars_mp" );
	demonPrecacheItem( "marty_grenade_mp" );
	demonPrecacheItem( "tabungas_mp" );
	demonPrecacheItem( "stickybomb_mp" );
	demonPrecacheItem( "satchel_charge_mp" );
	demonPrecacheItem( "carepackage_grenade_mp" );
	demonPrecacheItem( "hardpoint_mp" );
	demonPrecacheItem( "insertion_grenade_mp" );
	demonPrecacheItem( "magnum_mp" );
	demonPrecacheItem( "knife_mp" );
	
	//--- WEAPONS ARRAY ---
	level.weaponnames = [];
	level.weaponnames[0] = "greasegun_mp";
	level.weaponnames[1] = "m1carbine_mp";
	level.weaponnames[2] = "m1garand_mp";
	level.weaponnames[3] = "springfield_mp";
	level.weaponnames[4] = "thompson_mp";
	level.weaponnames[5] = "bar_mp";
	level.weaponnames[6] = "sten_mp";
	level.weaponnames[7] = "enfield_mp";
	level.weaponnames[8] = "enfield_scope_mp";
	level.weaponnames[9] = "bren_mp";
	level.weaponnames[10] = "PPS42_mp";
	level.weaponnames[11] = "mosin_nagant_mp";
	level.weaponnames[12] = "SVT40_mp";
	level.weaponnames[13] = "mosin_nagant_sniper_mp";
	level.weaponnames[14] = "ppsh_mp";
	level.weaponnames[15] = "mp40_mp";
	level.weaponnames[16] = "kar98k_mp";
	level.weaponnames[17] = "g43_mp";
	level.weaponnames[18] = "kar98k_sniper_mp";
	level.weaponnames[19] = "mp44_mp";
	level.weaponnames[20] = "shotgun_mp";
	level.weaponnames[21] = "fraggrenade";
	level.weaponnames[22] = "smokegrenade";
	level.weaponnames[23] = "springfield_scope_mp";
	level.weaponnames[24] = "30cal_mp";
	level.weaponnames[25] = "dp28_mp";
	level.weaponnames[26] = "mg42_mp";
	level.weaponnames[27] = "ptrs_mp";
	level.weaponnames[28] = "fg42_mp";

	level.weapons = [];
	
	level.weapons["30cal_mp"] = spawnstruct();
	level.weapons["30cal_mp"].server_allowcvar = "scr_allow_30cal";
	level.weapons["30cal_mp"].client_allowcvar = "ui_allow_30cal";
	level.weapons["30cal_mp"].allow_default = 1;

	level.weapons["mg42_mp"] = spawnstruct();
	level.weapons["mg42_mp"].server_allowcvar = "scr_allow_mg42";
	level.weapons["mg42_mp"].client_allowcvar = "ui_allow_mg42";
	level.weapons["mg42_mp"].allow_default = 1;

	level.weapons["fg42_mp"] = spawnstruct();
	level.weapons["fg42_mp"].server_allowcvar = "scr_allow_fg42";
	level.weapons["fg42_mp"].client_allowcvar = "ui_allow_fg42";
	level.weapons["fg42_mp"].allow_default = 1;

	level.weapons["ptrs_mp"] = spawnstruct();
	level.weapons["ptrs_mp"].server_allowcvar = "scr_allow_ptrs";
	level.weapons["ptrs_mp"].client_allowcvar = "ui_allow_ptrs";
	level.weapons["ptrs_mp"].allow_default = 1;

	level.weapons["dp28_mp"] = spawnstruct();
	level.weapons["dp28_mp"].server_allowcvar = "scr_allow_dp28";
	level.weapons["dp28_mp"].client_allowcvar = "ui_allow_dp28";
	level.weapons["dp28_mp"].allow_default = 1;

	level.weapons["springfield_scope_mp"] = spawnstruct();
	level.weapons["springfield_scope_mp"].server_allowcvar = "scr_allow_springfieldsniper";
	level.weapons["springfield_scope_mp"].client_allowcvar = "ui_allow_springfieldsniper";
	level.weapons["springfield_scope_mp"].allow_default = 1;
	
	level.weapons["greasegun_mp"] = spawnstruct();
	level.weapons["greasegun_mp"].server_allowcvar = "scr_allow_greasegun";
	level.weapons["greasegun_mp"].client_allowcvar = "ui_allow_greasegun";
	level.weapons["greasegun_mp"].allow_default = 1;

	level.weapons["m1carbine_mp"] = spawnstruct();
	level.weapons["m1carbine_mp"].server_allowcvar = "scr_allow_m1carbine";
	level.weapons["m1carbine_mp"].client_allowcvar = "ui_allow_m1carbine";
	level.weapons["m1carbine_mp"].allow_default = 1;

	level.weapons["m1garand_mp"] = spawnstruct();
	level.weapons["m1garand_mp"].server_allowcvar = "scr_allow_m1garand";
	level.weapons["m1garand_mp"].client_allowcvar = "ui_allow_m1garand";
	level.weapons["m1garand_mp"].allow_default = 1;

	level.weapons["springfield_mp"] = spawnstruct();
	level.weapons["springfield_mp"].server_allowcvar = "scr_allow_springfield";
	level.weapons["springfield_mp"].client_allowcvar = "ui_allow_springfield";
	level.weapons["springfield_mp"].allow_default = 1;

	level.weapons["thompson_mp"] = spawnstruct();
	level.weapons["thompson_mp"].server_allowcvar = "scr_allow_thompson";
	level.weapons["thompson_mp"].client_allowcvar = "ui_allow_thompson";
	level.weapons["thompson_mp"].allow_default = 1;

	level.weapons["bar_mp"] = spawnstruct();
	level.weapons["bar_mp"].server_allowcvar = "scr_allow_bar";
	level.weapons["bar_mp"].client_allowcvar = "ui_allow_bar";
	level.weapons["bar_mp"].allow_default = 1;

	level.weapons["sten_mp"] = spawnstruct();
	level.weapons["sten_mp"].server_allowcvar = "scr_allow_sten";
	level.weapons["sten_mp"].client_allowcvar = "ui_allow_sten";
	level.weapons["sten_mp"].allow_default = 1;

	level.weapons["enfield_mp"] = spawnstruct();
	level.weapons["enfield_mp"].server_allowcvar = "scr_allow_enfield";
	level.weapons["enfield_mp"].client_allowcvar = "ui_allow_enfield";
	level.weapons["enfield_mp"].allow_default = 1;

	level.weapons["enfield_scope_mp"] = spawnstruct();
	level.weapons["enfield_scope_mp"].server_allowcvar = "scr_allow_enfieldsniper";
	level.weapons["enfield_scope_mp"].client_allowcvar = "ui_allow_enfieldsniper";
	level.weapons["enfield_scope_mp"].allow_default = 1;

	level.weapons["bren_mp"] = spawnstruct();
	level.weapons["bren_mp"].server_allowcvar = "scr_allow_bren";
	level.weapons["bren_mp"].client_allowcvar = "ui_allow_bren";
	level.weapons["bren_mp"].allow_default = 1;

	level.weapons["PPS42_mp"] = spawnstruct();
	level.weapons["PPS42_mp"].server_allowcvar = "scr_allow_pps42";
	level.weapons["PPS42_mp"].client_allowcvar = "ui_allow_pps42";
	level.weapons["PPS42_mp"].allow_default = 1;

	level.weapons["mosin_nagant_mp"] = spawnstruct();
	level.weapons["mosin_nagant_mp"].server_allowcvar = "scr_allow_nagant";
	level.weapons["mosin_nagant_mp"].client_allowcvar = "ui_allow_nagant";
	level.weapons["mosin_nagant_mp"].allow_default = 1;

	level.weapons["SVT40_mp"] = spawnstruct();
	level.weapons["SVT40_mp"].server_allowcvar = "scr_allow_svt40";
	level.weapons["SVT40_mp"].client_allowcvar = "ui_allow_svt40";
	level.weapons["SVT40_mp"].allow_default = 1;

	level.weapons["mosin_nagant_sniper_mp"] = spawnstruct();
	level.weapons["mosin_nagant_sniper_mp"].server_allowcvar = "scr_allow_nagantsniper";
	level.weapons["mosin_nagant_sniper_mp"].client_allowcvar = "ui_allow_nagantsniper";
	level.weapons["mosin_nagant_sniper_mp"].allow_default = 1;

	level.weapons["ppsh_mp"] = spawnstruct();
	level.weapons["ppsh_mp"].server_allowcvar = "scr_allow_ppsh";
	level.weapons["ppsh_mp"].client_allowcvar = "ui_allow_ppsh";
	level.weapons["ppsh_mp"].allow_default = 1;

	level.weapons["mp40_mp"] = spawnstruct();
	level.weapons["mp40_mp"].server_allowcvar = "scr_allow_mp40";
	level.weapons["mp40_mp"].client_allowcvar = "ui_allow_mp40";
	level.weapons["mp40_mp"].allow_default = 1;

	level.weapons["kar98k_mp"] = spawnstruct();
	level.weapons["kar98k_mp"].server_allowcvar = "scr_allow_kar98k";
	level.weapons["kar98k_mp"].client_allowcvar = "ui_allow_kar98k";
	level.weapons["kar98k_mp"].allow_default = 1;

	level.weapons["g43_mp"] = spawnstruct();
	level.weapons["g43_mp"].server_allowcvar = "scr_allow_g43";
	level.weapons["g43_mp"].client_allowcvar = "ui_allow_g43";
	level.weapons["g43_mp"].allow_default = 1;

	level.weapons["kar98k_sniper_mp"] = spawnstruct();
	level.weapons["kar98k_sniper_mp"].server_allowcvar = "scr_allow_kar98ksniper";
	level.weapons["kar98k_sniper_mp"].client_allowcvar = "ui_allow_kar98ksniper";
	level.weapons["kar98k_sniper_mp"].allow_default = 1;

	level.weapons["mp44_mp"] = spawnstruct();
	level.weapons["mp44_mp"].server_allowcvar = "scr_allow_mp44";
	level.weapons["mp44_mp"].client_allowcvar = "ui_allow_mp44";
	level.weapons["mp44_mp"].allow_default = 1;

	level.weapons["shotgun_mp"] = spawnstruct();
	level.weapons["shotgun_mp"].server_allowcvar = "scr_allow_shotgun";
	level.weapons["shotgun_mp"].client_allowcvar = "ui_allow_shotgun";
	level.weapons["shotgun_mp"].allow_default = 1;

	level.weapons["fraggrenade"] = spawnstruct();
	level.weapons["fraggrenade"].server_allowcvar = "scr_allow_fraggrenades";
	level.weapons["fraggrenade"].client_allowcvar = "ui_allow_fraggrenades";
	level.weapons["fraggrenade"].allow_default = 1;

	level.weapons["smokegrenade"] = spawnstruct();
	level.weapons["smokegrenade"].server_allowcvar = "scr_allow_smokegrenades";
	level.weapons["smokegrenade"].client_allowcvar = "ui_allow_smokegrenades";
	level.weapons["smokegrenade"].allow_default = 1;

	for( i = 0; i < level.weaponnames.size; i++ )
	{
		weaponname = level.weaponnames[i];

		if( getCvar( level.weapons[weaponname].server_allowcvar ) == "" )
		{
			level.weapons[weaponname].allow = level.weapons[weaponname].allow_default;
			setCvar( level.weapons[weaponname].server_allowcvar, level.weapons[weaponname].allow );
		}
		else
			level.weapons[weaponname].allow = getCvarInt( level.weapons[weaponname].server_allowcvar );
	}
	
	level thread setUpSidearmArray();
	level thread setUpGrenadeArray();

	level thread onPlayerConnect();
	level thread TrackGrenades();

	for( ;; )
	{
		updateAllowed();
		wait 5;
	}
}

setUpSidearmArray()
{
	level.sidearmArray = [];
	level.sidearmArray[0] = "colt_mp";
	level.sidearmArray[1] = "webley_mp";
	level.sidearmArray[2] = "TT30_mp";
	level.sidearmArray[3] = "luger_mp";
	level.sidearmArray[4] = "magnum_mp";
	level.sidearmArray[5] = "knife_mp";	
}

setUpGrenadeArray()
{
	level.grenadeArray = [];
	level.grenadeArray[0] = "smoke_grenade_allied_mp";
	level.grenadeArray[1] = "smoke_grenade_german_mp";
	level.grenadeArray[2] = "satchel_charge_mp";
	level.grenadeArray[3] = "tabungas_mp";
	level.grenadeArray[4] = "stickybomb_mp";
	level.grenadeArray[5] = "frag_grenade_american_mp";
	level.grenadeArray[6] = "frag_grenade_british_mp";
	level.grenadeArray[7] = "frag_grenade_russian_mp";
	level.grenadeArray[8] = "frag_grenade_german_mp";
	level.grenadeArray[9] = "insertion_grenade_mp";	
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );

		player.usedweapons = false;

		player thread updateAllAllowedSingleClient();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for( ;; )
	{
		self waittill( "spawned_player" );

		self thread watchWeaponUsage();
		
		self thread watchWeaponChange();
		self thread detectWeaponChange();
		self thread WatchGrenades();
		self thread MonitorFiring();
	}
}

givePistol()
{
	// check if they have a CAC sidearm
	if( self.pers["sidearm"] == "" )
	{
		weapon2 = self getweaponslotweapon( "primaryb" );
		if( weapon2 == "none" )
		{
			if( self.pers["team"] == "allies" )
			{
				switch( game["allies"] )
				{
				case "american":
					pistoltype = "colt_mp";
					break;

				case "british":
					pistoltype = "webley_mp";
					break;

				default:
					assert( game["allies"] == "russian" );
					pistoltype = "TT30_mp";
					break;
				}
			}
			else
			{
				assert( self.pers["team"] == "axis" );
				switch( game["axis"] )
				{
				default:
					assert( game["axis"] == "german" );
					pistoltype = "luger_mp";
					break;
				}
			}
			
			for( i=0; i < level.sidearmArray.size; i++ )
				self takeWeapon( level.sidearmArray[i] );

			self setWeaponSlotWeapon( "primaryb", pistoltype );
			self giveMaxAmmo( pistoltype );
		}
	}
	else // if they do, give them the CAC sidearm rather than the default team pistol
	{
		for( i=0; i < level.sidearmArray.size; i++ )
			self takeWeapon( level.sidearmArray[i] );

		self setWeaponSlotWeapon( "primaryb", self.pers["sidearm"] );
		self giveMaxAmmo( self.pers["sidearm"] );
	}
}

giveClassGrenades()
{
	//Take All Grenades
	for( i=0; i < level.grenadeArray.size; i++ )
		self takeWeapon( level.grenadeArray[i] );

	//FRAG
	self.fragType = self getFragGrenadeType();
	self.fragType_count = self getFragCount();
	if( self.fragType != "" )
	{
		self giveWeapon( self.fragType );
		self setWeaponClipAmmo( self.fragType, self.fragType_count );
	}
	
	//SMOKE
	self.smokeType = self getSmokeGrenadeType();
	self.smokeType_count = self getSmokeCount();
	if( self.smokeType != "" )
	{
		self giveWeapon( self.smokeType );
		self setWeaponClipAmmo( self.smokeType, self.smokeType_count );
	}
}

getFragGrenadeType()
{
	fragtype = undefined;

	if( self hasPerk( "specialty_weapon_satchel_charge" ) )
		fragtype = "satchel_charge_mp";
	else if( self hasPerk( "specialty_weapon_stickybomb" ) )
		fragtype = "stickybomb_mp";
	else
	{
		if( getCvarInt( "scr_allow_fraggrenades" ) )
			fragtype = self getTeamGrenadeType();
		else
			fragtype = "";
	}
	
	return( fragtype );
}

getSmokeGrenadeType()
{
	smoketype = undefined;
	if( self hasPerk( "specialty_weapon_tabungas" ) )
		smoketype = "tabungas_mp";
	else
	{
		if( self.pers["team"] == "allies" )
		{
			if( getCvarInt( "scr_allow_smokegrenades" ) )
				smoketype = "smoke_grenade_allied_mp";
			else
				smoketype = "";
		}
		else
		{
			if( getCvarInt( "scr_allow_smokegrenades" ) )
				smoketype = "smoke_grenade_german_mp";
			else
				smoketype = "";
		}
	}
		
	return( smoketype );
}

getFragCount()
{
	fragcount = undefined;
	if( self hasPerk( "specialty_weapon_satchel_charge" ) || self hasPerk( "specialty_weapon_stickybomb" ) )
		fragcount = 2;
	else
		fragcount = 1;
		
	return( fragcount );
}

getSmokeCount()
{
	smokecount = undefined;
	if( self hasPerk( "specialty_weapon_tabungas" ) )
		smokecount = 2;
	else
		smokecount = 1;
		
	return( smokecount );
}

dropWeapon()
{
	current = self getcurrentweapon();
	if( CanDropWeapon( current )  )
	{
		weapon1 = self getweaponslotweapon( "primary" );
		weapon2 = self getweaponslotweapon( "primaryb" );

		if( current == weapon1 )
			currentslot = "primary";
		else
		{
			assert( current == weapon2 );
			currentslot = "primaryb";
		}

		clipsize = self getweaponslotclipammo( currentslot );
		reservesize = self getweaponslotammo( currentslot );

		if( clipsize || reservesize )
			self dropItem( current );
	}
}

CanDropWeapon( current )
{
	if( current == "none" || current == "hardpoint_mp" || demon\_sprint::isHoldingSprintWeapon( current ) )
		return false;
	
	return true;
}

dropOffhand()
{
	current = self getcurrentoffhand();
	if(current != "none")
	{
		ammosize = self getammocount( current );

		if( ammosize )
			self dropItem( current );
	}
}

isPistol( weapon )
{
	switch( weapon )
	{
		case "colt_mp":
		case "webley_mp":
		case "luger_mp":
		case "TT30_mp":
		case "magnum_mp":
		case "knife_mp":
			return true;
			
		default:
			return false;
	}
}

isMainWeapon( weapon )
{
	// Include any main weapons that can be picked up

	switch( weapon )
	{
		case "greasegun_mp":
		case "m1carbine_mp":
		case "m1garand_mp":
		case "thompson_mp":
		case "bar_mp":
		case "springfield_mp":
		case "springfield_scope_mp":
		case "sten_mp":
		case "enfield_mp":
		case "bren_mp":
		case "enfield_scope_mp":
		case "mosin_nagant_mp":
		case "SVT40_mp":
		case "PPS42_mp":
		case "ppsh_mp":
		case "mosin_nagant_sniper_mp":
		case "kar98k_mp":
		case "g43_mp":
		case "mp40_mp":
		case "mp44_mp":
		case "kar98k_sniper_mp":
		case "shotgun_mp":
		case "30cal_mp":
		case "dp28_mp":
		case "mg42_mp":
		case "fg42_mp":
		case "ptrs_mp":
			return true;
			
		default:
			return false;
	}
}

restrictWeaponByServerCvars( response )
{
	switch( response )
	{
	// American
	case "m1carbine_mp":
		if( !getcvarint("scr_allow_m1carbine") )
		{
			//self iprintln(&"MP_M1A1_CARBINE_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "m1garand_mp":
		if( !getcvarint("scr_allow_m1garand") )
		{
			//self iprintln(&"MP_M1_GARAND_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "thompson_mp":
		if( !getcvarint("scr_allow_thompson") )
		{
			//self iprintln(&"MP_THOMPSON_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "bar_mp":
		if( !getcvarint("scr_allow_bar") )
		{
			//self iprintln(&"MP_BAR_IS_A_RESTRICTED_WEAPON");
			response = "restricted";
		}
		break;

	case "springfield_mp":
		if( !getcvarint("scr_allow_springfield") )
		{
			//self iprintln(&"MP_SPRINGFIELD_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "springfield_scope_mp":
		if( !getcvarint("scr_allow_springfieldsniper") )
		{
			//self iprintln(&"MP_SPRINGFIELD_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "greasegun_mp":
		if( !getcvarint("scr_allow_greasegun") )
		{
			//self iprintln(&"MP_GREASEGUN_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "30cal_mp":
		if( !getcvarint("scr_allow_30cal") )
		{
			//self iprintln(&"MP_GREASEGUN_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "shotgun_mp":
		if( !getcvarint("scr_allow_shotgun") )
		{
			//self iprintln(&"MP_SHOTGUN_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	// British
	case "enfield_mp":
		if( !getcvarint("scr_allow_enfield") )
		{
			//self iprintln(&"MP_LEEENFIELD_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "sten_mp":
		if( !getcvarint("scr_allow_sten") )
		{
			//self iprintln(&"MP_STEN_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "bren_mp":
		if( !getcvarint("scr_allow_bren") )
		{
			//self iprintln(&"MP_BREN_LMG_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "enfield_scope_mp":
		if( !getcvarint("scr_allow_enfieldsniper") )
		{
			//self iprintln(&"MP_BREN_LMG_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	// Russian
	case "mosin_nagant_mp":
		if( !getcvarint("scr_allow_nagant") )
		{
			//self iprintln(&"MP_MOSINNAGANT_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "SVT40_mp":
		if( !getcvarint("scr_allow_svt40") )
		{
			//self iprintln(&"MP_MOSINNAGANT_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "PPS42_mp":
		if( !getcvarint("scr_allow_pps42") )
		{
			//self iprintln(&"MP_PPSH_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "ppsh_mp":
		if( !getcvarint("scr_allow_ppsh") )
		{
			//self iprintln(&"MP_PPSH_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "mosin_nagant_sniper_mp":
		if( !getcvarint("scr_allow_nagantsniper") )
		{
			//self iprintln(&"MP_SCOPED_MOSINNAGANT_IS");
			response = "restricted";
		}
		break;

	case "dp28_mp":
		if( !getcvarint( "scr_allow_dp28" ) )
		{
			//self iprintln(&"MP_SCOPED_MOSINNAGANT_IS") ;
			response = "restricted";
		}
		break;

	case "ptrs_mp":
		if( !getcvarint( "scr_allow_ptrs" ) )
		{
			//self iprintln(&"MP_SCOPED_MOSINNAGANT_IS");
			response = "restricted";
		}
		break;

	// German
	case "kar98k_mp":
		if( !getcvarint("scr_allow_kar98k") )
		{
			//self iprintln(&"MP_KAR98K_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "g43_mp":
		if( !getcvarint("scr_allow_g43") )
		{
			//self iprintln(&"MP_KAR98K_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "mp40_mp":
		if( !getcvarint("scr_allow_mp40") )
		{
			//self iprintln(&"MP_MP40_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "mp44_mp":
		if( !getcvarint("scr_allow_mp44") )
		{
			//self iprintln(&"MP_MP44_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "kar98k_sniper_mp":
		if( !getcvarint("scr_allow_kar98ksniper") )
		{
			//self iprintln(&"MP_SCOPED_KAR98K_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "mg42_mp":
		if( !getcvarint("scr_allow_mg42") )
		{
			//self iprintln(&"MP_SCOPED_KAR98K_IS_A_RESTRICTED");
			response = "restricted";
		}
		break;

	case "fg42_mp":
		if( !getcvarint( "scr_allow_fg42" ) )
		{
			//self iprintln(&"MP_SCOPED_MOSINNAGANT_IS");
			response = "restricted";
		}
		break;
		
	//Genric
	case "fraggrenade":
		if( !getcvarint("scr_allow_fraggrenades") )
		{
			//self iprintln("Frag grenades are restricted");
			response = "restricted";
		}
		break;

	case "smokegrenade":
		if( !getcvarint("scr_allow_smokegrenades") )
		{
			//self iprintln("Smoke grenades are restricted");
			response = "restricted";
		}
		break;

	default:
		//self iprintln(&"MP_UNKNOWN_WEAPON_SELECTED");
		response = "restricted";
		break;
	}

	return( response );
}

// TODO: This doesn't handle offhands
watchWeaponUsage()
{
	self endon( "spawned_player");
	self endon( "disconnect" );

	self.usedweapons = false;

	while( self attackButtonPressed() )
		wait( .05 );

	while( !( self attackButtonPressed() ) )
		wait( .05 );

	self.usedweapons = true;
}

getWeaponName(weapon)
{
	switch( weapon )
	{
	// American
	case "m1carbine_mp":
		weaponname = &"WEAPON_M1A1CARBINE";
		break;

	case "m1garand_mp":
		weaponname = &"WEAPON_M1GARAND";
		break;

	case "thompson_mp":
		weaponname = &"WEAPON_THOMPSON";
		break;

	case "bar_mp":
		weaponname = &"WEAPON_BAR";
		break;

	case "springfield_mp":
		weaponname = &"WEAPON_SPRINGFIELD";
		break;

	case "springfield_scope_mp":
		weaponname = &"MYWEAPONS_SPRINGFIELD_SCOPE";
		break;

	case "greasegun_mp":
		weaponname = &"WEAPON_GREASEGUN";
		break;

	case "30cal_mp":
		weaponname = &"MYWEAPONS_30CAL";
		break;

	// British
	case "enfield_mp":
		weaponname = &"WEAPON_LEEENFIELD";
		break;

	case "sten_mp":
		weaponname = &"WEAPON_STEN";
		break;

	case "bren_mp":
		weaponname = &"WEAPON_BREN";
		break;

	case "enfield_scope_mp":
		weaponname = &"WEAPON_SCOPEDLEEENFIELD";
		break;

	// Russian
	case "mosin_nagant_mp":
		weaponname = &"WEAPON_MOSINNAGANT";
		break;

	case "SVT40_mp":
		weaponname = &"WEAPON_SVT40";
		break;

	case "PPS42_mp":
		weaponname = &"WEAPON_PPS42";
		break;

	case "ppsh_mp":
		weaponname = &"WEAPON_PPSH";
		break;

	case "mosin_nagant_sniper_mp":
		weaponname = &"WEAPON_SCOPEDMOSINNAGANT";
		break;

	case "dp28_mp":
		weaponname = &"MYWEAPONS_DP28";
		break;

	case "ptrs_mp":
		weaponname = &"MYWEAPONS_PTRS41";
		break;

	//German
	case "kar98k_mp":
		weaponname = &"WEAPON_KAR98K";
		break;

	case "g43_mp":
		weaponname = &"WEAPON_G43";
		break;

	case "mp40_mp":
		weaponname = &"WEAPON_MP40";
		break;

	case "mp44_mp":
		weaponname = &"WEAPON_MP44";
		break;

	case "kar98k_sniper_mp":
		weaponname = &"WEAPON_SCOPEDKAR98K";
		break;

	case "mg42_mp":
		weaponname = &"MYWEAPONS_MG42";
		break;

	case "fg42_mp":
		weaponname = &"MYWEAPONS_FG42";
		break;
	
	// Generic
	case "shotgun_mp":
		weaponname = &"WEAPON_SHOTGUN";
		break;
		
	case "hardpoint_mp":
		weaponname = &"MYWEAPONS_HARDPOINT";
		break;
	
	// Default
	default:
		weaponname = &"WEAPON_UNKNOWNWEAPON";
		break;
	}

	return( weaponname );
}

useAn( weapon )
{
	switch( weapon )
	{
	case "m1carbine_mp":
	case "m1garand_mp":
	case "mp40_mp":
	case "mp44_mp":
	case "shotgun_mp":
		result = true;
		break;

	default:
		result = false;
		break;
	}

	return result;
}

updateAllowed()
{
	for( i = 0; i < level.weaponnames.size; i++ )
	{
		weaponname = level.weaponnames[i];

		cvarvalue = getCvarInt( level.weapons[weaponname].server_allowcvar );
		if( level.weapons[weaponname].allow != cvarvalue )
		{
			level.weapons[weaponname].allow = cvarvalue;

			thread updateAllowedAllClients( weaponname );
		}
	}
}

updateAllowedAllClients( weaponname )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
		players[i] updateAllowedSingleClient( weaponname );
}

updateAllowedSingleClient( weaponname )
{
	self setClientCvar( level.weapons[weaponname].client_allowcvar, level.weapons[weaponname].allow );
}

updateAllAllowedSingleClient()
{
	for( i = 0; i < level.weaponnames.size; i++ )
	{
		weaponname = level.weaponnames[i];
		self updateAllowedSingleClient( weaponname );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// CUSTOM UTILITIES ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
MonitorFiring()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if( !level.longrange_sniper ) return;

	for( ;; )
	{
		if( self attackButtonPressed() )
			self notify( "begin_firing" );
			
		wait( 0.05 );
	}
}

//======================================
//			GRENADE FUNCTIONS
//======================================

/************************************
	This function is snaffled from 
	the eXtreme+ mod for COD2
*************************************/
TrackGrenades()
{
	for( ;; )
	{
		nades = getentarray( "grenade", "classname" );
		if( isDefined( nades ) )
		{
			for( i = 0; i < nades.size; i++ )
			{
				nade = nades[i];
				if( !isDefined( nade.monitored ) )
					nade thread monitorNade();
			}
		}

		wait( 0.05 );
	}
}

/************************************
	This function is snaffled from 
	the eXtreme+ mod for COD2
*************************************/
monitorNade()
{
	self.monitored = true;
	
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if( self istouching( player ) )
			self.nadeThrower = player;
	}

	if( !isDefined( self.nadeThrower ) ) return;

	if( !isAlive( self.nadeThrower ) )
	{
		if( isDefined( self ) ) 
			self delete();
		return;
	}

	self.nadeType = self.nadeThrower getcurrentoffhand();
	self.nadeThrower notify( "grenade_thrown", self, self.nadeType );
	
}

/************************************
	This function is mine - it picks
	up on a player's thrown grenade
	and threads to various methods
*************************************/
WatchGrenades()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "grenade_thrown", grenade, grenadeType );
		
		if( grenadeType == "insertion_grenade_mp" )
			self thread perks\_tactical_insertion::doInsertionFX( grenade );
			
		if( grenadeType == "carepackage_grenade_mp" )
			self thread hardpoints\_carepackage::doCarePackageFX( grenade );
		
		if( isTabunGrenade( grenadeType ) )
			self thread perks\_tabungas::StartTabunGas( grenade, grenadeType );

		if( isSatchelCharge( grenadeType ) )
		{
			targetpos = self perks\_satchel_charge::GetTargetedWall();
			if( isdefined( targetpos ) )
				self thread perks\_satchel_charge::Stick_Satchel( targetpos, grenade, grenadeType );
		}

		if( isStickyGrenade( grenadeType ) )
		{
			targetpos = self perks\_stickybomb::GetTargetedWall();
			if( isdefined( targetpos ) )
				self thread perks\_stickybomb::Sticky( targetpos, grenade, grenadeType );
		}
		
	}
}

//======================================
//			WEAPON FUNCTIONS
//======================================

/************************************
	This function is mine - it tracks
	a player's weapon change
*************************************/
watchWeaponChange()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for( ;; )
	{
		old_weapon = self getCurrentWeapon();
		wait( 0.10 );
		new_weapon = self getCurrentWeapon();
		
		if( new_weapon != old_weapon )
			self notify( "weapon_change", new_weapon, old_weapon );
		
	}
}

/************************************
	This function is mine - it picks 
	up a player's weapon change and
	threads to various methods
*************************************/
detectWeaponChange()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	while( true )
	{		
		self waittill( "weapon_change", newWeapon, oldWeapon );
		
		if( newWeapon == "knife_mp" )
			self thread demon\_knife::init_knife();
		else
			self notify( "stop_knife" );
		
		if( newWeapon == self getWeaponSlotWeapon( "primaryb" ) )
			self thread StoreSecondaryWeapon( newWeapon );
		
		if( self.binocular_count == 1 )
		{
			if(	self getWeaponSlotWeapon( "primaryb" ) != "binoculars_mp" )
				self RemoveBinoculars();

			if( oldWeapon == "binoculars_mp" && newWeapon == self getWeaponSlotWeapon( "primary" )  )
				self thread RestoreSecondaryWeapon( oldWeapon );
		}
		
		if( isHardPointItem( newWeapon ) )
		{
			if( isDefined( self.pers["hardPointItem"] ) )
			{
				self setClientCvar( "cg_fovscale", ".80" );
				
				self.hasHardPointItem = true;
				self hardpoints\_hardpoints::triggerHardpoint( self.pers["hardPointItem"] );
				self thread hardpoints\_hardpoints::MonitorBinocularAction( self.pers["hardPointItem"] );
			}
		}
		else
			self.hasHardPointItem = undefined;
		
		// if they swap their hardpoint binoculars for another dropped weapon before they use them, remove their hardpoint
		if( oldweapon == "hardpoint_mp" && isDefined( self.pers["hardPointItem"] ) && self getWeaponSlotWeapon( "primaryb" ) != "hardpoint_mp" )
		{
			self setClientCvar( "cg_player_" + self getHardPointString(), 0 );
			self setClientCvar( "cg_player_" + self getHardPointString() + "_count", 0 );
			self.pers["hardPointItem"] = undefined;
		}
		
	}
}

/******************************************
	This function is mine - it flags
	a player's secondary weapon for 
	use with Officer's binoculars
	
	NB: self.pers["sidearm"], which 
	is used for CAC pistols, is 
	different from self.pers["secondary"]
	
*******************************************/
StoreSecondaryWeapon( Weapon )
{
	if( !isHardPointItem( Weapon ) && Weapon != "binoculars_mp" )
		self.pers["secondary"] = Weapon;
}

/************************************
	This function is mine - it 
	restores a player's secondary
	weapon once Officer's binoculars 
	have been used
*************************************/
RestoreSecondaryWeapon( binoculars )
{
	self setClientCvar( "cg_fovscale", "1" );
	
	self TakeWeapon( binoculars );
	self GiveWeapon( self.pers["secondary"] );
	self setWeaponSlotWeapon( "primaryb", self.pers["secondary"] );	
	self setWeaponSlotAmmo( "primaryb", self.bioculars_ammo_return );
	self setWeaponSlotClipAmmo( "primaryb", self.bioculars_clip_return );
	self.binocular_count = 0;

	self setClientCvar( "cg_player_binoculars_out", 0 );
	self setClientCvar( "cg_player_binoculars", 1 );
}

/******************************
	If they swapped their 
	binoculars for another
	weapon, remove their ability
	to use binoculars.
****************************/
RemoveBinoculars()
{
	self setClientCvar( "cg_player_binoculars", 0 );
	self setClientCvar( "cg_player_binoculars_out", 0 );
	self.binocularsAvailable = undefined;
	self.binocular_count = 0;
}

isHardPointItem( Weapon )
{
	if( Weapon == "hardpoint_mp" )
		return true;
	
	return false;
}

isSatchelCharge( grenadeType )
{
	if( isSubStr( grenadeType, "satchel_charge" ) )
		return true;
		
	return false;
}

isStickyGrenade( grenadeType )
{
	if( isSubStr( grenadeType, "stickybomb" ) )
		return true;
		
	return false;
}

isTabunGrenade( grenadeType )
{
	if( isSubStr( grenadeType, "tabungas" ) )
		return true;
	
	return false;
}



