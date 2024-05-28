#!/bin/bash

# 从网站下载数据
wget https://snap.stanford.edu/data/web-Google.txt.gz
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

# 可能需要执行：
# dos2unix web-google.csv
# 获取操作系统类型
#os_type=$(uname -s)
## 判断操作系统类型
#if [ "$os_type" == "Linux" ] || [ "$os_type" == "Darwin" ] || [ "$os_type" == "FreeBSD" ] || [ "$os_type" == "SunOS" ]; then
#    echo "当前系统是Unix/Linux/Mac系统，执行dos2unix命令"
#    dos2unix web-google.csv
#elif [ "$os_type" == "CYGWIN_NT-10.0" ] || [ "$os_type" == "MINGW32_NT-6.1" ]; then
#    echo "当前系统是Windows系统，不需要执行dos2unix命令"
#else
#    echo "未知的操作系统类型"
#fi

index=0
# 读取文件并在每一行前面加上序号
while IFS= read -r line; do
  echo "$index,$line" >> web-Google2.csv
  index=$((index + 1))
done < $output_file

cat web-Google2.csv | head -n 10

set -e

COMMAND1='LOAD DATA FROM INFILE "web-Google2.csv" AS CSV SKIPPING HEADER INTO pagerank(key, fromnode, tonode);'
COMMAND2='CREATE FUNCTION UDSF "pagerank" FROM "UDSFpagerank" IN "test/src/test/resources/polybench/udf/udsf_pagerank.py";'
COMMAND3='select * from (select pagerank(key, fromnode, tonode) as pagerank from pagerank) order by pagerank desc limit 100;'

SCRIPT_COMMAND="bash client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '{}'"

bash -c "chmod +x client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh"

if [ "$RUNNER_OS" = "Linux" ]; then
  bash -c "echo '$COMMAND1$COMMAND2$COMMAND3' | xargs -0 -t -i ${SCRIPT_COMMAND}"
elif [ "$RUNNER_OS" = "Windows" ]; then
  bash -c "client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.bat -e '$COMMAND1$COMMAND2$COMMAND3'"
elif [ "$RUNNER_OS" = "macOS" ]; then
  sh -c "echo '$COMMAND1$COMMAND2$COMMAND3' | xargs -0 -t -I F sh client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e 'F'"
fi