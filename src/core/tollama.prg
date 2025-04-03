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

    DATA   cModel
    DATA   cPrompt
    DATA   cResponse
    DATA   cUrl
    DATA   hCurl
    DATA   nError INIT 0
    DATA   nHttpCode INIT 0
    DATA   aAgents INIT {}

    METHOD New( cModel )
    METHOD Send( cPrompt, cImageFileName, bWriteFunction )
    METHOD GetPromptCategory( cPrompt )
    METHOD GetToolName( cPrompt, oAgent )
    METHOD End()
    METHOD GetValue()

ENDCLASS

METHOD New( cModel ) CLASS TOLLama
    hb_default(@cModel, "gemma3")
    ::cModel:=cModel
    ::cUrl:="http://localhost:11434/api/chat"
    ::hCurl:=curl_easy_init()
    ::aAgents:={}
return Self

METHOD GetPromptCategory( cPrompt ) CLASS TOLLama

    local cJson, hRequest:={ => }, hMessage:={ => }
    local cCategoryResponse, hResponse
    local nError, cCategories, nI

    cCategories:="'general'"
    if ! Empty( ::aAgents )
        for nI:=1 to Len( ::aAgents )
            cCategories += ", '" + ::aAgents[ nI ]:cCategory + "'"
        next
    endif

    curl_easy_reset( ::hCurl )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POST, .T. )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_URL, ::cUrl )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_HTTPHEADER, { "Content-Type: application/json" } )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_USERNAME, '' )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_DL_BUFF_SETUP )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_SSL_VERIFYPEER, .F. )

    hRequest[ "model" ]:=::cModel
    hMessage[ "role" ]:="user"
    hMessage[ "content" ]:="Classify this prompt: '" + cPrompt + "' into one of these categories: " + cCategories + ". Respond with only the category name."
    hRequest[ "messages" ]:={ hMessage }
    hRequest[ "stream" ]:=.F.
    hRequest[ "temperature" ]:=0.5

    cJson:=hb_jsonEncode( hRequest )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POSTFIELDS, cJson )

    nError:=curl_easy_perform( ::hCurl )
    if nError == HB_CURLE_OK
        cCategoryResponse:=curl_easy_dl_buff_get( ::hCurl )
        hb_jsonDecode( cCategoryResponse, @hResponse )
        #ifdef DEBUG
            DispOut("DEBUG: Category returned by AI: ","g+/n")
            ? hResponse[ "message" ][ "content" ],hb_eol()
        #endif
        return hResponse[ "message" ][ "content" ]
    endif
    #ifdef DEBUG
        DispOut("DEBUG: ","r+/n")
        ? "Error in GetPromptCategory: "+hb_NToC(nError),hb_eol()
    #endif
return nil

METHOD GetToolName( cPrompt, oAgent ) CLASS TOLLama
    local cJson, hRequest:={ => }, hMessage:={ => }
    local cToolResponse, hResponse, hToolInfo
    local nError, hTools:={=>}, nI

    if ! Empty( oAgent:aTools )
        for nI:=1 to Len( oAgent:aTools )
            hTools[oAgent:aTools[nI][1]]:={"parameters"=>oAgent:aTools[nI][3]}
        next
    endif

    curl_easy_reset( ::hCurl )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POST, .T. )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_URL, ::cUrl )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_HTTPHEADER, { "Content-Type: application/json" } )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_USERNAME, '' )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_DL_BUFF_SETUP )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_SSL_VERIFYPEER, .F. )

    hRequest[ "model" ]:=::cModel
    hMessage[ "role" ]:="user"

#pragma __cstream|hMessage[ "content" ]:=%s
Based on this prompt: '__PROMPT__' and category '__AGENT_CATEGORY__',
select the appropriate tool from the following list: ```json __JSON_HTOOLS__```,
where each tool has specific parameter names defined (e.g., "create_folder" expects "folder_name", "modify_file" expects "file_name" and "content", "get_time" expects no parameters).
Extract the relevant values from the prompt and map them to the exact parameter names required by the selected tool, as specified in the tool`s definition.
Do not use a generic "params" key; instead, use only the defined parameter names.
Return a JSON object with 'tool' (the tool name) and 'params' (a hash with the exact parameter names and their values from the prompt, or an empty hash if no parameters are required).
Examples:
- For "Create a folder named test": {"tool":"create_folder","params":{"folder_name":"test"}}
- For "Modify test.txt with content Hello World": {"tool":"modify_file","params":{"file_name":"test.txt","content":"Hello World"}}
- For "What time is it?": {"tool":"get_time","params":{}}.
#pragma __endtext

    hMessage[ "content" ]:=hb_StrReplace(;
        hMessage[ "content" ];
        ,{;
            "__PROMPT__"=>cPrompt;
            ,"__AGENT_CATEGORY__"=>oAgent:cCategory;
            ,"__JSON_HTOOLS__" => hb_JSONEncode(hTools);
        };
    )

    hRequest[ "messages" ]:={ hMessage }
    hRequest[ "stream" ]:=.F.
    hRequest[ "temperature" ]:=0.5

    cJson:=hb_jsonEncode( hRequest )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POSTFIELDS, cJson )

    nError:=curl_easy_perform( ::hCurl )
    if nError == HB_CURLE_OK
        cToolResponse:=curl_easy_dl_buff_get( ::hCurl )
        hb_jsonDecode( cToolResponse, @hResponse )
        #ifdef DEBUG
            DispOut("DEBUG: Raw response from AI: ","g+/n")
            ? cToolResponse,hb_eol()
            DispOut("DEBUG: hResponse after decoding: ","g+/n")
            ? hb_jsonEncode( hResponse ),hb_eol()
            DispOut("DEBUG: Content of hResponse[ 'message' ][ 'content' ]:","g+/n")
            ? hResponse[ "message" ][ "content" ],hb_eol()
        #endif
        hResponse[ "message" ][ "content" ]:=SubStr( hResponse[ "message" ][ "content" ], 9 )
        hResponse[ "message" ][ "content" ]:=SubStr( hResponse[ "message" ][ "content" ], 1, Len( hResponse[ "message" ][ "content" ] ) - 3 )
        hb_jsonDecode( hResponse[ "message" ][ "content" ], @hToolInfo )
        #ifdef DEBUG
            DispOut("DEBUG: hToolInfo after processing:","g+/n")
            ? hb_jsonEncode( hToolInfo ),hb_eol()
            DispOut("DEBUG: Type of hToolInfo:","g+/n")
            ? ValType( hToolInfo ),hb_eol()
            if ValType( hToolInfo ) == "H"
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

METHOD Send( cPrompt, cImageFileName, bWriteFunction ) CLASS TOLLama
    local aHeaders, cJson, hRequest:={ => }, hMessage:={ => }
    local cBase64Image
    local oAgent, cToolResult, nI, hToolInfo, cToolName, nTool
    local cCategory

    if ! Empty( cPrompt )
        ::cPrompt:=cPrompt
    endif

    if ! Empty( ::aAgents )
        cCategory:=::GetPromptCategory( cPrompt )
        #ifdef DEBUG
            DispOut("DEBUG: Obtained category (uncleaned): ","g+/n")
            ? cCategory,hb_eol()
        #endif
        cCategory:=AllTrim( StrTran( StrTran( cCategory, Chr(13), "" ), Chr(10), "" ) )
        #ifdef DEBUG
            DispOut("DEBUG: Obtained category (cleaned): ","g+/n")
            ? cCategory,hb_eol()
        #endif
        if ! Empty( cCategory )
            if Lower( cCategory ) == "general"
                // Proceed to send to OLLama
            else
                oAgent:=nil
                for nI:=1 to Len( ::aAgents )
                    if Lower( AllTrim( ::aAgents[ nI ]:cCategory ) ) == Lower( AllTrim( cCategory ) )
                        oAgent:=::aAgents[ nI ]
                        exit
                    endif
                next
                if oAgent != nil
                    hToolInfo:=::GetToolName( cPrompt, oAgent )
                    #ifdef DEBUG
                        DispOut("DEBUG: Received hToolInfo: ","g+/n")
                        ? hb_jsonEncode( hToolInfo ),hb_eol()
                    #endif
                    if ValType( hToolInfo ) == "H" .and. hb_HHasKey( hToolInfo, "tool" )
                        cToolName:=AllTrim( StrTran( StrTran( hToolInfo[ "tool" ], Chr(13), "" ), Chr(10), "" ) )
                        #ifdef DEBUG
                            DispOut("DEBUG: Obtained tool (cleaned): ","g+/n")
                            ? cToolName,hb_eol()
                            DispOut("DEBUG: Extracted parameters: ","g+/n")
                            ? hb_jsonEncode( hToolInfo[ "params" ] ),hb_eol()
                        #endif
                        if ! Empty( cToolName )
                            nTool:=AScan( oAgent:aTools, {|x| Lower( AllTrim( x[1] ) ) == Lower( AllTrim( cToolName ) ) } )
                            if nTool > 0
                                cToolResult:=Eval( oAgent:aTools[ nTool ][ 2 ], hToolInfo[ "params" ] )
                                #ifdef DEBUG
                                    DispOut("DEBUG: Tool result: ","GR+/n")
                                    ? cToolResult,hb_eol()
                                #endif
                                ::cResponse:=hb_jsonEncode( { "message" => { "content" => cToolResult }, "done" => .T. } )
                                return ::cResponse
                            else
                                #ifdef DEBUG
                                    DispOut("DEBUG: Tool ","g+/n")
                                    ? "'" + cToolName + "' not found in agent '" + oAgent:cCategory + "'",hb_eol()
                                #endif
                                ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Tool not found" }, "done" => .T. } )
                                return ::cResponse
                            endif
                        else
                            #ifdef DEBUG
                                DispOut("DEBUG: ","r+/n")
                                ? "No valid tool name obtained",hb_eol()
                            #endif
                            ::cResponse:=hb_jsonEncode( { "message" => { "content" => "No tool selected" }, "done" => .T. } )
                            return ::cResponse
                        endif
                    else
                        #ifdef DEBUG
                            DispOut("DEBUG: Invalid response from GetToolName or missing 'tool'. Type: ","r+/n")
                            ? ValType( hToolInfo ),hb_eol()
                            if ValType( hToolInfo ) == "H"
                                DispOut("DEBUG: Keys in hToolInfo: ","g+/n")
                                ? hb_JSONEncode(hb_HKeys( hToolInfo )),hb_eol()
                            endif
                        #endif
                        ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Invalid tool response" }, "done" => .T. } )
                        return ::cResponse
                    endif
                else
                    #ifdef DEBUG
                        DispOut("DEBUG: ","r+/n")
                        ? "No agent found for category '" + cCategory + "'",hb_eol()
                    #endif
                    ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Agent not found for category '" + cCategory + "'" }, "done" => .T. } )
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
    #endif
    curl_easy_reset( ::hCurl )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POST, .T. )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_URL, ::cUrl )
    aHeaders:={ "Content-Type: application/json" }
    curl_easy_setopt( ::hCurl, HB_CURLOPT_HTTPHEADER, aHeaders )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_USERNAME, '' )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_SSL_VERIFYPEER, .F. )

    hRequest[ "model" ]:=::cModel
    hMessage[ "role" ]:="user"
    hMessage[ "content" ]:=::cPrompt
    hRequest[ "messages" ]:={ hMessage }
    hRequest[ "temperature" ]:=0.5

    if ! Empty( cImageFileName )
        if File( cImageFileName )
            cBase64Image:=hb_base64Encode( memoRead( cImageFileName ) )
            hMessage[ "images" ]:={ cBase64Image }
        else
            Alert( "Image " + cImageFileName + " not found" )
            return nil
        endif
    endif

    if bWriteFunction != nil
        hRequest[ "stream" ]:=.T.
        curl_easy_setopt( ::hCurl, HB_CURLOPT_WRITEFUNCTION, bWriteFunction )
    else
        hRequest[ "stream" ]:=.F.
        curl_easy_setopt( ::hCurl, HB_CURLOPT_DL_BUFF_SETUP )
    endif

    cJson:=hb_jsonEncode( hRequest )
    curl_easy_setopt( ::hCurl, HB_CURLOPT_POSTFIELDS, cJson )

    ::nError:=curl_easy_perform( ::hCurl )
    curl_easy_getinfo( ::hCurl, HB_CURLINFO_RESPONSE_CODE, @::nHttpCode )

    if ::nError == HB_CURLE_OK
        if bWriteFunction == nil
            ::cResponse:=curl_easy_dl_buff_get( ::hCurl )
        endif
    else
        ::cResponse:="Error code " + Str( ::nError )
    endif
return ::cResponse

METHOD End() CLASS TOLLama
    curl_easy_cleanup( ::hCurl )
    ::hCurl:=nil
return nil

METHOD GetValue() CLASS TOLLama
    local hResponse, uValue
    hb_jsonDecode( ::cResponse, @hResponse )
    TRY
        uValue:=hResponse[ "message" ][ "content" ]
    CATCH
        uValue:=hResponse[ "error" ][ "message" ]
    END
return uValue
