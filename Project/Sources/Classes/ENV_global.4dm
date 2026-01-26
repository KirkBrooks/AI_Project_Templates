/*  ENV_global class
 Created by: Kirk Brooks as Designer, Created: 04/12/25, 08:11:55
 ------------------
Manages Environmental Variables in a text file.

NAMING
  - UPPERCASE_WITH_UNDERSCORES
  - Prefixing: Prefix with Service/App

File Name
The file name is usually .env
This obscures the file from casual discovery
If you find multiple .env files the typical hierarchy of precedence:
 - .env - The primary default file
 - .env.local - Often used for local development overrides
 -  Environment-specific files like .env.dev or .env.prod
 - .env.example or .env.template

FILE LOCATIONS
Since this is being run within the context of a 4D database we will
base file locations on this project.
 - [override] specific file passed to constructor
 - [project]  project directory                           fk database folder ;* Host Database
 - [prefs]    user settings in project directory          this._getUserPrefsFolder()
 - [data]     datafile directory                          varies
 - [4D]       Users/name/Library/Application Support/4D   fk user preferences folder
 - [user]     Users/name                                  fk home


You can specify a specific file by passing the path to that path

WRITING TO FILES
You can updated and create keys with .setEnv()

Because the whole point of environmentals is to have some security over them
the ability to write to these files is limited to
-  the override file
- .env in user prefs
To update anything else you should go directly to that file
*/

property envFiles : Collection
property _override_file : 4D.File

Class constructor($override)
	// $override is either a 4D.File or on the folder list
	Case of 
		: (Value type($override)=Is text)
			Case of 
				: ($override="prefs")
					This._override_file:=This._getUserPrefsFolder().file(".env")
				: ($override="project")
					This._override_file:=Folder(fk database folder; *).file(".env")
				: ($override="data")
					This._override_file:=This._getDatafileDirectory().file(".env")
				: ($override="4D")
					This._override_file:=Folder(fk user preferences folder; *).file(".env")
				: ($override="user")
					This._override_file:=Folder(fk home folder; *).file(".env")
			End case 
			
		: (Value type($override)=Is object) && (OB Instance of($override; 4D.File))
			This._override_file:=$override
			
	End case 
	
	This._getEnvFiles()
	
Function getEnv($key : Text) : Text
	$key:=This._normalize_key($key)
	return This._get_env($key)
	
Function setEnv($key : Text; $value : Text; $group : Text) : Boolean
	var $file : 4D.File
	
	If ($group="")
		// define the group as the project name
		$group:=File(Structure file(*); fk platform path).name
	End if 
	
	If (This._override_file#Null)
		$file:=This._override_file
	Else 
		$file:=This._getUserPrefsFolder().file(".env")
	End if 
	
	$key:=This._normalize_key($key)
	
	This._write_key_to_file($key; $value; $file; $group)
	
Function showOnDisk($key : Text)
	// shows the file the value is coming from
	// hold shift key to show all the files this key is in
	var $file : 4D.File
	
	For each ($file; This.envFiles)
		
		If (This._get_value_from_file($key; $file)#"")
			SHOW ON DISK($file.platformPath)
			
			If (Not(Shift down))
				return 
			End if 
			
		End if 
		
	End for each 
	
Function updateFiles
	This._getEnvFiles()
	
Function listKeys->$keys : Collection
	// return collection of available keys
	$keys:=[]
	var $file : 4D.File
	For each ($file; This.envFiles)
		var $col : Collection
		$col:=This._getFileKeys($file)
		$keys:=$keys.combine($col)
	End for each 
	
	//mark:  --- privates
Function _write_key_to_file($key : Text; $value : Text; $file : 4D.File; $group : Text) : Boolean
	//  group is a group line. Will begin with # on file.
	var $text : Text
	var $lines : Collection
	var $i : Integer
	
	If ($key="") || ($value="")
		return False
	End if 
	
	// if the key already exists in the file...
	If (This._get_value_from_file($key; $file)#"")
		return This._update_key($key; $value; $file)
	End if 
	
	$lines:=[]
	
	If ($file.exists)
		$text:=$file.getText()
		$lines:=Split string($text; "\n"; sk trim spaces)  // but leave the empty rows
	End if 
	
	// is there a group?
	If ($group#"")
		If ($group#"#@")
			$group:="# "+$group  //  must have #
		End if 
		
	Else 
		$group:="# misc"
	End if 
	
	$i:=$lines.indexOf($group)
	
	If ($i=-1)  //  not there - append to collection
		$lines.push("")
		$lines.push($group)
		$i:=$lines.length
		
	Else   // insert at next empty row
		
		Repeat 
			$i+=1
		Until ($i=$lines.length) || ($lines[$i]="")
		
	End if 
	
	$lines[$i]:=$key+"="+$value+Char(10)
	
	$text:=$lines.join(Char(10))
	$file.setText($text)
	return True
	
Function _update_key($key : Text; $value : Text; $file : 4D.File) : Boolean
	// use this to prevent duplicating keys
	var $text : Text
	
	If ($file=Null) || ($file.exists=False)
		return False
	End if 
	
	$text:=This._replace_value_in_text($key; $file.getText(); $value)
	$file.setText($text)
	return True
	
Function _get_env($key : Text)->$env : Text
	// hunt for a match among the files
	var $file : 4D.File
	
	For each ($file; This.envFiles)
		$env:=This._get_value_from_file($key; $file)
		
		If ($env#"")
			return $env
		End if 
		
	End for each 
	
Function _get_value_from_file($key : Text; $file : 4D.File) : Text
	// this method loads the text from the file and looks for the key
	
	If (Not($file.exists))
		return ""
	End if 
	
	return This._get_value_from_text($key; $file.getText())
	
Function _get_value_from_text($key : Text; $text : Text) : Text
	ARRAY LONGINT($pos; 0)
	ARRAY LONGINT($len; 0)
	var $pattern : Text
	
	$pattern:=$key+"=(.+)"
	
	If (Match regex($pattern; $text; 1; $pos; $len))
		return Substring($text; $pos{1}; $len{1})
	Else 
		return ""
	End if 
	
Function _replace_value_in_text($key : Text; $text : Text; $value : Text) : Text
	ARRAY LONGINT($pos; 0)
	ARRAY LONGINT($len; 0)
	var $pattern : Text
	
	$pattern:=$key+"=(.+)"
	
	If (Match regex($pattern; $text; 1; $pos; $len))
		$text:=Delete string($text; $pos{1}; $len{1})
		$text:=Insert string($text; $value; $pos{1})
	End if 
	
	return $text
	
Function _getEnvFiles()
/* This._override_path will be the first file searched
	
When multiple .env files are found in a location they will
be listed by:
  environment:  dev; staging; test; prod
  context:      server; local
	
ex: .env.dev   .env.prod.server
*/
	var $folder : 4D.Folder
	
	This.envFiles:=New shared collection()
	If (This._override_file#Null)
		This.envFiles.push(This._override_file)
	End if 
	
	This._appendFolder(This._getUserPrefsFolder())  // user prefs
	This._appendFolder(Folder(fk database folder; *))  // project dir
	This._appendFolder(This._getDatafileDirectory())  // datafile dir
	This._appendFolder(Folder(fk user preferences folder))  //  Users/name/Library/Application Support/4D
	This._appendFolder(Folder(fk home folder))  //   Users/name
	
Function _appendFolder($folder : 4D.Folder)
	//
	var $col : Collection
	
	$col:=$folder.files().query("extension = :1"; ".env@").orderBy(ck ascending)
	If ($col.length>0)
		This.envFiles:=This.envFiles.concat($col)
	End if 
	
Function _getUserPrefsFolder->$folder : 4D.Folder
	var $name : Text
	$name:="userPreferences."+System info.userName
	$folder:=Folder(fk database folder; *).folder($name)
	If (Not($folder.exists))
		$folder.create()
	End if 
	
Function _getDatafileDirectory()->$folder : 4D.Folder
	$folder:=Folder(Folder(Data file; fk platform path).parent.platformPath; fk platform path)
	
Function _normalize_key($text : Text)->$output : Text
	var $i : Integer
	
	$text:=Replace string($text; "-"; "_")
	$text:=Replace string($text; " "; "_")
	
	For ($i; 1; Length($text))
		If (Position($text[[$i]]; "ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890")>0)
			$output+=Uppercase($text[[$i]])
		End if 
	End for 
	
Function _getFileKeys($file : 4D.File)->$keys : Collection
	var $lines : Collection
	var $line : Text
	var $pos : Integer
	
	$lines:=Split string($file.getText(); "\n"; sk ignore empty strings)
	$keys:=[]
	
	For each ($line; $lines)
		$pos:=Position("="; $line)
		Case of 
			: ($pos=0)
				
			: ($line="#@")
			Else 
				$keys.push({path: $file.path; key: Substring($line; 1; $pos-1)})
		End case 
	End for each 
	