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
    DATA cMessage as character
    DATA cCategory as character
    DATA hTools INIT {=>} as hash
    METHOD New(cCategory as character,cMessage as character) as object
    METHOD aAddTool(cToolName as character,bToolAction as codeblock,hToolParameters as hash) as object
ENDCLASS

METHOD New(cCategory as character,cMessage as character) CLASS TAgent
    self:cCategory:=cCategory
    hb_default(@cMessage,"")
    self:cMessage:=cMessage
    return(self) as object

METHOD aAddTool(cToolName as character,bToolAction as codeblock,hToolParameters as hash) CLASS TAgent
    cToolName:=Lower(allTrim(cToolName))
    hb_Default(@hToolParameters,{"params"=>[""]})
    self:hTools[cToolName]:={"action"=>bToolAction,"parameters"=>hToolParameters}
    return(self)
