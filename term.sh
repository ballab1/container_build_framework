#!/bin/bash
#############################################################################
#
#   term-codes.sh
#
############################################################################# 

declare -r BLANK=''
declare -r RESET=0
declare -r LF=$'\n'
declare -rA FOREGROUND=( [default]=39 [black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 \
                         [cyan]=36 [lt_gray]=37 [dk_gray]=90 [lt_red]=91 [lt_green]=92 [lt_yellow]=93 \
                         [lt_blue]=94 [lt_magenta]=95 [lt_cyan]=96 [white]=97 )

declare -rA BACKGROUND=( [default]=49 [black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 \
                         [cyan]=46 [lt_gray]=47 [dk_gray]=100 [lt_red]=101 [lt_green]=102 [lt_yellow]=103 \
                         [lt_blue]=104 [lt_magenta]=105 [lt_cyan]=106 [white]=107 )

declare -rA ATTR_SETTERS=( [bold]=1 [dim]=2 [underline]=4 [blink]=5 [invert]=7 [hidden]=8 )

declare -rA ATTR_RESET=( [bold]=21 [dim]=22 [underline]=24 [blink]=25 [invert]=27 [hidden]=28 [all]=$RESET )

#declare -ra TERM_CODES=( 'FOREGROUND' 'BACKGROUND' 'ATTR_SETTERS' 'ATTR_RESET' )

declare LOG=term.log

############################################################################# 
function term.codes()
{
    local -r code=${1:?'Input parameter "code" must be defined'}

    printf "\e[%dm" $code
}

############################################################################# 
function term.decode()
{
    local -r name=${1:?'Input parameter "name" must be defined'}

    case "$name" in
         task)     term.codes ${FOREGROUND[lt_cyan]};;
         info)     term.codes ${FOREGROUND[lt_green]};;
         warn)     term.codes ${FOREGROUND[lt_yellow]};;
        error)     term.codes ${FOREGROUND[red]};;
        reset)     term.codes ${ATTR_RESET[all]};;
            *)     term.codes ${FOREGROUND[$name]};;
    esac
}

############################################################################# 
function term.getFb()
{
    local -r fg=${1:?'Input parameter "fg" must be defined'}
    local -r bg=${2:?'Input parameter "bg" must be defined'}

    printf "\e[%d;%dm" ${FOREGROUND[fg]} ${BACKGROUND[bg]} 
}

#############################################################################
function term.header()
{
    local -r name=${1:?'Input parameter "name" must be defined'}
    local -r bars='+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

    $LOG "${LF}${bars}${LF}" 'blue'
    $LOG "Building container: $( term.decode 'white' )${name}${LF}" 'lt_blue'
    $LOG "${bars}${LF}" 'blue'
}

#############################################################################
function term.log()
{
    local -r msg=${1:?'Input parameter "msg" must be defined'}
    local -r msg_type=${2:?'Input parameter "msg_type" must be defined'}

    printf "%s%s%s" $( term.decode $msg_type ) "$msg" $( term.decode 'reset' )
}
