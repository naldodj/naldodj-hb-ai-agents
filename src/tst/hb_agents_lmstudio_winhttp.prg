/*
 _      _                                    _            _         _
| |__  | |__       __ _   __ _   ___  _ __  | |_  ___    | |_  ___ | |_
| '_ \ | '_ \     / _` | / _` | / _ \| '_ \ | __|/ __|   | __|/ __|| __|
| | | || |_) |   | (_| || (_| ||  __/| | | || |_ \__ \   | |_ \__ \| |_
|_| |_||_.__/     \__,_| \__,| \___||_| |_| \__||___/    \__||___/ \__|
                         |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------

*/

#require "hbct"

REQUEST HB_CODEPAGE_UTF8EX

// Enable debugging (hbmk2 -DDEBUG)

procedure Main()

    local aModel as array
    local aModels as array

    local cCDP as character
    local cURL as character
    local cModel as character

    local nTimeOut as numeric:=600

    local oHTTPConnector as object

    CLS

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cCDP:=hb_cdpSelect("UTF8EX")

    aModels:=Array(0)
    /*The Best First:*/
    aAdd(aModels,{"qwen2.5-7b-instruct-1m",.T.})
    aAdd(aModels,{"gemma-3-4b-it",.T.})

    cURL:="http://127.0.0.1:1234/v1/chat/completions"

    for each aModel in aModels
        if (aModel[2])
            cModel:=aModel[1]
            oHTTPConnector:=TWinHTTPConnector():New(cURL)
            oHTTPConnector:SetTimeOuts(nTimeOut,nTimeOut,nTimeOut,nTimeOut)
            ExecutePrompts(cModel,cURL,oHTTPConnector)
        endif
    next each //aModel

    hb_cdpSelect(cCDP)

    return

#include "./hb_agents_prompts.prg"
