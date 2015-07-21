/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

Blackscreen()
{
	if( !level.blackscreen  || self.noBlackScreen ) return;
	
	self thread iprintlnboldCLEAR( "self", 5 );
	
	self.blackscreen = newClientHudElem( self );
	self.blackscreen.alpha = 1;
	self.blackscreen.x = 0;
	self.blackscreen.y = 0;
	self.blackscreen.alignX = "left";
	self.blackscreen.alignY = "top";
	self.blackscreen.horzAlign = "fullscreen";
	self.blackscreen.vertAlign = "fullscreen";
	self.blackscreen.foreground = true;
	self.blackscreen setShader( "black", 640, 480 );		
	
	self BlackScreenFadeout();
}

BlackScreenFadeout()
{
	wait( level.blackscreen_fadetime );
	
	if( isDefined( self.blackscreen ) )
	{
		self.blackscreen fadeOverTime( 1 );
		self.blackscreen.alpha = 0;
	}
	
	wait( 1 );

	if( isDefined( self.blackscreen ) ) self.blackscreen destroy();
}