#!/bin/bash

# 检查是否传入了参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <parameter>"
    exit 1
fi

set -e

COMMAND1='LOAD DATA FROM INFILE "web-Google2.csv" AS CSV SKIPPING HEADER INTO pagerank(key, fromnode, tonode);'
COMMAND2='CREATE FUNCTION UDSF "pagerank" FROM "UDSFpagerank" IN "test/src/test/resources/polybench/udf/udsf_pagerank.py";'
COMMAND3='select * from (select pagerank(key, fromnode, tonode) as pagerank from pagerank) order by pagerank desc limit 100;'

SCRIPT_COMMAND="bash client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '{}'"

bash -c "chmod +x client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh"
pip install networkx
# 读取第一个参数
param=$1

# 使用参数
echo "The parameter is: $param"

if [ "$param" = "1" ]; then
  # 从网站下载数据
  if [ "$RUNNER_OS" = "Windows" ]; then
    curl -O https://snap.stanford.edu/data/web-Google.txt.gz
  else
    wget https://snap.stanford.edu/data/web-Google.txt.gz
  fi
  gzip -d web-Google.txt.gz
  echo "数据下载完成"

  # 源文件路径
  input_file="web-Google.txt"
  # 输出文件路径
  output_file="web-Google.csv"
  head -n 1000000 "$input_file" > "$input_file.temp"
  # 删除前4行并在文件开头插入一行
  sed '1,4d' "$input_file.temp" | (echo "fromnode,tonode" && cat) > "$output_file.temp"
  # 将所有\t替换为","
  sed 's/\t/,/g' "$output_file.temp" > "$output_file"
  # 删除临时文件
  rm "$output_file.temp"
  rm "$input_file.temp"
  rm "$input_file"
  echo "操作完成"


  index=0
  # 读取文件并在每一行前面加上序号
  while IFS= read -r line; do
    echo "$index,$line" >> web-Google2.csv
    index=$((index + 1))
  done < $output_file

  cat web-Google2.csv | head -n 10

  if [ "$RUNNER_OS" = "Linux" ]; then
    bash -c "echo '$COMMAND1$COMMAND2' | xargs -0 -t -i ${SCRIPT_COMMAND}"
  elif [ "$RUNNER_OS" = "Windows" ]; then
    bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND1$COMMAND2'"
  elif [ "$RUNNER_OS" = "macOS" ]; then
    sh -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '$COMMAND1$COMMAND2'"
  fi
else
  if [ "$RUNNER_OS" = "Linux" ]; then
    bash -c "echo '$COMMAND2' | xargs -0 -t -i ${SCRIPT_COMMAND}"
  elif [ "$RUNNER_OS" = "Windows" ]; then
    bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND2'"
  elif [ "$RUNNER_OS" = "macOS" ]; then
    sh -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '$COMMAND2'"
  fi
fi
output_file="${GITHUB_WORKSPACE}/output.txt"
for i in {1..5}
do
  if [ "$RUNNER_OS" = "Linux" ]; then
    bash -c "echo '$COMMAND3' | xargs -0 -t -i ${SCRIPT_COMMAND}" > tmp.txt
  elif [ "$RUNNER_OS" = "Windows" ]; then
    bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND3'" > tmp.txt
  elif [ "$RUNNER_OS" = "macOS" ]; then
    sh -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '$COMMAND3'" > tmp.txt
  fi
  cat tmp.txt
  last_line=$(tail -n 1 tmp.txt)
  # 将最后一行写入 output.txt
  echo "$last_line" >> ${output_file}
done
echo --------------------------------
cat ${output_file}
echo --------------------------------
#
#if [ "$RUNNER_OS" = "Linux" ]; then
#  bash -c "echo 'clear data' | xargs -0 -t -i ${SCRIPT_COMMAND}"
#elif [ "$RUNNER_OS" = "Windows" ]; then
#  bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e 'clear data'"
#elif [ "$RUNNER_OS" = "macOS" ]; then
#  sh -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e 'clear data'"
#fi