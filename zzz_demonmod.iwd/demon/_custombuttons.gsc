/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

monitorButtons()
{
	self endon( "disconnect" );

	for( ;; )
	{
		self waittill( "menuresponse", menu, response );
		
		//============== DYNAMIC PERKS ==============
		
		if( response == "ibutton" )
		{
			if( level.dynamic_perks )
			{
				if( !self.perk_unlock[1] )
				{
					self iprintlnbold( "You Haven't Unlocked Any Perks Yet!" );
					continue;
				}
					
				switch( self.perk_count )
				{
					case 1:
						self closeMenu();
						self openMenu( game["perkgroup2"] );
						self.perk_count = 2;
						break;
					
					case 2:
						self closeMenu();
						self openMenu( game["perkgroup3"] );
						self.perk_count = 0;
						break;
						
					default:
						self openMenu( game["perkgroup1"] );
						self.perk_count = 1;
						break;
						
				}
			}
			else
				self iprintlnBold( "This feature is disabled" );
		}
		
		//========== OFFICER BINOCULARS =============
		
		if( response == "lbutton" )
		{			
			if( self.pers["class"] != "officer" || !isDefined( self.binocularsAvailable ) || isdefined( self.pers["hardPointItem"] ) 
			|| maps\mp\gametypes\_weapons::isHardPointItem( self getCurrentWeapon() ) || isDefined( self.isSprinting ) )
				continue;
			
			if( !self.binocular_count )
			{
				self setClientCvar( "cg_fovscale", ".80" );
				
				self.bioculars_ammo_return = self getWeaponSlotAmmo( "primaryb" );
				self.bioculars_clip_return = self getWeaponSlotClipAmmo( "primaryb" );
					
				self TakeWeapon( self.pers["secondary"] );
				self GiveWeapon( "binoculars_mp" );
				self setWeaponSlotWeapon( "primaryb", "binoculars_mp" );
				self switchtoWeapon( "binoculars_mp" );
				
				self.binocular_count = 1;
			}
			else if( self.binocular_count == 1 )
			{
					
				self setClientCvar( "cg_fovscale", "1" );
				
				self TakeWeapon( "binoculars_mp" );
				self GiveWeapon( self.pers["secondary"] );
				self setWeaponSlotWeapon( "primaryb", self.pers["secondary"] );
				self setWeaponSlotAmmo( "primaryb", self.bioculars_ammo_return );
				self setWeaponSlotClipAmmo( "primaryb", self.bioculars_clip_return );
				self switchtoWeapon( self getWeaponSlotWeapon( "primary" ) );
				
				self.binocular_count = 0;
			}
		}
		
		//============== CAREPACKAGES & INSERTION ==============
		
		if( response == "mbutton" )
		{
			if( self IsCarePackTime() )
				self thread hardpoints\_carepackage::setCarePackageGrenade();
			else
				self thread perks\_tactical_insertion::setInsertionGrenade();
		}
		
		//============== KEYBOARD MAP ==============
		
		if( response == "kbutton" && level.dynamic_perks )
		{	
			if( !self.keyboard_count )
			{
				self createKeyboardmapFull();
				self.keyboard_count = 1;
			}
			else
			{
				self deleteClientHudElementbyName( "keyboardmap_full" );
				self.keyboard_count = 0;
			}
			
		}
	}
}

createKeyboardmapFull()
{
	self createClientHudElement( "keyboardmap_full", 0, 0, "center", "middle", "center_safearea", "center_safearea", false, "keyboardmap", 400, 400, 1, 1, 1, 1, 1 );
}

