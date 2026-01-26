/*  Listbox ()
 Created by: Kirk as Designer
modified: 08/23/2023
 ------------------
Default Names
eg. display data, current item, etc. These are stored in the Form and accessed with

TO USE
/*
add the listbox to the form and set the names
initialize
    Form["listbox name"]:=cs.listbox.new("listbox name")
*/

*/
property name : Text
property source; data; selectedItems : Variant
property kind : Integer
property _lastError : Text
property position : Integer
property currentItem : Object



Class constructor($name : Text)
	ASSERT:C1129(Count parameters:C259=1; "The name of the listbox object is required.")
	
	This:C1470.name:=$name  //      the name of the listbox
	
	This:C1470.source:=Null:C1517  //  collection/entity selection form[name].data is drawn from
	This:C1470.data:=Null:C1517
	This:C1470.kind:=Is undefined:K8:13
	This:C1470._lastError:=""
	
	//  use these for the listbox datasource elements
	This:C1470._clearDatasources()
	
	//mark:  --- computed attributes
Function get isReady : Boolean
	//  return true when there is data
	return (This:C1470.source#Null:C1517)
	
Function get isFormObject : Boolean
	//  true if there is a form object for this listbox
	return OBJECT Get pointer:C1124(Object named:K67:5; This:C1470.name)#Null:C1517
	
Function get dataLength : Integer
	If (This:C1470.data=Null:C1517)
		return 0
	Else 
		return This:C1470.data.length
	End if 
	
Function get isSelected : Boolean
	return Num:C11(This:C1470.position)>0
	
	//todo:  add isScalar  \\  True when source is a scalar collection
	
Function get index : Integer
	return This:C1470.position-1
	
Function get isCollection : Boolean
	return This:C1470.kind=Is collection:K8:32
	
Function get isEntitySelection : Boolean
	return (This:C1470.kind=Is object:K8:27) && (OB Instance of:C1731(This:C1470.source; 4D:C1709.EntitySelection))
	
Function get error : Text
	return This:C1470._lastError
	
Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of 
		: (This:C1470.data=Null:C1517)
			return "The listbox is empty."
		: (This:C1470.isSelected)
			return String:C10(This:C1470.selectedItems.length)+" selected out of "+String:C10(This:C1470.dataLength)
		Else 
			return "0 selected out of "+String:C10(This:C1470.dataLength)
	End case 
	
	//MARK:-  setters
Function setSource($source : Variant) : cs:C1710.listbox
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type:C1509($source)
	This:C1470._clearDatasources()
	
	If ($type=Is collection:K8:32)
		This:C1470.source:=$source
		This:C1470.kind:=$type
		This:C1470.setData()
		
		return This:C1470
	End if 
	
	If ($type=Is object:K8:27) && (OB Instance of:C1731($source; 4D:C1709.EntitySelection))  //   entity selection
		This:C1470.source:=$source
		This:C1470.kind:=$type
		This:C1470.setData()
		
		return This:C1470
	End if 
	
	This:C1470.source:=Null:C1517
	This:C1470.data:=Null:C1517
	This:C1470.kind:=0
	return This:C1470
	
Function setData : cs:C1710.listbox
	This:C1470.data:=This:C1470.source
	return This:C1470
	
Function insert($index : Integer; $element : Variant) : Object
	// attempts to add the element into data
	// only supports collections
	
	If (Not:C34(This:C1470.isCollection))
		return This:C1470._result(False:C215; "Can only insert into collections. ")
	End if 
	
	This:C1470.data.insert($index; $element)
	This:C1470.redraw()
	return This:C1470._result(True:C214)
	
	//MARK:-
Function get_item()->$value : Variant
	//  gets the current item using the position index
	return (This:C1470.isSelected) ? This:C1470.data[This:C1470.index] : Null:C1517
	
Function redraw() : cs:C1710.listbox
	This:C1470.data:=This:C1470.data
	return This:C1470
	
Function reset() : cs:C1710.listbox
	This:C1470.setData()
	return This:C1470
	
Function updateEntitySelection() : cs:C1710.listbox
	//  if this is an entity selection reloads the entities
	If (Not:C34(This:C1470.isEntitySelection))
		This:C1470._lastError:="updateEntitySelection(): this is a collecton"
		return This:C1470
	End if 
	
	var $entity : Object
	
	For each ($entity; This:C1470.source)
		$entity.reload()
	End for each 
	return This:C1470
	
Function findRow($criteria : Variant) : Integer
/*  attempts to select the row
criteria is an entity when data is entity selection
criteria is a property for collections or entity selections
and value is the comparator.
*/
	
	If (Not:C34(This:C1470.isEntitySelection)) && (Not:C34(This:C1470.isCollection))
		return -1
	End if 
	
	If (Value type:C1509($criteria)=Is object:K8:27) && (This:C1470.isEntitySelection)
		return $criteria.indexOf(This:C1470.data)+1  //  add 1 for the row number
	End if 
	
	If (Value type:C1509($criteria)=Is object:K8:27)  // collection
		return This:C1470.data.indexOf($criteria)+1  //  add 1 for the row number
	End if 
	
	return -1  //
	
Function doQuery($queryString : Text; $settings : Object) : cs:C1710.listbox
	// execute the query on this.source and put the result into this.data
	If ($queryString="")
		return This:C1470
	End if 
	
	If ($settings#Null:C1517)
		This:C1470.data:=This:C1470.source.query($queryString; $settings)
		return This:C1470.first()
	End if 
	
	This:C1470.data:=This:C1470.source.query($queryString)
	return This:C1470.redraw().first()
	
	//mark:  --- updates the form object
Function deselect : cs:C1710.listbox
	//  clear the current selection
	LISTBOX SELECT ROW:C912(*; This:C1470.name; 0; lk remove from selection:K53:3)
	This:C1470._clearDatasources()
	return This:C1470
	
Function selectRow($criteria : Variant; $value : Variant) : cs:C1710.listbox
	var $row : Integer
	If (This:C1470.dataLength=0)
		return This:C1470
	End if 
	
	Case of 
		: (Value type:C1509($criteria)=Is real:K8:4)
			$row:=$criteria
		Else 
			$row:=This:C1470.findRow($criteria; $value)
	End case 
	
	LISTBOX SELECT ROW:C912(*; This:C1470.name; $row; lk replace selection:K53:1)
	
	If ($row>2)
		OBJECT SET SCROLL POSITION:C906(*; This:C1470.name; $row; *)
		This:C1470.currentItem:=This:C1470.data[$row-1]
	End if 
	
	return This:C1470
	
Function next : cs:C1710.listbox  // select the next row
	var $row : Integer
	If (This:C1470.dataLength=0)
		return This:C1470
	End if 
	
	$row:=(This:C1470.position+1)>This:C1470.dataLength ? 1 : This:C1470.position+1
	return This:C1470.selectRow($row)
	
Function prev : cs:C1710.listbox  // select the previous row
	var $row : Integer
	If (This:C1470.dataLength=0)
		return This:C1470
	End if 
	
	$row:=(This:C1470.position-1)<1 ? This:C1470.dataLength : This:C1470.position-1
	return This:C1470.selectRow($row)
	
Function first : cs:C1710.listbox  // select the first row
	var $row : Integer
	If (This:C1470.dataLength=0)
		return This:C1470
	End if 
	
	return This:C1470.selectRow(1)
	
Function last : cs:C1710.listbox  // select the last row
	var $row : Integer
	If (This:C1470.dataLength=0)
		return This:C1470
	End if 
	
	return This:C1470.selectRow(This:C1470.dataLength)
	
	//MARK:-  data functions
	//  these are really just wrappers for native functions
	// but are convenient to have
Function indexOf($what : Variant) : Integer
/* attempts to find the index of $what in .data
if this is an entity selection $what must be an entity of that dataclass
if this is a collection $what must be the same type as the collection data
*/
	If ($what=Null:C1517) | (This:C1470.kind=Null:C1517)
		return -1
	End if 
	
	If (This:C1470.kind=Is object:K8:27)  //  entity selection: $what is an entity
		return $what.indexOf(This:C1470.data)
	End if 
	
	If (This:C1470.kind=Is collection:K8:32)
		return This:C1470.data.indexOf($what)
	End if 
	
Function sum($key : Text) : Real
	//  return the sum of $key if it is a numeric value in this.data
	return (This:C1470._keyExists($key)) ? This:C1470.data.sum($key) : 0
	
Function min($key : Text) : Real
	//  return the min of $key if it is a numeric value in this.data
	return (This:C1470._keyExists($key)) ? This:C1470.data.min($key) : 0
	
Function max($key : Text) : Real
	//  return the max of $key if it is a numeric value in this.data
	return (This:C1470._keyExists($key)) ? This:C1470.data.max($key) : 0
	
Function average($key : Text)->$value : Real
	//  return the average of $key if it is a numeric value in this.data
	return (This:C1470._keyExists($key)) ? This:C1470.data.average($key) : 0
	
Function extract($key : Text)->$collection : Collection
	//  return the extracted values of a specific 'column' as a collection
	return (This:C1470._keyExists($key)) ? This:C1470.data.extract($key) : New collection:C1472
	
Function distinct($key : Text)->$collection : Collection
	//  return the distinct values of a specific 'column' as a collection
	return (This:C1470._keyExists($key)) ? This:C1470.data.distinct($key) : New collection:C1472
	
Function lastIndexOf($key : Text; $findValue : Variant) : Integer
	return (This:C1470._keyExists($key)) ? This:C1470.extract($key).lastIndexOf($findValue) : -1
	
	//MARK:-  ---- utilities
Function _clearDatasources
	//  clear the objects that are set by the listbox object
	This:C1470.currentItem:=Null:C1517
	This:C1470.position:=0
	This:C1470.selectedItems:=Null:C1517
	
Function _result($result : Boolean; $error : Variant) : Object
	Case of 
		: (Count parameters:C259=0) || (Bool:C1537($result))
			This:C1470._lastError:=""
			return New object:C1471("success"; True:C214)
			
		: (Count parameters:C259=2)  // $result=false and an error text
			This:C1470._lastError:=String:C10($error)
			return New object:C1471("success"; False:C215; "error"; String:C10($error))
			
		Else   // $result=false and no error text
			This:C1470._lastError:="Unspecified error."
			return New object:C1471("success"; False:C215; "error"; "Unspecified error.")
	End case 
	
Function _keyExists($key : Text) : Boolean
	
	return (This:C1470.isReady) && (This:C1470.data[0][$key]#Null:C1517)
	
Function _keyIsNumber($key : Text) : Boolean
	return This:C1470._keyExists($key) && (Value type:C1509(This:C1470.data[0][$key])=Is real:K8:4) || (Value type:C1509(This:C1470.data[0][$key])=Is longint:K8:6)
	