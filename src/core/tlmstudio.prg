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

    DATA   cModel
    DATA   cPrompt
    DATA   cResponse
    DATA   cUrl
    DATA   hCurl
    DATA   nError INIT 0
    DATA   nHttpCode INIT 0
    DATA   aAgents INIT {}

    METHOD New(cModel)
    METHOD Send(cPrompt,cImageFileName,bWriteFunction)
    METHOD GetPromptCategory(cPrompt)
    METHOD GetToolName(cPrompt,oTAgent)
    METHOD End()
    METHOD GetValue(cHKey)

ENDCLASS

METHOD New(cModel) CLASS TLMStudio
    hb_default(@cModel,"gemma-3-4b-it"/*qwen2.5-7b-instruct-1m*/)
    ::cModel:=cModel
    ::cUrl:="http://127.0.0.1:1234/v1/chat/completions"
    ::hCurl:=curl_easy_init()
    ::aAgents:={}
return Self

METHOD GetPromptCategory(cPrompt) CLASS TLMStudio

    local cJson,hRequest:={ => },hMessage:={ => }
    local cCategoryResponse,hResponse
    local nError,cCategories,nI

    cCategories:="'general'"
    if !Empty(::aAgents)
        for nI:=1 to Len(::aAgents)
            cCategories += ",'" + ::aAgents[nI]:cCategory + "'"
        next
    endif

    curl_easy_reset(::hCurl)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POST,.T.)
    curl_easy_setopt(::hCurl,HB_CURLOPT_URL,::cUrl)
    curl_easy_setopt(::hCurl,HB_CURLOPT_HTTPHEADER,{ "Content-Type: application/json" })
    curl_easy_setopt(::hCurl,HB_CURLOPT_USERNAME,'')
    curl_easy_setopt(::hCurl,HB_CURLOPT_DL_BUFF_SETUP)
    curl_easy_setopt(::hCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

    hRequest["model"]:=::cModel
    hMessage["role"]:="user"
    hMessage["content"]:="Classify this prompt: '" + cPrompt + "' into one of these categories: " + cCategories + ". Respond with only the category name."
    hRequest["messages"]:={ hMessage }
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.7
    hRequest["max_tokens"]:=-1

    cJson:=hb_jsonEncode(hRequest)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POSTFIELDS,cJson)

    nError:=curl_easy_perform(::hCurl)
    if nError == HB_CURLE_OK
        cCategoryResponse:=curl_easy_dl_buff_get(::hCurl)
        hb_jsonDecode(cCategoryResponse,@hResponse)
        #ifdef DEBUG
            DispOut("DEBUG: Category returned by AI: ","g+/n")
            ? hResponse["choices"][1]["message"]["content"],hb_eol()
        #endif
        return hResponse["choices"][1]["message"]["content"]
    endif
    #ifdef DEBUG
        DispOut("DEBUG: ","r+/n")
        ? "Error in GetPromptCategory: "+hb_NToC(nError),hb_eol()
    #endif
return nil

METHOD GetToolName(cPrompt,oTAgent) CLASS TLMStudio

    local cJson,cMessage,hRequest:={ => },hMessage:={ => }
    local cToolResponse,hResponse,hToolInfo
    local nError,hTools:={=>},nI

    if !Empty(oTAgent:aTools)
        for nI:=1 to Len(oTAgent:aTools)
            hTools[oTAgent:aTools[nI][1]]:={"parameters"=>oTAgent:aTools[nI][3]}
        next
    endif

    curl_easy_reset(::hCurl)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POST,.T.)
    curl_easy_setopt(::hCurl,HB_CURLOPT_URL,::cUrl)
    curl_easy_setopt(::hCurl,HB_CURLOPT_HTTPHEADER,{ "Content-Type: application/json" })
    curl_easy_setopt(::hCurl,HB_CURLOPT_USERNAME,'')
    curl_easy_setopt(::hCurl,HB_CURLOPT_DL_BUFF_SETUP)
    curl_easy_setopt(::hCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

    hRequest["model"]:=::cModel
    hMessage["role"]:="user"

    if Empty(oTAgent:cMessage)
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
    hRequest["messages"]:={ hMessage }
    hRequest["stream"]:=.F.
    hRequest["temperature"]:=0.5

    cJson:=hb_jsonEncode(hRequest)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POSTFIELDS,cJson)

    nError:=curl_easy_perform(::hCurl)
    if nError == HB_CURLE_OK
        cToolResponse:=curl_easy_dl_buff_get(::hCurl)
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
            endif
        #endif
        return hToolInfo
    endif
    #ifdef DEBUG
        DispOut("DEBUG: ","r+/n")
        ? "Error in GetToolName:"+hb_NToC(nError),hb_eol()
    #endif
return nil

METHOD Send(cPrompt,cImageFileName,bWriteFunction) CLASS TLMStudio

    local aHeaders,cJson,hRequest:={ => },hMessage:={ => }
    local cBase64Image
    local oTAgent,cToolResult,nI,hToolInfo,cToolName,nTool
    local cCategory

    if !Empty(cPrompt)
        ::cPrompt:=cPrompt
    endif

    if !Empty(::aAgents)
        cCategory:=::GetPromptCategory(cPrompt)
        #ifdef DEBUG
            DispOut("DEBUG: Obtained category (uncleaned): ","g+/n")
            ? cCategory,hb_eol()
        #endif
        cCategory:=AllTrim(StrTran(StrTran(cCategory,Chr(13),""),Chr(10),""))
        #ifdef DEBUG
            DispOut("DEBUG: Obtained category (cleaned): ","g+/n")
            ? cCategory,hb_eol()
        #endif
        if !Empty(cCategory)
            if Lower(cCategory) == "general"
                // Proceed to send to OLLama
            else
                oTAgent:=nil
                for nI:=1 to Len(::aAgents)
                    if Lower(AllTrim(::aAgents[nI]:cCategory)) == Lower(AllTrim(cCategory))
                        oTAgent:=::aAgents[nI]
                        exit
                    endif
                next
                if oTAgent != nil
                    hToolInfo:=::GetToolName(cPrompt,oTAgent)
                    #ifdef DEBUG
                        DispOut("DEBUG: Received hToolInfo: ","g+/n")
                        ? hb_jsonEncode(hToolInfo),hb_eol()
                    #endif
                    if ValType(hToolInfo) == "H" .and. hb_HHasKey(hToolInfo,"tool")
                        cToolName:=AllTrim(StrTran(StrTran(hToolInfo["tool"],Chr(13),""),Chr(10),""))
                        #ifdef DEBUG
                            DispOut("DEBUG: Obtained tool (cleaned): ","g+/n")
                            ? cToolName,hb_eol()
                            DispOut("DEBUG: Extracted parameters: ","g+/n")
                            ? hb_jsonEncode(hToolInfo["params"]),hb_eol()
                        #endif
                        if !Empty(cToolName)
                            nTool:=AScan(oTAgent:aTools,{|x| Lower(AllTrim(x[1])) == Lower(AllTrim(cToolName)) })
                            if nTool > 0
                                cToolResult:=Eval(oTAgent:aTools[nTool][2],hToolInfo["params"])
                                #ifdef DEBUG
                                    DispOut("DEBUG: Tool result: ","GR+/n")
                                    ? cToolResult,hb_eol()
                                #endif
                                ::cResponse:=hb_jsonEncode({ "message" => { "content" => cToolResult },"done" => .T. })
                                return ::cResponse
                            else
                                #ifdef DEBUG
                                    DispOut("DEBUG: Tool ","g+/n")
                                    ? "'" + cToolName + "' not found in agent '" + oTAgent:cCategory + "'",hb_eol()
                                #endif
                                ::cResponse:=hb_jsonEncode({ "message" => { "content" => "Tool not found" },"done" => .T. })
                                return ::cResponse
                            endif
                        else
                            #ifdef DEBUG
                                DispOut("DEBUG: ","r+/n")
                                ? "No valid tool name obtained",hb_eol()
                            #endif
                            ::cResponse:=hb_jsonEncode({ "message" => { "content" => "No tool selected" },"done" => .T. })
                            return ::cResponse
                        endif
                    else
                        #ifdef DEBUG
                            DispOut("DEBUG: Invalid response from GetToolName or missing 'tool'. Type: ","r+/n")
                            ? ValType(hToolInfo),hb_eol()
                            if ValType(hToolInfo) == "H"
                                DispOut("DEBUG: Keys in hToolInfo: ","g+/n")
                                ? hb_JSONEncode(hb_HKeys(hToolInfo)),hb_eol()
                            endif
                        #endif
                        ::cResponse:=hb_jsonEncode({ "message" => { "content" => "Invalid tool response" },"done" => .T. })
                        return ::cResponse
                    endif
                else
                    #ifdef DEBUG
                        DispOut("DEBUG: ","r+/n")
                        ? "No agent found for category '" + cCategory + "'",hb_eol()
                    #endif
                    ::cResponse:=hb_jsonEncode({ "message" => { "content" => "Agent not found for category '" + cCategory + "'" },"done" => .T. })
                    return ::cResponse
                endif
            endif
        else
            #ifdef DEBUG
                DispOut("DEBUG: ","r+/n")
                ? "No valid category obtained",hb_eol()
            #endif
        endif
    else
        #ifdef DEBUG
            DispOut("DEBUG: ","r+/n")
            ? "No agents defined",hb_eol()
        #endif
    endif

    #ifdef DEBUG
        DispOut("DEBUG: Calling OLLama API","g+/n")
        ? hb_eol()
    #endif

    curl_easy_reset(::hCurl)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POST,.T.)
    curl_easy_setopt(::hCurl,HB_CURLOPT_URL,::cUrl)
    aHeaders:={ "Content-Type: application/json" }
    curl_easy_setopt(::hCurl,HB_CURLOPT_HTTPHEADER,aHeaders)
    curl_easy_setopt(::hCurl,HB_CURLOPT_USERNAME,'')
    curl_easy_setopt(::hCurl,HB_CURLOPT_SSL_VERIFYPEER,.F.)

    hRequest["model"]:=::cModel
    hMessage["role"]:="user"
    hMessage["content"]:=::cPrompt
    hRequest["messages"]:={ hMessage }
    hRequest["temperature"]:=0.5

    if !Empty(cImageFileName)
        if File(cImageFileName)
            cBase64Image:=hb_base64Encode(memoRead(cImageFileName))
            hMessage["images"]:={ cBase64Image }
        else
            Alert("Image " + cImageFileName + " not found")
            return nil
        endif
    endif

    if bWriteFunction != nil
        hRequest["stream"]:=.T.
        curl_easy_setopt(::hCurl,HB_CURLOPT_WRITEFUNCTION,bWriteFunction)
    else
        hRequest["stream"]:=.F.
        curl_easy_setopt(::hCurl,HB_CURLOPT_DL_BUFF_SETUP)
    endif

    cJson:=hb_jsonEncode(hRequest)
    curl_easy_setopt(::hCurl,HB_CURLOPT_POSTFIELDS,cJson)

    ::nError:=curl_easy_perform(::hCurl)
    curl_easy_getinfo(::hCurl,HB_CURLINFO_RESPONSE_CODE,@::nHttpCode)

    if ::nError == HB_CURLE_OK
        if bWriteFunction == nil
            ::cResponse:=curl_easy_dl_buff_get(::hCurl)
        endif
    else
        ::cResponse:="Error code " + Str(::nError)
    endif

return ::cResponse

METHOD End() CLASS TLMStudio
    curl_easy_cleanup(::hCurl)
    ::hCurl:=nil
return nil

METHOD GetValue(cHKey) CLASS TLMStudio
    local aKeys as array:=hb_AParams()
    local cKey as character
    local uValue:=hb_JSONDecode(::cResponse)
    hb_default(@cHKey,"content")
    if (cHKey=="content")
        TRY
            uValue:=uValue["choices"][1]["message"]["content"]
        CATCH
            TRY
                uValue:=uValue["error"]["message"]
            CATCH
                uValue:=uValue
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
    CATCH
        //...
    END
    return(uValue)
