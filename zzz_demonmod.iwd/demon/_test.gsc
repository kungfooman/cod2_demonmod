#include demon\_utils;

test_onGametypeStarted()
{
/*	origin = (-356, 2450, -6);
	test = spawn( "script_model", origin +(0,0,40) );
	test setModel( "xmodel/static_berlin_ger_radio" );	
	test [[level.createFlagWaypoint]]( "test", origin, "objpoint_A", 55 );
*/

	if( level.script == "mp_carentan" )
	{
		
	//	test = spawn( "script_model", (437, 817, -9) );
	//	test setModel( "xmodel/ammo" );	
	//	test.angles = (-90,0,0);
	//	test setContents( 1 );
		
	//	test = spawn( "script_model", (346, 908, -9) +(0,0,40) );
	//	test setModel( "xmodel/static_berlin_diary" );
	
	}

}

test_Precache()
{
	if( level.script == "mp_carentan" )
	{
	//	demonPrecacheModel( "xmodel/ammo" );
	//	demonPrecacheModel( "xmodel/static_mp_supplies_x" );
	
	//	demonPrecacheModel( "xmodel/static_berlin_diary" );
	
	}

}

test_onPlayerSpawned()
{

//************* TESTING ************************//
	
	self thread ThirdPerson();

	if( level.hardpoint_debug )
		self thread demon\_hardpoint_test::init();
	
//*********************************************//



}

AnnouncetoAll( Msg )
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		players[i] iprintlnbold( Msg );
	}
}