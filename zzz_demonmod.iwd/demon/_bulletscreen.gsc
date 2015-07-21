/*************************************
	Original code by DemonSeed based on
	code by bell
**************************************/

bulletHitScreen()
{
	level endon( "intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !level.bulletscreen ) return;

	if( !isDefined( self.bulletscreen ) )
	{
		self.bulletscreen = newClientHudElem( self );
		self.bulletscreen1 = newClientHudElem( self );
		self.bulletscreen2 = newClientHudElem( self );

		self.bulletscreen.alignX = "left";
		self.bulletscreen.alignY = "top";
		self.bulletscreen1.alignX = "left";
		self.bulletscreen1.alignY = "top";
		
		self.bulletscreen2.alignX = "left";
		self.bulletscreen2.alignY = "top";
		
		bs1 = randomint(496);
		bs2 = randomint(336);
		bs1a = randomint(496);
		bs2a = randomint(336);
		bs1b = randomint(496);
		bs2b = randomint(336);

		self.bulletscreen.x = bs1;
		self.bulletscreen.y = bs2;
		self.bulletscreen1.x = bs1a;
		self.bulletscreen1.y = bs2a;
		self.bulletscreen2.x = bs1b;
		self.bulletscreen2.y = bs2b;

		bs3 = randomint( 38 );
		bs3a = randomint( 48 );
		bs3b = randomint( 50 );

		self.bulletscreen.alpha = 1;
		self.bulletscreen1.alpha = 1;
		self.bulletscreen2.alpha = 1;
		self.bulletscreen.sort = 1;
		self.bulletscreen1.sort = 1;
		self.bulletscreen2.sort = 1;
		
		self.bulletscreen SetShader( "bullethit_glass", 86 + bs3, 86 + bs3 );
		self.bulletscreen1 SetShader( "bullethit_glass1", 110 + bs3a, 110 + bs3a );
		self.bulletscreen2 SetShader( "bullethit_glass2", 100 + bs3b, 100 + bs3b );
	}
	
	wait( 2 );
		
	if( isdefined( self.bulletscreen ) )
	{
		self.bulletscreen fadeOverTime( 1.5 ); 
		self.bulletscreen.alpha = 0;
	}
	
	if( isdefined( self.bulletscreen1 ) )
	{
		self.bulletscreen1 fadeOverTime( 1.5 );
		self.bulletscreen1.alpha = 0; 
	}
	
	if( isdefined( self.bulletscreen2 ) )
	{
		self.bulletscreen2 fadeOverTime( 1.5 );
		self.bulletscreen2.alpha = 0;
	}
		
	wait( 2 ); 
		
	self thread CleanUponDeath();
}

CleanUponDeath()
{
	if( !level.bulletscreen ) return;

	// Remove bloody screen
	if ( isDefined( self.bulletscreen ) )	self.bulletscreen destroy();
	if ( isDefined( self.bulletscreen1 ) )	self.bulletscreen1 destroy();
	if ( isDefined( self.bulletscreen2 ) )	self.bulletscreen2 destroy();

}
