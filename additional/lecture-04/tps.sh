#!/bin/bash

case "$1" in
   'time'|'t')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort etime|awk '{if ($6>32000) print $0}'
   ;;
   'user'|'u')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort user|awk '{if ($6>32000) print $0}'
   ;;
   'cpu'|'c')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort pcpu|awk '{if ($6>32000) print $0}'
   ;;
   'mem'|'m')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort pmem|awk '{if ($6>32000) print $0}'
   ;;
   'uid')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort uid|awk '{if ($6>32000) print $0}'
   ;;
   'cmd')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort args|awk '{if ($6>32000) print $0}'
   ;;
   'pid'|'p')
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort pid|awk '{if ($6>32000) print $0}'
   ;;
   'help'|'h')
     echo -e "Userfriendly process listing.\nUsage:\n user - sort by usernames\n time - sort by elapsed time\n cpu - sort by cpu usage\n mem - sort by memory usage\n uid - sort by uid\n cmd - sort by command\n pid - sort by pid\nDefault: sort by usernames"
   ;;
   *)
     ps -e -o pid,user,pmem,pcpu,etime,uid,args --sort user|awk '$2 !~ /root/{if ($6>32000) print $0}'
esac
