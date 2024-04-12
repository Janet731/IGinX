# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# 无法单独执行，用来测试PySessionIT
import sys, traceback
sys.path.append('../session_py/')  # 将上一级目录添加到Python模块搜索路径中

from iginx.iginx_pyclient.session import Session
from iginx.iginx_pyclient.thrift.rpc.ttypes import StorageEngineType, StorageEngine, DataType, AggregateType, DebugInfoType

class Tests:
    def __init__(self):
        self.session = Session('127.0.0.1', 6888, "root", "root")
        self.session.open()
        pass

    def __del__(self):
        self.session.close()
        pass

    def addStorageEngine(self):
        retStr = ""
        try:
            import os
            os.makedirs('parquet/data', mode=0o777, exist_ok=True)
            os.makedirs('parquet/dummy', mode=0o777, exist_ok=True)
            cluster_info = self.session.get_cluster_info()
            original_cluster_info = cluster_info.get_storage_engine_list()
            for storage_engine in original_cluster_info:
                if storage_engine.port == 6670:
                    retStr = "The storage engine has been added, please delete it first\n"
                    return retStr
            self.session.add_storage_engine(
                "127.0.0.1",
                6670,
                StorageEngineType.parquet,
                {
                    "dir": f"{os.getcwd()}/parquet/data",
                    "dummy_dir": f"{os.getcwd()}/parquet/dummy",
                    "iginx_port": "6888",
                    "has_data": "true",
                    "is_read_only": "true",
                    "thrift_timeout": "30000",
                    "thrift_pool_max_size": "10",
                    "_thrift_pool_min_evictable_idle_time_millis": "600000",
                    "write_buffer_size": "104857600",
                    "write_batch_size": "1048576",
                    "flusher_permits": "16",
                    "cache.capacity": "1073741824",
                    "cache.timeout": "PT1H",
                    "cache.soft_values": "false",
                    "parquet.row_group_size": "134217728",
                    "parquet.page_size": "8192"
                }
            )
            # 输出所有存储引擎
            cluster_info = self.session.get_cluster_info()
            retStr += str(cluster_info) + "\n"
            # 删除加入的存储引擎
            self.session.execute_sql('REMOVE HISTORYDATASOURCE  ("127.0.0.1", 6670, "", "");')
            # 删除后输出所有存储引擎
            cluster_info = self.session.get_cluster_info()
            retStr += str(cluster_info) + "\n"
            # 批量加入存储引擎
            pg_engine = StorageEngine(
                "127.0.0.1",
                6670,
                StorageEngineType.parquet,
                {
                    "dir": f"{os.getcwd()}/parquet/data",
                    "dummy_dir": f"{os.getcwd()}/parquet/dummy",
                    "iginx_port": "6888",
                    "has_data": "true",
                    "is_read_only": "true",
                    "thrift_timeout": "30000",
                    "thrift_pool_max_size": "10",
                    "_thrift_pool_min_evictable_idle_time_millis": "600000",
                    "write_buffer_size": "104857600",
                    "write_batch_size": "1048576",
                    "flusher_permits": "16",
                    "cache.capacity": "1073741824",
                    "cache.timeout": "PT1H",
                    "cache.soft_values": "false",
                    "parquet.row_group_size": "134217728",
                    "parquet.page_size": "8192"
                }
            )
            self.session.batch_add_storage_engine([pg_engine])
            # 输出所有存储引擎
            cluster_info = self.session.get_cluster_info()
            retStr += str(cluster_info) + "\n"
            # 删除加入的存储引擎
            self.session.execute_sql('REMOVE HISTORYDATASOURCE  ("127.0.0.1", 6670, "", "");')
            # 删除新建的文件夹
            os.rmdir('parquet/data')
            os.rmdir('parquet/dummy')
            os.rmdir('parquet')
            # 删除后输出所有存储引擎
            cluster_info = self.session.get_cluster_info()
            retStr += str(cluster_info) + "\n"

            return retStr
        except Exception as e:
            print(e)
            retStr += str(e) + "\n"
            exit(1)

    def aggregateQuery(self):
        retStr = ""
        try:
            # 统计每个序列的点数
            dataset = self.session.aggregate_query(["test.*"], 0, 10, AggregateType.COUNT)
            retStr += str(dataset)

            return retStr
        except Exception as e:
            print(e)
            exit(1)
    def deleteAll(self):
        try:
            self.session.batch_delete_time_series(["*"])
        except Exception as e:
            if str(e) == (
            "Error occurs: Unable to delete data from read-only nodes. The data of the writable nodes has "
            "been cleared."):
                exit(0)
            traceback.print_exc()
            print(e)
            exit(1)
        finally:
            # 查询删除全部后剩余的数据
            try:
                dataset = self.session.query(["test.*"], 0, 10)
                print(dataset)
            except Exception as e:
                traceback.print_exc()
                print(e)
                exit(1)
            finally:

                return ""

    def deleteColumn(self):
        retStr = ""
        try:
            # 删除部分数据
            # 写入数据
            paths = ["test.a.a", "test.a.b", "test.b.b", "test.c.c"]
            timestamps = [5, 6, 7]
            values_list = [
                [None, None, 'a', 'b'],
                ['b', None, None, None],
                ['R', 'E', 'W', 'Q']
            ]
            data_type_list = [DataType.BINARY, DataType.BINARY, DataType.BINARY, DataType.BINARY]
            self.session.insert_row_records(paths, timestamps, values_list, data_type_list)
            self.session.delete_time_series("test.b.b")
        except Exception as e:
            if str(e) == (
            "Error occurs: Unable to delete data from read-only nodes. The data of the writable nodes has "
            "been cleared."):
                exit(0)
            print(e)
            exit(1)
        finally:
            # 查询删除后剩余的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)

            return retStr

    def deleteRow(self):
        retStr = ""
        try:
            # 这里因为key=1的这一行只有test.b.b有值，所以删除test.b.b这一列后这一整行数据就被删除了
            paths = ["test.a.a", "test.a.b", "test.b.b", "test.c.c"]
            timestamps = [5, 6, 7]
            values_list = [
                [None, None, 'a', 'b'],
                ['b', None, None, None],
                ['R', 'E', 'W', 'Q']
            ]
            data_type_list = [DataType.BINARY, DataType.BINARY, DataType.BINARY, DataType.BINARY]
            self.session.insert_row_records(paths, timestamps, values_list, data_type_list)
            self.session.delete_data("test.b.b", 1, 10)
        except Exception as e:
            if str(e) == (
            "Error occurs: Unable to delete data from read-only nodes. The data of the writable nodes has "
            "been cleared."):
                exit(0)
            print(e)
            exit(1)
        finally:
            # 查询删除后剩余的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)
            try:
                # 删除部分数据（设置为null
                self.session.batch_delete_data(["test.a.a", "test.a.b"], 5, 7)
            except Exception as e:
                if str(e) == (
                        "Error occurs: Unable to delete data from read-only nodes. The data of the writable nodes has "
                        "been cleared."):
                    exit(0)
                print(e)
                exit(1)
            finally:
                # 查询删除后剩余的数据
                dataset = self.session.query(["test.*"], 0, 10)
                retStr += str(dataset)

                return retStr

    def downsampleQuery(self):
        retStr = ""

        try:
            dataset = self.session.downsample_query(["test.*"], start_time=0, end_time=10, type=AggregateType.COUNT,
                                               precision=3)
            retStr += str(dataset)
        except Exception as e:
            print(e)
            exit(1)


        return retStr

    def exportToFile(self):
        try:
            # 将数据存入csv
            self.session.export_to_file("select * from test into outfile \"../generated/output.csv\" as csv with header;")
            # 将数据存入文件
            self.session.export_to_file("select * from test into outfile \"../generated\" as stream;")
        except Exception as e:
            traceback.print_exc()
            print(e)
            exit(1)

        return ""

    def getDebugInfo(self):
        retStr = ""
        dataset = self.session.get_debug_info("".encode(), DebugInfoType.GET_META)
        retStr += dataset.decode() + "\n"
        return retStr

    def insert(self):
        retStr = ""
        try:
            # 写入数据
            paths = ["test.a.a", "test.a.b", "test.b.b", "test.c.c"]
            timestamps = [5, 6, 7]
            values_list = [
                [None, None, 'a', 'b'],
                ['b', None, None, None],
                ['R', 'E', 'W', 'Q']
            ]
            data_type_list = [DataType.BINARY, DataType.BINARY, DataType.BINARY, DataType.BINARY]
            self.session.insert_row_records(paths, timestamps, values_list, data_type_list)
            # 查询写入的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)

            paths = ["test.a.a", "test.a.b", "test.b.b"]
            timestamps = [8, 9]
            values_list = [
                [None, 'a', 'b'],
                ['b', None, None]
            ]
            data_type_list = [DataType.BINARY, DataType.BINARY, DataType.BINARY]
            self.session.insert_non_aligned_row_records(paths, timestamps, values_list, data_type_list)
            # 查询写入的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)

            # 插入列
            paths = ["test.b.c"]
            timestamps = [6]
            values_list = [[1]]
            data_type_list = [DataType.INTEGER]
            self.session.insert_column_records(paths, timestamps, values_list, data_type_list)
            # 查询写入的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)

            # 插入列
            paths = ["test.b.c"]
            timestamps = [5]
            values_list = [[1]]
            data_type_list = [DataType.INTEGER]
            self.session.insert_non_aligned_column_records(paths, timestamps, values_list, data_type_list)
            # 查询写入的数据
            dataset = self.session.query(["test.*"], 0, 10)
            retStr += str(dataset)


            return retStr
        except Exception as e:
            print(e)
            exit(1)

    def insertBaseDataset(self):
        try:
            # 查询写入之前的数据
            dataset = self.session.query(["test.*"], 0, 10)
            print('Before insert: ', dataset)

            # 写入数据
            paths = ["test.a.a", "test.a.b", "test.b.b", "test.c.c"]
            timestamps = [0, 1, 2, 3]
            values_list = [
                ['a', 'b', None, None],
                [None, None, 'b', None],
                [None, None, None, 'c'],
                ['Q', 'W', 'E', 'R']
            ]
            data_type_list = [DataType.BINARY, DataType.BINARY, DataType.BINARY, DataType.BINARY]
            self.session.insert_row_records(paths, timestamps, values_list, data_type_list)
            # 查询写入的数据
            dataset = self.session.query(["test.*"], 0, 10)
            print(dataset)

        except Exception as e:
            traceback.print_exc()
            if str(e) == 'Error occurs: The query results contain overlapped keys.':
                exit(0)
            print(e)
            exit(1)
        finally:

            return ""

    def lastQuery(self):
        retStr = ""

        # 获取部分序列的最后一个数据点
        dataset = self.session.last_query(["test.*"], 0)
        retStr += str(dataset)


        return retStr

    def loadCSV(self):
        retStr = ""
        try:
            # calculate file path
            import os
            # print(os.getcwd())
            # 这里在用junit test运行时，对应的路径为： Iginx/test
            path = os.getcwd() + '/../session_py/tests/files/a.csv'
            statement = f"LOAD DATA FROM INFILE '{path}' AS CSV INTO test(key, a.a, a.b, b.b, c.c);"
            resp = self.session.load_csv(statement)
            retStr += str(resp) + "\n"

            # 使用 SQL 语句查询写入的数据
            dataset = self.session.execute_statement("select * from test;", fetch_size=2)

            columns = dataset.columns()
            for column in columns:
                retStr += column + "\t"
            retStr += "\n"

            while dataset.has_more():
                row = dataset.next()
                for field in row:
                    retStr += str(field) + "\t\t"
                retStr += "\n"

            dataset.close()


            return retStr
        except Exception as e:
            print(e)
            exit(1)

    def loadDirectory(self):
        retStr = ""
        try:
            # calculate file path
            import os
            path = os.getcwd() + '/../session_py/tests/dir'
            # path = 'dir/'
            self.session.load_directory(path)

            # 使用 SQL 语句查询写入的数据
            dataset = self.session.execute_statement("select * from dir;", fetch_size=2)

            columns = dataset.columns()
            for column in columns:
                retStr += column + "\t"
            retStr += "\n"

            while dataset.has_more():
                row = dataset.next()
                for field in row:
                    retStr += str(field) + "\t\t"
                retStr += "\n"
            retStr += "\n"
            dataset.close()

            return retStr
        except Exception as e:
            print(e)
            exit(1)

    def query(self):
        retStr = ""

        # 查询写入的数据，数据由PySessionIT测试写入
        dataset = self.session.query(["test.*"], 0, 10)
        retStr += str(dataset)
        # 转换为pandas.Dataframe
        df = dataset.to_df()
        retStr += str(df) + '\n'
        """
           key a.a.a a.a.b a.b.b a.c.c
        0    1  b'a'  b'b'  None  None
        1    2  None  None  b'b'  None
        2    3  None  None  None  b'c'
        3    4  b'Q'  b'W'  b'E'  b'R'
        """
        # 使用 SQL 语句查询写入的数据
        dataset = self.session.execute_statement("select * from test;", fetch_size=2)

        columns = dataset.columns()
        for column in columns:
            retStr += str(column) + '\t'
        retStr += '\n'

        while dataset.has_more():
            row = dataset.next()
            for field in row:
                retStr += str(field) + '\t\t'
            retStr += '\n'
        retStr += '\n'

        dataset.close()

        # 使用 SQL 语句查询副本数量
        replicaNum = self.session.get_replica_num()

        retStr += ('replicaNum: ' + str(replicaNum) + '\n')

        dataset.close()

        
        return retStr

    def showColumns(self):
        retStr = ""
        try:
            # 使用 SQL 语句查询时间序列
            dataset = self.session.execute_statement("SHOW COLUMNS;", fetch_size=2)

            columns = dataset.columns()
            for column in columns:
                retStr += str(column) + "\t"
            retStr += "\n"

            while dataset.has_more():
                row = dataset.next()
                for field in row:
                    retStr += str(field) + "\t\t"
                retStr += "\n"
            retStr += "\n"

            dataset.close()
            # 使用 list_time_series() 接口查询时间序列
            timeSeries = self.session.list_time_series()
            for ts in timeSeries:
                retStr += str(ts) + "\n"
            return retStr

        except Exception as e:
            print(e)
            exit(1)
