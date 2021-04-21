#!/bin/bash

declare -a stuff	# Define an array, this can be skipped
# Assigning values to an array
#stuff=( BREAK1 "long val2" val3 )
stuff=(BREAK1 "long val2" val3)

#stuff=([1]="string 1", [2]="string 2", [4]="string 4") 
stuff[4]=value1
stuff[5]=value2
# appending to an array
#stuff=( "${stuff[*]}" new_value )
#stuff=( ${stuff[*]} new_value )
stuff=( "${stuff[@]}" new_value )
# Append one value to an array
stuff+=( n_value1 )
stuff+=( next_value2 next_value3 )
# Not what you would expect, append the string to the first element
# Whenever you use the array as a normal variable, you will be referencing
# ONLY the first element of the array
stuff+=next_value1
# Return a specific element from the array:
echo ${stuff[0]}	# return the first element of an array
echo ${stuff[2]}	# return the third element of an array
echo ${stuff[-1]}	# return the last element of an array
echo ${stuff[-2]}	# return the second to last element of an array
read
# retrun all elements of an array, you can also use @ instead of * here
echo ${stuff[*]}
read
# number of elements in an array
# Notice that you would receive the number 10 instead of 9. 
# This is happening, because "long val2" is counted as two separate entries
echo "${#stuff[*]}"
# Expanded to: "BREAK1 long val2 val3"
echo "${#stuff[@]}"
# Expanded to: "BREAK1" "long val2" "val3"
read
# One array entry per line
echo  'for i in "${stuff[@]}"; do'
for i in "${stuff[@]}"; do
	echo "|$i|"
done

# The whole array as a single line
echo 'for i in "${stuff[*]}"; do'
for i in "${stuff[*]}"; do
	echo "|$i|"
done
# However, this is one entry per line, also
echo 'for i in ${stuff[*]}; do'
for i in ${stuff[*]}; do
	echo "|$i|"
done

