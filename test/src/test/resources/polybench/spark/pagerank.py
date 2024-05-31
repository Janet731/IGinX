from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType
import time
import networkx as nx

# 创建Spark会话
spark = SparkSession.builder.appName("pagerank")\
      .master("local[*]").config("spark.driver.memory","5g")\
      .config("spark.driver.host","127.0.0.1")\
      .getOrCreate()

start = time.time()
# graph.txt file has columns 'src' and 'dst' representing edges
edges = spark.read.csv("web-Google2.csv", header=True, inferSchema=True).toPandas()
# convert to list(tuple)
start1 = time.time()
edges = [tuple(x) for x in edges.values]
print(edges[:10])
print(type(edges))
G = nx.DiGraph()   # DiGraph()表示有向图
for edge in edges:
    G.add_edge(edge[0], edge[1])   # 加入边
print(G.number_of_nodes())
print(G.number_of_edges())


# 改进后的pagerank计算，随机跳跃概率为15%，因此alpha=0.85
pr_impro_value = nx.pagerank(G, alpha=0.85)
end1 = time.time()
print("calc time: ", end1 - start1)


# sort by value
result = sorted(pr_impro_value.items(), key=lambda x: x[1], reverse=True)
print("pagerank：", result[:10])
end = time.time()
print('Execution time: ', end - start)