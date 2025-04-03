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

REQUEST HB_CODEPAGE_UTF8EX

// Enable debugging (hbmk2 -DDEBUG)

procedure Main()

    local cCDP as character

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cCDP:=hb_cdpSelect("UTF8EX")

    Execute()

    hb_cdpSelect(cCDP)

    return

static procedure Execute()

    local cPrompt as character
    local cResponse as character

    local oTAgent as object
    local oTLMStudio as object

    oTLMStudio:=TLMStudio():New()

    // Agent for showing the time
    oTAgent:=Agent_DateTime():Execute("GetAgents")
    aAdd(oTLMStudio:aAgents,oTAgent)

    // Agent for filesystem with multiple tools
    oTAgent:=Agent_Filesystem():Execute("GetAgents")
    aAdd(oTLMStudio:aAgents,oTAgent)

    // Agent for math calculations
    oTAgent:=Agent_Math():Execute("GetAgents")
    aAdd(oTLMStudio:aAgents,oTAgent)

    cPrompt:="What the current 'time' is it?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What 'date' is Today?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What the current 'date and time' is it?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="Create a folder named 'test'"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="Create a file called 'test.txt'"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="Modify the file 'test.txt' with content 'Hello World'"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="Delete the file 'test.txt'"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What is 2 + 2?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What is 2 - 2?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What is 2 x 2?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What is 2 / 2?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What is (2 ^ 2)^2?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)

    cPrompt:="What's the weather like?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)
    cResponse:=oTLMStudio:GetValue()
    DispOut("DEBUG: result: ","GR+/n")
    ? cResponse

    cPrompt:="What is Dom Pedro II's full name?"
    ? Replicate("=",MaxCol()),hb_eol()
    DispOut("DEBUG: Testing ","RB+/n")
    ? cPrompt,hb_eol()
    oTLMStudio:Send(cPrompt)
    cResponse:=oTLMStudio:GetValue()
    DispOut("DEBUG: result: ","GR+/n")
    ? cResponse

    oTLMStudio:End()

    return
