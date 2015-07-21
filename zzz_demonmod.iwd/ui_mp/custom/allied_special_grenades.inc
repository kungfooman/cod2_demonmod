/**/
#define ORIGIN_SATCHELSLOT1		316 244
#define ORIGIN_SATCHELSLOT2		343 244

#define ORIGIN_GRENADESLOT1		316 244
#define ORIGIN_GRENADESLOT2		337 244
#define ORIGIN_GRENADESLOT3		358 244

#define ORIGIN_SMOKESLOT		370 244

//********************** TABUN GRENADE LOADOUT *******************************

itemDef
{
	name			"tabungas"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT2
	style			WINDOW_STYLE_SHADER
	background		"hud_tabungas_grenade"
	decoration
	dvartest		"scr_demon_allow_tabungas"
	showDvar		{ "1" }
}

itemDef
{
	name			"tabungas"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT3
	style			WINDOW_STYLE_SHADER
	background		"hud_tabungas_grenade"
	decoration
	dvartest		"scr_demon_allow_tabungas"
	showDvar		{ "1" }
}

//************************ SATCHEL LOADOUT ****************************************

itemDef
{
	name			"satchels"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_SATCHELSLOT1
	style			WINDOW_STYLE_SHADER
	background		"hud_satchel_charge"
	decoration
	dvartest		"scr_demon_allow_satchel"
	showDvar		{ "1" }
}

itemDef
{
	name			"satchels"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_SATCHELSLOT2
	style			WINDOW_STYLE_SHADER
	background		"hud_satchel_charge"
	decoration
	dvartest		"scr_demon_allow_satchel"
	showDvar		{ "1" }
}

//**************************** STICKYBOMBS ****************************************************

itemDef
{
	name			"stickybombs"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"inventory_stickybomb"
	decoration
	dvartest		"scr_demon_allow_stickybomb"
	showDvar		{ "1" }
}

itemDef
{
	name			"stickybombs"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT2
	style			WINDOW_STYLE_SHADER
	background		"inventory_stickybomb"
	decoration
	dvartest		"scr_demon_allow_stickybomb"
	showDvar		{ "1" }
}

//////////////////////////////////////////////////////////////////////
////////////////// STOCK GRENADES ////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//****************** FRAG GRENADE LOADOUT ***************************
itemDef
{
	name			"frag"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@us_grenade_C.tga"
	decoration
	dvartest		"ui_class_frags"
	showDvar		{ "american" }
}	

itemDef
{
	name			"frag"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	 style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@british_grenade_C.tga"
	decoration
	dvartest		"ui_class_frags"
	showDvar		{ "british" }
}

itemDef
{
	name			"frag"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@russian_grenade_C.tga"
	decoration
	dvartest		"ui_class_frags"
	showDvar		{ "russian" }
}

//******************************* SMOKE GRENADE LOADOUT *********************************

itemDef
{
	name			"smoke"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_SMOKESLOT
	style			WINDOW_STYLE_SHADER
	background		"hud_us_smokegrenade_C"
	decoration
	dvartest		"scr_allow_smokegrenades"
	showDvar		{ "1" }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// BACKUPS ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

////////// STICKYBOMBS ////////////////////
itemDef
{
	name			"stickybombs"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@us_grenade_C.tga"
	decoration
	dvartest		"ui_stickybomb_replace"
	showDvar		{ "american" }
}	

itemDef
{
	name			"stickybombs"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	 style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@british_grenade_C.tga"
	decoration
	dvartest		"ui_stickybomb_replace"
	showDvar		{ "british" }
}

itemDef
{
	name			"stickybombs"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@russian_grenade_C.tga"
	decoration
	dvartest		"ui_stickybomb_replace"
	showDvar		{ "russian" }
}

////////// SATCHELS ////////////////////
itemDef
{
	name			"satchels"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@us_grenade_C.tga"
	decoration
	dvartest		"ui_satchel_replace"
	showDvar		{ "american" }
}	

itemDef
{
	name			"satchels"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	 style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@british_grenade_C.tga"
	decoration
	dvartest		"ui_satchel_replace"
	showDvar		{ "british" }
}

itemDef
{
	name			"satchels"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@russian_grenade_C.tga"
	decoration
	dvartest		"ui_satchel_replace"
	showDvar		{ "russian" }
}

//////////////// TABUN GAS //////////////////////

itemDef
{
	name			"tabungas_replace"
	visible 		0
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT3
	style			WINDOW_STYLE_SHADER
	background		"hud_us_smokegrenade_C"
	decoration
	dvartest		"scr_demon_allow_tabungas"
	hideDvar		{ "1" }
}


