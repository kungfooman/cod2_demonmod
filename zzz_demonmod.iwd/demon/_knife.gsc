#include demon\_utils;

init_knife()
{
	level endon( "intermission" );
	self endon( "disconnect");
	self endon( "death" );
	self endon( "stop_knife" );
	
	self notify( "knife_thread_entered" );
	wait( 0.01 );
	self endon( "knife_thread_entered" );

	allowthrow = true;
	while( isAlive( self ) && self getcurrentweapon() == "knife_mp" )
	{
		wait( 0.05 );

		// Must release attack button to throw a knife again
		if( isdefined( self ) && !self attackbuttonpressed() ) 
			allowthrow = true;

		if( allowthrow && isdefined( self ) && self attackbuttonpressed() && self isOnground() )
		{
			// Block throwing until attack button released
			allowthrow = false;

			clipammo = self getweaponslotclipammo( "primaryb" );
			if( clipammo == 0 )
			{
				wait( 1 ); // Wait for new clip
				continue;
			}

			// Now animate the throw (new thread allows the knife to be deleted when player dies)
			self thread throwKnife();
			wait( 0.7 );

			// Loop until the attack button is released
			while( isdefined( self ) && self attackbuttonpressed() ) 
				wait( 0.05 );
		}
	}
}

throwKnife()
{
	knife = spawn( "script_model", (0, 0, 0) );
	knife.origin = self.thumbmarker.origin;
	knife setModel( "xmodel/weapon_knife" );
	knife.angles = self.angles;
	knife show();
	startOrigin = self getEye();
	forward = anglesToForward( self getplayerangles() );
	forward = maps\mp\_utility::vectorscale( forward, 500 );
	endOrigin = startOrigin + forward;
	knife moveto( endOrigin,.3,0,0 );
	knife rotatepitch( 360,.7,0,0 );
	wait( 0.7 );
	knife delete();
}


