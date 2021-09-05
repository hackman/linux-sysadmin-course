#!/bin/bash

# Example script of staring and waiting on a number of tasks at background

cmd='sleep 5'
max_threads=3
for i in {1..5}; do
	procs=()
	for m in $(seq 1 $max_threads); do
		$cmd &
		procs+=($!)
	done
	echo ${procs[*]}

	# Wait for all tasks to finish
	# After each task is finished, remove it from the array and reassign the rest of the elements
	# to the same array, so we can reference the first element.
	total=${#procs[*]}
	while [[ $total -ne 0 ]]; do
		wait ${procs[0]}
		echo "PID: ${procs[0]} finished"
		unset 'procs[0]'
		procs=(${procs[*]})
		let total--
	done
done

# A more optimal solution then the above one

count=0
# tasks will be used to store information about the pid
declare -A tasks
for i in {1..5}; do
	procs=()
	var=$((${RANDOM}%10+1))
	sleep $var &
	cmd_pid=$!
	procs+=($cmd_pid)
	tasks[$cmd_pid]="$i $var"

    let count++
    if [[ $count -eq $max_threads ]]; then
        echo "Waiting for ${procs[*]}"
        # Wait for any task to finish.
        # After a task has finished, remove it from the array and reduce the count of currently running tasks.
        # This will allow us to start the next process immediately.
        pid=''
        wait -p pid -n ${procs}
        echo "Task PID: $pid finished"
        echo ${tasks[$pid]} >> $finished_tasks
		all_procs=${procs[*]}
        procs=( $(echo ${all_procs//$pid}) )

        let count--
    fi

done
