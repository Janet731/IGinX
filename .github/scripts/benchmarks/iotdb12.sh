#!/bin/sh
set -e
echo "IOTDB_ROOT: $IOTDB_ROOT"
if [ "$RUNNER_OS" = "Linux" ]; then
  sh -c "cp -r $IOTDB_ROOT/ apache-iotdb-0.12.6-server-bin"
  sh -c "echo ========================="
  sh -c "ls apache-iotdb-0.12.6-server-bin"
  sh -c "sudo sed -i 's/^# compaction_strategy=.*$/compaction_strategy=NO_COMPACTION/g' apache-iotdb-0.12.6-server-bin/conf/iotdb-engine.properties"

  sh -c "sudo cp -r apache-iotdb-0.12.6-server-bin/ apache-iotdb-0.12.6-server-bin-6667"
  sh -c "sudo sed -i 's/# wal_buffer_size=16777216/wal_buffer_size=167772160/g' apache-iotdb-0.12.6-server-bin-6667/conf/iotdb-engine.properties"
  sh -c "sudo sed -i 's/6667/6667/g' apache-iotdb-0.12.6-server-bin-6667/conf/iotdb-engine.properties"
  sudo sh -c "cd apache-iotdb-0.12.6-server-bin-6667/; nohup sbin/start-server.sh &"

elif [ "$RUNNER_OS" = "Windows" ]; then
  sh -c "cp -r $IOTDB_ROOT/ apache-iotdb-0.12.6-server-bin"  
  sh -c "echo ========================="  
  sh -c "ls apache-iotdb-0.12.6-server-bin"  
  sh -c "sed -i 's/# wal_buffer_size=16777216/wal_buffer_size=167772160/g' apache-iotdb-0.12.6-server-bin/conf/iotdb-engine.properties"  
  sh -c "sed -i 's/^# compaction_strategy=.*$/compaction_strategy=NO_COMPACTION/g' apache-iotdb-0.12.6-server-bin/conf/iotdb-engine.properties"

  sh -c "cp -r apache-iotdb-0.12.6-server-bin/ apache-iotdb-0.12.6-server-bin-6667"
  sh -c "sed -i 's/6667/6667/g' apache-iotdb-0.12.6-server-bin-6667/conf/iotdb-engine.properties"
  sh -c "mkdir -p apache-iotdb-0.12.6-server-bin-6667/logs"
  sh -c "cd apache-iotdb-0.12.6-server-bin-6667/; nohup sbin/start-server.bat &"

elif [ "$RUNNER_OS" = "macOS" ]; then
  sh -c "cp -r $IOTDB_ROOT/ apache-iotdb-0.12.6-server-bin"
  sh -c "echo ========================="
  sh -c "ls apache-iotdb-0.12.6-server-bin"
  sh -c "sudo sed -i '' 's/^# compaction_strategy=.*$/compaction_strategy=NO_COMPACTION/' apache-iotdb-0.12.6-server-bin/conf/iotdb-engine.properties"

  sh -c "sudo cp -r apache-iotdb-0.12.6-server-bin/ apache-iotdb-0.12.6-server-bin-6667"
  sh -c "sudo sed -i '' 's/# wal_buffer_size=16777216/wal_buffer_size=167772160/' apache-iotdb-0.12.6-server-bin-6667/conf/iotdb-engine.properties"
  sh -c "sudo sed -i '' 's/6667/6667/' apache-iotdb-0.12.6-server-bin-6667/conf/iotdb-engine.properties"
  sudo sh -c "cd apache-iotdb-0.12.6-server-bin-6667/; nohup sbin/start-server.sh &"
else
  echo "$RUNNER_OS is not supported"
  exit 1
fi