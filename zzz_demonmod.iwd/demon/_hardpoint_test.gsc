/*************************************
	Original code by DemonSeed
**************************************/

#include demon\_utils;

/**************************************************
	Method to Give Bots Hardpoints for testing
***************************************************/
init()
{
	if( level.hardpoint_debug_bot )
	{
		if( !demon\_bots::IsBot( self ) )
			return;
			
		wait( 3 );
		
		if( self.pers["team"] == "axis" )
			self thread findCandidate();
	}
	else
	{
		if( demon\_bots::IsBot( self ) )
			return;
			
		if( level.hardpoint_to_test != "" )	
			self hardpoints\_hardpoints::giveHardpointItem( level.hardpoint_to_test );
	}
}

findCandidate()
{
	if( level.hardpointtest_count >= 1 ) return;
	level.hardpointtest_count++;
	
	if( level.hardpoint_to_test != "" )	
		self hardpoints\_hardpoints::triggerHardPoint( level.hardpoint_to_test );
}