/*
 _    _                  _               _  _
| |_ | | _ __ ___   ___ | |_  _   _   __| |(_)  ___
| __|| || '_ ` _ \ / __|| __|| | | | / _` || | / _ \
| |_ | || | | | | |\__ \| |_ | |_| || (_| || || (_) |
 \__||_||_| |_| |_||___/ \__| \__,_| \__,_||_| \___/

Class TLMStudio with Agents!

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------

*/
#include "hbcurl.ch"
#include "hbclass.ch"
#include "hbcompat.ch"

CLASS TLMStudio

    DATA aAgents INIT {} as array

    DATA cUrl as character
    DATA cModel as character
    DATA cPrompt as character
    DATA cResponse as character

    DATA phCurl as pointer

    DATA nError INIT 0 as numeric
    DATA nHttpCode INIT 0 as numeric

    METHOD New(cModel as character) as object
    METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) as character
    METHOD GetPromptCategory(cPrompt as character) as character
    METHOD GetToolName(cPrompt as character,oTAgent as object) as hash
    METHOD End()
    METHOD GetValue(cHKey as character) as anytype
    METHOD AddAgent(oTAgent as object) as object

ENDCLASS

METHOD New(cModel as character) CLASS TLMStudio
    hb_default(@cModel,"gemma-3-4b-it"/*qwen2.5-7b-instruct-1m*/)
    self:cModel:=cModel
    self:cUrl:="http://127.0.0.1:1234/v1/chat/completions"
    curl_global_init()
    self:phCurl:=curl_easy_init()
    self:aAgents:={}
    return(self) as object

METHOD GetPromptCategory(cPrompt as character) CLASS TLMStudio

    local cJSON as character
    local cCategories as character
    local cCategoryResponse as character

    local hMessage as hash:={=>}
    local hRequest as hash:={=>}
    local hResponse as hash

    local nError as numeric

    cCategories:="'general'"
    if (!Empty(self:aAgents))
        aEval(self:aAgents,{|o as object|cCategories+=",'"+o:cCategory+"'"})
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
    hMessage["content"]:="Classify this prompt: '"+cPrompt+"' into one of these categories: "+cCategories+". Respond with only the category name."
    hRequest["messages"]:={hMessage}
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.7
    hRequest["max_tokens"]:=-1

    cJSON:=hb_jsonEncode(hRequest)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POSTFIELDS,cJSON)

    nError:=curl_easy_perform(self:phCurl)
    if (nError==HB_CURLE_OK)
        cCategoryResponse:=curl_easy_dl_buff_get(self:phCurl)
        hb_jsonDecode(cCategoryResponse,@hResponse)
        cCategoryResponse:=hResponse["choices"][1]["message"]["content"]
        #ifdef DEBUG
            DispOut("DEBUG: Category returned by AI: ","g+/n")
            ? cCategoryResponse,hb_eol()
        #endif
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

METHOD GetToolName(cPrompt as character,oTAgent as object) CLASS TLMStudio

    local cJSON as character
    local cMessage as character
    local cToolResponse as character

    local hTools as hash:={=>}
    local hRequest as hash:={=>}
    local hMessage as hash:={=>}
    local hResponse as hash
    local hToolInfo as hash

    local nI as numeric
    local nError as numeric

    if (!Empty(oTAgent:aTools))
        for nI:=1 to Len(oTAgent:aTools)
            hTools[oTAgent:aTools[nI][1]]:={"parameters"=>oTAgent:aTools[nI][3]}
        next nI
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

    if (Empty(oTAgent:cMessage))
#pragma __cstream|cMessage:=%s
Based on this prompt: '__PROMPT__' and category '__AGENT_CATEGORY__',
select the appropriate tool from the following list: ```json __JSON_HTOOLS__```,
where each tool has specific parameter names defined (e.g.,"create_folder" expects "folder_name","modify_file" expects "file_name" and "content","get_time" expects no parameters).
Extract the relevant values from the prompt and map them to the exact parameter names required by the selected tool,as specified in the tool`s definition.
Do not use a generic "params" key; instead,use only the defined parameter names.
Return a JSON object with 'tool' (the tool name) and 'params' (a hash with the exact parameter names and their values from the prompt,or an empty hash if no parameters are required).
Provide only a JSON object containing 'tool' (the tool name) and 'params' (an empty object, as no parameters are required), with no additional text or explanation.
Examples:
- For "Create a folder named 'folderName'": {"tool":"create_folder","params":{"folder_name":"folderName"}}
- For "Modify 'fileName' with content 'fileContent'": {"tool":"modify_file","params":{"file_name":"fileName","content":"fileContent"}}
- For "What time is it?": {"tool":"get_date_time","params":{}}.
#pragma __endtext
    else
        cMessage:=oTAgent:cMessage
    endif

    cMessage:=hb_StrReplace(;
        cMessage;
        ,{;
            "__PROMPT__"=>cPrompt;
            ,"__AGENT_CATEGORY__"=>oTAgent:cCategory;
            ,"__JSON_HTOOLS__"=>hb_JSONEncode(hTools);
        };
    )

    hMessage["content"]:=cMessage
    hRequest["messages"]:={hMessage}
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.5

    cJSON:=hb_jsonEncode(hRequest)
    curl_easy_setopt(self:phCurl,HB_CURLOPT_POSTFIELDS,cJSON)

    nError:=curl_easy_perform(self:phCurl)
    if (nError==HB_CURLE_OK)
        cToolResponse:=curl_easy_dl_buff_get(self:phCurl)
        hb_jsonDecode(cToolResponse,@hResponse)
        #ifdef DEBUG
            DispOut("DEBUG: Raw response from AI: ","g+/n")
            ? cToolResponse,hb_eol()
            DispOut("DEBUG: hResponse after decoding: ","g+/n")
            ? hb_jsonEncode(hResponse),hb_eol()
            DispOut("DEBUG: Content of hResponse['choices'][1]['message']['content']:","g+/n")
            ? hResponse["choices"][1]["message"]["content"],hb_eol()
        #endif
        hResponse["choices"][1]["message"]["content"]:=hb_StrReplace(hResponse["choices"][1]["message"]["content"],{"```json"=>"","```"=>""})
        hb_jsonDecode(hResponse["choices"][1]["message"]["content"],@hToolInfo)
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

METHOD Send(cPrompt as character,cImageFileName as character,bWriteFunction as codeblock) CLASS TLMStudio

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
    local nAgent as numeric

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

            if (Empty(self:aAgents))
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

            nAgent:=aScan(self:aAgents,{|x|(Lower(allTrim(x:cCategory))==Lower(allTrim(cCategory)))})
            if (nAgent==0)
                #ifdef DEBUG
                    DispOut("DEBUG: ","r+/n")
                    ? "No agent found for category '"+cCategory+"'",hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>"Agent not found for category '"+cCategory+"'"},"done"=>.T.}]})
                lContinue:=.F.
                break
            endif

            oTAgent:=self:aAgents[nAgent]

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
                self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>"Invalid tool response"},"done"=>.T.}]})
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
                self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>"No tool selected"},"done"=>.T.}]})
                lContinue:=.F.
                break
            endif

            if ((nTool:=aScan(oTAgent:aTools,{|x|Lower(allTrim(x[1]))==Lower(allTrim(cToolName))}))==0)
                #ifdef DEBUG
                    DispOut("DEBUG: Tool ","g+/n")
                    ? "'"+cToolName+"' not found in agent '"+oTAgent:cCategory+"'",hb_eol()
                #endif
                self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>"Tool not found"},"done"=>.T.}]})
                lContinue:=.F.
                break
            endif

            cToolResult:=Eval(oTAgent:aTools[nTool][2],hToolInfo["params"])
            #ifdef DEBUG
                DispOut("DEBUG: Tool result: ","GR+/n")
                ? cToolResult,hb_eol()
            #endif
            self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>cToolResult},"done"=>.T.}]})
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
                self:cResponse:=hb_jsonEncode({"choices"=>[{"message"=>{"content"=>"Image '"+cImageFileName+"'not found"},"done"=>.T.}]})
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

METHOD PROCEDURE End() CLASS TLMStudio
    curl_easy_cleanup(self:phCurl)
    curl_global_cleanup()
    return

METHOD AddAgent(oTAgent as object) CLASS TLMStudio
    aAdd(self:aAgents,oTAgent)
    return(self) as object

METHOD GetValue(cHKey as character) CLASS TLMStudio

    local aKeys as array:=hb_AParams()

    local cKey as character

    local uValue as anytype:=hb_JSONDecode(self:cResponse)

    hb_default(@cHKey,"content")

    if (cHKey=="content")
        TRY
            uValue:=uValue["choices"][1]["message"]["content"]
        CATCH
            TRY
                uValue:=uValue["message"]["content"]
            CATCH
                TRY
                    uValue:=uValue["error"]["message"]
                CATCH
                    uValue:=uValue
                END
            END
        END
    endif

    TRY
        for each cKey in aKeys
            if (ValType(uValue[cKey])=="A")
                uValue:=uValue[cKey][1]["choices"][1]["message"]["content"]
            else
                uValue:=uValue[cKey]
            endif
        next
    END

    return(uValue) as anytype
