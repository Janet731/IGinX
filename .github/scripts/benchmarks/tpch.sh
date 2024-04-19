#!/bin/bash

if [ "$RUNNER_OS" = "Windows" ]; then
  python thu_cloud_download.py \
    -l https://cloud.tsinghua.edu.cn/d/63b9d1a6444e47ae8ac5/ \
    -s  "."
else
  pwd
  ls
  python3 thu_cloud_download.py \
    -l https://cloud.tsinghua.edu.cn/d/63b9d1a6444e47ae8ac5/ \
    -s  "."
fi

cd tpc
pwd
unzip E86C7FBC-89AB-4825-BAFA-5CF73EC94ED3-TPC-H-Tool.zip
rm E86C7FBC-89AB-4825-BAFA-5CF73EC94ED3-TPC-H-Tool.zip
echo "TPCH数据生成工具下载完成"

cd TPC-H\ V3.0.1/dbgen
if [ "$RUNNER_OS" = "Linux" ]; then
  apt install gcc
  sudo apt-get update

elif [ "$RUNNER_OS" = "Windows" ]; then
  echo "windows"

elif [ "$RUNNER_OS" = "macOS" ]; then
  # 根据 https://blog.csdn.net/mei86233824/article/details/81066999 修改makefile文件并进行编译生成可执行文件
  cp makefile.suite makefile
  awk 'NR < 103 || NR > 111 { print } NR == 103 { print "CC      = gcc\n# Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)\n#                                  SQLSERVER, SYBASE, ORACLE, VECTORWISE\n# Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS, \n#                                  SGI, SUN, U2200, VMS, LINUX, WIN32 \n# Current values for WORKLOAD are:  TPCH\nDATABASE= SQLSERVER\nMACHINE = LINUX\nWORKLOAD = TPCH" }' makefile > new_makefile
  mv new_makefile makefile

  sed 's/#include <malloc.h>/#include <sys\/malloc.h>/' bm_utils.c > new_bm_utils.c
  mv new_bm_utils.c bm_utils.c
  sed 's/#include <malloc.h>/#include <sys\/malloc.h>/' varsub.c > new_varsub.c
  mv new_varsub.c varsub.c
fi
make
echo "TPCH数据生成工具编译完成"

./dbgen -s 1 -f
echo "数据生成完成"
# 源文件夹路径
source_folder="."

# 目标文件夹路径
destination_folder="../data"

# 确保目标文件夹存在，如果不存在则创建
mkdir -p "$destination_folder"

# 将所有*.tbl文件移动到目标文件夹
mv "$source_folder"/*.tbl "$destination_folder/"

echo "文件移动完成"