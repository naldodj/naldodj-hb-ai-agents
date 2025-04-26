/*
                            _           _         _              _  _   __   __
  __ _   __ _   ___  _ __  | |_      __| |  __ _ | |_   ___   __| |(_) / _| / _|
 / _` | / _` | / _ \| '_ \ | __|    / _` | / _` || __| / _ \ / _` || || |_ | |_
| (_| || (_| ||  __/| | | || |_    | (_| || (_| || |_ |  __/| (_| || ||  _||  _|
 \__,_| \__,| \___||_| |_| \__|    \__,_| \__,_| \__| \___| \__,_||_||_|  |_|
        |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/
#include "hb_namespace.ch"

HB_NAMESPACE Agent_DateDiff METHOD "GetAgents" POINTER @GetAgents(),;
                                   "DateDiffDay" POINTER @__DateDiffDay(),;
                                   "DateDiffMonth" POINTER @__DateDiffMonth(),;
                                   "DateDiffYear" POINTER @__DateDiffYear(),;
                                   "DateDiffYearMonthDay" POINTER @__DateDiffYearMonthDay(),;
                                   "DateAddDay" POINTER @__DateAddDay(),;
                                   "DateAddMonth" POINTER @__DateAddMonth(),;
                                   "DateAddYear" POINTER @__DateAddYear(),;
                                   "DateSubDay" POINTER @__DateSubDay(),;
                                   "DateSubMonth" POINTER @__DateSubMonth(),;
                                   "DateSubYear" POINTER @__DateSubYear()

static function GetAgents()

    local oTAgent as object

    local cAgentPrompt as character
    local cAgentPurpose as character

    local hTool as hash

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:**
Based on the user prompt `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, choose the tool that best matches the **date-related operation** described.
Available tools:
```json
__JSON_HTOOLS__
```
---
### 🛠️ Tool Descriptions:
- `date_diff_day`: Calculate the **number of days** between two dates.
- `date_diff_month`: Calculate the **number of full months** between two dates.
- `date_diff_year`: Calculate the **number of full years** between two dates.
- `date_diff_year_month_day`: Calculate the **full difference in years, months, and days** between two dates.
- `date_add_day`: Add a **number of days** to a specific date.
- `date_add_month`: Add a **number of months** to a specific date.
- `date_add_year`: Add a **number of years** to a specific date.
- `date_subtract_day`: Subtract a **number of days** from a specific date.
- `date_subtract_month`: Subtract a **number of months** from a specific date.
- `date_subtract_year`: Subtract a **number of years** from a specific date.
---
### 🧠 Interpretation Rules:
- If the prompt is about how much time has passed since an event, assume:
  - `date2 = event date`
  - `date1 = today`s date or now`
- Always use the format `"yyyy.mm.dd"` for dates (e.g., `"1970.12.15"`).
- Only return a JSON object (no explanation or extra text).
- Every tool **must** include all required parameters in the `"params"` object.
- For `date_diff_*` tools, both `date1` and `date2` or `date` and `value` are **mandatory**.
---
### ✅ Expected Output Format:
```json
{"tool":"<tool_name>","params":{...}}
```
---
### 🔍 JSON Examples:
```json
{"tool":"date_diff_day","params":{"date1":"2025.04.04","date2":"1970.12.15"}}
{"tool":"date_diff_month","params":{"date1":"2025.04.04","date2":"1970.12.15"}}
{"tool":"date_diff_year","params":{"date1":"2025.04.04","date2":"1970.12.15"}}
{"tool":"date_diff_year_month_day","params":{"date1":"2025.04.04","date2":"1970.12.15"}}

{"tool":"date_add_day","params":{"date":"2025.03.01","value":10}}
{"tool":"date_add_month","params":{"date":"2025.03.01","value":10}}
{"tool":"date_add_year","params":{"date":"2025.03.01","value":10}}

{"tool":"date_subtract_day","params":{"date":"2025.03.01","value":10}}
{"tool":"date_subtract_month","params":{"date":"2025.03.01","value":10}}
{"tool":"date_subtract_year","params":{"date":"2025.03.01","value":10}}
```
---
### 💡 Examples of prompt-to-tool mapping:
| User Prompt                                      | Expected Tool              |Contains Operator          |
|--------------------------------------------------|----------------------------|---------------------------|
| "How many days since 15/12/1970?"                | `date_diff_day`            |                           |
| "How many months between 1970.12.15 and today?"  | `date_diff_month`          |                           |
| "How many years since 1970.12.15?"               | `date_diff_year`           |                           |
| "Time difference from 1970.12.15 to 2025.04.04?" | `date_diff_year_month_day` |                           |
| "Add 10 days to 2025.03.01"                      | `date_add_day`             |`(+) add`                  |
| "What is date 01/03/2025 + 10 days?"             | `date_add_day`             |`(+) add`                  |
| "01/03/2025 + 10 days"                           | `date_add_day`             |`(+) add`                  |
| "Add 10 months to 2025.03.01"                    | `date_add_month`           |`(+) add`                  |
| "What is date 01/03/2025 + 10 months?"           | `date_add_month`           |`(+) add`                  |
| "01/03/2025 + 10 months"                         | `date_add_month`           |`(+) add`                  |
| "Add 10 years to 2025.03.01"                     | `date_add_year`            |`(+) add`                  |
| "What is date 01/03/2025 + 10 years?"            | `date_add_year`            |`(+) add`                  |
| "01/03/2025 + 10 years"                          | `date_add_year`            |`(+) add`                  |
| "Subtract 10 days from 2025.03.01"               | `date_subtract_day`        |`(-) subtract and day(s)`  |
| "What is date 01/03/2025 - 10 days?"             | `date_subtract_day`        |`(-) subtract and day(s)`  |
| "01/03/2025 - 10 days"                           | `date_subtract_day`        |`(-) subtract and day(s)`  |
| "Subtract 10 months from 2025.03.01"             | `date_subtract_month`      |`(-) subtract and month(s)`|
| "What is date 01/03/2025 - 10 months?"           | `date_subtract_month`      |`(-) subtract and month(s)`|
| "01/03/2025 - 10 months"                         | `date_subtract_month`      |`(-) subtract and month(s)`|
| "Subtract 10 years from 2025.03.01"              | `date_subtract_year`       |`(-) subtract and year(s)` |
| "What is date 01/03/2025 - 10 years?"            | `date_subtract_year`       |`(-) subtract and year(s)` |
| "01/03/2025 - 10 years"                          | `date_subtract_year`       |`(-) subtract and year(s)` |
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_datediff" provides tools for performing various date calculations,including finding differences between two dates and modifying a date by adding or subtracting specific time periods.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_DateDiff",cAgentPrompt,cAgentPurpose)

    hTool:={=>}
    hTool["name"] := "date_diff_day"
    hTool["description"] := "Calculate the **number of days** between two dates."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date1"] := {=>}
    hTool["inputSchema"]["properties"]["date1"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date1"]["description"] := "The first date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["date2"] := {=>}
    hTool["inputSchema"]["properties"]["date2"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date2"]["description"] := "The second date in ISO 8601 format"
    hTool["inputSchema"]["required"]:={"date1","date2"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_diff_day",{|hParams|Agent_DateDiff():Execute("DateDiffDay",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_diff_month"
    hTool["description"] := "Calculate the **number of full months** between two dates."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date1"] := {=>}
    hTool["inputSchema"]["properties"]["date1"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date1"]["description"] := "The first date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["date2"] := {=>}
    hTool["inputSchema"]["properties"]["date2"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date2"]["description"] := "The second date in ISO 8601 format"
    hTool["inputSchema"]["required"]:={"date1","date2"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_diff_month",{|hParams|Agent_DateDiff():Execute("DateDiffMonth",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_diff_year"
    hTool["description"] := "Calculate the **number of full years** between two dates."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date1"] := {=>}
    hTool["inputSchema"]["properties"]["date1"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date1"]["description"] := "The first date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["date2"] := {=>}
    hTool["inputSchema"]["properties"]["date2"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date2"]["description"] := "The second date in ISO 8601 format"
    hTool["inputSchema"]["required"]:={"date1","date2"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_diff_year",{|hParams|Agent_DateDiff():Execute("DateDiffYear",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_diff_year_month_day"
    hTool["description"] := "Calculate the **full difference in years, months, and days** between two dates."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date1"] := {=>}
    hTool["inputSchema"]["properties"]["date1"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date1"]["description"] := "The first date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["date2"] := {=>}
    hTool["inputSchema"]["properties"]["date2"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date2"]["description"] := "The second date in ISO 8601 format"
    hTool["inputSchema"]["required"]:={"date1","date2"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_diff_year_month_day",{|hParams|Agent_DateDiff():Execute("DateDiffYearMonthDay",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_add_day"
    hTool["description"] := "Add a **specific number of days** to a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of days to add"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_add_day",{|hParams|Agent_DateDiff():Execute("DateAddDay",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_add_month"
    hTool["description"] := "Add a **specific number of months** to a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of months to add"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_add_month",{|hParams|Agent_DateDiff():Execute("DateAddMonth",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_add_year"
    hTool["description"] := "Add a **specific number of years** to a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of years to add"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_add_year",{|hParams|Agent_DateDiff():Execute("DateAddYear",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_subtract_day"
    hTool["description"] := "Subtract a **specific number of days** from a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of days to subtract"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_subtract_day",{|hParams|Agent_DateDiff():Execute("DateSubDay",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_subtract_month"
    hTool["description"] := "Subtract a **specific number of months** from a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of months to subtract"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_subtract_month",{|hParams|Agent_DateDiff():Execute("DateSubMonth",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "date_subtract_year"
    hTool["description"] := "Subtract a **specific number of years** from a given date."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["date"] := {=>}
    hTool["inputSchema"]["properties"]["date"]["type"] := "string"
    hTool["inputSchema"]["properties"]["date"]["description"] := "The base date in ISO 8601 format"
    hTool["inputSchema"]["properties"]["value"] := {=>}
    hTool["inputSchema"]["properties"]["value"]["type"] := "integer"
    hTool["inputSchema"]["properties"]["value"]["description"] := "The number of years to subtract"
    hTool["inputSchema"]["required"]:={"date","value"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("date_subtract_year",{|hParams|Agent_DateDiff():Execute("DateSubYear",hParams)},hTool)

    return(oTAgent) as object

static function __DateDiffDay(hParams as hash)

    local cDate1 as character
    local cDate2 as character
    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffDay as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        cDate1:=Lower(hParams["date1"])
        if (("today"$cDate1).or.("now"$cDate1))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(cDate1,"yyyy.mm.dd")
        endif
        cDate2:=Lower(hParams["date2"])
        if (("today"$cDate2).or.("now"$cDate2))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(cDate2,"yyyy.mm.dd")
        endif
        nDiffDay:=DateDiffDay(@dDate1,@dDate2)
        cMessage:="The difference,in days,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffDay)
    else
        cMessage:="Unable to calculate difference in days"
    endif

    return(cMessage) as character

static function __DateDiffMonth(hParams as hash)

    local cDate1 as character
    local cDate2 as character
    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffMonth as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        cDate1:=Lower(hParams["date1"])
        if (("today"$cDate1).or.("now"$cDate1))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(cDate1,"yyyy.mm.dd")
        endif
        cDate2:=Lower(hParams["date2"])
        if (("today"$cDate2).or.("now"$cDate2))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(cDate2,"yyyy.mm.dd")
        endif
        nDiffMonth:=DateDiffMonth(@dDate1,@dDate2)
        cMessage:="The difference,in months,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffMonth)
    else
        cMessage:="Unable to calculate difference in months"
    endif

    return(cMessage) as character

static function __DateDiffYear(hParams as hash)

    local cDate1 as character
    local cDate2 as character
    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffYear as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        cDate1:=Lower(hParams["date1"])
        if (("today"$cDate1).or.("now"$cDate1))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(cDate1,"yyyy.mm.dd")
        endif
        cDate2:=Lower(hParams["date2"])
        if (("today"$cDate2).or.("now"$cDate2))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(cDate2,"yyyy.mm.dd")
        endif
        nDiffYear:=DateDiffYear(@dDate1,@dDate2)
        cMessage:="The difference,in years,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffYear)
    else
        cMessage:="Unable to calculate difference in years"
    endif

    return(cMessage) as character

static function __DateDiffYearMonthDay(hParams as hash)

    local cDate1 as character
    local cDate2 as character
    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local hDiffYearMonthDay as hash

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        cDate1:=Lower(hParams["date1"])
        if (("today"$cDate1).or.("now"$cDate1))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(cDate1,"yyyy.mm.dd")
        endif
        cDate2:=Lower(hParams["date2"])
        if (("today"$cDate2).or.("now"$cDate2))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(cDate2,"yyyy.mm.dd")
        endif
        hDiffYearMonthDay:=DateDiffYearMonthDay(@dDate1,@dDate2)
        cMessage:="The difference,in years,months,and days,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+;
               hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(hDiffYearMonthDay["years"])+" years,"+;
               hb_NToC(hDiffYearMonthDay["months"])+" months,"+hb_NToC(hDiffYearMonthDay["days"])+" days"
    else
        cMessage:="Unable to calculate difference in years,months,and days"
    endif

    return(cMessage) as character

static function __DateAddDay(hParams as hash)

    local cMessage as character

    local dDate as date

    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateAddDay(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to add days"
    endif

    return(cMessage) as character

static function __DateSubDay(hParams as hash)

    local cMessage as character

    local dDate as date

    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateSubDay(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to subtract days"
    endif

    return(cMessage) as character

static function __DateAddMonth(hParams as hash)

    local cMessage as character

    local dDate as date

    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateAddMonth(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to add months"
    endif

    return(cMessage) as character

static function __DateSubMonth(hParams as hash)

    local cMessage as character

    local dDate as date
    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateSubMonth(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to subtract months"
    endif

    return(cMessage) as character

static function __DateAddYear(hParams as hash)

    local cMessage as character

    local dDate as date

    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateAddYear(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to add years"
    endif

    return(cMessage) as character

static function __DateSubYear(hParams as hash)

    local cMessage as character

    local dDate as date

    local nValue as numeric

    if (;
            (hb_HHasKey(hParams,"date").and.!Empty(hParams["date"]));
            .and.;
            (hb_HHasKey(hParams,"value").and.!Empty(hParams["value"]));
        )
        dDate:=hb_CToD(hParams["date"],"yyyy.mm.dd")
        nValue:=if(ValType(hParams["value"])=="N",hParams["value"],hb_Val(hParams["value"]))
        dDate:=DateSubYear(dDate,nValue)
        cMessage:="The new date is "+hb_DToC(dDate,"yyyy.mm.dd")
    else
        cMessage:="Unable to subtract years"
    endif

    return(cMessage) as character

*******************************************************************************************************************************
static function DateDiffDay(dDate1,dDate2)
    FixDateOrder(@dDate1,@dDate2)
    return((dDate1-dDate2)) as numeric

static function DateDiffMonth(dDate1,dDate2)

    local nMonths as numeric
    local nMonth1 as numeric
    local nMonth2 as numeric

    FixDateOrder(@dDate1,@dDate2)

    nMonth1:=((Year(dDate1)*12)+Month(dDate1))
    nMonth2:=((Year(dDate2)*12)+Month(dDate2))
    nMonths:=(nMonth1-nMonth2)
    if (Day(dDate1)-Day(dDate2)>Day(EoM(dDate1)))
        ++nMonths
    endif

    return(nMonths) as numeric

static function DateDiffYear(dDate1 as date,dDate2 as date)

    local nMonth1 as numeric
    local nMonth2 as numeric
    local nDiffYear as numeric

    FixDateOrder(@dDate1,@dDate2)

    nMonth1:=((Year(dDate1)*12)+Month(dDate1))
    nMonth2:=((Year(dDate2)*12)+Month(dDate2))
    nDiffYear:=((nMonth1-nMonth2)-1)
    if (Day(dDate1)>=Day(dDate2))
        ++nDiffYear
    endif
    nDiffYear/=12
    nDiffYear:=Int(nDiffYear)

    return(nDiffYear) as numeric

static function DateDiffYearMonthDay(dDate1,dDate2)

    local nYears
    local nMonths
    local nDays

    nYears:=DateDiffYear(@dDate1,@dDate2)
    nMonths:=DateDiffMonth(dDate1,dDate2)
    nMonths-=(nYears*12)
    if (Left(DToS(dDate1),6)<>Left(DToS(dDate2),6))
        if (dDate1>dDate2)
            if Day(dDate1)<Day(dDate2)
                nDays:=(Day(dDate1)+30)-Day(dDate2)
                nMonths-=1
                if (nMonths<0)
                    nMonths:=0
                endif
            else
                nDays:=Day(dDate1)-Day(dDate2)
            endif
        else
            if (Day(dDate1)>Day(dDate2))
                nDays:=(Day(dDate2)+30)-Day(dDate1)
                nMonths-=1
                if (nMonths<0)
                    nMonths:=0
                endif
            else
                nDays:=Day(dDate2)-Day(dDate1)
            endif
        endif
    else
        nDays:=DateDiffDay(dDate1,dDate2)
    endif

    return({"years"=>nYears,"months"=>nMonths,"days"=>nDays}) as hash

static function DateAddDay(dDate,nDays)
    return((dDate+=nDays)) as date

static function DateSubDay(dDate,nDays)
    return((dDate-=nDays)) as date

static function DateAddMonth(dDate,nMonth)
    return(AddMonth(dDate,nMonth)) as date

static function DateSubMonth(dDate,nMonth)
    return(AddMonth(dDate,-(nMonth))) as date

static function DateAddYear(dDate,nYear)
    return(AddMonth(dDate,(nYear*12))) as date

static function DateSubYear(dDate,nYear)
    return(AddMonth(dDate,-(nYear*12))) as date

static procedure FixDateOrder(/*@*/dDate1,/*@*/dDate2)

    local dTmp as date

    if (dDate2>dDate1)
        dTmp:=dDate2
        dDate2:=dDate1
        dDate1:=dTmp
    endif

    return
