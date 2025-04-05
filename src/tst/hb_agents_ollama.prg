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

    local cCDP as character

    CLS

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cCDP:=hb_cdpSelect("UTF8EX")

    Execute()

    hb_cdpSelect(cCDP)

    return

static procedure Execute()

    local aPrompts as array:=Array(0)

    local cEoL as character:=hb_eol()
    local cToday as character:=hb_DToC(Date(),"yyyy.mm.dd")
    local cPrompt as character
    local cResponse as character
    local cSeparator as character:=Replicate("=",MaxCol())+cEoL

    local hAgent
    local hAgents as hash

    local nPrompt

    aAdd(aPrompts,"What the current 'time' is it?")
    aAdd(aPrompts,"What 'date' is Today?")
    aAdd(aPrompts,"What the current 'date and time' is it?")

    aAdd(aPrompts,"Create a folder named 'test'")
    aAdd(aPrompts,"Create a file called './test/test.txt'")
    aAdd(aPrompts,"Modify the file './test/test.txt' with content 'Hello World'")
    aAdd(aPrompts,"Delete the file './test/test.txt'")

    aAdd(aPrompts,"What is 2 + 8?")
    aAdd(aPrompts,"What is 10 - 2?")
    aAdd(aPrompts,"What is 8 x 5?")
    aAdd(aPrompts,"What is 15 / 5?")
    aAdd(aPrompts,"What is (2 ^ 4)^2?")

    aAdd(aPrompts,"Today is "+cToday+". How many days have passed since the proclamation of the Republic in Brazil on 15/11/1889 until today")
    aAdd(aPrompts,"Today is "+cToday+". How many months have passed since the proclamation of the Republic in Brazil on 15/11/1889 until today?")
    aAdd(aPrompts,"Today is "+cToday+". How many years have passed since the proclamation of the Republic in Brazil on 15/11/1889 until today?")
    aAdd(aPrompts,"Today is "+cToday+". How many years, months, and days have passed since the proclamation of the Republic in Brazil on 15/11/1889 until today?")

    aAdd(aPrompts,"What is date "+cToday+" + 10 days?")
    aAdd(aPrompts,"What is date "+cToday+" - 10 days?")
    aAdd(aPrompts,"What is date "+cToday+" + 10 months?")
    aAdd(aPrompts,"What is date "+cToday+" - 10 months?")
    aAdd(aPrompts,"What is date "+cToday+" + 10 years?")
    aAdd(aPrompts,"What is date "+cToday+" - 10 years?")

    hAgents:=hb_agents():Execute("GetAgents")

    WITH OBJECT TOLLama():New()

        DispOut("DEBUG: Model: ","RB+/n")
        ? :cModel,cEoL

        ? cSeparator
        DispOut("DEBUG: Agents: ","RB+/n")

        for each hAgent in hAgents
            ? hAgent:__enumKey()
            :AddAgent(hAgent:__enumValue():Eval("GetAgents"))
        next each //hAgent

        for nPrompt:=1 to Len(aPrompts)
            cPrompt:=aPrompts[nPrompt]
            ? cSeparator
            DispOut("DEBUG: Testing ","RB+/n")
            ? cPrompt,cEoL
            :Send(cPrompt)
        next nPrompt

        cPrompt:="What's the weather like?"
        ? cSeparator
        DispOut("DEBUG: Testing ","RB+/n")
        ? cPrompt,cEoL
        :Send(cPrompt)
        cResponse:=:GetValue()
        DispOut("DEBUG: result: ","GR+/n")
        ? cResponse

        cPrompt:="What is Dom Pedro II's full name?"
        ? cSeparator
        DispOut("DEBUG: Testing ","RB+/n")
        ? cPrompt,cEoL
        :Send(cPrompt)
        cResponse:=:GetValue()
        DispOut("DEBUG: result: ","GR+/n")
        ? cResponse

        :End()

    END WITH

    return
