#!/bin/bash

# Define o caminho base (substitua /home/marin pelo seu caminho real, se necessário)
HB_BASE_PATH="/home/marin/naldodj-hb/bin/cygwin/gcc/hbmk2.exe"

# Verifica se o executável existe
if [ ! -f "$HB_BASE_PATH" ]; then
    echo "Erro: hbmk2.exe não encontrado em $HB_BASE_PATH"
    exit 1
fi

# Executa as compilações
"$HB_BASE_PATH" hbmcp.hbp
