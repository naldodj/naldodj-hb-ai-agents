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
    local oAgent as object
    local oLLama as object

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cCDP:=hb_cdpSelect("UTF8EX")

    oLLama:=ToLLama():New()

    // Agent for showing the time
    oAgent:=Agent_Time():Execute("GetAgents")
    aAdd(oLLama:aAgents,oAgent)

    // Agent for filesystem with multiple tools
    oAgent:=Agent_Filesystem():Execute("GetAgents")
    aAdd(oLLama:aAgents,oAgent)

    // Agent for math calculations
    oAgent:=Agent_Math():Execute("GetAgents")
    aAdd(oLLama:aAgents,oAgent)

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'What time is it?'","g+/n")
    #endif
    oLLama:Send("What time is it?")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'Create a folder named test'","g+/n")
    #endif
    oLLama:Send("Create a folder named 'test'")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'Create a file called test.txt'","g+/n")
    #endif
    oLLama:Send("Create a file called 'test.txt'")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'Modify the file test.txt with content Hello World'","g+/n")
    #endif
    oLLama:Send("Modify the file test.txt with content Hello World")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'Delete the file test.txt'","g+/n")
    #endif
    oLLama:Send("Delete the file 'test.txt'")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'What is 2 + 2?'","g+/n")
    #endif
    oLLama:Send("What is 2 + 2?")

    #ifdef DEBUG
        ? Replicate("=",MaxCol())
        ? "DEBUG: Testing "
        DispOut("'What’s the weather like?'","g+/n")
    #endif
    oLLama:Send("What's the weather like?")

    oLLama:End()

    hb_cdpSelect(cCDP)

    return
