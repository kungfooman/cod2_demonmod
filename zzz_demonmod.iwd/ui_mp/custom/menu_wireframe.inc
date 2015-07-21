/**/
#define ORIGIN_INFO_BOX1			282 -60
#define ORIGIN_INFO_BOX2			59 180
#define ORIGIN_INFO_BOX3			59 93
#define ORIGIN_INFO_BOX4			59 -60

#define WEAPONIMAGE_SIZE			0 6 244 132

#define ORIGIN_SIDEARM_TITLE		60 315
#define ORIGIN_SPECIALTY_TITLE		60 217
#define ORIGIN_PRIMARY_TITLE		286 68

#define ORIGIN_WEAPONIMAGE			336 94 
#define ORIGIN_WEAPONPROPERTIESTEXT	306 345
#define ORIGIN_WEAPONACCURACY		405 332
#define ORIGIN_WEAPONDAMAGE			405 356
#define ORIGIN_WEAPONMOBILITY		405 380

//************************ INFO BOX 1 ********************************
// Gradient 1
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-10 128 360 340
	origin			ORIGIN_INFO_BOX1
	background		"gradient"
	border			1
	bordersize		1
	bordercolor		1.000 0.647 0.290 1
	visible			1
	decoration
}


//**********************************************************************

//***************** INFO BOX 2 (SIDE ARM) ******************************
// Gradient 2
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-10 138 220 90
	origin			ORIGIN_INFO_BOX2
	background		"gradient"
	border			1
	bordersize		1
	bordercolor		1.000 0.647 0.290 1
	visible			1
	decoration
}

//**********************************************************************

//****************** INFO BOX 3 (SPECILATIES ) *************************
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-10 128 220 94
	origin			ORIGIN_INFO_BOX3
	background		"gradient"
	border			1
	bordersize		1
	bordercolor		1.000 0.647 0.290 1
	visible			1
	decoration
}

//********************************************************************** 

//******************* INFO BOX 4 (WEAPON BUTTONS) **********************
// Gradient 2
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-10 128 220 150
	origin			ORIGIN_INFO_BOX4
	background		"gradient"
	border			1
	bordersize		1
	bordercolor		1.000 0.647 0.290 1
	visible			1
	decoration
}

//**********************************************************************

//************************ HEADINGS ************************************
itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			ORIGIN_SIDEARM_TITLE
	forecolor		1 1 1 1
	text			"@Side Arm"
	textfont		UI_FONT_NORMAL
	textscale		.25
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			ORIGIN_PRIMARY_TITLE
	forecolor		1 1 1 1
	text			"@Primary Weapon"
	textfont		UI_FONT_NORMAL
	textscale		.35
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
}

itemDef
{
	type			ITEM_TYPE_TEXT
	visible			1
	origin			ORIGIN_SPECIALTY_TITLE
	forecolor		1 1 1 1
	text			"@Specialties"
	textfont		UI_FONT_NORMAL
	textscale		.25
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
}

//****************** DISABLED WEAPON ******************************
itemDef
{
	name			"disabled_info"
	visible 		0
	forecolor		.8 .8 .8 .8
	rect			WEAPONIMAGE_SIZE
	origin			ORIGIN_WEAPONIMAGE
	style			WINDOW_STYLE_SHADER
	background		"disabled"
}
