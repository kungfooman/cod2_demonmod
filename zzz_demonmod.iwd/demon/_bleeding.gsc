/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	level.bleeding 		= cvardef( "scr_demon_bleeding", 2, 0, 2, "int" );

	if( level.bleeding )
	{
		level.startbleed 			= cvardef( "scr_demon_startbleed", 80, 1, level.player_maxhealth - 1, "int" );
		level.maxbleed 				= cvardef( "scr_demon_maxbleed", level.player_maxhealth, 0, level.player_maxhealth, "int" );
		level.bleedmsg 				= cvardef( "scr_demon_bleedmsg", 1, 0, 4, "int" );
		level.bleedsound 			= cvardef( "scr_demon_bleedsound", 0, 0, 1, "int" );
		level.bleedspeed 			= cvardef( "scr_demon_bleeddelay", 0, 0, 10, "float" );
		level.lowhealth_realism		= cvardef( "scr_demon_lowhealth_realism", 1, 0, 1, "int" );
	}
	else 
		level.bleedmsg = 0;
 
}

playerBleed( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	level endon( "intermission");
	self endon( "disconnect");
	self endon( "StopBleeding" );
	self endon( "death" );

	wait( 1 );

	bleedV = [];
	bleedV = getBleedData( sMeansOfDeath, sWeapon, sHitLoc );

	if( !isDefined( bleedV["bleedmsg"] ) ) return;

	// Do not do friendly damage if friendly damage is off
	if( level.teamBased && isPlayer( eAttacker ) && self != eAttacker && self.pers["team"] == eAttacker.pers["team"] )
	{
		if( !int( level.friendlyfire ) || level.friendlyfire == "2" )
			return;
			
		if( level.friendlyfire == "3" )
		{
			iDamage = int( iDamage * .5 );
		}
	}

	if( isPlayer( self ) )
	{
		if( isAlive( self ) && ( self.health < level.startbleed ) && self.sessionstate != "spectator" )
		{
			self.bleeding = true;
			bleedcount = ( level.maxbleed + 10 );

			msg = bleedV["bleedmsg"];

			switch( level.bleedmsg )
			{
				case 0: break;
				case 1: self iprintln( msg ); break;
				case 2: self iprintlnbold( msg ); break;
				case 3: self thread playerBleedMsg( msg ); break;

				default: self iprintln( msg ); break;
			}

			while( ( bleedcount > 0 ) && isAlive( self ) && ( self.health < level.startbleed ) && self.sessionstate != "spectator" )
			{
				if( isdefined( self.lastStand ) )
					break;
						
				if( self.health > 1 )
				{		
					self.health--;
					if( !self.bpshockinit ) self thread doBleedPainShock();
					if( !self.bsoundinit ) self thread doBleedPainSound();
					
					if( level.lowhealth_realism && self.health < 30 )
						self thread ShockDropProne();
				}
				else 
					self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

				bleedcount--;
				
				wait bleedV["bleeddly"];
			}

			self.bleeding = false;
			self.bsoundinit = false;
			self.bpshockinit = false;
			self.proning = undefined;

			if( level.bleedmsg && isalive( self ) && ( self.health > level.startbleed ) )
			{
				msg = "^1Bleeding stopped";

				switch( level.bleedmsg )
				{
					case 0: break;
					case 1: self iprintln( msg ); break;
					case 2: self iprintlnbold( msg ); break;
					case 3: self thread playerBleedMsg( msg ); break;

					default: self iprintln( msg ); break;
				}
			}
		}
	}
}

ShockDropProne()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( isdefined( self.proning ) ) return;
	self.proning = true;
	
	self iprintln( "^1You are too Wounded to Stand for Long" );

	while( self.bleeding && !( self playerADS() == 1.0 ) )
	{
		if( self.health > 40 )
		{
			self.proning = undefined;
			break; 
		}

		self maps\mp\gametypes\_weapons::dropWeapon();
		self demon\_utils::ExecClientCommand( "goprone" );
		self shellshock( "default", 3 );

		wait 8;
	}
}

doBleedPainSound()
{
	level endon( "intermission");
	self endon( "disconnect");
	self endon( "StopBleeding" );
	self endon( "death" );

	if( !level.bleedsound ) return;

	self.bsoundinit = true;
	sounddelay = 5.0;

	while( isPlayer( self ) && self.sessionstate == "playing" && isdefined( self.bleeding ) && ( self.health < level.startbleed ) )
	{
		if( self.health >= 1 && self.health <= 5 ) sounddelay = 1.0;
		else if( self.health >= 6 && self.health <= 10 ) sounddelay = 1.5;
		else if( self.health >= 11 && self.health <= 25 ) sounddelay = 2.0;
		else if( self.health >= 26 && self.health <= 50 ) sounddelay = 3.0;
		else if( self.health >= 51 && self.health <= 75 ) sounddelay = 4.0;
		else sounddelay = 5.0;

		self playLocalSound( "breathing_hurt" );

		wait sounddelay;
	}
}

doBleedPainShock()
{
	level endon( "intermission");
	self endon( "disconnect");
	self endon( "StopBleeding" );
	self endon( "death" );

	if( level.bleeding == 2 ) return;

	self.bpshockinit = true;
	shocktime = 1;

	while( isalive( self ) && self.sessionstate == "playing" && isdefined( self.bleeding ) && ( self.health < level.startbleed ) )
	{
		if( self.health >= 1 && self.health <= 5 ) shocktime = 10;
		else if( self.health >= 6 && self.health <= 10 ) shocktime = 5;
		else if( self.health >= 11 && self.health <= 25 ) shocktime = 4;
		else if( self.health >= 26 && self.health <= 50 ) shocktime = 3;
		else if( self.health >= 51 && self.health <= 75 ) shocktime = 2;

		self shellshock( "default", shocktime );

		wait shocktime + ( randomInt( 10 ) + 5 );
	}
}

playerBleedMsg( bleedmsg )
{
	level endon( "intermission");
	self endon( "disconnect");
	self endon( "StopBleeding" );
	self endon( "death" );
		
	if( !isdefined( self.bleedmsg ) )
	{
		self.bleedmsg = newClientHudElem( self );
		self.bleedmsg.x = 320;
		self.bleedmsg.y = 420;
		self.bleedmsg.alignX = "center";
		self.bleedmsg.alignY = "middle";
		self.bleedmsg.horzAlign = "fullscreen";
		self.bleedmsg.vertAlign = "fullscreen";
		self.bleedmsg.alpha = 1.0;
		self.bleedmsg.hideWhenInMenu = true;
		self.bleedmsg.fontScale = 1.4;
	}

	wait 0.5;

	if( isdefined( self.bleedmsg ) )
	{
		self.bleedmsg setText( bleedmsg );
		self.bleedmsg fadeOverTime( 2 );
		self.bleedmsg.alpha = 1;
	}

	wait 5;

	if( isdefined( self.bleedmsg ) )
	{	
		self.bleedmsg fadeOverTime( 2 );
		self.bleedmsg.alpha = 0;
	}
}

getBleedData( sMeansOfDeath, sWeapon, sHitLoc )
{
	pmsg = undefined;
	delay = undefined;

	switch( sHitLoc )
	{
		case "neck":				pmsg = "^1Your neck is bleeding"; delay = 0.7; break;
		case "head":				pmsg = "^1Your head is bleeding"; delay = 0.4; break;
		case "helmet":				pmsg = "^1Your helmet was shot off and now your head is bleeding"; delay = 0.9; break;
		case "torso_upper":			pmsg = "^1Your chest is bleeding"; delay = 1.0; break;
		case "torso_lower":			pmsg = "^1Your stomach is bleeding"; delay = 1.0; break;
		case "left_leg_upper":		pmsg = "^1Your left thigh is bleeding"; delay = 1.2; break;
		case "right_leg_upper":		pmsg = "^1Your right thigh is bleeding"; delay = 1.2; break;
		case "left_leg_lower":		pmsg = "^1Your left shin is bleeding"; delay = 1.5; break;
		case "right_leg_lower":		pmsg = "^1Your right shin is bleeding"; delay = 1.5; break;
		case "left_foot":			pmsg = "^1Your left foot is bleeding"; delay = 2.5; break;
		case "right_foot":			pmsg = "^1Your right foot is bleeding"; delay = 2.5; break;
		case "left_arm_upper":		pmsg = "^1Your upper left arm is bleeding"; delay = 1.5; break;
		case "right_arm_upper":		pmsg = "^1Your upper right arm is bleeding"; delay = 1.5; break;
		case "left_arm_lower":		pmsg = "^1Your lower left arm is bleeding"; delay = 1.5; break;
		case "right_arm_lower":		pmsg = "^1Your lower right arm is bleeding"; delay = 1.5; break;
		case "left_hand":			pmsg = "^1Your left hand is bleeding"; delay = 2.0; break;
		case "right_hand":			pmsg = "^1Your right hand is bleeding"; delay = 2.0; break;

		case "none":
		{
			switch( sMeansOfDeath )
			{
				
				case "MOD_GRENADE": pmsg = "^1You are bleeding because of that explosion"; break;
				case "MOD_GRENADE_SPLASH": pmsg = "^1You are bleeding because of that explosion"; break;
				case "MOD_PROJECTILE": pmsg = "^1You are bleeding because of that projectile"; break;
				case "MOD_PROJECTILE_SPLASH": pmsg = "^1You are bleeding because of that projectile"; break;
				case "MOD_CRUSH": pmsg = "^1You were crushed and now you're bleeding"; break;
				case "MOD_EXPLOSIVE": pmsg = "^1You are bleeding because of that explosion"; break;
				case "MOD_IMPACT": pmsg = "^1You are bleeding because of that impact"; break;
				case "MOD_FALLING": pmsg = "^1You are bleeding due to that fall"; break;
			}
		}
					
		delay = 2.0;
		break;

		default: pmsg = "^1You've been wounded and you're bleeding"; delay = 2.0; break;
	}

	bleedV["bleedmsg"] = pmsg;
	
    if( level.bleedspeed == 0 )
		bleedV["bleeddly"] = delay;
    else 
		bleedV["bleeddly"] = level.bleedspeed;
	
	return bleedV;
}
