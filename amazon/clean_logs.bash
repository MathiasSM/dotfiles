#!/bin/bash
# script that cleans all the archived logs of the apollo environments
APOLLO_HOME='/apollo/env';
LOG_DIR='var/output/logs';
#add the environments that needs to be ignored for clean up in the array
IGNORED_ENVIRONMENTS=()

should_ignore_environment(){
    env_directory=$1;
    for environment_name in "${IGNORED_ENVIRONMENTS[@]}";
    do
        if [[ "$env_directory" == *"$environment_name" ]]; then
            return 0;
        fi
    done
    return 1;
}

clean_up_environment(){
    env_directory=$1;
    echo "about to clean up the enivronment $env_directory";
    logs_directory="${env_directory}/$LOG_DIR";
    echo "logs directory is $logs_directory";
    if [ -d "$logs_directory" ]; then
        for file in "$logs_directory"/*;
        do
          if [[ "$file" == *.gz ]]; then
            echo "removing the log file $file"
            rm -f "$file";
          fi
        done
    else
       echo "logs directory does not exist in $env_directory";
    fi;
}

echo 'started executing the log clean up script';
for env_directory in "$APOLLO_HOME"/*;
do
    if should_ignore_environment "$env_directory"; then
        echo "ignoring directory $env_directory"
    else
        clean_up_environment $env_directory;
    fi;

done
echo 'Finished executing the script';
