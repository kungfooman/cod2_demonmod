/************************************
	original code by Tally
	modifications by DemonSeed
*************************************/
#include demon\_utils;

init()
{
	if( !level.server_logo ) 
		return;
	
	level thread Logo();
}

Logo()
{
	level endon( "intermission" );
	level endon( "round_ended" );
	
	time = level.server_logo_looptime;
	
	X = 608;
	Y = 35;	

	if( isdefined( level.svrlogo ) ) level.svrlogo destroy();
		
	if( !isDefined( level.svrlogo ) )
	{
		level.svrlogo = newHudElem();
		level.svrlogo.x = X; 
		level.svrlogo.y = Y;
		level.svrlogo.alignX = "center"; 
		level.svrlogo.alignY = "middle"; 
		level.svrlogo.archived = false; 
		level.svrlogo.sort = 3;
		level.svrlogo setShader( game["logo"], 60, 60 );
		level.svrlogo.alpha = 0;
	}
		
	wait( 15 );

	if( isdefined( level.svrlogo ) )
	{			
		level.svrlogo fadeOverTime( 2 );
		level.svrlogo.alpha = .9;
	}
		
	wait( 20 );
		
	for( ;; )
	{
		if( isdefined( level.svrlogo ) )
		{
			level.svrlogo fadeOverTime( 2 );
			level.svrlogo.alpha = 0;
		}
			
		wait( time );
			
		if( isdefined( level.svrlogo ) )
		{
			level.svrlogo fadeOverTime( 2 );
			level.svrlogo.alpha = .9;
		}
			
		wait( 20 );
	
	}
}