#!/bin/bash

#####################################################################
#                         __                                        #
#                        / /   ____  ____  ____                     #
#                       / /   / __ \/ __ \/ __ \                    #
#                      / /___/ /_/ / /_/ / /_/ /                    #
#                     /_____/\____/\____/ .___/                     #
#                                      /_/                          #
#                                                                   #
#        Nom du script: loop.sh                                     #
#          Description: Exécute un script bash et le relance        #
#                       automatiquement en cas d'arrêt ou de crash. #
#            Arguments: loop [mode] [time] [script] <arguments>     #
#              Autheur: Thibault Bustos (alias TheRake66)           #
#                       (thibault.bustos1234@gmail.com)             #
#     Date de création: 01/09/2024                                  #
# Date de modification: 01/09/2024                                  #
#              Version: 1.1.6.0                                     #
#          Dépendances: Aucune                                      #
#              Licence: MIT License                                 #
#                                                                   #
#####################################################################



# Affiche la documentation d'aide.
#
# @param
# @throws
# @return
function showUsage() {
    echo "Description:"
    echo "    Run a bash script and automatically re-run it in case of a scheduled"
    echo "    shutdown or crash."
    echo
    echo "Usage:"
    echo "    loop [mode] [time] [script] <arguments>"
    echo
    echo "Options:"
    echo "    [mode]"
    echo "        -start     Run the script and loop it."
    echo "        -stop      Stop looping the script but don't stop it."
    echo "    [time]         Timeout before re-run the script (in seconds)."
    echo "    [script]       Script file path."
    echo "    <arguments>    Argument(s) to pass to the script when running."
    echo
    echo "Example:"
    echo "    loop -start 5 ./script.sh"
    echo "    loop -start 1 ./script.sh arg1 arg2"
    echo "    loop -stop ./script.sh"
}



# Affiche une erreur et quitte le script avec un code de retour 1.
#
# @param $1 [string] Le message à afficher.
# @throws
# @return
function throwError() {
    local _message=$1
    echo "Error: $_message"
    exit 1
}



# Déclenche une erreur si le fichier n'existe pas ou n'est pas un script.
#
# @param $1 [string] Le chemin du script.
# @throws Si le fichier n'existe pas.
# @throws Si le fichier n'est pas un script.
# @return
function scriptExist() {
    local _script=$1
    if [[ ! -f $_script ]]; then
        throwError "File not found."
    elif [[ ! $_script == *.sh ]]; then
        throwError "File is'nt a bash script."
    fi
}



# Déclenche une erreur si le temps n'est pas un entier positif.
#
# @param $1 [int] Le temps en secondes.
# @throws Si le temps n'est pas un nombre entier.
# @throws Si le temps n'est pas positif.
# @return
function timeNumber() {
    local _time=$1
    if [[ ! $_time =~ ^[0-9]+$ ]]; then
        throwError "Time must be a positive integer."
    elif [[ $_time -le 0 ]]; then
        throwError "Time must be greater than 0."
    fi
}



# Exécute un script dans une autre instance avec comme répertoire de travail le répertoire du script.
#
# @param $1 [string] Chemin du script à lancer.
# @param $... [any] Liste des paramètres à passer au script.
# @throws
# @return
function runInstance() {
    local _script=$1
    local _arguments=${@:2}
    local workdir=$(dirname "$_script")
    (cd "$workdir"; bash "$_script" "$_arguments")
}



# Lance le script et lance la surveillance pour le relancer automatiquement.
#
# @param $1 [int] Nombre de secondes avant de relancer le script.
# @param $2 [string] Chemin du script à lancer.
# @param $... [any] Liste des paramètres à passer au script.
# @throws
# @return
function startLoop() {
    local _time=$1
    local _script=$2
    local _arguments=${@:3}
    local locker="$_script.loop"
    if [[ ! -f $locker ]]; then
        touch "$locker"
        echo "Loop start, first run."
        runInstance "$_script" "$_arguments"
        local count=1
        while [[ -f $locker ]]; do
            echo "Waiting $_time second(s)..."
            sleep "$_time"
            echo "Re-run for the $count time."
            ((count++))
            runInstance "$_script" "$_arguments"
        done
        echo "End of loop, $count run(s) in total."
    else
        throwError "Script already looping."
    fi
}



# Arrête la surveillance mais pas le script.
#
# @param $1 [string] Chemin du script à lancer.
# @throws
# @return
function stopLoop() {
    local _script=$1
    local locker="$_script.loop"
    if [[ -f $locker ]]; then
        rm -f "$locker"
        echo "Loop was stopped but not the script."
    else
        throwError "Script not looping."
    fi
}



# main
if [[ $# -eq 0 ]]; then
    showUsage
elif [[ $1 == "-start" ]]; then
    if [[ $# -ge 3 ]]; then
        timeNumber "$2"
        scriptExist "$3"
        startLoop "$2" "$3" "${@:4}"
    else
        throwError "Missing time or script file."
    fi
elif [[ $1 == "-stop" ]]; then
    if [[ $# -eq 2 ]]; then
        scriptExist "$2"
        stopLoop "$2"
    elif [[ $# -gt 2 ]]; then
        throwError "Too much arguments."
    else
        throwError "Missing script file."
    fi
else
    throwError "Unknown mode selected."
fi