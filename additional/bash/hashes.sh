#!/bin/bash

declare -A stuff	# Define an associative array, this can be skipped
# Assigning values to an associative array
my_key='my key1'
stuff[my key]="my value"
stuff["my key"]="my value"
stuff[$my_key]="my value1"
echo "Keys count:"
echo "${#stuff[*]}"
echo "${#stuff[@]}"
read
echo "All keys:"
echo "${!stuff[*]}"
echo "${!stuff[@]}"
read
echo "All values:"
echo "${stuff[*]}"
echo "${stuff[@]}"
read

echo 'for i in "${stuff[@]}"; do'
# One array entry per line
for i in "${stuff[@]}"; do
	echo "|$i|"
done
echo 'for i in "${stuff[*]}"; do'
# The whole array as a single line
for i in "${stuff[*]}"; do
	echo "|$i|"
done
echo 'for i in ${stuff[*]}; do'
# However, this is one entry per line, also
for i in ${stuff[*]}; do
	echo "|$i|"
done

