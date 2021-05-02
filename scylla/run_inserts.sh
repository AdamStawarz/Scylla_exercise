echo "Bash version ${BASH_VERSION}..."

Create_KS_cmd='cqlsh -e "SOURCE '\'./create_ks_db.cql\''"'
Populate_tab_STCS='cqlsh -e "COPY test_keyspace.tab_STCS FROM '"'temp_data.csv'"' WITH DELIMITER='"','"' AND HEADER=TRUE"'
Populate_tab_LCS='cqlsh -e "COPY test_keyspace.tab_LCS FROM '"'temp_data.csv'"' WITH DELIMITER='"','"' AND HEADER=TRUE"'
Populate_tab_TWCS='cqlsh -e "COPY test_keyspace.tab_TWCS FROM '"'temp_data.csv'"' WITH DELIMITER='"','"' AND HEADER=TRUE"'

#create header
echo first_name,last_name,location > temp_data.csv

declare -a arr=("Adam" "Alberto" "Felipe" "Amihay" "Pawel" "Blue" "Sujan")

  # for i in {0..10000}
  #   do
  #     first_name=$[$RANDOM % ${#arr[@]}]
  #     last_name=$[$RANDOM % ${#arr[@]}]
  # INSERT='cqlsh -e "INSERT INTO test_keyspace.tab_STCS (first_name,last_name,location) VALUES ('"'${arr[$first_name]}'"','"'${arr[$last_name]}'"', '$RANDOM') IF NOT EXISTS;"'
  # eval $INSERT
  # done

echo Creating CSV "temp_data.csv"

for i in {1..10000}
  do
    first_name=$[$RANDOM % ${#arr[@]}]
    last_name=$[$RANDOM % ${#arr[@]}]
    uuid=$(uuidgen)

    INSERT=''$uuid','${arr[$first_name]}','${arr[$last_name]}','$RANDOM''
    echo $INSERT >> temp_data.csv
done

echo Creating Keyspaces...
  eval $Create_KS_cmd

echo Populating data...
  eval $Populate_tab_STCS
  eval $Populate_tab_LCS
  eval $Populate_tab_TWCS