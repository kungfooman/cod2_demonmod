/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

dropHealth()
{
	
    if( !level.drophealth )  return;
	if( level.regen ) return;
	
	if( !self hasPerk( "specialty_firstaid" ) ) return;
 
	item_healthpack = spawn( "script_model", (0, 0, 0) );	
	item_healthpack setModel( game["Item_Healthpack"] );
	item_healthpack.targetname = "item_health";
	item_healthpack hide();    
	item_healthpack.origin = self.origin + (25, 0, 0);
	item_healthpack.angles = (0, randomint( 360 ), 0);
	item_healthpack show(); 
	item_healthpack.count = 0;
	
	healthpack_obj = spawn( "script_model", (0, 0, 0) );
	healthpack_obj setModel( game["health_obj"] );
	healthpack_obj.targetname = "health_obj";
	healthpack_obj.origin = item_healthpack.origin;
	healthpack_obj.angles = item_healthpack.angles;
	healthpack_obj.count = 0;
	healthpack_obj thread Health_Pack_Life();
	
	item_healthpack.obj = healthpack_obj;
	
	item_healthpack thread Healthpack_Think();
	if( level.healthpacks_lifespan > 0 ) 
		item_healthpack thread Health_Pack_Life();
}

Healthpack_Think()
{	
	while( true )
	{
		wait( 0.2 );
		
		if( !isDefined( self ) )
			return;
			
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) 
		{             
			player = players[i];
			
			if( player.sessionstate == "playing" && distance( self.origin, player.origin ) < 50 && (player.health < player.maxhealth || level.firstaidpickup && player.firstaidkits < 5) )
			{	
				if( player.health < player.maxhealth )
				{
					player.health = player.health+35;

					if( player.health > player.maxhealth ) 
						player.health = player.maxhealth;
					
					player playLocalSound( "health_pickup_large" );
					player iprintln( "You Picked up a Health kit" );
					
					if( isdefined( self ) && isDefined( self.obj ) ) 
					{
						self delete();
						self.obj delete();
					}
				}
				else if( level.firstaidpickup && player.firstaidkits < level.firstaidpickup )
				{
					if( !player hasPerk( "specialty_firstaid" ) ) break;
						
					player.firstaidkits++;
					
					player playLocalSound( "health_pickup_large" );
					player iprintln( "You Picked up a First Aid kit" );
					
					player.canheal = true;
					player setClientCvar( "cg_player_firstaid_value", player.firstaidkits );
					
					if( isdefined( self ) && isDefined( self.obj ) ) 
					{
						self delete();
						self.obj delete();
					}
				}
				
				return;
			}
		}				
	}
}

Health_Pack_Life()
{

	for( ;; )
	{
		if( !isDefined( self ) ) break;
		self.count++;
		if( self.count == level.healthpacks_lifespan ) self delete();
		wait( 1 );
	}
}


