#!/bin/bash

#LINUX STARTER PACK - CONFIGURADOR PÓS-INSTALAÇÃO
#Script para automação de instalação de softwares
#Compatível com sistemas Debian/Ubuntu e derivados (apt)

#Tratamento de interrupção pelo usuário (CTRL+C)
trap 'echo ""; echo "Execução interrompida pelo usuário."; exit 1' INT

#Verificação se o sistema usa APT como gerenciador de pacotes
if ! command -v apt >/dev/null 2>&1; then
    echo "Este script requer Debian/Ubuntu (apt)."
    exit 1
fi

# Verificação de ajuda-help
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "h" || "$1" == "help" ]]; then
    echo "========================================================="
    echo "LINUX STARTER PACK - Ajuda"
    echo "========================================================="
    echo "Uso: ./script.sh"
    echo ""
    echo "Script de pós-instalação com menu interativo."
    echo "Permite instalar programas por categoria."
    echo "========================================================="
    exit 0
fi
# Valida o sudo e atualiza os repositórios do APT uma única vez no início.
sudo -v || exit 1
sudo apt update -y

# Função para instalar via Snap (com suporte a flags, como --classic)
INSTALAR_APT() {
    for PACOTE in "$@"; do
        if dpkg-query -W -f='${Status}' "$PACOTE" 2>/dev/null | grep -q "install ok installed"; then
            echo "OK $PACOTE ja esta instalado."
        else
            echo "... Instalando $PACOTE..."
            sudo apt install -y "$PACOTE"
        fi
    done
}
# Função para instalar via Snap (com suporte a flags, como --classic)
INSTALAR_SNAP() {
    local PACOTE="$1"
    local FLAGS="${2:-}"

    if ! command -v snap >/dev/null 2>&1; then
        echo "Instalando snapd..."
        sudo apt install -y snapd
    fi

    if snap list "$PACOTE" >/dev/null 2>&1; then
        echo "OK $PACOTE ja esta instalado (snap)."
    else
        echo "... Instalando $PACOTE via snap..."
        sudo snap install "$PACOTE" $FLAGS
    fi
}

# Função responsável por descobrir se um programa existe no computador.

VERIFICAR_INSTALADO() {
    local PACOTE="$1"
    local TIPO="$2"
    local COMANDO="$3"

    # 1. Tenta achar o comando executável no PATH (Pega APT, Snap, NVM, compilações manuais)
    if command -v "$COMANDO" >/dev/null 2>&1; then
        return 0
    fi

    # 2. Tenta achar no registro do APT (dpkg)
    if dpkg-query -W -f='${Status}' "$PACOTE" 2>/dev/null | grep -q "install ok installed"; then
        return 0
    fi

    # 3. Tenta achar no registro do Snap
    if command -v snap >/dev/null 2>&1 && snap list "$PACOTE" >/dev/null 2>&1; then
        return 0
    fi

    # 4. Tenta achar no registro do Flatpak 
    if command -v flatpak >/dev/null 2>&1 && flatpak list --app | grep -iq "$PACOTE"; then
        return 0
    fi

    # Se passou por todos os testes e não achou, então realmente não está instalado
    return 1
}

# Constrói menus dinâmicos processando Arrays de parâmetros (4 colunas)

MENU_CATEGORIA() {
    local ARGS=("$@")
    local TITULO="${ARGS[0]}"
    local NOMES=()
    local PACOTES=()
    local TIPOS=()
    local COMANDOS=()
    local TOTAL_ITENS=${#ARGS[@]}

    # Lendo de 4 em 4 itens
    for (( i=1; i<TOTAL_ITENS; i+=4 )); do
        NOMES+=("${ARGS[i]}")
        PACOTES+=("${ARGS[i+1]}")
        TIPOS+=("${ARGS[i+2]}")
        COMANDOS+=("${ARGS[i+3]}")
    done

    local QUANTIDADE=${#NOMES[@]}

    while true; do
        clear
        echo "===== $TITULO ====="
        echo ""

        for ((I=0; I<QUANTIDADE; I++)); do
            
            if VERIFICAR_INSTALADO "${PACOTES[$I]}" "${TIPOS[$I]}" "${COMANDOS[$I]}"; then
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

# Mantém o script rodando até o usuário escolher a opção de sair.

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

        # PADRÃO - "Nome Exibição" "pacote" "tipo" "comando_no_terminal"

        1) MENU_CATEGORIA "GRÁFICOS E DESIGN" \
            "GIMP" "gimp" "apt" "gimp" \
            "Inkscape" "inkscape" "apt" "inkscape" \
            "Blender" "blender" "apt" "blender" \
            "Krita" "krita" "apt" "krita" ;;

        2) MENU_CATEGORIA "DESENVOLVIMENTO" \
            "Git (Controle de versão)" "git" "apt" "git" \
            "Python 3" "python3" "apt" "python3" \
            "Node.js" "nodejs" "apt" "node" \
            "VS Code" "code" "snap-classic" "code" \
            "Docker" "docker.io" "apt" "docker" \
            "PostgreSQL" "postgresql" "apt" "psql" \
            "Vim" "vim" "apt" "vim" \
            "curl" "curl" "apt" "curl" ;;

        3) MENU_CATEGORIA "PRODUTIVIDADE" \
            "LibreOffice (Pacote Office)" "libreoffice" "apt" "libreoffice" \
            "Evince (Leitor de PDF)" "evince" "apt" "evince" \
            "Thunderbird (E-mail)" "thunderbird" "apt" "thunderbird" \
            "Notion" "notion-snap-reborn" "snap" "notion-snap-reborn" \
            "Obsidian (Notas)" "obsidian" "snap-classic" "obsidian" \
            "Flameshot (Print de tela)" "flameshot" "apt" "flameshot" \
            "Timeshift (Backup do sistema)" "timeshift" "apt" "timeshift" ;;

        4) MENU_CATEGORIA "MULTIMÍDIA" \
            "VLC (Player de Vídeo)" "vlc" "apt" "vlc" \
            "OBS Studio (Gravação e Live)" "obs-studio" "apt" "obs" \
            "Audacity (Edição de Áudio)" "audacity" "apt" "audacity" \
            "Discord" "discord" "snap" "discord" \
            "Spotify" "spotify" "snap" "spotify" ;;

        5) MENU_CATEGORIA "JOGOS" \
            "Steam" "steam" "apt" "steam" \
            "Lutris (Gerenciador)" "lutris" "apt" "lutris" \
            "RetroArch (Emuladores)" "retroarch" "apt" "retroarch" ;;

        6) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida."; sleep 1 ;;
    esac
done