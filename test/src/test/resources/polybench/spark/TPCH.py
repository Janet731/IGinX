import os
import time
from pyspark.sql import SparkSession

# 创建SparkSession
spark = SparkSession.builder \
    .appName("TPC-H All Tables Read and SQL Queries") \
    .getOrCreate()

# 定义TPC-H表及其列名
tpch_tables = {
    "lineitem": ["l_orderkey", "l_partkey", "l_suppkey", "l_linenumber", "l_quantity", "l_extendedprice",
                 "l_discount", "l_tax", "l_returnflag", "l_linestatus", "l_shipdate", "l_commitdate",
                 "l_receiptdate", "l_shipinstruct", "l_shipmode", "l_comment", "dummy"],
    "orders": ["o_orderkey", "o_custkey", "o_orderstatus", "o_totalprice", "o_orderdate", "o_orderpriority",
               "o_clerk", "o_shippriority", "o_comment", "dummy"],
    "customer": ["c_custkey", "c_name", "c_address", "c_nationkey", "c_phone", "c_acctbal", "c_mktsegment", "c_comment", "dummy"],
    "nation": ["n_nationkey", "n_name", "n_regionkey", "n_comment", "dummy"],
    "region": ["r_regionkey", "r_name", "r_comment", "dummy"],
    "part": ["p_partkey", "p_name", "p_mfgr", "p_brand", "p_type", "p_size", "p_container", "p_retailprice", "p_comment", "dummy"],
    "partsupp": ["ps_partkey", "ps_suppkey", "ps_availqty", "ps_supplycost", "ps_comment", "dummy"],
    "supplier": ["s_suppkey", "s_name", "s_address", "s_nationkey", "s_phone", "s_acctbal", "s_comment", "dummy"]
}

# 读取每个表并设置列名
data_dir = "tpc/TPC-H V3.0.1/data"
for table, columns in tpch_tables.items():
    file_path = f"{data_dir}/{table}.tbl"
    df = spark.read.option("delimiter", "|") \
        .option("header", "false") \
        .option("inferSchema", "true") \
        .csv(file_path) \
        .toDF(*columns)
    df.createOrReplaceTempView(table)
    row_count = df.count()
    print(f"Table {table} has {row_count} rows.")

# 读取SQL文件夹并执行查询
sql_dir = "test/src/test/resources/polybench/spark/queries"
query_times = {}

for sql_file in os.listdir(sql_dir):
    if sql_file.endswith(".sql"):
        file_path = os.path.join(sql_dir, sql_file)
        with open(file_path, "r") as file:
            query = file.read()
            start_time = time.time()
            spark.sql(query).show()  # 执行查询并显示结果
            end_time = time.time()
            elapsed_time = end_time - start_time
            query_times[sql_file] = elapsed_time
            print(f"Query {sql_file} executed in {elapsed_time:.2f} seconds")

# 显示所有查询的执行时间
for query, elapsed_time in query_times.items():
    print(f"{query}: {elapsed_time:.2f} seconds")

# 停止SparkSession
spark.stop()
