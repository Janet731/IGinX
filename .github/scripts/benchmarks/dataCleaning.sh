#!/bin/bash

set -e

COMMAND1='LOAD DATA FROM INFILE "test/src/test/resources/dataCleaning/zipcode_city.csv" AS CSV INTO uszip(key,city,zipcode);'
COMMAND2="SELECT count(a.zipcode) FROM uszip as a JOIN uszip as b ON a.zipcode = b.zipcode WHERE a.city <> b.city;"

SCRIPT_COMMAND="bash client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '{}'"

bash -c "chmod +x client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh"
output_file="${GITHUB_WORKSPACE}/output.txt"
if [ "$RUNNER_OS" = "Linux" ]; then
  bash -c "echo '$COMMAND1' | xargs -0 -t -i ${SCRIPT_COMMAND}"
elif [ "$RUNNER_OS" = "Windows" ]; then
  bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND1'"
elif [ "$RUNNER_OS" = "macOS" ]; then
  sh -c "echo '$COMMAND1' | xargs -0 -t -I F sh client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e 'F'"
fi
for i in {1..5}
do
  if [ "$RUNNER_OS" = "Linux" ]; then
    bash -c "echo '$COMMAND2' | xargs -0 -t -i ${SCRIPT_COMMAND}" > tmp.txt
  elif [ "$RUNNER_OS" = "Windows" ]; then
    bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND2'" > tmp.txt
  elif [ "$RUNNER_OS" = "macOS" ]; then
    sh -c "echo '$COMMAND2' | xargs -0 -t -I F sh client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e 'F'" > tmp.txt
  fi
  cat tmp.txt
  last_line=$(tail -n 1 tmp.txt)
  echo "$last_line"
  # 将最后一行写入 output.txt
  echo "$last_line" >> ${output_file}
done
echo --------------------------------
cat ${output_file}
echo --------------------------------