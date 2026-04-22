

export SERVER6_IP=172.31.40.22

# Generate cluster ID
KAFKA_CLUSTER_ID=$(/opt/kafka/bin/kafka-storage.sh random-uuid)

sudo mkdir -p /var/lib/kafka/data
sudo chown -R $USER /var/lib/kafka

cat > /opt/kafka/config/kraft/server.properties << EOF
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@${SERVER6_IP}:9093

listeners=PLAINTEXT://${SERVER6_IP}:9092,CONTROLLER://${SERVER6_IP}:9093
advertised.listeners=PLAINTEXT://${SERVER6_IP}:9092
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
inter.broker.listener.name=PLAINTEXT
controller.listener.names=CONTROLLER
log.dirs=/var/lib/kafka/data
num.partitions=3
default.replication.factor=1
EOF

/opt/kafka/bin/kafka-storage.sh format \
  -t $KAFKA_CLUSTER_ID \
  -c /opt/kafka/config/kraft/server.properties

#/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties

# Start the Kafka server
cd /opt/kafka
sudo bin/kafka-server-start.sh config/server.properties

# Stop the Kafka server
cd /opt/kafka
sudo bin/kafka-server-stop.sh

