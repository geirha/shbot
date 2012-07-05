read RANDOM
read date
date -s "1970-01-01 + $date seconds" &> /dev/null

unset date
rm .bash_profile
