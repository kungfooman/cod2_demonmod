/**/
#define ORIGIN_TEAMIMAGE 		350 -10
#define ORIGIN_TEAMICON			-70 60

#define ORIGIN_TEAMIMAGE_RUSS 	260 -30

//************* TEAM ICONS **************************

itemDef
{
	name			"american_icon"
	visible 		1
	rect			0 0 200 200
	forecolor		.2 .2 .2 .2
	origin			ORIGIN_TEAMICON
	style			WINDOW_STYLE_SHADER
	background		"teamicon_american"
	decoration
	dvartest		"scr_class_american"
	showDvar		{ "1" }
}

itemDef
{
	name			"british_icon"
	visible 		1
	rect			0 0 200 200
	forecolor		.2 .2 .2 .2
	origin			ORIGIN_TEAMICON
	 style			WINDOW_STYLE_SHADER
	background		"teamicon_british"
	decoration
	dvartest		"scr_class_british"
	showDvar		{ "1" }
}

itemDef
{
	name			"russian_icon"
	visible 		1
	rect			0 0 200 200
	forecolor		.3 .3 .3 .3
	origin			ORIGIN_TEAMICON
	 style			WINDOW_STYLE_SHADER
	background		"teamicon_russian"
	decoration
	dvartest		"scr_class_russian"
	showDvar		{ "1" }
}

//************** TEAM SOLDIERS *****************************

itemDef
{
	name			"british_team"
	visible 		1
	rect			0 0 500 500
	forecolor		.4 .4 .4 .5
	origin			ORIGIN_TEAMIMAGE
	style			WINDOW_STYLE_SHADER
	background		"team_british"
	decoration
	dvartest		"scr_class_british"
	showDvar		{ "1" }
}

itemDef
{
	name			"russian_team"
	visible 		1
	rect			0 0 500 500
	forecolor		.4 .4 .4 .5
	origin			ORIGIN_TEAMIMAGE_RUSS
	style			WINDOW_STYLE_SHADER
	background		"team_russian"
	decoration
	dvartest		"scr_class_russian"
	showDvar		{ "1" }
}

itemDef
{
	name			"american_team"
	visible 		1
	rect			0 0 500 500
	forecolor		.4 .4 .4 .5
	origin			ORIGIN_TEAMIMAGE
	style			WINDOW_STYLE_SHADER
	background		"team_american"
	decoration
	dvartest		"scr_class_american"
	showDvar		{ "1" }
}





