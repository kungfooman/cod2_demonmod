/*************************************************
	Demon Mod for COD2 by Tally
**************************************************/

#include demon\_utils;

onPrecachePlayerModels()
{
	//------------------ Axis Class ------------------------------//
	if( isdefined( game["german_soldiertype"] ) && game["german_soldiertype"] == "africa" )
	{
		//AFRICA
		demonPrecacheModel( "xmodel/head_german_africa_mask" );

		//--- Officer ---
		//AFRICA
		demonPrecacheModel( "xmodel/playerbody_german_africa_officer" );
		demonPrecacheModel( "xmodel/german_africa_officer_hat");
		demonPrecacheModel( "xmodel/viewmodel_hands_officer_africa" );
		demonPrecacheModel( "xmodel/head_german_normandy_ericp" );
		demonPrecacheModel( "xmodel/head_german_normandy_josh" );

		//--- Medic ---
		//AFRICA
		demonPrecacheModel( "xmodel/helmet_german_medic_africa");
		demonPrecacheModel( "xmodel/playerbody_german_africa_medic" );
		demonPrecacheModel( "xmodel/viewmodel_hands_german_afrika" );
	}
	else if( isdefined( game["german_soldiertype"] ) && ( game["german_soldiertype"] == "winterlight" || game["german_soldiertype"] == "winterdark" ) )
	{
		//--- Medic ---
		demonPrecacheModel( "xmodel/playerbody_german_winterlight_medic" );
		demonPrecacheModel( "xmodel/head_german_winter_jon" );
		demonPrecacheModel( "xmodel/helmet_medic_winter" );
		
		//--- Officer ---
		demonPrecacheModel( "xmodel/helmet_german_normandy_officer_hat");
		demonPrecacheModel( "xmodel/head_german_normandy_josh" );
		demonPrecacheModel( "xmodel/head_german_normandy_ericp" );
		demonPrecacheModel( "xmodel/playerbody_axis_officer_winter" );
	}
	else 
	{
		//NORMANDY
		demonPrecacheModel( "xmodel/head_german_normandy_josh" );
		demonPrecacheModel( "xmodel/head_german_normandy_ericp" );
		demonPrecacheModel( "xmodel/head_german_normandy_christoph" );
		demonPrecacheModel( "xmodel/head_german_normandy_eric" );
		
		//--- Officer ---
		//NORMANDY
		demonPrecacheModel( "xmodel/playerbody_german_normandy_officer" );
		demonPrecacheModel( "xmodel/helmet_german_normandy_officer_hat");
		
		//--- Medic ---
		//NORMANDY
		demonPrecacheModel( "xmodel/helmet_german_normandy_medic");
		demonPrecacheModel( "xmodel/playerbody_german_normandy_medic" );
	}
	
	demonPrecacheModel( "xmodel/viewmodel_hands_german" );
	
	//---------------- Allied Class -------------------------------//
	switch( game["allies"] )
	{
		case "british":
			if( isdefined( game["british_soldiertype"] ) && game["british_soldiertype"] == "africa" )
			{
				//--- Officer British ---
				//AFRICA
				demonPrecacheModel( "xmodel/playerbody_british_africa04" );
				demonPrecacheModel( "xmodel/head_british_price" );
				
				//--- Medic British ---
				//AFRICA
				demonPrecacheModel( "xmodel/playerbody_british_africa_medic" );
				demonPrecacheModel( "xmodel/helmet_british_africa_medic" );
			}
			else
			{
				//NORMANDY
				demonPrecacheModel( "xmodel/playerbody_british_normandy_medic" );
				demonPrecacheModel( "xmodel/helmet_british_normandy_medic" );
				demonPrecacheModel( "xmodel/head_british_price" );
				demonPrecacheModel( "xmodel/viewmodel_hands_british_bare" );
			}
			break;

		case "american":
			{
				//--- Officer US ---
				demonPrecacheModel( "xmodel/playerbody_american_normandy03" );
				demonPrecacheModel( "xmodel/helmet_ranger_officer_cap" );
				demonPrecacheModel( "xmodel/head_russian_winter_volsky" );

				// --- Medic US ---
				demonPrecacheModel("xmodel/playerbody_american_normandy_medic");
				demonPrecacheModel( "xmodel/helmet_us_ranger_medic_wells" );
				demonPrecacheModel( "xmodel/head_us_ranger_medic_wells" );
				demonPrecacheModel( "xmodel/viewmodel_hands_cloth" );
			}
			break;

		case "russian":
			if( isdefined(game["russian_soldiertype"]) && ( game["russian_soldiertype"] == "padded" || game["russian_soldiertype"] == "coats" ) )
			{
				//--- Medic ----
				demonPrecacheModel( "xmodel/playerbody_russian_medic" );
				demonPrecacheModel( "xmodel/head_russian_winter_datien" );
				demonPrecacheModel( "xmodel/helmet_russian_medic" );
				
				//--- Officer ---
				demonPrecacheModel( "xmodel/playerbody_russian_officer" );
				demonPrecacheModel( "xmodel/russian_officer_cap" );
				demonPrecacheModel( "xmodel/head_russian_winter_popov" );
				
				demonPrecacheModel( "xmodel/viewmodel_hands_russian" );
				demonPrecacheModel( "xmodel/viewmodel_hands_russian_officer" );
			}
			break;
	}
	//--------------------------------------------------------------//
}

init( class )
{
	self detachAll();
	
	if( isdefined( game["allies"] ) )
	{
		switch( game["allies"] )
		{		
			case "british":
				if( isdefined( game["british_soldiertype"] ) && game["british_soldiertype"] == "africa" )
					self thread set_Africa_Models( self.pers["team"], class );
				else
					self thread set_Normandy_Models( self.pers["team"], class );
				break;

			case "russian":
				if( isdefined( game["russian_soldiertype"] ) && game["russian_soldiertype"] == "padded" )
					self thread set_Winterdark_Models( self.pers["team"], class );
				else
					self thread set_Winterlight_Models( self.pers["team"], class );
				break;
				
			case "american":
			default:
				self thread set_Normandy_Models( self.pers["team"], class );
				break;
		}
	}	
	else
	{
		switch( game["axis"] )
		{
			case "german":
				if( isdefined( game["german_soldiertype"] ) && game["german_soldiertype"] == "winterdark" )
					self thread set_Winterdark_Models( self.pers["team"], class );
				else if( isdefined( game["german_soldiertype"] ) && game["german_soldiertype"] == "winterlight" )
					self thread set_Winterlight_Models( self.pers["team"], class );
				else if( isdefined( game["german_soldiertype"] ) && game["german_soldiertype"] == "africa" )
					self thread set_Africa_Models( self.pers["team"], class );
				else
					self thread set_Normandy_Models( self.pers["team"], class );
				break;
		}
	}
}

set_Winterdark_Models( team, class )
{
	body = undefined;
	view = undefined;
	helmet = undefined;
	head = undefined;
	
	if( team == "allies" )
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_russian_medic";
				head = "xmodel/head_russian_winter_datien";
				helmet = "xmodel/helmet_russian_medic";
				view = "xmodel/viewmodel_hands_russian";
				break;
			
			case "officer":
				body = "xmodel/playerbody_russian_officer";
				view = "xmodel/viewmodel_hands_russian_officer";
				helmet = "xmodel/russian_officer_cap";
				head = "xmodel/head_russian_winter_popov";
				break;

			case "sniper":
				[[ game["allies_model"] ]]();
				break;
				
			case "assault":
				[[ game["allies_model"] ]]();
				break;
						
			case "engineer":
				[[ game["allies_model"] ]]();
				break;

			case "gunner":
				[[ game["allies_model"] ]]();
				break;
		}
	}
	else
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_german_winterlight_medic";
				head = "xmodel/head_german_winter_jon";
				helmet = "xmodel/helmet_medic_winter";
				view = "xmodel/viewmodel_hands_german_winter";
				break;
			
			case "officer":
				body = "xmodel/playerbody_axis_officer_winter";
				view = "xmodel/viewmodel_hands_german_winter";
				helmet = "xmodel/helmet_german_normandy_officer_hat";
				head = randomize_AxisofficerHead();
				break;

			case "sniper":
				[[ game["axis_model"] ]]();
				break;
				
			case "assault":
				[[ game["axis_model"] ]]();
				break;
						
			case "engineer":
				[[ game["axis_model"] ]]();
				break;

			case "gunner":
				[[ game["axis_model"] ]]();
				break;
		}	
	}
	
	self SavedModel( body, head, view, helmet );
}

set_Winterlight_Models( team, class )
{
	body = undefined;
	view = undefined;
	helmet = undefined;
	head = undefined;

	if( team == "allies" )
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_russian_medic";
				head = "xmodel/head_russian_winter_datien";
				helmet = "xmodel/helmet_russian_medic";
				view = "xmodel/viewmodel_hands_russian";
				break;
			
			case "officer":
				body = "xmodel/playerbody_russian_officer";
				view = "xmodel/viewmodel_hands_russian_officer";
				helmet = "xmodel/russian_officer_cap";
				head = "xmodel/head_russian_winter_popov";
				break;

			case "sniper":
				[[ game["allies_model"] ]]();
				break;
				
			case "assault":
				[[ game["allies_model"] ]]();
				break;
						
			case "engineer":
				[[ game["allies_model"] ]]();
				break;

			case "gunner":
				[[ game["allies_model"] ]]();
				break;
		}
	}
	else
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_german_winterlight_medic";
				head = "xmodel/head_german_winter_jon";
				helmet = "xmodel/helmet_medic_winter";
				view = "xmodel/viewmodel_hands_german_winter";
				break;
			
			case "officer":
				body = "xmodel/playerbody_axis_officer_winter";
				view = "xmodel/viewmodel_hands_german_winter";
				helmet = "xmodel/helmet_german_normandy_officer_hat";
				head = randomize_AxisofficerHead();
				break;

			case "sniper":
				[[ game["axis_model"] ]]();
				break;
				
			case "assault":
				[[ game["axis_model"] ]]();
				break;
						
			case "engineer":
				[[ game["axis_model"] ]]();
				break;

			case "gunner":
				[[ game["axis_model"] ]]();
				break;
		}	
	}
	
	self SavedModel( body, head, view, helmet );
}

set_Africa_Models( team, class )
{
	body = undefined;
	view = undefined;
	helmet = undefined;
	head = undefined;
	
	if( team == "allies" )
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_british_africa_medic";
				view = "xmodel/viewmodel_hands_british_bare";
				helmet = "xmodel/helmet_british_africa_medic";
				head = "xmodel/head_british_boon";
				break;
			
			case "officer":
				body = "xmodel/playerbody_british_africa04";
				view = "xmodel/viewmodel_hands_british_bare";
				helmet = undefined;
				head = "xmodel/head_british_price";
				break;

			case "sniper":
				[[ game["allies_model"] ]]();
				break;
				
			case "assault":
				[[ game["allies_model"] ]]();
				break;
						
			case "engineer":
				[[ game["allies_model"] ]]();
				break;

			case "gunner":
				[[ game["allies_model"] ]]();
				break;
		}
	}
	else
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_german_africa_medic";
				view = "xmodel/viewmodel_hands_german_afrika";
				helmet = "xmodel/helmet_german_medic_africa";
				head = randomize_AxisAfricaHead();
				break;
			
			case "officer":
				body = "xmodel/playerbody_german_africa_officer";
				view = "xmodel/viewmodel_hands_officer_africa";
				helmet = "xmodel/german_africa_officer_hat";
				head = randomize_AxisofficerHead();
				break;

			case "sniper":
				[[ game["axis_model"] ]]();
				break;
				
			case "assault":
				[[ game["axis_model"] ]]();
				break;
						
			case "engineer":
				[[ game["axis_model"] ]]();
				break;

			case "gunner":
				[[ game["axis_model"] ]]();
				break;
		}	
	}

	self SavedModel( body, head, view, helmet );
}

set_Normandy_Models( team, class )
{
	body = undefined;
	view = undefined;
	helmet = undefined;
	head = undefined;
	
	if( team == "allies" )
	{
		switch( game["allies"] )
		{
			case "american":
				switch( class )
				{
					case "medic":
						body = "xmodel/playerbody_american_normandy_medic";
						view = "xmodel/viewmodel_hands_cloth";
						helmet = "xmodel/helmet_us_ranger_medic_wells";
						head = "xmodel/head_us_ranger_medic_wells";
						break;
			
					case "officer":
						body = "xmodel/playerbody_american_normandy03";
						view = "xmodel/viewmodel_hands_cloth";
						helmet = "xmodel/helmet_ranger_officer_cap";
						head = "xmodel/head_russian_winter_volsky";
						break;

					case "sniper":
						[[ game["allies_model"] ]]();
						break;
						
					case "assault":
						[[ game["allies_model"] ]]();
						break;
						
					case "engineer":
						[[ game["allies_model"] ]]();
						break;

					case "gunner":
						[[ game["allies_model"] ]]();
						break;
				}
				break;
			
			case "british":
				switch( class )
				{
					case "medic":
						body = "xmodel/playerbody_british_normandy_medic";
						view = "xmodel/viewmodel_hands_british";
						helmet = "xmodel/helmet_british_normandy_medic";
						head = "xmodel/head_british_boon";
						break;
			
					case "officer":
						body = "xmodel/playerbody_british_normandy04";
						view = "xmodel/viewmodel_hands_british_bare";
						helmet = undefined;
						head = "xmodel/head_british_price";
						break;

					case "sniper":
						[[ game["allies_model"] ]]();
						break;
						
					case "assault":
						[[ game["allies_model"] ]]();
						break;
						
					case "engineer":
						[[ game["allies_model"] ]]();
						break;

					case "gunner":
						[[ game["allies_model"] ]]();
						break;
				}
				break;
		}
	
	}
	else
	{
		switch( class )
		{
			case "medic":
				body = "xmodel/playerbody_german_normandy_medic";
				view = "xmodel/viewmodel_hands_german";
				helmet = "xmodel/helmet_german_normandy_medic";
				head = randomize_AxisMedicHead();
				break;
			
			case "officer":
				body = "xmodel/playerbody_german_normandy_officer";
				view = "xmodel/viewmodel_hands_german";
				helmet = "xmodel/helmet_german_normandy_officer_hat";
				head = randomize_AxisofficerHead();
				break;

			case "sniper":
				[[ game["axis_model"] ]]();
				break;
				
			case "assault":
				[[ game["axis_model"] ]]();
				break;
						
			case "engineer":
				[[ game["axis_model"] ]]();
				break;

			case "gunner":
				[[ game["axis_model"] ]]();
				break;
		}	
	}

	self SavedModel( body, head, view, helmet );
}

SavedModel( body, head, view, helmet )
{
	if( isdefined( body ) ) self setModel( body );

	if( isdefined( head ) ) self attach( head );

	if( isdefined( helmet ) ) 
	{
		self.hatModel = helmet;
		self attach( self.hatModel );
	}

	if( isdefined( view ) ) self setViewmodel( view );
	
	if( !isDefined( self.pers["savedmodel"] ) )
		self.pers["savedmodel"] = maps\mp\_utility::saveModel();
	else
		maps\mp\_utility::loadModel( self.pers["savedmodel"] );
}

randomize_AxisAfricaHead()
{
	head = [];
	head[0] = "xmodel/head_german_afrca_eric";
	head[1] = "xmodel/head_german_afrca_josh";
	head[2] = "xmodel/head_german_afrca_christoph";
	head[3] = "xmodel/head_german_africa_mask";
	
	headmodel = head[ randomint( head.size ) ];
	return headmodel;
}

randomize_AxisofficerHead()
{
	head = [];
	head[0] = "xmodel/head_german_normandy_josh";
	head[1] = "xmodel/head_german_normandy_ericp";
	
	headmodel = head[ randomint( head.size ) ];
	return headmodel;
}

randomize_AxisMedicHead()
{
	head = [];
	head[0] = "xmodel/head_german_normandy_josh";
	head[1] = "xmodel/head_german_normandy_ericp";
	head[2] = "xmodel/head_german_normandy_christoph";
	head[3] = "xmodel/head_german_normandy_eric";
	
	headmodel = head[ randomint( head.size ) ];
	return headmodel;
}

