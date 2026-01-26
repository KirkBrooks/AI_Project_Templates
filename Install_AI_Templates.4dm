/* Purpose: Install AI Project Template files into the current project
	 ------------------
	Install_AI_Templates ()
	 Created by: Claude Code, Created: 01/25/26

	 Prompts user to select the AI_Project_Templates folder, then copies all
	 files into the corresponding directories of the current project.

	 Walks the template folder tree and recreates the directory structure under
	 the database root. All files are copied. Form folders (under
	 Project/Sources/Forms/) are copied as complete units since 4D stores
	 each form as a folder.

	 Hidden files and folders (names starting with ".") are skipped.

	 Usage: Copy this method into any 4D project and run it once.
*/

var $templatePath : Text:=Select folder("Select the AI_Project_Templates folder:")

If ($templatePath="")
	return   // user cancelled
End if

var $templateFolder : 4D.Folder:=Folder($templatePath; fk platform path)

//  verify the selected folder looks correct
If (Not($templateFolder.file("CLAUDE.md").exists))
	ALERT("The selected folder does not contain a CLAUDE.md file at root.\nPlease select the AI_Project_Templates folder.")
	return
End if

//  target: database root folder
//  Filesystem path refs (/PROJECT/) are top-level in 4D's virtual filesystem.
//  .parent returns Null on them. Convert to platform path first.
var $dbRoot : 4D.Folder:=Folder(Folder("/PROJECT/").platformPath; fk platform path).parent

//  walk the template tree using a breadth-first queue
//  each item: {src: source 4D.Folder, dest: destination 4D.Folder}
var $queue : Collection:=[{src: $templateFolder; dest: $dbRoot}]
var $filesCopied : Integer:=0
var $formFoldersCopied : Integer:=0
var $errors : Collection:=[]

var $item : Object
var $srcDir : 4D.Folder
var $destDir : 4D.Folder
var $files : Collection
var $subDirs : Collection
var $f : 4D.File
var $sub : 4D.Folder
var $isFormsDir : Boolean

While ($queue.length>0)
	$item:=$queue[0]
	$queue.remove(0)

	$srcDir:=$item.src
	$destDir:=$item.dest

	//  ensure destination folder exists
	If (Not($destDir.exists))
		$destDir.create()
	End if

	//  copy all files at this level
	$files:=$srcDir.files()
	For each ($f; $files)
		//  skip hidden/OS metadata files
		If ($f.fullName[[1]]#".")
			Try
				$f.copyTo($destDir; $f.fullName; fk overwrite)
				$filesCopied+=1
			Catch
				$errors.push("File: "+$f.fullName)
			End try
		End if
	End for each

	//  process subdirectories
	//  detect if we are inside Project/Sources/Forms
	$isFormsDir:=($srcDir.name="Forms") & ($srcDir.parent.name="Sources")

	$subDirs:=$srcDir.folders()
	For each ($sub; $subDirs)
		//  skip hidden folders
		If ($sub.fullName[[1]]#".")
			If ($isFormsDir)
				//  Forms: copy form subfolders as complete units
				If (Not($destDir.exists))
					$destDir.create()
				End if
				Try
					$sub.copyTo($destDir; $sub.name; fk overwrite)
					$formFoldersCopied+=1
				Catch
					$errors.push("Form folder: "+$sub.name)
				End try
			Else
				//  normal directory: queue for file-by-file processing
				$queue.push({src: $sub; dest: $destDir.folder($sub.name)})
			End if
		End if
	End for each
End while

//  report results
var $msg : Text:=String($filesCopied)+" file(s) installed."

If ($formFoldersCopied>0)
	$msg+="\n"+String($formFoldersCopied)+" form folder(s) copied."
End if

If ($errors.length>0)
	$msg+="\n\nFailed:\n"
	var $err : Text
	For each ($err; $errors)
		$msg+="  - "+$err+"\n"
	End for each
Else
	$msg+="\n\nAll templates installed successfully."
End if

ALERT($msg)
