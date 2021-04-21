#!/bin/bash

line="20312 S 21-03-2021 321213 name"

echo "String count:"
echo $line|wc -c
echo -n $line|wc -c
echo ${#line}
read

echo "Match everywhere in the line:"
echo -e "${line/S/KK}\t\t\${line/S/KK}"
echo -e "${line/2/6}\t\t\${line/2/6}"
echo -e "${line//2/6}\t\t\${line//2/6}"
read
echo "Prefix match:"
echo -e "${line#[0-9]}\t\t\${line#[0-9]}"
echo -e "${line#[0-9]*}\t\t\${line#[0-9]*}"
echo -e "${line#[0-9]* }\t\t\${line#[0-9]* }"
echo -e "${line##[0-9]* }\t\t\${line##[0-9]* }"
read
echo "Suffix match:"
echo -e "${line%[a-zA-Z]*}\t\t\${line%[a-zA-Z]}"
echo -e "${line%[a-zA-Z]*}\t\t\${line%[a-zA-Z]*}"
echo -e "${line% [a-zA-Z]*}\t\t\${line% [a-zA-Z]*}"
echo -e "${line%% [a-zA-Z]*}\t\t\${line%% [a-zA-Z]*}"
read
echo "Offsets:"
echo -e "${line:0:5}\t\t\${line:0:5} only the first 5 chars"
echo -e "${line::5}\t\t\${line::5} only the first 5 chars"
echo "erything without the first 5 chars"
echo -e "${line:5}\t\t\${line:5}"
echo -e "${line:5:-5}\t\t\${line:5:-5}"
echo "Case convertion: let IT be 12 rain"
a='let IT be 12 rain'
echo "Original: $a"
echo -e "${a^}\t\t\${a^}"
echo -e "${a^^}\t\t\${a^^}"
echo -e "${a,}\t\t\${a,}"
echo -e "${a,,}\t\t\${a,,}"
a="things may be 'quoted' or \"double quoted"\"
echo "Original: $a"
echo -e "${a@Q}\t\t\${a@Q}"
echo -e "${a@A}\t\t\${a@A}"
