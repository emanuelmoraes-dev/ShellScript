#!/bin/bash

# NOME DAS LIBS GLOBAIS A SEREM IMPORTADAS
PARAMETER_HELPER_NAME="parameter-helper"

# CÓDIGOS DE ERRO DO SCRIPT (60-89)
ERR_UNEXPECTED=60
## NOT FOUND (6X)
ERR_NOT_FOUND_PARAMETER_HELPER=61
## EMPTY (7X)
ERR_EMPTY_ARGUMENTS=71
ERR_EMPTY_NAME_ARG=72
ERR_EMPTY_EXEC_ARG=73

function _shut_gendesk_helpout() {
    echo
    echo "    Script responsável por criar um lançador de aplicativo para uma aplicação"
    echo "    qualquer no menu do sistema. Caso contrário, cria-se o arquivo em"
    echo "    $HOME/.local/share/applications. Os parâmetros que iniciam por -- possuem"
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
    echo "            'exec' do [Desktop Entry]. Opcional"
    echo "        --comment: Comentário sobre a aplicação. Opcional"
	echo "        --dirname: Diretório onde o arquivo .desktop será gerado. Se não"
	echo "            Se não informado e o usuário for root, cria-se o arquivo em"
	echo "            /usr/share/applications. Se o usuário não for root, cria-se"
	echo "            o arquivo em $HOME/.local/share/applications"
	echo "        --out: Se esta flag for informada, nenhum arquivo será gerado e o"
	echo "            conteúdo que seria gerado no arquivo é exibido na saída padrão"
    echo
    echo "    Atalhos:"
    echo "        -n = --name"
    echo "        -e = --exec"
    echo "        -i = --icon"
    echo "        -c = --categories"
    echo "        -f = --filename"
    echo "        -fe = --flag-exec"
    echo "        -ct = --comment"
    echo "        -d = --dirname"
    echo
    echo "    Parâmetros Posicionais:"
    echo "        0: Equivalente ao parâmetro nomeado --name"
    echo "        1: Equivalente ao parâmetro nomeado --exec"
    echo "        2: Equivalente ao parâmetro nomeado --icon"
    echo "        3: Equivalente ao parâmetro nomeado --categories"
    echo "        4: Equivalente ao parâmetro nomeado --filename"
    echo "        5: Equivalente ao parâmetro nomeado --flag-exec"
    echo "        6: Equivalente ao parâmetro nomeado --comment"
    echo "        7: Equivalente ao parâmetro nomeado --dirname"
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

# Ecoa mensagem de erro em erro padrão e código do erro em saída padrão
#
#EX: m="Erro interno! Algo inesperado ocorreu" e=100 _shut_gendesk_helperr -v
function _shut_gendesk_helperr() {
    local err="$?"

    if [ -z "$err" ] || [ "$err" = "0" ]; then
        err=$ERR_UNEXPECTED
    fi

    if [ "$e" ]; then
        err=$e
    fi

    local message="$m"

    if [ -z "$message" ]; then
        message="Erro interno! Algo inesperado ocorreu. Código: $_err!"
    fi

    if [ "$1" == "-v" ]; then
        helpout >&2
    fi

    printf >&2 "\n  $message\n\n"
    echo $err
}

function _shut_gendesk_getParameterHelper() {
    local DIRNAME="$(dirname "$0")"
    local PARAMETER_HELPER="$DIRNAME/shut_parameterHelper.sh"

    if ! [ -f "$PARAMETER_HELPER" ]; then
        if type -P "$PARAMETER_HELPER_NAME" 1>/dev/null 2>/dev/null; then
            PARAMETER_HELPER="$PARAMETER_HELPER_NAME"
        else
            echo >&2 "Erro! \"$PARAMETER_HELPER_NAME\" não encontrado!"
            return $ERR_NOT_FOUND_PARAMETER_HELPER
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
        return $(m="Erro! Argumentos vazios" e=$ERR_EMPTY_ARGUMENTS _shut_gendesk_helperr -v)
    fi

    source $PARAMETER_HELPER --create-exists-array --params -help -default -name -exec -icon -categories -filename -flag-exec -comment -dirname -out n e i c f fe ct d @@ --default "$@" || return $(m="Erro! Argumentos Inválidos" _shut_gendesk_helperr -v)

    if [ ${shut_parameterHelper_exists[0]} -eq 1 ]; then
        _shut_gendesk_helpout autor || return $?
        return 0
    fi

    # Arrays dos parâmetros de atalho

    shut_util_array $'\n' "${shut_parameterHelper_args[11]}" || return $?
    args_shortcut_name=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[12]}" || return $?
    args_shortcut_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[13]}" || return $?
    args_shortcut_icon=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[14]}" || return $?
    args_shortcut_categories=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[15]}" || return $?
    args_shortcut_filename=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[16]}" || return $?
    args_shortcut_flag_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[17]}" || return $?
    args_shortcut_comment=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[18]}" || return $?
    args_shortcut_dirname=("${shut_util_return[@]}")

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

    shut_util_array $'\n' "${shut_parameterHelper_args[9]}" || return $?
    args_dirname=("${shut_util_return[@]}")

    name="${args_default[0]}"
    exec="${args_default[1]}"
    icon="${args_default[2]}"
    categories="$(shut_util_join \; ${args_default[3]})" || return $?
    filename="${args_default[4]}"
    flag_exec="${args_default[5]}"
    comment="${args_default[6]}"
    dirname="${args_default[7]}"

    # Parâmetros de atalho

    if [ ${shut_parameterHelper_exists[11]} -eq 1 ]; then
        name="${args_shortcut_name[@]}"
    fi

    if [ ${shut_parameterHelper_exists[12]} -eq 1 ]; then
        exec="${args_shortcut_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[13]} -eq 1 ]; then
        icon="${args_shortcut_icon[@]}"
    fi

    if [ ${shut_parameterHelper_exists[14]} -eq 1 ]; then
        categories="$(shut_util_join \; ${args_shortcut_categories[@]})" || return $?
    fi

    if [ ${shut_parameterHelper_exists[15]} -eq 1 ]; then
        filename="${args_shortcut_filename[@]}"
    fi

    if [ ${shut_parameterHelper_exists[16]} -eq 1 ]; then
        flag_exec="${args_shortcut_flag_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[17]} -eq 1 ]; then
        comment="${args_shortcut_comment[@]}"
    fi

    if [ ${shut_parameterHelper_exists[18]} -eq 1 ]; then
        dirname="${args_shortcut_dirname}"
    fi

    # Parâmetros nomeados

    if [ ${shut_parameterHelper_exists[2]} -eq 1 ]; then
        name="${args_name[@]}"
    fi

    if [ ${shut_parameterHelper_exists[3]} -eq 1 ]; then
        exec="${args_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[4]} -eq 1 ]; then
        icon="${args_icon[@]}"
    fi

    if [ ${shut_parameterHelper_exists[5]} -eq 1 ]; then
        categories="$(shut_util_join \; ${args_categories[@]})" || return $?
    fi

    if [ ${shut_parameterHelper_exists[6]} -eq 1 ]; then
        filename="${args_filename[@]}"
    fi

    if [ ${shut_parameterHelper_exists[7]} -eq 1 ]; then
        flag_exec="${args_flag_exec[@]}"
    fi

    if [ ${shut_parameterHelper_exists[8]} -eq 1 ]; then
        comment="${args_comment[@]}"
    fi

    if [ ${shut_parameterHelper_exists[9]} -eq 1 ]; then
        dirname="${args_dirname[@]}"
    fi

    # Verificando se argumento --out está presente

    present_out=0

    if [ ${shut_parameterHelper_exists[10]} -eq 1 ]; then
        present_out=1
    fi

    # Verificando existência de argumentos obrigatórios

    if [ -z "$name" ]; then
        return $(m="Erro! --name não informado!" e=$ERR_EMPTY_NAME_ARG _shut_gendesk_helperr -v)
    fi

    if [ -z "$exec" ]; then
        return $(m="Erro! --exec não informado!" e=$ERR_EMPTY_EXEC_ARG _shut_gendesk_helperr -v)
    fi

    # Adaptando valores de argumentos

    if [ -z "$filename" ]; then
        filename="$name"
    fi

    if [ -z "$dirname" ]; then
        if [ "$(id -u)" = "0" ]; then
            dirname="/usr/share/applications"
        else
            dirname="$HOME/.local/share/applications"
        fi
    fi

    local last_dirname=${#dirname}
    let last_dirname=$last_dirname-1

    if [ "${dirname:last_dirname:1}" = "/" ]; then
        dirname="${dirname:0:last_dirname}"
    fi

    exec="$(_shut_gendesk_adapter "$exec" --is-exec)" || return $?
    icon="$(_shut_gendesk_adapter "$icon")" || return $?

    # Gerando o o [Desktop Entry]

    desktop_entry="\
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
name=$name
exec=$exec $flag_exec
icon=$icon
categories=$categories
comment=$comment"

    if [ $present_out -eq 1 ]; then
        echo "$desktop_entry"
    else
        echo "$desktop_entry" > "$dirname/$filename.desktop"
    fi
}

_shut_gendesk_main "$@" # Executa a função principal
