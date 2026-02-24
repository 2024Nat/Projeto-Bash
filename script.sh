#!/bin/bash

#LINUX STARTER PACK - CONFIGURADOR PÓS-INSTALAÇÃO
#Script para automação de instalação de softwares
#Compatível com sistemas Debian/Ubuntu (APT)

#Tratamento de interrupção pelo usuário (CTRL+C)
trap 'echo ""; echo "Execução interrompida pelo usuário."; exit 1' INT

#Verificação se o sistema usa APT como gerenciador de pacotes
if ! command -v apt >/dev/null 2>&1; then
    echo "Este script requer Debian/Ubuntu (apt)."
    exit 1
fi

#Aqui começa a flag de ajuda do script. Se o usuário passar -h ou --help como argumento, ele exibirá as informações de uso do script.
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "h" || "$1" == "help" ]]; then
    echo "========================================================="
    echo "LINUX STARTER PACK - Ajuda"
    echo "========================================================="
    echo "Uso: ./script.sh"
    echo ""
    echo "Script de pós-instalação com menu interativo."
    echo "Permite instalar programas por categoria."
    echo ""
    echo "Indicado para sistemas Debian/Ubuntu recém-instalados."
    echo "O script trata automaticamente todos os pré-requisitos."
    echo "========================================================="
    exit 0
fi

#Atualização do APT realizada uma única vez antes das instalações
sudo -v || exit 1
sudo apt update -y

# FUNÇÃO DE INSTALAÇÃO VIA APT
# Para adicionar mais funções de instalação, basta criar novas funções seguindo o mesmo padrão
INSTALAR_APT() {
    for PACOTE in "$@"; do
        if dpkg -s "$PACOTE" >/dev/null 2>&1; then
            echo "OK $PACOTE ja esta instalado."
        else
            echo "... Instalando $PACOTE..."
            sudo apt install -y "$PACOTE"
        fi
    done
}

# FUNÇÃO DE INSTALAÇÃO VIA SNAP
INSTALAR_SNAP() {
    local PACOTE="$1"
    local FLAGS="${2:-}"  # segundo argumento opcional, ex: --classic

    if ! command -v snap >/dev/null 2>&1; then
        echo "Instalando snapd..."
        sudo apt install -y snapd
    fi

    if snap list | grep -q "^$PACOTE "; then
        echo "OK $PACOTE ja esta instalado (snap)."
    else
        echo "... Instalando $PACOTE via snap..."
        sudo snap install "$PACOTE" $FLAGS
    fi
}

#Verifica se um pacote já está instalado (APT ou Snap)
VERIFICAR_INSTALADO() {
    local PACOTE="$1"
    local TIPO="$2"

    if [[ "$TIPO" == "snap" || "$TIPO" == "snap-classic" ]]; then
        snap list 2>/dev/null | grep -q "^$PACOTE "
    else
        dpkg -s "$PACOTE" >/dev/null 2>&1
    fi
}

#Menu de cada categoria das opções do menu principal
MENU_CATEGORIA() {
    local ARGS=("$@")
    local TITULO="${ARGS[0]}"
    local NOMES=()
    local PACOTES=()
    local TIPOS=()
    local TOTAL_ITENS=${#ARGS[@]}

    # Lê triplas: "Nome" "pacote" "apt/snap"
    for (( i=1; i<TOTAL_ITENS; i+=3 )); do
        NOMES+=("${ARGS[i]}")
        PACOTES+=("${ARGS[i+1]}")
        TIPOS+=("${ARGS[i+2]}")
    done

    local QUANTIDADE=${#NOMES[@]}

    while true; do
        clear
        echo "===== $TITULO ====="
        echo ""

        for ((I=0; I<QUANTIDADE; I++)); do
            if VERIFICAR_INSTALADO "${PACOTES[$I]}" "${TIPOS[$I]}"; then
                echo "$((I+1))) ${NOMES[$I]}  [INSTALADO]"
            else
                echo "$((I+1))) ${NOMES[$I]}  [NAO INSTALADO]"
            fi
        done

        echo "0) Voltar"
        echo ""

        read -p "Você gostaria de baixar todos? (s/n): " BAIXAR_TODOS

        if [[ "${BAIXAR_TODOS,,}" == "s" ]]; then
            for ((I=0; I<QUANTIDADE; I++)); do
                if [[ "${TIPOS[$I]}" == "snap-classic" ]]; then
                    INSTALAR_SNAP "${PACOTES[$I]}" "--classic"
                elif [[ "${TIPOS[$I]}" == "snap" ]]; then
                    INSTALAR_SNAP "${PACOTES[$I]}"
                else
                    INSTALAR_APT "${PACOTES[$I]}"
                fi
            done
            read -p "Pressione ENTER para continuar..."
            break
        fi

        read -p "Escolha uma opção: " ESCOLHA

        if [[ "$ESCOLHA" == "0" ]]; then
            break
        fi

        if [[ "$ESCOLHA" =~ ^[0-9]+$ ]] && [ "$ESCOLHA" -ge 1 ] && [ "$ESCOLHA" -le "$QUANTIDADE" ]; then
            IDX=$((ESCOLHA-1))
            if [[ "${TIPOS[$IDX]}" == "snap-classic" ]]; then
                INSTALAR_SNAP "${PACOTES[$IDX]}" "--classic"
            elif [[ "${TIPOS[$IDX]}" == "snap" ]]; then
                INSTALAR_SNAP "${PACOTES[$IDX]}"
            else
                INSTALAR_APT "${PACOTES[$IDX]}"
            fi
            read -p "Gostaria de instalar mais algum desta categoria? (s/n): " MAIS_ALGUM
            if [[ "${MAIS_ALGUM,,}" == "n" ]]; then
                break
            fi
        else
            echo "Opção inválida."
            sleep 1
        fi
    done
}

#loop do menu principal
while true; do
    clear
    echo "======================================"
    echo "LINUX STARTER PACK - MENU PRINCIPAL"
    echo "======================================"
    echo "1) Gráficos e Design"
    echo "2) Desenvolvimento"
    echo "3) Produtividade"
    echo "4) Multimídia"
    echo "5) Jogos"
    echo "6) Sair"
    echo "======================================"
    read -p "Escolha uma opção: " MAIN

    case $MAIN in

        # Para adicionar mais programas, basta seguir o padrão "Nome do Programa" "nome-do-pacote" "apt/snap"

        1) MENU_CATEGORIA "GRÁFICOS E DESIGN" \
            "GIMP" "gimp" "apt" \
            "Inkscape" "inkscape" "apt" \
            "Blender" "blender" "apt" \
            "Krita" "krita" "apt" ;;

        2) MENU_CATEGORIA "DESENVOLVIMENTO" \
            "Git (Controle de versão)" "git" "apt" \
            "Python 3" "python3" "apt" \
            "Node.js" "nodejs" "apt" \
            "VS Code" "code" "snap-classic" \
            "Docker" "docker.io" "apt" \
            "PostgreSQL" "postgresql" "apt" \
            "Vim" "vim" "apt" \
            "curl" "curl" "apt" ;;

        3) MENU_CATEGORIA "PRODUTIVIDADE" \
            "LibreOffice (Pacote Office)" "libreoffice" "apt" \
            "Evince (Leitor de PDF)" "evince" "apt" \
            "Thunderbird (E-mail)" "thunderbird" "apt" \
            "Notion" "notion-snap-reborn" "snap" \
            "Obsidian (Notas)" "obsidian" "snap-classic" \
            "Flameshot (Print de tela)" "flameshot" "apt" \
            "Timeshift (Backup do sistema)" "timeshift" "apt" ;;

        4) MENU_CATEGORIA "MULTIMÍDIA" \
            "VLC (Player de Vídeo)" "vlc" "apt" \
            "OBS Studio (Gravação e Live)" "obs-studio" "apt" \
            "Audacity (Edição de Áudio)" "audacity" "apt" \
            "Spotify" "spotify" "snap" ;;

        5) MENU_CATEGORIA "JOGOS" \
            "Steam" "steam" "apt" \
            "Lutris (Gerenciador)" "lutris" "apt" \
            "RetroArch (Emuladores)" "retroarch" "apt" ;;

        6) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida."; sleep 1 ;;
    esac
done
