/*

 _      _
| |__  | |__   _ __ ___    ___  _ __
| '_ \ | '_ \ | '_ ` _ \  / __|| '_ \
| | | || |_) || | | | | || (__ | |_) |
|_| |_||_.__/ |_| |_| |_| \___|| .__/
                               |_|

vscode MCP support

Ref.: FiveTech Software tech support forums
Post by Antonio Linares => Sun Apr 20, 2025 1:54 pm
https://forums.fivetechsupport.com/viewtopic.php?p=279038&fbclid=IwY2xjawJuYexleHRuA2FlbQIxMAABHs9xck4cJElRsb8JNH8mCYB4npX7bymu-7yVGDbWrVNyno4M7j9A3CxP-_zL_aem_IfLRzD3kMCei7UE5CHYsYA#p279038

Ref.: //https://code.visualstudio.com/docs/copilot/chat/mcp-servers

Released to Public Domain.
--------------------------------------------------------------------------------------

*/

#include "fileio.ch"

#define __LOGFILE__ (hb_ProgName()+".log")

procedure Main()

    local cInput as character
    local cResponse as character

    ErrorBlock({|oError|LogFile("error: ",hb_JSONEncode(hb_DumpVar(oError,.T.,nil)))})

    while (.T.)

        cInput:=StdIn()
        if (Empty(cInput))
           exit // Exit if no input (EOF)
        endif

        // Process the message
        LogFile("in: ",cInput)
        cResponse:=ProcessMessage(cInput)
        if (!Empty(cResponse))
            LogFile("out: ",cResponse)
            StdOut(cResponse)
        endif

    end while

    LogFile("exit: ","finished")

    return

// Function to process JSON-RPC messages
static function ProcessMessage(cInput as character)

    local aTools as array

    local cMethod as character
    local cResult as character
    local cResponse as character

    local cKey as character
    local cCode as character
    local cToolName as character

    local hTool as hash
    local hJSON as hash
    local hAgent as hash
    local hAgents as hash
    local hResult as hash
    local hResponse as hash

    local nId as numeric

    local oTAgent as object

    local xResult as anytype

    // Decode JSON to obtain the method and ID
    hb_jsonDecode(cInput,@hJSON)
    cMethod:=Lower(allTrim(hJSON["method"]))

    LogFile("method: ",cMethod)

    if (hb_HHasKey(hJSON,"id"))
        nId:=hJSON["id"]
    endif

    // Build the response
    hResponse:={=>}
    hResponse["jsonrpc"]:="2.0"
    hResponse["id"]:=nId

    switch (cMethod)

        case "initialize"

            hResult:={;
                "protocolVersion" => "2025-03-26",;
                "capabilities" => {;
                    "tools" => {=>},;
                    "resources" => {=>},;
                    "prompts" => {=>};
                };
            }

            exit

        case "notifications/initialized"

            hResult:={;
                "protocolVersion" => "2025-03-26",;
                "capabilities" => {;
                    "tools" => {=>},;
                    "resources" => {=>},;
                    "prompts" => {=>};
                };
            }

            exit

        case "tools/list"

            hResult:={=>}
            aTools:={}

            // Adding tool "get_time"
            hTool:={=>}
            hTool["name"]:="get_time"
            hTool["description"]:="Returns the current system time in YYYY-MM-DD HH:MM:SS format"
            hTool["inputSchema"]:={=>}
            hTool["inputSchema"]["type"]:="object"
            hTool["inputSchema"]["properties"]:={=>}
            hTool["inputSchema"]["required"]:={}
            hTool["inputSchema"]["additionalProperties"]:=.F.
            hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
            aAdd(aTools,hTool)

            // Adding tool "hb_version"
            hTool:={=>}
            hTool["name"]:="hb_version"
            hTool["description"]:="Returns the version of the Harbour runtime environment"
            hTool["inputSchema"]:={=>}
            hTool["inputSchema"]["type"]:="object"
            hTool["inputSchema"]["properties"]:={=>}
            hTool["inputSchema"]["required"]:={}
            hTool["inputSchema"]["additionalProperties"]:=.F.
            hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
            aAdd(aTools,hTool)

            // Adding tool "hb_compiler"
            hTool:={=>}
            hTool["name"]:="hb_compiler"
            hTool["description"]:="Returns the name of the compiler used to build the Harbour runtime environment"
            hTool["inputSchema"]:={=>}
            hTool["inputSchema"]["type"]:="object"
            hTool["inputSchema"]["properties"]:={=>}
            hTool["inputSchema"]["required"]:={}
            hTool["inputSchema"]["additionalProperties"]:=.F.
            hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
            aAdd(aTools,hTool)

            // New tool hb_macro
            hTool:={=>}
            hTool["name"]:="hb_macro"
            hTool["description"]:="Executes a Harbour macro expression provided as a string and returns the result as a string. Useful for dynamic code execution within the Harbour runtime environment."
            hTool["inputSchema"]:={=>}
            hTool["inputSchema"]["type"]:="object"
            hTool["inputSchema"]["properties"]:={=>}
            hTool["inputSchema"]["properties"]["code"]:={=>}
            hTool["inputSchema"]["properties"]["code"]["type"]:="string"
            hTool["inputSchema"]["required"]:={"code"}
            hTool["inputSchema"]["additionalProperties"]:=.F.
            hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
            aAdd(aTools,hTool)

            hAgents:=hb_agents():Execute("GetAgents")
            for each hAgent in hAgents
                oTAgent:=hAgent:__enumValue():Eval("GetAgents")
                for each cKey in hb_HKeys(oTAgent:hTools)
                    aAdd(aTools,oTAgent:hTools[cKey]["tool"])
                next each //hTool
            next each //hAgent

            // Build the result
            hResult["tools"]:=aTools

            exit

        case "tools/call"

            cToolName:=hJSON["params"]["name"]

            hResponse:={=>}
            hResponse["jsonrpc"]:="2.0"
            hResponse["id"]:=nId

            if (cToolName=="get_time")

                hResult:={;
                    "content" => {;
                        {;
                            "type" => "text",;
                            "text" => Time();
                        };
                    };
                }

            elseif (cToolName=="hb_version")

                hResult:={;
                    "content" => {;
                        {;
                            "type" => "text",;
                            "text" => hb_version();
                        };
                    };
                }

            elseif (cToolName=="hb_compiler")

                hResult:={;
                    "content" => {;
                        {;
                            "type" => "text",;
                            "text" => hb_compiler();
                        };
                    };
                }

            elseif (cToolName=="hb_macro")

                // New tool: execute macro and return result as string
                // Verify that the "code" parameter exists and is a string
                if (;
                    hb_HHasKey(hJSON["params"],"arguments");
                    .and.;
                    hb_HHasKey(hJSON["params"]["arguments"],"code");
                    .and.;
                    ValType(hJSON["params"]["arguments"]["code"])=="C";
                )

                    cCode:=hJSON["params"]["arguments"]["code"]
                    // Execute the macro and convert the result to string
                    BEGIN SEQUENCE
                        xResult:=&(cCode)
                        cResult:=hb_ValToExp(xResult)
                        hResult:={;
                            "content" => {;
                                {;
                                    "type" => "text",;
                                    "text" => cResult;
                                };
                            };
                        }
                    RECOVER
                        // In case of macro error, return a JSON-RPC error
                        hResult:={;
                            "error" => {;
                                "code" => -32602,;
                                "message" => "Invalid macro expression";
                            };
                        }
                    END SEQUENCE
                else
                    // Error: "code" parameter not provided or invalid
                    hResult:={;
                        "error" => {;
                            "code" => -32604,;
                            "message" => "Missing or invalid code parameter";
                        };
                    }
                endif

            else

                BEGIN SEQUENCE
                    hAgents:=hb_agents():Execute("GetAgents") as hash
                    for each hAgent in hAgents
                        oTAgent:=hAgent:__enumValue():Eval("GetAgents")
                        for each cKey in hb_HKeys(oTAgent:hTools)
                            if (cKey==cToolName)
                                xResult:=Eval(oTAgent:hTools[cToolName]["action"],hJSON["params"]["arguments"])
                                hResult:={;
                                    "content" => {;
                                        {;
                                            "type" => "text",;
                                            "text" => xResult;
                                        };
                                    };
                                }
                                break
                            endif
                        next each //cKey
                    next each //hAgent
                END SEQUENCE

            endif

            exit

        otherwise

            hResult:={;
                "error" => {;
                    "code" => -32604,;
                    "message" => "Method not found: " + cMethod;
                };
            }

    end switch

    hResponse["result"]:=hResult
    cResponse:=hb_JsonEncode(hResponse)+hb_eol()

    return(cResponse) as character

static function LogFile(cKey as character,cValue as character)

    local cLogFile as character:=hb_GetEnv("MCP_LOGFILE",__LOGFILE__)

    local lSuccess as logical:=.F.

    local nfHandle as numeric

    if (!File(cLogFile))
       // Create the file if it does not exist
       nfHandle:=fOpen(cLogFile,FO_WRITE+FO_CREAT)
    else
       // Open the file to append content
       nfHandle:=fOpen(cLogFile,FO_WRITE)
    endif

    if (nfHandle>0)
       fSeek(nfHandle,0,FS_END) // Move the pointer to the end of the file
       lSuccess:=fWrite(nfHandle,cKey+cValue+hb_eol())
       fClose(nfHandle)
    endif

    return(lSuccess)

#pragma BEGINDUMP

    #include <hbapi.h>

    HB_FUNC_STATIC( STDIN)
    {
        char buffer[1024];

        if (fgets(buffer,sizeof(buffer),stdin) != NULL)
        {
            // Remove final line break, if exists
            size_t len=strlen(buffer);
            if (len > 0 && buffer[len - 1]=='\n')
                buffer[len - 1]='\0';
            hb_retc(buffer);
        }
        else
        {
            hb_retc(""); // Return empty string in case of EOF
        }
    }

    HB_FUNC_STATIC( STDOUT)
    {
        if (HB_ISCHAR(1))
        {
            fputs(hb_parc(1),stdout);
            fflush(stdout); // Force immediate write
        }
    }

#pragma ENDDUMP
