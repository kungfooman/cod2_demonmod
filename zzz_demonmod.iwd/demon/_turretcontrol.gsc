/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include maps\mp\_utility;
#include demon\_utils;

Remove_Map_Entity()
{
	level.remove_turret = cvardef( "scr_demon_remove_turrets", 0, 0, 1, "int" );

	if( level.remove_turret )
	{
		deletePlacedEntity( "misc_turret" );
		deletePlacedEntity( "misc_mg42" );
	}
}