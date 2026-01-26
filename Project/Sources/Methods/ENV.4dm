//%attributes = {"folder":"ENV","lang":"en"}
/* Purpose: singleton of ENV_global
 ------------------
ENV ()
 Created by: Kirk Brooks as Designer, Created: 04/06/25, 09:27:49
$file is optional - if passed in is the default (first) source for .env variables

FILE LOCATIONS
Since this is being run within the context of a 4D database we will
base file locations on this Project. 
 - [override] specific file passed to constructor
 - [prefs]    user settings in project directory          this._getUserPrefsFolder() - useful if your local settings differ from Prod
 - [project]  project directory                           fk database folder ;* Host Database
 - [data]     datafile directory                          varies
 - [4D]       Users/name/Library/Application Support/4D   fk user preferences folder
 - [user]     Users/name                                  fk home

Get Functions:  returns the first instance of the key you pass in

Set Functions:  Starts at the top and will add the key if it does not already exist.
    Pass in a specific file if you want to update that file. Otherwise new values
    are written in your user prefs 

*/
#DECLARE($overrideFile : 4D.File) : cs.ENV_global
return cs.ENV_global.new($overrideFile)
