#include demon\_utils;

init()
{
	game["menu_ingame"] = "ingame";
	game["menu_team"] = "team_" + game["allies"] + game["axis"];
	game["menu_callvote"] = "callvote";
	game["menu_muteplayer"] = "muteplayer";
	
	precacheMenu( "clientcmd" );
	
	//--- Download Checker ---
	
	game["checker"] = "checker";
	precacheMenu( game["checker"] );

	game["force_download_msg"] = &"If You Are Seeing This, You Don't Have the Mod Files \n Reconnect to Download the Missing Mod Files \n  At The End of The Timer, You Will Be Kicked";
	precacheString( game["force_download_msg"] );
	
	//-------------------------
	
	game["perkgroup1"] = "perkgroup1";
	precacheMenu( game["perkgroup1"] );
	game["perkgroup2"] = "perkgroup2";
	precacheMenu( game["perkgroup2"] );
	game["perkgroup3"] = "perkgroup3";
	precacheMenu( game["perkgroup3"] );
	
	game["cac_popup_perk1"] = "popup_perk1";
	precacheMenu( game["cac_popup_perk1"] );
	game["cac_popup_perk2"] = "popup_perk2";
	precacheMenu( game["cac_popup_perk2"] );
	game["cac_popup_perk3"] = "popup_perk3";
	precacheMenu( game["cac_popup_perk3"] );

	precacheMenu( game["menu_ingame"] );
	precacheMenu( game["menu_team"] );
	precacheMenu( game["menu_callvote"] );
	precacheMenu( game["menu_muteplayer"] );
	
	precacheString( &"DEMON_CLASS_CHANGED" );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );

		if( !isDefined( player.pers["checking"] ) )
			player.pers["checking"] = undefined;
				
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	if( !demon\_bots::IsBot( self ) )
		self maps\mp\gametypes\_downloadchecker::menuWaiter();
	
	for( ;; )
	{
		self waittill( "menuresponse", menu, response );

		if( response == "back_to_team" )
		{
			if( self.sessionstate == "playing" )
				self openMenu( game["menu_ingame"] );
			else
				self openMenu( game["menu_team"] );
		}

		if( menu == game["menu_ingame"] )
		{			
			switch( response )
			{
			case "changeweapon":
				self closeMenu();
				self closeInGameMenu();
				self.changedWeapon = true;
				self openMenu( game[ "menu_" + self maps\mp\gametypes\_class::getClass() + "_" + self.pers["team"] ] );
				break;	

			case "changeteam":
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_team"] );
				break;
			
			case "changeclass":
				self closeMenu();
				self closeInGameMenu();
				self maps\mp\gametypes\_class::unSetClass();
				self.changedClass = true;
				self openMenu( game[ "menu_class_" + self.pers["team"] ] );
				break;

			case "muteplayer":
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_muteplayer"] );
				break;

			case "callvote":
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_callvote"] );
				break;
			}
	
		}
		else if( menu == game["menu_team"] )
		{
			switch( response )
			{
			case "allies":
				self closeMenu();
				self closeInGameMenu();
				self [[level.allies]]();
				self openMenu( game["menu_class_allies"] );
				break;

			case "axis":
				self closeMenu();
				self closeInGameMenu();
				self [[level.axis]]();
				self openMenu( game["menu_class_axis"] );
				break;

			case "autoassign":
				self closeMenu();
				self closeInGameMenu();
				self [[level.autoassign]]();
				break;

			case "spectator":
				self closeMenu();
				self closeInGameMenu();
				self [[level.spectator]]();
				break;
			}
			
		}
		else if( menu == game[ "menu_class_allies" ] || menu == game[ "menu_class_axis" ] )
		{
			self [[level.class]]( response );
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game[ "menu_" + response + "_" + self.pers["team"] ] );

			if( isdefined( self.changedClass ) )
				self iprintln( &"DEMON_CLASS_CHANGED", response );
			
			self.changedClass = undefined;
			self.changedWeapon = undefined;
		}
		else if( AnyClassMenu( menu ) )
		{
			self closeMenu();
			self closeInGameMenu();
			self [[level.weapon]]( response );
			self thread maps\mp\gametypes\_class_limits::setClassChoice( self.pers["team"], self maps\mp\gametypes\_class::getClass() );
		}
		else
		{
			//---------- Side Arm Popup Menu -----------
			
			if( menu == game["menu_popup_sidearm"] )
				self thread maps\mp\gametypes\_class::MonitorSidearm( response );
			
			//------------------------------------------
			
			//---------- Officer Create-a-Class Popup Menus -----------
			
			if( menu == game["cac_popup_perk1"] )
				self thread maps\mp\gametypes\_class::MonitorCaCDvars( 1, 0, response );
			else if( menu == game["cac_popup_perk2"] )
				self thread maps\mp\gametypes\_class::MonitorCaCDvars( 2, 1, response );
			else if( menu == game["cac_popup_perk3"] )
				self thread maps\mp\gametypes\_class::MonitorCaCDvars( 3, 2, response );
			
			//----------------------------------------------------------
			
			//-------------------- Dynamic Perks -----------------------
			
			if( menu == game["perkgroup1"] )
				demon\_dynamicperks::monitorPerkGroup1( response );
			else if( menu == game["perkgroup2"] )
				demon\_dynamicperks::monitorPerkGroup2( response );
			else if( menu == game["perkgroup3"] )
				demon\_dynamicperks::monitorPerkGroup3( response );
			
			//----------------------------------------------------------
				
			if( menu == game["menu_quickcommands"] )
				maps\mp\gametypes\_quickmessages::quickcommands( response );
			else if( menu == game["menu_quickstatements"] )
				maps\mp\gametypes\_quickmessages::quickstatements( response );
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses( response );

		}	
	}
}

AnyClassMenu( menu )
{
	if( isSubStr( menu, "engineer" ) || isSubStr( menu, "assault" ) || isSubStr( menu, "sniper" )
	|| isSubStr( menu, "medic" ) || isSubStr( menu, "officer" ) || isSubStr( menu, "gunner" ) )
		return true;
			
	return false;
}




