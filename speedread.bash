#!/bin/bash
#!/bin/sh
# Written by CryptoLuigi (Michael Ruperto)
# Date Created December 2016 
# Last update March 2019
# Usage, ./speedread filename [Number between 100-100]
# Example ./speedread ./book 100

function  ctrl()
{
       break 2
}

function VowelOps()
{
        if [[ ! $1 =~ [aeiouAEIOU] ]]; then
                orp=0
        elif [[ $1 =~ ^[^aeiouAEIOU]*[aeiouAEIOU][^aeiouAEIOU]*$ ]]; then
                a=$(echo "$1"| sed 's/[aeiouAEIOU]/ /' | cut -d' ' -f1)
                orp=${#a}
        else
                a=$(echo "$1"| sed 's/[aeiouAEIOU]/ /2' | cut -d' ' -f1)
                orp=${#a}
        fi
}

function colors()
{
        echo -e "${1:0:$orp}${red}${1:$orp:1}${reset}${1:$((orp+1))}"
}

function errorChecking()
{
        finish=$(date +%s)
        echo "total $i time= $((finish - start))"
        stty echo
        tput cnorm
        exit 0
}

if [ $# -gt 2 ]; then
        exit 4
fi
if [ $# -eq 2 ]; then
        if [ ! -f $1 ] || [ ! -r $1 ]; then
			echo "usage: speedread filename [speed]"
			exit 1
        fi
        if [[ ! $2 =~ ^[0-9]*$ ]]; then
			echo "Please Enter a number"
			exit 2
        fi
        if [ $2 -lt 100 ] || [ $2 -gt 1000 ]; then
			echo "Please Enter a number between 100 - 1000"
			exit 3
        fi
        readSpeed=$2
fi
if [ $# -eq 1 ]; then
        if [ ! -f $1 ] || [ ! -r $1 ]; then
            echo "usage: speadread filename [speed]"
            exit 1
        fi
        readSpeed=120
fi

i=0
red='\e[0;31m'
reset='\e[0m'
end=0
trap ctrl INT
tput civis
stty -echo

start=$(date +%s)

while read line <&3
do
        for word in $line
        do
            	tput cup 0 0
            	tput ed
                if [ $end -eq 1 ];then
                        esc
                fi
                VowelOps $word
                Cols=$(tput cols)
                Rows=$(tput lines)
				tput cup $((Rows/2-2)) $((Cols/2-15))
			echo "_________________________________"

                tput cup $((Rows/2-1)) $((Cols/2))

                echo "▼"
                tput cup $((Rows/2)) $((Cols/2-orp))
                colors $word
				tput cup $((Rows/2+1)) $((Cols/2))
				echo "▲"
				tput cup $((Rows/2+2)) $((Cols/2-15))	
			echo "_________________________________"
                i=$((i+1))

                read -s -n 1 -t "0.01" Change
                case "$Change" in
                        k) if [ $readSpeed -lt 100 ]; then
							readSpeed=$((readSpeed+10));
						fi
                        ;;
                        j) if [ $readSpeed -gt 100 ]; then
                           readSpeed=$((readSpeed-10));
                        fi
                        ;;
                esac
                wait_time=$(echo "scale=6;60/$readSpeed"| bc )
				tput cup $((Rows/2+3)) $((Cols/2+3))
                echo $readSpeed "WPM"
               	echo "Press j to dereaase speed by 10 | Press k to increase speed by 10"
				sleep $wait_time
        done

done 3< $1

finish=$(date +%s)
echo "You have read a total of $i word in $((finish - start)) seconds"
stty echo
tput cnorm
