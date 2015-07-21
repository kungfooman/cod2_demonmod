/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/
/**************************
	ORIGINAL CODE BY BELL
***************************/

#include demon\_utils;

jumpMonitor()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "intermission" );

	count = 0;
	stop_db = (level.anti_dbbh == 1) || (level.anti_dbbh == 3);
	stop_bh = (level.anti_dbbh == 2) || (level.anti_dbbh == 3);
	lastjump = 3;

	for( ;; )
	{
		count ++;
		if( count > 3 )
		{
			jump = self StanceCheck( true );

			// Test if dive bombing
			if( stop_db && self getStance() == "prone" && canMonitor( self ) )
				self thread WeaponPause( 0.4 );
			
			// Test if bunny hopping
			if( stop_bh && ( (jump == 3) && (lastjump != 3) ) && self getCurrentWeapon() != "binoculars_mp" )
				self thread WeaponPause( 0.4 + randomfloat( 0.3 ) );
				
			lastjump = jump;
			count = 0;
		}

		wait( 0.05 );
	}
}

canMonitor( player )
{
	if( player hasPerk( "specialty_weapon_tripwire" ) || player hasPerk( "specialty_weapon_betty" ) )
		return false;
	
	return true;
}

WeaponPause( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "intermission" );

	self disableWeapon();
	
	wait( time );
	
	self enableWeapon();
}

StanceCheck( checkjump )
{
	if( checkjump && !self isOnGround() )
	{
		groundpos = physicstrace( self.origin, self.origin + (0, 0, -100) );
		if( distance( self.origin, groundpos ) >= level.anti_dbbh_jump_height )
			return 3;
	}
	
	return 0;
}