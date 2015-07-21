/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
/*********************************************
	ORIGINAL CODE BY BELL FOR vCOD/UO
**********************************************/

#include demon\_utils;

show_WelcomeMessages()
{
	
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	if( !level.welcome_enabled ) return;

	if( isdefined( self.pers[ "welcomed" ] ) ) return;
	self.pers[ "welcomed" ] = true;
	
	msg_num = level.welcome_msg_num;

	wm_delay = level.welcome_msg_delay;

	for( i = 1; i <= msg_num; i++ )
	{
		msg = cvardef( "scr_demon_welcome_msg" + i, "", "", "", "string" );
		
		wait( wm_delay );
		
		if( msg != "" )
		{
			self iprintlnBold( msg );
		}
	}
}

ServerMessages()
{
	if( !level.message_enable ) return;
	
	if( level.messageindividual )
	{
		self endon( "game_ended" );
		if( isdefined( self.pers[ "serverMessages" ] ) ) return;
	}
	else
	{
		level endon( "game_ended" );

		// Check if thread has allready been called.
		if( isdefined( game[ "serverMessages" ] ) ) return;
	}

	wait( level.messagedelay );
	
	maps = undefined;
	while( 1 ) 
	{
		if( level.messagenextmap && !( level.messageindividual && isdefined( self.pers[ "messagecount" ] ) ) )
		{
			x = demon\_maprotation::GetCurrentMapRotation( 1 );
			if( isdefined( x ) )
			{
				if( isdefined( x.maps ) )
					maps = x.maps;
				x delete();
			}

			if( isdefined( maps ) && maps.size )
			{
				// Get next map
				if( isdefined( maps[0][ "gametype" ] ) )
					nextgt = maps[0][ "gametype" ];
				else
					nextgt = level.gametype;

				nextmap = maps[0]["map"];

				if( level.messagenextmap == 4 )
				{
					if( level.randommaprotation )
					{
						if( level.messageindividual )
							self iprintln( "This Server Runs Random Map Rotation" );
						else
							iprintln( "This Server Runs Random Map Rotation" );
					}
					else
					{
						if( level.messageindividual )
							self iprintln( "This Server Runs Normal Map Rotation" );
						else
							iprintln( "This Server Runs Normal Map Rotation" );
					}	
				
					wait( 1 );
				}

				if( level.messagenextmap > 2 )
				{
					if( level.messageindividual )
						self iprintln( "^3Next gametype: ^5" + demon\_maprotation::getGametypeName( nextgt ) );
					else
						iprintln( "^3Next gametype: ^5" + demon\_maprotation::getGametypeName( nextgt ) );
						
					wait( 1 );
				}

				if( level.messagenextmap > 2 || level.messagenextmap == 1)
				{
					if( level.messageindividual)
						self iprintln( "^3Next map: ^5" + demon\_maprotation::getMapName( nextmap ) );
					else
						iprintln( "^3Next map: ^5" + demon\_maprotation::getMapName( nextmap ) );
				}

				if( level.messagenextmap == 2 )
				{
					if( level.messageindividual )
						self iprintln("^3Next: ^5" + demon\_maprotation::getMapName( nextmap ) + "^3/^5" + demon\_maprotation::getGametypeName( nextgt ) );
					else
						iprintln("^3Next: ^5" + demon\_maprotation::getMapName( nextmap ) + "^3/^5" + demon\_maprotation::getGametypeName( nextgt ) );
						
					wait( 1 );
				}

				// Set next message
				if( level.messageindividual )
					self.pers[ "messagecount" ] = 0;

				wait( level.messagedelay );
			}
		}

		// Get first message
		if( level.messageindividual && isdefined( self.pers[ "messagecount" ] ) )
			count = self.pers[ "messagecount" ];
		else
			count = 0;

		message = cvardef( "scr_demon_message" + count, "", "", "", "string" );

		// Avoid infinite loop
		if( message == "" && !( isdefined( maps ) && maps.size ) )
			wait level.messagedelay;

		// Announce messages
		while( message != "" )
		{
			if( level.messageindividual )
				self iprintln( message );
			else
			{
				iprintln( message );
			}
			count++;
			// Set next message
			if( level.messageindividual )
				self.pers[ "messagecount" ] = count;

			wait( level.messagedelay );

			message = cvardef( "scr_demon_message" + count, "", "", "", "string" );
		}

		if( level.messageindividual )
			self.pers[ "messagecount" ] = undefined;

		// Loop?
		if( !level.messageloop )
			break;
		
	}
	
	// Set flag to indicate that this thread has been called and run all through once
	if( level.messageindividual )
		self.pers[ "serverMessages" ] = true;
	else
		game[ "serverMessages" ] = true;
}

