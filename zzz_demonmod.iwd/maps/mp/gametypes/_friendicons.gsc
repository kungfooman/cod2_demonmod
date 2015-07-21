/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	// Draws a team icon over teammates
	level.drawfriend = cvardef( "scr_drawfriend", 0, 0, 1, "int" );

	if( level.rank )
	{
		if( isdefined( game["allies"] ) )
		{
			switch( game["allies"] )
			{
				case "american":
					game["headicon_am_priv"] 	= "headicon_am_priv";
					game["headicon_am_corp"] 	= "headicon_am_corp";
					game["headicon_am_sarg"] 	= "headicon_am_sarg";
					game["headicon_am_lieut"] 	= "headicon_am_lieut";
					game["headicon_am_capt"] 	= "headicon_am_capt";
					game["headicon_am_maj"] 	= "headicon_am_maj";
					
					demonPrecacheHeadIcon( game["headicon_am_priv"] );
					demonPrecacheHeadIcon( game["headicon_am_corp"] );
					demonPrecacheHeadIcon( game["headicon_am_sarg"] );
					demonPrecacheHeadIcon( game["headicon_am_lieut"] );
					demonPrecacheHeadIcon( game["headicon_am_capt"] );
					demonPrecacheHeadIcon( game["headicon_am_maj"] );
					break;
				
				case "british":
					game["headicon_brit_priv"] 		= "headicon_brit_priv";
					game["headicon_brit_corp"] 		= "headicon_brit_corp";
					game["headicon_brit_sarg"] 		= "headicon_brit_sarg";
					game["headicon_brit_lieut"] 	= "headicon_brit_lieut";
					game["headicon_brit_capt"] 		= "headicon_brit_capt";
					game["headicon_brit_maj"] 		= "headicon_brit_maj";

					demonPrecacheHeadIcon( game["headicon_brit_priv"] );
					demonPrecacheHeadIcon( game["headicon_brit_corp"] );
					demonPrecacheHeadIcon( game["headicon_brit_sarg"] );
					demonPrecacheHeadIcon( game["headicon_brit_lieut"] );
					demonPrecacheHeadIcon( game["headicon_brit_capt"] );
					demonPrecacheHeadIcon( game["headicon_brit_maj"] );
					break;
				
				case "russian":
					game["headicon_rus_priv"] 	= "headicon_rus_priv";
					game["headicon_rus_corp"] 	= "headicon_rus_corp";
					game["headicon_rus_sarg"] 	= "headicon_rus_sarg";
					game["headicon_rus_lieut"] 	= "headicon_rus_lieut";
					game["headicon_rus_capt"] 	= "headicon_rus_capt";
					game["headicon_rus_maj"] 	= "headicon_rus_maj";

					demonPrecacheHeadIcon( game["headicon_rus_priv"] );
					demonPrecacheHeadIcon( game["headicon_rus_corp"] );
					demonPrecacheHeadIcon( game["headicon_rus_sarg"] );
					demonPrecacheHeadIcon( game["headicon_rus_lieut"] );
					demonPrecacheHeadIcon( game["headicon_rus_capt"] );
					demonPrecacheHeadIcon( game["headicon_rus_maj"] );
					break;
			}
		}
		
		if( isdefined( game["axis"] ) )
		{
			switch( game["axis"] )
			{
				case "german":
					assert( game["axis"] == "german" );
					game["headicon_ger_priv"] 	= "headicon_ger_priv";
					game["headicon_ger_corp"] 	= "headicon_ger_corp";
					game["headicon_ger_sarg"] 	= "headicon_ger_sarg";
					game["headicon_ger_lieut"] 	= "headicon_ger_lieut";
					game["headicon_ger_capt"] 	= "headicon_ger_capt";
					game["headicon_ger_maj"] 	= "headicon_ger_maj";
					
					demonPrecacheHeadIcon( game["headicon_ger_priv"] );
					demonPrecacheHeadIcon( game["headicon_ger_corp"] );
					demonPrecacheHeadIcon( game["headicon_ger_lieut"] );
					demonPrecacheHeadIcon( game["headicon_ger_sarg"] );
					demonPrecacheHeadIcon( game["headicon_ger_capt"] );
					demonPrecacheHeadIcon( game["headicon_ger_maj"] );
					break;
			}
		}
	}
	else
	{
		if( isdefined( game["allies"] ) )
		{
			switch( game["allies"] )
			{
				case "american":
					game["headicon_allies"] = "headicon_american";
					demonPrecacheHeadIcon( game["headicon_allies"] );
					break;
				
				case "british":
					game["headicon_allies"] = "headicon_british";
					demonPrecacheHeadIcon( game["headicon_allies"] );
					break;
				
				case "russian":
					game["headicon_allies"] = "headicon_russian";
					demonPrecacheHeadIcon( game["headicon_allies"] );
					break;
			}
		}
		
		if( isdefined( game["axis"] ) )
		{
			switch( game["axis"] )
			{
				case "german":
					assert( game["axis"] == "german" );
					game["headicon_axis"] = "headicon_german";
					demonPrecacheHeadIcon( game["headicon_axis"] );
					break;
			}
		}
	}

	level thread onPlayerConnect();
	
	for( ;; )
	{
		updateFriendIconSettings();
		wait( 5 );
	}
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );

		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "spawned_player" );
		
		self thread showFriendIcon();
	}
}

onPlayerKilled()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "killed_player" );
		
		self.headicon = "";
	}
}	

showFriendIcon()
{
	if( level.drawfriend )
	{
		if( level.rank )
		{
			self.statusicon = demon\_rank::ranking_GetStatusicon( self );
			self.headicon = demon\_rank::ranking_GetHeadicon( self );
			self.headiconteam = self.pers["team"];
		}
		else
		{
			if( self.pers["team"] == "allies" )
			{
				self.headicon = game["headicon_allies"];
				self.headiconteam = "allies";
			}
			else
			{
				self.headicon = game["headicon_axis"];
				self.headiconteam = "axis";
			}
		}
	}
	else 
	{
		if( level.rank )
		{
			self.statusicon = demon\_rank::ranking_GetStatusicon( self );
		}
		else
		{
			self.statusicon = "";
		}
		
		self.headicon = "";
		self.headiconteam = "none";
	}
}
	
updateFriendIconSettings()
{
	if( level.drawfriend || level.rank )
	{	
		updateFriendIcons();
	}
}

updateFriendIcons()
{
	if( level.rank )
	{
		// for all living players, show the appropriate headicon
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if( isDefined( player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing" )
			{
				player.statusicon = demon\_rank::ranking_GetStatusicon( player );
				
				if ( level.drawfriend )
				{
					player.headicon = demon\_rank::ranking_GetHeadicon( player );
					player.headiconteam = player.pers["team"];
				}
				else
				{
					player.headicon = "";
				}
			}

		}
	}
	else if( level.drawfriend )
	{
		// for all living players, show the appropriate headicon
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
			{
				if(level.drawfriend)
				{
					if(player.pers["team"] == "allies")
					{
						player.headicon = game["headicon_allies"];
						player.headiconteam = "allies";
					}
					else
					{
						player.headicon = game["headicon_axis"];
						player.headiconteam = "axis";
					}
				}
				else
				{
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
		
						if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
							player.headicon = "";
					}
				}
			}
		}
	}
}
