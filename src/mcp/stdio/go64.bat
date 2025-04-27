@setlocal
SET HB_BASE_PATH="C:\Users\marin\Downloads\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2"
call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
%HB_BASE_PATH% hbmcp.hbp -comp=msvc64
@endlocal
