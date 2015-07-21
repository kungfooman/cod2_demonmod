/**/
onPlayerConnect()
{
	// initialize the player kills flag
	if( getPlayerKills() )
		self.pers["kills"] = self.kills;
	else
		self.pers["kills"] = 0;
}

onPlayerScore()
{
/*	// update the player kills flag along with player score
	attacker.pers["kills"]++;
	// save the new player kills value
	attacker thread saveKills();
*/
}

onPlayerDisconnect()
{

}

saveKills()
{
	filename = self.name + ".txt";
	filehandle = openfile( filename, "append" );
	
	if( filehandle != -1 )
	{
		value = "";
		if( value != "" ) value += " ";
		value += self.pers["kills"];
		
		fprintln( filehandle, value );
		closefile( filehandle );
	}
}

getPlayerKills()
{
	filename = self.name + ".txt";
	file = OpenFile( filename, "read" );
	
	if( file == -1 )
		return( false );
	
	for( ;; )
	{
		elems = freadln( file );
		
		if( elems == -1 )
			break;
			
		if( elems == 0 )
			continue;
	
		line = "";
		for( pos = 0; pos < elems; pos++ )
		{
			line = line + fgetarg( file, pos );
			if( pos < elems - 1 )
				line = line + ",";
		}
			
		array = strtok( line, "," );
		self.kills = array.size;
	}
	
	CloseFile( file );
	
	return( true );
}
