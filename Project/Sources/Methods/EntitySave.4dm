//%attributes = {}
// EntitySave
//
// this method allows you to save an entity using automerge by default if the simple save fails.
// you can also force save your changes which may overwrite other recent changes.
// $1 $eEntity         any entity to save
// $2 $b_useForceSave  {optional} default = NO force save
//          will write your mods on top of other changes
// $3 $b_noAutoMerge   {optional} default = use autoMerge
//          auto merge if other mods have been made that do not conflict with your mods
// $0 $oStatus         success = true if save succeeds or will contain information about why it failed
// This method DOES NOT use server updates. 

#DECLARE($entity : 4D.Entity; $useForceSave : Boolean; $noAutoMerge : Boolean)->$status : Object
var $touchedAttributes : Collection
var $i : Integer

If ($entity=Null)
	return New object("success"; False; "error"; "No entity passed to save. ")
End if 

// trap 4D errors:  'serious errors' throw a 4D error 
//  - saving with a duplicate PrimaryID
//  - if a save action is rejected by a trigger
//  information about the error will be in $status

ON ERR CALL("Err_ignore")
$status:=$entity.save()
ON ERR CALL("")

// did we fail?  locking is most likely cause
While (Not($status.success)) && (Num($status.status)=dk status locked)
	DELAY PROCESS(Current process; 5)
	$status:=$entity.save()
	$i+=1
	
	If (Not($status.success)) && ($i>=10)
		return $status
	End if 
End while 

If ($status.success)
	$entity.reload()  //  make sure we are updated with any fields updated by triggers
	return $status
End if 

If ($status.status=dk status locked)
	//  4D wrote the locked information to $status
	return $status
End if 

If ($status.status=dk status serious error) || ($status.status=dk status entity does not exist anymore)
	//  4D wrote the error information to $status
	return $status
End if 

If ($status.status=dk status stamp has changed)
/*  record was changed elsewhere
 auto merge will succeed if we are not changing any fields changed elsewhere
 this will frequently fail if the trigger is making changes also
Note: changes made to an object field do not count as 'modified'
*/
	
	$status:=$entity.save(dk auto merge)
	
	// if this fails and the user wants to do a force save...
	$useForceSave:=$useForceSave && Not($status.success)
End if 

If (Not($useForceSave))
	return $status
End if 

//mark:-  forcesave
// our changes may overwrite some changes already made.
var $currentEntity : 4D.Entity
var $fieldName : Text

$currentEntity:=$entity.getDataClass().get($entity.getKey())  // get the entity on the server

$touchedAttributes:=$entity.touchedAttributes()  //  get our changes 

// now write our changes from $entity
For each ($fieldName; $touchedAttributes)
	$currentEntity[$fieldName]:=$entity[$fieldName]
End for each 

$status:=$currentEntity.save()  // note that now we are saving a DIFFERENT entity than the one passed in

If ($status.success)
	// at this point $currentEntity is the 'true' or 'current' version
	// reload() to update our entity with current data - like fields updated by the trigger
	$status:=$entity.reload()
End if 

$status.forceSave:=True
