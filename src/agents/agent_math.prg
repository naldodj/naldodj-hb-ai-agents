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

    local oTAgent as object

    local cMessage as character

    #pragma __cstream|cMessage:=%s
Based on this prompt: '__PROMPT__' and category '__AGENT_CATEGORY__',
select the appropriate tool from the following list: ```json __JSON_HTOOLS__```,
Analyze the prompt and choose the tool that best matches its intent:
Return a JSON object with 'tool' (the tool name) and 'params'.
Provide only a JSON object containing 'tool' (the tool name) and 'params' (an empty object, as no parameters are required), with no additional text or explanation.
Examples:
- For "What is 2 + 2?": {"tool":"evaluate","params":{"expression":"2+2"}}
- For "What is 2 * 2?": {"tool":"evaluate","params":{"expression":"2*2"}}
- For "What is 2 x 2?": {"tool":"evaluate","params":{"expression":"2*2"}}
- For "What is 2 / 2?": {"tool":"evaluate","params":{"expression":"2/2"}}
- For "What is 2 - 2?": {"tool":"evaluate","params":{"expression":"2-2"}}
- For "What is 2 ^ 2?": {"tool":"evaluate","params":{"expression":"2^2"}}
    #pragma __endtext

    oTAgent:=TAgent():New(;
        "agent_math";
        ,{;
             {"evaluate",{|hParams|Agent_Math():Execute("EvaluateExpression",hParams)},{"params" => ["expression"]}};
        };
        ,cMessage;
   )

    return(oTAgent)

static function EvaluateExpression(hParams as hash)
    local cExpression as character
    if hb_HHasKey(hParams, "expression") .and. !Empty(hParams["expression"])
        cExpression:=hb_StrReplace(hParams["expression"],{"x"=>"*","X"=>"*"})
        return "The result of " + cExpression + " is " + hb_NToC(&cExpression)
    endif
    return "Failed to evaluate expression: no expression specified"
