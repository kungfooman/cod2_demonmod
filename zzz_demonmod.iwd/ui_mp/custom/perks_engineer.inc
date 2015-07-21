/**/
#define ORIGN_PERK_1	73 231
#define ORIGN_PERK_2	133 231
#define ORIGN_PERK_3	193 231
#define PERK_SIZE		0 6 50 50

#define PERK_DES_1		80 276
#define PERK_DES_2		135 276
#define PERK_DES_3		190 276

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
	dvartest		"scr_demon_allow_satchel"
	showDvar		{ "1" }
}
itemDef
{
	name			"null"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_1
	style			WINDOW_STYLE_SHADER
	background		"specialty_null"
	decoration
	dvartest		"scr_demon_allow_satchel"
	hideDvar		{ "1" }
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
	dvartest		"scr_demon_allow_bombsquad"
	showDvar		{ "1" }
}
itemDef
{
	name			"null"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_2
	style			WINDOW_STYLE_SHADER
	background		"specialty_null"
	decoration
	dvartest		"scr_demon_allow_bombsquad"
	hideDvar		{ "1" }
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
	dvartest		"scr_demon_allow_sonicboom"
	showDvar		{ "1" }
}
itemDef
{
	name			"null"
	visible 		1
	rect			PERK_SIZE
	forecolor		.7 .7 .7 .7
	origin			ORIGN_PERK_3
	style			WINDOW_STYLE_SHADER
	background		"specialty_null"
	decoration
	dvartest		"scr_demon_allow_sonicboom"
	hideDvar		{ "1" }
}

///////////////////////// TEXT //////////////////////////////
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
	dvartest		"scr_demon_allow_satchel"
	showDvar		{ "1" }
}
itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_1
	forecolor		1 1 1 1
	text			"@DISABLED"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	dvartest		"scr_demon_allow_satchel"
	hideDvar		{ "1" }
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
	dvartest		"scr_demon_allow_bombsquad"
	showDvar		{ "1" }
}
itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_2
	forecolor		1 1 1 1
	text			"@DISABLED"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		5
	dvartest		"scr_demon_allow_bombsquad"
	hideDvar		{ "1" }
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
	dvartest		"scr_demon_allow_sonicboom"
	showDvar		{ "1" }
}
itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			PERK_DES_3
	forecolor		1 1 1 1
	text			"@DISABLED"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		10
	dvartest		"scr_demon_allow_sonicboom"
	hideDvar		{ "1" }
}