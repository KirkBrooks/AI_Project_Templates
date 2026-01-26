//%attributes = {}
/* Purpose: attempts to edit the folders.json
 ------------------
Util_MoveToExpFolder ()
 Created by: Kirk Brooks as Designer, Created: 01/05/26, 14:46:10

$folder:  where you _want_ $target to be
$kind:    methods; forms; classes; tables
$target:  the name of the items you want to move - supports @ wildcard

Examples:
Util_MoveToExpFolder("_KB"; "classes"; "listbox")// move the 'listbox' class into folder '_KB'
Util_MoveToExpFolder("Data Updates"; "methods"; "_data_update_@")// move all methods named '_data_update_ ...' to the folder 'Data Updates'

Table forms need the table name: 
Util_MoveToExpFolder("Invoices"; "forms"; "[Invoices]@") // moves all table forms for Invoices table to the folder
Util_MoveToExpFolder("Inputs"; "forms"; "[@]input")// move all input table forms

You can nest and un-nest folders:
Util_MoveToExpFolder("_KB";"groups";"Alerts")// moves the Alerts folder into _KB
Util_MoveToExpFolder("";"groups";"Alerts")// moves the Alerts to Top Level

*/

#DECLARE($folder : Text; $kind : Text; $target : Text)
var $key : Text
var $i; $ii : Integer
var $f : 4D.Function

If (Is compiled mode)
	return 
End if 

If (["methods"; "forms"; "classes"; "tables"; "groups"].indexOf($kind)=-1)
	// these are the only kinds supported
	return 
End if 

//  get the list of names to move
ARRAY TEXT($aNames; 0)
var $names : Collection
$names:=[]
$f:=Formula($1.value=$2)  //  this function finds names that MATCH $target

Case of 
	: (Position("@"; $target; *)=0)  //  no wildcard
		$names:=[$target]  //  this is the only thing that will move
		
	: ($kind="methods")
		METHOD GET NAMES($aNames; $target)  //  project method names filtered by $target
		ARRAY TO COLLECTION($names; $aNames)
		
	: ($kind="classes")
		METHOD GET PATHS(Path class; $aNames)
		ARRAY TO COLLECTION($names; $aNames)
		$names:=$names.filter($f; $target)
		
	: ($kind="tables")
		For each ($key; ds)
			If ($key=$target)
				$names.push($key)
			End if 
		End for each 
		
	: ($kind="forms")
		ARRAY TEXT($aTemp; 0)
		
		If ($target[[1]]="[")  //  these are table forms
			// Build a single array of all the table names and form names
			// have to do this so you can use the wildcard on table names
			var $n : Integer
			var $ptr : Pointer
			
			For ($i; 1; Last table number)
				$n:=Size of array($aNames)
				
				$ptr:=Table($i)
				
				If ($ptr=Null)
					continue
				End if 
				
				FORM GET NAMES($ptr->; $aTemp)  //  table form names filtered by target
				INSERT IN ARRAY($aNames; $n; Size of array($aTemp))
				
				For ($ii; 1; Size of array($aTemp))
					$aNames{$ii+$n}:="["+Table name($ptr)+"]"+$aTemp{$ii}
				End for 
			End for 
			
			ARRAY TO COLLECTION($names; $aNames)
			// now we filter the collection 
			$names:=$names.filter($f; $target)
			
		Else   //  these are Project Forms
			FORM GET NAMES($aNames; $target)  // project form names filtered by $target
			ARRAY TO COLLECTION($names; $aNames)
		End if 
		
End case 

//mark:  --- get the folder file
var $file : 4D.File
$file:=Folder(fk database folder).folder("Project/Sources").file("folders.json")

If ($file.exists=False)
	return 
End if 

var $data:=JSON Parse($file.getText())

//mark:  --- figure out what we need to do
/*  The folders.json first level keys are 'folder' names, so they must be unique. 
The properties are collections. 
'groups' is a collection of properties nested in this key
'methods; forms; classes; tables'  identify what strings that identify one of those things

*/
//  need to remove this from anyplace it is now

$f:=Formula($1.value#$2)  //  this will filter everything that DOES NOT match $target

For each ($key; $data)
	// does this key have this kind?
	If ($data[$key][$kind]=Null)
		continue
	End if 
	
	$data[$key][$kind]:=$data[$key][$kind].filter($f; $target)  // filter any target matches 
	
End for each 

//mark:  --- now place the item(s)

If ($folder="")
	//  if $folder="" this is the 'Top Level'
Else 
	If ($data[$folder]=Null)
		$data[$folder]:={}
	End if 
	
	If ($data[$folder][$kind]=Null)
		$data[$folder][$kind]:=[]
	End if 
	
	For each ($name; $names)
		$data[$folder][$kind].push($name)
	End for each 
	
	$data[$folder][$kind]:=$data[$folder][$kind].orderBy("asc")
End if 

//mark:  --- save the file
$file.setText(JSON Stringify($data; *))
RELOAD PROJECT
