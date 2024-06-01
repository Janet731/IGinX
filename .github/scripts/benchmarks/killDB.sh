#!/bin/bash

# 定义数据库与端口的映射（多个端口使用空格分隔）
db_ports=(
    "IoTDB12:6667 6668 6669"
    "InfluxDB:8086 8087 8088"
    "Parquet:0 0 0"          # 假设Parquet没有固定的监听端口
    "PostgreSQL:5432 5433 5434"
    "FileSystem:0 0 0"       # 假设FileSystem没有固定的监听端口
    "Redis:6379 6380 6381"
    "MongoDB:27017 27018 27019"
    "MySQL:3306 3307 3308"
)

# 获取输入参数
DB_NAME=$1

# 检查输入参数是否为空
if [ -z "$DB_NAME" ]; then
    echo "请提供数据库名称。"
    exit 1
fi

# 查找数据库对应的端口
PORTS=""
for entry in "${db_ports[@]}"; do
    IFS=":" read -r name ports <<< "$entry"
    if [ "$name" == "$DB_NAME" ]; then
        PORTS=$ports
        break
    fi
done

# 检查是否有对应的端口
if [ -z "$PORTS" ]; then
    echo "未知的数据库名称：$DB_NAME"
    exit 1
fi

# 遍历每个端口并杀掉占用该端口的任务
for PORT in $PORTS; do
    # 检查端口是否有效
    if [ "$PORT" -eq 0 ]; then
        echo "$DB_NAME 的端口 $PORT 不使用固定的监听端口或端口未知。"
        continue
    fi

    # 查找并杀掉占用端口的任务
    PIDS=$(lsof -t -i:$PORT)

    if [ -z "$PIDS" ]; then
        echo "没有找到占用端口 $PORT 的任务。"
    else
        echo "杀掉以下占用端口 $PORT 的任务：$PIDS"
        kill -9 $PIDS
        echo "端口 $PORT 上的任务已被杀掉。"
    fi
done
