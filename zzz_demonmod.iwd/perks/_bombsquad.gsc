/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

checkDefuse( stringType, entity, sWeapon )
{
	level endon( "killthreads" );
	self endon( "killthreads" );

	if( self.pers["checkdefuse"][ stringType ] || !self hasPerk( "specialty_detectexplosives" ) )
		return;

	range = 50;
	Y = 365;
	
	if( self getStance() == "stand" ) return;

	if( level.teamBased && self.sessionteam == entity.team && !game[stringType]["picktimesameteam"] )
		return;
	else if( ( !level.teamBased || self.sessionteam != entity.team ) && !game[stringType]["picktimeotherteam"] )
		return;

	if( stringType == "tripwire" )
	{
		distance1 = distance( entity.nade1.origin, self.origin );
		distance2 = distance( entity.nade2.origin, self.origin );
					
		if( distance1 >= range && distance2 >= range ) 
			return;
	}
	else
	{
		distance = distance( entity.landmine.origin, self.origin );
		
		if( distance >= range ) 
			return;
	}
	
	self notify( "check_" + stringType + "_placement" );

	self.pers["checkdefuse"][ stringType ] = true;

	self CleanUpMessages( stringType );

	showExplosivesMessage( stringType, sWeapon, game[ stringType ]["pickupmessage"], true );

	for( ;; )
	{
		if( isAlive( self ) && self.sessionstate == "playing" && self useButtonPressed() )
		{
			origin = self.origin;
			angles = self.angles;

			if( level.teamBased && self.sessionteam == entity.team )
			{
				if( game[ stringType ]["picktimesameteam"] )
					planttime = game[ stringType ]["picktimesameteam"];
				else
					planttime = undefined;
			}
			else
			{
				if( game[ stringType ]["picktimeotherteam"] )
					planttime = game[ stringType ]["picktimeotherteam"];
				else
					planttime = undefined;
			}

			if( isdefined( planttime ) )
			{
				self disableWeapon();
				self playsound( "MP_bomb_plant" );
				
				if( !isdefined( self.plantbar ) )
				{
					barsize = 288;
					bartime = planttime;

					self CleanUpMessages( stringType );

					self.plantbarbackground = newClientHudElem( self );				
					self.plantbarbackground.alignX = "center";
					self.plantbarbackground.alignY = "top";
					self.plantbarbackground.x = 320;
					self.plantbarbackground.y = Y - 6;
					self.plantbarbackground.alpha = 0.5;
					self.plantbarbackground.color = (0,0,0);
					self.plantbarbackground setShader( "white", (barsize + 4), 12 );			

					self.plantbar = newClientHudElem( self );				
					self.plantbar.alignX = "left";
					self.plantbar.alignY = "top";
					self.plantbar.x = (320 - (barsize / 2.0));
					self.plantbar.y = Y - 4;
					self.plantbar setShader( "white", 0, 8 );
					self.plantbar scaleOverTime( bartime , barsize, 8 );

					showExplosivesMessage( stringType, sWeapon, game[stringType]["pickingUpmessage"], true );
				}

				color = 1;
				for( i=0; i < planttime*20 && isdefined( entity ); i++ )
				{
					if( !( self useButtonPressed() && origin == self.origin && isAlive( self ) && self.sessionstate == "playing" ) )
						break;

					if( isdefined( self.plantbar ) )
						self.plantbar.color = (color,1,color);

					color -= 0.05 / planttime;
					wait 0.05;
				}
				
				self playsound( "weap_fraggrenade_pin" );
				self CleanUpMessages( stringType );
				self enableWeapon();
				
				if( i < planttime*20 || !isdefined( entity ) )
				{
					self.pers["checkdefuse"][ stringType ] = false;
					return;
				}
			}

			if( level.teamBased )
				game[ stringType + "_team" ][entity.team]--;
			else
				game[ stringType + "_team" ]--;
				
			entity notify( "monitor_" + stringType );
			
			wait .05;
			
			if( isdefined( entity.nade1 ) )
				entity.nade1 delete();
			if( isdefined( entity.nade2 ) )
				entity.nade2 delete();
			
			if( isdefined( entity.landmine ) )
				entity.landmine delete();
				
			if( isdefined( entity.entityHeadIcons ) ) 
				entity maps\mp\gametypes\_entityheadicons::setEntityHeadIcon( "none" );	
				
			if( isdefined( entity ) )
				entity delete();

			self.pers[ stringType + "_count" ]++;
				
			if( self.pers[ stringType + "_count" ] > 2 )
				self.pers[ stringType + "_count" ] = 2;
			
			if( stringType == "tripwire" && self hasPerk( "specialty_weapon_tripwire" ) || stringType == "landmine" && self hasPerk( "specialty_weapon_betty" ) )
				self setClientCvar( "cg_player_" + stringType + "_count", self.pers[ stringType + "_count"] );

			break;
		}
		wait .05;

		if( self getStance() == "stand" ) break;
		
		if( stringType == "tripwire" )
		{
			if( !isdefined( entity.nade1 ) || !isdefined( entity.nade2 ) )
				break;
				
			distance1 = distance( entity.nade1.origin, self.origin );
			distance2 = distance( entity.nade2.origin, self.origin );
			
			if( distance1 >= range && distance2 >= range ) 
				break;
		}
		else
		{
			if( !isdefined( entity.landmine ) )
				break;
			
			distance = distance( entity.landmine.origin, self.origin );
			
			if( distance >= range ) 
				break;
		}
	}

	self CleanUpMessages( stringType );

	self.pers["checkdefuse"][ stringType ] = false;
}

showExplosivesMessage( stringType, sWeapon, which_message, defuse )
{
	if( isdefined( self.Explosivesmessage[stringType] ) )	self.Explosivesmessage[stringType] destroy();
	if( isdefined( self.ExplosivesShader[stringType] ) ) self.ExplosivesShader[stringType] destroy();
	
	Y = 345;
	
	self.Explosivesmessage[stringType] = newClientHudElem( self );
	self.Explosivesmessage[stringType].alignX = "center";
	self.Explosivesmessage[stringType].alignY = "middle";
	self.Explosivesmessage[stringType].x = 320;
	self.Explosivesmessage[stringType].y = Y;
	self.Explosivesmessage[stringType].alpha = 1;
	self.Explosivesmessage[stringType].fontScale = 0.85;
	if( ( isdefined( game[stringType]["pickingUpmessage"] ) && which_message == game[stringType]["pickingUpmessage"] ) ||
		( isdefined( game[stringType]["placingmessage"] ) && which_message == game[stringType]["placingmessage"] ) )
		self.Explosivesmessage[stringType].color = (.5,.5,.5);
	self.Explosivesmessage[stringType] setText( which_message );

	self.ExplosivesShader[stringType] = newClientHudElem( self );
	self.ExplosivesShader[stringType].alignX = "center";
	self.ExplosivesShader[stringType].alignY = "top";
	self.ExplosivesShader[stringType].x = 320;
	self.ExplosivesShader[stringType].y = Y+30;
	self.ExplosivesShader[stringType] setShader( self GetShadertoUse( stringType, sWeapon, defuse ), 40, 40 );
}

CleanUpMessages( stringType )
{
	if( isdefined( self.pickbar ) )				self.pickbar destroy();
	if( isdefined( self.plantbarbackground ) )	self.plantbarbackground destroy();
	if( isdefined( self.plantbar ) )			self.plantbar destroy();
	if( isdefined( self.Explosivesmessage[stringType] ) )	self.Explosivesmessage[stringType] destroy();
	if( isdefined( self.ExplosivesShader[stringType] ) ) self.ExplosivesShader[stringType] destroy();
}

GetShadertoUse( stringType, Weapon, defuse )
{
	shader = undefined;
	switch( stringType )
	{
		case "tripwire":
			shader = self getGrenadeHud( Weapon, defuse );
			break;
		
		case "landmine":
			shader = self getLandMineHud( Weapon, defuse );
			break;
	}
	
	return shader;
}

bombsquadDetectionTrigger( origin )
{
	trigger = spawn( "trigger_radius", origin-(0,0,128), 0, 512, 256 );
	trigger.detectId = "trigger" + getTime() + randomInt( 1000000 );
	
	if( self.team == "allies" )
		otherteam = "axis";
	else
		otherteam = "allies";
		
	trigger thread detectIconWaiter( otherteam );

	self waittill( "death" );
	
	trigger notify( "end_detection" );

	if( isDefined( trigger.bombSquadIcon ) )
		trigger.bombSquadIcon destroy();
	
	trigger delete();	
}


detectIconWaiter( detectTeam )
{
	self endon( "end_detection" );
	level endon( "intermission" );

	while( true )
	{
		self waittill( "trigger", player );
		
		if( !isDefined( player.detectExplosives ) )
			continue;
			
		if( player.pers["team"] != detectTeam )
			continue;
			
		if( isDefined( player.bombSquadIds[self.detectId] ) )
			continue;
			
		if( !player hasPerk( "specialty_detectexplosives" ) )
			continue;

		player thread showHeadIcon( self );
	}
}

setupBombSquad()
{
	self.bombSquadIds = [];
	
	if( isDefined( self.detectExplosives ) && !self.bombSquadIcons.size )
	{
		for( index = 0; index < 4; index++ )
		{
			self.bombSquadIcons[index] = newClientHudElem( self );
			self.bombSquadIcons[index].x = 0;
			self.bombSquadIcons[index].y = 0;
			self.bombSquadIcons[index].z = 0;
			self.bombSquadIcons[index].alpha = 0;
			self.bombSquadIcons[index].archived = true;
			self.bombSquadIcons[index] setShader( "waypoint_bombsquad", 13, 13 );
			self.bombSquadIcons[index] setWaypoint( false );
			self.bombSquadIcons[index].detectId = "";
		}
	}
	else if( !isDefined( self.detectExplosives ) )
	{
		for( index = 0; index < self.bombSquadIcons.size; index++ )
			self.bombSquadIcons[index] destroy();
			
		self.bombSquadIcons = [];
	}
}

showHeadIcon( trigger )
{
	triggerDetectId = trigger.detectId;
	useId = -1;
	for( index = 0; index < 4; index++ )
	{
		detectId = self.bombSquadIcons[index].detectId;

		if( detectId == triggerDetectId )
			return;
			
		if( detectId == "" )
			useId = index;
	}
	
	if( useId < 0 )
		return;

	self.bombSquadIds[triggerDetectId] = true;
	
	self.bombSquadIcons[useId].x = trigger.origin[0];
	self.bombSquadIcons[useId].y = trigger.origin[1];
	self.bombSquadIcons[useId].z = trigger.origin[2]+24+128;

	self.bombSquadIcons[useId] fadeOverTime( 0.25 );
	self.bombSquadIcons[useId].alpha = 1;
	self.bombSquadIcons[useId].detectId = trigger.detectId;
	
	while( isAlive( self ) && isDefined( trigger ) && self isTouching( trigger ) )
		wait( 0.05 );
		
	if( !isDefined( self ) )
		return;
		
	if( !isDefined( self.bombSquadIcons[useId] ) )
		return;
		
	self.bombSquadIcons[useId].detectId = "";
	self.bombSquadIcons[useId] fadeOverTime( 0.25 );
	self.bombSquadIcons[useId].alpha = 0;
	self.bombSquadIds[triggerDetectId] = undefined;
}

EndBombSquad()
{
	for( index = 0; index < self.bombSquadIcons.size; index++ )
		self.bombSquadIcons[index] destroy();
			
	self.bombSquadIcons = [];
}
