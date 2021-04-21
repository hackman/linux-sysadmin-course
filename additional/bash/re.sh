#!/bin/bash

if [[ ! $1 =~ ^\/[a-z]+\/$ ]]; then
	echo "Not matched \$1"
else
	echo "Matched"
fi
