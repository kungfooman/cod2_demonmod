/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	
	//----------------------------- TESTING ---------------------------------------------//
	level.Bots = cvardef( "scr_testclients", 0, 0, 32, "int" );
	level.freezeBots = cvardef( "scr_testclients_freeze", 0, 0, 1, "int" );
	
	level.hardpoint_debug 		= Cvardef( "scr_debug_hardpoint", 0, 0 , 1, "int" );
	level.hardpoint_debug_bot 	= Cvardef( "scr_debug_hardpoint_bot", 0, 0 , 1, "int" );
	level.hardpoint_to_test 	= Cvardef( "scr_debug_hardpoint_hardpointType", "", "", "", "string" );
	
	level.thirdperson = cvardef( "scr_thirdperson", 0, 0, 1, "int" );
	level.thirdperson_angle = cvardef( "scr_thirdperson_angle", 180, 0, 360, "float" );
	level.thirdperson_range = cvardef( "scr_thirdperson_range", 120, 0, 120, "int" );
	//-----------------------------------------------------------------------------------//
	
	level.allow_frags = getCvarInt( "scr_allow_fraggrenades" );
	level.allow_smoke = getCvarInt( "scr_allow_smokegrenades" );
	
	level.bloodObit = cvardef( "scr_allow_bloodsplatter_obituary", 0, 0, 1, "int" );
	
	level.show_teamstatus = cvardef( "scr_demon_teamstatus", 1, 0, 1, "int" );

	//--- Fall Damage Modifiers ---
	level.minfallheight 			= cvardef( "scr_demon_minfallheight", 200, 1, 1000, "int" );
	level.maxfallheight 			= cvardef( "scr_demon_maxfallheight", 380, level.minfallheight, 1000, "int" );
	
	//--- Hardcore Mode ---
	level.hardcore = cvardef( "scr_demon_hardcore", 0, 0, 1, "int" );
	
	//--- Max Health ---
	level.player_maxhealth = cvardef( "scr_demon_player_maxhealth", 100, 0, 100, "int" );
	
	level.showPerksonSpawn = cvardef( "scr_demon_show_perks_onspawn", 1, 0, 1, "int" );
	
	//--- Server Logo ---
	level.server_logo = cvardef( "scr_demon_server_logo", 1, 0, 1, "int" );
	level.server_logo_looptime = cvardef( "scr_demon_logo_looptime", 10, 0, 3600, "int" );
	
	//---Ranking System---
	level.rank = cvardef( "scr_demon_rank_system", 0, 0, 1, "int" );
	level.rank_hud_announce = cvardef( "scr_demon_rank_hud_announce", 1, 0, 1, "int" );
	
	//---Health bar---
	level.healthbar = cvardef( "scr_demon_draw_healthbar", 1, 0, 1, "int" );
	
	//---Healthpacks---
	level.drophealth 			= cvardef( "scr_demon_drophealth", 1, 0, 1, "int" );
	level.healthpacks_lifespan 	= cvardef( "scr_demon_healthpack_lifespan", 30, 0, 3600, "int" ); //max - I hour

	//--- Welcome Messages ---
	level.welcome_enabled		= cvardef( "scr_demon_welcome_msg_enabled", 1, 0, 1, "int" );
	level.welcome_alt 			= cvardef( "scr_demon_welcome_msg_type", 0, 0, 1, "int" );
	level.welcome_msg_num 		= cvardef( "scr_demon_welcome_msg_num", 2, 0, 5, "int" );
	level.welcome_msg_delay 	= cvardef( "scr_demon_welcome_msg_delay", 4, 0, 10, "int" );

	//--- Server Messages ---
	level.message_enable		= cvardef( "scr_demon_messages_enable", 1, 0, 1, "int" );
	level.messagenextmap		= cvardef( "scr_demon_message_next_map", 3, 0, 4, "int" );
	level.messageloop			= cvardef( "scr_demon_message_loop", 1, 0, 1, "int" );
	level.messageindividual		= cvardef( "scr_demon_message_individual", 0, 0, 1, "int" );
	level.messagedelay 			= cvardef( "scr_demon_message_delay", 20, 0, 99, "int" );

	//--- Black Death Screen ---
	level.blackscreen				= cvardef( "scr_demon_black_deathscreen", 1, 0, 1, "int" );
	level.blackscreen_fadetime		= cvardef( "scr_demon_black_deathscreen_fadetime", 2, 0, 10, "float" );

	//--- Bullet Glass Hit ---
	level.bulletscreen				= cvardef( "scr_demon_bulletscreen", 1, 0, 1, "int" );

	//--- Bloody Screen ---
	level.bloodyscreen				= cvardef( "scr_demon_bloodyscreen", 1, 0, 1, "int" );

	//--- Pain Killer (Spawn Protection) ---
	level.spawnprotection 			= cvardef( "scr_demon_painkiller", 0, 0, 99, "int" );
	level.spawnpro_timer 			= cvardef( "scr_demon_painkiller_use_timer", 1, 0, 1, "int" );
	level.protection_headicon 		= cvardef( "scr_demon_painkiller_headicon", 0, 0, 1, "int" );
	level.spawnpro_invisible 		= cvardef( "scr_demon_painkiller_invisibleplayer", 0, 0, 1, "int" );
	level.spawnpro_disable 			= cvardef( "scr_demon_painkiller_disableweapon", 0, 0, 1, "int" );
	level.spawnpro_freezeplayer    	= cvardef( "scr_demon_painkiller_freezeplayer", 0, 0, 1, "int" );
	level.spawnpro_range			= cvardef( "scr_demon_painkiller_range", 20, 0, 200, "int" );

	//---Anti-dbbh---
	level.anti_dbbh 			= cvardef( "scr_demon_anti_dbbh", 3, 0, 3, "int");
	level.anti_dbbh_jump_height = cvardef( "scr_demon_anti_dbbh_jump_height", 16, 0, 100, "int" );

	//---LaserDot Settings---
	level.laserdot				= cvardef( "scr_demon_laserdot", 0, 0, 1, "int" );
	level.laserdotalpha			= cvardef( "scr_demon_laserdot_alpha", 0.9, 0, 1, "float" );
	level.laserdotred			= cvardef( "scr_demon_laserdot_red", 1, 0, 1, "float" );
	level.laserdotgreen			= cvardef( "scr_demon_laserdot_green", 0, 0, 1, "float" );
	level.laserdotblue			= cvardef( "scr_demon_laserdot_blue", 0, 0, 1, "float" );
	level.laserdotsize			= cvardef( "scr_demon_laserdot_size", 2, 0, 10, "int" );

	//--- Realism Settings ---
	level.droponarmhit 				= cvardef( "scr_demon_droponarmhit", 50, 0, 100, "int");
	level.droponhandhit	 			= cvardef( "scr_demon_droponhandhit", 50, 0, 100, "int");
	level.triponleghit 				= cvardef( "scr_demon_triponleghit", 50, 0, 100, "int");
	level.triponfoothit 			= cvardef( "scr_demon_triponfoothit", 50, 0, 100, "int");

	//--- Damage View Shift ---
	level.damageviewshift			= cvardef( "scr_demon_damage_viewshift", 25, 0, 45, "int" );
	
	level.dynamic_perks = cvardef( "scr_demon_dynamic_perks", 1, 0, 1, "int" );
	
	//--- Perks ---
	//PERK GROUP 1
	level.perk_allow_tripwire		= cvardef( "scr_demon_allow_tripwire", 1, 0, 1, "int" ); //1
	level.perk_allow_betty			= cvardef( "scr_demon_allow_betty", 1, 0, 1, "int" ); //2
	level.perk_allow_stickybomb		= cvardef( "scr_demon_allow_stickybomb", 1, 0, 1, "int" ); //3
	level.perk_allow_satchel		= cvardef( "scr_demon_allow_satchel", 1, 0, 1, "int" ); //4
	level.perk_allow_tabungas		= cvardef( "scr_demon_allow_tabungas", 1, 0, 1, "int" ); //5
	level.perk_allow_artillery		= cvardef( "scr_demon_allow_artillery", 1, 0, 1, "int" );
	//PERK GROUP 2
	level.perk_allow_bulletdamage	= cvardef( "scr_demon_allow_bulletdamage", 1, 0, 1, "int" );
	level.perk_allow_bombsquad		= cvardef( "scr_demon_allow_bombsquad", 1, 0, 1, "int" );
	level.perk_allow_juggernaut		= cvardef( "scr_demon_allow_juggernaut", 1, 0, 1, "int" );
	level.perk_allow_firstaid		= cvardef( "scr_demon_allow_firstaid", 1, 0, 1, "int" );
	level.perk_allow_scavenger		= cvardef( "scr_demon_allow_scavenger", 1, 0, 1, "int" );
	//PERK GROUP 3
	level.perk_allow_martyrdom		= cvardef( "scr_demon_allow_martyrdom", 1, 0, 1, "int" );
	level.perk_allow_endurance		= cvardef( "scr_demon_allow_endurance", 1, 0, 1, "int" );
	level.perk_allow_sonicboom		= cvardef( "scr_demon_allow_sonicboom", 1, 0, 1, "int" );
	level.perk_allow_hardline		= cvardef( "scr_demon_allow_hardline", 1, 0, 1, "int" );
	level.perk_allow_insertion		= cvardef( "scr_demon_allow_insertion", 1, 0, 1, "int" );
	
	//--- Default Officer CAC Specialties ---
	level.officer_cac_perk1 = cvardef( "ui_cac_perk1", "specialty_weapon_tripwire", "", "", "string" );
	level.officer_cac_perk2 = cvardef( "ui_cac_perk2", "specialty_armorvest", "", "", "string" );
	level.officer_cac_perk3 = cvardef( "ui_cac_perk3", "specialty_longersprint", "", "", "string" );
	
	//-------------------------------- HARDPOINT HANDLING -----------------------------------------------------
	game["hardpoint_artillery_limit"] 		= cvardef( "scr_demon_hardpoint_limit_artillery", 1, 0, 50, "int" );
	game["hardpoint_airstrike_limit"] 		= cvardef( "scr_demon_hardpoint_limit_airstrike", 1, 0, 50, "int" );
	game["hardpoint_carepack_limit"] 		= cvardef( "scr_demon_hardpoint_limit_carepack", 1, 0, 50, "int" );
	
	level.limit_hardpoint_byTeam			= cvardef( "scr_demon_hardpoint_limit_byTeam", 0, 0 , 1, "int" );
	level.limit_hardpoint_byPlayer			= cvardef( "scr_demon_hardpoint_limit_byPlayer", 0, 0 , 1, "int" );
		
	level.artillery_num 					= cvardef( "scr_demon_hardpoint_artillery_streak", 5, 0, 50,"int" );
	level.airstrike_num 					= cvardef( "scr_demon_hardpoint_airstrike_streak", 7, 0, 50,"int" );
	level.carepack_num 						= cvardef( "scr_demon_hardpoint_carepack_streak", 3, 0, 50,"int" );
	//----------------------------------------------------------------------------------------------------------
}



