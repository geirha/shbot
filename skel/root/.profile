read RANDOM
read date
date -s "@$date" > /dev/null 2>&1
printf %d "$RANDOM" > /dev/urandom

unset date

[ -n "$BASH" ] && . ~/.bashrc

# Signal that the shell is ready
printf '\n'
