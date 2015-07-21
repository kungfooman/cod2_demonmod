/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
/**************************************************

	Original code taken from United Offensive
	
***************************************************/

#include demon\_utils;

init()
{
	if( !level.rank ) 
		return;

	ranking_setup();
	ranking_Precache();
	
	level thread ranking_CheckUpDates();
	level thread onEndGame();
	
}

/*----------------------------------------------------------------------------------
	Setup the Rank Variables
------------------------------------------------------------------------------------*/
ranking_setup()
{
	// set up the icons
	game["rank_icon_0"] = "rank_private";
	game["rank_icon_1"] = "rank_corporal";
	game["rank_icon_2"] = "rank_sergeant";
	game["rank_icon_3"] = "rank_lieutenant";
	game["rank_icon_4"] = "rank_captain";
	game["rank_icon_5"] = "rank_major";
	game["rank_icon_6"] = "rank_colonel";
	game["rank_icon_7"] = "rank_general";

	// rank score points
	game["rank_1"] = cvardef( "scr_rank_corporal_points", 50, 0, 999, "int" ); 
	game["rank_2"] = cvardef( "scr_rank_sergeant_points", 100, 0, 999, "int" ); 
	game["rank_3"] = cvardef( "scr_rank_lieutenant_points", 150, 0, 999, "int" ); 
	game["rank_4"] = cvardef( "scr_rank_captain_points", 200, 0, 999, "int" );
	game["rank_5"] = cvardef( "scr_rank_major_points", 250, 0, 999, "int" ); 
	game["rank_6"] = cvardef( "scr_rank_colonel_points", 300, 0, 999, "int" ); 
	game["rank_7"] = cvardef( "scr_rank_general_points", 350, 0, 999, "int" ); 
		
	// set up the ammo values for the various ranks
	// remember that they will already have one clip in the gun
	game["rank_ammo_gunclips_0"] = cvardef( "scr_rank_private_gunclips", 1, 0, 999, "int" );
	game["rank_ammo_gunclips_1"] = cvardef( "scr_rank_corporal_gunclips", 2, 0, 999, "int" ); 
	game["rank_ammo_gunclips_2"] = cvardef( "scr_rank_sergeant_gunclips", 3, 0, 999, "int" );
	game["rank_ammo_gunclips_3"] = cvardef( "scr_rank_lieutenant_gunclips", 4, 0, 999, "int" );
	game["rank_ammo_gunclips_4"] = cvardef( "scr_rank_captain_gunclips", 5, 0, 999, "int" );
	game["rank_ammo_gunclips_5"] = cvardef( "scr_rank_major_gunclips", 6, 0, 999, "int" );
	game["rank_ammo_gunclips_6"] = cvardef( "scr_rank_colonel_gunclips", 6, 0, 999, "int" );
	game["rank_ammo_gunclips_7"] = cvardef( "scr_rank_general_gunclips", 6, 0, 999, "int" );

	game["rank_ammo_pistolclips_0"] = cvardef( "scr_rank_private_pistolclips", 0, 0, 999, "int" );
	game["rank_ammo_pistolclips_1"] = cvardef( "scr_rank_corporal_pistolclips", 1, 0, 999, "int" );
	game["rank_ammo_pistolclips_2"] = cvardef( "scr_rank_sergeant_pistolclips", 2, 0, 999, "int" );
	game["rank_ammo_pistolclips_3"] = cvardef( "scr_rank_lieutenant_pistolclips", 3, 0, 999, "int" );
	game["rank_ammo_pistolclips_4"] = cvardef( "scr_rank_captain_pistolclips", 4, 0, 999, "int" );
	game["rank_ammo_pistolclips_5"] = cvardef( "scr_rank_major_pistolclips", 5, 0, 999, "int" );
	game["rank_ammo_pistolclips_6"] = cvardef( "scr_rank_colonel_pistolclips", 5, 0, 999, "int" );
	game["rank_ammo_pistolclips_7"] = cvardef( "scr_rank_general_pistolclips", 5, 0, 999, "int" );
}

/*----------------------------------------------------------------------------------
	Precache
------------------------------------------------------------------------------------*/
ranking_Precache()
{
	demonPrecacheStatusIcon( game["rank_icon_0"] );
	demonPrecacheStatusIcon( game["rank_icon_1"] );
	demonPrecacheStatusIcon( game["rank_icon_2"] );
	demonPrecacheStatusIcon( game["rank_icon_3"] );
	demonPrecacheStatusIcon( game["rank_icon_4"] );
	demonPrecacheStatusIcon( game["rank_icon_5"] );
	demonPrecacheStatusIcon( game["rank_icon_6"] );
	demonPrecacheStatusIcon( game["rank_icon_7"] );

	demonPrecacheShader( game["rank_icon_0"] );
	demonPrecacheShader( game["rank_icon_1"] );
	demonPrecacheShader( game["rank_icon_2"] );
	demonPrecacheShader( game["rank_icon_3"] );
	demonPrecacheShader( game["rank_icon_4"] );
	demonPrecacheShader( game["rank_icon_5"] );
	demonPrecacheShader( game["rank_icon_6"] );
	demonPrecacheShader( game["rank_icon_7"] );
	
	demonPrecacheString( &"RANK_PROMOTION" );
	demonPrecacheString( &"RANK_DEMOTION" );
}

/*----------------------------------------------------------------------------------
	Check for Rank Updates
 	Check every second
------------------------------------------------------------------------------------*/
ranking_CheckUpdates()
{
	level endon( "game_ended" );
	
	for( ;; )
	{
		ranking_CheckRanks();
		wait( 0.75 );
	}
}

onPlayerConnect()
{
	if( !level.rank ) 
		return;
		
	// get the player's rank
//	self thread demon\_playerdata::onPlayerConnect();
	
	// check if the player can become an Officer
	self thread CheckforOfficerUpgrade();
}

onPlayerPreSpawned()
{
	if( !level.rank ) 
		return;
		
	self.pers["rank"] = ranking_GetRank( self );
}

onPlayerSpawned()
{
	if( !level.rank ) 
		return;
		
	self.rank_changed = undefined;
	self thread ranking_RankHudInit();
	
	// give the player ammo for rank
	self thread SetAmmoForRank();
	
	// unlock dynamic perk items for players rank
	self thread unLockItemsforRank();
}

onPlayerKilled()
{
	if( !level.rank ) 
		return;
		
	self thread ranking_RankHudDestroy();
}

/*----------------------------------------------------------------------------------
	Check End of Game
------------------------------------------------------------------------------------*/
onEndGame()
{
	for( ;; )
	{
		level waittill( "intermission" );
		
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player.statusicon = ranking_GetStatusicon( player ); 
			
			// save the players rank value
		//	player thread demon\_playerdata::onEndGame();
		}
	}
}


/*----------------------------------------------------------------------------------
	Unlock Dynamic Perk Items for Players Rank onPlayerSpawned
------------------------------------------------------------------------------------*/
unLockItemsforRank()
{
	if( self.pers["rank"] == 0 ) return;
	
	for( index = 1; index < 6; index++ )
	{
		if( index > self.pers["rank"] )
			continue;
		
		self.perk_unlock[index] = true;
				
		for( perkNum = 1; perkNum < 4; perkNum++ )
			self setClientCvar( "perk" + perkNum + "_unlock_rank_" + index, getPerkAllowDvar( perkNum, index ) );
			
		wait( 0.05 );
	}
}


/*----------------------------------------------------------------------------------
	Get the Dynamic Perks Unlock Dvar
------------------------------------------------------------------------------------*/
getPerkAllowDvar( perkNum, tier )
{	
	return( level.perkAllow["perk_"+perkNum][tier] );
}


/*----------------------------------------------------------------------------------
	Set the Ammo for the Right Rank & Unlock Dynamic Items
------------------------------------------------------------------------------------*/
SetAmmoForRank()
{	
	ammo =  self ranking_GetGunAmmo( self getweaponslotweapon( "primary" ) );
	self setWeaponSlotAmmo( "primary", ammo );
	wait( 0.10 );
	pistolammo =  self ranking_GetPistolAmmo( self getweaponslotweapon( "primaryb" ) );
	self setWeaponSlotAmmo( "primaryb", pistolammo );
	
	// if they are a private, don't do anything
	if( self.pers["rank"] == 0 ) return;

	// if they are less than rank 6 unlock dynamic perk items for rank
	if( self.pers["rank"] < 6 )
	{	
		for( perkNum=1; perkNum < 4; perkNum++ )
			self setClientCvar( "perk" + perkNum + "_unlock_rank_" + self.pers["rank"], getPerkAllowDvar( perkNum, self.pers["rank"] ) );
			
		self.perk_unlock[ self.pers["rank"] ] = true;
	}
}

CheckforOfficerUpgrade()
{
	if( ranking_GetRank( self ) == 7 )
	{
		self setClientCvar( "ui_allow_officer", 1 );
		self setClientCvar( "cg_player_binoculars", "1" );
		self.binocularsAvailable = true;
	}
	else
		self setClientCvar( "ui_allow_officer", 0 );
}


/*----------------------------------------------------------------------------------
	ranking_GetRank

 	Returns a level 0 - 7 that the player is currently at.
------------------------------------------------------------------------------------*/
ranking_GetRank( player )
{
	if( player.pers["rank_score"] >= game["rank_7"] )
		return 7;	
	else if( player.pers["rank_score"] >= game["rank_6"] )
		return 6;
	else if( player.pers["rank_score"] >= game["rank_5"] )
		return 5;
	else if( player.pers["rank_score"] >= game["rank_4"] )
		return 4;
	else if( player.pers["rank_score"] >= game["rank_3"] )
		return 3;
	else if( player.pers["rank_score"] >= game["rank_2"] )
		return 2;
	else if( player.pers["rank_score"] >= game["rank_1"] )
		return 1;
		
	return 0;
}

/*----------------------------------------------------------------------------------
	ranking_GetRankText

	Returns rank text that the player is currently at.
------------------------------------------------------------------------------------*/
ranking_GetRankText( player )
{
	if( player.pers["rank_score"]  >= game["rank_7"] )
		return "General";
	else if( player.pers["rank_score"]  >= game["rank_6"] )
		return "Colonel";
	else if( player.pers["rank_score"]  >= game["rank_5"] )
		return "Major";
	else if( player.pers["rank_score"]  >= game["rank_4"] )
		return "Captain";
	else if( player.pers["rank_score"] >= game["rank_3"] )
		return "Lieutenant";
	else if( player.pers["rank_score"] >= game["rank_2"] )
		return "Sergeant";
	else if( player.pers["rank_score"] >= game["rank_1"] )
		return "Corporal";
	
	return "Private";
}

/*----------------------------------------------------------------------------------
	ranking_GetStatusicon

	Returns the appropriate status rank icon
------------------------------------------------------------------------------------*/
ranking_GetStatusicon( player )
{	
	if( player.pers["team"] == "spectator" )
		return "";	

	icon_name = game[ "rank_icon_" + player.pers["rank"] ];
	
	return icon_name;
}

/*----------------------------------------------------------------------------------
	ranking_GetHeadicon

	Returns the appropriate head rank icon
------------------------------------------------------------------------------------*/
ranking_GetHeadicon( player )
{	
	if( player.pers["team"] == "spectator" || player.pers["rank"] == 7 )
		return "";

	icon_name = game[ "headicon_" + getTeamString( player.pers["team"] ) + getRankString( player.pers["rank"] ) ];
	return icon_name;
}

/*----------------------------------------------------------------------------------
	ranking_CheckRanks

 	Checks all of the players for a change from their previous rank.
	This function will update the rank value of all players.
	This function will play sounds when the player changes rank.
------------------------------------------------------------------------------------*/
ranking_CheckRanks()
{
	level endon( "game_ended" );
	
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if( isalive( player ) )
		{			
			old_rank = player.pers["rank"];
			new_rank = ranking_GetRank( player );
			
			if( old_rank == new_rank )
				player.rank_changed = undefined;
			
			if( old_rank != new_rank )
			{
				// did they get promoted?
				if( old_rank < new_rank )
				{
					player notify( "rank changed" );
					
					player.rank_changed = true;
					player.pers["rank"] = new_rank;
					
					player playLocalSound( "mp_promotion" );
					
					player thread SetAmmoForRank();
					player thread CheckforOfficerUpgrade();
					
					if( level.rank_hud_announce )
						player thread PromotionNotice();
					else
						player iprintln( "^3You have been promoted to " + ranking_GetRankText( player ) );
						
				}
				else // they were demoted
				{
					player notify( "rank changed" );
					
					player.rank_changed = true;
					player.pers["rank"] = new_rank;
					
					player playLocalSound( "ctf_enemy_touchdown" );
					
					if( level.rank_hud_announce )
						player thread DemotionNotice();
					else
						player iprintln( "^3You have been demoted to " + ranking_GetRankText( player ) );		
				}
			}
			
		}
		
		wait( 1 );
	}
}

/*----------------------------------------------------------------------------------
	ranking_RankHudInit

	Sets up the rank hud icon
------------------------------------------------------------------------------------*/
ranking_RankHudInit()
{
	if( !level.rank || level.hardcore )
		return;
	
	ranking_RankHudDestroy();
	
	if( !isdefined( self.rank_hud_icon ) )
	{
		self.rank_hud_icon = newClientHudElem( self );		
		self.rank_hud_icon.alignX = "center";
		self.rank_hud_icon.alignY = "middle";
		self.rank_hud_icon.horzAlign = "fullscreen";
		self.rank_hud_icon.vertAlign = "fullscreen";
		self.rank_hud_icon.x = 128;
		self.rank_hud_icon.y = 415;
		self.rank_hud_icon.alpha = 0.8;
		self.rank_hud_icon.sort = 1;
	}

	self thread ranking_RankHudSetShader();
	self thread ranking_RankHudMonitor();
}

/*----------------------------------------------------------------------------------
	ranking_RankHudMonitor

 	Sets up the rank hud icon to the appropriate shader for the rank
------------------------------------------------------------------------------------*/
ranking_RankHudMonitor()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	while( level.rank )
	{
		self waittill( "rank changed" );
		
		self thread ranking_RankHudSetShader();
		
		wait( 0.05 );
	}
	
	ranking_RankHudDestroy();
}		

/*----------------------------------------------------------------------------------
	ranking_RankHudSetShader

	Sets up the rank hud icon to the appropriate shader for the rank
------------------------------------------------------------------------------------*/
ranking_RankHudSetShader()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	icon = ranking_GetStatusicon( self );
	
	// only scaleover if promoted or demoted
	if( isdefined( self.rank_changed ) )
	{
		if( isDefined( self.rank_hud_icon ) )
		{
			self.rank_hud_icon setShader( icon, 30, 30 );
			self.rank_hud_icon scaleOverTime( 1.5, 20, 20 );
		}
	}
	else
	{
		if( isDefined( self.rank_hud_icon ) )
			self.rank_hud_icon setShader( icon, 20, 20 );
	}
}

/*----------------------------------------------------------------------------------
	ranking_RankHudDestroy

	Sets up the rank hud icon to the appropriate shader for the rank
------------------------------------------------------------------------------------*/
ranking_RankHudDestroy()
{
	if( isdefined( self.rank_hud_icon ) )
		self.rank_hud_icon destroy();
}

/*----------------------------------------------------------------------------------
	Promotion Notice
------------------------------------------------------------------------------------*/
PromotionNotice()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !level.rank_hud_announce ) return;
	
	// Clear the Hud Ready for Announcements
	{
		self deleteClientHudElementbyName( "hardpoint_notify_shader" );
		self deleteClientHudTextElementbyName( "hardpoint_notify_text" );

		if( isDefined( self.rank_hud_promo ) ) self.rank_hud_promo destroy();
		if( isdefined( self.rank_promo_text ) ) self.rank_promo_text destroy();
	}

	promo_icon = ranking_GetStatusicon( self );
	
	if( !isDefined( self.rank_promo_text ) )
	{
		self.rank_promo_text = newClientHudElem( self );
		self.rank_promo_text.x = 320;
		self.rank_promo_text.y = 50;
		self.rank_promo_text.alignx = "center";
		self.rank_promo_text.aligny = "middle";
		self.rank_promo_text.alpha = 0.9;
		self.rank_promo_text.font = "default";
		self.rank_promo_text.fontscale = 1.3;
		
	}

	if( !isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo = newClientHudElem( self );
		self.rank_hud_promo.x = 320;
		self.rank_hud_promo.y = 85;
		self.rank_hud_promo.alignx = "center";
		self.rank_hud_promo.aligny = "middle";
		self.rank_hud_promo.alpha = 0.8;
	}
	
	if( isdefined( self.rank_promo_text ) ) self.rank_promo_text setText( &"RANK_PROMOTION" );
	
	if( isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo setShader( promo_icon, 50,50 );
		self.rank_hud_promo scaleOverTime( 1, 30, 30 );
	}
	
	wait( 3 );
	
	if( isdefined( self.rank_promo_text ) )
	{
		self.rank_promo_text fadeOverTime( 1, 0 );
		self.rank_promo_text.alpha = 0;
	}
		
	if( isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo fadeOverTime( 1, 0 );
		self.rank_hud_promo.alpha = 0;
	}
	
	wait( 1 );
	
	if( isDefined( self.rank_hud_promo ) ) self.rank_hud_promo destroy();
	if( isdefined( self.rank_promo_text ) ) self.rank_promo_text destroy();
}

/*----------------------------------------------------------------------------------
	Demotion Notice
------------------------------------------------------------------------------------*/
DemotionNotice()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !level.rank_hud_announce ) return;

	// Clear the Hud Ready for Announcements
	{
		self deleteClientHudElementbyName( "hardpoint_notify_shader" );
		self deleteClientHudTextElementbyName( "hardpoint_notify_text" );

		if( isDefined( self.rank_hud_promo ) ) self.rank_hud_promo destroy();
		if( isdefined( self.rank_promo_text ) ) self.rank_promo_text destroy();
	}

	promo_icon = ranking_GetStatusicon( self );
	
	if( !isDefined( self.rank_promo_text ) )
	{
		self.rank_promo_text = newClientHudElem( self );
		self.rank_promo_text.x = 320;
		self.rank_promo_text.y = 50;
		self.rank_promo_text.alignx = "center";
		self.rank_promo_text.aligny = "middle";
		self.rank_promo_text.alpha = 0.9;
		self.rank_promo_text.font = "default";
		self.rank_promo_text.fontscale = 1.3;	
	}

	if( !isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo = newClientHudElem( self );
		self.rank_hud_promo.x = 320;
		self.rank_hud_promo.y = 85;
		self.rank_hud_promo.alignx = "center";
		self.rank_hud_promo.aligny = "middle";
		self.rank_hud_promo.alpha = 0.8;
	}
	
	if( isdefined( self.rank_promo_text ) ) self.rank_promo_text setText( &"RANK_DEMOTION" );
	
	if( isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo setShader( promo_icon, 50,50 );
		self.rank_hud_promo scaleOverTime( 1, 30, 30 );
	}
	
	wait( 3 );
	
	if( isdefined( self.rank_promo_text ) )
	{
		self.rank_promo_text fadeOverTime( 1, 0 );
		self.rank_promo_text.alpha = 0;
	}
		
	if( isDefined( self.rank_hud_promo ) )
	{
		self.rank_hud_promo fadeOverTime( 1, 0 );
		self.rank_hud_promo.alpha = 0;
	}
	
	wait( 1 );
	
	if( isDefined( self.rank_hud_promo ) ) self.rank_hud_promo destroy();
	if( isdefined( self.rank_promo_text ) ) self.rank_promo_text destroy();
}

/*----------------------------------------------------------------------------------
	ranking_GetGunAmmo
	
 	returns the ammo count that the player will get for the weapon
------------------------------------------------------------------------------------*/
ranking_GetGunAmmo( weapon )
{
	clip_count = game["rank_ammo_gunclips_" + self.pers["rank"] ];

	clip_size = ranking_getWeaponClipSize( weapon );
	
	switch( weapon )
	{
		case "bar_mp":
		case "bren_mp":
		case "mp44_mp":
		case "thompson_mp":
		case "sten_mp":
		case "mp40_mp":
		case "PPS42_mp":		
		case "greasegun_mp":
		
		//MGs	
		case "fg42_mp":
		case "mg42_mp":
		case "30cal_mp":
		
		return clip_count * clip_size;
		
		case "ppsh_mp":
		return (clip_count - 1) * clip_size;

		//  get 1 extra clip
		case "m1carbine_mp":
		case "m1garand_mp":
		case "SVT40_mp":
		case "g43_mp":
		case "shotgun_mp":
		case "ptrs_mp":

		return (clip_count + 1) * clip_size;

		//  2 extra clips
		case "springfield_mp":
		case "springfield_scope_mp":
		case "enfield_scope_mp":
		case "mosin_nagant_sniper_mp":
		case "kar98k_sniper_mp":
		case "enfield_mp":
		case "mosin_nagant_mp":
		case "kar98k_mp":
			
		return (clip_count + 2) * clip_size;

		default:
		   	return 0;
	}
		
	return 0;
}

/*----------------------------------------------------------------------------------
	ranking_GetPistolAmmo

	returns the ammo count that the player will get for the weapon
------------------------------------------------------------------------------------*/
ranking_GetPistolAmmo( weapon )
{
	clip_count = game["rank_ammo_pistolclips_" + self.pers["rank"] ];

	switch( weapon )
	{	
		case "colt_mp":
		case "knife_mp":
		return clip_count * 7;

		case "webley_mp":
		case "magnum_mp":
		return clip_count * 6;

		case "TT30_mp":
		case "luger_mp":
		return clip_count * 8;

		default:
		   	return 0;
	}
	
	return 0;
}

/*----------------------------------------------------------------------------------
	ranking_getWeaponClipSize

	returns the ammo clip size for the weapon
------------------------------------------------------------------------------------*/
ranking_getWeaponClipSize( weapon )
{
	switch( weapon )
	{
		case "springfield_mp":
		case "springfield_scope_mp":
		case "mosin_nagant_mp":
		case "mosin_nagant_sniper_mp":
		case "kar98k_mp":
		case "kar98k_sniper_mp":
		case "ptrs_mp":
		return 5;

		case "shotgun_mp":
		return 6;
		
		case "m1garand_mp":
		return 8;

		case "enfield_mp":
		case "enfield_scope_mp":
		case "SVT40_mp":
		case "g43_mp":
		return 10;

		case "m1carbine_mp":
		return 15;

		case "bar_mp":
		case "thompson_mp":
		case "fg42_mp":
		return 20;

		case "mp44_mp":
		case "bren_mp":
		return 30;

		case "sten_mp":
		case "greasegun_mp":
		case "mp40_mp":	
		return 32;

		case "PPS42_mp":
		return 35;

		case "30cal_mp":
		case "mg42_mp":
		return 50;

		case "ppsh_mp":
		return 71;

		default:
		   	return 0;
	}
		
	return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// UTILITIES ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

getTeamString( team )
{
	teamstring = undefined;
	if( team == "allies" )
	{
		switch( game["allies"] )
		{
			case "american": 
				teamstring = "am_";
				break;
			
			case "british": 
				teamstring = "brit_";
				break;
			
			case "russian": 
				teamstring = "rus_";
				break;
		}
	}
	else
	{
		teamstring = "ger_";
	}
	
	return teamstring;
}

getRankString( rank )
{
	rankstring = undefined;
	switch( rank )
	{
		case 0: rankstring = "priv"; break;
		case 1: rankstring = "corp";  break;
		case 2: rankstring = "sarg";  break;
		case 3: rankstring = "lieut"; break;
		case 4: rankstring = "capt"; break;
		case 5: rankstring = "maj"; break;
		case 6: rankstring = "col"; break;
	}	
	
	return( rankstring );
}

