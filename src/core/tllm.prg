/*
 _    _  _
| |_ | || | _ __ ___
| __|| || || '_ ` _ \
| |_ | || || | | | | |
 \__||_||_||_| |_| |_|

Class TLLM with Agents!

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------

*/
#include "hbcurl.ch"
#include "hbclass.ch"

CLASS TLLM

    DATA cUrl as character
    DATA cModel as character
    DATA cPrompt as character
    DATA cResponse as character
    DATA cCategory as character

    DATA hAgents INIT {=>} as hash
    DATA hResponse INIT {=>} as hash

    DATA nError INIT 0 as numeric
    DATA nHttpCode INIT 0 as numeric

    DATA oHTTPConnector as object

    METHOD New(cModel as character,cURL as character,oHTTPConnector as object) as object
    METHOD AddAgent(oTAgent as object) as object
    METHOD End()
    METHOD Reset()
    METHOD ResetAll()

    METHOD GetResponseValue() as character
    METHOD GetToolName(cPrompt as character,oTAgent as object) as character
    METHOD GetPromptCategory(cPrompt as character) as character

    METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) as character

ENDCLASS

METHOD New(cModel as character,cURL as character,oHTTPConnector as object) CLASS TLLM
    self:cModel:=cModel
    self:cUrl:=cURL
    if (valType(oHTTPConnector)!="O")
        self:oHTTPConnector:=TCURLHTTPConnector():New(self:cUrl)
        self:cUrl:=self:oHTTPConnector:oURL:cAddress
    else
        self:oHTTPConnector:=oHTTPConnector
    endif
    self:cCategory:="general"
    curl_global_init()
    self:hAgents:={=>}
    self:hResponse:={=>}
    return(self) as object

METHOD AddAgent(oTAgent as object) CLASS TLLM
    local cCategory as character:=Lower(allTrim(oTAgent:cCategory))
    local nCategory as numeric
    nCategory:=hb_HPos(self:hAgents,cCategory)
    if (nCategory==0)
        self:hAgents[cCategory]:=oTAgent
    endif
    return(self) as object

METHOD PROCEDURE End() CLASS TLLM
    self:oHTTPConnector:Close()
    return

METHOD PROCEDURE Reset() CLASS TLLM
    self:oHTTPConnector:Reset()
    return

METHOD PROCEDURE ResetAll() CLASS TLLM
    self:oHTTPConnector:ResetAll()
    return

METHOD GetResponseValue() CLASS TLLM

    local cValue as character

    hb_JSONDecode(self:cResponse,@self:hResponse)

    //TODO: rever estre block BEGIN SEQUENCE WITH __BreakBlock()
    BEGIN SEQUENCE WITH __BreakBlock()
        cValue:=self:hResponse["choices"][1]["message"]["content"]
    RECOVER
        BEGIN SEQUENCE WITH __BreakBlock()
            cValue:=self:hResponse["message"]["content"]
        RECOVER
            BEGIN SEQUENCE WITH __BreakBlock()
                cValue:=self:hResponse["error"]["message"]
            RECOVER
                cValue:=self:cResponse
            END SEQUENCE
        END SEQUENCE
    END SEQUENCE

    return(cValue) as character

METHOD GetToolName(cPrompt as character,oTAgent as object) CLASS TLLM

    local cKey as character
    local cJSON as character
    local cResponse as character
    local cAgentPrompt as character

    local hTools as hash:={=>}
    local hRequest as hash:={=>}
    local hMessage as hash:={=>}
    local hResponse as hash
    local hToolInfo as hash

    local lTCURLHTTPConnector as logical:=(self:oHTTPConnector:ClassName()=="TCURLHTTPCONNECTOR")

    if (!Empty(oTAgent:hTools))
        for each cKey in hb_HKeys(oTAgent:hTools)
            hTools[cKey]:={"parameters"=>oTAgent:hTools[cKey]["parameters"]}
        next each
    endif

    self:oHTTPConnector:SetHeader("Content-Type","application/json")
    if (lTCURLHTTPConnector)
        self:oHTTPConnector:SetOption(HB_CURLOPT_USERNAME,'')
        self:oHTTPConnector:SetOption(HB_CURLOPT_DL_BUFF_SETUP)
        self:oHTTPConnector:SetOption(HB_CURLOPT_SSL_VERIFYPEER,.F.)
    endif

    hRequest["model"]:=self:cModel
    hMessage["role"]:="user"

    cAgentPrompt:=oTAgent:cAgentPrompt

    cAgentPrompt:=hb_StrReplace(;
        cAgentPrompt;
        ,{;
            "__PROMPT__"=>cPrompt;
            ,"__AGENT_CATEGORY__"=>oTAgent:cCategory;
            ,"__JSON_HTOOLS__"=>hb_JSONEncode(hTools);
        };
    )

    hMessage["content"]:=cAgentPrompt
    hRequest["messages"]:={hMessage}
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.5

    cJSON:=hb_jsonEncode(hRequest)

    hResponse:=self:oHTTPConnector:SendRequest("POST",cJSON)

    if (hb_HHasKey(hResponse,"has_error").and.(!hResponse["has_error"]))
        self:cResponse:=hResponse["body"]
        cResponse:=self:GetResponseValue()
        //TODO: rever estre block BEGIN SEQUENCE WITH __BreakBlock()
        BEGIN SEQUENCE WITH __BreakBlock()
            cResponse:=hb_StrReplace(cResponse,{"```json"=>"","```"=>""})
            hb_jsonDecode(cResponse,@hToolInfo)
            #ifdef DEBUG
                DispOut("DEBUG: hToolInfo after processing:","g+/n")
                ? hb_jsonEncode(hToolInfo),hb_eol()
                DispOut("DEBUG: Type of hToolInfo:","g+/n")
                ? ValType(hToolInfo),hb_eol()
                if (ValType(hToolInfo)=="H")
                    DispOut("DEBUG: Keys in hToolInfo:","g+/n")
                    ? hb_JSONEncode(hb_HKeys(hToolInfo)),hb_eol()
                else
                    hToolInfo:={=>}
                endif
            #endif
        RECOVER
            hToolInfo:={=>}
        END SEQUENCE
    else
        hToolInfo:={=>}
    endif

    if (Empty(hToolInfo))
        #ifdef DEBUG
            DispOut("DEBUG: ","r+/n")
            ? "Error in GetToolName",hb_eol()
        #endif
    endif

    return(hToolInfo)

METHOD GetPromptCategory(cPrompt as character) CLASS TLLM

    local aCategories as array:=Array(0)

    local cJSON as character
    local cCategories as character
    local cGeneralPurpose as character

    local hMessage as hash:={=>}
    local hRequest as hash:={=>}
    local hResponse as hash

    local lTCURLHTTPConnector as logical:=(self:oHTTPConnector:ClassName()=="TCURLHTTPCONNECTOR")

    if (!Empty(self:hAgents))
        hb_HEval(self:hAgents,{|k as character|aAdd(aCategories,{"category_name"=>k,"category_purpose"=>self:hAgents[k]:cAgentPurpose})})
    endif

    #pragma __cstream|cGeneralPurpose:=%s
The "general" category is used when a given prompt does not clearly fit into any predefined categories. It serves as a broad classification for diverse inquiries that do not require specialized tools or domain-specific processing.
This category is designed to handle a wide range of requests, including open-ended questions, conceptual discussions, or queries that span multiple topics. While responses in this category may not be as precise as those in specialized categories, the system will still attempt to provide the best possible answer based on the available information.
If a prompt was mistakenly classified as "general," refining the wording to include more explicit references to a relevant category may improve categorization accuracy.
    #pragma __endtext
    aAdd(aCategories,{"category_name"=>"general","category_purpose"=>cGeneralPurpose})

    cCategories:=hb_JSONEncode({"categories"=>aCategories},.T.)
    #ifdef DEBUG
*        DispOut("DEBUG: Category List: ","g+/n")
*        ? cCategories,hb_eol()
    #endif

    self:oHTTPConnector:SetHeader("Content-Type","application/json")
    if (lTCURLHTTPConnector)
        self:oHTTPConnector:SetOption(HB_CURLOPT_USERNAME,'')
        self:oHTTPConnector:SetOption(HB_CURLOPT_DL_BUFF_SETUP)
        self:oHTTPConnector:SetOption(HB_CURLOPT_SSL_VERIFYPEER,.F.)
    endif

    hRequest["model"]:=self:cModel
    hMessage["role"]:="user"
    hMessage["content"]:="Classify this prompt: '"+cPrompt+"' into the most appropriate category from the following list: ```json"+cCategories+"```. If no specific category fits, return 'general'. Respond only with the category name."
    hRequest["messages"]:={hMessage}
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.7
    hRequest["max_tokens"]:=-1

    cJSON:=hb_jsonEncode(hRequest)
    hResponse:=self:oHTTPConnector:SendRequest("POST",cJSON)

    if (hb_HHasKey(hResponse,"has_error").and.(!hResponse["has_error"]))
        self:cResponse:=hResponse["body"]
        //TODO: rever estre block BEGIN SEQUENCE WITH __BreakBlock()
        BEGIN SEQUENCE WITH __BreakBlock()
            self:cCategory:=self:GetResponseValue()
            #ifdef DEBUG
                DispOut("DEBUG: Category returned by AI: ","g+/n")
                ? self:cCategory,hb_eol()
            #endif
        RECOVER
            self:cResponse:=""
        END SEQUENCE
    else
        self:cResponse:=""
    endif

    if (Empty(self:cResponse))
        #ifdef DEBUG
            DispOut("DEBUG: ","r+/n")
            ? "Error in GetPromptCategory",hb_eol()
        #endif
    endif

    if (Empty(self:cCategory))
        self:cCategory:="general"
    endif

    return(self:cCategory) as character

METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) CLASS TLLM

    local cJSON as character
    local cToolName as character
    local cCategory as character
    local cToolResult as character
    local cBase64Image as character

    local hRequest as hash:={=>}
    local hMessage as hash:={=>}
    local hToolInfo as hash
    local hResponse as hash

    local lContinue as logical:=.T.
    local lTCURLHTTPConnector as logical:=(self:oHTTPConnector:ClassName()=="TCURLHTTPCONNECTOR")

    local nTool as numeric
    local nCategory as numeric

    local oTAgent as object

    begin SEQUENCE

        self:cResponse:=""

        if (!Empty(cPrompt))
            self:cPrompt:=cPrompt
        endif

        if (Empty(self:cPrompt))
            self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Invalid Prompt"},"done"=>.T.})
            break
        endif

        begin sequence

            if (Empty(self:hAgents))
                #ifdef DEBUG
                    DispOut("DEBUG: ","r+/n")
                    ? "No agents defined",hb_eol()
                #endif
                break
            endif

            cCategory:=self:GetPromptCategory(cPrompt)
            #ifdef DEBUG
                DispOut("DEBUG: Obtained category (uncleaned): ","g+/n")
                ? cCategory,hb_eol()
            #endif

            cCategory:=allTrim(hb_StrReplace(cCategory,{Chr(13)=>"",Chr(10)=>""}))
            #ifdef DEBUG
                DispOut("DEBUG: Obtained category (cleaned): ","g+/n")
                ? cCategory,hb_eol()
            #endif

            if (Empty(cCategory))
                #ifdef DEBUG
                    DispOut("DEBUG: ","r+/n")
                    ? "No valid category obtained",hb_eol()
                #endif
                break
            endif

            if (Lower(cCategory)=="general")
                break
            endif

            cCategory:=Lower(allTrim(cCategory))
            nCategory:=hb_HPos(self:hAgents,cCategory)
            if (nCategory==0)
                #ifdef DEBUG
                    DispOut("DEBUG: ","r+/n")
                    ? "No agent found for category '"+cCategory+"'",hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Agent not found for category '"+cCategory+"'"},"done"=>.T.})
                lContinue:=.F.
                break
            endif

            oTAgent:=hb_HValueAt(self:hAgents,nCategory)

            hToolInfo:=self:GetToolName(cPrompt,oTAgent)
            #ifdef DEBUG
                DispOut("DEBUG: Received hToolInfo: ","g+/n")
                ? hb_jsonEncode(hToolInfo),hb_eol()
            #endif

            if ((ValType(hToolInfo)!="H").or.(!hb_HHasKey(hToolInfo,"tool").or.!hb_HHasKey(hToolInfo,"params")))
                #ifdef DEBUG
                    DispOut("DEBUG: Invalid response from GetToolName or missing 'tool' or 'params'. Type: ","r+/n")
                    ? ValType(hToolInfo),hb_eol()
                    if (ValType(hToolInfo)=="H")
                        DispOut("DEBUG: Keys in hToolInfo: ","g+/n")
                        ? hb_JSONEncode(hb_HKeys(hToolInfo)),hb_eol()
                    endif
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Invalid 'tool' or 'params' response"},"done"=>.T.})
                lContinue:=.F.
                break
            endif

            cToolName:=allTrim(hb_StrReplace(hToolInfo["tool"],{Chr(13)=>"",Chr(10)=>""}))
            #ifdef DEBUG
                DispOut("DEBUG: Obtained tool (cleaned): ","g+/n")
                ? cToolName,hb_eol()
                DispOut("DEBUG: Extracted parameters: ","g+/n")
                ? hb_jsonEncode(hToolInfo["params"]),hb_eol()
            #endif

            if (Empty(cToolName))
                #ifdef DEBUG
                    DispOut("DEBUG: ","r+/n")
                    ? "No valid tool name obtained",hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"No tool selected"},"done"=>.T.})
                lContinue:=.F.
                break
            endif

            cToolName:=Lower(allTrim(cToolName))
            nTool:=hb_HPos(oTAgent:hTools,cToolName)
            if (nTool==0)
                #ifdef DEBUG
                    DispOut("DEBUG: Tool ","g+/n")
                    ? "'"+cToolName+"' not found in agent '"+oTAgent:cCategory+"'",hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Tool not found"},"done"=>.T.})
                lContinue:=.F.
                break
            endif

            cToolResult:=Eval(oTAgent:hTools[cToolName]["action"],hToolInfo["params"])
            HB_SYMBOL_UNUSED(cToolResult)
            #ifdef DEBUG
                DispOut("DEBUG: Tool result: ","GR+/n")
                ? cToolResult,hb_eol()
            #endif
            self:cResponse:=hb_jsonEncode({"message"=>{"content"=>cToolResult},"done"=>.T.})
            lContinue:=.F.
            break

        end sequence

        if (!lContinue)
            break
        endif

        #ifdef DEBUG
            DispOut("DEBUG: Calling LMStudio API","g+/n")
            ? hb_eol()
        #endif

        self:oHTTPConnector:SetHeader("Content-Type","application/json")
        if (lTCURLHTTPConnector)
            self:oHTTPConnector:SetOption(HB_CURLOPT_USERNAME,'')
            self:oHTTPConnector:SetOption(HB_CURLOPT_SSL_VERIFYPEER,.F.)
        endif

        hRequest["model"]:=self:cModel
        hMessage["role"]:="user"
        hMessage["content"]:=self:cPrompt
        hRequest["messages"]:={hMessage}
        hRequest["temperature"]:=0.5

        if (!Empty(cImageFileName))
            if (hb_FileExists(cImageFileName))
                cBase64Image:=hb_base64Encode(hb_MemoRead(cImageFileName))
                hMessage["images"]:={cBase64Image}
            else
                #ifdef DEBUG
                    DispOut("DEBUG: Image not found: ","g+/n")
                    ? cImageFileName,hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Image '"+cImageFileName+"'not found"},"done"=>.T.})
                break
            endif
        endif

        if (bWriteFunction!=nil)
            hRequest["stream"]:=.T.
            if (lTCURLHTTPConnector)
                self:oHTTPConnector:SetOption(HB_CURLOPT_WRITEFUNCTION,bWriteFunction)
            endif
        else
            hRequest["stream"]:=.F.
            if (lTCURLHTTPConnector)
                self:oHTTPConnector:SetOption(HB_CURLOPT_DL_BUFF_SETUP)
            endif
        endif

        cJSON:=hb_jsonEncode(hRequest)
        hResponse:=self:oHTTPConnector:SendRequest("POST",cJSON)

        self:nError:=hResponse["error_number"]
        self:nHttpCode:=hResponse["http_status"]

        if (hb_HHasKey(hResponse,"has_error").and.(!hResponse["has_error"]))
            if (bWriteFunction==nil)
                self:cResponse:=hResponse["body"]
            endif
        else
            self:cResponse:=hb_jsonEncode({"error"=>{"message"=>"Error in Send: "+hb_NToC(self:nError)},"done"=>.T.})
        endif

    end sequence

    return(self:GetResponseValue()) as character
