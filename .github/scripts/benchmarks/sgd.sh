#!/bin/bash

# 检查是否传入了参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <parameter>"
    exit 1
fi

set -e

COMMAND1="LOAD DATA FROM INFILE \"HIGGS.csv\" AS CSV INTO trainall(key, label,lepton_pt,lepton_eta,lepton_phi,missing_energy_magnitude,missing_energy_phi,jet1_pt,jet1_eta,jet1_phi,jet1_b_tag,jet2_pt,jet2_eta,jet2_phi,jet2_b_tag,jet3_pt,jet3_eta,jet3_phi,jet3_b_tag,jet4_pt,jet4_eta,jet4_phi,jet4_b_tag,m_jj,m_jjj,m_lv,m_jlv,m_bb,m_wbb,m_wwbb);"
COMMAND2="CREATE FUNCTION UDAF \"trainall\" FROM \"UDAFtrainall\" IN \"test/src/test/resources/polybench/udf/udaf_trainall.py\";"
COMMAND3="select trainall(key,label,lepton_pt,lepton_eta,lepton_phi,missing_energy_magnitude,missing_energy_phi,jet1_pt,jet1_eta,jet1_phi,jet1_b_tag,jet2_pt,jet2_eta,jet2_phi,jet2_b_tag,jet3_pt,jet3_eta,jet3_phi,jet3_b_tag,jet4_pt,jet4_eta,jet4_phi,jet4_b_tag,m_jj,m_jjj,m_lv,m_jlv,m_bb,m_wbb,m_wwbb) from trainall;"

SCRIPT_COMMAND="bash client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh -e '{}'"

bash -c "chmod +x client/target/iginx-client-0.6.0-SNAPSHOT/sbin/start_cli.sh"

pip install scikit-learn pandas numpy

# 读取第一个参数
param=$1

# 使用参数
echo "The parameter is: $param"

if [ "$param" = "1" ]; then

  if [ "$RUNNER_OS" = "Windows" ]; then
    python thu_cloud_download.py \
      -l https://cloud.tsinghua.edu.cn/d/dce662ee7ced4a6398e3/ \
      -s  "."
  else
    python3 thu_cloud_download.py \
      -l https://cloud.tsinghua.edu.cn/d/dce662ee7ced4a6398e3/ \
      -s  "."
  fi

  # 输出文件名
  output_file="HIGGS.csv"
  # 清空 output_file
  > $output_file

  # 初始化序号
  index=0
  # 读取文件并在每一行前面加上序号
  while IFS= read -r line; do
    echo "$index,$line" >> "$output_file"
    index=$((index + 1))
  done < sgddata/HIGGS2.csv

  echo "处理完成，结果已保存到 $output_file"
  rm sgddata/HIGGS2.csv
  rmdir sgddata

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
