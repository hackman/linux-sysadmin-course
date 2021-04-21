#!/bin/bash

line="some words here"

for i in $line; do
	echo "|$i|"
done
read

for i in "$line"; do
	echo "|$i|"
done
read

arr=(ok ek en)
echo 'Pritning ${arr[*]}'
for i in ${arr[*]}; do
	echo "|$i|"
done
read

echo 'Pritning "${arr[*]}"'
for i in "${arr[*]}"; do
	echo "|$i|"
done
read

echo 'Pritning ${arr[@]}'
for i in ${arr[@]}; do
	echo "|$i|"
done
read

echo 'Pritning "${arr[@]}"'
for i in "${arr[@]}"; do
	echo "|$i|"
done
read
