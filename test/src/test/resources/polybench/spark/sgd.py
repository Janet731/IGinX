from pyspark.sql import Row
from pyspark.ml.linalg import Vectors
from pyspark.ml.classification import LogisticRegression
from pyspark.sql import SparkSession
from sklearn.model_selection import train_test_split
from sklearn.linear_model import SGDClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
import time

# 创建Spark会话
spark = SparkSession.builder.appName("sgh")\
      .master("local[*]").config("spark.driver.memory","5g")\
      .config("spark.driver.maxResultSize", "0")\
      .config("spark.driver.host","127.0.0.1")\
      .getOrCreate()

start = time.time()
# 从文件中读入数据
data = spark.read.csv('HIGGS2.csv', header=True, inferSchema=True)
end = time.time()
print('Read data time: ', end - start)

start = time.time()
# label,lepton  pT,lepton  eta,lepton  phi,missing energy magnitude,missing energy phi,jet 1 pt,jet 1 eta,jet 1 phi,
# jet 1 b-tag,jet 2 pt,jet 2 eta,jet 2 phi,jet 2 b-tag,jet 3 pt,jet 3 eta,jet 3 phi,jet 3 b-tag,jet 4 pt,jet 4 eta,
# jet 4 phi,jet 4 b-tag,m_jj,m_jjj,m_lv,m_jlv,m_bb,m_wbb,m_wwbb
# 这里要去掉'label'和'weight'两列
X = (data.drop('label')).toPandas()
y = (data.toPandas())['label']
print(y.sum()/y.count())


# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.05, random_state=100)

# 特征缩放
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 创建SGDClassifier模型
sgd_classifier = SGDClassifier(loss='hinge', alpha=0.005, max_iter=1000, random_state=100)

# 训练模型
sgd_classifier.fit(X_train_scaled, y_train)

# 预测
y_pred = sgd_classifier.predict(X_test_scaled)

# 评估模型
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy}")
print(sgd_classifier.coef_.tolist()[0])
end = time.time()
print('Training time: ', end - start)

# start = time.time()
# # 加载测试数据
# test_data = spark.read.csv('test.csv', header=True, inferSchema=True)
# X_pred = test_data.drop('EventId').toPandas()
# scaler = StandardScaler()
# X_pred_scaled = scaler.fit_transform(X_pred)
# theta = sgd_classifier.coef_.tolist()[0]
# import numpy as np
# theta = np.array(theta)[:30]
# print(theta.shape)
# print(X_pred_scaled.shape)
# y_pred = 1 / (1 + np.exp(-np.dot(X_pred_scaled, theta)))
# # map to s, b
# y_pred = np.where(y_pred > 0.51, 's'.encode('utf-8'), 'b'.encode('utf-8'))
# print(y_pred[:20])
# end = time.time()
# print('Prediction time: ', end - start)