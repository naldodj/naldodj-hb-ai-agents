@setlocal

    call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_lmstudio_curl_msvc.hbp -comp=msvc64
    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_lmstudio_tip_msvc.hbp -comp=msvc64

    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_lmstudio_msxml2_msvc.hbp -comp=msvc64
    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_lmstudio_winhttp_msvc.hbp -comp=msvc64

    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_ollama_curl_msvc.hbp -comp=msvc64
    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_ollama_tip_msvc.hbp -comp=msvc64

    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_ollama_msxml2_msvc.hbp -comp=msvc64
    F:\harbour_msvc2022_64_20250216\bin\win\msvc64\hbmk2 hb_agents_ollama_winhttp_msvc.hbp -comp=msvc64

@endlocal
