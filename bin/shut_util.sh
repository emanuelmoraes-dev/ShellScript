#!/bin/bash

# Script contendo vários utilitários
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

# Exibe na saída padrão uma string de um array unido por meio
# de um separador
#
# shut_util_join "$sep" "${array[@]}"
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
# shut_util_contains "$string" "${array[@]}"
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
# shut_util_array "$separador" "$string"
# array=("${shut_util_return[@]}")
function shut_util_array {
    local sep=$1
    shift

    local args="$@"
    local len=${#args}
    local j=0
    local ch
    shut_util_return=()

    if [ "$len" != "0" ]; then
        shut_util_return[0]=""
    fi

    for (( i=0; i < len; i++ )); do
        ch=${args:i:1}

        if [ "$ch" = "$sep" ]; then
            let j=$j+1
            shut_util_return[$j]=""
        else
            shut_util_return[$j]="${shut_util_return[j]}${ch}"
        fi
    done
}