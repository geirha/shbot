echo "Ready"
read RANDOM
read date
date -s "1970-01-01 + $date seconds" > /dev/null 2>&1
echo "$RANDOM" > /dev/urandom

unset date
rm /root/.profile
