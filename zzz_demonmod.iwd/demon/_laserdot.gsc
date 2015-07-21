/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

CleanUponDeath()
{
	if( !level.laserdot ) 
		return;

	if( isdefined( self.laserdot ) ) self.laserdot destroy();
}

RunOnSpawn()
{
	if( !level.laserdot ) 
		return;
	
	self setClientCvar( "cg_drawCrosshair", 0 );
	self thread laserDotAds();
	
	color = ( level.laserdotred, level.laserdotgreen, level.laserdotblue );
	
	if( isdefined( self.laserdot ) ) self.laserdot destroy();

	if( !isdefined( self.laserdot ) )
	{
		self.laserdot = newClientHudElem( self );
		self.laserdot.x = 0;
		self.laserdot.y = 0;
		self.laserdot.alignX = "center";
		self.laserdot.alignY = "middle";
		self.laserdot.horzAlign = "center_safearea";
		self.laserdot.vertAlign = "center_safearea";
		self.laserdot.alpha = level.laserdotalpha;
		self.laserdot.color = color;
		self.laserdot setShader( "white", level.laserdotsize, level.laserdotsize );
	}
}

laserDotAds()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !level.laserdot ) return;

   	while( isAlive( self ) && ( self.sessionstate == "playing" && self.sessionstate != "spectator" ) )
	{
		// Wait
		wait (.05);

		if( isdefined( self.laserdot ) )
		{
			if( self playerADS() == 1.0 )
				self.laserdot.alpha = 0;
			else
				self.laserdot.alpha = level.laserdotalpha;
		}
	}
}
