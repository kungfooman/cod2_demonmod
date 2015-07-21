/**/
#define ORIGIN_TEAMIMAGE 	340 0
#define ORIGIN_TEAMICON		-70 60

itemDef
{
	name			"german_icon"
	visible 		1
	rect			0 0 200 200
	forecolor		.2 .2 .2 .2
	origin			ORIGIN_TEAMICON
	style			WINDOW_STYLE_SHADER
	background		"teamicon_german"
	decoration
}

itemDef
{
	name			"german_team"
	visible 		1
	rect			0 0 480 480
	forecolor		.4 .4 .4 .5
	origin			ORIGIN_TEAMIMAGE
	style			WINDOW_STYLE_SHADER
	background		"team_german_normandy"
	decoration
	dvartest		"ui_teams"
	showDvar		{ "american", "british" }
}

itemDef
{
	name			"german_team"
	visible 		1
	rect			0 0 500 500
	forecolor		.4 .4 .4 .5
	origin			ORIGIN_TEAMIMAGE
	style			WINDOW_STYLE_SHADER
	background		"team_german_winter"
	decoration
	dvartest		"ui_teams"
	showDvar		{ "russian" }
}

