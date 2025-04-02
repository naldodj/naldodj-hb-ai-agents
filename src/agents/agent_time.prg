/*
                            _       _    _
  __ _   __ _   ___  _ __  | |_    | |_ (_) _ __ ___    ___
 / _` | / _` | / _ \| '_ \ | __|   | __|| || '_ ` _ \  / _ \
| (_| || (_| ||  __/| | | || |_    | |_ | || | | | | ||  __/
 \__,_| \__, | \___||_| |_| \__|    \__||_||_| |_| |_| \___|
        |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE Agent_Time METHOD "GetAgents" POINTER @GetAgents(),;
                               "GetCurrentTime" POINTER @GetCurrentTime()

static function GetAgents()

    local oAgent as object
    //local oAgent_Time as object:=Agent_Time():New()

    oAgent:=TAgent():New(;
        "agent_time";
        ,{;
             {"get_time",{|hParams| Agent_Time():Execute("GetCurrentTime",hParams)}};
        };
    )

    return(oAgent)

static function GetCurrentTime(hParams as hash)
    local cTime as character:=Time()
    HB_SYMBOL_UNUSED(hParams)
    return "The current time is " + cTime
