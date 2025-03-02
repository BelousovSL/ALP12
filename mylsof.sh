#!/bin/bash

print_result(){
  printf '%-10s %-6s %-7s %-19s %-8s %-20s\n' "$1" "$2" "$3" "$4" "$5" "$6"
}

print_result "COMMAND" "PID" "TID" "TASKCMD" "USER" "NAME" 

for pid in $(ls /proc | grep -o '[0-9]*' | sort -k1n)
do   
   path_proc="/proc/"$pid/

   path_proc_stat=$path_proc"stat"
   main_stat_text=`cat $path_proc_stat`

   command=`echo $main_stat_text | awk '{print $2}' | awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }'`
   
   for pid_task_path in $(ls "/proc/"$pid/task)
   do        
        path_proc_task_id="/proc/"$pid/task/$pid_task_path/
        stat_text=`cat $path_proc_task_id/stat`

        task_cmd=`echo $stat_text | awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }' | awk '{print $1}'`
        user=`ls -la "$path_proc_task_id/stat" | awk '{print $3}'`
        
        for file in $(ls -la "$path_proc_task_id"fd | awk -F '->' '{print $2}')
        do            
            print_result $command $pid $pid_task_path $task_cmd $user $file
        done    

        for file_maps in $(cat "$path_proc_task_id"maps | awk '{print $6}' | grep -v -e '^$' | uniq | grep -v '^\[')
        do            
            print_result $command $pid $pid_task_path $task_cmd $user $file_maps
        done    
   done
   
done
