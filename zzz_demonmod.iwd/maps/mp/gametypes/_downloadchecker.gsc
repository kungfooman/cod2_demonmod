#include demon\_utils;

startChecker()
{
	self endon( "disconnect" );
	
	if( !hasBeenChecked() )
	{
		self thread Limbo();
		self waittill( "check_done" );
	}

	self notify( "check_done" );
}

menuWaiter()
{
	self endon( "disconnect" );
	self waittill( "check_done" );
	return;
}

// function to spawn a player in limbo while a download checker is run on them
Limbo()
{
	self endon( "disconnect" );
	self endon( "check_done" );

	self.pers["checking"] = true;
	self setClientCvar( "cl_allowdownload", 1 );
	self setClientCvar( "cl_wwwdownload", 1 );
	
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
		
	maps\mp\gametypes\_globalgametypes::spawnSpectator();

	self.linker = spawn( "script_origin", self.origin );
	self linkTo( self.linker );
	
	self openMenu( game["checker"] );
	self thread CheckMenuReponseSpecial();
	
	if( !isdefined( self.downloadChecker_msg ) )
	{
		self.downloadChecker_msg = newClientHudElem( self );
		self.downloadChecker_msg.archived = true;
		self.downloadChecker_msg.x = 340;
		self.downloadChecker_msg.y = 80;
		self.downloadChecker_msg.alignX = "center";
		self.downloadChecker_msg.alignY = "middle";
		self.downloadChecker_msg.fontScale = 1.6;
		self.downloadChecker_msg.sort = 1;
		self.downloadChecker_msg.alpha = 1;
		self.downloadChecker_msg.foreground = true;
		self.downloadChecker_msg setText( game["force_download_msg"] );
	}
	
	if( !isdefined( self.downloadChecker_timer ) )
	{
		self.downloadChecker_timer = newClientHudElem( self );
		self.downloadChecker_timer.x = 0;
		self.downloadChecker_timer.y = -80;
		self.downloadChecker_timer.alignX = "center";
		self.downloadChecker_timer.alignY = "middle";
		self.downloadChecker_timer.horzAlign = "center_safearea";
		self.downloadChecker_timer.vertAlign = "center_safearea";	
		self.downloadChecker_timer.fontScale = 2.4;
		self.downloadChecker_timer.font = "default";
		self.downloadChecker_timer.alpha = .9;
		self.downloadChecker_timer.color = ( 1, 1, 0 );
		self.downloadChecker_timer setTimer( level.limbotime );
	}

	timer = level.limbotime + 1; // add 1 second to total to get down to 0 before timer ends
	
	while( isDefined( self ) )
	{
		wait( 1 );
			
		timer--;

		if( !timer || !isDefined( self.pers["checking"] ) )
			break;
	}
	
	if( !isDefined( self.pers["checking"] ) ) return;
	
	if( isDefined( self.pers["checking"] ) )
		kick( self getEntityNumber() );
}

// this proved necessary because the principle menu response loop kept kicking off
// about self.pers["checker"] inside the loop, even though it was patently defined.
// So, I moved everything to its own loop, which is only run once.
CheckMenuReponseSpecial()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self waittill( "menuresponse", menu, response );
		
		if( menu == game["checker"] && response == "accept" )
		{
			self.pers["checking"] = undefined;
			self notify( "check_done" );
			self closeMenu( game["checker"] );
			
			if( isdefined( self.downloadChecker_msg ) )
				self.downloadChecker_msg destroy();

			if( isdefined( self.downloadChecker_timer ) )
				self.downloadChecker_timer destroy();
				
			break;
		}
	}
}

hasBeenChecked()
{
	return( true );
}
