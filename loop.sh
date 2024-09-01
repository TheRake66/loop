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
#              Version: 1.0.4.0                                     #
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
    echo "    Run a bash script and automatically restarts it in case of a scheduled"
    echo "    shutdown or crash."
    echo
    echo "Usage:"
    echo "    loop [mode] [time] [script] <arguments>"
    echo
    echo "Options:"
    echo "    [mode]"
    echo "        -start     Start the script and watch it."
    echo "        -stop      Stop watching the script but don't stop it."
    echo "    [time]         The timeout before restarting the script (in seconds)."
    echo "    [script]       The script path."
    echo "    <arguments>    The argument(s) to pass to the script when starting."
    echo
    echo "Example:"
    echo "    loop -start 5 ./script.sh"
    echo "    loop -start 1 ./script.sh arg1 arg2"
    echo "    loop -stop ./script.sh"
    echo
    exit 0
}



# Affiche une erreur et quitte le script avec un code de retour 1.
#
# @param $1 [string] Le message à afficher.
# @throws
# @return
function throwError() {
    echo "Error: $1"
    exit 1
}



# Déclenche une erreur si le fichier n'existe pas ou n'est pas un script.
#
# @param $1 [string] Le chemin du script.
# @throws Si le fichier n'existe pas.
# @throws Si le fichier n'est pas un script.
# @return
function scriptExist() {
    script=$1
    if [[ ! -f $script ]]; then
        throwError "File not found."
    elif [[ ! $script == *.sh ]]; then
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
    time=$1
    if ! [[ $time =~ ^[0-9]+$ ]]; then
        throwError "Time must be a positive integer."
    elif [[ $time -le 0 ]]; then
        throwError "Time must be greater than 0."
    fi
}



# Lance le script et lance la surveillance pour le relancer automatiquement.
#
# @param $1 [int] Nombre de secondes avant de relancer le script.
# @param $2 [string] Chemin du script à lancer.
# @param $... [any] Liste des paramètres à passer au script.
# @throws
# @return
function startLoop() {
    time=$1
    script=$2
    arguments=${@:3}
    workdir=$(dirname "$script")
    locker="$script.loop"
    count=0
    touch "$locker"
    cd "$workdir"
    (bash "$script" "$arguments")
    while [[ -f $locker ]]; do
        echo "Waiting $time second(s)..."
        sleep "$time"
        ((count++))
        echo "Restarting for the $count time."
        (bash "$script" "$arguments")
    done
}



# Arrête la surveillance mais pas le script.
#
# @param $1 [string] Chemin du script à lancer.
# @throws
# @return
function stopLoop() {
    script=$1
    locker="$script.loop"
    rm -f "$locker"
}



if [[ $# -eq 0 ]]; then
    showUsage
elif [[ $1 = "-start" ]]; then
    if [[ $# -lt 3 ]]; then
        throwError "Missing time or script file."
    else
        timeNumber "$2"
        scriptExist "$3"
        startLoop "$2" "$3" "${@:4}"
    fi
elif [[ $1 = "-stop" ]]; then
    if [[ $# -lt 2 ]]; then
        throwError "Missing script file."
    else
        scriptExist "$2"
        stopLoop "$2"
    fi
else
    throwError "Unknown mode selected."
fi