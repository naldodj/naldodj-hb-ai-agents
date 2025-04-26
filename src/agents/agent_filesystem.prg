/*
                            _        __  _  _                         _
  __ _   __ _   ___  _ __  | |_     / _|(_)| |  ___  ___  _   _  ___ | |_   ___  _ __ ___
 / _` | / _` | / _ \| '_ \ | __|   | |_ | || | / _ \/ __|| | | |/ __|| __| / _ \| '_ ` _ \
| (_| || (_| ||  __/| | | || |_    |  _|| || ||  __/\__ \| |_| |\__ \| |_ |  __/| | | | | |
 \__,_| \__, | \___||_| |_| \__|   |_|  |_||_| \___||___/ \__,||___/ \__| \___||_| |_| |_|
        |___/                                             |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE Agent_FileSystem METHOD "GetAgents" POINTER @GetAgents(),;
                                     "CreateFile" POINTER @CreateFile(),;
                                     "ModifyFile" POINTER @ModifyFile(),;
                                     "DeleteFile" POINTER @DeleteFile(),;
                                     "CreateFolder" POINTER @CreateFolder()

static function GetAgents()

    local oTAgent as object

    local cAgentPrompt as character
    local cAgentPurpose as character

    local hTool as hash

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on '__PROMPT__' and the category '__AGENT_CATEGORY__', select the appropriate tool from:
```json
__JSON_HTOOLS__
```
### Rules:
- Each tool requires specific parameters (e.g., `create_folder` → `folder_name`, `modify_file` → `file_name`, `content`).
- Extract values from the prompt and match them exactly to the expected parameter names.
- **Do not alter file paths. Use them exactly as provided in the prompt.**
- Do **not** use a generic "params" object with arbitrary keys.
- Only include the parameters defined by the tool (or return an empty object if none are required).
### Output:
Return only a JSON object:
```json
{"tool":"<tool_name>","params":{"param1":"value1", ...}}
```
### Examples:
- "Create a folder named 'folderName'" →
  ```json
  {"tool":"create_folder","params":{"folder_name":"folderName"}}
  ```
- "Modify 'fileName' with content 'text'" →
  ```json
  {"tool":"modify_file","params":{"file_name":"fileName","content":"text"}}
  ```
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_filesystem" provides tools for performing basic file system operations, enabling users to manage files and directories programmatically. It is designed to automate tasks such as creating, modifying, and deleting files, as well as creating folders, through a set of specialized functions.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_FileSystem",cAgentPrompt,cAgentPurpose)

    hTool:={=>}
    hTool["name"] := "create_file"
    hTool["description"] := "Create a new file in the current directory or in a specified directory"
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"]["type"] := "string"
    hTool["inputSchema"]["properties"]["file_name"]["description"] := "The name of the file or full path to create"
    hTool["inputSchema"]["required"]:={"file_name"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("create_file",{|hParams|Agent_FileSystem():Execute("CreateFile",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "delete_file"
    hTool["description"] := "Delete a file in the current directory or in a specified directory"
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"]["type"] := "string"
    hTool["inputSchema"]["properties"]["file_name"]["description"] := "The name of the file or full path to delete"
    hTool["inputSchema"]["required"]:={"file_name"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("delete_file",{|hParams|Agent_FileSystem():Execute("DeleteFile",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "modify_file"
    hTool["description"] := "Modify a file in the current directory or in a specified directory"
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"] := {=>}
    hTool["inputSchema"]["properties"]["file_name"]["type"] := "string"
    hTool["inputSchema"]["properties"]["file_name"]["description"] := "The name of the file or full path to modify"
    hTool["inputSchema"]["properties"]["content"] := {=>}
    hTool["inputSchema"]["properties"]["content"]["type"] := "string"
    hTool["inputSchema"]["properties"]["content"]["description"] := "The content to write to the file"
    hTool["inputSchema"]["required"]:={"file_name","content"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("modify_file",{|hParams|Agent_FileSystem():Execute("ModifyFile",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "create_folder"
    hTool["description"] := "Create a folder in the current directory or in a specified subdirectory"
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["folder_name"] := {=>}
    hTool["inputSchema"]["properties"]["folder_name"]["type"] := "string"
    hTool["inputSchema"]["properties"]["folder_name"]["description"] := "The name or path of the folder to create"
    hTool["inputSchema"]["required"]:={"folder_name"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("create_folder",{|hParams|Agent_FileSystem():Execute("CreateFolder",hParams)},hTool)

    return(oTAgent) as object

static function CreateFolder(hParams as hash)
    local cPS as character
    local cDir as character
    local cExt as character
    local cDrive as character
    local cFolder as character
    local cMessage as character
    local cFileName as character
    if (hb_HHasKey(hParams,"folder_name").and.!Empty(hParams["folder_name"]))
        cFolder:=hParams["folder_name"]
        hb_FNameSplit(cFolder,@cDir,@cFileName,@cExt,@cDrive)
        if (Empty(cDir).and.Empty(cExt).and.Empty(cDrive))
            cPS:=hb_ps()
            if (Left(cFolder,2)!=(Left("."+cPS+cFolder,2)))
                cFolder:=("."+cPS+cFolder)
                cFolder:=hb_StrReplace(cFolder,{cPS+cPS=>cPS})
            endif
        endif
        if (hb_DirExists(cDrive+cFolder))
            cMessage:="Folder '"+cDrive+cFolder+"' already exists"
        elseif (hb_DirBuild(cDrive+cFolder).or.(hb_DirCreate(cDrive+cFolder)==0))
            cMessage:="Folder '"+cDrive+cFolder+"' created successfully"
        else
            cMessage:="Failed to create folder: no name specified"
        endif
    else
        cMessage:="Failed to create folder: no name specified"
    endif
    return(cMessage) as character

static function CreateFile(hParams as hash)
    local cPS as character
    local cDir as character
    local cExt as character
    local cFile as character
    local cDrive as character
    local cMessage as character
    local cFileName as character
    if ((hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"])))
        cFile:=hParams["file_name"]
        hb_FNameSplit(cFile,@cDir,@cFileName,@cExt,@cDrive)
        if (Empty(cDrive))
            cPS:=hb_ps()
            if (Left(cFile,2)!=(Left("."+cPS+cFile,2)))
                cFile:=("."+cPS+cFile)
                cFile:=hb_StrReplace(cFile,{cPS+cPS=>cPS})
            endif
        endif
        if (!hb_DirExists(cDrive+cDir))
            hb_DirBuild(cDrive+cDir)
        endif
        if (hb_MemoWrit(cFile,""))
            cMessage:="File '"+cFile+"' created successfully"
        else
            cMessage:="Failed to create file: no name specified"
        endif
    else
        cMessage:="Failed to create file: no name specified"
    endif
    return(cMessage) as character

static function ModifyFile(hParams as hash)
    local cPS as character
    local cDir as character
    local cExt as character
    local cFile as character
    local cDrive as character
    local cMessage as character
    local cContent as character
    local cFileName as character
    if (;
        (hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"]));
        .and.;
        (hb_HHasKey(hParams,"content").and.!Empty(hParams["content"]));
      )
        cFile:=hParams["file_name"]
        hb_FNameSplit(cFile,@cDir,@cFileName,@cExt,@cDrive)
        if (Empty(cDrive))
            cPS:=hb_ps()
            if (Left(cFile,2)!=(Left("."+cPS+cFile,2)))
                cFile:=("."+cPS+cFile)
                cFile:=hb_StrReplace(cFile,{cPS+cPS=>cPS})
            endif
        endif
        cContent:=hParams["content"]
        if (!hb_DirExists(cDrive+cDir))
            hb_DirBuild(cDrive+cDir)
        endif
        if (hb_MemoWrit(cFile,cContent))
            cMessage:="File '"+cFile+"' modified with content: "+cContent
        else
            cMessage:="Failed to modify file: missing file name or content"
        endif
    else
        cMessage:="Failed to modify file: missing file name or content"
    endif
    return(cMessage) as character

static function DeleteFile(hParams as hash)
    local cPS as character
    local cDir as character
    local cExt as character
    local cFile as character
    local cDrive as character
    local cMessage as character
    local cFileName as character
    if ((hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"])))
        cFile:=hParams["file_name"]
        hb_FNameSplit(cFile,@cDir,@cFileName,@cExt,@cDrive)
        if (Empty(cDrive))
            cPS:=hb_ps()
            if (Left(cFile,2)!=(Left("."+cPS+cFile,2)))
                cFile:=("."+cPS+cFile)
                cFile:=hb_StrReplace(cFile,{cPS+cPS=>cPS})
            endif
        endif
        if (!hb_DirExists(cDrive+cDir))
            hb_DirBuild(cDrive+cDir)
        endif
        if (hb_FileExists(cFile))
            if (fErase(cFile)==0)
                cMessage:="File '"+cFile+"' deleted successfully"
            else
                cMessage:="Failed to delete file '"+cFile+"'"
            endif
        else
            cMessage:="File '"+cFile+"' does not exist"
        endif
    else
        cMessage:="Failed to delete file: no name specified"
    endif
    return(cMessage) as character
