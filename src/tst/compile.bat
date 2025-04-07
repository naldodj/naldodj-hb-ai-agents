@echo off
SETLOCAL ENABLEEXTENSIONS
    echo BATCH FILE FOR Harbour MinGW64
    rem ============================================================================
    IF EXIST env_mk64.txt (
        DEL env_mk64.txt /F /Q
    )
    SET > env_mk64.txt
        SET HB_PATH=C:\GitHub\core\
        SET MinGW64_PATH=C:\MinGW64\BIN\
        SET PATH=%PATH%;%HB_PATH%
        SET PATH=%PATH%;%MinGW64_PATH%
        SET HB_CPU=x86_64
        SET HB_PLATFORM=win
        SET HB_COMPILER=mingw64
        SET HB_CCPATH=%MinGW64_PATH%
        SET HB_BUILD_SHARED=yes
        %HB_PATH%bin\win\mingw64\hbmk2.exe -plat=win -cpu=x86_64 -jobs=10 -cpp -compr=max -comp=mingw64 -gui ./hb_agents_ollama.hbp
        %HB_PATH%bin\win\mingw64\hbmk2.exe -plat=win -cpu=x86_64 -jobs=10 -cpp -compr=max -comp=mingw64 -gui ./hb_agents_lmstudio.hbp
    for /f %%e in (env_mk64.txt) do (
        SET %%e
    )
    DEL env_mk64.txt /F /Q
ENDLOCAL
