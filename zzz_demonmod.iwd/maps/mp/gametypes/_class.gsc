/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	//--- Class Choice Menu ---
	game["menu_class_allies"] = "class_allies";
	game["menu_class_axis"] = "class_axis";
	
	precacheMenu( game["menu_class_allies"] );
	precacheMenu( game["menu_class_axis"] );
	
	//--- Side Arm Popup Menu ---
	game["menu_popup_sidearm"] = "popup_sidearm";
	precacheMenu( game["menu_popup_sidearm"] );
	
	//-------- Allied Class Menus -----------
	
	switch( game["allies"] )
	{
		case "russian":
			game["menu_engineer_allies"] = "engineer_russian";
			game["menu_assault_allies"] = "assault_russian";
			game["menu_sniper_allies"] = "sniper_russian";
			game["menu_medic_allies"] = "medic_russian";
			game["menu_officer_allies"] = "officer_russian";
			game["menu_gunner_allies"] = "gunner_russian";
			break;

		case "british":
			game["menu_engineer_allies"] = "engineer_british";
			game["menu_assault_allies"] = "assault_british";
			game["menu_sniper_allies"] = "sniper_british";
			game["menu_medic_allies"] = "medic_british";
			game["menu_officer_allies"] = "officer_british";
			game["menu_gunner_allies"] = "gunner_british";
			break;

		default:
			game["menu_engineer_allies"] = "engineer_american";
			game["menu_assault_allies"] = "assault_american";
			game["menu_sniper_allies"] = "sniper_american";
			game["menu_medic_allies"] = "medic_american";
			game["menu_officer_allies"] = "officer_american";
			game["menu_gunner_allies"] = "gunner_american";
			break;
	}
	
	precacheMenu( game["menu_engineer_allies"] );
	precacheMenu( game["menu_assault_allies"] );
	precacheMenu( game["menu_sniper_allies"] );
	precacheMenu( game["menu_medic_allies"] );
	precacheMenu( game["menu_officer_allies"] );
	precacheMenu( game["menu_gunner_allies"] );
	
	//---------------------------------------
	
	//-------- German Class Menus -----------
	
	game["menu_assault_axis"] = "assault_axis";
	game["menu_engineer_axis"] = "engineer_axis";
	game["menu_sniper_axis"] = "sniper_axis";
	game["menu_medic_axis"] = "medic_axis";
	game["menu_officer_axis"] = "officer_axis";
	game["menu_gunner_axis"] = "gunner_axis";
	
	precacheMenu( game["menu_assault_axis"] );
	precacheMenu( game["menu_engineer_axis"] );
	precacheMenu( game["menu_sniper_axis"] );
	precacheMenu( game["menu_medic_axis"] );
	precacheMenu( game["menu_officer_axis"] );
	precacheMenu( game["menu_gunner_axis"] );
	
	//---------------------------------------
	
	//--- Define the Perks ---
	thread PerkIconArray();
	thread PerkNameArray();
	thread PerkAllowDvarArray();
	thread initPerkDvars();
	
	//--- Setup the Class Arrays ---
	thread setUpClassArray();
	
}

PerkIconArray()
{
	level.perkIcons[0] = [];
	level.perkIcons[1] = [];
	level.perkIcons[2] = [];

	level.perkIcons[0][0] = "specialty_weapon_tripwire";
	level.perkIcons[0][1] = "specialty_weapon_betty";
	level.perkIcons[0][2] = "specialty_weapon_stickybomb";
	level.perkIcons[0][3] = "specialty_weapon_satchel_charge";
	level.perkIcons[0][4] = "specialty_weapon_tabungas";
	
	level.perkIcons[1][0] = "specialty_firstaid";
	level.perkIcons[1][1] = "specialty_detectexplosives";
	level.perkIcons[1][2] = "specialty_armorvest";	
	level.perkIcons[1][3] = "specialty_bulletdamage";
	level.perkIcons[1][4] = "specialty_tactical_insertion";

	level.perkIcons[2][0] = "specialty_grenadepulldeath";	
	level.perkIcons[2][1] = "specialty_longersprint";
	level.perkIcons[2][2] = "specialty_explosivedamage";
	level.perkIcons[2][3] = "specialty_hardline";
	level.perkIcons[2][4] = "specialty_scavenger";
	
	for( j=0; j < 3; j++ )
		for( index = 0; index < level.perkIcons[j].size; index++ )
			demonPrecacheShader( level.perkIcons[j][index] );

	demonPrecacheShader( "specialty_null" );
}

PerkNameArray()
{
	level.perkNames[0] = [];
	level.perkNames[1] = [];
	level.perkNames[2] = [];
	
	level.perkNames[0][0] = &"PERKS_TRIPWIRE";
	level.perkNames[0][1] = &"PERKS_WEAPON_BETTY";
	level.perkNames[0][2] = &"PERKS_STICKYBOMB";
	level.perkNames[0][3] = &"PERKS_SATCHELS";
	level.perkNames[0][4] = &"PERKS_TABUNGAS";
	
	level.perkNames[1][0] = &"PERKS_FIRSTAID";
	level.perkNames[1][1] = &"PERKS_DETECTEXPLOSIVES";
	level.perkNames[1][2] = &"PERKS_ARMORVEST";	
	level.perkNames[1][3] = &"PERKS_BULLETDAMAGE";
	level.perkNames[1][4] = &"PERKS_TACTICAL_INSERTION";
	
	level.perkNames[2][0] = &"PERKS_GRANADEPULLDEATH";	
	level.perkNames[2][1] = &"PERKS_LONGERSPRINT";
	level.perkNames[2][2] = &"PERKS_EXPLOSIVEDAMAGE";
	level.perkNames[2][3] = &"PERKS_HARDLINE";
	level.perkNames[2][4] = &"PERKS_SCAVENGER";
	
	for( j=0; j < 3; j++ )
		for( index = 0; index < level.perkNames[j].size; index++ )
			demonPrecacheString( level.perkNames[j][index] );

	demonPrecacheString( &"PERKS_NULL" );
}

PerkAllowDvarArray()
{
	level.perkallow["perk_1"] = [];
	level.perkallow["perk_2"] = [];
	level.perkallow["perk_3"] = [];
	
	// GROUP 1
	level.perkallow["perk_1"][1] = level.perk_allow_tripwire;
	level.perkallow["perk_1"][2] = level.perk_allow_betty;
	level.perkallow["perk_1"][3] = level.perk_allow_stickybomb;
	level.perkallow["perk_1"][4] = level.perk_allow_satchel;
	level.perkallow["perk_1"][5] = level.perk_allow_tabungas;
	
	// GROUP 2
	level.perkallow["perk_2"][1] = level.perk_allow_firstaid;
	level.perkallow["perk_2"][2] = level.perk_allow_bombsquad;
	level.perkallow["perk_2"][3] = level.perk_allow_juggernaut;
	level.perkallow["perk_2"][4] = level.perk_allow_bulletdamage;
	level.perkallow["perk_2"][5] = level.perk_allow_insertion;
	
	//PERK GROUP 3
	level.perkallow["perk_3"][1] = level.perk_allow_martyrdom;
	level.perkallow["perk_3"][2] = level.perk_allow_endurance;
	level.perkallow["perk_3"][3] = level.perk_allow_sonicboom;
	level.perkallow["perk_3"][4] = level.perk_allow_hardline;
	level.perkallow["perk_3"][5] = level.perk_allow_scavenger;
}

setUpClassArray()
{
	level.class_string = [];
	level.class_string[0] = "assault";
	level.class_string[1] = "engineer";
	level.class_string[2] = "gunner";
	level.class_string[3] = "sniper";
	level.class_string[4] = "medic";
	
	level.class_officer_string = [];
	level.class_officer_string[0] = "officer_american";
	level.class_officer_string[1] = "officer_british";
	level.class_officer_string[2] = "officer_russian";
	level.class_officer_string[3] = "officer_german";
}


//==================================================
//=========== MAIN CLASS MENU ======================
//==================================================

menuClass( response )
{
	self unSetClass();
	class = response;
	self setClass( class );

	// set the dvar for smoke grenades
	self setClientCvar( "scr_allow_smokegrenades", level.allow_smoke );

	// set the team string for default sidearm
	self setClientCvar( "ui_player_team", self getTeamStr() );
		
	// setup the sidearm dvar array
	self thread SetSidearm();

	if( level.allow_frags )
	{
		if( response == "officer" )
		{
			if( isSubStr( level.officer_cac_perk1, "satchel_charge" ) || isSubStr( level.officer_cac_perk1, "stickybomb" ) )
				self setClientCvar( "ui_cac_frag", "" );
			else
				self setClientCvar( "ui_cac_frag", getTeamStr() );
		}
		else
			self setClientCvar( "ui_class_frags", getTeamStr() );
	}
	else
	{
		self setClientCvar( "ui_cac_frag", "" );
		self setClientCvar( "ui_class_frags", "" );
	}

	if( level.allow_smoke )
	{
		if( isSubStr( level.officer_cac_perk1, "tabungas" ) )
			self setClientCvar( "ui_cac_smoke", "0" );
		else
			self setClientCvar( "ui_cac_smoke", "1" );
	}
	else
		self setClientCvar( "ui_cac_smoke", "0" );
}

setClass( newClass )
{
	self.class = newClass;
	self.pers["class"] = self.class;
}

getClass()
{
	if( isValidClass( self.pers["class"] ) )
		return self.pers["class"];
	else
		return "assault";
}

unSetClass()
{
	self.class = "";
	self.pers["class"] = "";
	self.pers["savedmodel"] = undefined;

	self.pers["perk1"] = "";
	self.pers["perk2"] = "";
	self.pers["perk3"] = "";

	//--- Set the default Officer Menu Perks ---
	self setClientCvar( "ui_cac_perk1", level.officer_cac_perk1 );
	self setClientCvar( "ui_cac_perk2", level.officer_cac_perk2 );
	self setClientCvar( "ui_cac_perk3", level.officer_cac_perk3 );
}

SetSidearm()
{
	// set the default pistols until a Create-a-Class sidearm is defined
	if( self.pers["sidearm"] == "" )
	{
		if( self.pers["team"] == "allies" )
		{
			switch( game["allies"] )
			{		
				case "british":
					self sidearmDvarArray( "webley" );
					break;
					
				case "russian":
					self sidearmDvarArray( "tokarev" );
					break;
				
				default:
					self sidearmDvarArray( "colt" );
					break;
			}
		}
		else
		{
			self sidearmDvarArray( "walthar" );	
		}
	}
	else // if Create-a-Class sidearm is defined
	{
		sidearm = getSubStr( self.pers["sidearm"], 0, self.pers["sidearm"].size - 3 );
		self sidearmDvarArray( sidearm );
	}
}

sidearmDvarArray( sidearm )
{
	// the sidearm array is defined in demon\_globallogic Player Connect
	for( i=0; i < self.sidearmArray.size; i++ )
		if( isSubStr( self.sidearmArray[i], sidearm ) )
			self setClientCvar( self.sidearmArray[i], "1" );
		else
			self setClientCvar( self.sidearmArray[i], "0" );
}

//==================================================
//========= END MAIN CLASS MENU ====================
//==================================================


//==================================================
//=========== MENU MONITORS ========================
//==================================================

// Monitor for Side Arm Create-a-Class Popup Menu
MonitorSidearm( response )
{
	switch( response )
	{
		case "knife":
			self.pers["sidearm"] = "knife_mp";
			break;
			
		case "magnum":
			self.pers["sidearm"] = "magnum_mp";
			break;	
			
		default:
			self.pers["sidearm"] = "";
			break;
	}
}

// Monitor for Officer Create-a-Class Perk PopUp Menus
MonitorCaCDvars( perkNum, index, response )
{
	for( i=0; i < level.perkIcons[index].size; i++ )
	{
		if( isSubStr( level.perkIcons[index][i], response ) )
		{
			self setClientCvar( "ui_cac_perk" + perkNum, level.perkIcons[index][i] );
			self.pers["perk" + perkNum ] = level.perkIcons[index][i];
		}
	}

	if( perkNum == 1 )
	{
		if( level.allow_frags )
		{
			if( response != "satchel_charge" || response != "stickybomb" )
				self setClientCvar( "ui_cac_frag", self getTeamStr() );
			
			if( response == "satchel_charge" || response == "stickybomb" )
				self setClientCvar( "ui_cac_frag", "" );
		}
		else
			self setClientCvar( "ui_cac_frag", "" );

		if( level.allow_smoke && response != "tabungas" )
			self setClientCvar( "ui_cac_smoke", "1" );
		else
			self setClientCvar( "ui_cac_smoke", "0" );
	}
}

//==================================================
//=========== END MENU MONITORS ====================
//==================================================


//===================================================
//============= LOADOUT FROM SPAWN ==================
//===================================================

GiveLoadOut()
{
	//--- Set the Player Class Models ---
	self thread maps\mp\gametypes\_player_classmodels::init( self getClass() );
	
	//--- Set the Class String Hud ---
	self thread ClassStringHud( self getClass() );

	//--- Set the Class Icon Hud ---
	self setClassHud( self getClass() );
	
	//--- Set the Perks ---
	self SetPerks( self getClass() );
	
	if( level.roundBased )
	{
		if( level.numLives )
		{
			if( isdefined( self.pers["weapon1"] ) && isdefined( self.pers["weapon2"] ) )
			{
				self setWeaponSlotWeapon( "primary", self.pers["weapon1"] );
				self setWeaponSlotAmmo( "primary", 999 );
				self setWeaponSlotClipAmmo( "primary", 999 );

				self setWeaponSlotWeapon( "primaryb", self.pers["weapon2"] );
				self setWeaponSlotAmmo( "primaryb", 999 );
				self setWeaponSlotClipAmmo( "primaryb", 999 );

				self setSpawnWeapon( self.pers["spawnweapon"] );
			}
			else
			{
				self setWeaponSlotWeapon( "primary", self.pers["weapon"] );
				self setWeaponSlotAmmo( "primary", 999 );
				self setWeaponSlotClipAmmo( "primary", 999 );

				self setSpawnWeapon( self.pers["weapon"] );
			}
		}
		else
		{
			self setWeaponSlotWeapon( "primary", self.pers["weapon"] );
			self setWeaponSlotAmmo( "primary", 999 );
			self setWeaponSlotClipAmmo( "primary", 999 );

			self setSpawnWeapon( self.pers["weapon"] );		
		}
	}
	else
	{
		self giveWeapon( self.pers["weapon"] );
		self giveMaxAmmo( self.pers["weapon"] );
		self setSpawnWeapon( self.pers["weapon"] );
	}

	maps\mp\gametypes\_weapons::givePistol();	
	maps\mp\gametypes\_weapons::giveClassGrenades();
	
	// Player flag for use in monitoring officer binoculars. 
	// Not to be confused with the player flag for Side Arm Create-a-Class purposes (self.pers["sidearm"]).
	self.pers["secondary"] = self getWeaponSlotWeapon( "primaryb" );
	
	if( self getClass() == "sniper" )
	{
		self thread demon\_sniperzoom::monitorCurrentWeapon();
		self thread demon\_sniperzoom::monitorUseMeleeKeys();
	}

}

SetPerks( class )
{
	self.specialty = [];
	self.specialty[0] = "specialty_null";
	self.specialty[1] = "specialty_null";
	self.specialty[2] = "specialty_null";
	
	switch( class )
	{
		case "assault":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
			{
				if( level.perk_allow_tabungas )
					self.specialty[0] = "specialty_weapon_tabungas";
				else
					self.specialty[0] = "specialty_null";
			}
			
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
			{
				if( level.perk_allow_bulletdamage )
					self.specialty[1] = "specialty_bulletdamage";
				else
					self.specialty[1] = "specialty_null";
			}
			
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
			{
				if( level.perk_allow_martyrdom )
					self.specialty[2] = "specialty_grenadepulldeath";
				else
					self.specialty[2] = "specialty_null";
			}
			break;
			
		case "engineer":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
			{
				if( level.perk_allow_satchel )
					self.specialty[0] = "specialty_weapon_satchel_charge";
				else
					self.specialty[0] = "specialty_null";
			}
			
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
			{
				if( level.perk_allow_bombsquad )
					self.specialty[1] = "specialty_detectexplosives";
				else
					self.specialty[1] = "specialty_null";
			}
			
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
			{
				if( level.perk_allow_sonicboom )
					self.specialty[2] = "specialty_explosivedamage";
				else
					self.specialty[2] = "specialty_null";
			}
			break;
		
		case "sniper":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
			{
				if( level.perk_allow_tripwire )
					self.specialty[0] = "specialty_weapon_tripwire";
				else
					self.specialty[0] = "specialty_null";
			}
			
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
			{
				if( level.perk_allow_juggernaut )
					self.specialty[1] = "specialty_armorvest";
				else
					self.specialty[1] = "specialty_null";
			}
			
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
			{
				if( level.perk_allow_martyrdom )
					self.specialty[2] = "specialty_grenadepulldeath";
				else
					self.specialty[2] = "specialty_null";
			}
			break;

		case "gunner":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
			{
				if( level.perk_allow_betty )
					self.specialty[0] = "specialty_weapon_betty";
				else
					self.specialty[0] = "specialty_null";
			}
			
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
			{
				if( level.perk_allow_scavenger )
					self.specialty[1] = "specialty_tactical_insertion";
				else
					self.specialty[1] = "specialty_null";
			}
			
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
			{
				if( level.perk_allow_martyrdom )
					self.specialty[2] = "specialty_grenadepulldeath";
				else
					self.specialty[1] = "specialty_null";
			}
			break;
		
		case "medic":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
			{
				if( level.perk_allow_stickybomb )
					self.specialty[0] = "specialty_weapon_stickybomb";
				else
					self.specialty[0] = "specialty_null";
			}
			
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
			{
				if( level.perk_allow_firstaid )
					self.specialty[1] = "specialty_firstaid";
				else
					self.specialty[1] = "specialty_null";
			}
			
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
			{
				if( level.perk_allow_endurance )
					self.specialty[2] = "specialty_longersprint";
				else
					self.specialty[2] = "specialty_null";
			}
			break;
			
		case "officer":
			if( self.pers["perk1"] != "" )
				self.specialty[0] = self.pers["perk1"];
			else
				self.specialty[0] = level.officer_cac_perk1;
			if( self.pers["perk2"] != "" )
				self.specialty[1] = self.pers["perk2"];
			else
				self.specialty[1] = level.officer_cac_perk2;
			if( self.pers["perk3"] != "" )
				self.specialty[2] = self.pers["perk3"];
			else
				self.specialty[2] = level.officer_cac_perk3;
			break;
	}
	
	//--- Setup Bomb Squad ---
	if( self hasPerk( "specialty_detectexplosives" ) )
		self.detectExplosives = true;
	else
		self.detectExplosives = undefined;
	self thread perks\_bombsquad::setupBombSquad();
}

// Class Icon Hud
setClassHud( class )
{
	if( level.hardcore ) return;
	
	for( index=0; index < level.class_string.size; index++ )
	{
		if( isSubStr( class, level.class_string[index] ) )
			self setClientCvar( "ui_player_class_" + level.class_string[index], 1 );
		else
			self setClientCvar( "ui_player_class_" + level.class_string[index], 0 );
	}
	
	for( index=0; index < level.class_officer_string.size; index++ )
	{
		if( isSubStr( level.class_officer_string[index], class ) )
			self setClientCvar( "ui_player_class_officer", self getTeamStr() );
		else
			self setClientCvar( "ui_player_class_officer", "" );
	}
}

// Class String Hud
ClassStringHud( class )
{
	if( level.hardcore ) return;
	
	if( isdefined( self.class_string ) ) self.class_string destroy();

	if( !isdefined( self.class_string ) )
	{
		self.class_string = newClientHudElem( self );		
		self.class_string.alignX = "center";
		self.class_string.alignY = "middle";
		self.class_string.horzAlign = "center_safearea";
		self.class_string.vertAlign = "center_safearea";
		self.class_string.x = -230;
		self.class_string.y = 230;
		self.class_string.alpha = 0.9;
		self.class_string.sort = 1;
		self.class_string.fontScale = 1;
		self.class_string.font = "default";
	}
	
	if( isdefined( self.class_string ) )
		self.class_string setText( game["strings"][ "class_" + class ] );

}

//===================================================
//=========== END LOADOUT FROM SPAWN ================
//===================================================


//===================================================
//=========== SHOW PERK ON SPAWN ====================
//===================================================

getPerks( player )
{
	perks[0] = "specialty_null";
	perks[1] = "specialty_null";
	perks[2] = "specialty_null";

	if( isPlayer( player ) )
	{
		perks[0] = player.specialty[0];
		perks[1] = player.specialty[1];
		perks[2] = player.specialty[2];
	}
	
	return( perks );
}

showPerk( index, perk, ypos )
{
	if( !isdefined( self.perkicon ) )
	{
		self.perkicon = [];
		self.perkname = [];
	}
	
	iconsize = 32;
	offset = 65;
	
	if( isdefined( self.perkicon[ index ] ) ) self.perkicon[ index ] destroy();
	if( isdefined( self.perkname[ index ] ) ) self.perkname[ index ] destroy();
	
	if( !isdefined( self.perkicon[ index ] ) || !isdefined( self.perkname[ index ] ) )
	{
		assert( !isdefined( self.perkname[ index ] ) );
		
		xpos = 340;
		ypos = 270 - (150 + iconsize * (2 - index));
		
		icon = newClientHudElem( self );
		icon.alignX = "center";
		icon.alignY = "middle";
		icon.x = xpos;
		icon.y = ypos;
		icon.horzAlign = "center_safearea";
		icon.vertAlign = "center_safearea";
		icon.sort = 1;
		icon.foreground = true;
		
		text = newClientHudElem( self );
		text.alignX = "center";
		text.alignY = "middle";
		text.x = xpos-offset;
		text.y = ypos;
		text.horzAlign = "center_safearea";
		text.vertAlign = "center_safearea";
		text.sort = 1;
		text.fontScale = 1;
		text.font = "default";
		text.foreground = true;
		
		self.perkname[ index ] = text;
		self.perkicon[ index ] = icon;
	}
	
	icon = self.perkicon[ index ];
	text = self.perkname[ index ];
	
	if( perk == "specialty_null" )
	{
		icon.alpha = 0;
		text.alpha = 0;
	}
	else
	{	
		icon.alpha = 1;
		icon setShader( self.specialty[index], iconsize, iconsize );
		
		text.alpha = 1;
		text setText( getPerkName( self.specialty[index], index ) );
	}
}

getPerkName( perk, tier )
{
	for( i = 0; i < level.perkIcons[tier].size; i++ )
		if( level.perkIcons[tier][i] == perk )
			return( level.perkNames[tier][i] );
}

hidePerksAfterTime( delay )
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );
	
	wait( delay );
	
	for( index = 0; index < 3; index++ )
		self thread hidePerk( index, 2.0 );
	
	self notify( "perks_hidden" );
}

hidePerksOnDeath()
{
	self endon( "disconnect" );
	self endon( "perks_hidden" );

	self waittill( "death" );
	
	for( index = 0; index < 3; index++ )
		self hidePerk( index );
	
	self notify( "perks_hidden" );
}

hidePerksOnKill()
{
	self endon(" disconnect" );
	self endon( "death" );
	self endon( "perks_hidden" );

	self waittill( "killed_player" );
	
	for( index = 0; index < 3; index++ )
		self hidePerk( index );
	
	self notify( "perks_hidden" );
}

hidePerk( index, fadetime, hideTextOnly )
{
	if( isdefined( fadetime ) )
	{
		if( !isDefined( hideTextOnly ) || !hideTextOnly )
			self.perkicon[ index ] fadeOverTime( fadetime );
		self.perkname[ index ] fadeOverTime( fadetime );
	}
	
	if( !isDefined( hideTextOnly ) || !hideTextOnly )
		self.perkicon[ index ].alpha = 0;
	self.perkname[ index ].alpha = 0;
}

//===================================================
//=========== END SHOW PERK ON SPAWN ================
//===================================================

// Damage Modifier called from Callback Player Killed
modified_damage( victim, attacker, damage, meansofdeath )
{
	if( !isdefined( victim) || !isdefined( attacker ) || !isplayer( attacker ) || !isplayer( victim ) )
		return damage;
	if( attacker.sessionstate != "playing" || !isdefined( damage ) || !isdefined( meansofdeath ) )
		return damage;
	if( meansofdeath == "" )
		return damage;
		
	old_damage = damage;
	final_damage = damage;
	
	/*======== Cases =============
	attacker - bullet damage
		victim - none
		victim - armor
	attacker - explosive damage
		victim - none
		victim - armor
	attacker - none
		victim - none
		victim - armor
	===============================*/
	
	if( attacker hasPerk( "specialty_bulletdamage" ) && isPrimaryDamage( meansofdeath ) )
	{
		if( isdefined( victim ) && isPlayer( victim ) && victim hasPerk( "specialty_armorvest" ) )
			final_damage = old_damage;
		else
			final_damage = damage*(100+level.bulletdamage_data)/100;
	}
	else if( attacker hasPerk( "specialty_explosivedamage" ) && isExplosiveDamage( meansofdeath ) )
	{
		if( isdefined( victim ) && isPlayer( victim ) && victim hasPerk( "specialty_armorvest" ) )
			final_damage = old_damage;
		else
			final_damage = damage*(100+level.explosivedamage_data)/100;
	}
	else
	{	
		if( isdefined( victim ) && isPlayer( victim ) && victim hasPerk( "specialty_armorvest" ) )
			final_damage = old_damage*( level.armorvest_data/100 );
		else
			final_damage = old_damage;	
	}
	
	return int( final_damage );
}

isExplosiveDamage( meansofdeath )
{
	explosivedamage = "MOD_GRENADE MOD_GRENADE_SPLASH MOD_PROJECTILE MOD_PROJECTILE_SPLASH MOD_EXPLOSIVE";
	if( isSubstr( explosivedamage, meansofdeath ) )
		return true;
		
	return false;
}

isPrimaryDamage( meansofdeath )
{
	if( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
		return true;
		
	return false;
}

initPerkDvars()
{
	level.bulletdamage_data 	= get_dvar_int( "perk_bulletDamage", "40" );		// increased bullet damage by this %
	level.armorvest_data 		= get_dvar_int( "perk_armorVest", "50" );			// increased health by this %
	level.explosivedamage_data 	= get_dvar_int( "perk_explosiveDamage", "40" );		// increased explosive damage by this %
}

get_dvar_int( dvar, def )
{
	return int( get_dvar( dvar, def ) );
}

get_dvar( dvar, def )
{
	if( getCvar( dvar ) != "" )
		return getCvarfloat( dvar );
	else
	{
		setCvar( dvar, def );
		return def;
	}
}



