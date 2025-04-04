/*
                            _           _         _              _  _   __   __
  __ _   __ _   ___  _ __  | |_      __| |  __ _ | |_   ___   __| |(_) / _| / _|
 / _` | / _` | / _ \| '_ \ | __|    / _` | / _` || __| / _ \ / _` || || |_ | |_
| (_| || (_| ||  __/| | | || |_    | (_| || (_| || |_ |  __/| (_| || ||  _||  _|
 \__,_| \__,| \___||_| |_| \__|    \__,_| \__,_| \__| \___| \__,_||_||_|  |_|
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

    local hParameters as hash

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, choose the best matching tool from:
```json
__JSON_HTOOLS__
```
### Tool Options:
- `date_diff_day`: days between two dates.
- `date_diff_month`: months between two dates.
- `date_diff_year`: years between two dates.
- `date_diff_year_month_day`: years, months, and days between two dates.
- `date_add_day`: add days to a date.
- `date_add_month`: add months to a date.
- `date_add_year`: add years to a date.
- `date_subtract_day`: subtract days from a date.
- `date_subtract_month`: subtract months from a date.
- `date_subtract_year`: subtract years from a date.
### Rules:
- For historical events, use the event date as `date2` and today’s date as `date1`.
- Use date format `"yyyy.mm.dd"` (e.g., 15/12/1970 → "1970.12.15").
### Output:
Return only a JSON object:
```json
{"tool":"<tool_name>","params":{...}}
```
### Examples:
- “How many days since...” → `date_diff_day`
- “What is 2025.03.01 + 10 days?” → `date_add_day`
- “What is 2025.03.01 - 10 years?” → `date_subtract_year`
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_datediff" provides tools for performing various date calculations,including finding differences between two dates and modifying a date by adding or subtracting specific time periods.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_DateDiff",cAgentPrompt,cAgentPurpose)

    hParameters:={"params"=>{"date1","date2"}}
    oTAgent:aAddTool("date_diff_day",{|hParams|Agent_DateDiff():Execute("DateDiffDay",hParams)},hParameters)
    oTAgent:aAddTool("date_diff_month",{|hParams|Agent_DateDiff():Execute("DateDiffMonth",hParams)},hParameters)
    oTAgent:aAddTool("date_diff_year",{|hParams|Agent_DateDiff():Execute("DateDiffYear",hParams)},hParameters)
    oTAgent:aAddTool("date_diff_year_month_day",{|hParams|Agent_DateDiff():Execute("DateDiffYearMonthDay",hParams)},hParameters)

    hParameters:={"params"=>{"date","value"}}
    oTAgent:aAddTool("date_add_day",{|hParams|Agent_DateDiff():Execute("DateAddDay",hParams)},hParameters)
    oTAgent:aAddTool("date_add_month",{|hParams|Agent_DateDiff():Execute("DateAddMonth",hParams)},hParameters)
    oTAgent:aAddTool("date_add_year",{|hParams|Agent_DateDiff():Execute("DateAddYear",hParams)},hParameters)
    oTAgent:aAddTool("date_subtract_day",{|hParams|Agent_DateDiff():Execute("DateSubDay",hParams)},hParameters)
    oTAgent:aAddTool("date_subtract_month",{|hParams|Agent_DateDiff():Execute("DateSubMonth",hParams)},hParameters)
    oTAgent:aAddTool("date_subtract_year",{|hParams|Agent_DateDiff():Execute("DateSubYear",hParams)},hParameters)

    return(oTAgent) as object

static function __DateDiffDay(hParams as hash)

    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffDay as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        if ("today"$Lower(hParams["date1"]))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(hParams["date1"],"yyyy.mm.dd")
        endif
        if ("today"$Lower(hParams["date2"]))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(hParams["date2"],"yyyy.mm.dd")
        endif
        nDiffDay:=DateDiffDay(@dDate1,@dDate2)
        cMessage:="The difference,in days,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffDay)
    else
        cMessage:="Unable to calculate difference in days"
    endif

    return(cMessage) as character

static function __DateDiffMonth(hParams as hash)

    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffMonth as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        if ("today"$Lower(hParams["date1"]))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(hParams["date1"],"yyyy.mm.dd")
        endif
        if ("today"$Lower(hParams["date2"]))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(hParams["date2"],"yyyy.mm.dd")
        endif
        nDiffMonth:=DateDiffMonth(@dDate1,@dDate2)
        cMessage:="The difference,in months,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffMonth)
    else
        cMessage:="Unable to calculate difference in months"
    endif

    return(cMessage) as character

static function __DateDiffYear(hParams as hash)

    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local nDiffYear as numeric

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        if ("today"$Lower(hParams["date1"]))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(hParams["date1"],"yyyy.mm.dd")
        endif
        if ("today"$Lower(hParams["date2"]))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(hParams["date2"],"yyyy.mm.dd")
        endif
        nDiffYear:=DateDiffYear(@dDate1,@dDate2)
        cMessage:="The difference,in years,between the dates "+hb_DToC(dDate1,"yyyy.mm.dd")+" and "+hb_DToC(dDate2,"yyyy.mm.dd")+" is: "+hb_NToC(nDiffYear)
    else
        cMessage:="Unable to calculate difference in years"
    endif

    return(cMessage) as character

static function __DateDiffYearMonthDay(hParams as hash)

    local cMessage as character

    local dDate1 as date
    local dDate2 as date

    local hDiffYearMonthDay as hash

    if (;
            (hb_HHasKey(hParams,"date1").and.!Empty(hParams["date1"]));
            .and.;
            (hb_HHasKey(hParams,"date2").and.!Empty(hParams["date2"]));
        )
        if ("today"$Lower(hParams["date1"]))
            dDate1:=Date()
        else
            dDate1:=hb_CToD(hParams["date1"],"yyyy.mm.dd")
        endif
        if ("today"$Lower(hParams["date2"]))
            dDate2:=Date()
        else
            dDate2:=hb_CToD(hParams["date2"],"yyyy.mm.dd")
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

    local dTmp as date

    if (dDate2>dDate1)
        dTmp:=dDate2
        dDate2:=dDate1
        dDate1:=dTmp
    endif

    return((dDate1-dDate2)) as numeric

static function DateDiffMonth(dDate1,dDate2)

    local dTmp as date

    local nMonths as numeric
    local nMonth1 as numeric
    local nMonth2 as numeric

    if (dDate2>dDate1)
        dTmp:=dDate2
        dDate2:=dDate1
        dDate1:=dTmp
    endif

    nMonth1:=((Year(dDate1)*12)+Month(dDate1))
    nMonth2:=((Year(dDate2)*12)+Month(dDate2))
    nMonths:=(nMonth1-nMonth2)
    if (Day(dDate1)-Day(dDate2)>Day(EoM(dDate1)))
        ++nMonths
    endif

    return(nMonths) as numeric

static function DateDiffYear(dDate1 as date,dDate2 as date)

    local dTmp as date

    local nMonth1 as numeric
    local nMonth2 as numeric
    local nDiffYear as numeric

    if (dDate2>dDate1)
        dTmp:=dDate2
        dDate2:=dDate1
        dDate2:=dTmp
    endif

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
