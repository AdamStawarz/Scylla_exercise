#!/bin/bash
echo "Bash version ${BASH_VERSION}..."

declare -a arr=("Adam" "Alberto" "Felipe")

for i in {0..10000}
  do 
    first_name=$[$RANDOM % ${#arr[@]}]
    last_name=$[$RANDOM % ${#arr[@]}]

INSERT='cqlsh -e "INSERT INTO test_keyspace.tab_STCS (first_name,last_name,location) VALUES ('"'${arr[$first_name]}'"','"'${arr[$last_name]}'"', '$RANDOM') IF NOT EXISTS;"'
eval $INSERT

done
