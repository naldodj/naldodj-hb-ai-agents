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
            ? "DEBUG: Category returned by AI: "
            DispOut(hResponse[ "message" ][ "content" ],"g+/n")
        #endif
        return hResponse[ "message" ][ "content" ]
    endif
    #ifdef DEBUG
        ? "DEBUG: "
        DispOut("Error in GetPromptCategory: "+hb_NToC(nError),"r+/n")
    #endif
return nil

METHOD GetToolName( cPrompt, oAgent ) CLASS TOLLama
    local cJson, hRequest:={ => }, hMessage:={ => }
    local cToolResponse, hResponse, hToolInfo
    local nError, cTools:="", nI

    if ! Empty( oAgent:aTools )
        for nI:=1 to Len( oAgent:aTools )
            cTools += "'" + oAgent:aTools[ nI ][ 1 ] + "'"
            if nI < Len( oAgent:aTools )
                cTools += ", "
            endif
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
    hMessage[ "content" ]:="Given this prompt: '" + cPrompt + "' and category '" + oAgent:cCategory + "', " + ;
                            "select the appropriate tool from: " + cTools + " and extract any relevant parameters. " + ;
                            "Respond with a JSON object containing 'tool' (the tool name) and 'params' (a hash of parameters)."
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
            ? "DEBUG: Raw response from AI: "
            DispOut(cToolResponse,"g+/n")
            ? "DEBUG: hResponse after decoding: "
            DispOut(hb_jsonEncode( hResponse ),"g+/n")
            ? "DEBUG: Content of hResponse[ 'message' ][ 'content' ]:"
            DispOut(hResponse[ "message" ][ "content" ],"g+/n")
        #endif
        hResponse[ "message" ][ "content" ]:=SubStr( hResponse[ "message" ][ "content" ], 9 )
        hResponse[ "message" ][ "content" ]:=SubStr( hResponse[ "message" ][ "content" ], 1, Len( hResponse[ "message" ][ "content" ] ) - 3 )
        hb_jsonDecode( hResponse[ "message" ][ "content" ], @hToolInfo )
        #ifdef DEBUG
            ? "DEBUG: hToolInfo after processing:"
            DispOut(hb_jsonEncode( hToolInfo ),"g+/n")
            ? "DEBUG: Type of hToolInfo:"
            DispOut(ValType( hToolInfo ),"g+/n")
            if ValType( hToolInfo ) == "H"
                ? "DEBUG: Keys in hToolInfo:"
                DispOut(hb_JSONEncode(hb_HKeys(hToolInfo)),"g+/n")
            endif
        #endif
        return hToolInfo
    endif
    #ifdef DEBUG
        ? "DEBUG: "
        DispOut("Error in GetToolName:"+hb_NToC(nError),"r+/n")
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
            ? "DEBUG: Obtained category (uncleaned): "
            DispOut(cCategory,"g+/n")
        #endif
        cCategory:=AllTrim( StrTran( StrTran( cCategory, Chr(13), "" ), Chr(10), "" ) )
        #ifdef DEBUG
            ? "DEBUG: Obtained category (cleaned): "
            DispOut(cCategory,"g+/n")
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
                        ? "DEBUG: Received hToolInfo: "
                        DispOut(hb_jsonEncode( hToolInfo ),"g+/n")
                    #endif
                    if ValType( hToolInfo ) == "H" .and. hb_HHasKey( hToolInfo, "tool" )
                        cToolName:=AllTrim( StrTran( StrTran( hToolInfo[ "tool" ], Chr(13), "" ), Chr(10), "" ) )
                        #ifdef DEBUG
                            ? "DEBUG: Obtained tool (cleaned): "
                            DispOut(cToolName,"g+/n")
                            ? "DEBUG: Extracted parameters: "
                            DispOut(hb_jsonEncode( hToolInfo[ "params" ] ),"g+/n")
                        #endif
                        if ! Empty( cToolName )
                            nTool:=AScan( oAgent:aTools, {|x| Lower( AllTrim( x[1] ) ) == Lower( AllTrim( cToolName ) ) } )
                            if nTool > 0
                                cToolResult:=Eval( oAgent:aTools[ nTool ][ 2 ], hToolInfo[ "params" ] )
                                #ifdef DEBUG
                                    ? "DEBUG: Tool result: "
                                    DispOut(cToolResult,"g+/n")
                                #endif
                                ::cResponse:=hb_jsonEncode( { "message" => { "content" => cToolResult }, "done" => .T. } )
                                return ::cResponse
                            else
                                #ifdef DEBUG
                                    ? "DEBUG: Tool "
                                    DispOut("'" + cToolName + "' not found in agent '" + oAgent:cCategory + "'","g+/n")
                                #endif
                                ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Tool not found" }, "done" => .T. } )
                                return ::cResponse
                            endif
                        else
                            #ifdef DEBUG
                                ? "DEBUG: "
                                DispOut("No valid tool name obtained","r+/n")
                            #endif
                            ::cResponse:=hb_jsonEncode( { "message" => { "content" => "No tool selected" }, "done" => .T. } )
                            return ::cResponse
                        endif
                    else
                        #ifdef DEBUG
                            ? "DEBUG: Invalid response from GetToolName or missing 'tool'. Type: "
                            DispOut(ValType( hToolInfo ),"r+/n")
                            if ValType( hToolInfo ) == "H"
                                ? "DEBUG: Keys in hToolInfo: "
                                DispOut(hb_HKeys( hToolInfo ),"g+/n")
                            endif
                        #endif
                        ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Invalid tool response" }, "done" => .T. } )
                        return ::cResponse
                    endif
                else
                    #ifdef DEBUG
                        ? "DEBUG: "
                        DispOut("No agent found for category '" + cCategory + "'","r+/n")
                    #endif
                    ::cResponse:=hb_jsonEncode( { "message" => { "content" => "Agent not found for category '" + cCategory + "'" }, "done" => .T. } )
                    return ::cResponse
                endif
            endif
        else
            #ifdef DEBUG
                ? "DEBUG: "
                DispOut("No valid category obtained","r+/n")
            #endif
        endif
    else
        #ifdef DEBUG
            ? "DEBUG: "
            DispOut("No agents defined","r+/n")
        #endif
    endif

    #ifdef DEBUG
        ? "DEBUG: "
        DispOut("Calling OLLama API","g+/n")
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
