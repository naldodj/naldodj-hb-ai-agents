/*
                            _        __  _  _                         _
  __ _   __ _   ___  _ __  | |_     / _|(_)| |  ___  ___  _   _  ___ | |_   ___  _ __ ___
 / _` | / _` | / _ \| '_ \ | __|   | |_ | || | / _ \/ __|| | | |/ __|| __| / _ \| '_ ` _ \
| (_| || (_| ||  __/| | | || |_    |  _|| || ||  __/\__ \| |_| |\__ \| |_ |  __/| | | | | |
 \__,_| \__, | \___||_| |_| \__|   |_|  |_||_| \___||___/ \__, ||___/ \__| \___||_| |_| |_|
        |___/                                             |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE Agent_FileSystem METHOD "GetAgents" POINTER @GetAgents(),;
                                     "CreateFolder" POINTER @CreateFolder(),;
                                     "CreateFile" POINTER @CreateFile(),;
                                     "ModifyFile" POINTER @ModifyFile(),;
                                     "DeleteFile" POINTER @DeleteFile()

static function GetAgents()

    local oAgent as object
    //local oAgent_FileSystem as object:=Agent_FileSystem():New()

    oAgent:=TAgent():New(;
        "agent_filesystem";
        ,{;
             {"create_folder",{|hParams| Agent_FileSystem():Execute("CreateFolder",hParams)}};
            ,{"create_file",{|hParams| Agent_FileSystem():Execute("CreateFile",hParams)}};
            ,{"modify_file",{|hParams| Agent_FileSystem():Execute("ModifyFile",hParams)}};
            ,{"delete_file",{|hParams| Agent_FileSystem():Execute("DeleteFile",hParams)}};
        };
    )

    return(oAgent)

static function CreateFolder(hParams as hash)
    local cFolder as character
    if (hb_HHasKey( hParams, "folder" ) .and. ! Empty( hParams[ "folder" ] )) .or. (hb_HHasKey( hParams, "folder_name" ) .and. ! Empty( hParams[ "folder_name" ] ))
        cFolder:=if(hb_HHasKey( hParams, "folder_name" ), hParams[ "folder_name" ], hParams[ "folder" ])
        if hb_DirExists(cFolder)
            return "Folder '" + cFolder + "' already exists"
        elseif hb_DirCreate( cFolder ) == 0
            return "Folder '" + cFolder + "' created successfully"
        else
            return "Failed to create folder: no name specified"
        endif
    endif
    return "Failed to create folder: no name specified"

static function CreateFile(hParams as hash)
    local cFile as character
    if (hb_HHasKey( hParams, "file" ) .and. ! Empty( hParams[ "file" ] )) .or. (hb_HHasKey( hParams, "filename" ) .and. ! Empty( hParams[ "filename" ] ))
        cFile:=if(hb_HHasKey( hParams, "filename" ), hParams[ "filename" ], hParams[ "file" ])
        if hb_MemoWrit( cFile, "" )
            return "File '" + cFile + "' created successfully"
        else
            return "Failed to create file: no name specified"
        endif
    endif
    return "Failed to create file: no name specified"

static function ModifyFile(hParams as hash)
    local cFile as character
    local cContent as character
    if (hb_HHasKey( hParams, "file" ) .and. ! Empty( hParams[ "file" ] )) .or. (hb_HHasKey( hParams, "filename" ) .and. ! Empty( hParams[ "filename" ] )) .and. hb_HHasKey( hParams, "content" ) .and. ! Empty( hParams[ "content" ] )
        cFile:=if(hb_HHasKey( hParams, "filename" ), hParams[ "filename" ], hParams[ "file" ])
        cContent:=hParams[ "content" ]
        if hb_MemoWrit( cFile, cContent )
            return "File '" + cFile + "' modified with content: " + cContent
        else
            return "Failed to modify file: missing file name or content"
        endif
    endif
    return "Failed to modify file: missing file name or content"

static function DeleteFile(hParams as hash)
    local cFile as character
    if (hb_HHasKey( hParams, "file" ) .and. ! Empty( hParams[ "file" ] )) .or. (hb_HHasKey( hParams, "filename" ) .and. ! Empty( hParams[ "filename" ] ))
        cFile:=if(hb_HHasKey( hParams, "filename" ), hParams[ "filename" ], hParams[ "file" ])
        if hb_FileExists( cFile )
            if (fErase( cFile )==0)
                return "File '" + cFile + "' deleted successfully"
            else
                return "Failed to delete file '" + cFile + "'"
            endif
        else
            return "File '" + cFile + "' does not exist"
        endif
    endif
    return "Failed to delete file: no name specified"
