/*
Released to Public Domain.
--------------------------------------------------------------------------------------
*/
static procedure ExecutePrompts(cModel,cURL)

    local aPrompts as array:=Array(0)

    local cEoL as character:=hb_eol()
    local cLine as character
    local cToday as character:=hb_DToC(Date(),"yyyy.mm.dd")
    local cPrompt as character
    local cResponse as character
    local cSeparator as character:=Replicate("=",MaxCol())+cEoL

    local hAgent as hash
    local hAgents as hash

    local nPrompt

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

    if (hb_FileExists("./hb_agents_prompts.txt"))
        for each cLine in hb_ATokens(MemoRead("./hb_agents_prompts.txt"),.T.)
            if (Empty(cLine))
                loop
            endif
            aAdd(aPrompts,cLine)
        next each //cLine
    endif

    hAgents:=hb_agents():Execute("GetAgents")

    ? cSeparator

    WITH OBJECT TOLLama():New(cModel,cURL)

        DispOut("DEBUG: Model: ","RB+/n")
        ?  :cModel ,cEoL

        ? cSeparator
        DispOut("DEBUG: Agents: ","RB+/n")

        for each hAgent in hAgents
            ? hAgent:__enumKey()
            :AddAgent(hAgent:__enumValue():Eval("GetAgents"))
        next each //hAgent

        for nPrompt:=1 to Len(aPrompts)
            cPrompt:=aPrompts[nPrompt]
            ? cSeparator
            DispOut("DEBUG Model: ["+cModel+"] Testing : ","RB+/n")
            ? cPrompt,cEoL
            :Send(cPrompt)
            #ifndef DEBUG
                cResponse:=:GetResponseValue()
                ? cResponse
            #endif
            if (:cCategory=="general")
                cResponse:=:GetResponseValue()
                DispOut("DEBUG Model: ["+cModel+"] result: ","GR+/n")
                ? cResponse
            endif
        next nPrompt

        :End()

    END WITH

    return
