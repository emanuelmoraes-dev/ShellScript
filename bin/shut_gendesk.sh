#!/bin/bash

VERSION=1.0.0

# Script responsável por criar um lançador de aplicativo para uma aplicação
# qualquer no menu do sistema. Se for root, por padrão, cria-se o arquivo
# .desktop em /usr/share/applications. Caso contrário, cria-se o arquivo em
# $HOME/.local/share/applications. Os parâmetros que iniciam por -- possuem
# a maior prioridade. Os parâmetros que inicial por - possuem a segunda
# maior prioridade
#
# Parâmetros Nomeados:
#     --help: Mostra todas as opções. Opcional
#     --version: Mostra a versão atual deste script
#     --lang: Define a linguagem na qual o --name e o --comment devem ser
#         exibidos. --lang APENAS será aplicado nos argumentos definidos
#         APÓS este. Se não passado, a linguagem não será definida e os
#         parâmetros --name e --comment se definirão como valor padrão.
#         Opcional
#     --name: Nome da aplicação a ser exibido no menu. Opcional
#     --exec: Comando de execução da aplicação. Opcional (é altamente
#         recomendado que flags, como o %f, não sejam inseridos aqui.
#         Caso alguma flag seja necessária, insira ela no parâmetro
#         --flag-exec)
#     --flag-exec: Flags a serem inseridas ao final do conteúdo da chave
#         'exec' do [Desktop Entry]. Opcional
#     --icon: Caminho onde se encontra o ícone da aplicação. Opcional
#     --categories: Lista de categorias separadas por espaço. Opcional
#     --comment: Comentário sobre a aplicação. Opcional
#     --filename: Nome do arquivo \".desktop\". Se não passado, usa-se o
#         mesmo valor presente no parâmetro --name. Opcional
#     --dirname: Diretório onde o arquivo .desktop será gerado. Se não
#         Se não informado e o usuário for root, cria-se o arquivo em
#         /usr/share/applications. Se o usuário não for root, cria-se
#         o arquivo em $HOME/.local/share/applications.
#         Opcional
#     --out: Se esta flag for informada, nenhum arquivo será gerado e o
#         conteúdo que seria gerado no arquivo é exibido na saída padrão.
#         Opcional
#     --replace-file: Se esta flag for informada e se já ouver um arquivo
#         .desktop, tal arquivo será reescrito, ao invés de concatenado
#
# Atalhos:
#     -n = --name
#     -e = --exec
#     -i = --icon
#     -c = --categories
#     -f = --filename
#     -fe = --flag-exec
#     -ct = --comment
#     -d = --dirname
#     -rf = --replace-file
#
# Parâmetros Posicionais:
#     0: Equivalente ao parâmetro nomeado --name
#     1: Equivalente ao parâmetro nomeado --exec
#     2: Equivalente ao parâmetro nomeado --flag-exec
#     3: Equivalente ao parâmetro nomeado --icon
#     4: Equivalente ao parâmetro nomeado --categories
#     6: Equivalente ao parâmetro nomeado --comment
#     5: Equivalente ao parâmetro nomeado --filename
#     7: Equivalente ao parâmetro nomeado --dirname
#
# Exemplos de Uso:
#
#     gendesk --name Eclipse --exec ./eclipse/eclipse --icon ./eclipse/icon.xpm --categories Development Java --filename eclipse --dirname /usr/share/applications --flag-exec %f --comment IDE para desenvolvedores Java
#
#     gendesk -n Eclipse -e ./eclipse/eclipse -i ./eclipse/icon.xpm -c Development Java -f eclipse -d /usr/share/applications -fe %f -ct IDE para desenvolvedores Java
#
#     gendesk Eclipse ./eclipse/eclipse %f ./eclipse/icon.xpm "Development Java" "IDE para desenvolvedores Java" eclipse /usr/share/applications
#
#     gendesk Eclipse ./eclipse/eclipse "" ./eclipse/icon.xpm "Development Java" "IDE para desenvolvedores Java"
#
#     gendesk --out --name Eclipse --exec ./eclipse/eclipse --icon ./eclipse/icon.xpm --categories Development Java --filename eclipse --dirname /usr/share/applications --flag-exec %f --lang en --comment IDE for Java developer --lang pt --comment IDE para desenvolvedores Java
#
#     gendesk -n Eclipse -e ./eclipse/eclipse -i ./eclipse/icon.xpm -c Development Java -f eclipse -d /usr/share/applications -fe %f -ct IDE for Java developer --lang pt -ct IDE para desenvolvedores Java
#
#     gendesk Eclipse ./eclipse/eclipse "" ./eclipse/icon.xpm "Development Java" "IDE for Java developer" --lang pt -ct IDE para desenvolvedores Java
#
#     gendesk --lang pt Eclipse ./eclipse/eclipse "" ./eclipse/icon.xpm "Development Java" "IDE para desenvolvedores Java"
#
# É possível misturar parâmetros nomeados com parâmetros posicionais. Neste
# caso os parâmetros nomeados sempre terão preferência, sobrescrevendo os
# posicionais. Os parâmetros posicionais não sobrescrevem eles próprios,
# acumulando os valores caso eles seja duplicados
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

# NOME DAS LIBS GLOBAIS A SEREM IMPORTADAS
PARAMETER_HELPER_NAME="parameter-helper"

# CÓDIGOS DE ERRO DO SCRIPT (60-89)
ERR_6X8X_UNEXPECTED=60
## NOT FOUND (6X)
ERR_6X8X_NOT_FOUND_PARAMETER_HELPER=61
ERR_6X8X_NOT_FOUND_NAME=62
ERR_6X8X_NOT_FOUND_EXEC=63
## EMPTY (7X)
ERR_6X8X_EMPTY_ARGUMENTS=71
ERR_6X8X_EMPTY_NAME_ARG=72
ERR_6X8X_EMPTY_EXEC_ARG=73

# CORES
RED="\e[31;1m"
END_COLOR="\e[m"

# TEMAS
ERROR_THEME="$RED"

function helpout {
    echo
    echo "    Script responsável por criar um lançador de aplicativo para uma aplicação"
    echo "    qualquer no menu do sistema. Se for root, por padrão, cria-se o arquivo"
    echo "    .desktop em /usr/share/applications. Caso contrário, cria-se o arquivo em"
    echo "    $HOME/.local/share/applications. Os parâmetros que iniciam por -- possuem"
    echo "    a maior prioridade. Os parâmetros que inicial por - possuem a segunda"
    echo "    maior prioridade"
    echo
    echo "    Parâmetros Nomeados:"
    echo "        --help: Mostra todas as opções. Opcional"
    echo "        --version: Mostra a versão atual deste script"
    echo "        --lang: Define a linguagem na qual o --name e o --comment devem ser"
    echo "            exibidos. --lang APENAS será aplicado nos argumentos definidos"
    echo "            APÓS este. Se não passado, a linguagem não será definida e os"
    echo "            parâmetros --name e --comment se definirão como valor padrão."
    echo "            Opcional"
    echo "        --name: Nome da aplicação a ser exibido no menu. Opcional"
    echo "        --exec: Comando de execução da aplicação. Opcional (é altamente"
    echo "            recomendado que flags, como o %f, não sejam inseridos aqui. "
    echo "            Caso alguma flag seja necessária, insira ela no parâmetro"
    echo "            --flag-exec)"
    echo "        --flag-exec: Flags a serem inseridas ao final do conteúdo da chave"
    echo "            'exec' do [Desktop Entry]. Opcional"
    echo "        --icon: Caminho onde se encontra o ícone da aplicação. Opcional"
    echo "        --categories: Lista de categorias separadas por espaço. Opcional"
    echo "        --comment: Comentário sobre a aplicação. Opcional"
    echo "        --filename: Nome do arquivo \".desktop\". Se não passado, usa-se o"
    echo "            mesmo valor presente no parâmetro --name. Opcional"
	echo "        --dirname: Diretório onde o arquivo .desktop será gerado. Se não"
	echo "            Se não informado e o usuário for root, cria-se o arquivo em"
	echo "            /usr/share/applications. Se o usuário não for root, cria-se"
	echo "            o arquivo em $HOME/.local/share/applications."
    echo "            Opcional"
	echo "        --out: Se esta flag for informada, nenhum arquivo será gerado e o"
	echo "            conteúdo que seria gerado no arquivo é exibido na saída padrão."
    echo "            Opcional"
    echo "        --replace-file: Se esta flag for informada e se já ouver um arquivo"
    echo "            .desktop, tal arquivo será reescrito, ao invés de concatenado"
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
    echo "        -rf = --replace-file"
    echo
    echo "    Parâmetros Posicionais:"
    echo "        0: Equivalente ao parâmetro nomeado --name"
    echo "        1: Equivalente ao parâmetro nomeado --exec"
    echo "        2: Equivalente ao parâmetro nomeado --flag-exec"
    echo "        3: Equivalente ao parâmetro nomeado --icon"
    echo "        4: Equivalente ao parâmetro nomeado --categories"
    echo "        6: Equivalente ao parâmetro nomeado --comment"
    echo "        5: Equivalente ao parâmetro nomeado --filename"
    echo "        7: Equivalente ao parâmetro nomeado --dirname"
    echo
    echo "    Exemplos de Uso:"
    echo
    echo "        gendesk --name Eclipse --exec ./eclipse/eclipse --icon ./eclipse/icon.xpm --categories Development Java --filename eclipse --dirname /usr/share/applications --flag-exec %f --comment IDE para desenvolvedores Java"
    echo
    echo "        gendesk -n Eclipse -e ./eclipse/eclipse -i ./eclipse/icon.xpm -c Development Java -f eclipse -d /usr/share/applications -fe %f -ct IDE para desenvolvedores Java"
    echo
    echo "        gendesk Eclipse ./eclipse/eclipse %f ./eclipse/icon.xpm \"Development Java\" \"IDE para desenvolvedores Java\" eclipse /usr/share/applications"
    echo
    echo "        gendesk Eclipse ./eclipse/eclipse \"\" ./eclipse/icon.xpm \"Development Java\" \"IDE para desenvolvedores Java\""
    echo
    echo "        gendesk --out --name Eclipse --exec ./eclipse/eclipse --icon ./eclipse/icon.xpm --categories Development Java --filename eclipse --dirname /usr/share/applications --flag-exec %f --lang en --comment IDE for Java developer --lang pt --comment IDE para desenvolvedores Java"
    echo
    echo "        gendesk -n Eclipse -e ./eclipse/eclipse -i ./eclipse/icon.xpm -c Development Java -f eclipse -d /usr/share/applications -fe %f -ct IDE for Java developer --lang pt -ct IDE para desenvolvedores Java"
    echo
    echo "        gendesk Eclipse ./eclipse/eclipse \"\" ./eclipse/icon.xpm \"Development Java\" \"IDE for Java developer\" --lang pt -ct IDE para desenvolvedores Java"
    echo
    echo "        gendesk --lang pt Eclipse ./eclipse/eclipse \"\" ./eclipse/icon.xpm \"Development Java\" \"IDE para desenvolvedores Java\""
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

function logerr {
    local message="$@"
    printf >&2 "${ERROR_THEME}\n  ${message}${END_COLOR}\n"
}

# Ecoa mensagem de erro em erro padrão e código do erro em saída padrão
#
#EX: m="Erro interno! Algo inesperado ocorreu" e=100 helperr -v
function helperr {
    local err="$?"

    if [ -z "$err" ] || [ "$err" = "0" ]; then
        err=$ERR_6X8X_UNEXPECTED
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

    logerr "$message"
    echo $err
}

# Joga na variável global PARAMETER_HELPER o nome da lib que tratará os
# argumentos passados pelo usuário
function get_parameter_helper {
    local DIRNAME="$(dirname "$0")"
    PARAMETER_HELPER="$DIRNAME/shut_parameterHelper.sh"

    if ! [ -f "$PARAMETER_HELPER" ]; then
        if type -P "$PARAMETER_HELPER_NAME" 1>/dev/null 2>/dev/null; then
            PARAMETER_HELPER="$PARAMETER_HELPER_NAME"
        else
            return $(m="Erro! \"$PARAMETER_HELPER_NAME\"" e=$ERR_6X8X_NOT_FOUND_PARAMETER_HELPER helperr)
        fi
    fi
}

# Transforma path relativo de executável (--is-exec) ou de outro arquivo
# em path absoluto
function adapter {
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

# Processa os parâmetros passados pelo usuário
function parameters {
    source $PARAMETER_HELPER --create-exists-array --flag-params -out -replace-file rf --params -help -version -lang -default -name -exec -icon -categories -filename -flag-exec -comment -dirname -out -replace-file n e i c f fe ct d rf @@ --default "$@" || return $(m="Erro! Argumentos Inválidos" helperr -v)

    # Mapeando posições de parâmetros

    __HELP__=0
    __VERSION__=1
    __LANG__=2
    __DEFAULT__=3
    __NAME__=4
    __EXEC__=5
    __ICON__=6
    __CATEGORIES__=7
    __FILENAME__=8
    __FLAG_EXEC__=9
    __COMMENT__=10
    __DIRNAME__=11
    __OUT__=12
    __REPLACE_FILE__=13
    _N_=14
    _E_=15
    _I_=16
    _C_=17
    _F_=18
    _FE_=19
    _CT_=20
    _D_=21
    _RF_=22

    # Verificando presença de --help

    present_help=0

    if [ "${shut_parameterHelper_exists[__HELP__]}" = 1 ]; then
        present_help=1
    fi

    # Verificando presença de --version

    present_version=0

    if [ "${shut_parameterHelper_exists[__VERSION__]}" = 1 ]; then
        present_version=1
    fi

    # Atribuindo o valor de lang

    lang="${shut_parameterHelper_args[__LANG__]}"

    # Arrays dos parâmetros nomeados

    shut_util_array $'\n' "${shut_parameterHelper_args[__DEFAULT__]}" || return $?
    args_default=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__NAME__]}" || return $?
    args_name=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__EXEC__]}" || return $?
    args_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__ICON__]}" || return $?
    args_icon=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__CATEGORIES__]}" || return $?
    args_categories=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__FILENAME__]}" || return $?
    args_filename=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__FLAG_EXEC__]}" || return $?
    args_flag_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__COMMENT__]}" || return $?
    args_comment=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[__DIRNAME__]}" || return $?
    args_dirname=("${shut_util_return[@]}")

    # Verificando se argumento --out está presente

    if [ -z "$present_out" ]; then
        present_out=0
    fi

    if [ "${shut_parameterHelper_exists[__OUT__]}" = 1 ]; then
        present_out=1
    fi

    # Verificando se argumento --replace-file está presente

    if [ -z "$present_replace_file" ]; then
        present_replace_file=0
    fi

    if [ "${shut_parameterHelper_exists[__REPLACE_FILE__]}" = 1 ]; then
        present_replace_file=1
    fi

    # Arrays dos parâmetros de atalho

    shut_util_array $'\n' "${shut_parameterHelper_args[_N_]}" || return $?
    args_shortcut_name=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_E_]}" || return $?
    args_shortcut_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_I_]}" || return $?
    args_shortcut_icon=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_C_]}" || return $?
    args_shortcut_categories=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_F_]}" || return $?
    args_shortcut_filename=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_FE_]}" || return $?
    args_shortcut_flag_exec=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_CT_]}" || return $?
    args_shortcut_comment=("${shut_util_return[@]}")

    shut_util_array $'\n' "${shut_parameterHelper_args[_D_]}" || return $?
    args_shortcut_dirname=("${shut_util_return[@]}")

    # Verificando se argumento -rf está presente

    if [ "${shut_parameterHelper_exists[_RF_]}" = 1 ]; then
        present_replace_file=1
    fi

    # Atribui os valores de --default

    if [ "${args_default[0]}" ]; then
        name="${args_default[0]}"
    fi

    exec="${args_default[1]}"
    flag_exec="${args_default[2]}"
    icon="${args_default[3]}"
    categories="$(shut_util_join \; ${args_default[4]})" || return $?

    if [ "${args_default[5]}" ]; then
        comment="${args_default[5]}"
    fi

    if [ "${args_default[6]}" ]; then
        filename="${args_default[6]}"
    fi

    if [ "${args_default[7]}" ]; then
        dirname="${args_default[7]}"
    fi

    # Atribui (se existir) os parâmetros de atalho

    if [ "${shut_parameterHelper_exists[_N_]}" = 1 ]; then
        name="${args_shortcut_name[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_E_]}" = 1 ]; then
        exec="${args_shortcut_exec[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_I_]}" = 1 ]; then
        icon="${args_shortcut_icon[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_C_]}" = 1 ]; then
        categories="$(shut_util_join \; ${args_shortcut_categories[@]})" || return $?
    fi

    if [ "${shut_parameterHelper_exists[_F_]}" = 1 ]; then
        filename="${args_shortcut_filename[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_FE_]}" = 1 ]; then
        flag_exec="${args_shortcut_flag_exec[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_CT_]}" = 1 ]; then
        comment="${args_shortcut_comment[@]}"
    fi

    if [ "${shut_parameterHelper_exists[_D_]}" = 1 ]; then
        dirname="${args_shortcut_dirname}"
    fi

    # Atribui (se existir) os parâmetros nomeados

    if [ "${shut_parameterHelper_exists[__NAME__]}" = 1 ]; then
        name="${args_name[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__EXEC__]}" = 1 ]; then
        exec="${args_exec[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__ICON__]}" = 1 ]; then
        icon="${args_icon[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__CATEGORIES__]}" = 1 ]; then
        categories="$(shut_util_join \; ${args_categories[@]})" || return $?
    fi

    if [ "${shut_parameterHelper_exists[__FILENAME__]}" = 1 ]; then
        filename="${args_filename[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__FLAG_EXEC__]}" = 1 ]; then
        flag_exec="${args_flag_exec[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__COMMENT__]}" = 1 ]; then
        comment="${args_comment[@]}"
    fi

    if [ "${shut_parameterHelper_exists[__DIRNAME__]}" = 1 ]; then
        dirname="${args_dirname[@]}"
    fi
}

# Gera [Desktop Entry]
function run {
    local endl=$'\n' # Quebra de linha

    parameters "$@" || return $? # Processa os parâmetros passados pelo usuário

    if [ "$present_help" = 1 ]; then
        helpout autor || return $?
        return 0
    fi

    if [ "$present_version" = 1 ]; then
        echo "version: $VERSION"
        return 0
    fi

    local str_args="$@"

    if [ "$str_args" = "--out" ]; then
        return 0
    fi

    # Transforma path relativo em path absoluto

    exec="$(adapter "$exec" --is-exec)" || return $?

    if [ "$icon" ]; then
        icon="$(adapter "$icon")" || return $?
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

    dirname="$(dirname "$dirname")/$(basename "$dirname")"

    if [ "$lang" ]; then
        lang="[$lang]"
    fi

    # Gerando [Desktop Entry]

    if [ -z "$desktop_entry" ] && [ "$present_replace_file" = 0 ] && [ "$filename" ] && [ -f "$dirname/$filename.desktop" ]; then
        desktop_entry="$(cat "$dirname/$filename.desktop")"
    fi

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep \"[Desktop Entry]\"")" ]; then
        if [ "$present_replace_file" = 0 ] && [ -f "$dirname/$filename.desktop" ]; then
            desktop_entry="${desktop_entry}${endl}[Desktop Entry]"
        else
            desktop_entry="${desktop_entry}[Desktop Entry]"
        fi
    fi

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep \"Encoding=\"")" ]; then
        desktop_entry="${desktop_entry}${endl}Encoding=UTF-8"
    fi

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep \"Type=\"")" ]; then
        desktop_entry="${desktop_entry}${endl}Type=Application"
    fi

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep \"Terminal=\"")" ]; then
        desktop_entry="${desktop_entry}${endl}Terminal=false"
    fi

    if [ "$exec" ]; then
        desktop_entry="${desktop_entry}${endl}Exec=$exec $flag_exec"
    fi

    if [ "$icon" ]; then
        desktop_entry="${desktop_entry}${endl}Icon=$icon"
    fi

    if [ "$categories" ]; then
        desktop_entry="${desktop_entry}${endl}Categories=$categories"
    fi

    if [ "$name" ]; then
        desktop_entry="${desktop_entry}${endl}Name$lang=$name"
    fi

    if [ "$comment" ]; then
        desktop_entry="${desktop_entry}${endl}Comment$lang=$comment"
    fi
}

# Função principal
function main {
    if [ "$#" = 0 ]; then
        return $(m="Erro! Argumentos vazios" e=$ERR_6X8X_EMPTY_ARGUMENTS helperr -v)
    fi

    # Joga na variável global PARAMETER_HELPER o nome da lib que tratará os
    # argumentos passados pelo usuário
    get_parameter_helper || return $?

    # Obtém as libs importados pelo próprio PARAMETER_HELPER
    source $PARAMETER_HELPER --no-strict

    local args=("$@") # Argumentos passados pelo usuário
    local index_lang="-1"
    local iargs=() # Argumentos que serão passados para run
    local lang_args="" # Argumento --lang <vlang> a ser passado para run

    while [ "${#args[@]}" -gt 0 ]; do
        index_lang=$(shut_util_findex "--lang" "${args[@]}") #index da primeira ocorrência de --lang

        if [ "$index_lang" != "-1" ]; then
            iargs=("${args[@]:0:index_lang}")
        fi

        if [ "$index_lang" != "-1" ]; then
            if [ "${#iargs[@]}" -gt 0 ]; then
                run "${iargs[@]}" $lang_args || return $? # Gera [Desktop Entry]
            fi

            let index_lang=$index_lang+1
            lang_args="--lang ${args[index_lang]}"
            let index_lang=$index_lang+1

            args=("${args[@]:index_lang}")
        else
            if [ "${#args[@]}" -gt 0 ]; then
                run "${args[@]}" $lang_args || return $? # Gera [Desktop Entry]
            fi

            args=()
        fi
    done

    # Verificando se script foi encerrado por --help

    if [ "$present_help" = 1 ] || [ "$present_version" = 1 ]; then
    	return
    fi

    # Verificando existência de argumentos obrigatórios

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep -E \"Name=|Name\[.*\]=\"")" ]; then
        return $(m="Erro! O parâmetro --name é obrigatório!" e=$ERR_6X8X_NOT_FOUND_NAME helperr -v)
    fi

    if ! [ "$(bash -c "echo \"$desktop_entry\" | grep \"Exec=\"")" ]; then
        return $(m="Erro! O parâmetro --exec é obrigatório!" e=$ERR_6X8X_NOT_FOUND_EXEC helperr -v)
    fi

    if [ "$desktop_entry" ]; then
        if [ "$present_out" = 1 ]; then
            echo "$desktop_entry"
        else
            echo "$desktop_entry" > "$dirname/$filename.desktop"
        fi
    fi
}

main "$@" # Executa a função principal
