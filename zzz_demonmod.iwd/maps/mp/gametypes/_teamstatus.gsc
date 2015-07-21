#include demon\_utils;

Show_TeamStatus()
{
	level endon( "game_ended" );
	
	if( !level.show_teamstatus || !level.teamBased ) return;
	
	thread CleanUp();
	
	allied_X = 600;
	axis_X = 620;
	
	thread createHud( allied_X, axis_X );

	for( ;; )
	{
		allies = [];
		axis = [];
		deadallies = [];
		deadaxis = [];
	
		players = getentarray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			if( players[i].pers["team"] == "allies" )
			{
				if( players[i].sessionstate == "playing" )
					allies[allies.size] = players[i];
				
				if( players[i].sessionstate != "playing" )
					deadallies[deadallies.size] = players[i];
			}
			else
			{
				if( players[i].sessionstate == "playing" )
					axis[axis.size] = players[i];
				
				if( players[i].sessionstate != "playing" )
					deadaxis[deadaxis.size] = players[i];
			}
		}
		
		if( isDefined( level.axisnumber ) ) level.axisnumber setValue( axis.size );
		if( isDefined( level.deadaxisnumber ) ) level.deadaxisnumber setValue( deadaxis.size );
		
		if( isDefined( level.alliednumber ) ) level.alliednumber setValue( allies.size );
		if( isDefined( level.deadalliednumber ) ) level.deadalliednumber setValue( deadallies.size );

		wait( 0.05 );
	}
}

createHud( allied_x, axis_x )
{
	if( !isdefined( level.axisicon ) )
	{
		level.axisicon = newHudElem();	
		level.axisicon.x = axis_X;
		level.axisicon.y = 20;
		level.axisicon.alignX = "center";
		level.axisicon.alignY = "middle";
		level.axisicon.horzAlign = "fullscreen";
		level.axisicon.vertAlign = "fullscreen";
		level.axisicon.alpha = 0.7;
		level.axisicon setShader( game["hudicon_axis"], 17, 17 );
	}
	
	if( !isdefined( level.axisnumber ) )
	{
		level.axisnumber = newHudElem();	
		level.axisnumber.x = axis_X;
		level.axisnumber.y = 36;
		level.axisnumber.alignX = "center";
		level.axisnumber.alignY = "middle";
		level.axisnumber.horzAlign = "fullscreen";
		level.axisnumber.vertAlign = "fullscreen";
		level.axisnumber.font = "default";
		level.axisnumber.fontscale = 1.2;
		level.axisnumber setValue( 0 );
	}
	
	if( !isdefined( level.deadaxisicon ) )
	{
		level.deadaxisicon = newHudElem();	
		level.deadaxisicon.x = axis_X;
		level.deadaxisicon.y = 54;
		level.deadaxisicon.alignX = "center";
		level.deadaxisicon.alignY = "middle";
		level.deadaxisicon.horzAlign = "fullscreen";
		level.deadaxisicon.vertAlign = "fullscreen";
		level.deadaxisicon.alpha = 0.7;
		level.deadaxisicon setShader( game["deathicon"], 17, 17 );
	}
	
	if( !isdefined( level.deadaxisnumber ) )
	{
		level.deadaxisnumber = newHudElem();	
		level.deadaxisnumber.x = axis_X;
		level.deadaxisnumber.y = 70;
		level.deadaxisnumber.alignX = "center";
		level.deadaxisnumber.alignY = "middle";
		level.deadaxisnumber.horzAlign = "fullscreen";
		level.deadaxisnumber.vertAlign = "fullscreen";
		level.deadaxisnumber.font = "default";
		level.deadaxisnumber.fontscale = 1.2;
		level.deadaxisnumber.color = ( 0.624, 0.624, 0.624 );
		level.deadaxisnumber setValue( 0 );
	}
		
	//////////////////////// ALLIES //////////////////////////////////////
		
	if( !isdefined( level.alliedicon ) )
	{
		level.alliedicon = newHudElem( );	
		level.alliedicon.x = allied_X;
		level.alliedicon.y = 20;
		level.alliedicon.alignX = "center";
		level.alliedicon.alignY = "middle";
		level.alliedicon.horzAlign = "fullscreen";
		level.alliedicon.vertAlign = "fullscreen";
		level.alliedicon.alpha = 0.7;
		level.alliedicon setShader( game["hudicon_allies"], 17, 17 );
	}
	
	if( !isdefined( level.alliednumber ) )
	{
		level.alliednumber = newHudElem( );	
		level.alliednumber.x = allied_X;
		level.alliednumber.y = 36;
		level.alliednumber.alignX = "center";
		level.alliednumber.alignY = "middle";
		level.alliednumber.horzAlign = "fullscreen";
		level.alliednumber.vertAlign = "fullscreen";
		level.alliednumber.font = "default";
		level.alliednumber.fontscale = 1.2;
		level.alliednumber setValue( 0 );
	}
	if( !isdefined( level.deadalliedicon ) )
	{
		level.deadalliedicon = newHudElem();	
		level.deadalliedicon.x = allied_X;
		level.deadalliedicon.y = 54;
		level.deadalliedicon.alignX = "center";
		level.deadalliedicon.alignY = "middle";
		level.deadalliedicon.horzAlign = "fullscreen";
		level.deadalliedicon.vertAlign = "fullscreen";
		level.deadalliedicon.alpha = 0.7;
		level.deadalliedicon setShader( game["deathicon"], 17, 17 );
	}
	
	if( !isdefined( level.deadalliednumber ) )
	{
		level.deadalliednumber = newHudElem();	
		level.deadalliednumber.x = allied_X;
		level.deadalliednumber.y = 70;
		level.deadalliednumber.alignX = "center";
		level.deadalliednumber.alignY = "middle";
		level.deadalliednumber.horzAlign = "fullscreen";
		level.deadalliednumber.vertAlign = "fullscreen";
		level.deadalliednumber.font = "default";
		level.deadalliednumber.fontscale = 1.2;
		level.deadalliednumber.color = ( 0.624, 0.624, 0.624 );
		level.deadalliednumber setValue( 0 );
	}
}

CleanUp()
{
	if( isDefined( level.axisnumber ) ) level.axisnumber destroy();
	if( isDefined( level.deadaxisnumber ) ) level.deadaxisnumber destroy();
	if( isdefined( level.axisicon ) ) level.axisicon destroy();
	if( isdefined( level.deadaxisicon ) ) level.deadaxisicon destroy();

	if( isdefined( level.deadalliedicon ) ) level.deadalliedicon destroy();
	if( isdefined( level.alliedicon ) ) level.alliedicon destroy();
	if( isDefined( level.deadalliednumber ) ) level.deadalliednumber destroy();
	if( isDefined( level.alliednumber ) ) level.alliednumber destroy();
}