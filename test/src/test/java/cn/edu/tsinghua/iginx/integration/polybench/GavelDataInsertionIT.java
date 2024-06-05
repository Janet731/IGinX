package cn.edu.tsinghua.iginx.integration.polybench;

import com.mongodb.MongoClientSettings;
import com.mongodb.ServerAddress;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import org.bson.Document;
import org.junit.Test;
import org.postgresql.copy.CopyManager;
import org.postgresql.core.BaseConnection;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class GavelDataInsertionIT {
  private static final String dataPath = System.getProperty("user.dir") + "../Polystore-utils/gavel";

  public void GavelDataInsertionIT() {}
  @Test
  public void insertDataIntoPostgreSQL() {
    int port = 5432;
    String databaseName = "gavel";
    // PostgreSQL连接参数
    String url = String.format("jdbc:postgresql://localhost:%s/postgres", port);
    String user = "postgres";
    String password = "postgres";

    try (Connection conn = DriverManager.getConnection(url, user, password);
        Statement stmt = conn.createStatement()) {
      if (conn != null) {
        System.out.println("Connected to the PostgreSQL server successfully.");
        stmt.executeUpdate(String.format("DROP DATABASE IF EXISTS %s", databaseName));
        stmt.executeUpdate(String.format("CREATE DATABASE %s", databaseName));
        System.out.println(String.format("Database '%s' created successfully.", databaseName));
        // 关闭当前连接
        stmt.close();
        conn.close();
      }
    } catch (SQLException e) {
      System.out.println("SQLException: " + e.getMessage());
      e.printStackTrace();
    }
    // 连接到新创建的数据库
    String newDbUrl = String.format("jdbc:postgresql://localhost:5432/%s", databaseName);
    try (Connection conn = DriverManager.getConnection(newDbUrl, user, password);
        Statement stmt = conn.createStatement()) {
      if (conn != null) {
        System.out.println(String.format("Connected to '%s' successfully.", databaseName));

        // 创建表
        System.out.println("删除并创建表...");
        stmt.executeUpdate("DROP TABLE IF EXISTS \"user\";");
        stmt.executeUpdate("DROP TABLE IF EXISTS picture;");
        stmt.executeUpdate("DROP TABLE IF EXISTS category;");
        stmt.executeUpdate(
                "CREATE TABLE \"user\" (" +
                        "id INTEGER PRIMARY KEY, " +
                        "email VARCHAR(64), " +
                        "password VARCHAR(16), " +
                        "last_name VARCHAR(16), " +
                        "first_name VARCHAR(16), " +
                        "gender VARCHAR(6), " +
                        "birthday VARCHAR(16), " +
                        "country VARCHAR(64), " +
                        "city VARCHAR(32), " +
                        "zip_code VARCHAR(16));"
        );
        stmt.executeUpdate(
                "CREATE TABLE category (" +
                        "id INTEGER PRIMARY KEY, " +
                        "name VARCHAR(16));"
        );
        stmt.executeUpdate(
                "CREATE TABLE picture (" +
                        "filename VARCHAR(64) PRIMARY KEY, " +
                        "type INTEGER, " +
                        "size BIGINT, " +
                        "auction INTEGER);"
        );

        // 赋予权限
        System.out.println("赋予权限...");
        stmt.executeUpdate("GRANT ALL ON \"user\" TO postgres;");
        stmt.executeUpdate("GRANT ALL ON category TO postgres;");
        stmt.executeUpdate("GRANT ALL ON picture TO postgres;");

        // 导入 CSV 文件
        System.out.println("导入 CSV 文件...");
        stmt.executeUpdate("COPY \"user\" FROM '" + dataPath + "/user.csv' DELIMITER ',' CSV HEADER;");
        stmt.executeUpdate("COPY category FROM '" + dataPath + "/category.csv' DELIMITER ',' CSV HEADER;");
        stmt.executeUpdate("COPY picture FROM '" + dataPath + "/picture.csv' DELIMITER ',' CSV HEADER;");

        System.out.println("操作完成！");
      } else {
        System.out.println("Failed to make connection to the PostgreSQL server.");
      }
    } catch (SQLException e) {
      System.out.println("SQLException: " + e.getMessage());
      e.printStackTrace();
    }
  }
}
