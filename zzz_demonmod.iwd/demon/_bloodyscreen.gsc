/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

Splatter_View()
{
	self endon( "death" );
	self endon( "disconnect" );

	if( !level.bloodyscreen ) return;

	if( !isDefined( self.bloodyscreen ) )
	{
		self.bloodyscreen = newClientHudElem( self );
		self.bloodyscreen1 = newClientHudElem( self );
		self.bloodyscreen2 = newClientHudElem( self );
		self.bloodyscreen3 = newClientHudElem( self );

		self.bloodyscreen.alignX = "left";
		self.bloodyscreen.alignY = "top";
	
		self.bloodyscreen1.alignX = "left";
		self.bloodyscreen1.alignY = "top";

		self.bloodyscreen2.alignX = "left";
		self.bloodyscreen2.alignY = "top";
		
		self.bloodyscreen3.alignX = "left";
		self.bloodyscreen3.alignY = "top";
		
		bs1 = randomint(496);
		bs2 = randomint(336);
		bs1a = randomint(496);
		bs2a = randomint(336);
		bs1b = randomint(496);
		bs2b = randomint(336);
		bs1c = randomint(496);
		bs2c = randomint(336);

		self.bloodyscreen.x = bs1;
		self.bloodyscreen.y = bs2;

		self.bloodyscreen1.x = bs1a;
		self.bloodyscreen1.y = bs2a;

		self.bloodyscreen2.x = bs1b;
		self.bloodyscreen2.y = bs2b;

		self.bloodyscreen3.x = bs1c;
		self.bloodyscreen3.y = bs2c;

		bs3 = randomint(48);
		bs3a = randomint(48);
		bs3b = randomint(48);
		bs3c = randomint(48);
		
		self.bloodyscreen.color = (1,1,1);
		self.bloodyscreen1.color = (1,1,1);
		self.bloodyscreen2.color = (1,1,1);
		self.bloodyscreen3.color = (1,1,1);
		self.bloodyscreen.alpha = 1;
		self.bloodyscreen1.alpha = 1;
		self.bloodyscreen2.alpha = 1;
		self.bloodyscreen3.alpha = 1;
		self.bloodyscreen1.sort = 1;
		self.bloodyscreen2.sort = 1;
		self.bloodyscreen3.sort = 1;

		self.bloodyscreen SetShader( "overlay_flesh_hit2", 96 + bs3 , 96 + bs3 );
		self.bloodyscreen1 SetShader( "overlay_fleshhitgib", 96 + bs3a , 96 + bs3a );
		self.bloodyscreen2 SetShader( "overlay_flesh_hit2", 96 + bs3b , 96 + bs3b );
		self.bloodyscreen3 SetShader( "overlay_fleshhitgib", 96 + bs3c , 96 + bs3c );
	}
	
	wait( 4 );
		
	if( isdefined( self.bloodyscreen ) )
	{
		self.bloodyscreen fadeOverTime( 2 ); 
		self.bloodyscreen.alpha = 0;
	}

	if( isdefined( self.bloodyscreen1 ) )
	{
		self.bloodyscreen1 fadeOverTime( 2 );
		self.bloodyscreen1.alpha = 0;
	}

	if( isdefined( self.bloodyscreen2 ) )
	{
		self.bloodyscreen2 fadeOverTime( 2 );
		self.bloodyscreen2.alpha = 0;
	}

	if( isdefined( self.bloodyscreen3 ) )
	{
		self.bloodyscreen3 fadeOverTime( 2 );
		self.bloodyscreen3.alpha = 0; 
	}
		
	wait( 2 ); 
		
	self thread CleanUponDeath();
}

CleanUponDeath()
{
	if( !level.bloodyscreen ) return;

	// Remove bloody screen
	if( isDefined( self.bloodyscreen ) )	self.bloodyscreen destroy();
	if( isDefined( self.bloodyscreen1 ) )	self.bloodyscreen1 destroy();
	if( isDefined( self.bloodyscreen2 ) )	self.bloodyscreen2 destroy();
	if( isDefined( self.bloodyscreen3 ) )	self.bloodyscreen3 destroy();
}