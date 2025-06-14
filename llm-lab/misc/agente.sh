#!/usr/bin/env bash
# Made by 0x4171341 <alfierimorillo@gmail.com> 
# Licence: GPL-2
LC_ALL=C
LOCKFILE="/tmp/$(basename $0)_$(whoami)"
LOCKFD="150"
token="TOKEN"
url="https://n8n.example.com/webhook/path"
disponible=$(curl -s -o /dev/null -w "%{http_code}" --request POST ${url})

function clean_1() {
        rm -f /tmp/$(basename $0)_$(whoami)
        echo -e "\e[00m"
}

function lock () {
        echo {LOCKFD}>$LOCKFILE
        flock -n $LOCKFD
}

function exit_error () {
        echo "ERROR: Ya hay una instancia en ejecución. Saliendo"
        exit 1
}

if ! [[ -f $HOME/.sid.txt ]]; then
        echo $RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM > $HOME/.sid.txt
        sid=$(cat $HOME/.sid.txt)
else
        sid=$(cat $HOME/.sid.txt)
fi

if [[ -z $1 ]]; then
        modo="normal"
else
        if [[ "$1" == "retro" ]]; then
                modo="retro"
        else
                modo="normal"
        fi
fi

trap "clean_1; exit" 0 1 2 3 9 15
lock || exit_error

if [[ "$disponible" == "403" ]]; then
        echo -e "\e[00;1;92mPara salir presione Ctrl + C\e[00m"
else
        echo -e "\e[00;31mServicio no disponible.\e[00m"
        exit 1
fi

while true; do
        echo ""
        echo -e "\e[00;1;92mEscribe tu mensaje:\e[00m"
        read -t 60 prompt
        if [[ $? -gt 128 ]] ; then
                echo -e "\e[00;31mTiempo de espera agotado.\e[00m"
                exit 1
        fi
        if [[ "$modo" == "normal" ]]; then
                echo ""
                curl -s --request POST $url -d "chatInput=$prompt&sessionId=$sid" -H "Accept: application/json" -H "Authorization: Bearer $token" | jq -r '.output'
        fi
        if [[ "$modo" == "retro" ]]; then
                echo -e "\e[00;1;32m"
                curl -s --request POST $url -d "chatInput=$prompt&sessionId=$sid" -H "Accept: application/json" -H "Authorization: Bearer $token" | jq -r '.output' | pv -qL 10
        fi
done
exit 0
