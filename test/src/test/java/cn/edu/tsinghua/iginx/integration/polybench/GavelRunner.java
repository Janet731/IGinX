package cn.edu.tsinghua.iginx.integration.polybench;

import cn.edu.tsinghua.iginx.exception.SessionException;
import cn.edu.tsinghua.iginx.integration.tool.MultiConnection;
import cn.edu.tsinghua.iginx.session.Session;
import cn.edu.tsinghua.iginx.session.SessionExecuteSqlResult;
import cn.edu.tsinghua.iginx.thrift.StorageEngineType;
import org.junit.Test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

public class GavelRunner {
  // host info
  protected static String defaultTestHost = "127.0.0.1";
  protected static int defaultTestPort = 6888;
  protected static String defaultTestUser = "root";
  protected static String defaultTestPass = "root";
  protected static MultiConnection conn;

  public static void GavelRunner(String[] args) {}

  public static void writeToFile(List<Double> avgTimeCosts, String fileName) throws IOException {
    Path filePath = Paths.get(fileName);
    List<String> lines = avgTimeCosts.stream().map(String::valueOf).collect(Collectors.toList());
    Files.write(filePath, lines);
  }

  public static List<Double> readFromFile(String fileName) throws IOException {
    Path filePath = Paths.get(fileName);
    List<String> lines = Files.readAllLines(filePath);
    return lines.stream().map(Double::valueOf).collect(Collectors.toList());
  }

  private List<List<String>> csvReader(String filePath) {
    List<List<String>> data = new ArrayList<>();
    boolean skipHeader = true;
    try (Scanner scanner = new Scanner(Paths.get(filePath))) {
      while (scanner.hasNextLine()) {
        String line = scanner.nextLine();
        if (skipHeader) {
          skipHeader = false;
          continue;
        }
        List<String> row = Arrays.asList(line.split("\\|"));
        data.add(row);
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    System.out.println(data);
    return data;
  }

  public static String readSqlFileAsString(String filePath) throws IOException {
    StringBuilder contentBuilder = new StringBuilder();
    try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
      String line;
      while ((line = br.readLine()) != null) {
        contentBuilder.append(line).append("\n");
      }
    }
    return contentBuilder.toString();
  }

  @Test
  public void test() {
    System.out.println("start");
    try {
      conn =
          new MultiConnection(
              new Session(defaultTestHost, defaultTestPort, defaultTestUser, defaultTestPass));
      conn.openSession();

      // 输出所有存储引擎
      String clusterInfo = conn.executeSql("SHOW CLUSTER INFO;").getResultInString(false,
 "");
      System.out.println(clusterInfo);

      // 添加存储引擎
      System.out.println("start adding storage engine");
      long startTime = System.currentTimeMillis();
      Map<String, String> pgMap = new HashMap<>();
      pgMap.put("engine", "postgresql");
      pgMap.put("has_data", "true");
      pgMap.put("is_read_only", "true");
      pgMap.put("username", "postgres");
      pgMap.put("password", "postgres");
      pgMap = Collections.unmodifiableMap(pgMap);
      conn.addStorageEngine("127.0.0.1", 5432, StorageEngineType.relational, pgMap);
      Map<String, String> iotdbMap = new HashMap<>();
      iotdbMap.put("has_data", "true");
      iotdbMap.put("is_read_only", "true");
      iotdbMap.put("username", "root");
      iotdbMap.put("password", "root");
      conn.addStorageEngine("127.0.0.1", 6667, StorageEngineType.iotdb12, iotdbMap);
      System.out.println(
          "end adding storage engine, time cost: "
              + (System.currentTimeMillis() - startTime)
              + "ms");

      // 输出所有存储引擎
      clusterInfo = conn.executeSql("SHOW CLUSTER INFO;").getResultInString(false, "");
      System.out.println(clusterInfo);
      // Long startTime;
      String columns = conn.executeSql("SHOW COLUMNS;").getResultInString(false, "");
      System.out.println(columns);

      // 关闭会话
      conn.closeSession();
    } catch (SessionException e) {
      throw new RuntimeException(e);
    }
  }
}
