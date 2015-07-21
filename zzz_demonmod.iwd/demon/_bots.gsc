/**/
/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
#include demon\_utils;

init()
{
	level.testclients = Cvardef( "scr_testclients", 0, 0, 99, "int" );
	
	if( !level.testclients ) return;
	
	thread addTestClients();
}

addTestClients()
{
	wait 5;
	
	for( ;; )
	{
		if( getCvarInt( "scr_testclients" ) > 0 )
			break;
		wait 1;
	}
	
	iNumBots = getCvarInt( "scr_testclients" );
	
	for( i = 0; i < iNumBots; i++ )
	{
		ent[i] = addtestclient();
		Bot = ent[i];
		wait 0.5;

		if( isPlayer( Bot ) )
		{
			if( i & 1 )
			{
				bot.pers["class"] = Bot randomizeClass();
				Bot maps\mp\gametypes\_globalgametypes::menuAllies();
				wait( 0.5 );
				Bot maps\mp\gametypes\_globalgametypes::menuWeapon( GetWeapon( bot.pers["team"] ) );
					
			}
			else
			{
				bot.pers["class"] = Bot randomizeClass();
				Bot maps\mp\gametypes\_globalgametypes::menuAxis();
				wait( 0.5 );
				Bot maps\mp\gametypes\_globalgametypes::menuWeapon( GetWeapon( bot.pers["team"] ) );	
			}
		}
	}
	
	setCvar( "scr_bots_loaded", "1" );
}

isbot( player )
{
 
  if( GetSubStr( player.name, 0, 3 ) == "bot") return true; 
 
  return false;
}

randomizeClass()
{
	selfclass = [];

	selfclass[0] = "assault";
	selfclass[1] = "engineer";
	selfclass[2] = "gunner";
	selfclass[3] = "sniper";
	selfclass[4] = "medic";
	
	self.pers["class"] = selfclass[ randomint( selfclass.size ) ];
	self maps\mp\gametypes\_class::setPerks( self.pers["class"] );
}

GetWeapon( team )
{
	giveweapon = [];
	
	if( team == "allies" )
	{
		switch( game["allies"] )
		{
			case "american":
				giveweapon[0] = "thompson_mp";
				giveweapon[1] = "greasegun_mp";
				giveweapon[2] = "m1garand_mp";
				giveweapon[3] = "m1carbine_mp";
				giveweapon[4] = "shotgun_mp";
				giveweapon[5] = "bar_mp";
				giveweapon[6] = "springfield_mp";
				break;
			
			case "british":
				giveweapon[0] = "sten_mp";
				giveweapon[1] = "bren_mp";
				giveweapon[2] = "enfield_mp";
				giveweapon[3] = "enfield_sniper_mp";
				giveweapon[4] = "shotgun_mp";
				giveweapon[5] = "thompson_mp";
				giveweapon[6] = "m1garand_mp";
				break;
			
			case "russian":
				giveweapon[0] = "ppsh_mp";
				giveweapon[1] = "pps42_mp";
				giveweapon[2] = "mosin_nagant_mp";
				giveweapon[3] = "mosin_nagant_sniper_mp";
				giveweapon[4] = "shotgun_mp";
				giveweapon[5] = "svt40_mp";
				break;
		}
	}
	else
	{
		switch( game["axis"] )
		{
			case "german":
				giveweapon[0] = "mp40_mp";
				giveweapon[1] = "mp44_mp";
				giveweapon[2] = "kar98k_mp";
				giveweapon[3] = "kar98k_sniper_mp";
				giveweapon[4] = "shotgun_mp";
				giveweapon[5] = "g43_mp";
				break;
		}
	}
	
	giveBotweapon = giveweapon[ randomint( giveweapon.size ) ];
	return giveBotweapon;
}

spawnFreezer()
{
	if( !level.freezeBots )
		return;
		
	self.anchor = spawn( "script_origin", self.origin );
	self linkTo( self.anchor );
}
