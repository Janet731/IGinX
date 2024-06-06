#!/bin/bash

# 插入数据
COMMAND1='LOAD DATA FROM INFILE "Polystore-utils/gavel/auction.csv" AS CSV SKIPPING HEADER INTO gavel.auction(key,id,title,description,start_date,end_date,category,user);'
SCRIPT_COMMAND="bash client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '{}'"

bash -c "chmod +x client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh"

if [ "$RUNNER_OS" = "Linux" ]; then
  bash -c "echo '$COMMAND1' | xargs -0 -t -i ${SCRIPT_COMMAND}"
elif [ "$RUNNER_OS" = "Windows" ]; then
  bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND1'"
elif [ "$RUNNER_OS" = "macOS" ]; then
  sh -c "echo '$COMMAND1' | xargs -0 -t -I F sh client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e 'F'"
fi
