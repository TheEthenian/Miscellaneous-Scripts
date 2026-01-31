#!/bin/bash

INPUT_DIR="$(pwd)/mutable_input_files"
LOCAL_PATHS_FILE="$INPUT_DIR/rclone_backup_directories_local.txt"
REMOTE_PATHS_FILE="$INPUT_DIR/rclone_backup_directories_remote.txt"
RCLONE_REMOTE_PREFIX="TheEthenianCollection:"


if [[ ! -f $LOCAL_PATHS_FILE || ! -f $REMOTE_PATHS_FILE ]]; then
    echo "The source files $LOCAL_PATHS_FILE and $REMOTE_PATHS_FILE not found"
    exit 1
fi

        
remote_relative_directories=($(cat $REMOTE_PATHS_FILE))
local_relative_directories=($(cat $LOCAL_PATHS_FILE))


if (( ${#remote_relative_directories[@]}==${#local_relative_directories[@]} ));then
    iterations=${#remote_relative_directories[@]}
    counter=0


    while (( $counter<$iterations ));do 

        local_files=$HOME/${local_relative_directories[$counter]}
        remote_files=${remote_relative_directories[$counter]}

        echo "Started sync ${local_relative_directories[$counter]}"
        rclone sync $local_files $RCLONE_REMOTE_PREFIX$remote_files
        
        echo "Done ${local_relative_directories[$counter]}"
        ((counter++))

    done

fi    

