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

HB_NAMESPACE Agent_DateTime METHOD "GetAgents" POINTER @GetAgents(),;
                                   "GetCurrentTime" POINTER @GetCurrentTime(),;
                                   "GetCurrentDate" POINTER @GetCurrentDate(),;
                                   "GetCurrentDateTime" POINTER @GetCurrentDateTime()

static function GetAgents()

    local oTAgent as object

    local cMessage as character

    #pragma __cstream|cMessage:=%s
Based on this prompt: '__PROMPT__' and category '__AGENT_CATEGORY__',
select the appropriate tool from the following list: ```json __JSON_HTOOLS__```,
where:
- "get_current_time" returns only the current time (e.g., "23:25:21"),
- "get_current_date" returns only the current date (e.g., "2025-04-02"),
- "get_current_date_time" returns both the current date and time (e.g., "2025-04-02 23:25:21").
Analyze the prompt and choose the tool that best matches its intent:
- Use "get_current_time" if the prompt asks only for the time (e.g., contains "time" but not "date"),
- Use "get_current_date" if the prompt asks only for the date (e.g., contains "date" but not "time"),
- Use "get_current_date_time" if the prompt asks for both date and time (e.g., contains "date and time" or similar).
Return a JSON object with 'tool' (the tool name) and 'params' (an empty hash, as no parameters are required).
Examples:
- For "What time is it?": {"tool":"get_current_time","params":{}}
- For "What the current time is it?": {"tool":"get_current_time","params":{}}
- For "What date is it?": {"tool":"get_current_date","params":{}}
- For "What the current date is it?": {"tool":"get_current_date","params":{}}
- For "What date and time is it?": {"tool":"get_current_date_time","params":{}}
- For "What the current date and time is it?": {"tool":"get_current_date_time","params":{}}
    #pragma __endtext

    oTAgent:=TAgent():New(;
        "agent_datetime";
        ,{;
             {"get_current_time",{|hParams|Agent_DateTime():Execute("GetCurrentTime",hParams)},{"params"=>[""]}};
            ,{"get_current_date",{|hParams|Agent_DateTime():Execute("GetCurrentDate",hParams)},{"params"=>[""]}};
            ,{"get_current_date_time",{|hParams|Agent_DateTime():Execute("GetCurrentDateTime",hParams)},{"params"=>[""]}};
        };
        ,cMessage;
   )

    return(oTAgent)

static function GetCurrentTime(hParams as hash)
    local cTime as character:=Time()
    HB_SYMBOL_UNUSED(hParams)
    return "The current time is " + cTime

static function GetCurrentDate(hParams as hash)
    local dDate as date:=Date()
    HB_SYMBOL_UNUSED(hParams)
    return "The current date is " + hb_DToC(dDate, "yyyy.mm.dd")

static function GetCurrentDateTime(hParams as hash)
    local tTimeStamp as datetime:=hb_DateTime()
    HB_SYMBOL_UNUSED(hParams)
    return "The current date and time is " + hb_TSToSTR(tTimeStamp,.T.)
