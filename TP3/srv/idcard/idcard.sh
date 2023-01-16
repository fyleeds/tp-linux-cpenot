echo "
Machine name : $(hostnamectl | grep hostname | cut -d ':' -f2)
OS $(cat /etc/redhat-release) and kernel version is $(uname -r)
IP : $(ip a | grep inet | head -3 | tail -1 | cut -d ' ' -f6)
RAM : $(free -m | grep Mem | cut -d ' ' -f29) memory available on $(free -m | grep Mem | cut -d ' ' -f12
1812) total memory
Disk : $( df -H -t xfs | grep root | tr -s [:space:] ' '| cut -d ' ' -f4) space left
Top 5 processes by RAM usage :"

while read super_line; do

echo "- ${super_line}" 

done <<< "$(ps -eo cmd= --sort=-%mem | cut -d '/' -f 4| head -5)"

echo "Listening ports:"
while read super_line; do
 
  type=$(echo "${super_line}" | cut -d' ' -f1)
  port=$(echo "${super_line}" | cut -d' ' -f5| cut -d ':' -f2)
  process=$(echo "${super_line}" | cut -d' ' -f7 | cut -d '"' -f2)
  echo "- ${type} ${port} ${process}"

done <<< "$(ss -lnp4H | tr -s ' ')"

echo "
Here is your random cat : ./cat.jpg
"
