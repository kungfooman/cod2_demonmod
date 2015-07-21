/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

Start_Protection()
{
	if( !level.spawnprotection )
		return;
	
	self.spawnprotected = true;
	
	self thread CleanUponDeath();
	
	if( level.spawnpro_timer )
	{
		self.protected_timer = newClientHudElem( self );
		self.protected_timer.x = 0;
		self.protected_timer.y = 140;
		self.protected_timer.alignX = "center";
		self.protected_timer.alignY = "middle";
		self.protected_timer.horzAlign = "center_safearea";
		self.protected_timer.vertAlign = "center_safearea";	
		self.protected_timer.fontScale = 1.5;
		self.protected_timer.font = "default";
		self.protected_timer.alpha = .9;
		self.protected_timer.color = ( 1, 1, 0 );
		self.protected_timer setTimer( level.spawnprotection );
	}

	self.protected_hudicon = newClientHudElem( self );
	self.protected_hudicon.x = 0;
	self.protected_hudicon.y = 110;
	self.protected_hudicon.alignX = "center";
	self.protected_hudicon.alignY = "middle";
	self.protected_hudicon.horzAlign = "center_safearea";
	self.protected_hudicon.vertAlign = "center_safearea";
	self.protected_hudicon.alpha = .9;
	self.protected_hudicon.archived = false;
	self.protected_hudicon setShader( game["painkiller"], 40, 40 );
	
	self thread CreateFakeHeadIcon();

	if( level.spawnpro_invisible ) 
		self hide();

	if( level.spawnpro_disable )
		self thread weapDisabledMsg();
			
	self thread PainKillerMonitor();
}

PainKillerMonitor()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "intermission" );
	
	timer = level.spawnprotection + 1; // add 1 second to total to get down to 0 before timer ends
	
	time = undefined;
	if( level.spawnpro_timer )
		time = 1;
	else
		time = 0.05;
	
	before_pos = self.origin;
	while( true )
	{
		wait( time );
		
		if( level.spawnpro_timer )
		{
			new_pos = self.origin;
			
			timer--;

			if( !timer )
				break;

			if( level.spawnpro_range )
			{
				if( distance( before_pos, new_pos ) > level.spawnpro_range *40 )
				{
					self iprintlnBold( "^3Exceeded Painkiller Range" );
					break;
				}
			}

			if( level.spawnpro_disable || level.spawnpro_freezeplayer )
			{
				self disableWeapon();
				self.weaponDisabled = true;
			}
		}
		else
		{
			if( self attackButtonPressed() || self MeleeButtonPressed() )
				break;
		}
	}
	
	self thread EndPainKiller();
}

EndPainKiller()
{
	self.spawnprotected = false;
	
	if( level.spawnpro_timer )
	{	
		if( level.spawnpro_invisible ) 
			self show();
			
		if( level.spawnpro_disable || level.spawnpro_freezeplayer ) 
			self enableWeapon();
	}

	if( level.spawnpro_freezeplayer && isDefined( self.blocker ) )
		self.blocker delete();
		
	self iprintln( "^3Painkiller Ended" );
	self thread CleanUponDeath();
	self thread retoreHeadIcon();
	self.weaponDisabled = false;
}

CleanUponDeath()
{
	if( isdefined( self.FakeHeadIcon ) ) self.FakeHeadIcon destroy();
	if( isdefined( self.protected_hudicon ) ) self.protected_hudicon destroy();
	if( isDefined( self.weap_disabledmsg ) ) self.weap_disabledmsg destroy();
	if( isdefined( self.protected_timer ) ) self.protected_timer destroy();
}

spawnBlocker()
{
	self.blocker = spawn( "script_origin", self.origin );
	self Linkto( self.blocker );
}

weapDisabledMsg()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "intermission" );
	
	time = level.spawnprotection;
	
	if( isdefined( self.weap_disabledmsg ) ) self.weap_disabledmsg destroy();
	
	if( self.spawnprotected )
	{
		if( !isdefined( self.weap_disabledmsg ) )
		{
			self.weap_disabledmsg = newClientHudElem( self );
			self.weap_disabledmsg.archived = true;
			self.weap_disabledmsg.x = 0;
			self.weap_disabledmsg.y = 160;
			self.weap_disabledmsg.alignX = "center";
			self.weap_disabledmsg.alignY = "middle";
			self.weap_disabledmsg.horzAlign = "center_safearea";
			self.weap_disabledmsg.vertAlign = "center_safearea";	
			self.weap_disabledmsg.font = "default";
			self.weap_disabledmsg.fontScale = 1.3;
			self.weap_disabledmsg.alpha = 0;
			self.weap_disabledmsg.color = ( 1, 1, 0 );
			self.weap_disabledmsg setText( &"DEMON_DISABLED_WEAPON" );
		}
		
		if( isdefined( self.weap_disabledmsg ) )
		{
			self.weap_disabledmsg fadeOverTime( 1.5 );
			self.weap_disabledmsg.alpha = 1;
		}
		
		wait( time -1 );
		
		if( isdefined( self.weap_disabledmsg ) )
		{
			self.weap_disabledmsg fadeOverTime( 1.5 );
			self.weap_disabledmsg.alpha = 0;
			wait( 1 );
			self.weap_disabledmsg destroy();
		}
	}
	
}

CreateFakeHeadIcon()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "intermission" );
	
	if( !level.protection_headicon ) return;

	if( isdefined( self.FakeHeadIcon ) ) self.FakeHeadIcon destroy();
	
	self.FakeHeadIcon = newteamHudElem( getOtherTeam( self.pers["team"] ) );
	self.FakeHeadIcon.x = self.origin[0];
	self.FakeHeadIcon.y = self.origin[1];
	self.FakeHeadIcon.z = self.origin[2]+getOffset();
	self.FakeHeadIcon.alpha = .8;
	self.FakeHeadIcon.archived = true;
	self.FakeHeadIcon setShader( game["painkiller"], 8, 8 );
	self.FakeHeadIcon setwaypoint( false );
	
	while( isAlive( self ) && self.spawnprotected )
	{
		self.headicon = "";
		
		self.FakeHeadIcon.x = self.origin[0];
		self.FakeHeadIcon.y = self.origin[1];
		self.FakeHeadIcon.z = self.origin[2]+getOffset();
		
		wait( 0.05 );
	}

	if( isdefined( self.FakeHeadIcon ) ) self.FakeHeadIcon destroy();
}

GetOffset()
{	
	offset = undefined;
	
	switch( self getstance() )
	{
		case "stand":
			offset = 75;
			break;
			
		case "crouch":
			offset = 50;
			break;
		
		case "prone":
			offset = 25;
			break;
	}
	
	return offset;
}

retoreHeadIcon()
{
	if( !level.protection_headicon ) return;
	
	if( self.pers["team"] != "spectator" && self.sessionstate == "playing" )
	{
		if( level.drawfriend )
		{
			if( level.rank )
			{
				self.statusicon = demon\_rank::ranking_GetStatusicon( self );
				
				self.headicon = demon\_rank::ranking_GetHeadicon( self );
				self.headiconteam = self.pers["team"];
			}
			else 
			{
				if( self.pers["team"] == "allies" )
				{
					self.headicon = game["headicon_allies"];
					self.headiconteam = "allies";
				}
				else
				{
					self.headicon = game["headicon_axis"];
					self.headiconteam = "axis";
				}
			}
		}
		else
		{
			self.headicon = "";
		}
	}
}





