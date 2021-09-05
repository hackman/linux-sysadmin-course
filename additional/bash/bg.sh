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
