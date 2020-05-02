#!/bin/bash

function _shut_gendesk_helpout {
	echo
	echo "    Script responsável por criar um lançador de aplicativo para uma aplicação"
	echo "    qualquer no menu do sistema. Se o usuário for root, cria-se um arquivo"
	echo "    \".desktop\" em /usr/share/applications. Caso contrário, cria-se o arquivo"
	echo "    em $HOME/.local/share/applications"
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

function _shut_gendesk_helperr {
	local err=$?

	if [ "$2" ]; then
		err="$2"
	elif [ -z "$err" ]; then
		err=200
	fi

	local message="$1"

	if [ -z "$message" ]; then
		message="Erro! Argumentos Inválidos"
	fi

	>&2 _shut_gendesk_helpout # Executa função para exibir ajuda
	>&2 printf "\n$message\n\n"
	return $err
}

function _shut_gendesk_getParameterHelper {
	local DIRNAME="`dirname "$0"`"
	local PARAMETER_HELPER="$DIRNAME/shut_parameterHelper.sh"

	if ! [ -f "$PARAMETER_HELPER" ]; then
		if which "shut_parameterHelper.sh" 1> /dev/null 2> /dev/null; then
			PARAMETER_HELPER="shut_parameterHelper.sh" 
		elif which "parameter-helper" 1> /dev/null 2> /dev/null; then
			PARAMETER_HELPER="parameter-helper"
		else
			>&2 echo "Erro! \"$DIRNAME/shut_parameterHelper.sh\" não encontrado!"
			return 100
		fi
	fi

	echo $PARAMETER_HELPER
}

function _shut_gendesk_adapter {
	local rt="$1"

	if [ -f "$rt" ] && [[ "$rt" != /* ]]; then
		if [ "$(pwd)" = "/" ]; then
			rt="/$rt"
		else
			rt="$(pwd)/$rt"
		fi
	fi

	if ! which "$rt" 1> /dev/null 2> /dev/null; then
		rt="$1"
	elif [ -f "$rt" ]; then
		rt="${rt// /\\ }"
	fi

	echo "$rt"
}

function _shut_gendesk_main {
	local PARAMETER_HELPER="`_shut_gendesk_getParameterHelper`" || return $?

	if [ $# -eq 0 ]; then
		_shut_gendesk_helperr "Erro! Argumentos vazios" 101
	fi

	source $PARAMETER_HELPER --create-exists-array --params -help -default -name -exec -icon -categories -filename -flag-exec -comment @@ --default "$@" || _shut_gendesk_helperr

	if [ ${shut_parameterHelper_exists[0]} -eq 1 ]; then
		_shut_gendesk_helpout autor || return $?
		return 0
	fi

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
	Categories="`shut_util_join \; ${args_default[3]}`" || return $?
	Filename="${args_default[4]}"
	FlagExec="${args_default[5]}"
	Comment="${args_default[6]}"

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
		Categories="`shut_util_join \; ${args_categories[@]}`" || return $?
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
		_shut_gendesk_helperr "Erro! --name não informado!" 102
	fi

	if [ -z "$Exec" ]; then
		_shut_gendesk_helperr "Erro! --exec não informado!" 103
	fi

	if [ -z "$Filename" ]; then
		Filename="$Name"
	fi

	Exec="`_shut_gendesk_adapter "$Exec"`" || return $?
	Icon="`_shut_gendesk_adapter "$Icon"`" || return $?

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
Comment=$Comment\
" > "/usr/share/applications/$Filename.desktop"
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
Comment=$Comment\
" > "$HOME/.local/share/applications/$Filename.desktop"
	fi
}

_shut_gendesk_main "$@" # Executa a função principal