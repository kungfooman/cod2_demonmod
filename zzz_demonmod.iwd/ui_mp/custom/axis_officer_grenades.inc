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
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT2
	style			WINDOW_STYLE_SHADER
	background		"hud_tabungas_grenade"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tabungas" }
}

itemDef
{
	name			"tabungas"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT3
	style			WINDOW_STYLE_SHADER
	background		"hud_tabungas_grenade"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tabungas" }
}

//************************ SATCHEL LOADOUT ****************************************

itemDef
{
	name			"satchels"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_SATCHELSLOT1
	style			WINDOW_STYLE_SHADER
	background		"hud_satchel_charge"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_satchel_charge" }
}

itemDef
{
	name			"satchels"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_SATCHELSLOT2
	style			WINDOW_STYLE_SHADER
	background		"hud_satchel_charge"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_satchel_charge" }
}

//**************************** STICKYBOMBS ****************************************************

itemDef
{
	name			"stickybombs"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"inventory_stickybomb"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_stickybomb" }
}

itemDef
{
	name			"stickybombs"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT2
	style			WINDOW_STYLE_SHADER
	background		"inventory_stickybomb"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_stickybomb" }
}

//////////////////////////////////////////////////////////////////////
////////////////// STOCK GRENADES ////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//****************** FRAG GRENADE LOADOUT ***************************
itemDef
{
	name			"frag"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_GRENADESLOT1
	style			WINDOW_STYLE_SHADER
	background		"gfx/icons/hud@steilhandgrenate_C.tga"
	decoration
	dvartest		"ui_cac_frag"
	showDvar		{ "german" }
}

//******************** SMOKE GRENADE LOADOUT *********************************
itemDef
{
	name			"smoke"
	visible 		1
	rect			0 0 32 32
	origin			ORIGIN_SMOKESLOT
	style			WINDOW_STYLE_SHADER
	background		"hud_nebelhandgranate"
	decoration
	dvartest		"ui_cac_smoke"
	showDvar		{ "1" }
}