/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	level.debug = CvarDef( "scr_debug_class_limits", 0, 0, 1, "int" );

	//================ ALLIES =====================
	
	if( !isDefined( game["allies_assault_count"] ) )
		game["allies_assault_count"] = CvarDef( "class_assault_allies_limit", 5, 0, 10, "int" );
	
	if( !isDefined( game["allies_engineer_count"] ) )
		game["allies_engineer_count"] = CvarDef( "class_engineer_allies_limit", 5, 0, 10, "int" );
	
	if( !isDefined( game["allies_gunner_count"] ) )
		game["allies_gunner_count"] = CvarDef( "class_gunner_allies_limit", 3, 0, 10, "int" );
		
	if( !isDefined( game["allies_sniper_count"] ) )
		game["allies_sniper_count"] = CvarDef( "class_sniper_allies_limit", 2, 0, 10, "int" );
	
	if( !isDefined( game["allies_medic_count"] ) )
		game["allies_medic_count"] = CvarDef( "class_medic_allies_limit", 2, 0, 10, "int" );
	
	//==============================================
	
	//================ AXIS ========================
	
	if( !isDefined( game["axis_assault_count"] ) )
		game["axis_assault_count"] = CvarDef( "class_assault_axis_limit", 5, 0, 10, "int" );
	
	if( !isDefined( game["axis_engineer_count"] ) )
		game["axis_engineer_count"] = CvarDef( "class_engineer_axis_limit", 5, 0, 10, "int" );
	
	if( !isDefined( game["axis_gunner_count"] ) )
		game["axis_gunner_count"] = CvarDef( "class_gunner_axis_limit", 3, 0, 10, "int" );
	
	if( !isDefined( game["axis_sniper_count"] ) )
		game["axis_sniper_count"] = CvarDef( "class_sniper_axis_limit", 2, 0, 10, "int" );
	
	if( !isDefined( game["axis_medic_count"] ) )
		game["axis_medic_count"] = CvarDef( "class_medic_axis_limit", 2, 0, 10, "int" );
	
	//==============================================
	
	level thread classCvarUpdate();
	level thread onPlayerConnect();
}

// we need to release a disconnecting player's class
onPlayerDisconnect()
{
	if( self.pers["team"] != "spectator" )
		self releaseClass( self.pers["team"], self.pers["class"] );
}

// Moved this fucntion from onJoinedTeam to onPlayerConnect because the player doesn't 
// have to be on a team to set the class menu limits if we do both teams at the same time
onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connected", player );
		
		// Set the opening menu dvars as they currently stand
		player setDefaultMenuCvar( "ui_allow_allies_assault", game["allies_assault_count"] );
		player setDefaultMenuCvar( "ui_allow_allies_engineer", game["allies_engineer_count"] );
		player setDefaultMenuCvar( "ui_allow_allies_gunner", game["allies_gunner_count"] );
		player setDefaultMenuCvar( "ui_allow_allies_sniper", game["allies_sniper_count"] );
		player setDefaultMenuCvar( "ui_allow_allies_medic", game["allies_medic_count"] );
		
		player setDefaultMenuCvar( "ui_allow_axis_assault", game["axis_assault_count"] );
		player setDefaultMenuCvar( "ui_allow_axis_engineer", game["axis_engineer_count"] );
		player setDefaultMenuCvar( "ui_allow_axis_gunner", game["axis_gunner_count"] );
		player setDefaultMenuCvar( "ui_allow_axis_sniper", game["axis_sniper_count"] );
		player setDefaultMenuCvar( "ui_allow_axis_medic", game["axis_medic_count"] );
		
		// Set the current class totals
		player menuTotalCvar( "allies", "assault", game["allies_assault_count"] );
		player menuTotalCvar( "allies", "engineer", game["allies_engineer_count"] );
		player menuTotalCvar( "allies", "gunner", game["allies_gunner_count"] );
		player menuTotalCvar( "allies", "sniper", game["allies_sniper_count"] );
		player menuTotalCvar( "allies", "medic", game["allies_medic_count"] );

		player menuTotalCvar( "axis", "assault", game["axis_assault_count"] );
		player menuTotalCvar( "axis", "engineer", game["axis_engineer_count"] );
		player menuTotalCvar( "axis", "gunner", game["axis_gunner_count"] );
		player menuTotalCvar( "axis", "sniper", game["axis_sniper_count"] );
		player menuTotalCvar( "axis", "medic", game["axis_medic_count"] );
	}
}

// open the class menus if the class count is not zero, else close them
setDefaultMenuCvar( Cvarname, setVal )
{
	if( setVal != 0 )
		self setClientCvar( CvarName, 1 ); // Open
	else
		self setClientCvar( CvarName, 0 ); // Close
}

menuTotalCvar( team, classType, setVal )
{
	Cvarname = ("ui_" + team + "_" + classType + "_total");
	self setClientCvar( CvarName, setVal );
}

classCvarUpdate()
{
	level endon( "intermission" );
	
	for( ;; )
	{	
		level waittill( "updateClasslimits" );
		
		players = getEntArray( "player", "classname" );
		for( i=0; i < players.size; i++ )
		{
			player = players[i];
			
			// At this stage, player should be either allies or axis because the thread wont notify until a player has chosen a weapon
			if( player.pers["team"] == "allies" )
				team = "allies";
			else
				team = "axis";
			
			// ASSAULT CLASS
			if( game[ team + "_assault_count"] != 0 )
				player setClientCvar( "ui_allow_" + team + "_assault", 1 );
			else
				player setClientCvar( "ui_allow_" + team + "_assault", 0 );
			
			// ENGINEER CLASS
			if( game[ team + "_engineer_count"] != 0 )
				player setClientCvar( "ui_allow_" + team + "_engineer", 1 );
			else
				player setClientCvar( "ui_allow_" + team + "_engineer", 0 );
			
			// GUNNER CLASS
			if( game[ team + "_gunner_count"] != 0 )
				player setClientCvar( "ui_allow_" + team + "_gunner", 1 );
			else
				player setClientCvar( "ui_allow_" + team + "_gunner", 0 );
			
			// SNIPER CLASS
			if( game[ team + "_sniper_count"] != 0 )
				player setClientCvar( "ui_allow_" + team + "_sniper", 1 );
			else
				player setClientCvar( "ui_allow_" + team + "_sniper", 0 );
			
			// MEDIC CLASS
			if( game[ team + "_medic_count"] != 0 )
				player setClientCvar( "ui_allow_" + team + "_medic", 1 );
			else
				player setClientCvar( "ui_allow_" + team + "_medic", 0 );

		}
	}
}

// Update the number of slots available for each class
updateMenuTotalCvar( team, classType, setVal )
{	
	Cvarname = ("ui_" + team + "_" + classType + "_total");
	
	players = getEntArray( "player", "classname" );
	for( index = 0; index < players.size; index++ )
		players[index] setClientCvar( CvarName, setVal );
}

// Class counts work in reverse, so add to count and don't subtract when releasing
releaseClass( team, classType )
{
	if( classType == "officer" ) return;
	
	game[ team + "_" + classType + "_count" ]++;
	
	updateMenuTotalCvar( team, classType, game[ team + "_" + classType + "_count" ] );	

	if( level.debug )
	{
		num = game[ team + "_" + classType + "_count" ];
		self iprintln( "release " + classType + "class set to " + num );
		self iprintlnBold( getCvar( "ui_" + team + "_" + classType + "_total" ) );
	}
}

// Class counts work in reverse, so subtract count and don't add to it when claiming
claimClass( team, classType )
{
	if( classType == "officer" ) return;
	
	if( game[ team + "_" + classType + "_count" ] != 0 )
		game[ team + "_" + classType + "_count" ]--;
	
	updateMenuTotalCvar( team, classType, game[ team + "_" + classType + "_count" ] );
	
	if( level.debug )
	{
		num = game[ team + "_" + classType + "_count" ];
		if( isdefined( num ) )
		{
			iprintln( "claim " + classType + "class set to " + num );
			self iprintlnBold( "claim num " + getCvar( "ui_" + team + "_" + classType + "_total" ) );
		}
	}
}

setClassChoice( team, classType )
{
	if( classType == "officer" ) return;
	
	self checkClasses( team, classType );
	
	self.presClass = self maps\mp\gametypes\_class::getClass();
	
	claimClass( team, self.presClass );
	
	level notify( "updateClasslimits" );
}

checkClasses( team, classType )
{
	if( isDefined( self.presClass ) && self.presClass != classType )
	{
		releaseClass( team, self.presClass );
		if( isdefined( self.changedClass ) )
			self iprintlnBold( "Your class will change the next time you spawn" );
	}
}



