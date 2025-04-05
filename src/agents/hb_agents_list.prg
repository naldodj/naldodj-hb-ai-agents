/*
 _      _                                    _            _  _       _
| |__  | |__       __ _   __ _   ___  _ __  | |_  ___    | |(_) ___ | |_
| '_ \ | '_ \     / _` | / _` | / _ \| '_ \ | __|/ __|   | || |/ __|| __|
| | | || |_) |   | (_| || (_| ||  __/| | | || |_ \__ \   | || |\__ \| |_
|_| |_||_.__/     \__,_| \__, | \___||_| |_| \__||___/   |_||_||___/ \__|
                         |___/

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE hb_agents METHOD "GetAgents" POINTER @GetAgents()

static function GetAgents()

    local hAgents as hash:={=>}

    // Agent for showing the time
    hAgents["Agent_DateTime"]:={|cGetAgents as character|Agent_DateTime():Execute(cGetAgents)}

    // Agent for filesystem with multiple tools
    hAgents["Agent_Filesystem"]:={|cGetAgents as character|Agent_Filesystem():Execute(cGetAgents)}

    // Agent for math calculations
    hAgents["Agent_Math"]:={|cGetAgents as character|Agent_Math():Execute(cGetAgents)}

    // Agent for Date operations
    hAgents["Agent_DateDiff"]:={|cGetAgents as character|Agent_DateDiff():Execute(cGetAgents)}

    return(hAgents) as hash
