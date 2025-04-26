/*
                            _                         _    _
  __ _   __ _   ___  _ __  | |_     _ __ ___    __ _ | |_ | |__
 / _` | / _` | / _ \| '_ \ | __|   | '_ ` _ \  / _` || __|| '_ \
| (_| || (_| ||  __/| | | || |_    | | | | | || (_| || |_ | | | |
 \__,_| \__, | \___||_| |_| \__|   |_| |_| |_| \__,_| \__||_| |_|
        |___/

Obs.: Extra math functions that require linking with -lm?

Ref.: FiveTech Software tech support forums
https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g

Released to Public Domain.
--------------------------------------------------------------------------------------
*/

#require "hbct"

/*
  hbtest:
  Alternative solution to correctly obtain mathematical functions according to examples obtained in /hbct/tests/math.prg and /hbct/tests/test.prg.
  How can I make the system recognize them without this?
*/
#require "hbtest"

#include "error.ch"
#include "hb_namespace.ch"

HB_NAMESPACE Agent_Math METHOD "GetAgents" POINTER @GetAgents(),;
                               "SQRT" POINTER @EvaluateExpression(),;
                               "EXP" POINTER @EvaluateExpression(),;
                               "LOG" POINTER @EvaluateExpression(),;
                               "ABS" POINTER @EvaluateExpression(),;
                               "ROUND" POINTER @EvaluateExpression(),;
                               "SIN" POINTER @EvaluateExpression(),;
                               "COS" POINTER @EvaluateExpression(),;
                               "TAN" POINTER @EvaluateExpression(),;
                               "INT" POINTER @EvaluateExpression(),;
                               "PLUS" POINTER @EvaluateExpression(),;
                               "MINUS" POINTER @EvaluateExpression(),;
                               "TIMES" POINTER @EvaluateExpression(),;
                               "DIVIDEBY" POINTER @EvaluateExpression(),;
                               "POWEROF" POINTER @EvaluateExpression(),;
                               "FLOOR" POINTER @EvaluateExpression(),;
                               "CEILING" POINTER @EvaluateExpression(),;
                               "SIGN" POINTER @EvaluateExpression(),;
                               "LOG10" POINTER @EvaluateExpression(),;
                               "FACT" POINTER @EvaluateExpression(),;
                               "COT" POINTER @EvaluateExpression(),;
                               "ASIN" POINTER @EvaluateExpression(),;
                               "ACOS" POINTER @EvaluateExpression(),;
                               "ATAN" POINTER @EvaluateExpression(),;
                               "ATN2" POINTER @EvaluateExpression(),;
                               "SINH" POINTER @EvaluateExpression(),;
                               "COSH" POINTER @EvaluateExpression(),;
                               "TANH" POINTER @EvaluateExpression(),;
                               "RTOD" POINTER @EvaluateExpression(),;
                               "DTOR" POINTER @EvaluateExpression(),;
                               "PI" POINTER @EvaluateExpression(),;
                               "EXPONENT" POINTER @EvaluateExpression(),;
                               "MANTISSA" POINTER @EvaluateExpression();

static function GetAgents()

    static st__lInitMathFunctions as logical:=.T.

    local oTAgent as object

    local cAgentPrompt as character
    local cAgentPurpose as character

    local hTool as hash

    if (st__lInitMathFunctions)
        st__lInitMathFunctions:=.F.
        InitMathFunctions()
    endif

    #pragma __cstream|cAgentPrompt:=%s
**Prompt:** Based on `'__PROMPT__'` and category `'__AGENT_CATEGORY__'`, select the best matching tool from:
```json
__JSON_HTOOLS__
```
### Rules:
### Rules:
- Identify the intent from the prompt using pattern matching.
- Choose the tool accordingly.
- Extract required values (e.g., `expression`) and map them using exact parameter names.
- Map to Harbour expressions based on keywords:
  - "square root of" → "SQRT(number)"
    * Calculates the square root of a number. Example: SQRT(16) returns 4.
  - "exponential of" → "EXP(number)"
    * Calculates the exponential (base e) of a number. Example: EXP(1) returns approximately 2.71828 (constant e).
  - "logarithm of" → "LOG(number)"
    * Calculates the natural logarithm (base e) of a number. Example: LOG(2.71828) returns approximately 1.
  - "absolute value of" → "ABS(number)"
    * Returns the absolute value of a number. Example: ABS(-5) returns 5.
  - "round"+"with"+"decimal places" → "ROUND(number, number_precision)"
    * Rounds a number to d decimal places. Example: ROUND(3.14159, 2) returns 3.14.
  - "sine of" → "SIN(number)"
    * Calculates the sine of an angle in radians. Example: SIN(0) returns 0.
  - "cosine of" → "COS(number)"
    * Calculates the cosine of an angle in radians. Example: COS(0) returns 1.
  - "tangent of" → "TAN(number)"
    * Calculates the tangent of an angle in radians. Example: TAN(0) returns 0.
  - "integer part of" → "INT(number)"
    * Returns the integer part of a number. Example: INT(3.7) returns 3.
  - "plus" → "+"
    * Adds two numbers.
  - "minus" → "-"
    * Subtracts one number from another.
  - "times" → "*"
    * Multiplies two numbers.
  - "divided by" → "/"
    * Divides one number by another.
  - "power of" or "raised to" → "^"
    * Raises a number n to the power x (equivalent to n ^ x). Example: (2^3) returns 8.
  - "floor of" → "FLOOR(number)"
    * Returns the largest integer less than or equal to a number. Example: FLOOR(1.1) returns 1.
  - "ceiling of" → "CEILING(number)"
    * Returns the smallest integer greater than or equal to a number. Example: CEILING(1.1) returns 2.
  - "sign of" → "SIGN(number)"
    * Returns the sign of a number: 1 if positive, -1 if negative, 0 if zero. Example: SIGN(1.1) returns 1.
  - "log base 10 of" → "LOG10(number)"
    * Calculates the base-10 logarithm of a number. Example: LOG10(10.0) returns 1.0.
  - "factorial of" → "FACT(number)"
    * Calculates the factorial of a non-negative integer. Example: FACT(4) returns 24.
  - "cotangent of" → "COT(number)"
    * Calculates the cotangent of an angle in radians. Example: COT(PI()/4) returns 1.
  - "arcsine of" → "ASIN(number)"
    * Calculates the arcsine (inverse sine) in radians. Example: ASIN(0.0) returns 0.0.
  - "arccosine of" → "ACOS(number)"
    * Calculates the arccosine (inverse cosine) in radians. Example: ACOS(0.0) returns PI()/2.
  - "arctangent of" → "ATAN(number)"
    * Calculates the arctangent (inverse tangent) in radians. Example: ATAN(0.0) returns 0.0.
  - "arctangent of"+"with y,x" → "ATN2(y, x)"
    * Calculates the arctangent of y/x, considering the quadrant. Example: ATN2(0.0, 1.0) returns 0.0.
  - "hyperbolic sine of" → "SINH(number)"
    * Calculates the hyperbolic sine of a number. Example: SINH(0.0) returns 0.0.
  - "hyperbolic cosine of" → "COSH(number)"
    * Calculates the hyperbolic cosine of a number. Example: COSH(-0.5) equals COSH(0.5).
  - "hyperbolic tangent of" → "TANH(number)"
    * Calculates the hyperbolic tangent of a number. Example: TANH(0.0) returns 0.0.
  - "radians to degrees" → "RTOD(number)"
    * Converts radians to degrees. Example: RTOD(PI()) returns 180.0.
  - "degrees to radians" → "DTOR(number)"
    * Converts degrees to radians. Example: DTOR(180.0) returns PI().
  - "pi" → "PI()"
    * Returns the mathematical constant π (approximately 3.14159).
  - "exponent" → "Exponent(<nFloatingPointNumber>)"
    * Returns the exponent of the <nFloatingPointNumber> number in base 2
    - This function supplements Mantissa() to return the exponent of the <nFloatingPointNumber> number.
        Values > 1 or values < -1 return a positive number 0 to 1023.
        Values < 1 or values > -1 return a negative number -1 to -1023.
        The Exponent( 0 ), return 0.
        The following calculation reproduces the original value:
        Example: 2^Exponent(<nFloatingPointNumber>) * Mantissa(<nFloatingPointNumber>) = <nFloatingPointNumber>
  - "mantissa" → "Mantissa(<nFloatingPointNumber>)"
    * Returns the mantissa of the <nFloatingPointNumber> number.
        - This function supplements Exponent() to return the mantissa of the <nFloatingPointNumber> number.
            Example: Mantissa( <nFloatingPointNumber> ) * 2 ^ Exponent( <nFloatingPointNumber> ) = <nFloatingPointNumber>
- Extract numbers from the prompt.
### Output:
Return only a JSON object:
```json
{"tool":"<tool_name>","params":{"<param_name>":"<value>"}}
```
### Examples:
- "What is 2+2?" →
  ```json
  {"tool":"evaluate","params":{"expression":"2+2"}}
  ```
- "What is 2 x 2?" →
  ```json
  {"tool":"evaluate","params":{"expression":"2*2"}}
- "What is square root of 16?" →
  ```json
  {"tool":"evaluate","params":{"expression":"SQRT(16)"}}
  ```
    #pragma __endtext

    #pragma __cstream|cAgentPurpose:=%s
The "agent_math" provides tools for performing basic mathematical operations by evaluating user-provided expressions. It is designed to handle fundamental arithmetic tasks such as addition, subtraction, multiplication, division, and exponentiation, making it a straightforward solution for quick calculations.
    #pragma __endtext

    oTAgent:=TAgent():New("Agent_Math",cAgentPrompt,cAgentPurpose)

    hTool:={=>}
    hTool["name"] := "SQRT"
    hTool["description"] := "Calculates the square root of a number. Example: SQRT(16) returns 4."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "square root of → SQRT(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("SQRT",{|hParams|Agent_Math():Execute("SQRT",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "EXP"
    hTool["description"] := "Calculates the exponential (base e) of a number. Example: EXP(1) returns approximately 2.71828 (constant e)."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "exponential of → EXP(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("EXP",{|hParams|Agent_Math():Execute("EXP",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "LOG"
    hTool["description"] := "Calculates the natural logarithm (base e) of a number. Example: LOG(2.71828) returns approximately 1."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "logarithm of → LOG(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("LOG",{|hParams|Agent_Math():Execute("LOG",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ABS"
    hTool["description"] := "Returns the absolute value of a number. Example: ABS(-5) returns 5."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "absolute value of → ABS(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("LOG",{|hParams|Agent_Math():Execute("LOG",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ROUND"
    hTool["description"] := "Rounds a number to d decimal places. Example: ROUND(3.14159, 2) returns 3.14."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "round+with+decimal places  → ROUND(number, number_precision)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("ROUND",{|hParams|Agent_Math():Execute("ROUND",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "SIN"
    hTool["description"] := "Calculates the sine of an angle in radians. Example: SIN(0) returns 0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "sine of → SIN(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("SIN",{|hParams|Agent_Math():Execute("SIN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "COS"
    hTool["description"] := "Calculates the cosine of an angle in radians. Example: COS(0) returns 1."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "cosine of → COS(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("COS",{|hParams|Agent_Math():Execute("COS",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "TAN"
    hTool["description"] := "Calculates the tangent of an angle in radians. Example: TAN(0) returns 0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "tangent of → TAN(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("TAN",{|hParams|Agent_Math():Execute("TAN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "INT"
    hTool["description"] := "Returns the integer part of a number. Example: INT(3.7) returns 3."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "integer part of → INT(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("INT",{|hParams|Agent_Math():Execute("INT",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "PLUS"
    hTool["description"] := "Adds two numbers"
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'plus' → '+' → a+b"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("PLUS",{|hParams|Agent_Math():Execute("PLUS",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "MINUS"
    hTool["description"] := "Subtracts one number from another."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'minus' → '-' → a-b"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("MINUS",{|hParams|Agent_Math():Execute("MINUS",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "TIMES"
    hTool["description"] := "Multiplies two numbers."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'times' → '*' → a*b"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("TIMES",{|hParams|Agent_Math():Execute("TIMES",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "DIVIDEDBY"
    hTool["description"] := "Divides one number by another."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'divided by' → '/' → a/b"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("DIVIDEDBY",{|hParams|Agent_Math():Execute("DIVIDEDBY",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "POWEROF"
    hTool["description"] := "Raises a number n to the power x (equivalent to n ^ x). Example: (2^3) returns 8."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'power of' or 'raised to' → '^' → a^b or a**b"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("DIVIDEDBY",{|hParams|Agent_Math():Execute("DIVIDEDBY",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "FLOOR"
    hTool["description"] := "Returns the largest integer less than or equal to a number. Example: FLOOR(1.1) returns 1."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "floor of → FLOOR(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("FLOOR",{|hParams|Agent_Math():Execute("FLOOR",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "CEILING"
    hTool["description"] := "Returns the smallest integer greater than or equal to a number. Example: CEILING(1.1) returns 2."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'ceiling of' → 'CEILING(number)'"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("CEILING",{|hParams|Agent_Math():Execute("CEILING",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "SIGN"
    hTool["description"] := "Returns the sign of a number: 1 if positive, -1 if negative, 0 if zero. Example: SIGN(1.1) returns 1."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'sign of' → 'SIGN(number)'"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("SIGN",{|hParams|Agent_Math():Execute("SIGN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "LOG10"
    hTool["description"] := "Calculates the base-10 logarithm of a number. Example: LOG10(10.0) returns 1.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "log base 10 of → LOG10(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("LOG10",{|hParams|Agent_Math():Execute("LOG10",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "FACT"
    hTool["description"] := "Calculates the factorial of a non-negative integer. Example: FACT(4) returns 24."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "factorial of → FACT(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("FACT",{|hParams|Agent_Math():Execute("FACT",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "COT"
    hTool["description"] := "Calculates the cotangent of an angle in radians. Example: COT(PI()/4) returns 1."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "cotangent of → COT(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("COT",{|hParams|Agent_Math():Execute("COT",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ASIN"
    hTool["description"] := "Calculates the arcsine (inverse sine) in radians. Example: ASIN(0.0) returns 0.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'arcsine of' → 'ASIN(number)'"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("ASIN",{|hParams|Agent_Math():Execute("ASIN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ACOS"
    hTool["description"] := "Calculates the arccosine (inverse cosine) in radians. Example: ACOS(0.0) returns PI()/2."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "arccosine of → ACOS(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("ACOS",{|hParams|Agent_Math():Execute("ACOS",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ATAN"
    hTool["description"] := "Calculates the arctangent (inverse tangent) in radians. Example: ATAN(0.0) returns 0.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "arctangent of → ATAN(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("ATAN",{|hParams|Agent_Math():Execute("ATAN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "ATN2"
    hTool["description"] := "Calculates the arctangent of y/x, considering the quadrant. Example: ATN2(0.0, 1.0) returns 0.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "arctangent of"+"with y,x → ATN2(y, x)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("ATN2",{|hParams|Agent_Math():Execute("ATN2",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "SINH"
    hTool["description"] := "Calculates the hyperbolic sine of a number. Example: SINH(0.0) returns 0.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "hyperbolic sine of → SINH(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("SINH",{|hParams|Agent_Math():Execute("SINH",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "COSH"
    hTool["description"] := "Calculates the hyperbolic cosine of a number. Example: COSH(-0.5) equals COSH(0.5)."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "hyperbolic cosine of → COSH(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("COSH",{|hParams|Agent_Math():Execute("COSH",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "TANH"
    hTool["description"] := "Calculates the hyperbolic tangent of a number. Example: TANH(0.0) returns 0.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "hyperbolic tangent of → TANH(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("TANH",{|hParams|Agent_Math():Execute("TANH",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "RTOD"
    hTool["description"] := "Converts radians to degrees. Example: RTOD(PI()) returns 180.0."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "radians to degrees → RTOD(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("RTOD",{|hParams|Agent_Math():Execute("RTOD",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "DTOR"
    hTool["description"] := "Converts degrees to radians. Example: DTOR(180.0) returns PI()."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "degrees to radians → DTOR(number)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("DTOR",{|hParams|Agent_Math():Execute("DTOR",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "PI"
    hTool["description"] := "Returns the mathematical constant π (approximately 3.14159)."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "'pi' → 'PI()'"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("PI",{|hParams|Agent_Math():Execute("PI",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "EXPONENT"
    #pragma __cstream|hTool["description"]:=%s
* Returns the exponent of the <nFloatingPointNumber> number in base 2. This function supplements Mantissa() to return the exponent of the <nFloatingPointNumber> number.
Values > 1 or values < -1 return a positive number 0 to 1023.
Values < 1 or values > -1 return a negative number -1 to -1023.
The Exponent( 0 ), return 0.
The following calculation reproduces the original value:
Example: 2^Exponent(<nFloatingPointNumber>) * Mantissa(<nFloatingPointNumber>) = <nFloatingPointNumber>
    #pragma __endtext
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "exponent → Exponent(<nFloatingPointNumber>)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("EXPONENT",{|hParams|Agent_Math():Execute("ASIN",hParams)},hTool)

    hTool:={=>}
    hTool["name"] := "MANTISSA"
    hTool["description"] := "The mantissa of a real number x is defined as the positive fractional part x-|x|=frac (x), where |x| denotes the floor function. In Italian, it is called mantissa or parte frazionaria."
    hTool["inputSchema"] := {=>}
    hTool["inputSchema"]["type"] := "object"
    hTool["inputSchema"]["properties"] := {=>}
    hTool["inputSchema"]["properties"]["expression"] := {=>}
    hTool["inputSchema"]["properties"]["expression"]["type"] := "string"
    hTool["inputSchema"]["properties"]["expression"]["description"] := "mantissa → Mantissa(<nFloatingPointNumber>)"
    hTool["inputSchema"]["required"]:={"expression"}
    hTool["inputSchema"]["additionalProperties"] := .F.
    hTool["$schema"]:="http://json-schema.org/draft-07/schema#"
    oTAgent:aAddTool("MANTISSA",{|hParams|Agent_Math():Execute("MANTISSA",hParams)},hTool)

    return(oTAgent)

static function EvaluateExpression(hParams as hash)
    local cMessage as character
    local cExpression as character
    local oError as object
    if (hb_HHasKey(hParams,"expression").and.!Empty(hParams["expression"]))
        cExpression:=hb_StrReplace(hParams["expression"],{"x"=>"*","X"=>"*"})
        BEGIN SEQUENCE WITH __BreakBlock()
            cMessage:="The result of "+cExpression+" is "+hb_NToC(&(cExpression))
        RECOVER USING oError
            cMessage:="Failed to evaluate expression."
            #ifdef DEBUG
              cMessage+=" Error: "+ErrorMessage(oError)
            #endif
        END SEQUENCE
    else
        cMessage:="Failed to evaluate expression: no expression specified"
    endif
    return(cMessage)

static procedure InitMathFunctions()

    local aFunc as array
    local aMathFunc as array:=Array(0)

    aAdd(aMathFunc,{@aCos(),{1}})
    aAdd(aMathFunc,{@aSin(),{1}})
    aAdd(aMathFunc,{@aTan(),{1}})
    aAdd(aMathFunc,{@aTn2(),{1,1}})
    aAdd(aMathFunc,{@Ceiling(),{1}})
    aAdd(aMathFunc,{@CoS(),{1}})
    aAdd(aMathFunc,{@CoSH(),{1}})
    aAdd(aMathFunc,{@CoT(),{1}})
    aAdd(aMathFunc,{@DToR(),{1}})
    aAdd(aMathFunc,{@Exp(),{1}})
    aAdd(aMathFunc,{@Exponent(),{1}})
    aAdd(aMathFunc,{@Fact(),{1}})
    aAdd(aMathFunc,{@Floor(),{1}})
    aAdd(aMathFunc,{@Log10(),{1}})
    aAdd(aMathFunc,{@Mantissa(),{1}})
    aAdd(aMathFunc,{@Pi(),{}})
    aAdd(aMathFunc,{@RToD(),{1}})
    aAdd(aMathFunc,{@Sign(),{1}})
    aAdd(aMathFunc,{@Sin(),{1}})
    aAdd(aMathFunc,{@SinH(),{1}})
    aAdd(aMathFunc,{@Tan(),{1}})
    aAdd(aMathFunc,{@TanH(),{1}})

    for each aFunc in aMathFunc
        BEGIN SEQUENCE WITH __BreakBlock()
            hb_ExecFromArray(aFunc)
        END SEQUENCE
    next aFunc

return

static function ErrorMessage(oError as object)

    local cMessage as character:=""

    local nArgs as numeric

    local tmp as anytype

    if (ValType(oError:severity)=="N")
        switch oError:severity
            case ES_WHOCARES
                cMessage+="M "
                exit
            case ES_WARNING
                cMessage+="W "
                exit
            case ES_ERROR
                cMessage+="E "
                exit
            case ES_CATASTROPHIC
                cMessage+="C "
                exit
        end switch
    endif

    if (ValType( oError:genCode )=="N")
        cMessage+=hb_NToC(oError:genCode)+" "
    endif

    if (ValType(oError:subsystem)=="C")
        cMessage+=oError:subsystem+" "
    endif

    if (ValType(oError:subCode)=="N")
        cMessage+=hb_NToC(oError:subCode)+" "
    endif

    if (ValType(oError:description )=="C")
        cMessage+=oError:description+" "
    endif

    if (!Empty(oError:operation))
        cMessage+="("+oError:operation+") "
    endif

    if (!Empty(oError:filename))
        cMessage+="<"+oError:filename+"> "
    endif

    if (ValType(oError:osCode )=="N")
        cMessage+="OS:"+hb_NToC(oError:osCode)+" "
    endif

    if (ValType(oError:tries)=="N")
        cMessage+="#:"+hb_NToC( oError:tries )+" "
    endif

    if (ValType(oError:Args)=="A")
        cMessage+="A:"+hb_NToC(Len( oError:Args ))+":"
        nArgs:=Len(oError:Args)
        for tmp:= 1 to nArgs
            cMessage+=ValType(oError:Args[tmp])+":"+XToStrE(oError:Args[tmp])
            if (tmp<nArgs)
                cMessage+=";"
            endif
        next tmp
        cMessage+=" "
    endif

    if oError:canDefault .or. oError:canRetry .or. oError:canSubstitute

        cMessage+="F:"
        if oError:canDefault
            cMessage+="D"
        endif
        if oError:canRetry
            cMessage+="R"
        endif
        if oError:canSubstitute
            cMessage+="S"
        endif
    endif

    return(cMessage) as character

static function XToStrE( xValue as anytype )

    local cType as character:=ValType(xValue )

    local cStrRet as character

    switch cType
        case "C"
            xValue:=hb_StrReplace(;
                xValue,;
                ,{;
                     Chr(0) => '"+Chr(0)+"';
                    ,Chr(9) => '"+Chr(9)+"';
                    ,Chr(10) => '"+Chr(10)+"';
                    ,Chr(13) => '"+Chr(13)+"';
                    ,Chr(26) => '"+Chr(26)+"';
                };
            )
            cStrRet:=xValue
            exit
        case "N"
            cStrRet:=hb_NToS(xValue)
            exit
        case "D"
            cStrRet:="0d"+iif(Empty(xValue),"0",DToS(xValue))
            exit
        case "L"
            cStrRet:=iif(xValue,".T.",".F.")
            exit
        case "O"
            cStrRet:=xValue:className()+" Object"
            exit
        case "U"
            cStrRet:="NIL"
            exit
        case "B"
            cStrRet:="{||...}"
            exit
        case "A"
            cStrRet:="{.["+hb_NToC(Len(xValue))+"].}"
            exit
        case "M"
            cStrRet:="M:"+xValue
            exit
        otherwise
            cStrRet:=""
    end switch

    return(cStrRet)
