/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

init()
{
	level.regen	 		= cvardef( "scr_regen", 0, 0, 1, "int" );
	level.regenmethod 	= cvardef( "scr_regen_method", 1, 0, 4, "int" );
	
	if( !level.regen )
		return;
		
	precacheShader( "overlay_low_health" );

	level.healthOverlayCutoff = 0.35;
	level.playerHealth_RegularRegenDelay = 5000;

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerDisconnect();
	}
}

onJoinedTeam()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_team");
		self notify("end_healthregen");
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_spectators");
		self notify("end_healthregen");
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		self thread playerHealthRegen();
	}
}

onPlayerKilled()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("killed_player");
		self notify("end_healthregen");
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");
	self notify("end_healthregen");
}

playerHealthRegen()
{
//||||||||||||||||||||||||||||||||||||||||||||||||||||||
//  Developed by Wanna Ganoush -- www.anarchic-x.com
//  Modified by bell for use in AWE
//||||||||||||||||||||||||||||||||||||||||||||||||||||||
//  level.regenmethod is (can be) set with cvar "awe_regen_method"
//    = "0" : implements IW's "flawed" model (default)
//	  = "1" : implements IW's "intended" model
//    = "2" : implements my "healing regen limits" model
//	  = "3" : implements "healing regen limits" and "pain"
//||||||||||||||||||||||||||||||||||||||||||||||||||||||
	self endon("end_healthregen");

	maxhealth = self.health;
	oldhealth = maxhealth;
	player = self;
	health_add = 0;

	gapHealth = 0;
	gapRecoverRatio = 0;
	sustainHealth = 0;
	sustainRegenRate = 0;
	woundGroan = 0;
	
	regenRate = 0.1; // 0.017;
	veryHurt = false;
	
	thread playerBreathingSound(maxhealth * 0.35);
	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;
    //--------------V
    lastTime = 0;
	for (;;)
	{
		wait (0.05);
		if (player.health == maxhealth)
		{
			veryHurt = false;
			continue;
		}
					
		if (player.health <= 0)
			return;

		if (player.health < oldhealth)
		{
			gapHealth = (maxHealth - player.health);
			gapRecoverRatio = ((100 - gapHealth)/100);
			sustainHealth = player.health + (gapHealth * gapRecoverRatio);
			sustainRegenRate = regenRate * (gapRecoverRatio + .5);
		}
		wasVeryHurt = veryHurt;
		ratio = player.health / maxHealth;
		if (ratio <= level.healthOverlayCutoff)
		{
			veryHurt = true;
			if (!wasVeryHurt)
			{
				hurtTime = gettime();
			}
		}
			
		if (player.health >= oldhealth)
		{
			if (gettime() - hurttime < level.playerHealth_RegularRegenDelay)
			{
				if(level.regenmethod == 0)
				{}
				else
				{
					lastTime = getTime();
				}
				continue;
			}

			if (gettime() - lastSoundTime_Recover > level.playerHealth_RegularRegenDelay)
			{
				if ( !veryHurt || level.regenmethod < 3)
				{
				}
				else
				{
					lastSoundTime_Recover = gettime();
					self playLocalSound("breathing_better");
				}
			}
	
			if (veryHurt)
			{
				newHealth = ratio;
				if(level.regenmethod == 0)
					lastTime = hurtTime;
				if (gettime() > lastTime + 3000)
				{
					if(level.regenmethod < 2)
					{
						newHealth += regenRate;
					}
					else
					{
						if (player.health < sustainHealth)
							newHealth += sustainRegenRate;
					}
					lastTime = getTime();
				}
			}
			else
			{
				newHealth = ratio;
				if(level.regenmethod == 0)
					lastTime = hurtTime;
				if (gettime() > lastTime + 3000)
				{
					if(level.regenmethod < 2)
					{
						newHealth =1;
					}
					else
					{
						if (player.health < sustainHealth)
							newHealth += sustainRegenRate;
					}
					lastTime = getTime();
				}
			
			}
							
			if (newHealth > 1.0)
				newHealth = 1.0;
				
			if (newHealth <= 0)
			{
				// Player is dead
				return;
			}
			
			player setnormalhealth( newHealth );
			oldhealth = player.health;

			continue;
		}

		oldhealth = player.health;
			
		health_add = 0;
		hurtTime = gettime();
	}	
}

playerBreathingSound(healthcap)
{
	self endon("end_healthregen");
	
	wait (2);
	player = self;
	for (;;)
	{
		wait (0.2);
		if (player.health <= 0)
			return;
			
		// Player still has a lot of health so no breathing sound
		if (player.health >= healthcap)
			continue;
			
		player playLocalSound("breathing_hurt");
		wait .784;
		wait (0.1 + randomfloat (0.8));
	}
}
