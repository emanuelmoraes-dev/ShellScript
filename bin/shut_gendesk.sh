#!/bin/bash

# NOME DAS LIBS GLOBAIS A SEREM IMPORTADAS
PARAMETER_HELPER_NAME="parameter-helper"

function _shut_gendesk_helpout() {
    echo
    echo "    Script responsável por criar um lançador de aplicativo para uma aplicação"
    echo "    qualquer no menu do sistema. Se o usuário for root, cria-se um arquivo"
    echo "    \".desktop\" em /usr/share/applications. Caso contrário, cria-se o arquivo"
    echo "    em $HOME/.local/share/applications. Os parâmetros que iniciam por -- possuem"
    echo "    maior prioridade"
    echo
    echo "    Parâmetros Nomeados:"
    echo "        --help: Mostra todas as opções. Opcional"
    echo "        --name: Nome da aplicação a ser exibido no menu. Obrigatório"
    echo "        --exec: Comando de execução da aplicação. Obrigatório (é altamente"
    echo "            recomendado que flags, como o %f, não sejam inseridos aqui. "
    echo "            Caso alguma flag seja necessária, insira ela no parâmetro"
    echo "            --flag-exec)"
    echo "        --icon: Caminho onde se encontra o ícone da aplicação. Opcional"
    echo "        --categories: Lista de categorias separadas por espaço. Opcional"
    echo "        --filename: Nome do arquivo \".desktop\". Se não passado, usa-se o"
    echo "            mesmo valor presente no parâmetro --name"
    echo "        --flag-exec: Flags a serem inseridas ao final do conteúdo da chave"
    echo "            'Exec' do [Desktop Entry]. Opcional"
    echo "        --comment: Comentário sobre a aplicação. Opcional"
    echo
    echo "    Atalhos:"
    echo "        -n = --name"
    echo "        -e = --exec"
    echo "        -i = --icon"
    echo "        -c = --categories"
    echo "        -f = --filename"
    echo "        -fe = --flag-exec"
    echo "        -ct = --comment"
    echo
    echo "    Parâmetros Posicionais:"
    echo "        0: Equivalente ao parâmetro nomeado --name"
    echo "        1: Equivalente ao parâmetro nomeado --exec"
    echo "        2: Equivalente ao parâmetro nomeado --icon"
    echo "        3: Equivalente ao parâmetro nomeado --categories"
    echo "        4: Equivalente ao parâmetro nomeado --filename"
    echo "        5: Equivalente ao parâmetro nomeado --flag-exec"
    echo "        6: Equivalente ao parâmetro nomeado --comment"
    echo
    echo "    Exemplos de Uso:"
    echo
    echo "        gendesk --name Eclipse --exec ./eclipse/eclipse --icon ./eclipse/icon.xpm --categories Development Java --filename eclipse --flag-exec %f --comment IDE para desenvolvedores Java"
    echo
    echo "        gendesk -n Eclipse -e ./eclipse/eclipse -i ./eclipse/icon.xpm -c Development Java -f eclipse -fe %f -ct IDE para desenvolvedores Java"
    echo
    echo "        gendesk Eclipse ./eclipse/eclipse ./eclipse/icon.xpm \"Development Java\" eclipse %f \"IDE para desenvolvedores Java\""
    echo
    echo "        gendesk Eclipse ./eclipse/eclipse ./eclipse/icon.xpm \"Development Java\" eclipse \"\" \"IDE para desenvolvedores Java\""
    echo
    echo "    É possível misturar parâmetros nomeados com parâmetros posicionais. Neste"
    echo "    caso os parâmetros nomeados sempre terão preferência, sobrescrevendo os"
    echo "    posicionais. Os parâmetros posicionais não sobrescrevem eles próprios,"
    echo "    acumulando os valores caso eles seja duplicados"
    echo

    if [ "$1" = "autor" ]; then
        echo "    Autor: Emanuel Moraes de Almeida"
        echo "    Email: emanuelmoraes297@gmail.com"
        echo "    Github: https://github.com/emanuelmoraes-dev"
        echo
    fi
}

function _shut_gendesk_helperr() {
    local message="$1"

    if [ -z "$message" ]; then
        message="Erro! Argumentos Inválidos"
    fi

    _shut_gendesk_helpout >&2 # Executa função para exibir ajuda
    printf >&2 "\n$message\n\n"
}

function _shut_gendesk_getParameterHelper() {
    local DIRNAME="$(dirname "$0")"
    local PARAMETER_HELPER="$DIRNAME/shut_parameterHelper.sh"

    if ! [ -f "$PARAMETER_HELPER" ]; then
        if type -P "$PARAMETER_HELPER_NAME" 1>/dev/null 2>/dev/null; then
            PARAMETER_HELPER="$PARAMETER_HELPER_NAME"
        else
            echo >&2 "Erro! \"$PARAMETER_HELPER_NAME\" não encontrado!"
            return 100
        fi
    fi

    echo $PARAMETER_HELPER
}

function _shut_gendesk_adapter() {
    local rt="$1"

    if [ -f "$rt" ] && [[ "$rt" != /* ]]; then
        if [ "$(pwd)" = "/" ]; then
            rt="/$rt"
        else
            rt="$(pwd)/$rt"
        fi
    fi

    if [ "$2" = "--is-exec" ] && ! type -P "$rt" 1>/dev/null 2>/dev/null; then
        rt="$1"
    elif [ -f "$rt" ]; then
        rt="${rt// /\\ }"
    fi

    echo "$rt"
}

function _shut_gendesk_main() {
    local PARAMETER_HELPER="$(_shut_gendesk_getParameterHelper)" || return $?

    if [ $# -eq 0 ]; then
        _shut_gendesk_helperr "Erro! Argumentos vazios"
        return 101
    fi

    source $PARAMETER_HELPER --create-exists-array --params -help -default -name -exec -icon -categories -filename -flag-exec -comment n e i c f fe ct @@ --default "$@" || (err="$?"; _shut_gendesk_helperr; return $err )

    if [ ${shut_parameterHelper_exists[0]} -eq 1 ]; then
        _shut_gendesk_helpout autor || return $?
        return 0
    fi

    # Arrays dos parâmetros de atalho

    shut_util_array $'\n' "${shut_parameterHelper_args[9]}" || return $?
    args_shortcut_name=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[10]}" || return $?
    args_shortcut_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[11]}" || return $?
    args_shortcut_icon=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[12]}" || return $?
    args_shortcut_categories=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[13]}" || return $?
    args_shortcut_filename=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[14]}" || return $?
    args_shortcut_flag_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[15]}" || return $?
    args_shortcut_comment=("${shut_util_return[@]}")

    # Arrays dos parâmetros nomeados

    shut_util_array $'\n' "${shut_parameterHelper_args[1]}" || return $?
    args_default=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[2]}" || return $?
    args_name=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[3]}" || return $?
    args_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[4]}" || return $?
    args_icon=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[5]}" || return $?
    args_categories=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[6]}" || return $?
    args_filename=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[7]}" || return $?
    args_flag_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[8]}" || return $?
    args_comment=("${shut_util_return[@]}")

    Name="${args_default[0]}"
    Exec="${args_default[1]}"
    Icon="${args_default[2]}"
    Categories="$(shut_util_join \; ${args_default[3]})" || return $?
    Filename="${args_default[4]}"
    FlagExec="${args_default[5]}"
    Comment="${args_default[6]}"

    # Parâmetros de atalho

    if [ ${shut_parameterHelper_exists[9]} -eq 1 ]; then
        Name="${args_shortcut_name[@]}"
    fi

    if [ ${shut_parameterHelper_exists[10]} -eq 1 ]; then
        Exec="${args_shortcut_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[11]} -eq 1 ]; then
        Icon="${args_shortcut_icon[@]}"
    fi

    if [ ${shut_parameterHelper_exists[12]} -eq 1 ]; then
        Categories="$(shut_util_join \; ${args_shortcut_categories[@]})" || return $?
    fi

    if [ ${shut_parameterHelper_exists[13]} -eq 1 ]; then
        Filename="${args_shortcut_filename[@]}"
    fi

    if [ ${shut_parameterHelper_exists[14]} -eq 1 ]; then
        FlagExec="${args_shortcut_flag_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[15]} -eq 1 ]; then
        Comment="${args_shortcut_comment[@]}"
    fi

    # Parâmetros nomeados

    if [ ${shut_parameterHelper_exists[2]} -eq 1 ]; then
        Name="${args_name[@]}"
    fi

    if [ ${shut_parameterHelper_exists[3]} -eq 1 ]; then
        Exec="${args_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[4]} -eq 1 ]; then
        Icon="${args_icon[@]}"
    fi

    if [ ${shut_parameterHelper_exists[5]} -eq 1 ]; then
        Categories="$(shut_util_join \; ${args_categories[@]})" || return $?
    fi

    if [ ${shut_parameterHelper_exists[6]} -eq 1 ]; then
        Filename="${args_filename[@]}"
    fi

    if [ ${shut_parameterHelper_exists[7]} -eq 1 ]; then
        FlagExec="${args_flag_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[8]} -eq 1 ]; then
        Comment="${args_comment[@]}"
    fi

    if [ -z "$Name" ]; then
        _shut_gendesk_helperr "Erro! --name não informado!"
        return 102
    fi

    if [ -z "$Exec" ]; then
        _shut_gendesk_helperr "Erro! --exec não informado!"
        return 103
    fi

    if [ -z "$Filename" ]; then
        Filename="$Name"
    fi

    Exec="$(_shut_gendesk_adapter "$Exec" --is-exec)" || return $?
    Icon="$(_shut_gendesk_adapter "$Icon")" || return $?

    if [ "$(id -u)" = "0" ]; then
        echo "\
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
Name=$Name
Exec=$Exec $FlagExec
Icon=$Icon
Categories=$Categories
Comment=$Comment" >"/usr/share/applications/$Filename.desktop"
    else
        echo "\
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
Name=$Name
Exec=$Exec $FlagExec
Icon=$Icon
Categories=$Categories
Comment=$Comment" >"$HOME/.local/share/applications/$Filename.desktop"
    fi
}

_shut_gendesk_main "$@" # Executa a função principal
