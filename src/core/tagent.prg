/*
 _                               _
| |_   __ _   __ _   ___  _ __  | |_
| __| / _` | / _` | / _ \| '_ \ | __|
| |_ | (_| || (_| ||  __/| | | || |_
 \__| \__,_| \__,| \___||_| |_| \__|
             |___/

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/

#include "hbclass.ch"

CLASS TAgent

    DATA cCategory as character
    DATA cAgentPrompt as character
    DATA cAgentPurpose as character

    DATA hTools INIT {=>} as hash

    METHOD New(cCategory as character,cAgentPrompt as character,cAgentPurpose as character) as object
    METHOD aAddTool(cToolName as character,bToolAction as codeblock,hToolParameters as hash) as object

ENDCLASS

METHOD New(cCategory as character,cAgentPrompt as character,cAgentPurpose as character) CLASS TAgent
    self:cCategory:=cCategory
    hb_default(@cAgentPrompt,"")
    self:cAgentPrompt:=cAgentPrompt
    hb_default(@cAgentPurpose,cCategory)
    self:cAgentPurpose:=cAgentPurpose
    return(self) as object

METHOD aAddTool(cToolName as character,bToolAction as codeblock,hToolParameters as hash) CLASS TAgent
    cToolName:=Lower(allTrim(cToolName))
    hToolParameters["name"]:=Lower(allTrim(hToolParameters["name"]))
    self:hTools[cToolName]:={"action"=>bToolAction,"tool"=>hToolParameters}
    return(self)
