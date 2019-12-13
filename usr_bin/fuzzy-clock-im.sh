#!/bin/bash

if [[ $# -eq 2 ]]; then
	hr=$1
	min=$2
else
	hr=($(date '+%_H'))
	min=10#$(date '+%M')
fi

nearlys[0]="almost"
nearlys[1]="soon"
nearlys[2]="nearly"
rand=$[$RANDOM % ${#nearlys[@]}]
nearly=${nearlys[$rand]}

justafters[0]="short after"
justafters[1]="just past"
justafters[2]="past"
justafters[3]="after"
rand=$[$RANDOM % ${#justafters[@]}]
justafter=${justafters[$rand]}

if [[ ( $min -gt 47 && $min -lt 57 ) || ( $min -gt 17 && $min -lt 27 ) || ( $min -ge 37 && $min -lt 43) ]]; then
	adv=$nearly
elif [[ ( $min -lt 13 && $min -gt 3 ) ]]; then
	adv=$justafter
fi

if [[ $min -gt 17 && $min -lt 37 ]]; then
    adj=$"half past"
fi

if [[ $min -ge 13 && $min -le 17 ]]; then
    adj=$"a quarter past"
fi

if [[ $min -ge 37 && $min -le 47 ]]; then
    adj=$"a quarter to"
fi

if [[ $min -ge 37 ]]; then
    hr=$((hr + 1))

    if [[ $hr -eq 24 ]]; then
        hr=0
    fi
fi

case $hr in
    1|13)
        th=$"one"
        ;;
    2|14)
        th=$"two"
        ;;
    3|15)
        th=$"three"
        ;;
    4|16)
        th=$"four"
        ;;
    5|17)
        th=$"five"
        ;;
    6|18)
        th=$"six"
        ;;
    7|19)
        th=$"seven"
        ;;
    8|20)
        th=$"eight"
        ;;
    9|21)
        th=$"nine"
        ;;
    10|22)
        th=$"ten"
        ;;
    11|23)
        th=$"eleven"
        ;;
    0)
        th=$"midnight"
        ;;
    12)
        th=$"noon"
esac

if [[ -z "$adv" && -z "$adj" ]]; then
	printf $"$th\n"
fi

if [[ -z "$adv" && -n "$adj" ]]; then
	printf $"$adj $th\n"
fi

if [[ -n "$adv" && -z "$adj" ]]; then
    printf $"$adv $th\n"
fi

if [[ -n "$adv" && -n "$adj" ]]; then
	printf $"$adv $adj $th\n"
fi
