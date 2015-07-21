/**/
#define ORIGN_PERK_1	73 231
#define ORIGN_PERK_2	133 231
#define ORIGN_PERK_3	193 231
#define PERK_SIZE		0 6 50 50

#define PERK_DES_1		80 276
#define PERK_DES_2		135 276
#define PERK_DES_3		190 276

#define PERK_EDIT_1		75 300
#define PERK_EDIT_2		135 300
#define PERK_EDIT_3		195 300

//////////// ICONS ///////////////////////////

/////////// GROUP 1 //////////
itemDef
{
	name			"tabungas"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_weapon_tabungas"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tabungas" }
}

itemDef
{
	name			"satchel_charges"
	visible 		1
	rect			PERK_SIZE
	forecolor		.8 .8 .8 .8
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_weapon_satchel_charge"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_satchel_charge" }
}

itemDef
{
	name			"betty"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_weapon_betty"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_betty" }
}

itemDef
{
	name			"stickybomb"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_weapon_stickybomb"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_stickybomb" }
}

itemDef
{
	name			"tripwires"
	visible 		1
	rect			PERK_SIZE
	forecolor		.8 .8 .8 .8
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_weapon_tripwire"
	decoration
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tripwire" }
}

/////////// GROUP 2 //////////
itemDef
{
	name			"juggernaut"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_armorvest"
	decoration
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_armorvest" }
}

itemDef
{
	name			"stopping_power"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_bulletdamage"
	decoration
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_bulletdamage" }
}

itemDef
{
	name			"bomb_squad"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_detectexplosives"
	decoration
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_detectexplosives" }
}

itemDef
{
	name			"first_aid"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_firstaid"
	decoration
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_firstaid" }
}

itemDef
{
	name			"tactical_insertion"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_tactical_insertion"
	decoration
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_tactical_insertion" }
}

/////////// GROUP 3 //////////
itemDef
{
	name			"endurance"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_longersprint"
	decoration
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_longersprint" }
}

itemDef
{
	name			"martyrdom"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_grenadepulldeath"
	decoration
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_grenadepulldeath" }
}

itemDef
{
	name			"sonic_boom"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_explosivedamage"
	decoration
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_explosivedamage" }
}

itemDef
{
	name			"hardline"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_hardline"
	decoration
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_hardline" }
}

itemDef
{
	name			"scavenger"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_scavenger"
	decoration
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_scavenger" }
}

//////////////////// TEXT /////////////////////////////////

///// GROUP 1 /////////

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@Tabun Gas"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tabungas" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@Satchel Charges"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		-5
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_satchel_charge" }

}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@Betties x2"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_betty" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@Sticky Bombs"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		-5
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_stickybomb" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@Tripwires X2"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	dvartest		"ui_cac_perk1"
	showDvar		{ "specialty_weapon_tripwire" }
}

///// GROUP 2 /////////

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@Juggernaut"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		5
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_armorvest" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@Stopping Power"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_bulletdamage" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@Bomb Squad"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		5
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_detectexplosives" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@First Aid"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		5
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_firstaid" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@Tactical Insertion"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		-5
	dvartest		"ui_cac_perk2"
	showDvar		{ "specialty_tactical_insertion" }
}

///// GROUP 3 /////////

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@Endurance"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_longersprint" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@Martyrdom"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_grenadepulldeath" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@Sonic Boom"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_explosivedamage" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@Hardline"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_hardline" }
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@Scavenger"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"ui_cac_perk3"
	showDvar		{ "specialty_scavenger" }
}

/////////////////////// EDIT BUTTONS  ////////////////////////

itemDef
{
	name			"edit_1"
	type			ITEM_TYPE_BUTTON
	visible			1
	rect			0 0 50 15
	origin			PERK_EDIT_1
	forecolor		1.000 0.773 0.541 1
	text			"@[ CLICK TO EDIT ]"
	textfont		UI_FONT_NORMAL
	textscale		.14
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		10
	textalignx		0
	action
	{
		play "mouse_click";
		open popup_perk1;

	}
	onFocus
	{
		play "mouse_over";
	}
}

itemDef
{
	name			"edit_2"
	type			ITEM_TYPE_BUTTON
	visible			1
	rect			0 0 50 15
	origin			PERK_EDIT_2
	forecolor		1.000 0.773 0.541 1
	text			"@[ CLICK TO EDIT ]"
	textfont		UI_FONT_NORMAL
	textscale		.14
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		10
	textalignx		0
	action
	{
		play "mouse_click";
		open popup_perk2;

	}
	mouseEnter
	{
		play "mouse_over";
	}

}

itemDef
{
	name			"edit_3"
	type			ITEM_TYPE_BUTTON
	visible			1
	rect			0 0 50 15
	origin			PERK_EDIT_3
	forecolor		1.000 0.773 0.541 1
	text			"@[ CLICK TO EDIT ]"
	textfont		UI_FONT_NORMAL
	textscale		.14
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		10
	textalignx		0
	action
	{
		play "mouse_click";
		open popup_perk3;
	}
	mouseEnter
	{
		play "mouse_over";
	}
}


