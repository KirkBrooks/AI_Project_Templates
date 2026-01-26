/*  HostProject class
 Created by: Kirk Brooks as Designer, Created: 04/06/25, 12:14:02
 ------------------
Designed for when you need to manipulate files in 
a different 4D Project

https://developer.4d.com/docs/20/Project/architecture

MyPackage (project root folder)    Folder(fk database folder)  aka /PACKAGE/
 |- Components
 |- Data                           Folder(fk data folder)
 |--|- Logs                        Folder(fk logs folder)
 |--|- Settings
 |- Documentation
 |- Plugins
 |- Project    *
 |--*.4DProject                     Structure File
 |--|- DerivedData
 |--|- Sources
 |--|--|- .4DCatalog
 |--|--|- Methods
 |--|--|- Classes
 |--|--|- Forms
 |--|--|- ...
 |--|- Trash
 |- Resources
 |- Settings
 |- userPreferences.jSmith
 |- WebFolder

home                                Folder(fk home folder)              /Users/<username>
editor_theme                        Folder(fk editor theme folder)      /Users/<userName>/Library/Application Support/4D/4D Editor Themes/
4D_user_prefs                       Folder(fk user preferences folder)  /Users/kirkbrooks/Library/Application Support/4D/
sys_user_prefs                      System folder(User preferences_user)/Users/kirkbrooks/Library/Application Support/

$root must be the Database folder of the other project

The Project folder is the Parent folder of the .4DProject file.
 It should be in a folder named Project but may not be


*/
property root : 4D.Folder  //  this is the root folder for the Database
property _projectFile : 4D.File  //  project file for the Project
property _projectFolder : 4D.Folder  // this is the root folder for all project paths
property _docFolder : 4D.Folder  //  documentation root


Class constructor($src)
	
	Case of 
		: (Value type($src)#Is object)  //  use the current database
			This._projectFile:=File(File(Structure file(*); fk platform path).platformPath; fk platform path)
			This._projectFolder:=This._projectFile.parent
			This.root:=This._projectFolder.parent
			return 
			
		: (OB Instance of($src; 4D.File))  // project file
			This._projectFile:=File(File($src; fk platform path).platformPath; fk platform path)
			This._projectFolder:=This._projectFile.parent
			This.root:=This._projectFolder.parent
			return 
			
		: (OB Instance of($src; 4D.Folder))
			This.root:=Folder($src.platformPath; fk platform path)
			
			// find the .4DProject file
			var $file : 4D.File
			$file:=This.root.files(fk recursive).query("extension = :1"; ".4DProject").first()
			
			If ($file#Null)
				This._projectFile:=$file
				This._projectFolder:=This._projectFile.parent
				return 
			End if 
	End case 
	
	ALERT("Can't initialize HostProject class.")
	
	
	//mark:  --- getters
Function get Project : 4D.Folder
	return This._projectFolder
	
Function get Sources : 4D.Folder
	return This.Project.folder("Sources")
	
Function get Classes : 4D.Folder
	return This.Sources.folder("Classes")
	
Function get Methods : 4D.Folder
	return This.Sources.folder("Methods")
	
Function get Documentation : 4D.Folder
	return This.root.folder("Documentation")
	
Function get Components : 4D.Folder
	return This.root.folder("Components")
	
Function get Resources : 4D.Folder
	return This.root.folder("Resources")
	
Function get Settings : 4D.Folder
	return This.root.folder("Settings")
	
Function get Plugins : 4D.Folder
	return This.root.folder("Plugins")
	
Function get Macros : 4D.Folder
	return This.root.folder("Macros v2")
	
Function get Forms : 4D.Folder
	return This.Sources.folder("Forms")
	
Function get catalog : 4D.File
	return This.Sources.file("catalog.4DCatalog")
	
Function get folders : 4D.File
	return This.Sources.file("folders.json")
	
	//mark:  --- Host Information
Function get hostName : Text
	If (This._projectFile=Null)
		return ""
	Else 
		return This._projectFile.name
	End if 
	
	//mark:  --- functions
Function getForm($name : Text; $documentation : Boolean) : Object
	If ($documentation)
		return This._docFolder.folder("Forms").file($name+".md")
	Else 
		return This.Forms.folder($name)
	End if 
	
Function getClass($name : Text; $documentation : Boolean) : 4D.File
	If ($documentation)
		return This._docFolder.folder("Classes").file($name+".md")
	Else 
		return This.Classes.file($name+".4dm")
	End if 
	
Function getMethod($name : Text; $documentation : Boolean) : 4D.File
	If ($documentation)
		return This._docFolder.folder("Methods").file($name+".md")
	Else 
		return This.Methods.file($name+".4dm")
	End if 
	
	
	
	
Function getLocalFileFromPath($path : Text) : 4D.File
	If ($path="")
		return Null
	End if 
	
	return This.root.file($path)
	
Function getLocalFolderFromPath($path : Text) : 4D.Folder
	If ($path="")
		return This.root
	End if 
	return This.root.folder($path)
	
	//mark:  --- github paths
Function getClassPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Classes/"+$name+".md"
	Else 
		return "Project/Sources/Classes/"+$name+".4dm"
	End if 
	
Function getMethodPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Methods/"+$name+".md"
	Else 
		return "Project/Sources/Methods/"+$name+".4dm"
	End if 
	
Function getFormPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Forms/"+$name+".md"
	Else 
		return "Project/Sources/Forms/"+$name+"/"
	End if 
	