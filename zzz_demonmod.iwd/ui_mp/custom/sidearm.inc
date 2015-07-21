/**/
#define PISTOL_IMAGE_SIZE		0 4 65 65
#define ORIGIN_PISTOL			120 325
#define SIDEARM_EDIT			115 393

itemDef
{
	name			"colt"
	visible 		1
	rect			PISTOL_IMAGE_SIZE
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_colt45"
	dvartest		"ui_sidearm_colt"
	showDvar		{ "1" }
}

itemDef
{
	name			"webley"
	visible 		1
	rect			PISTOL_IMAGE_SIZE
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_webley"
	dvartest		"ui_sidearm_webley"
	showDvar		{ "1" }
}

itemDef
{
	name			"tokarev"
	visible 		1
	rect			PISTOL_IMAGE_SIZE
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_tokarev"
	dvartest		"ui_sidearm_tokarev"
	showDvar		{ "1" }
}

itemDef
{
	name			"walther"
	visible 		1
	rect			PISTOL_IMAGE_SIZE
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_walther"
	dvartest		"ui_sidearm_walthar"
	showDvar		{ "1" }
}

itemDef
{
	name			"magnum"
	visible 		1
	rect			0 4 75 75
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_magnum"
	dvartest		"ui_sidearm_magnum"
	showDvar		{ "1" }
}

itemDef
{
	name			"kinfe"
	visible 		1
	rect			0 0 95 95
	origin			ORIGIN_PISTOL
	style			WINDOW_STYLE_SHADER
	background		"weapon_knife"
	dvartest		"ui_sidearm_knife"
	showDvar		{ "1" }
}

/////////////////// EDIT BUTTON /////////////////////////////

itemDef
{
	name			"edit_sidearm"
	type			ITEM_TYPE_BUTTON
	visible			1
	rect			0 0 80 20
	origin			SIDEARM_EDIT
	forecolor		1.000 0.773 0.541 1
	text			"@[ CLICK TO EDIT ]"
	textfont		UI_FONT_NORMAL
	textscale		.18
	textstyle		ITEM_TEXTSTYLE_SHADOWED
	textaligny		10
	textalignx		10
	action
	{
		play "mouse_click";
		open popup_sidearm;
	}
	mouseEnter
	{
		play "mouse_over";
	}

}