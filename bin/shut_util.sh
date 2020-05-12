#!/bin/bash

# Script contendo vários utilitários
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

# Exibe na saída padrão uma string de um array unido por meio
# de um separador
#
# shut_util_join "<sep>" "${<array>[@]}"
#
# shut_util_join --help # show help
function shut_util_join {
    local sep="$1"
	shift
	local rt="$1"
	shift

	for v in "$@"; do
		rt="${rt}${sep}${v}"
	done

	printf "$rt\n"
}

# Verifica se uma string está dentro de um array. Se a string
# estiver no array, finaliza-se a função corretamente. Caso
# contrário, a função é encerrada com erro
#
# shut_util_contains "<string>" "${<array>[@]}"
#
# shut_util_contains --help # show help
function shut_util_contains {
    if [ $# -eq 0 ]; then
        return 0
    fi

    local target="$1"
    shift

    local index=0
    for key in "$@"; do
        if [ "$key" = "$target" ]; then
            return 0
        fi

        let index=$index+1
    done

    return 1
}

# Cria um array de uma string por meio de um separador
#
# shut_util_array "<separador>" <string>
# array=("${shut_util_return[@]}") # array
#
# shut_util_array --help # show help
function shut_util_array {
    local sep="$1"
    local len_sep=${#sep}
    local i_last_sep
    let i_last_sep=$len_sep-1
    shift

    local args="$@"
    local len_args=${#args}

    shut_util_return=()
    local i_return=0

    if [ "$len_args" != "0" ]; then
        shut_util_return[0]=""
    fi

    local ch
    local sub
    for (( i=0; i < len_args; i++ )); do
        ch="${args:i:1}"
        sub="${args:i:len_sep}"

        if [ -z "$sep" ]; then
            shut_util_return[$i_return]="${ch}"
            let i_return=$i_return+1
        elif [ "$sub" = "$sep" ]; then
            let i_return=$i_return+1
            shut_util_return[$i_return]=""
            let i=$i+$i_last_sep
        else
            shut_util_return[$i_return]="${shut_util_return[i_return]}${ch}"
        fi
    done
}