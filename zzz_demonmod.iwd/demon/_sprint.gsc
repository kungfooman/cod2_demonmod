/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	//---Sprint Vars-----
	level.allow_sprint 		= cvardef( "scr_allow_sprint", 1, 0, 1,"int");
	
	if( !level.allow_sprint )
		return;
	
	level.sprint_duration 	= cvardef( "scr_sprint_time", 10, 0, 99, "float" );
	level.sprint_regen_time = cvardef( "scr_sprint_regen_time", 2, 0, 99, "int" );
	level.sprintheavyflag 	= cvardef( "scr_sprint_heavyflag", 1, 0, 1, "int" );
	level.sprinthud 		= cvardef( "scr_sprint_hud", 1, 0, 1,"int" );
	
	if( level.hardcore )
		level.sprinthud = 0;

	level.sprint_time = int( level.sprint_duration * 250 );
	level.sprint_min_stamina = int( level.sprint_duration * 62.5 );

	regentime = level.sprint_regen_time;

	level.sprint_fast_regen = int( level.sprint_time / ( regentime * 20 ) );
	level.sprint_fast_regen2 = level.sprint_fast_regen * 2;
	level.sprint_slow_regen = int( level.sprint_fast_regen / 2 );
	level.sprint_slow_regen2 = level.sprint_slow_regen * 2;
	
	//------Sprint Images-----
	game["sprinthud_back"] = "gfx/hud/hud@health_back.tga";
	game["sprinthud"] = "gfx/hud/hud@health_bar.tga";
	
	thread Precache();
}

Precache()
{
	//---Precache only the Sprint Weapons Required by a Map for Allies---
	if( isDefined( game["allies"] ) )
	{
		switch( game["allies"] ) 
		{
			case "american": 
			{
				demonPrecacheItem( "sprint_thompson_mp" );
				demonPrecacheItem( "sprint_greasegun_mp" );
				demonPrecacheItem( "sprint_colt_mp" );
				demonPrecacheItem( "sprint_bar_mp" );
				demonPrecacheItem( "sprint_m1garand_mp" );
				demonPrecacheItem( "sprint_m1carbine_mp" );
				demonPrecacheItem( "sprint_springfield_mp" );
				demonPrecacheItem( "sprint_springfield_scope_mp" );
				demonPrecacheItem( "sprint_30cal_mp" );
			}
			break;
			
			case "british":
			{
				demonPrecacheItem( "sprint_thompson_mp" );
				demonPrecacheItem( "sprint_m1garand_mp" );
				demonPrecacheItem( "sprint_bren_mp" );
				demonPrecacheItem( "sprint_enfield_mp" );
				demonPrecacheItem( "sprint_enfield_scope_mp");
				demonPrecacheItem( "sprint_sten_mp" );
				demonPrecacheItem( "sprint_webley_mp" );
			}
			break;
			
			case "russian":
			{
				demonPrecacheItem( "sprint_mosin_nagant_mp" );
				demonPrecacheItem( "sprint_mosin_nagant_sniper_mp" );
				demonPrecacheItem( "sprint_ppsh_mp" );
				demonPrecacheItem( "sprint_PPS42_mp" );
				demonPrecacheItem( "sprint_TT30_mp" );
				demonPrecacheItem( "sprint_SVT40_mp" );
				demonPrecacheItem( "sprint_dp28_mp" );
				demonPrecacheItem( "sprint_ptrs_mp" );
			}
			break;
		}
	}
	
	//---Precache German Weapons---
	demonPrecacheItem( "sprint_mp40_mp" );
	demonPrecacheItem( "sprint_mp44_mp" );
	demonPrecacheItem( "sprint_luger_mp");
	demonPrecacheItem( "sprint_kar98k_mp");
	demonPrecacheItem( "sprint_kar98k_sniper_mp");
	demonPrecacheItem( "sprint_g43_mp");
	demonPrecacheItem( "sprint_mg42_mp");
	demonPrecacheItem( "sprint_fg42_mp");
	
	//---Precache Universal Weapons---
	demonPrecacheItem( "sprint_shotgun_mp" );
	demonPrecacheItem( "sprint_knife_mp" );
	demonPrecacheItem( "sprint_magnum_mp" );
	
	//---Strings---
	demonPrecacheString( &"SPRINT_HOLD_ACTIVATE" );
	demonPrecacheString( &"SPRINT_HEAVY_FLAG" );
	
	//---Shaders---
	demonPrecacheShader( game["sprinthud_back"] );
	demonPrecacheShader( game["sprinthud"] );

}

onPlayerSpawned()
{
	if( !level.allow_sprint )
		return;
		
	if( demon\_bots::isbot( self ) ) return;
	
	self.isSprinting = undefined;

	self.sprintTime = self getSprintTime();
	self.sprint_stamina = self.sprintTime;
	self.old_position = self.origin;
			
	self thread Monitor_Sprint();
}

onPlayerKilled()
{
	if( !level.allow_sprint )
		return;
	
	if( demon\_bots::isbot( self ) ) return;
		
	self thread CleanupKilled();
}


Monitor_Sprint()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	maxwidth = 88;
	
	self setupSprintHud( maxwidth );

	for( ;; )
	{
		wait( 0.05 );
		
		delay = 0;
		while( isAlive( self ) && self useButtonPressed() && self GetStance() == "stand" && ( self.sprint_stamina > level.sprint_min_stamina ) )
		{
			wait( 0.05 );

			if( !isMoving( self ) || isHoldingBinoculars( self getCurrentWeapon() ) || self AttackButtonPressed() || self.weaponDisabled )
			{
				self.sprint_stamina = self.sprint_stamina + level.sprint_fast_regen2;
				if( self.sprint_stamina > self.sprintTime )
					self.sprint_stamina = self.sprintTime;
				break;
			}

			if( delay < 5 )
			{
				self.sprint_stamina = self.sprint_stamina + level.sprint_slow_regen2;
					
				if( self.sprint_stamina > self.sprintTime )
					self.sprint_stamina = self.sprintTime;
				delay++;
				continue;
			}
			
			if( level.sprintheavyflag && isdefined( self.flagAttached ) ) 
			{
				self thread Heavy_flag();
				continue;
			}
			
			self Sprint( maxwidth );
		}
		
		// replenish the sprint hud back to full strength
		if( level.sprinthud )
		{	
			sprint = ( self.sprintTime - self.sprint_stamina )/self.sprintTime;
			
			if( !self.sprint_stamina )
				self.sprinthud.color = ( 1.0, 0.0, 0.0 );
			else	
				self.sprinthud.color = ( sprint, 0, 1.0 - sprint );
		
			hud_width = int( ( 1.0 - sprint ) * maxwidth );
			
			if( hud_width < 1 )
				hud_width = 1;
			
			self.sprinthud setShader( game["sprinthud"], hud_width, 5 );
		}

		if( self.sprint_stamina == self.sprintTime )
			continue;

		if( isMoving( self ) )
			  self.sprint_stamina = self.sprint_stamina + level.sprint_slow_regen;
		else
			  self.sprint_stamina = self.sprint_stamina + level.sprint_fast_regen;

		if( self.sprint_stamina > self.sprintTime )
			  self.sprint_stamina = self.sprintTime;
	}
}

Sprint( maxwidth )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self notify( "start_sprinting" );
	
	// return if the current weapon has become invalid for any reason (e.g. holding a grenade button down)
	if( isInvalidWeapon( self getCurrentWeapon() ) )
		return;

	// 1st store current weapon
	self.weap_return = self getCurrentWeapon();
	
	// 2nd get the sprint weapon for the current weapon
	self.sprint_weap = getSprintWeapon( self getCurrentWeapon() ); 
	
	// 3rd determine the weapon slot ( primary or primaryb )
	if( self.weap_return == self getWeaponSlotWeapon( "primary" ) )
		self.weap_slot = "primary";
	else
		self.weap_slot = "primaryb";
	
	// 4th store the ammo for the current weapon
	self.weap_ammo = self getWeaponSlotAmmo( self.weap_slot );
	self.weap_clip = self getWeaponSlotClipAmmo( self.weap_slot );
	
	// 5th give the player the sprint weapon and set the ammo
	self TakeWeapon( self.weap_return );
	self GiveWeapon( self.sprint_weap );
	self setWeaponSlotWeapon( self.weap_slot, self.sprint_weap );
	self setWeaponSlotAmmo( self.weap_slot, self.weap_ammo );
	self setWeaponSlotClipAmmo( self.weap_slot, self.weap_clip );
	self switchToWeapon( self.sprint_weap );

	while( isAlive( self ) && self useButtonPressed() && self GetStance() == "stand" && self.sprint_stamina > 0 )
	{
		wait( 0.10 ); // <---- changed the wait time to avoid weapon wiggle
		
		self.isSprinting = true;

		if( !isMoving( self ) || self AttackButtonPressed() || !isHoldingSprintWeapon( self getCurrentWeapon() ) )
			break;

		self.sprint_stamina = self.sprint_stamina -50; // <---- this number has doubled (original was -25) since the change of wait time from 0.05 to 0.10 
		if( self.sprint_stamina < 0 )
			self.sprint_stamina = 0;
		
		// diminish the sprint hud over time
		if( level.sprinthud )
		{
			sprint = ( self.sprintTime-self.sprint_stamina ) / self.sprintTime;
			
			if( !self.sprint_stamina )
				self.sprinthud.color = ( 1.0, 0.0, 0.0 );
			else	
				self.sprinthud.color = ( sprint, 0, 1.0 - sprint );
		
			hud_width = int( ( 1.0 - sprint ) * maxwidth );
			
			if( hud_width < 1 )
				hud_width = 1;
			
			self.sprinthud setShader( game["sprinthud"], hud_width, 5 );
		}
	}

	// Stoped Sprinting for whatever reason - return old weapon and set stored ammo
	if( isAlive( self ) )
	{
		self TakeWeapon( self.sprint_weap );
		self GiveWeapon( self.weap_return );
		self setWeaponSlotWeapon( self.weap_slot, self.weap_return );
		self setWeaponSlotAmmo( self.weap_slot, self.weap_ammo );
		self setWeaponSlotClipAmmo( self.weap_slot, self.weap_clip );
		self switchToWeapon( self.weap_return );

		self thread Sprint_Breathing();
		
		self.isSprinting = undefined;
	}
}

setupSprintHud( maxwidth )
{
	if( !level.sprinthud ) return;
	
	self destroyHud();

	y = 470;
	x = 604;

	if( !isdefined( self.sprinthud_back ) )
	{
		self.sprinthud_back = newClientHudElem( self );
		self.sprinthud_back setShader( game["sprinthud_back"], maxwidth + 2, 7 );
		self.sprinthud_back.alignX = "left";
		self.sprinthud_back.alignY = "top";
		self.sprinthud_back.x = x;
		self.sprinthud_back.y = y;
	}
		
	if( !isdefined( self.sprinthud ) )
	{
		self.sprinthud = newClientHudElem( self );
		self.sprinthud setShader( game["sprinthud"], maxwidth, 5 );
		self.sprinthud.color = ( 0, 0, 1 );
		self.sprinthud.alignX = "left";
		self.sprinthud.alignY = "top";
		self.sprinthud.x = x + 1;
		self.sprinthud.y = y + 1;
	}
		
	if( !isdefined( self.sprinthud_hint ) )
	{
		self.sprinthud_hint = newClientHudElem( self );
		self.sprinthud_hint.color = (0.980,0.996,0.388);
		self.sprinthud_hint setText( &"SPRINT_HOLD_ACTIVATE" );
		self.sprinthud_hint.alignX = "right";
		self.sprinthud_hint.alignY = "top";
		self.sprinthud_hint.fontScale = 0.7;
		self.sprinthud_hint.x = x-3;
		self.sprinthud_hint.y = y;
		self.sprinthud_hint.alpha = .9;
	}
}

destroyHud()
{
	if( isdefined( self.sprinthud ) ) self.sprinthud destroy();
	if( isdefined( self.sprinthud_hint ) ) self.sprinthud_hint destroy();
	if( isdefined( self.sprinthud_back ) ) self.sprinthud_back destroy();
}

CleanupKilled()
{
	// Remove hud elements
	if( isdefined( self.sprinthud ) )			self.sprinthud destroy();
	if( isdefined( self.sprinthud_back ) )		self.sprinthud_back destroy();
	if( isdefined( self.sprinthud_hint ) )		self.sprinthud_hint destroy();
	if( isdefined( self.heavymsg ) ) 			self.heavymsg destroy();
}

Sprint_Breathing()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "start_sprinting" );

	very_tired = level.sprint_min_stamina * .75;
	getting_better = level.sprint_min_stamina * 2.25;

	played_sound = false;
	while( isAlive( self ) && self.sprint_stamina < very_tired  )
	{
		if( level.sprintheavyflag && isdefined( self.flagAttached ) )
		{
			self playLocalSound( "sprint_breathing" );
			wait( 2 );
			played_sound = true;
			continue;
		}
		else
		{ 
			self playLocalSound( "sprint_breathing" );
			played_sound = true;
			wait( 0.8 );
		}
	}

	while( self.sprint_stamina < getting_better && isAlive( self ) )
	{
		self playLocalSound( "sprint_breathing" );
		wait( 1.2 );
		played_sound = true;
	}

	if( isAlive( self ) && played_sound  )
		self playLocalSound( "sprint_breathing" );
}

Heavy_flag()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "start_sprinting" );
	
	if( isdefined( self.heavymsg ) ) self.heavymsg destroy();

	if( !isdefined( self.heavymsg ) )
	{
		self.heavymsg = newClientHudElem( self );
		self.heavymsg.archived = true;
		self.heavymsg.x = 320;
		self.heavymsg.y = 80;
		self.heavymsg.alignX = "center";
		self.heavymsg.alignY = "middle";
		self.heavymsg.fontScale = 1.3;
		self.heavymsg.alpha = 1;
		self.heavymsg setText( &"SPRINT_HEAVY_FLAG" );
	}
		
	wait( 3 );
		
	if( isDefined( self.heavymsg ) ) self.heavymsg destroy();
}

getSprintTime()
{
	final_amount = undefined;
	if( self hasPerk( "specialty_longersprint" ) )
		final_amount = level.sprint_time *2;
	else
		final_amount = level.sprint_time;
		
	return( final_amount );
}

isMoving( player )
{
	moving = true;

	if( player.old_position == player.origin )
		moving = false;

	player.old_position = player.origin;

	return( moving );
}

isHoldingSprintWeapon( weapon )
{
	if( isSubStr( weapon, "sprint_" ) )
		return( true );

	return( false );
}

getSprintWeapon( weapon )
{
	sprintWeap = undefined;
	if( weapon != "none" )
		sprintWeap = "sprint_" + weapon;
	
	return( sprintWeap );
}

isInvalidWeapon( weapon )
{
	if( weapon == "none" )
		return( true );
		
	return( false );
}

isHoldingBinoculars( Weapon )
{
	if( Weapon == "binoculars_mp" || Weapon == "hardpoint_mp" )
		return( true );
	
	return( false );
}
