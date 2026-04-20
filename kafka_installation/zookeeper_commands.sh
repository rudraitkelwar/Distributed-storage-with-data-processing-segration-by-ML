cd /opt/kafka
bin/zookeeper-server-start.sh config/zookeeper.properties

ps aux | grep -i zookeeper | grep -v grep