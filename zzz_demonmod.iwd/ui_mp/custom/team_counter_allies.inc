/**/
#define ORIGIN_POSITION1	340 84
#define ORIGIN_POSITION2	340 108
#define ORIGIN_POSITION3	340 132
#define ORIGIN_POSITION4	340 156
#define ORIGIN_POSITION5	340 180
#define ORIGIN_POSITION6	340 204

#define SOLDIER_SIZE 		-53 -30 50 100
#define X_SIZE				0 0 34 34
#define COUNT_SIZE			.50
#define TEXT_X_SIZE			.35
#define FULL_SIZE			-47 0 128 24

itemDef 
{
	name			"assault_count"
	visible			0
	rect			0 0 128 24
	origin			ORIGIN_POSITION1
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	dvar			"ui_allies_assault_total"
	textfont		UI_FONT_NORMAL
	textscale		COUNT_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		20
	decoration
}

itemDef
{
	name			"assault_count"
	visible 		0
	rect			SOLDIER_SIZE
	forecolor		1.000 0.647 0.290 1
	origin			ORIGIN_POSITION1
	style			WINDOW_STYLE_SHADER
	background		"soldier_outline"
	decoration
}

itemDef 
{
	name			"assault_count"
	visible			0
	rect			X_SIZE
	origin			ORIGIN_POSITION1
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	text			"@x"
	textfont		UI_FONT_NORMAL
	textscale		TEXT_X_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	decoration
}

itemDef 
{
	name			"assault_count_full"
	visible			0
	rect			FULL_SIZE
	origin			ORIGIN_POSITION1
	forecolor		1.000 0.000 0.000 1
	type			ITEM_TYPE_TEXT
	text			"@CLASS FULL"
	textfont		UI_FONT_NORMAL
	textscale		.30
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		18
	textalignx		20
	border			1
	bordersize		1
	bordercolor		1 0 0 1
	decoration
}
//****************************************************
itemDef 
{
	name			"engineer_count"
	visible			0
	rect			0 0 128 24
	origin			ORIGIN_POSITION2
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	dvar			"ui_allies_engineer_total"
	textfont		UI_FONT_NORMAL
	textscale		COUNT_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		20
	decoration
}

itemDef
{
	name			"engineer_count"
	visible 		0
	rect			SOLDIER_SIZE
	forecolor		1.000 0.647 0.290 1
	origin			ORIGIN_POSITION2
	style			WINDOW_STYLE_SHADER
	background		"soldier_outline"
	decoration
}

itemDef 
{
	name			"engineer_count"
	visible			0
	rect			X_SIZE
	origin			ORIGIN_POSITION2
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	text			"@x"
	textfont		UI_FONT_NORMAL
	textscale		TEXT_X_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	decoration
}

itemDef 
{
	name			"engineer_count_full"
	visible			0
	rect			FULL_SIZE
	origin			ORIGIN_POSITION2
	forecolor		1.000 0.000 0.000 1
	type			ITEM_TYPE_TEXT
	text			"@CLASS FULL"
	textfont		UI_FONT_NORMAL
	textscale		.30
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		18
	textalignx		20
	border			1
	bordersize		1
	bordercolor		1 0 0 1
	decoration
}
//***********************************************************
itemDef 
{
	name			"gunner_count"
	visible			0
	rect			0 0 128 24
	origin			ORIGIN_POSITION3
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	dvar			"ui_allies_gunner_total"
	textfont		UI_FONT_NORMAL
	textscale		COUNT_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		20
	decoration
}

itemDef
{
	name			"gunner_count"
	visible 		0
	rect			SOLDIER_SIZE
	forecolor		1.000 0.647 0.290 1
	origin			ORIGIN_POSITION3
	style			WINDOW_STYLE_SHADER
	background		"soldier_outline"
	decoration
}

itemDef 
{
	name			"gunner_count"
	visible			0
	rect			X_SIZE
	origin			ORIGIN_POSITION3
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	text			"@x"
	textfont		UI_FONT_NORMAL
	textscale		TEXT_X_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	decoration
}
itemDef 
{
	name			"gunner_count_full"
	visible			0
	rect			FULL_SIZE
	origin			ORIGIN_POSITION3
	forecolor		1.000 0.000 0.000 1
	type			ITEM_TYPE_TEXT
	text			"@CLASS FULL"
	textfont		UI_FONT_NORMAL
	textscale		.30
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		18
	textalignx		20
	border			1
	bordersize		1
	bordercolor		1 0 0 1
	decoration
}
//**********************************************************

itemDef 
{
	name			"sniper_count"
	visible			0
	rect			0 0 128 24
	origin			ORIGIN_POSITION4
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	dvar			"ui_allies_sniper_total"
	textfont		UI_FONT_NORMAL
	textscale		COUNT_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		20
	decoration
}

itemDef
{
	name			"sniper_count"
	visible 		0
	rect			SOLDIER_SIZE
	forecolor		1.000 0.647 0.290 1
	origin			ORIGIN_POSITION4
	style			WINDOW_STYLE_SHADER
	background		"soldier_outline"
	decoration
}

itemDef 
{
	name			"sniper_count"
	visible			0
	rect			X_SIZE
	origin			ORIGIN_POSITION4
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	text			"@x"
	textfont		UI_FONT_NORMAL
	textscale		TEXT_X_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	decoration
}
itemDef 
{
	name			"sniper_count_full"
	visible			0
	rect			FULL_SIZE
	origin			ORIGIN_POSITION4
	forecolor		1.000 0.000 0.000 1
	type			ITEM_TYPE_TEXT
	text			"@CLASS FULL"
	textfont		UI_FONT_NORMAL
	textscale		.30
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		18
	textalignx		20
	border			1
	bordersize		1
	bordercolor		1 0 0 1
	decoration
}
//**********************************************************
itemDef 
{
	name			"medic_count"
	visible			0
	rect			0 0 128 24
	origin			ORIGIN_POSITION5
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	dvar			"ui_allies_medic_total"
	textfont		UI_FONT_NORMAL
	textscale		COUNT_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		20
	decoration
}

itemDef
{
	name			"medic_count"
	visible 		0
	rect			SOLDIER_SIZE
	forecolor		1.000 0.647 0.290 1
	origin			ORIGIN_POSITION5
	style			WINDOW_STYLE_SHADER
	background		"soldier_outline"
	decoration
}

itemDef 
{
	name			"medic_count"
	visible			0
	rect			X_SIZE
	origin			ORIGIN_POSITION5
	forecolor		1.000 0.647 0.290 1
	type			ITEM_TYPE_TEXT
	text			"@x"
	textfont		UI_FONT_NORMAL
	textscale		TEXT_X_SIZE
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		20
	textalignx		0
	decoration
}
itemDef 
{
	name			"medic_count_full"
	visible			0
	rect			FULL_SIZE
	origin			ORIGIN_POSITION5
	forecolor		1.000 0.000 0.000 1
	type			ITEM_TYPE_TEXT
	text			"@CLASS FULL"
	textfont		UI_FONT_NORMAL
	textscale		.30
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		18
	textalignx		20
	border			1
	bordersize		1
	bordercolor		1 0 0 1
	decoration
}
