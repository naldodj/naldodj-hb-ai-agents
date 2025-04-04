/*
                            _        __  _  _                         _
  __ _   __ _   ___  _ __  | |_     / _|(_)| |  ___  ___  _   _  ___ | |_   ___  _ __ ___
 / _` | / _` | / _ \| '_ \ | __|   | |_ | || | / _ \/ __|| | | |/ __|| __| / _ \| '_ ` _ \
| (_| || (_| ||  __/| | | || |_    |  _|| || ||  __/\__ \| |_| |\__ \| |_ |  __/| | | | | |
 \__,_| \__, | \___||_| |_| \__|   |_|  |_||_| \___||___/ \__,||___/ \__| \___||_| |_| |_|
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

    local hParameters as hash

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, select the correct tool from:
```json
__JSON_HTOOLS__
```
### Rules:
- Each tool has specific required parameters (e.g., `create_folder` → `folder_name`, `modify_file` → `file_name`, `content`).
- Extract values from the prompt and match them exactly to the expected parameter names.
- Do **not** use a generic `"params"` object with arbitrary keys.
- Only include the parameters defined by the tool (or return an empty object if none are needed).
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

    hParameters:={"params"=>["file_name"]}
    oTAgent:aAddTool("create_file",{|hParams|Agent_FileSystem():Execute("CreateFile",hParams)},hParameters)
    oTAgent:aAddTool("delete_file",{|hParams|Agent_FileSystem():Execute("DeleteFile",hParams)},hParameters)

    hParameters:={"params"=>["file_name","content"]}
    oTAgent:aAddTool("modify_file",{|hParams|Agent_FileSystem():Execute("ModifyFile",hParams)},hParameters)

    hParameters:={"params"=>["folder_name"]}
    oTAgent:aAddTool("create_folder",{|hParams|Agent_FileSystem():Execute("CreateFolder",hParams)},hParameters)

    return(oTAgent) as object

static function CreateFolder(hParams as hash)
    local cFolder as character
    local cMessage as character
    if (hb_HHasKey(hParams,"folder_name").and.!Empty(hParams["folder_name"]))
        cFolder:=hParams["folder_name"]
        if (hb_DirExists(cFolder))
            cMessage:="Folder '"+cFolder+"' already exists"
        elseif (hb_DirCreate(cFolder)==0)
            cMessage:="Folder '"+cFolder+"' created successfully"
        else
            cMessage:="Failed to create folder: no name specified"
        endif
    else
        cMessage:="Failed to create folder: no name specified"
    endif
    return(cMessage) as character

static function CreateFile(hParams as hash)
    local cFile as character
    local cMessage as character
    if ((hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"])))
        cFile:=hParams["file_name"]
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
    local cFile as character
    local cContent as character
    local cMessage as character
    if (;
        (hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"]));
        .and.;
        (hb_HHasKey(hParams,"content").and.!Empty(hParams["content"]));
      )
        cFile:=hParams["file_name"]
        cContent:=hParams["content"]
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
    local cFile as character
    local cMessage as character
    if ((hb_HHasKey(hParams,"file_name").and.!Empty(hParams["file_name"])))
        cFile:=hParams["file_name"]
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
