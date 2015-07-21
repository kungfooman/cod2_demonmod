/**/
#define INSIGNIA_SIZE		0 0 135 135
#define ORIGIN_INSIGNIA		410 100
#define FORECOLOR			.8 .8 .8 .9

itemDef
{
	name			"assault_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"assault_insignia"
}

itemDef
{
	name			"engineer_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"engineer_insignia"
}

itemDef
{
	name			"gunner_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"gunner_insignia"
}

itemDef
{
	name			"sniper_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"sniper_insignia"
}

itemDef
{
	name			"medic_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"medic_insignia"
}

itemDef
{
	name			"officer_allied_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"officer_allied_insignia"
	dvartest 		"scr_class_american"
	showDvar		{ "1" }
}

itemDef
{
	name			"officer_allied_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"british_officer_insignia"
	dvartest 		"scr_class_british"
	showDvar		{ "1" }
}

itemDef
{
	name			"officer_allied_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"russian_officer_insignia"
	dvartest 		"scr_class_russian"
	showDvar		{ "1" }
}

itemDef
{
	name			"officer_axis_insignia"
	visible 		0
	forecolor		FORECOLOR
	rect			INSIGNIA_SIZE
	origin			ORIGIN_INSIGNIA
	style			WINDOW_STYLE_SHADER
	background		"officer_axis_insignia"
}

