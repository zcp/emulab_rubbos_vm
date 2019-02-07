#!/bin/bash
# ./lock_stat.sh result_save
result=$1-"`hostname`"

#infinite loop
echo \#`date +"%Y-%m-%d-%H:%M:%S.%3N"` > $result
while :
do  
   #cat  /proc/lock_stat | sed -e  '/^--/d' -e 's/\s\s\+/,/g' -e '/^(\.\)/d'  >> $result
   cat  /proc/lock_stat | sed -e  '/^--/d' -e 's/\s\s\+/,/g' -e '/^\.\.\./d'  >> $result
   echo 0 > /proc/lock_stat

   sleep 0.1
   echo \#`date +"%Y-%m-%d-%H:%M:%S.%3N"` >> $result 
done


