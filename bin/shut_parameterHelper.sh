#!/bin/bash

VERSION=1.0.0

# Utilitário cujo objetivo é receber um conjunto de parâmetros
# nomeados e separar os valores de seus parâmetros. Se usado com
# o 'source', o resultado para cada parâmetro fica disponível na
# variável 'shut_parameterHelper_args'
#
# Parâmetros:
#     --help: Mostra todas as opções. Opcional"
#     --version = Mostra a versão atual deste script. Opcional
#     --index = Posição do parâmetro na qual será retornado seus
#         valores. Valor padrão: 0
#     --out = Exibe os valores do parâmetro da posição --index na
#         saída padrão
#     --exists = Lança erro se o parâmetro de --index não foi
#         passado pelo usuário. Encerra a aplicação com sucesso
#         caso o parâmetro foi passado. Opcional
#     --sep = Separador utilizado para separar os vários elementos
#         de uma lista de valores passados pelo usuário. Valor
#         padrão: $'\n'
#     --is-param = String na qual todos os parâmetros nomeados devem
#         começar. Este parâmetro deve sempre vir antes do parâmetro
#         --params. Valor padrão: -
#     --params = Nomes dos parâmetros esperados para o usuário passar
#         (ignorando o valor de --is-param, que por padrão é '-').
#         Obrigatório
#     --flag-params = Nomes dos parâmetros presentes em --params que
#         não esperam nenhum valor. Um parâmetro marcado nesta opção
#         pode ser inserido no meio dos valores de um outro parâmetro.
#         Opcional
#     --create-exists-array = Cria um array
#         (shut_parameterHelper_exists) para informar se cada parâmetro
#         de cada posição foi infomado pelo usuário (0 - não, 1 - sim)
#     --no-strict = Impede o lançamento de erro por parâmetro
#         desconhecido
#     @@ = Informa que os argumentos começarão a ser analizados.
#         Obrigatório
#
# Exemplo 1:
#     source parameter-helper --sep + --params -v1 -nomes -idades @@ --idades "" 20 40 --nomes Emanuel Pedro
#
#     shut_util_array + "${shut_parameterHelper_args[2]}"
#
#     # Array de tamanho 3 com os valores '' '20' e '40'
#     idades=("${shut_util_return[@]}")
#
# Exemplo 2:
#     # Se o parâmetro --v1 foi passado
#     if parameter-helper --exists --is-param @ --index 0 --params v1 nomes idades @@ @v1 1 2 3 @idades 18 20 @nomes Emanuel Pedro; then
#
#         source parameter-helper
#
#         shut_util_array $'\n' "`parameter-helper --out --is-param @ --index 0 --params v1 nomes idades @@ @v1 1 2 3 @idades 18 20 @nomes Emanuel Pedro`"
#
#         v1=("${shut_util_return[@]}") # Array com '1', '2' e '3'
#     fi
#
# Exemplo 3:
#     source parameter-helper --create-exists-array --params -v1 -nomes -idades @@ --idades 18 20 --nomes Emanuel Pedro
#
#     shut_util_array $'\n' "${shut_parameterHelper_args[0]}"
#
#     v1=("${shut_util_return[@]}") # Array vazio
#
#     # Se o parâmetro --nome foi passado
#     if [ "${shut_parameterHelper_exists[1]}" = 1 ]; then
#
#         shut_util_array $'\n' "${shut_parameterHelper_args[1]}"
#
#         # Array com 'Emanuel' e 'Pedro'
#         nome=("${shut_util_return[@]}")
#     fi
#
# Exemplo 4: (Argumentos com string vazias são ignoradas nesta forma de uso)
#     IFS=$'\n' # Define o separador do sistema
#
#     # Array de tamanho 2 com os valores '20' e '40'
#     idades=(`parameter-helper --out --index 2 --params -v1 -nomes -idades @@ --idades \"\" 20 40 --nomes Emanuel Pedro`)
#
#     IFS=$'+' # Define o separador do sistema
#
#     # Array de tamanho 2 com os valores 'Emanuel' e 'Pedro'
#     nomes=(`parameter-helper --out --sep + --index 1 --params -v1 -nomes -idades @@ --idades "" 20 40 --nomes Emanuel Pedro`)
#
#     IFS=' ' # Volta ao separador padrão do sistema
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

# NOME DAS LIBS GLOBAIS A SEREM IMPORTADAS
SHUT_UTIL_NAME="shut-util"

# CÓDIGOS DE ERRO DO SCRIPT (30-59)
## NOT FOUND (3X)
ERR_3X5X_NOT_FOUND_SHUT_UTIL=31
ERR_3X5X_NOT_FOUND_SHUT_UTIL_CONTAINS=32
## EMPTY (4X)
ERR_3X5X_EMPTY_PARAMS=41
ERR_3X5X_EMPTY_ARGS=42
## INVALID (5X)
ERR_3X5X_INVALID_PARAMETER=52
ERR_3X5X_INVALID_ARGUMENTS=53

function _shut_parameterHelper_helpout {
    echo
    echo "    Utilitário cujo objetivo é receber um conjunto de parâmetros"
    echo "    nomeados e separar os valores de seus parâmetros. Se usado com"
    echo "    o 'source', o resultado para cada parâmetro fica disponível na"
    echo "    variável 'shut_parameterHelper_args'"
    echo
    echo "    Parâmetros:"
    echo "        --help: Mostra todas as opções. Opcional"
    echo "        --version: Mostra a versão atual deste script"
    echo "        --index = Posição do parâmetro na qual será retornado seus"
    echo "            valores. Valor padrão: 0"
    echo "        --out = Exibe os valores do parâmetro da posição --index na"
    echo "            saída padrão"
    echo "        --exists = Lança erro se o parâmetro de --index não foi"
    echo "            passado pelo usuário. Encerra a aplicação com sucesso"
    echo "            caso o parâmetro foi passado. Opcional"
    echo "        --sep = Separador utilizado para separar os vários elementos"
    echo "            de uma lista de valores passados pelo usuário. Valor"
    echo "            padrão: \$'\n'"
    echo "        --is-param = String na qual todos os parâmetros nomeados devem"
    echo "            começar. Este parâmetro deve sempre vir antes do parâmetro"
    echo "            --params. Valor padrão: -"
    echo "        --params = Nomes dos parâmetros esperados para o usuário passar"
    echo "            (ignorando o valor de --is-param, que por padrão é '-')."
    echo "            Obrigatório"
    echo "        --flag-params = Nomes dos parâmetros presentes em --params que"
    echo "             não esperam nenhum valor. Um parâmetro marcado nesta opção"
    echo "             pode ser inserido no meio dos valores de um outro parâmetro."
    echo "             Opcional"
    echo "        --create-exists-array = Cria um array"
    echo "            (shut_parameterHelper_exists) para informar se cada parâmetro"
    echo "            de cada posição foi infomado pelo usuário (0 - não, 1 - sim)"
    echo "        --no-strict = Impede o lançamento de erro por parâmetro"
    echo "            desconhecido"
    echo "        @@ = Informa que os argumentos começarão a ser analizados."
    echo "            Obrigatório"
    echo
    echo "    Exemplo 1:"
    echo "        source parameter-helper --sep + --params -v1 -nomes -idades @@ --idades \"\" 20 40 --nomes Emanuel Pedro"
    echo
    echo "        shut_util_array + \"\${shut_parameterHelper_args[2]}\""
    echo
    echo "        # Array de tamanho 3 com os valores '' '20' e '40'"
    echo "        idades=(\"\${shut_util_return[@]}\")"
    echo
    echo "    Exemplo 2:"
    echo "        # Se o parâmetro --v1 foi passado"
    echo "        if parameter-helper --exists --is-param @ --index 0 --params v1 nomes idades @@ @v1 1 2 3 @idades 18 20 @nomes Emanuel Pedro; then"
    echo
    echo "            source parameter-helper"
    echo
    echo "            shut_util_array $'\n' \"\`parameter-helper --out --is-param @ --index 0 --params v1 nomes idades @@ @v1 1 2 3 @idades 18 20 @nomes Emanuel Pedro\`\""
    echo
    echo "            v1=(\"\${shut_util_return[@]}\") # Array com '1', '2' e '3'"
    echo "        fi"
    echo
    echo "    Exemplo 3:"
    echo "        source parameter-helper --create-exists-array --params -v1 -nomes -idades @@ --idades 18 20 --nomes Emanuel Pedro"
    echo
    echo "        shut_util_array $'\n' \"\${shut_parameterHelper_args[0]}\""
    echo
    echo "        v1=(\"\${shut_util_return[@]}\") # Array vazio"
    echo
    echo "        # Se o parâmetro --nome foi passado"
    echo "        if [ \"\${shut_parameterHelper_exists[1]}\" = 1 ]; then"
    echo
    echo "            shut_util_array $'\n' \"\${shut_parameterHelper_args[1]}\""
    echo
    echo "            # Array com 'Emanuel' e 'Pedro'"
    echo "            nome=(\"\${shut_util_return[@]}\")"
    echo "        fi"
    echo
    echo "    Exemplo 4: (Argumentos com string vazias são ignoradas nesta forma de uso)"
    echo "        IFS=$'\n' # Define o separador do sistema"
    echo
    echo "        # Array de tamanho 2 com os valores '20' e '40'"
    echo "        idades=(\`parameter-helper --out --index 2 --params -v1 -nomes -idades @@ --idades \"\" 20 40 --nomes Emanuel Pedro\`)"
    echo
    echo "        IFS=$'+' # Define o separador do sistema"
    echo
    echo "        # Array de tamanho 2 com os valores 'Emanuel' e 'Pedro'"
    echo "        nomes=(\`parameter-helper --out --sep + --index 1 --params -v1 -nomes -idades @@ --idades \"\" 20 40 --nomes Emanuel Pedro\`)"
    echo
    echo "        IFS=' ' # Volta ao separador padrão do sistema"
    echo
    echo "    Autor: Emanuel Moraes de Almeida"
    echo "    Email: emanuelmoraes297@gmail.com"
    echo "    Github: https://github.com/emanuelmoraes-dev"
    echo
}

function _shut_parameterHelper_import {
    local DIRNAME="$(dirname "$0")"
    local UTIL="$DIRNAME/shut_util.sh"

    if ! [ -f "$UTIL" ]; then
        if type -P "$SHUT_UTIL_NAME" 1>/dev/null 2>/dev/null; then
            UTIL="$SHUT_UTIL_NAME"
        else
            printf >&2 "\e[31;1m\nErro! \"$SHUT_UTIL_NAME\" não encontrado!\e[m"
            return $ERR_3X5X_NOT_FOUND_SHUT_UTIL
        fi
    fi

    source $UTIL
}

shut_parameterHelper_args=()   # Array resposta do script
shut_parameterHelper_exists=() # Array para informar se cada parâmetro de cada posição foi infomado (0 - não, 1 - sim)

function _shut_parameterHelper_main {
    _shut_parameterHelper_import || return $? # Importa utilitários

    if [ "$1" = "--help" ]; then # Se --help estiver presente no primeiro argumento
        _shut_parameterHelper_helpout || return $? # Executa função de ajuda na saída padrão
        return 0                                   # Finaliza Script com Sucesso!
    fi

    if [ "$1" = "--version" ]; then # Se --version estiver presente no primeiro argumento
        echo "version: $VERSION"                   # Exibe a versão do script
        return 0                                   # Finaliza Script com Sucesso!
    fi

    local start_args=0                  # Flag para indicar se o parâmetro @@ já foi lido
    local present_exists=0              # Flag para indicar se o parâmetro "--exists" está presente
    local present_create_exists_array=0 # Flag para indicar se o parâmetro "--create-exists-array" está presente
    local present_out=0                 # Flag para indicar se o parâmetro "--out" está presente
    local present_no_strict=0           # Flag para indicar se o parâmetro "--no-strict" está presente
    local param=""                      # Parâmetro atual na qual está sendo extraído seus valores
    local empty_param=1                 # Informa se o parâmetro atual ainda não possui valores
    local index="0"                     # Posição do parâmetro que terá seus valores retornados
    local sep=$'\n'                     # Separador utilizado para separar os vários elementos de um array de valores passados pelo usuário
    local is_param="-"                  # String na qual todos os parâmetros nomeados devem começar
    local params=()                     # Parâmetros que serão esperados
    local flag_params=()                # Parâmetros de --params que não esperam nenhum valor (marcados como flag)
    local used_params=()                # Parâmetros nomeados usados
    local len_params=0                  # Quantidade de parâmetros já registrados
    local len_flag_params=0             # Quantidade de parâmetros já marcados como flag

    if [ "$#" = 0 ]; then
        printf >&2 "\e[31;1m\nErro! Argumentos não definidos!\e[m"
        return $ERR_3X5X_EMPTY_ARGS
    fi

    for a in "$@"; do # Percorre todos os argumentos passados pelo usuário

        if [ "$start_args" = 0 ] && (
            [ "$a" = "--params" ] ||
            [ "$a" = "--flag-params" ] ||
            [ "$a" = "--index" ] ||
            [ "$a" = "--sep" ] ||
            [ "$a" = "--exists" ] ||
            [ "$a" = "--create-exists-array" ] ||
            [ "$a" = "--out" ] ||
            [ "$a" = "--no-strict" ] ||
            [ "$a" = "--is-param" ] ||
            [ "$a" = "@@" ]
        ); then

            param="$a"

            if [ "$a" = "--index" ]; then
                index=0
            elif [ "$a" = "--sep" ]; then
                sep=$'\n'
            elif [ "$a" = "--exists" ]; then
                present_exists=1
            elif [ "$a" = "--create-exists-array" ]; then
                present_create_exists_array=1
            elif [ "$a" = "--out" ]; then
                present_out=1
            elif [ "$a" = "--no-strict" ]; then
                present_no_strict=1
            elif [ "$a" = "--is-param" ]; then
                is_param="-"
            elif [ "$a" = "@@" ]; then
                start_args=1
            fi

        elif [ "$start_args" = 0 ] && [ "$param" = "--index" ]; then

            index="$a"

        elif [ "$start_args" = 0 ] && [ "$param" = "--sep" ]; then

            sep="$a"

        elif [ "$start_args" = 0 ] && [ "$param" = "--is-param" ]; then

            is_param="$a"

        elif [ "$start_args" = 0 ] && [ "$param" = "--params" ]; then # Se 'param' é o parâmetro para setar os parâmetros

            len_params=${#params[@]}                  # Tamanho do array
            params[$len_params]="${is_param}${a}"     # Adiciona no fim do array de 'params' o argumento
            shut_parameterHelper_args[$len_params]="" # Adiciona no fim do array de 'shut_parameterHelper_args' uma string vazia

        elif [ "$start_args" = 0 ] && [ "$param" = "--flag-params" ]; then # Se 'param' é o parâmetro para setar os parâmetros marcados como flag

            len_flag_params=${#flag_params[@]}                  # Tamanho do array
            flag_params[$len_flag_params]="${is_param}${a}"     # Adiciona no fim do array de 'flag_params' o argumento

        elif [ "$start_args" = 1 ] && [[ "$a" == $is_param* ]]; then # Se o argumento for o nome de um parâmetro nomeado

            shut_util_contains || return $ERR_3X5X_NOT_FOUND_SHUT_UTIL_CONTAINS

            if shut_util_contains "$a" "${flag_params[@]}"; then
                len_used_params=${#used_params[@]}     # Tamanho do array "used_params"
                used_params[$len_used_params]="$a"     # Adiciona no final do array o parâmetro
            elif shut_util_contains "$a" "${params[@]}"; then
                param="$a"                             # 'param' recebe o argumento
                len_used_params=${#used_params[@]}     # Tamanho do array "used_params"
                used_params[$len_used_params]="$param" # Adiciona no final do array o parâmetro
                empty_param=1                          # Informa que o parâmetro atual ainda não possui valores
            elif [ "$present_no_strict" = "0" ]; then
                printf >&2 "\e[31;1m\nErro! Parâmetro $a inválido!\e[m"
                return $ERR_3X5X_INVALID_PARAMETER # Finaliza Script com erro
            fi

        elif [ "$start_args" = 1 ]; then
            if [ "$present_exists" = 1 ]; then # Se houver a opção --exists
                continue                       # Os valores não precisam ser armazenados
            fi

            if [ "${#params[@]}" = "0" ]; then # Se 'params' estiver vazio
                printf >&2 "\e[31;1m\nErro Interno! Contate o desenvolvedor. --params vazios!\e[m"
                return $ERR_3X5X_EMPTY_PARAMS # Finaliza Script com erro
            fi

            len_params=${#params[@]}
            for ((i = 0; i < len_params; i++)); do # Percorre a lista de parâmetros
                local_param="${params[i]}"
                if [ "$param" = "$local_param" ]; then # Se o 'param' foi encontrado na lista de parâmetros
                    if [ "$empty_param" = 1 ]; then
                        shut_parameterHelper_args[$i]="$a" # Um novo valor para o parâmetro de posição 'i'
                        empty_param=0
                    else
                        shut_parameterHelper_args[$i]="${shut_parameterHelper_args[$i]}${sep}${a}" # Um novo valor para o parâmetro de posição 'i'
                    fi

                    break # Finaliza loop
                fi
            done
        else
            printf >&2 "\e[31;1m\nErro! Argumentos Inválidos!\e[m"
            return $ERR_3X5X_INVALID_ARGUMENTS # Finaliza Script com erro
        fi
    done

    if [ "$present_exists" = 1 ]; then
        shut_util_contains || return $ERR_3X5X_NOT_FOUND_SHUT_UTIL_CONTAINS
        shut_util_contains "${params[index]}" "${used_params[@]}"
    else
        if [ "$present_create_exists_array" = 1 ]; then
            shut_util_contains || return $ERR_3X5X_NOT_FOUND_SHUT_UTIL_CONTAINS
            for ((i = 0; i < len_params; i++)); do
                if shut_util_contains "${params[i]}" "${used_params[@]}"; then
                    shut_parameterHelper_exists[$i]=1
                else
                    shut_parameterHelper_exists[$i]=0
                fi
            done
        fi

        if [ "$present_out" = 1 ]; then
            printf "%s\n" "${shut_parameterHelper_args[index]}" # Retorna os valores do parâmetro da posição '--index'
        fi
    fi
}

_shut_parameterHelper_main "$@" # Executa função principal
