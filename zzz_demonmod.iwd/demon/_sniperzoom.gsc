/********************************************************
	Original code by OpenWarfare team
	Current arrangement and improvements by DemonSeed
*********************************************************/

#include demon\_utils;

init()
{
	level endon( "intermission" );
	
	level.sniperzoom_enable = cvardef( "scr_sniperzoom_enable", 1, 0, 1, "int");

	if( !level.sniperzoom_enable ) return;
	
	level.sniperzoom_lower_levels = cvardef( "scr_sniperzoom_lower_levels", 8, 0, 8, "int" );
	level.sniperzoom_upper_levels = cvardef( "scr_sniperzoom_upper_levels", 9, 0, 9, "int" );

	level.sniperZooms = []; 
	level.sniperZoomsText = [];
	iZoom = 10 - level.sniperzoom_upper_levels; 
	iZoomText = 34 - ( 2 * ( 9 - level.sniperzoom_upper_levels ) );
	upperLevel = 11 + level.sniperzoom_lower_levels;

	game["zoom_hint"] = &"DEMON_ZOOM_HINT";
	precacheString( game["zoom_hint"] );
	precacheString( &"&&1x" );
	  
	while( iZoom < upperLevel && iZoom < 18 ) 
	{
		// Check if this level is the default zoom level
		if( iZoom == 10 ) 
			level.sniperZoomDefault = level.sniperZooms.size;
			
		// Add this zoom level to the allowed zoom levels
		level.sniperZooms[ level.sniperZooms.size ] = iZoom;
		level.sniperZoomsText[ level.sniperZoomsText.size ] = iZoomText;
			
		// Move to the next zoom level
		iZoom++; iZoomText -= 2;
	}
		
	// Add the last zoom level x1
	if( level.sniperzoom_lower_levels == 8 ) 
	{
		level.sniperZooms[ level.sniperZooms.size ] = 18;
		level.sniperZoomsText[ level.sniperZoomsText.size ] = 1;
	}
	
}

RunOnSpawned()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if( isDefined( self.zoomLevelText ) ) self.zoomLevelText destroy();
	
	self.zoomLevelText = newClientHudElem( self );
	self.zoomLevelText.alpha = 0;
	self.zoomLevelText.fontScale = 1.3;
	self.zoomLevelText.font = "default";
	self.zoomLevelText.archived = true;
	self.zoomLevelText.hideWhenInMenu = false;
	self.zoomLevelText.alignX = "right";
	self.zoomLevelText.alignY = "top";
	self.zoomLevelText.horzAlign = "right";
	self.zoomLevelText.vertAlign = "top";
	self.zoomLevelText.sort = 1001;
	self.zoomLevelText.label = &"&&1x";
	self.zoomLevelText.x = -10;
	self.zoomLevelText.y = 10;	
		
	self setZoomLevel( level.sniperZoomDefault );
	self thread monitorCurrentWeapon();
	self thread monitorUseMeleeKeys();
}


CleanUpKilled()
{
	self setClientCvar( "cg_fovmin", level.sniperZooms[ level.sniperZoomDefault ] );
	if( isDefined( self.zoomLevelText ) ) self.zoomLevelText destroy();
	self deleteHudTextElementbyName( "zoom_hint" );
}

monitorCurrentWeapon()
{
	if( !level.sniperzoom_enable )
		return;
		
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );
	
	oldweapon = self getCurrentWeapon();

	for( ;; )
	{
		wait( 0.05 );

		if( oldWeapon != self getCurrentWeapon() ) 
		{
			oldWeapon = self getCurrentWeapon();
			
			self.sniperZoomLevel = level.sniperZoomDefault;
			self setZoomLevel( self.sniperZoomLevel );
			self updateZoomLevel( false );
						
			if( self.zoomLevelSet ) 
			{
				self setClientCvar( "cg_fovmin", level.sniperZooms[ level.sniperZoomDefault ] );		
				self.zoomLevelSet = false;
			}
		}
		else
		{
			if( isSniperRifle( oldWeapon ) )
			{		
				if( self playerADS() == 1.0 ) 
				{
					self createHudTextElement( "zoom_hint", 0, -210, "center", "middle", "center_safearea", "center_safearea", true, 1, .8, 1, 1, 1, 1.3, game["zoom_hint"] );
					
					if( !self.zoomLevelSet ) 
					{
						self setClientCvar( "cg_fovmin", level.sniperZooms[ self.sniperZoomLevel ] );
						self thread updateZoomLevel( true );	
						self.zoomLevelSet = true;				
					}
				} 
				else 
				{
					self deleteHudTextElementbyName( "zoom_hint" );
					
					if( self.zoomLevelSet ) 
					{
						self setClientCvar( "cg_fovmin", level.sniperZooms[ level.sniperZoomDefault ] );
						self.zoomLevelSet = false;
					}
				}
			}	
		}
	}
}

setZoomLevel( sniperZoomLevel )
{
	if( !isSniperRifle( self getCurrentWeapon() ) )
		return;
		
	// Change the zoom level
	self.sniperZoomLevel = sniperZoomLevel;
	self setClientCvar( "cg_fovmin", level.sniperZooms[ sniperZoomLevel ] );
	
	// Update the text element showing the zoom level
	self.zoomLevelText setValue( level.sniperZoomsText[ sniperZoomLevel ] );		
}

monitorUseMeleeKeys()
{
	if( !level.sniperzoom_enable )
		return;
		
	self endon( "disconnect" );
	self endon( "death" );

	for( ;; )
	{
		wait( 0.05 );
	
		if( isSniperRifle( self getCurrentWeapon() ) )
		{
			// Use = Zoom In, Melee = Zoom Out
			if( self useButtonPressed() ) 
				self thread zoomIn();
			else if( self meleeButtonPressed() ) 
				self thread zoomOut();
		}
	}
}

zoomIn()
{
	if( !level.sniperzoom_enable )
		return;
	
	if( self playerAds() == 1.0 ) 
	{
		if( self.sniperZoomLevel > 0 ) 
		{
			self.sniperZoomLevel--;
			self thread setZoomLevel( self.sniperZoomLevel );
			self thread updateZoomLevel( true );
		}
	}	
}


zoomOut()
{
	if( !level.sniperzoom_enable )
		return;
	
	if( self playerAds() == 1.0 ) 
	{
		if( self.sniperZoomLevel < level.sniperZooms.size - 1 ) 
		{
			self.sniperZoomLevel++;
			self thread setZoomLevel( self.sniperZoomLevel );
			self thread updateZoomLevel( true );
		}
	}	
}

updateZoomLevel( shouldshow )
{
	// Adjust the location based on the level
	if( isDefined( self.zoomLevelText ) ) self.zoomLevelText.x = -10 + ( -15 * self.sniperZoomLevel );
	
	if( shouldshow )
	{
		if( isDefined( self.zoomLevelText ) )
		{
			self.zoomLevelText.alpha = 1; 
			self.zoomLevelText fadeOverTime( 1.5 );
			self.zoomLevelText.alpha = 0;
		}
	}	
}

