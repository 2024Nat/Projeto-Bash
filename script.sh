#!/bin/bash

#Aqui começa a flag de ajuda  do script. Se o usuário passar -h ou --help como argumento, ele exibirá as informações de uso do script.

    if [[ "$1" == "-h" || "$1" == "--help" ]]; then

        
        echo "========================================================="
        echo "LINUX STARTER PACK - Ajuda"
        echo "========================================================="
        echo "Uso: ./script.sh"
        echo ""
        echo "Este script é um facilitador de pós-instalação."
        echo "Ele fornece um menu interativo para baixar e instalar"
        echo "programas divididos por categorias , o usuário deve escolher a opção e logo em seguida instalar os programas."
        echo "========================================================="
        exit 0

    fi

#Menu de cada categoria das opções do menu principal

    MENU_CATEGORIA(){

    # 1. Pega todos os argumentos passados e joga numa lista chamada 'args'

        local ARGS=("$@")
    
    # 2. O primeiro item (posição 0) é o título da categoria

        local TITULO="${ARGS[0]}"
        local NOMES=() #lista de exibição para o usuário ler
        local PACOTES=() #lista técnica para o computador instalar

    # Conta quantos itens vieram na chamada da função

        local TOTAL_ITENS=${#ARGS[@]}

    # 3. O Loop FOR: começa no 1 (pulando o título) e pula de 2 em 2

        for (( i=1; i<TOTAL_ITENS; i+=2 )); do
            NOMES+=("${ARGS[i]}")        # Pega o nome de exibição
            PACOTES+=("${ARGS[i+1]}")    # Pega o nome do pacote (logo em seguida)
        done
    
        local QUANTIDADE=${#NOMES[@]} # Conta quantos programas reais tem na categoria

        clear
        echo "--- CATEGORIA: $TITULO ---"
        echo "Programas disponíveis nesta categoria:"
    
    # 4. Lista os programas automaticamente na tela

        for i in "${!NOMES[@]}"; do
            echo "$((i+1))) ${NOMES[$i]}"
        done
       read -p "Você gostaria de baixar todos? (s/n): " BAIXAR_TODOS
        
        if [[ "${BAIXAR_TODOS,,}" == "s" ]]; then
            INSTALAR_PACOTES"${PACOTES[@]}"
        else
            while true; do
                read -p "Escolha o número do programa (1-$QUANTIDADE): " ESCOLHA
                
                # Validação: só aceita números dentro do limite de opções

                if [[ "$ESCOLHA" =~ ^[0-9]+$ ]] && [ "$ESCOLHA" -ge 1 ] && [ "$ESCOLHA" -le "$QUANTIDADE" ]; then
                    IDX=$((ESCOLHA-1))
                    INSTALAR_PACOTES "${PACOTES[$IDX]}"
                else
                    echo "Opção inválida!"
                    sleep 1
                    continue
                fi
                
                read -p "Gostaria de instalar mais algum desta categoria? (s/n): " MAIS_ALGUM
                if [[ "${MAIS_ALGUM,,}" == "n" ]]; then
                    break 
                fi
            done
        fi
    }

#loop do menu principal

    while true; do
    clear
    echo "========================================================="
    echo "LINUX STARTER PACK - Menu Principal"
    echo "========================================================="
    echo "1) opcao 1"
    echo "2) opcao 1"
    echo "3) opcao 1"
    echo "4) opcao 1"
    echo "5) opcao 1"
    echo "6) Sair"
    echo "========================================================="
    read -p "Escolha uma categoria (1-6): " MAIN_CHOICE

    case $MAIN_CHOICE in

        # Para adicionar mais programas, basta seguir o padrão "Nome do Programa" "nome-do-pacote"
        
        1) MENU_CATEGORIA "GRÁFICOS E DESIGN" \
            "GIMP" "gimp" \
            "Inkscape" "inkscape" \
            "Blender" "blender" \
            "Krita" "krita" ;; 
            
        2) MENU_CATEGORIA "DESENVOLVIMENTO" \
            "Git (Controle de versão)" "git" \
            "Python 3" "python3" \
            "Node.js" "nodejs" ;;
            
        3) MENU_CATEGORIA "PRODUTIVIDADE" \
            "LibreOffice (Pacote Office)" "libreoffice" \
            "Evince (Leitor de PDF)" "evince" \
            "Thunderbird (E-mail)" "thunderbird" ;;
            
        4) MENU_CATEGORIA "MULTIMÍDIA" \
            "VLC (Player de Vídeo)" "vlc" \
            "OBS Studio (Gravação e Live)" "obs-studio" \
            "Audacity (Edição de Áudio)" "audacity" ;;
            
        5) MENU_CATEGORIA "JOGOS" \
            "Steam" "steam" \
            "Lutris (Gerenciador)" "lutris" \
            "RetroArch (Emuladores)" "retroarch" ;;
            
        6) clear; echo "Saindo do script. Até mais!"; exit 0 ;;
        *) echo "Opção inválida. Escolha entre 1 e 6."; sleep 2 ;;
    esac
done