/*
 _      _                                    _            _         _
| |__  | |__       __ _   __ _   ___  _ __  | |_  ___    | |_  ___ | |_
| '_ \ | '_ \     / _` | / _` | / _ \| '_ \ | __|/ __|   | __|/ __|| __|
| | | || |_) |   | (_| || (_| ||  __/| | | || |_ \__ \   | |_ \__ \| |_
|_| |_||_.__/     \__,_| \__, | \___||_| |_| \__||___/    \__||___/ \__|
                         |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------

*/

REQUEST HB_CODEPAGE_UTF8EX

// Enable debugging (hbmk2 -DDEBUG)

procedure Main()

    local aModel as array
    local aModels as array

    local cCDP as character
    local cURL as character
    local cModel as character

    local oHTTPConnector as object

    CLS

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cCDP:=hb_cdpSelect("UTF8EX")

    aModels:=Array(0)
    /*The Best First:*/
    aAdd(aModels,{"hf.co/lmstudio-community/Qwen2.5-7B-Instruct-1M-GGUF:Q8_0",.T.})
    aAdd(aModels,{"gemma3",.T.})

    cURL:="http://localhost:11434/api/chat"

    oHTTPConnector:=TIPHTTPConnector():New(cURL)
    oHTTPConnector:SetTimeout(600)

    for each aModel in aModels
        if (aModel[2])
            cModel:=aModel[1]
            ExecutePrompts(cModel,cURL,oHTTPConnector)
        endif
    next each //aModel

    hb_cdpSelect(cCDP)

    return

#include "./hb_agents_prompts.prg"
