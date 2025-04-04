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

    local cAgentPrompt as character
    local cAgentPurpose as character

    local hParameters as hash

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, select the best matching tool from:
```json
__JSON_HTOOLS__
```
### Rules:
- Identify the intent from the prompt.
- Choose the tool accordingly.
- Extract required values (e.g., `expression`) and map them using exact parameter names.
### Output:
Return only a JSON object:
```json
{"tool":"<tool_name>","params":{"<param_name>":"<value>"}}
```
### Examples:
- "What is 2 + 2?" →
  ```json
  {"tool":"evaluate","params":{"expression":"2+2"}}
  ```
- "What is 2 x 2?" →
  ```json
  {"tool":"evaluate","params":{"expression":"2*2"}}
  ```
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_math" provides tools for performing basic mathematical operations by evaluating user-provided expressions. It is designed to handle fundamental arithmetic tasks such as addition, subtraction, multiplication, division, and exponentiation, making it a straightforward solution for quick calculations.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_Math",cAgentPrompt,cAgentPurpose)

    hParameters:={"params"=>["expression"]}
    oTAgent:aAddTool("evaluate",{|hParams|Agent_Math():Execute("EvaluateExpression",hParams)},hParameters)

    return(oTAgent)

static function EvaluateExpression(hParams as hash)
    local cMessage as character
    local cExpression as character
    if (hb_HHasKey(hParams,"expression").and.!Empty(hParams["expression"]))
        cExpression:=hb_StrReplace(hParams["expression"],{"x"=>"*","X"=>"*"})
        cMessage:="The result of "+cExpression+" is "+hb_NToC(&cExpression)
    else
        cMessage:="Failed to evaluate expression: no expression specified"
    endif
    return(cMessage)
