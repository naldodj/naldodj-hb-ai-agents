/*
                            _           _         _          _    _
  __ _   __ _   ___  _ __  | |_      __| |  __ _ | |_   ___ | |_ (_) _ __ ___    ___
 / _` | / _` | / _ \| '_ \ | __|    / _` | / _` || __| / _ \| __|| || '_ ` _ \  / _ \
| (_| || (_| ||  __/| | | || |_    | (_| || (_| || |_ |  __/| |_ | || | | | | ||  __/
 \__,_| \__, | \___||_| |_| \__|    \__,_| \__,_| \__| \___| \__||_||_| |_| |_| \___|
        |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE Agent_DateTime METHOD "GetAgents" POINTER @GetAgents(),;
                                   "GetCurrentTime" POINTER @GetCurrentTime(),;
                                   "GetCurrentDate" POINTER @GetCurrentDate(),;
                                   "GetCurrentDateTime" POINTER @GetCurrentDateTime()

static function GetAgents()

    local oTAgent as object

    local cAgentPrompt as character
    local cAgentPurpose as character

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, select the best-matching tool from:
```json
__JSON_HTOOLS__
```
### Tool logic:
- `"get_current_time"` → if prompt asks for time only (mentions "time" but not "date")
- `"get_current_date"` → if prompt asks for date only (mentions "date" but not "time")
- `"get_current_date_time"` → if prompt asks for both date and time
### Output:
Return only a JSON object:
```json
{"tool":"<tool_name>","params":{}}
```
### Examples:
- "What time is it?" →
  ```json
  {"tool":"get_current_time","params":{}}
  ```
- "What date is it?" →
  ```json
  {"tool":"get_current_date","params":{}}
  ```
- "What date and time is it?" →
  ```json
  {"tool":"get_current_date_time","params":{}}
  ```
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_datetime" provides tools for retrieving the current date and time in various formats. It is designed to handle requests for the current time, date, or both, depending on the user's prompt.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_DateTime",cAgentPrompt,cAgentPurpose)

    oTAgent:aAddTool("get_current_time",{|hParams|Agent_DateTime():Execute("GetCurrentTime",hParams)})
    oTAgent:aAddTool("get_current_date",{|hParams|Agent_DateTime():Execute("GetCurrentDate",hParams)})
    oTAgent:aAddTool("get_current_date_time",{|hParams|Agent_DateTime():Execute("GetCurrentDateTime",hParams)})

    return(oTAgent)

static function GetCurrentTime(hParams as hash)
    local cTime as character:=Time()
    HB_SYMBOL_UNUSED(hParams)
    return("The current time is "+cTime)

static function GetCurrentDate(hParams as hash)
    local dDate as date:=Date()
    HB_SYMBOL_UNUSED(hParams)
    return("The current date is "+hb_DToC(dDate,"yyyy.mm.dd"))

static function GetCurrentDateTime(hParams as hash)
    local tTimeStamp as datetime:=hb_DateTime()
    HB_SYMBOL_UNUSED(hParams)
    return("The current date and time is "+hb_TSToSTR(tTimeStamp,.T.))
