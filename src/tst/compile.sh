#!/bin/bash

# Define o caminho base (substitua /home/marin pelo seu caminho real, se necessário)
BASE_PATH="/home/marin/naldodj-hb/bin/cygwin/gcc/hbmk2.exe"

# Verifica se o executável existe
if [ ! -f "$BASE_PATH" ]; then
    echo "Erro: hbmk2.exe não encontrado em $BASE_PATH"
    exit 1
fi

# Executa as compilações
"$BASE_PATH" hb_agents_lmstudio_curl.hbp
"$BASE_PATH" hb_agents_lmstudio_tip.hbp
"$BASE_PATH" hb_agents_ollama_tip.hbp
"$BASE_PATH" hb_agents_ollama_curl.hbp
