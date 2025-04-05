/*
 _           _  _
| |_   ___  | || |  __ _  _ __ ___    __ _
| __| / _ \ | || | / _` || '_ ` _ \  / _` |
| |_ | (_) || || || (_| || | | | | || (_| |
 \__| \___/ |_||_| \__,_||_| |_| |_| \__,_|

Class TOllama with Agents!

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------

*/
#include "hbcurl.ch"
#include "hbclass.ch"
#include "hbcompat.ch"

CLASS TOLLama

    DATA cUrl as character
    DATA cModel as character
    DATA cPrompt as character
    DATA cResponse as character

    DATA hAgents INIT {=>} as hash

    DATA phCurl as pointer

    DATA nError INIT 0 as numeric
    DATA nHttpCode INIT 0 as numeric

    METHOD New(cModel as character) as object
    METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) as character
    METHOD GetPromptCategory(cPrompt as character) as character
    METHOD GetToolName(cPrompt as character,oTAgent as object) as hash
    METHOD End()
    METHOD GetValue() as anytype
    METHOD AddAgent(oTAgent as object) as object

ENDCLASS

METHOD New(cModel as character) CLASS TOLLama
    /*
        The Best First:
        hf.co/lmstudio-community/Qwen2.5-7B-Instruct-1M-GGUF:Q8_0/Qwen2.5-7B-Instruct-1M-GGUF
        gemma3
    */
    hb_default(@cModel,"hf.co/lmstudio-community/Qwen2.5-7B-Instruct-1M-GGUF:Q8_0")
    self:cModel:=cModel
    self:cUrl:="http://localhost:11434/api/chat"
    curl_global_init()
    self:phCurl:=curl_easy_init()
    self:hAgents:={=>}
    return(self) as object

METHOD GetPromptCategory(cPrompt as character) CLASS TOLLama

    local aCategories as array:=Array(0)

    local cJSON as character
    local cCategories as character
    local cGeneralPurpose as character
    local cCategoryResponse as character

    local hMessage as hash:={=>}
    local hRequest as hash:={=>}
    local hResponse as hash

    local nError as numeric

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

    curl_easy_reset(self:phCurl)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POST,.T.)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_URL,self:cUrl)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_HTTPHEADER,{"Content-Type: application/json"})
    curl_easy_setopt(self:phCurl,HB_CURLOPT_USERNAME,'')
    curl_easy_setopt(self:phCurl,HB_CURLOPT_DL_BUFF_SETUP)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

    hRequest["model"]:=self:cModel
    hMessage["role"]:="user"
    hMessage["content"]:="Classify this prompt: '"+cPrompt+"' into the most appropriate category from the following list: ```json"+cCategories+"```. If no specific category fits, return 'general'. Respond only with the category name."
    hRequest["messages"]:={hMessage}
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.5

    cJSON:=hb_jsonEncode(hRequest)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POSTFIELDS,cJSON)

    nError:=curl_easy_perform(self:phCurl)
    if (nError==HB_CURLE_OK)
        cCategoryResponse:=curl_easy_dl_buff_get(self:phCurl)
        TRY
            hb_jsonDecode(cCategoryResponse,@hResponse)
            cCategoryResponse:=hResponse["message"]["content"]
            #ifdef DEBUG
                DispOut("DEBUG: Category returned by AI: ","g+/n")
                ? cCategoryResponse,hb_eol()
            #endif
        CATCH
            cCategoryResponse:=""
        END TRY
    else
        cCategoryResponse:=""
    endif

    if (Empty(cCategoryResponse))
        #ifdef DEBUG
            DispOut("DEBUG: ","r+/n")
            ? "Error in GetPromptCategory: "+hb_NToC(nError),hb_eol()
        #endif
    endif

    return(cCategoryResponse) as character

METHOD GetToolName(cPrompt as character,oTAgent as object) CLASS TOLLama

    local cKey as character
    local cJSON as character
    local cAgentPrompt as character
    local cToolResponse as character

    local hTools as hash:={=>}
    local hRequest as hash:={=>}
    local hMessage as hash:={=>}
    local hResponse as hash
    local hToolInfo as hash

    local nError as numeric

    if (!Empty(oTAgent:hTools))
        for each cKey in hb_HKeys(oTAgent:hTools)
            hTools[cKey]:={"parameters"=>oTAgent:hTools[cKey]["parameters"]}
        next each
    endif

    curl_easy_reset(self:phCurl)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POST,.T.)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_URL,self:cUrl)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_HTTPHEADER,{"Content-Type: application/json"})
    curl_easy_setopt(self:phCurl,HB_CURLOPT_USERNAME,'')
    curl_easy_setopt(self:phCurl,HB_CURLOPT_DL_BUFF_SETUP)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

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
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POSTFIELDS,cJSON)

    nError:=curl_easy_perform(self:phCurl)
    if (nError==HB_CURLE_OK)
        cToolResponse:=curl_easy_dl_buff_get(self:phCurl)
        //TODO: rever estre block TRY
        TRY
            hb_jsonDecode(cToolResponse,@hResponse)
            #ifdef DEBUG
                DispOut("DEBUG: Raw response from AI: ","g+/n")
                ? cToolResponse,hb_eol()
                DispOut("DEBUG: hResponse after decoding: ","g+/n")
                ? hb_jsonEncode(hResponse),hb_eol()
                DispOut("DEBUG: Content of hResponse['message']['content']:","g+/n")
                ? hResponse["message"]["content"],hb_eol()
            #endif
            hResponse["message"]["content"]:=hb_StrReplace(hResponse["message"]["content"],{"```json"=>"","```"=>""})
            hb_jsonDecode(hResponse["message"]["content"],@hToolInfo)
            #ifdef DEBUG
                DispOut("DEBUG: hToolInfo after processing:","g+/n")
                ? hb_jsonEncode(hToolInfo),hb_eol()
                DispOut("DEBUG: Type of hToolInfo:","g+/n")
                ? ValType(hToolInfo),hb_eol()
                if ValType(hToolInfo) == "H"
                    DispOut("DEBUG: Keys in hToolInfo:","g+/n")
                    ? hb_JSONEncode(hb_HKeys(hToolInfo)),hb_eol()
                else
                    hToolInfo:={=>}
                endif
            #endif
        CATCH
            hToolInfo:={=>}
        END TRY
    else
        hToolInfo:={=>}
    endif

    if (Empty(hToolInfo))
        #ifdef DEBUG
            DispOut("DEBUG: ","r+/n")
            ? "Error in GetToolName:"+hb_NToC(nError),hb_eol()
        #endif
    endif

    return(hToolInfo)

METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) CLASS TOLLama

    local aHeaders as array

    local cJSON as character
    local cToolName as character
    local cCategory as character
    local cToolResult as character
    local cBase64Image as character

    local hRequest as hash:={=>}
    local hMessage as hash:={=>}
    local hToolInfo as hash

    local lContinue as logical:=.T.

    local nTool as numeric
    local nCategory as numeric

    local oTAgent as object

    begin SEQUENCE

        self:cResponse:=""

        if (!Empty(cPrompt))
            self:cPrompt:=cPrompt
        endif

        if (Empty(self:cPrompt))
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

            if ((ValType(hToolInfo)!="H").or.(!hb_HHasKey(hToolInfo,"tool")))
                #ifdef DEBUG
                    DispOut("DEBUG: Invalid response from GetToolName or missing 'tool'. Type: ","r+/n")
                    ? ValType(hToolInfo),hb_eol()
                    if (ValType(hToolInfo)=="H")
                        DispOut("DEBUG: Keys in hToolInfo: ","g+/n")
                        ? hb_JSONEncode(hb_HKeys(hToolInfo)),hb_eol()
                    endif
                #endif
                self:cResponse:=hb_jsonEncode({"message"=>{"content"=>"Invalid tool response"},"done"=>.T.})
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
            DispOut("DEBUG: Calling OLLAMA API","g+/n")
            ? hb_eol()
        #endif

        curl_easy_reset(self:phCurl)
        curl_easy_setopt(self:phCurl,HB_CURLOPT_POST,.T.)
        curl_easy_setopt(self:phCurl,HB_CURLOPT_URL,self:cUrl)
        aHeaders:={"Content-Type: application/json"}
        curl_easy_setopt(self:phCurl,HB_CURLOPT_HTTPHEADER,aHeaders)
        curl_easy_setopt(self:phCurl,HB_CURLOPT_USERNAME,'')
        curl_easy_setopt(self:phCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

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
            curl_easy_setopt(self:phCurl,HB_CURLOPT_WRITEFUNCTION,bWriteFunction)
        else
            hRequest["stream"]:=.F.
            curl_easy_setopt(self:phCurl,HB_CURLOPT_DL_BUFF_SETUP)
        endif

        cJSON:=hb_jsonEncode(hRequest)
        curl_easy_setopt(self:phCurl,HB_CURLOPT_POSTFIELDS,cJSON)

        self:nError:=curl_easy_perform(self:phCurl)
        curl_easy_getinfo(self:phCurl,HB_CURLINFO_RESPONSE_CODE,@self:nHttpCode)

        if (self:nError==HB_CURLE_OK)
            if (bWriteFunction==nil)
                self:cResponse:=curl_easy_dl_buff_get(self:phCurl)
            endif
        else
            self:cResponse:="Error code "+Str(self:nError)
        endif

    end sequence

    return(self:cResponse) as character

METHOD PROCEDURE End() CLASS TOLLama
    curl_easy_cleanup(self:phCurl)
    curl_global_cleanup()
    return

METHOD AddAgent(oTAgent as object) CLASS TOLLama
    local cCategory as character:=Lower(allTrim(oTAgent:cCategory))
    local nCategory as numeric
    nCategory:=hb_HPos(self:hAgents,cCategory)
    if (nCategory==0)
        self:hAgents[cCategory]:=oTAgent
    endif
    return(self) as object

METHOD GetValue() CLASS TOLLama

    local hResponse as hash
    local uValue as anytype

    hb_jsonDecode(self:cResponse,@hResponse)

    TRY
        uValue:=hResponse["message"]["content"]
    CATCH
        uValue:=hResponse["error"]["message"]
    END TRY

    return(uValue) as anytype
