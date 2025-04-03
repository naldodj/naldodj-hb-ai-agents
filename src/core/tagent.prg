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
    DATA aTools as array
    METHOD New(cCategory as character,aTools as array,cMessage as character) as object
ENDCLASS

METHOD New(cCategory as character,aTools as array,cMessage as character) CLASS TAgent
    ::cCategory:=cCategory
    ::aTools:=aTools
    hb_default(@cMessage,"")
    ::cMessage:=cMessage
return(self) as object
