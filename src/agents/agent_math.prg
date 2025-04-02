/*
                            _                         _    _
  __ _   __ _   ___  _ __  | |_     _ __ ___    __ _ | |_ | |__
 / _` | / _` | / _ \| '_ \ | __|   | '_ ` _ \  / _` || __|| '_ \
| (_| || (_| ||  __/| | | || |_    | | | | | || (_| || |_ | | | |
 \__,_| \__, | \___||_| |_| \__|   |_| |_| |_| \__,_| \__||_| |_|
        |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/

#include "hb_namespace.ch"

HB_NAMESPACE Agent_Math METHOD "GetAgents" POINTER @GetAgents(),;
                               "EvaluateExpression" POINTER @EvaluateExpression()

static function GetAgents()

    local oAgent as object
    //local oAgent_Math as object:=Agent_Math():New()

    oAgent:=TAgent():New(;
        "agent_math";
        ,{;
             {"evaluate",{|hParams| Agent_Math():Execute("EvaluateExpression",hParams)}};
        };
    )

    return(oAgent)

static function EvaluateExpression(hParams as hash)
    local cExpression as character
    if hb_HHasKey( hParams, "expression" ) .and. ! Empty( hParams[ "expression" ] )
        cExpression:=hParams[ "expression" ]
        return "The result of " + cExpression + " is " + hb_NToC( &cExpression )
    endif
    return "Failed to evaluate expression: no expression specified"
