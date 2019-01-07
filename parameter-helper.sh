#!/bin/bash
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# github: github.com/emanuelmoraes-dev

function helpout {
	echo
	echo "    Utilitário cujo objetivo é receber um conjunto de argumento nomeados"
	echo "    e separar os valores de seus argumentos"
	echo
	echo "    Parâmetros:"
	echo "        -index: Posição do argumento na qual será retornado seus valores"
	echo "        -args: Nomes dos argumentos esperados para o usuário passar"
	echo "        -sep: Separador utilizado para separar os vários elementos"
	echo "            de um array de valores passados pelo usuário"
	echo
	echo "    Exemplo de uso:"
	echo "        IFS=$'\n' # Separador padrão"
	echo "        v1=(`./parameter-helper.sh -index 0 -args v1 nomes idades --idades 18 20 --nomes Emanuel Pedro`) # Array vazio"
	echo "        nomes=(`./parameter-helper.sh -index 1 -args v1 nomes idades --idades 18 20 --nomes Emanuel Pedro`) # Array com 'Emanuel' e 'Pedro'"
	echo "        IFS='+' # Separador passado no argumento '-sep'"
	echo "        idades=(`./parameter-helper.sh -sep + -index 2 -args v1 nomes idades --idades 18 20 --nomes Emanuel Pedro`) # Array com 18 e 20"
	echo "        IFS=' ' # volta ao separador padrão do sistema"
	echo
	echo "    Autor: Emanuel Moraes de Almeida"
	echo "    Email: emanuelmoraes297@gmail.com"
	echo "    github: github.com/emanuelmoraes-dev"
	echo
}

if [ "$1" = "--help" ]; then
	helpout # Executa função de ajuda
	exit 0 # Finaliza Script com Sucesso!
fi

param="" # Parâmetro atual na qual está sendo extraído seus valores
index="0" # Posição na do parâmetro que terá seus valores retornados
sep=$'\n' # Separador utilizado para separar os vários elementos de um array de valores passados pelo usuário
args=() # Argumentos que serão esperados
resp=() # Array Resposta do Script

for p in "$@"; do # Percorre todos os argumentos passados pelo usuário
    if [[ $p == --* ]]; then # Se o argumento começar por '--'
        param="$p" # 'param' recebe o argumento

        if [ "${#args[@]}" = "0" ]; then # Se 'args' estiver vazio
            exit 1 # Finaliza o Script com erro
        fi

        flag=0 # Argumento 'param' ainda não encontrado em 'args'
        len=${#args[@]}
        for ((i=0 ; i < len ; i++)); do # Percorre a lista de argumentos
            arg=${args[i]}
            if [ "$param" = "--$arg" ]; then # Se o parâmetro foi encontrado na lista de argumentos
                flag=1 # Argumento 'param' foi encontrado em 'args'
                break # finaliza loop
            fi
        done

        if [ "$flag" = "0" ]; then # Se 'param' não foi encontrado em 'args'
            echo $param
            exit 2 # finaliza Script com erro
        fi

    elif [ "$p" = "-args" ] || [ "$p" = "-index" ] || [ "$p" = "-sep" ]; then

        param="$p"

        if [ "$p" = "-sep" ]; then
            sep=" "
        fi

    elif [ "$param" = "-index" ]; then

        index="$p"
	
	elif [ "$param" = "-sep" ]; then

		sep="$p"

    elif [ "$param" = "-args" ]; then # Se 'param' é o parâmetro para setar os argumentos

        len=${#args[@]} # Tamanho do array
        args[$len]="$p" # Adiciona no fim do array de 'args' o argumento
        resp[$len]="" # Adiciona no fim do array de 'resp' uma string vazia
        
    else
        if [ "${#args[@]}" = "0" ]; then # Se 'args' estiver vazio
            exit 3 # Finaliza Script com erro
        fi

        len=${#args[@]}
        for ((i=0 ; i < len ; i++)); do # Percorre a lista de argumentos
            arg="${args[i]}"
            if [ "$param" = "--$arg" ]; then # Se o 'param' foi encontrado na lista de argumentos
                if [ -z "${resp[$i]}" ]; then
                    resp[$i]="$p" # Um novo valor para o argumento de posição 'i'
                else
                    resp[$i]="${resp[$i]}${sep}${p}" # Um novo valor para o argumento de posição 'i'
                fi

                break # Finaliza loop
            fi
        done
    fi
done

echo "${resp[index]}" # Retorna os valores do argumento da posição '-index'

